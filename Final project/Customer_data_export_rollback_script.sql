-- Stage table for batch job
drop table dom_batch.t_cust_acct_info_xport cascade constraints;

-- Batch job meta data

delete from dom_batch.tb_job_stp_trckng where job_trckng_id in (select job_trckng_id from dom_batch.tb_job_trckng where job_dfntn_id in (1234,1235));

delete from dom_batch.tb_job_trckng where job_dfntn_id in (1234,1235);

delete from dom_batch.tb_job_scrpt_dfntn where job_dfntn_id  in (1234,1235);

delete from dom_batch.tb_job_def where job_dfntn_id in (1234,1235);

commit;