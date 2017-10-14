/**************************************************************************************************
**    Script to rollback  stage and destination tables 
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    06/2016     Initial Code
**************************************************************************************************/
/* 
      Export from table to table - Roll back script for Stage table and final table
*/

-- Drop tables

drop table job_frmwrk.t_cust_acct_info_dest_tbl cascade constraints;

drop table job_frmwrk.t_cust_acct_info_stg cascade constraints;

delete from job_frmwrk.tb_job_stp_trckng where job_trckng_id in (select job_trckng_id from job_frmwrk.tb_job_trckng where job_dfntn_id in (2001,2002));

delete from job_frmwrk.tb_job_trckng where job_dfntn_id in (2001,2002);

delete from job_frmwrk.tb_job_scrpt_dfntn where job_dfntn_id  in (2001,2002);

delete from job_frmwrk.tb_job_def where job_dfntn_id in (2001,2002);

commit;