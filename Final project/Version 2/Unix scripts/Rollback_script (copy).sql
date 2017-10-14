/**************************************************************************************************
**    Script to rollback  job framework tables 
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    01/2016     Initial Code
**************************************************************************************************/

drop table job_frmwrk.tb_job_def cascade constraints;

drop table job_frmwrk.tb_job_err_trckng cascade constraints;

drop table job_frmwrk.tb_job_exec_stts_lkp cascade constraints;

drop table job_frmwrk.tb_job_scrpt_dfntn cascade constraints;

drop table job_frmwrk.tb_job_stp_trckng cascade constraints;

drop table job_frmwrk.tb_job_trckng  cascade constraints;

drop sequence job_frmwrk.seq_job_err_trckng_id;

drop sequence job_frmwrk.sq_job_scrpt_dfntn_id;

drop sequence job_frmwrk.seq_job_stp_trckng_id;

drop sequence job_frmwrk.sq_job_trckng_id;
