create or replace package job_frmwrk.pkg_job_api
as

/**************************************************************************************************
**    PACKAGE:  pkg_job_api
**
**    DESC:    This package contains proecedure and fuctions that would be used to run batch
**             jobs in framework
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    02/2016     Initial Code
**************************************************************************************************/

    procedure g_sp_insrt_trckg_id
    (
        i_job_dfntn_id  in     number,
        o_job_trckng_id    out number
    );
    
    procedure g_sp_insrt_id_with_prnt_id
    (
        i_job_trckng_id     in     number,
        i_job_dfntn_id      in     number,
        o_job_trckng_id    out     number
    );

    procedure g_sp_insrt_stp_trckg_id
    (
        i_job_trckng_id     in     number,
        o_job_stp_trckng_id    out number
    );

    procedure g_sp_updt_job_trckg_det
    (
        i_job_trckng_id    in number,
        i_job_exec_stts_id in number,
        i_job_trckng_drtn  in number := null
    );

    procedure g_sp_updt_stp_trckg_det
    (
        i_job_stp_trckng_id      in number,
        i_job_stp_prcss_rcrd_cnt in number := null,
        i_job_stp_stts_id        in number := 2
    );

    procedure g_sp_insrt_err_trckg_id
    (
        i_job_trckng_id in number,
        i_job_err_rcrd  in varchar,
        i_job_err_msg   in varchar
    );

    procedure g_sp_exec_job
    (
        i_job_schema    in varchar2,
        i_job_pkg       in varchar2,
        i_job_proc      in varchar2,
        i_job_trckng_id in number
    );

    procedure g_sp_drop_partition
    (
        i_table_owner          in varchar2,
        i_table_name           in varchar2,
        i_table_partition_name in varchar
    );

    procedure g_sp_add_partition
    (
        i_table_owner          in varchar2,
        i_table_name           in varchar2,
        i_table_partition_name in varchar
    );
    
    procedure g_sp_rtrv_trckg_id
    (
        i_job_dfntn_id         in number,
        i_parnt_job_trckng_id  in number,
        o_job_trckng_id       out number
    );

    function g_sf_get_parnt_bat_job_exec_no (i_bat_job_exec_trckg_id in number)
        return number;

end pkg_job_api;
/

show errors;


create or replace package body job_frmwrk.pkg_job_api
as

/**************************************************************************************************
**    OBJECT NAME:  pkg_job_api
**
**    DESC:    This package contains proecedure and fuctions that would be used to run batch
**             jobs in framework
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    02/2016     Initial Code
**************************************************************************************************/


    procedure g_sp_insrt_trckg_id
    (
        i_job_dfntn_id  in     number,
        o_job_trckng_id    out number
    )
    is
    
/**************************************************************************************************
**    OBJECT NAME:  pkg_job_api.g_sp_insrt_trckg_id
**
**    DESC:    This procedure will insert a tracking id for a job to be executed.
**             This takes job defition id as input paramenter and return tracking id.
**             jobs in framework
**
**************************************************************************************************/

    begin

        insert into
            job_frmwrk.tb_job_trckng
            (
                job_trckng_id,
                job_dfntn_id,
                job_trckng_strt_tme,
                job_trckng_end_tme,
                job_exec_stts_id,
                job_trckng_drtn,
                job_trckng_insrt_dt
            )
        values
            (
                job_frmwrk.sq_job_trckng_id.nextval,
                i_job_dfntn_id,
                sysdate,
                null,
                1,
                null,
                sysdate
            )
        returning
            job_trckng_id
        into
            o_job_trckng_id;

        commit;

    end;

    
     procedure g_sp_insrt_id_with_prnt_id
    (
        i_job_trckng_id     in     number,
        i_job_dfntn_id      in     number,
        o_job_trckng_id    out     number
    ) is

