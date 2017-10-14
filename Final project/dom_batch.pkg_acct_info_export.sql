create or replace package dom_batch.pkg_acct_info_export
/**************************************************************************************************
**    PACKAGE:  pkg_acct_info_export
**
**    DESC:    This package contains the procedures to load account data.
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/
as
    procedure g_sp_acct_info_stg (i_bat_job_exec_trckg_id in number);

    procedure g_sp_acct_info_xport (i_bat_job_exec_trckg_id in number);

end pkg_acct_info_export;
/

show errors

create or replace package body dom_batch.pkg_acct_info_export
/**************************************************************************************************
**    PACKAGE:  pkg_acct_info_export
**
**    DESC:    This package contains the procedures to load account data.
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/
as
    -- -----------------
    -- Private Constants
    -- -----------------
    p_c_package_name             constant varchar2 (30) := 'pkg_acct_info_export';

    p_x_dml_errors                        exception;
    pragma exception_init (p_x_dml_errors, -24381);

    /****************************************************************************************
    **    PROCEDURE: g_sp_acct_info_stg
    **
    **    DESC:      This procedure extracts customer data for account info file.
    **
    **    HISTORY:   name                  date        comment
    **               --------------------  --------    -------------------------
    **               Chaitanya Shankari    04/2016     Initial Code
    *****************************************************************************************/

    procedure g_sp_acct_info_stg (i_bat_job_exec_trckg_id in number)
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
                dom_batch.t_cust_acct ca,
                dom_batch.t_cust_addr cad,
                dom_batch.t_cust_trnsctn ct
            where
                ca.cust_acct_id = cad.cust_acct_id and
                ca.cust_acct_id = ct.cust_acct_id and
                ct.trnsctn_date between sysdate - 30 and sysdate
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

        -- Set the application module info
        dbms_application_info.set_module ('Procedure', l_c_identifier);

        -- Set the application client info
        dbms_application_info.set_client_info ('Fetching customer account data');

            dom_batch.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );

        -- Create new partition
        dom_batch.pkg_job_api.g_sp_add_partition
        (
            i_table_owner           => 'DOM_BATCH',
            i_table_name            => 'T_CUST_ACCT_INFO_XPORT',
            i_table_partition_name  => i_bat_job_exec_trckg_id
        );

        -- Open the cursor
        open l_v_acct_info_cur;

        -- Loop through the table
        loop

            l_v_error_count     := 0;

            -- Grab a chunk (10k) of records
            fetch l_v_acct_info_cur
                bulk
                    collect into l_v_acct_info_tab
                limit 10000;

            -- Exit when we are out of records
            exit when l_v_acct_info_tab.count = 0;

            dbms_application_info.set_client_info ('inserting into dom_batch.t_cust_acct_info_xport');

            begin

                forall i in 1 .. l_v_acct_info_tab.count save exceptions

                    insert into
                        dom_batch.t_cust_acct_info_xport
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

                        dom_batch.pkg_job_api.g_sp_insrt_err_trckg_id
                        (
                            i_job_trckng_id     => i_bat_job_exec_trckg_id,
                            i_job_err_rcrd      => l_v_acct_info_tab (l_v_error_index).cust_acct_id,
                            i_job_err_msg       => l_v_error_message
                        );
                        l_v_acct_info_tab.delete (l_v_error_index);
                    end loop;

            end;

            -- Increment the total record count
            l_v_rec_prcsd_count := l_v_rec_prcsd_count + l_v_acct_info_tab.count;

            -- Commit the chunk to keep resource usage low
            commit;

            -- Wait between chunks to lessen impact
