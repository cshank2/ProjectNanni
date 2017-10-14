create or replace package job_frmwrk.pkg_acct_info_export_no_bulk
as

/*********************************************************************************************************
**    PACKAGE:  pkg_acct_info_export_no_bulk
**
**    DESC:    This package is used to extract the requested information from the tables and load
**             onto the file. This package consists of procedures to extract and load the data.  
**             The package does the following:
**             a. 	Executes a procedure to extract the requested customer details i.e. 
**                  Customer account id, First name, Last name, Address line1, Address line2, State, 
**                  Zip code and Total transaction amount; by joining the customer tables (Customer 
**                  account table, customer address table and transaction table)
**
**                  The extracted information is inserted into staging table.
**             b. Executes a procedure to fetch the customer details from the staging and writes to a file.
**
**
**    NOTE:   In this package, one record at a time is fetched from the table
**
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
*******************************************************************************************************/

    procedure g_sp_acct_info_stg (i_bat_job_exec_trckg_id in number);

    procedure g_sp_acct_info_xport (i_bat_job_exec_trckg_id in number);

end pkg_acct_info_export_no_bulk;
/

show errors

create or replace package body job_frmwrk.pkg_acct_info_export_no_bulk

/*****************************************************************************************************
**    PACKAGE:  pkg_acct_info_export_no_bulk
**
**    DESC:    This package contains the procedures extract and load account data
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
*****************************************************************************************************/

as
    -- -----------------
    -- Private Constants
    -- -----------------
    
    p_c_package_name             constant varchar2 (30) := 'pkg_acct_info_export_no_bulk';

    p_x_dml_errors                        exception;
    pragma exception_init (p_x_dml_errors, -24381);

    procedure g_sp_acct_info_stg (i_bat_job_exec_trckg_id in number)
    
