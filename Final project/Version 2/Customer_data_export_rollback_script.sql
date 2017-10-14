/**************************************************************************************************
**    Script to rollback  stage tables 
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/
-- Drop stage table

drop table job_frmwrk.t_cust_acct_info_xport cascade constraints;

delete from job_frmwrk.tb_job_stp_trckng where job_trckng_id in (select job_trckng_id from job_frmwrk.tb_job_trckng where job_dfntn_id in (1234,1235));

delete from job_frmwrk.tb_job_trckng where job_dfntn_id in (1234,1235);

delete from job_frmwrk.tb_job_scrpt_dfntn where job_dfntn_id  in (1234,1235);

delete from job_frmwrk.tb_job_def where job_dfntn_id in (1234,1235);

commit;