--            sys.dbms_lock.sleep(0.1);

        end loop;

        -- close the cursor
        close l_v_acct_info_cur;

        l_v_total_rec_count      := l_v_rec_prcsd_count + l_v_total_error_count;

        dom_batch.pkg_job_api.g_sp_updt_stp_trckg_det
        (
            i_job_stp_trckng_id         => l_v_bat_job_exec_step_id,
            i_job_stp_prcss_rcrd_cnt    => l_v_rec_prcsd_count,
            i_job_stp_stts_id           => 3
        );

        -- Set the application client info
        dbms_application_info.set_client_info ('Finished loading internal data to export table');

        -- Set statistics on export table
        dbms_stats.set_table_stats
        (
            ownname    => 'DOM_BATCH',
            tabname    => 'T_CUST_ACCT_INFO_XPORT',
            partname   => 'P_' || i_bat_job_exec_trckg_id,
            avgrlen    => 55,
            numrows    => l_v_rec_prcsd_count
        );

        -- Store the actual records inserted into export table
        l_v_main_rec_prcsd_count := l_v_rec_prcsd_count;


        -- setup tracking id for next job. 
        dom_batch.pkg_job_api.g_sp_insrt_id_with_prnt_id
        (
        i_job_trckng_id    => i_bat_job_exec_trckg_id,
        i_job_dfntn_id     => 1235,
        o_job_trckng_id    => l_v_sec_chld_trckg_id
        );

    exception
        when others
        then

            -- Close cursor if open
            if (l_v_acct_info_cur%isopen)
            then

                close l_v_acct_info_cur;

            end if;

            -- Set step tracking with failure info
            dom_batch.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 4
            );

            -- Update execution tracking record with failure info
            dom_batch.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 4
            );

            raise;

    end g_sp_acct_info_stg;

    /****************************************************************************
    **    PROCEDURE:  g_sp_acct_info_xport
    **
    **    DESC:       This procedure generates dialer exclusion file.
    **
    **    HISTORY:    NAME                  DATE        COMMENT
    **                --------------------  --------    -----------------------
    **                Narendar Bobbiligama  02/2014     Initial Code
    *****************************************************************************/

    procedure g_sp_acct_info_xport (i_bat_job_exec_trckg_id in number)
    is
        --  -----------------
        --  cursor
        --  -----------------

        cursor l_v_acct_info_xprt_cur
        (
            l_v_tracking_id number
        )
        is
            select --+ pkg_acct_info_export.g_sp_acct_info_xport.l_v_acct_info_xprt_cur
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
                dom_batch.t_cust_acct_info_xport xport
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
                                           := 'CREDIT_CLCTN_DIALER_EXCLUSION_FILE' || to_char (sysdate, '_YYYYMMDDHH24MI') || '.txt';
        l_v_out_file_dir               varchar2 (30) := 'BATCH_EXPORT';
        l_v_exists                     boolean;
        l_v_file_length                number;
        l_v_block_size                 number;

        --  ---------------------
        --  local constants
        --  ---------------------

        l_c_stored_proc_name  constant varchar2 (30) := 'g_sp_acct_info_xport';
    begin

        --  ----------------------------------------------
        --  Initialization
        --  ----------------------------------------------

        -- Set the application module info
        dbms_application_info.set_module (p_c_package_name, l_c_stored_proc_name || ': writing dialer exclusion file');

        -- Set the application client info
        dbms_application_info.set_client_info ('Looping through t_cust_acct_info_xport');


        --  ----------------------------------------------
        --  Setup step record for load process
        --  ----------------------------------------------
            dom_batch.pkg_job_api.g_sp_insrt_stp_trckg_id
            (
                i_job_trckng_id => i_bat_job_exec_trckg_id,
                o_job_stp_trckng_id => l_v_bat_job_exec_step_id
            );

        --  ----------------------------------------------
        --  Get parent tracking id to read export table
        --  ----------------------------------------------
        l_v_prnt_bat_job_exec_trckg_id := dom_batch.pkg_job_api.g_sf_get_parnt_bat_job_exec_no (i_bat_job_exec_trckg_id);

        --  ------------------------------------------------------
        --  Write data from the cursor into dialer exclusion file
        --  ------------------------------------------------------

        -- Open file for writing
        l_v_out_file_handle            := utl_file.fopen (l_v_out_file_dir, l_v_out_file_name, 'W', 3200);

        -- Open the cursor to write the file
        open l_v_acct_info_xprt_cur (l_v_prnt_bat_job_exec_trckg_id);

        loop

            l_v_error_count     := 0;

            -- Set client info
            dbms_application_info.set_client_info ('Selecting from t_cust_acct_info_xport');

            -- Grab a chunk of records
            fetch l_v_acct_info_xprt_cur
                bulk
                    collect into l_v_acct_info_xprt_tab
                limit 10000;

            -- Exit when we are out of records
            exit when l_v_acct_info_xprt_tab.count = 0;

            -- Insert the chunk into the target table
            begin

                for i in 1 .. l_v_acct_info_xprt_tab.count loop
                    -- write rec to file
                    utl_file.put_line (l_v_out_file_handle, l_v_acct_info_xprt_tab (i).acct_info_file_rec, true);
                end loop;
            exception
                when p_x_dml_errors
                then

                    -- Set error counts
                    l_v_error_count       := sql%bulk_exceptions.count;
                    l_v_total_error_count := l_v_total_error_count + l_v_error_count;

                    -- Insert to error table
                    for j in 1 .. l_v_error_count loop

                        l_v_error_index   := sql%bulk_exceptions (j).error_index;
                        l_v_error_code    := sql%bulk_exceptions (j).error_code;
                        l_v_error_message := sqlerrm (-l_v_error_code);

                        dom_batch.pkg_job_api.g_sp_insrt_err_trckg_id
                        (
                            i_job_trckng_id     => i_bat_job_exec_trckg_id,
                            i_job_err_rcrd      => l_v_acct_info_xprt_tab (l_v_error_index).acct_info_file_rec,
                            i_job_err_msg       => l_v_error_message
                        );

                    end loop;

            end;

            -- Increment the record count
            l_v_rec_prcsd_count := l_v_rec_prcsd_count + l_v_acct_info_xprt_tab.count - l_v_error_count;

            -- Check error percentage
            dom_batch.pkg_job_api.g_sp_updt_stp_trckg_det
            (
                i_job_stp_trckng_id         => l_v_bat_job_exec_step_id,
                i_job_stp_prcss_rcrd_cnt    => l_v_rec_prcsd_count
            );

            -- Clean-up
            l_v_acct_info_xprt_tab.delete;

            -- Commit the chunk to keep resource usage low
            commit;

            -- Wait between chunks to lessen impact
