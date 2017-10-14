/**************************************************************************************************
**    Script to rollback  Customer tables 
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/

drop table job_frmwrk.t_cust_acct cascade constraints;

drop sequence job_frmwrk.sq_cust_acct;

drop table job_frmwrk.t_cust_acct_hist cascade constraints;

drop sequence job_frmwrk.sq_cust_acct_hist;

drop table job_frmwrk.t_cust_addr cascade constraints;

drop sequence job_frmwrk.sq_cust_addr;

drop table job_frmwrk.t_cust_addr_hist cascade constraints;

drop sequence job_frmwrk.sq_cust_addr_hist;

drop table job_frmwrk.t_cust_trnsctn cascade constraints;

drop sequence job_frmwrk.sq_cust_trnsctn;

drop table job_frmwrk.t_cust_trnsctn_hist cascade constraints;

drop sequence job_frmwrk.sq_cust_trnsctn_hist;