/**************************************************************************************************
**    OBJECT NAME:  g_sp_insrt_id_with_prnt_id
**
**    DESC:    This procedure will insert parent tracking id for a job 
**             This takes job defition id, and job tracking id as input paramenter and return 
**             next tracking id for the jobs in framework
**
**************************************************************************************************/

    begin

        insert into
            job_frmwrk.tb_job_trckng
            (
                job_trckng_id,
                parnt_job_trckng_id,
                job_dfntn_id,
                job_trckng_strt_tme,
                job_trckng_end_tme,
                job_exec_stts_id,
                job_trckng_drtn,
                job_trckng_insrt_dt
            )
        values
            (
                job_frmwrk.sq_job_trckng_id.nextval,
                i_job_trckng_id,
                i_job_dfntn_id,
                sysdate,
                null,
                1,
                null,
                sysdate
            )
        returning
            job_trckng_id
        into
            o_job_trckng_id;

        commit;

    end;

    procedure g_sp_insrt_stp_trckg_id
    (
        i_job_trckng_id     in     number,
        o_job_stp_trckng_id    out number
    )
    is
    
/**************************************************************************************************
**    OBJECT NAME:  g_sp_insrt_stp_trckg_id
**
**    DESC:    This procedure will insert a step tracking id for a job to be executed. 
**             This takes job tracking id as input paramenter and return step tracking id
**
**************************************************************************************************/

    begin

        insert into
            job_frmwrk.tb_job_stp_trckng
            (
                job_stp_trckng_id,
                job_trckng_id,
                job_stp_prcss_rcrd_cnt,
                job_stp_stts_id,
                job_stp_insrt_dt,
                job_stp_upd_dt,
                job_stp_strt_tme,
                job_stp_end_tme
            )
        values
            (
                job_frmwrk.seq_job_stp_trckng_id.nextval,
                i_job_trckng_id,
                null,
                1,
                sysdate,
                null,
                sysdate,
                null
            )
        returning
            job_stp_trckng_id
        into
            o_job_stp_trckng_id;

        commit;
    end;

    procedure g_sp_updt_job_trckg_det
    (
        i_job_trckng_id    in number,
        i_job_exec_stts_id in number,
        i_job_trckng_drtn  in number := null
    )
    is
/**************************************************************************************************
**    OBJECT NAME:  g_sp_updt_job_trckg_det
**
**    DESC:    This procedure will update job execution status, job duration, update date and end
**             date of the job with the help of key job tracking id
**
**************************************************************************************************/
    
    begin

        update
            job_frmwrk.tb_job_trckng
        set
            job_trckng_end_tme = sysdate,
            job_exec_stts_id   = i_job_exec_stts_id,
            job_trckng_drtn    = i_job_trckng_drtn,
            job_trckng_upd_dt  = sysdate
        where
            job_trckng_id = i_job_trckng_id;

        commit;
    end;

    procedure g_sp_updt_stp_trckg_det
    (
        i_job_stp_trckng_id      in number,
        i_job_stp_prcss_rcrd_cnt in number := null,
        i_job_stp_stts_id        in number := 2
    )
    is
/**************************************************************************************************
**    OBJECT NAME:  g_sp_updt_stp_trckg_det
**
**    DESC:    This procedure will update job execution status, step processing record count,
**             step update date and  step end time with the help of key step tracking id
**
**************************************************************************************************/

    begin

        update
            job_frmwrk.tb_job_stp_trckng
        set
            job_stp_prcss_rcrd_cnt = i_job_stp_prcss_rcrd_cnt,
            job_stp_stts_id        = i_job_stp_stts_id,
            job_stp_upd_dt         = sysdate,
            job_stp_end_tme        = sysdate
        where
            job_stp_trckng_id = i_job_stp_trckng_id;

        commit;
    end;

    procedure g_sp_insrt_err_trckg_id
    (
        i_job_trckng_id in number,
        i_job_err_rcrd  in varchar,
        i_job_err_msg   in varchar
    )
    is

