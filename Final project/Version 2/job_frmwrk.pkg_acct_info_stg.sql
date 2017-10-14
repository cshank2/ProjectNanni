create or replace package job_frmwrk.PKG_ACCT_INFO_STG

/*********************************************************************************************************
**    PACKAGE:  PKG_ACCT_INFO_STG
**
**    DESC:    This package is used to extract the requested information from the tables and load
**             onto another table. This package consists of procedures to extract and load the data.  
**             The package does the following:
**             a. 	Executes a procedure to extract the requested customer details i.e. 
**                  Customer account id, First name, Last name, Address line1, Address line2, State, 
**                  Zip code and Total transaction amount; by joining the customer tables (Customer 
**                  account table, customer address table and transaction table)
**
**                  The extracted information is inserted into staging table.
**             b. Executes a procedure to fetch the customer details from the staging and 
**                inserts into destination table.
**
**
**    NOTE:   In this package, chunk of records (limit 10000 as defined in the script) are extracted 
**            at a time from a table using bulk collect.
**
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    06/2016     Initial Code
*******************************************************************************************************/

as 

    procedure g_sp_acct_info_stg1 (i_bat_job_exec_trckg_id in number);

    procedure g_sp_acct_info_xport_tbl (i_bat_job_exec_trckg_id in number);

END PKG_ACCT_INFO_STG;
/

show errors;

create or replace package body            pkg_acct_info_stg

/*****************************************************************************************************
**    PACKAGE:  pkg_acct_info_stg
**
**    DESC:    This package contains the procedures extract and load account data using bulk collect
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    06/2016     Initial Code
*****************************************************************************************************/

as
    -- -----------------
    -- Private Constants
    -- -----------------
    
    p_c_package_name             constant varchar2 (30) := 'pkg_acct_info_stg';

    p_x_dml_errors                        exception;
    pragma exception_init (p_x_dml_errors, -24381);


    procedure g_sp_acct_info_stg1 (i_bat_job_exec_trckg_id in number)

