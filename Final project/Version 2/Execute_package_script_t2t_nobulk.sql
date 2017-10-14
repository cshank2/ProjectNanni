CREATE OR REPLACE PROCEDURE G_SP_EXECUTE_CUST_XPORT_T_NOBK 

/*********************************************************************************************************
**    OBJECT NAME:  g_sp_execute_cust_xport_t_nobk
**
**    DESC:    This procedure is used to execute the ETL package.  
**             The procedure does the following:
**             a. Invokes the procedure to creates and inserts the job tracking id for a given 
**                job definition id.
**             b. Invoke the procedure to extract the requested data from the customer tables onto 
**                the staging table.
**             c. Invokes the procedure to retrieve the job-tracking id.
**             d. Invokes the procedure to extract the data from staging table onto the destination table                
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    06/2016     Initial Code
*******************************************************************************************************/
AS 

    l_v_stg_job_trckg_id number;
    l_v_xport_job_trckg_id number;
BEGIN

    dbms_output.put_line ('Inserting staging tracking id for account export job. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_job_api.g_sp_insrt_trckg_id
    (
    i_job_dfntn_id  =>  2001,
    o_job_trckng_id => l_v_stg_job_trckg_id
    ); 
    
    dbms_output.put_line ('Starting account info stage job. Batch tracking id : '|| l_v_stg_job_trckg_id ||' Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_acct_info_stg_nobulk.g_sp_acct_info_stg2(l_v_stg_job_trckg_id);

    dbms_output.put_line ('Retrieving export job tracking id. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_job_api.g_sp_rtrv_trckg_id
    (
    i_job_dfntn_id  =>  2002,
    i_parnt_job_trckng_id  => l_v_stg_job_trckg_id,
    o_job_trckng_id       => l_v_xport_job_trckg_id
    ); 

    dbms_output.put_line ('Starting account info export job. Batch tracking id : '|| l_v_xport_job_trckg_id ||' Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_acct_info_stg_nobulk.g_sp_acct_info_xport_tb_nobulk(l_v_xport_job_trckg_id);  
    
    dbms_output.put_line ('Finished account info export into destination table without using bulk inserts and writes. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));  

end;
