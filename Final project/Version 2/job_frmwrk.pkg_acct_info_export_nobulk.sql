create or replace PACKAGE job_frmwrk.pkg_acct_info_stg_nobulk 
/**************************************************************************************************
**    PACKAGE:  pkg_acct_info_stg_nobulk
**
**    DESC:    This package contains the procedures to load account data into the stage table.
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/

AS 

    procedure g_sp_acct_info_stg2 (i_bat_job_exec_trckg_id in number);

    procedure g_sp_acct_info_xport_tb_nobulk (i_bat_job_exec_trckg_id in number);

END pkg_acct_info_stg_nobulk;
/

show errors

create or replace package body            job_frmwrk.pkg_acct_info_stg_nobulk
/**************************************************************************************************
**    PACKAGE:  pkg_acct_info_stg
**
**    DESC:    This package contains the procedures to load account data.
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
************************************************************************************************/
as
    -- -----------------
    -- Private Constants
    -- -----------------
    p_c_package_name             constant varchar2 (30) := 'pkg_acct_info_stg2';

    p_x_dml_errors                        exception;
    pragma exception_init (p_x_dml_errors, -24381);

    /****************************************************************************************
    **    PROCEDURE: g_sp_acct_info_stg2
    **
    **    DESC:      This procedure extracts customer data for account info file.
    **
    **    HISTORY:   name                  date        comment
    **               --------------------  --------    -------------------------
    **               Chaitanya Shankari    04/2016     Initial Code
    *****************************************************************************************/

    procedure g_sp_acct_info_stg2 (i_bat_job_exec_trckg_id in number)
    is
        --  ---------------------
        --  cursors
        --  ---------------------
        cursor l_v_acct_info_cur2
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

        type l_typ_acct_info_tab is table of l_v_acct_info_cur2%rowtype;
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

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_stg2';
        l_c_identifier        constant varchar2 (61) := p_c_package_name || l_c_stored_proc_name;
    begin

        -- Set the application module info
        dbms_application_info.set_module ('Procedure', l_c_identifier);

        -- Set the application client info
        dbms_application_info.set_client_info ('Fetching customer account data');

            job_frmwrk.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );

            dbms_application_info.set_client_info ('inserting into job_frmwrk.t_cust_acct_info_stg');

        for cur_acct_info_cur in l_v_acct_info_cur2 
        loop 

                    insert into
                        job_frmwrk.t_cust_acct_info_stg
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
         dbms_application_info.set_client_info ('Finished loading internal data to export table');

        -- Store the actual records inserted into export table
        l_v_main_rec_prcsd_count := l_v_rec_prcsd_count;


        -- setup tracking id for next job. 
        job_frmwrk.pkg_job_api.g_sp_insrt_id_with_prnt_id
        (
        i_job_trckng_id    => i_bat_job_exec_trckg_id,
        i_job_dfntn_id     => 2002,
        o_job_trckng_id    => l_v_sec_chld_trckg_id
        );

    exception
        when others
        then

            -- Close cursor if open
            if (l_v_acct_info_cur2%isopen)
            then

                close l_v_acct_info_cur2;

            end if;

            -- Set step tracking with failure info
            job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 4
            );

            -- Update execution tracking record with failure info
            job_frmwrk.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 4
            );

            raise;

    end g_sp_acct_info_stg2;

    /****************************************************************************
    **    PROCEDURE:  g_sp_acct_info_xport_tbl_nobulk
    **
    **    DESC:       This procedure exports the account info to destination table.
    **
    **    HISTORY:    NAME                  DATE        COMMENT
    **                --------------------  --------    -----------------------
    **                Chaitanya Shankari  02/2014     Initial Code
    *****************************************************************************/

    procedure g_sp_acct_info_xport_tb_nobulk (i_bat_job_exec_trckg_id in number)
    is
        --  -----------------
        --  cursor
        --  -----------------

        cursor l_v_acct_info_xprt_tbl_cur2 (l_v_prnt_bat_job_exec_trckg_id number)
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
                ins_date
            from
                job_frmwrk.t_cust_acct_info_stg
            where
                bat_job_exec_trckg_id = l_v_prnt_bat_job_exec_trckg_id
            order by
                cust_acct_id;
                
                
                
                --  ---------------------
        --  local variables
        --  ---------------------

        type l_typ_acct_info_tab is table of l_v_acct_info_xprt_tbl_cur2%rowtype;
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

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_stg_nobulk';
        l_c_identifier        constant varchar2 (61) := p_c_package_name || l_c_stored_proc_name;
    begin

        -- Set the application module info
        dbms_application_info.set_module ('Procedure', l_c_identifier);

        -- Set the application client info
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
        
         dbms_application_info.set_client_info ('inserting into job_frmwrk.t_cust_acct_info_dest_tbl');


        for cur_acct_info_cur2 in l_v_acct_info_xprt_tbl_cur2(l_v_prnt_bat_job_exec_trckg_id) 
        loop 

                    insert into
                        job_frmwrk.t_cust_acct_info_dest_tbl
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
                            cur_acct_info_cur2.bat_job_exec_trckg_id,
                            cur_acct_info_cur2.cust_acct_id,
                            cur_acct_info_cur2.first_name,
                            cur_acct_info_cur2.last_name,
                            cur_acct_info_cur2.address_line_1,
                            cur_acct_info_cur2.address_line_2,
                            cur_acct_info_cur2.state,
                            cur_acct_info_cur2.zipcode,
                            cur_acct_info_cur2.total_trnsctn_amt,
                            cur_acct_info_cur2.ins_date
                        );

        end loop;



        -- Set the application client info
        dbms_application_info.set_client_info ('Finished loading account data from stage table to dest table');

    exception
        when others
        then

            -- Close cursor if open
            if (l_v_acct_info_xprt_tbl_cur2%isopen)
            then

                close l_v_acct_info_xprt_tbl_cur2;

            end if;

            -- Set step tracking with failure info
            job_frmwrk.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 4
            );

            -- Update execution tracking record with failure info
            job_frmwrk.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 4
            );

            raise;

    end g_sp_acct_info_xport_tb_nobulk;
end pkg_acct_info_stg_nobulk;
/
show errors;