--            dbms_lock.sleep(0.1);

        end loop;

        -- Close the cursor
        close l_v_acct_info_xprt_cur;

        -- Close file handle
        utl_file.fclose (l_v_out_file_handle);

        -- Set the application client info
        dbms_application_info.set_client_info ('Finished writing the dialer exclusion file');

    exception
        when others
        then

            -- Close cursor if open
            if (l_v_acct_info_xprt_cur%isopen)
            then

                close l_v_acct_info_xprt_cur;

            end if;

            -- Close file handle
            utl_file.fgetattr (l_v_out_file_dir, l_v_out_file_name, l_v_exists, l_v_file_length, l_v_block_size);

            if l_v_exists
            then
                utl_file.fclose (l_v_out_file_handle);
            end if;

            -- Set step tracking with failure info
            dom_batch.pkg_job_api.g_sp_updt_stp_trckg_det
            (
               i_job_stp_trckng_id  => i_bat_job_exec_trckg_id,
               i_job_stp_stts_id    => 1
            );

            -- Update execution tracking record with failure info
            dom_batch.pkg_job_api.g_sp_updt_job_trckg_det
            (
                i_job_trckng_id    => i_bat_job_exec_trckg_id,
                i_job_exec_stts_id => 2
            );

            raise;

    end g_sp_acct_info_xport;

end pkg_acct_info_export;
/

show errors;