/**************************************************************************************************
**    OBJECT NAME: g_sp_acct_info_stg
**
**    DESC:      This procedure extracts customer data from customer tables
**               and inserts into staging table
**
**    HISTORY:   name                  date        comment
**               --------------------  --------    -------------------------
**               Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/
    
    is
        --  ---------------------
        --  cursors
        --  ---------------------
    
        cursor l_v_acct_info_cur
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
                ct.trnsctn_date between sysdate - 90 and sysdate
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

        type l_typ_acct_info_tab is table of l_v_acct_info_cur%rowtype;
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


        for cur_acct_info_cur in l_v_acct_info_cur 
        loop 

                    insert into
                        job_frmwrk.t_cust_acct_info_xport
                        (
                          BAT_JOB_EXEC_TRCKG_ID  ,
                          CUST_ACCT_ID          , 
                          FIRST_NAME             ,
                          LAST_NAME              ,
                          ADDRESS_LINE_1         ,
                          ADDRESS_LINE_2         ,
                          STATE                  ,
                          ZIPCODE                ,
                          TOTAL_TRNSCTN_AMT      ,
                          INS_DATE               
                        )
                    values
                        (
                            cur_acct_info_cur.bat_job_exec_trckg_id,
                            cur_acct_info_cur.cust_acct_id,
                            cur_acct_info_cur.first_name,
                            cur_acct_info_cur.last_name,
                            cur_acct_info_cur.address_line_1,
                            cur_acct_info_cur.address_line_2,
                            cur_acct_info_cur.state,
                            cur_acct_info_cur.zipcode,
                            cur_acct_info_cur.total_trnsctn_amt,
                            cur_acct_info_cur.ins_date
                        );

        end loop;
        
        --  ---------------------
        -- Set the application client info
        --  ---------------------
        
        dbms_application_info.set_client_info ('Finished loading internal data to export table');

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
        i_job_dfntn_id     => 1235,
        o_job_trckng_id    => l_v_sec_chld_trckg_id
        );

    exception
        when others
        then

            --  ---------------------
            -- Close cursor if open
            --  ---------------------
            
            if (l_v_acct_info_cur%isopen)
            then

                close l_v_acct_info_cur;

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

    end g_sp_acct_info_stg;


    procedure g_sp_acct_info_xport (i_bat_job_exec_trckg_id in number)

/**************************************************************************************************
**    OBJECT NAME: g_sp_acct_info_xport
**
**    DESC:      This procedure extracts customer details from staging table and writes to a file
**
**    HISTORY:   name                  date        comment
**               --------------------  --------    -------------------------
**               Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/

    is
        --  -----------------
        --  cursor
        --  -----------------

        cursor l_v_acct_info_xprt_cur
        (
            l_v_tracking_id number
        )
        is
            select --+ pkg_acct_info_export_no_bulk.g_sp_acct_info_xport.l_v_acct_info_xprt_cur
                xport.cust_acct_id      ||'|' ||
                xport.first_name        ||'|' ||
                xport.last_name         ||'|' ||
                xport.address_line_1    ||'|' ||
                xport.address_line_2    ||'|' ||
                xport.state             ||'|' ||
                xport.zipcode           ||'|' ||
                xport.total_trnsctn_amt
                    as acct_info_file_rec
            from
                job_frmwrk.t_cust_acct_info_xport xport
            where
                xport.bat_job_exec_trckg_id = l_v_tracking_id
            order by
                xport.cust_acct_id;

        --  -----------------
        --  local variables
        --  -----------------

        type l_typ_acct_info_xprt_tab is table of l_v_acct_info_xprt_cur%rowtype;
        l_v_acct_info_xprt_tab         l_typ_acct_info_xprt_tab;

        l_v_bat_job_exec_step_id       number;
        l_v_prnt_bat_job_exec_trckg_id number;
        l_v_chld_bat_job_exec_trckg_id number;
        l_v_exec_file_id               number;

        l_v_rec_prcsd_count            number := 0;
        l_v_error_count                number := 0;
        l_v_error_index                number;
        l_v_error_code                 number;
        l_v_error_message              varchar2 (4000);

        l_v_total_error_count          number := 0;
        l_v_total_rec_count            number := 0;

        --  ---------------------
        --  file variables
        --  ---------------------

        l_v_out_file_handle            utl_file.file_type;
        l_v_out_file_name              varchar2 (60)
                                           := 'CUSTOMER_ACCOUNT_INFO_FILE' || to_char (sysdate, '_YYYYMMDDHH24MI') || '.txt';
        l_v_out_file_dir               varchar2 (30) := 'EXT_TAB_DIR';
        l_v_exists                     boolean;
        l_v_file_length                number;
        l_v_block_size                 number;

        --  ---------------------
        --  local constants
        --  ---------------------

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_xport';
    begin

        --  -----------------
        -- Set the application module info
        --  -----------------
        
        dbms_application_info.set_module (p_c_package_name, l_c_stored_proc_name || ': writing a file');
      
        --  -----------------
        -- Set the application client info
        --  -----------------
      
        dbms_application_info.set_client_info ('Looping through t_cust_acct_info_xport');


        --  ----------------------------------------------
        --  Setup step record for load process
        --  ----------------------------------------------
        
            job_frmwrk.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );

        --  ----------------------------------------------
        --  Get parent tracking id to read export table
        --  ----------------------------------------------
        
        l_v_prnt_bat_job_exec_trckg_id := job_frmwrk.pkg_job_api.g_sf_get_parnt_bat_job_exec_no (i_bat_job_exec_trckg_id);

        --  ------------------------------------------------------
        --  Write data from the cursor into  file
        --  ------------------------------------------------------

        --  -----------------
        -- Open file for writing
        --  -----------------
        
        l_v_out_file_handle            := utl_file.fopen (l_v_out_file_dir, l_v_out_file_name, 'W', 3200);

        for cur_acct_info_xprt_cur in l_v_acct_info_xprt_cur(l_v_prnt_bat_job_exec_trckg_id) loop
            
            --  ----------------- 
            -- write rec to file
            --  -----------------
           
           utl_file.put_line (l_v_out_file_handle, cur_acct_info_xprt_cur.acct_info_file_rec, true);
        end loop;
        
        --  -----------------
        -- Close file handle
        --  -----------------
        
        utl_file.fclose (l_v_out_file_handle);

        --  -----------------
        -- Set the application client info
        --  -----------------
        
        dbms_application_info.set_client_info ('Finished writing the file');

    exception
        when others
        then

             --  -----------------
             -- Close cursor if open
             --  -----------------
          
           if (l_v_acct_info_xprt_cur%isopen)
            then

                close l_v_acct_info_xprt_cur;

            end if;

            --  -----------------
            -- Close file handle
            --  -----------------
        
            utl_file.fgetattr (l_v_out_file_dir, l_v_out_file_name, l_v_exists, l_v_file_length, l_v_block_size);

            if l_v_exists
            then
                utl_file.fclose (l_v_out_file_handle);
            end if;

            --  -----------------
            -- Set step tracking with failure info
            --  -----------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 1
            );

            --  -----------------
            -- Update execution tracking record with failure info
            --  -----------------
            
            job_frmwrk.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 2
            );

            raise;

    end g_sp_acct_info_xport;

end pkg_acct_info_export_no_bulk;
/

show errors;