/**************************************************************************************************
**    OBJECT NAME:  g_sp_insrt_err_trckg_id
**
**    DESC:    This procedure will insert a error tracking id, error record, error message and 
**             date for a job executed.
**              This takes job tracking id as input paramenter and return error tracking id.
**
**************************************************************************************************/
    begin

        insert into
            job_frmwrk.tb_job_err_trckng
            (
                job_err_trckng_id,
                job_trckng_id,
                job_err_rcrd,
                job_err_insrt_dt,
                job_err_msg
            )
        values
            (
                job_frmwrk.seq_job_err_trckng_id.nextval,
                i_job_trckng_id,
                i_job_err_rcrd,
                sysdate,
                i_job_err_msg
            );

        commit;
    end;

    procedure g_sp_exec_job
    (
        i_job_schema    in varchar2,
        i_job_pkg       in varchar2,
        i_job_proc      in varchar2,
        i_job_trckng_id in number
    )
    is
    
/**************************************************************************************************
**    OBJECT NAME:  g_sp_exec_job
**
**    DESC:    This procedure does the following 
**             - Updates the job status in Job Tracking table as 'job started'
**             - executes job1 package with job tracking id as input
**             - Updates the job status in Job Tracking tables as 'job completed' after
**               successfull execution of the job1 package
**              This takes job tracking id as input paramenter.
**
**************************************************************************************************/
        
        l_v_sql varchar2 (2000);
    begin

        update
            tb_job_trckng
        set
            tb_job_trckng.job_exec_stts_id      =
                (select
                     tb_job_exec_stts_lkp.job_exec_stts_id
                 from
                     tb_job_exec_stts_lkp
                 where
                     job_exec_stts_msg = 'JOB STARTED')
        where
            job_trckng_id = i_job_trckng_id;

        commit;

        -- with the help of the dynamic sql execute the procedure of the package (given as input)

        --i_job_schema.i_job_pkg.i_job_proc (i_job_trckng_id);

        l_v_sql := 'execute ' || i_job_schema || '.' || i_job_pkg || '.' || i_job_proc || ' (' || i_job_trckng_id || ');';

        execute immediate l_v_sql;

        commit;

        -- for the job with the given tracking id, update the status of the job to 'job completed'

        update
            tb_job_trckng
        set
            tb_job_trckng.job_exec_stts_id      =
                (select
                     tb_job_exec_stts_lkp.job_exec_stts_id
                 from
                     tb_job_exec_stts_lkp
                 where
                     job_exec_stts_msg = 'JOB COMPLETED')
        where
            job_trckng_id = i_job_trckng_id;

        commit;
    end;

    procedure g_sp_rtrv_trckg_id
    (
        i_job_dfntn_id         in number,
        i_parnt_job_trckng_id  in number,
        o_job_trckng_id       out number
    )
    is

/**************************************************************************************************
**    OBJECT NAME:  g_sp_rtrv_trckg_id
**
**    DESC:    This procedure will retrieve job tracking id. 
**             It takes job definition id and parent job tracking id as input and returns 
**             job tracking id.
**
**************************************************************************************************/

    begin
    
        select
            job_trckng_id
        into
            o_job_trckng_id
        from
            job_frmwrk.tb_job_trckng
        where
             parnt_job_trckng_id = i_parnt_job_trckng_id
         and job_dfntn_id = i_job_dfntn_id; 
    exception
    when no_data_found then
    
        dbms_output.put_line('Batch tracking id is not found for parent tracking id '||i_parnt_job_trckng_id);
        raise;
    
    end;


    function g_sf_get_parnt_bat_job_exec_no (i_bat_job_exec_trckg_id in number)
        return number
    is
    
/**************************************************************************************************
**    OBJECT NAME:  g_sf_get_parnt_bat_job_exec_no
**
**    DESC:    This function will retrieve parent job tracking id 
**             This takes job tracking id as input and returns parent job tracking id 
**
**************************************************************************************************/

        l_v_parnt_bat_job_exec_id number;
    begin

        select
            parnt_job_trckng_id
        into
            l_v_parnt_bat_job_exec_id
        from
            job_frmwrk.tb_job_trckng
        where
            job_trckng_id = i_bat_job_exec_trckg_id;

        return l_v_parnt_bat_job_exec_id;

    end g_sf_get_parnt_bat_job_exec_no;

end;
/

show errors;