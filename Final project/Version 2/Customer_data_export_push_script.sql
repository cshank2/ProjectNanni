/**************************************************************************************************
**    Script to create Stage table and meta data for batch job 
**    Stage table name - t_cust_acct_info_xport
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/

--Create stage table

create table job_frmwrk.t_cust_acct_info_xport
(
    bat_job_exec_trckg_id number not null,
    cust_acct_id          number,
    first_name            varchar2 (100),
    last_name             varchar2 (100),
    address_line_1        varchar2 (1000),
    address_line_2        varchar2 (1000),
    state                 varchar2 (100),
    zipcode               varchar2 (50),
    total_trnsctn_amt     number (20, 2),
    ins_date              date
);

-- Insert meta data

insert into job_frmwrk.tb_job_def values (1234, 'First test job stage', sysdate, null, 'Y');
insert into job_frmwrk.tb_job_def values (1235, 'First test job export', sysdate, null, 'Y');

insert into job_frmwrk.tb_job_scrpt_dfntn values (1,1234,'job_frmwrk','PKG_ACCT_INFO_EXPORT','G_SP_ACCT_INFO_STG',sysdate, null, 'Y');
insert into job_frmwrk.tb_job_scrpt_dfntn values (2,1235,'job_frmwrk','PKG_ACCT_INFO_EXPORT','G_SP_ACCT_INFO_XPORT',sysdate, null, 'Y');

commit;