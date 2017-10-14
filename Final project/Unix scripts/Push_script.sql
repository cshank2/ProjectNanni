create table dom_batch.tb_job_def
(
    job_dfntn_id       number not null,
    job_dfntn_desc     varchar2 (250) not null,
    job_dfntn_insrt_dt date not null,
    job_dfntn_upd_dt   date,
    job_dfntn_actv_flg char (1) not null
);

alter table dom_batch.tb_job_def add constraint pk_job_dfntn_id primary key (job_dfntn_id);

create table dom_batch.tb_job_err_trckng
(
    job_err_trckng_id number not null,
    job_trckng_id     number not null,
    job_err_rcrd      varchar2 (4000) not null,
    job_err_insrt_dt  date not null,
    job_err_msg       varchar2 (250)
);

alter table dom_batch.tb_job_err_trckng add constraint pk_job_err_trckng_id
primary key ( job_err_trckng_id );

create table dom_batch.tb_job_exec_stts_lkp
(
    job_exec_stts_id  number not null,
    job_exec_stts_msg varchar2 (250) not null,
    job_exec_insrt_dt date not null,
    job_exec_upd_dt   date
);

alter table dom_batch.tb_job_exec_stts_lkp add constraint pk_job_exec_stts_id
primary key ( job_exec_stts_id );

create table dom_batch.tb_job_scrpt_dfntn
(
    job_scrpt_dfntn_id number not null,
    job_dfntn_id       number not null,
    job_scrpt_schm_nm  varchar2 (30) not null,
    job_scrpt_pckg_nm  varchar2 (30) not null,
    job_scrpt_prcdr_nm varchar2 (30),
    job_scrpt_insrt_dt date not null,
    job_scrpt_updt_dt  date,
    job_scrpt_actv_flg char (1) not null
);

alter table dom_batch.tb_job_scrpt_dfntn add constraint pk_job_scrpt_dfntn_id
primary key ( job_scrpt_dfntn_id );

create table dom_batch.tb_job_stp_trckng
(
    job_stp_trckng_id      number not null,
    job_trckng_id          number not null,
    job_stp_prcss_rcrd_cnt number,
    job_stp_stts_id        number not null,
    job_stp_insrt_dt       date not null,
    job_stp_upd_dt         date,
    job_stp_strt_tme       date not null,
    job_stp_end_tme        date
);

alter table dom_batch.tb_job_stp_trckng add constraint pk_job_stp_trckng_id
primary key ( job_stp_trckng_id );

create table dom_batch.tb_job_trckng
(
    job_trckng_id       number not null,
    parnt_job_trckng_id number, 
    job_dfntn_id        number not null,
    job_trckng_strt_tme date not null,
    job_trckng_end_tme  date,
    job_exec_stts_id    number not null,
    job_trckng_drtn     number,
    job_trckng_insrt_dt date not null,
    job_trckng_upd_dt   date
);

alter table dom_batch.tb_job_trckng add constraint pk_job_trckng_id primary
key ( job_trckng_id );

alter table dom_batch.tb_job_err_trckng add constraint fk_tb_job_err_trckng_1
foreign key ( job_trckng_id ) references dom_batch.tb_job_trckng (job_trckng_id );

alter table dom_batch.tb_job_scrpt_dfntn add constraint fk_tb_job_scrpt_dfntn
foreign key ( job_dfntn_id ) references dom_batch.tb_job_def ( job_dfntn_id );

alter table dom_batch.tb_job_stp_trckng add constraint fk_tb_job_stp_trckng_1
foreign key ( job_trckng_id ) references dom_batch.tb_job_trckng (job_trckng_id );

alter table dom_batch.tb_job_stp_trckng add constraint fk_tb_job_stp_trckng_2
foreign key ( job_stp_stts_id ) references dom_batch.tb_job_exec_stts_lkp (job_exec_stts_id );

alter table dom_batch.tb_job_trckng add constraint fk_tb_job_trckng_1 foreign
key ( job_dfntn_id ) references dom_batch.tb_job_def ( job_dfntn_id );

alter table dom_batch.tb_job_trckng add constraint fk_tb_job_trckng_2 foreign
key ( job_exec_stts_id ) references dom_batch.tb_job_exec_stts_lkp (job_exec_stts_id );

create sequence dom_batch.seq_job_err_trckng_id
    start with 1
    nocache;

create or replace trigger dom_batch.tb_job_err_trckng_job_err_trck
    before insert
    on dom_batch.tb_job_err_trckng
    for each row
    when (new.job_err_trckng_id is null)
begin
    :new.job_err_trckng_id := dom_batch.seq_job_err_trckng_id.nextval;
end;
/

create sequence dom_batch.sq_job_scrpt_dfntn_id
    start with 1
    nocache;

create or replace trigger dom_batch.tb_job_scrpt_dfntn_job_scrpt_d
    before insert
    on dom_batch.tb_job_scrpt_dfntn
    for each row
    when (new.job_scrpt_dfntn_id is null)
begin
    :new.job_scrpt_dfntn_id := dom_batch.sq_job_scrpt_dfntn_id.nextval;
end;
/

create sequence dom_batch.seq_job_stp_trckng_id
    start with 1
    nocache;

create or replace trigger dom_batch.tb_job_stp_trckng_job_stp_trck
    before insert
    on dom_batch.tb_job_stp_trckng
    for each row
    when (new.job_stp_trckng_id is null)
begin
    :new.job_stp_trckng_id := dom_batch.seq_job_stp_trckng_id.nextval;
end;
/

create sequence dom_batch.sq_job_trckng_id
    start with 1
    nocache;

create or replace trigger dom_batch.tb_job_trckng_job_trckng_id
    before insert
    on dom_batch.tb_job_trckng
    for each row
    when (new.job_trckng_id is null)
begin
    :new.job_trckng_id := dom_batch.sq_job_trckng_id.nextval;
end;
/

-- Setup framework lookup values

-- Status lookup values
insert into dom_batch.tb_job_exec_stts_lkp 
select 1,'Job Started',sysdate, null from dual union all 
select 2,'Job in progress',sysdate, null from dual union all
select 3,'Job finished successfully',sysdate, null from dual union all
select 4,'Job failed',sysdate, null from dual;

commit;