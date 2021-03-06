create or replace procedure job_frmwrk.g_sp_execute_cust_xport 

/*********************************************************************************************************
**    OBJECT NAME:  g_sp_execute_cust_xport
**
**    DESC:    This procedure is used to execute the ETL package.  
**             The procedure does the following:
**             a. Invokes the procedure to creates and inserts the job tracking id for a given 
**                job definition id.
**             b. Invoke the procedure to extract the requested data from the customer tables onto 
**                the staging table.
**             c. Invokes the procedure to retrieve the job-tracking id.
**             d. Invokes the procedure to extract the data from staging table onto the file                 
****
**
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
*******************************************************************************************************/

as
    l_v_stg_job_trckg_id number;
    l_v_xport_job_trckg_id number;
begin
   
    dbms_output.put_line ('Inserting staging tracking id for account export job. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_job_api.g_sp_insrt_trckg_id
    (
    i_job_dfntn_id  =>  1234,
    o_job_trckng_id => l_v_stg_job_trckg_id
    ); 
    
    dbms_output.put_line ('Starting account info stage job. Batch tracking id : '|| l_v_stg_job_trckg_id ||' Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_acct_info_export.g_sp_acct_info_stg(l_v_stg_job_trckg_id);

    dbms_output.put_line ('Retrieving export job tracking id. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_job_api.g_sp_rtrv_trckg_id
    (
    i_job_dfntn_id  =>  1235,
    i_parnt_job_trckng_id  => l_v_stg_job_trckg_id,
    o_job_trckng_id       => l_v_xport_job_trckg_id
    ); 

    dbms_output.put_line ('Starting account info export job. Batch tracking id : '|| l_v_xport_job_trckg_id ||' Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    job_frmwrk.pkg_acct_info_export.g_sp_acct_info_xport(l_v_xport_job_trckg_id);  
    
    dbms_output.put_line ('Finished account info export using bulk inserts and writes. Time '||to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));  

end;
/
show errors;
