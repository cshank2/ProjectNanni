/**************************************************************************************************
**    Script to create Stage and destination tables and meta data for batch job 
**    Stage table name - t_cust_acct_info_stg
**    Destination table name -  t_cust_acct_info_dest_tbl
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    06/2016     Initial Code
**************************************************************************************************/

/* 
      Export from table to table - Create stage table, final table and meta data for batch job
*/

-- Create stage table

create table job_frmwrk.t_cust_acct_info_stg
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

-- Create destination table

create table job_frmwrk.t_cust_acct_info_dest_tbl
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
    
--   Insert meta data

insert into job_frmwrk.tb_job_def values (2001, 'Test job to export to stage table', sysdate, null, 'Y');
insert into job_frmwrk.tb_job_def values (2002, 'Test job to export from stage to dest table', sysdate, null, 'Y');

insert into job_frmwrk.tb_job_scrpt_dfntn values (3,2001,'job_frmwrk','PKG_ACCT_INFO_EXPORT_TBL2TBL','G_SP_ACCT_INFO_STG1',sysdate, null, 'Y');
insert into job_frmwrk.tb_job_scrpt_dfntn values (4,2002,'job_frmwrk','PKG_ACCT_INFO_EXPORT_TBL2TBL','G_SP_ACCT_INFO_XPORT_TBL',sysdate, null, 'Y');

commit;