/**************************************************************************************************
**    OBJECT NAME: g_sp_acct_info_stg1
**
**    DESC:      This procedure extracts customer data from customer tables using bulk collect
**               and inserts into staging table
**
**    HISTORY:   name                  date        comment
**               --------------------  --------    -------------------------
**               Chaitanya Shankari    06/2016     Initial Code
**************************************************************************************************/

    is
        --  ---------------------
        --  cursors
        --  ---------------------
        
        cursor l_v_acct_info_cur1
        is
            select
                i_bat_job_exec_trckg_id bat_job_exec_trckg_id,
                ca.cust_acct_id cust_acct_id,
                ca.first_name first_name,
                ca.last_name last_name,
                cad.address_line_1 address_line_1,
                cad.address_line_2 address_line_2,
                cad.state state,
                cad.zipcode zipcode,
                sum (ct.trnsctn_amt) total_trnsctn_amt,
                sysdate ins_date
            from
                job_frmwrk.t_cust_acct ca,
                job_frmwrk.t_cust_addr cad,
                job_frmwrk.t_cust_trnsctn ct
            where
                ca.cust_acct_id = cad.cust_acct_id and
                ca.cust_acct_id = ct.cust_acct_id and
                ct.trnsctn_date between sysdate - 180 and sysdate
            group by
                ca.cust_acct_id,
                ca.first_name,
                ca.last_name,
                cad.address_line_1,
                cad.address_line_2,
                cad.state,
                cad.zipcode
            order by
                ca.last_name;

        --  ---------------------
        --  local variables
        --  ---------------------

        type l_typ_acct_info_tab is table of l_v_acct_info_cur1%rowtype;
        l_v_acct_info_tab              l_typ_acct_info_tab;


        l_v_rec_prcsd_count            number := 0;
        l_v_main_rec_prcsd_count       number := 0;
        l_v_error_count                number := 0;
        l_v_error_index                number;
        l_v_error_code                 number;
        l_v_error_message              varchar2 (4000);

        l_v_bat_job_exec_step_id       number;
        l_v_total_error_count          number := 0;
        l_v_chld_bat_job_exec_trckg_id number;
        l_v_sec_chld_trckg_id          number;
        l_v_bad_count                  number := 0;
        l_v_total_rec_count            number := 0;

        --  ---------------------
        --  local constants
        --  ---------------------

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_stg';
        l_c_identifier        constant varchar2 (61) := p_c_package_name || l_c_stored_proc_name;
    
    begin

        --  ---------------------
        -- Set the application module info
        --  ---------------------
            
        dbms_application_info.set_module ('Procedure', l_c_identifier);

        --  ---------------------
        -- Set the application client info
        --  ---------------------
                
        dbms_application_info.set_client_info ('Fetching customer account data');

            job_frmwrk.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );

        --  ---------------------
        -- Open the cursor
        --  ---------------------
     
        open l_v_acct_info_cur1;

        --  ---------------------
        -- Loop through the table
        --  ---------------------
        
        loop

            l_v_error_count     := 0;

            --  ---------------------
            -- Grab a chunk (10k) of records
            --  ------------------
            
            fetch l_v_acct_info_cur1
                bulk
                    collect into l_v_acct_info_tab
                limit 10000;

          --  ----------------------
          -- Exit when we are out of records
          --  ---------------------
                  
            exit when l_v_acct_info_tab.count = 0;

            dbms_application_info.set_client_info ('inserting into job_frmwrk.t_cust_acct_info_stg');

            begin

                forall i in 1 .. l_v_acct_info_tab.count save exceptions

                    insert into
                        job_frmwrk.t_cust_acct_info_stg
                    values
                        l_v_acct_info_tab (i);
            exception
                when p_x_dml_errors
                then

                    l_v_error_count       := sql%bulk_exceptions.count;
                    l_v_total_error_count := l_v_total_error_count + l_v_error_count;

                    for j in 1 .. l_v_error_count loop
                        l_v_error_index   := sql%bulk_exceptions (j).error_index;
                        l_v_error_code    := sql%bulk_exceptions (j).error_code;
                        l_v_error_message := sqlerrm (-l_v_error_code);

                        job_frmwrk.pkg_job_api.g_sp_insrt_err_trckg_id
                        (
                            i_job_trckng_id     => i_bat_job_exec_trckg_id,
                            i_job_err_rcrd      => l_v_acct_info_tab (l_v_error_index).cust_acct_id,
                            i_job_err_msg       => l_v_error_message
                        );
                        l_v_acct_info_tab.delete (l_v_error_index);
                    end loop;

            end;

            --  ---------------------
            -- Increment the total record count
            --  --------------------- 
            
            l_v_rec_prcsd_count := l_v_rec_prcsd_count + l_v_acct_info_tab.count;

            --  -----------
            -- Commit the chunk to keep resource usage low
            --  ---------------------   
       
            commit;

        end loop;
        --  ---------------------
        -- close the cursor
        --  ---------------------
        
        close l_v_acct_info_cur1;

        l_v_total_rec_count      := l_v_rec_prcsd_count + l_v_total_error_count;

        job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
        (
            i_job_stp_trckng_id         => l_v_bat_job_exec_step_id,
            i_job_stp_prcss_rcrd_cnt    => l_v_rec_prcsd_count,
            i_job_stp_stts_id           => 3
        );

        --  ---------------------
        -- Set the application client info
        --  ---------------------
        
        dbms_application_info.set_client_info ('Finished loading internal data to stage table');

        --  ---------------------
        -- Store the actual records inserted into export table
        --  ---------------------
        
        l_v_main_rec_prcsd_count := l_v_rec_prcsd_count;

        --  ---------------------
        -- setup tracking id for next job. 
        --  ---------------------
                
        job_frmwrk.pkg_job_api.g_sp_insrt_id_with_prnt_id
        (
        i_job_trckng_id    => i_bat_job_exec_trckg_id,
        i_job_dfntn_id     => 2002,
        o_job_trckng_id    => l_v_sec_chld_trckg_id
        );

    exception
        when others
        then

            --  ---------------------  
            -- Close cursor if open
            --  ---------------------
        
            if (l_v_acct_info_cur1%isopen)
            then

                close l_v_acct_info_cur1;

            end if;
        
            --  ---------------------
            -- Set step tracking with failure info
            --  ---------------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 4
            );

            --  ---------------------
            -- Update execution tracking record with failure info
            --  ---------------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 4
            );

            raise;

    end g_sp_acct_info_stg1;

    
    procedure g_sp_acct_info_xport_tbl (i_bat_job_exec_trckg_id in number)
    
/**************************************************************************************************
**    OBJECT NAME: g_sp_acct_info_xport_tbl
**
**    DESC:      This procedure extracts customer data from staging table and inserts into
**               destination table
**
**    HISTORY:   name                  date        comment
**               --------------------  --------    -------------------------
**               Chaitanya Shankari    06/2016     Initial Code
**************************************************************************************************/
    
    is
        --  -----------------
        --  cursor
        --  -----------------

        cursor l_v_acct_info_xprt_tbl_cur (l_v_prnt_bat_job_exec_trckg_id number)
        is
            select 
                bat_job_exec_trckg_id,
                cust_acct_id,
                first_name,
                last_name,
                address_line_1,
                address_line_2,
                state,
                zipcode,
                total_trnsctn_amt,
                sysdate
            from
                job_frmwrk.t_cust_acct_info_stg
            where
                bat_job_exec_trckg_id = l_v_prnt_bat_job_exec_trckg_id
            order by
                cust_acct_id;
                        
        --  ---------------------
        --  local variables
        --  ---------------------

        type l_typ_acct_info_tab is table of l_v_acct_info_xprt_tbl_cur%rowtype;
        l_v_acct_info_tab              l_typ_acct_info_tab;

        l_v_prnt_bat_job_exec_trckg_id number :=0;
        l_v_rec_prcsd_count            number := 0;
        l_v_main_rec_prcsd_count       number := 0;
        l_v_error_count                number := 0;
        l_v_error_index                number;
        l_v_error_code                 number;
        l_v_error_message              varchar2 (4000);

        l_v_bat_job_exec_step_id       number;
        l_v_total_error_count          number := 0;
        l_v_chld_bat_job_exec_trckg_id number;
        l_v_sec_chld_trckg_id          number;
        l_v_bad_count                  number := 0;
        l_v_total_rec_count            number := 0;

        --  ---------------------
        --  local constants
        --  ---------------------

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_stg';
        l_c_identifier        constant varchar2 (61) := p_c_package_name || l_c_stored_proc_name;
    begin
    
        --  -----------------
        -- Set the application module info
        --  -----------------
    
        dbms_application_info.set_module ('Procedure', l_c_identifier);

        --  -----------------
        -- Set the application client info
        --  -----------------
                
        dbms_application_info.set_client_info ('Fetching customer account data from stage table');

            job_frmwrk.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );
        
        --  ----------------------------------------------
        --  Get parent tracking id to read export table
        --  ----------------------------------------------
        
        l_v_prnt_bat_job_exec_trckg_id := job_frmwrk.pkg_job_api.g_sf_get_parnt_bat_job_exec_no (i_bat_job_exec_trckg_id);

        --  -----------------
        -- Open the cursor
        --  -----------------
              
        open l_v_acct_info_xprt_tbl_cur(l_v_prnt_bat_job_exec_trckg_id);

        --  -----------------
        -- Loop through the table
        --  -----------------
        
        loop

            l_v_error_count     := 0;

            --  -----------------
            -- Grab a chunk (10k) of records
            --  -----------------
            
            fetch l_v_acct_info_xprt_tbl_cur
                bulk
                    collect into l_v_acct_info_tab
                limit 10000;

            --  -----------------
            -- Exit when we are out of records
            --  -----------------
            
            exit when l_v_acct_info_tab.count = 0;

            dbms_application_info.set_client_info ('inserting into job_frmwrk.t_cust_acct_info_dest_tbl');

            begin

                forall i in 1 .. l_v_acct_info_tab.count save exceptions

                    insert into
                        job_frmwrk.t_cust_acct_info_dest_tbl
                    values
                        l_v_acct_info_tab (i);  
            exception
                when p_x_dml_errors
                then

                    l_v_error_count       := sql%bulk_exceptions.count;
                    l_v_total_error_count := l_v_total_error_count + l_v_error_count;

                    for j in 1 .. l_v_error_count loop
                        l_v_error_index   := sql%bulk_exceptions (j).error_index;
                        l_v_error_code    := sql%bulk_exceptions (j).error_code;
                        l_v_error_message := sqlerrm (-l_v_error_code);

                        job_frmwrk.pkg_job_api.g_sp_insrt_err_trckg_id
                        (
                            i_job_trckng_id     => i_bat_job_exec_trckg_id,
                            i_job_err_rcrd      => l_v_acct_info_tab (l_v_error_index).cust_acct_id,
                            i_job_err_msg       => l_v_error_message
                        );
                        l_v_acct_info_tab.delete (l_v_error_index);
                    end loop;

            end;

            --  -----------------
            -- Increment the total record count
            --  -----------------
            
            l_v_rec_prcsd_count := l_v_rec_prcsd_count + l_v_acct_info_tab.count;

            --  -----------------
            -- Commit the chunk to keep resource usage low
            --  -----------------
            commit;


        end loop; 

        --  -----------------
        -- close the cursor
        --  -----------------
       
        close l_v_acct_info_xprt_tbl_cur;

        l_v_total_rec_count      := l_v_rec_prcsd_count + l_v_total_error_count;

        job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
        (
            i_job_stp_trckng_id         => l_v_bat_job_exec_step_id,
            i_job_stp_prcss_rcrd_cnt    => l_v_rec_prcsd_count,
            i_job_stp_stts_id           => 3
        );

        --  -----------------
        -- Set the application client info
        --  -----------------
        
        dbms_application_info.set_client_info ('Finished loading account data from stage table to dest table');


        --  -----------------
        -- Store the actual records inserted into export table
        --  -----------------
        
        l_v_main_rec_prcsd_count := l_v_rec_prcsd_count;

    exception
        when others
        then

            --  -----------------
            -- Close cursor if open
            --  -----------------      
            
            if (l_v_acct_info_xprt_tbl_cur%isopen)
            then

                close l_v_acct_info_xprt_tbl_cur;

            end if;

            --  -----------------
            -- Set step tracking with failure info
            --  -----------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 4
            );

            --  -----------------
            -- Update execution tracking record with failure info
            --  -----------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 4
            );

            raise;

    end g_sp_acct_info_xport_tbl;
end pkg_acct_info_stg;
/
show errors;