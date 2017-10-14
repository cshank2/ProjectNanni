/**************************************************************************************************
**    Script to create Customer tables to test job framework 
**    Customer tables are
**               - job_frmwrk.t_cust_acct
**               - job_frmwrk.t_cust_acct_hist
**               - job_frmwrk.t_cust_addr
**               - job_frmwrk.t_cust_addr_hist
**               - job_frmwrk.t_cust_trnsctn
**               - job_frmwrk.t_cust_trnsctn_hist
**               
**    HISTORY:    NAME                  DATE        COMMENT
**                --------------------  --------    ----------------------
**                Chaitanya Shankari    04/2016     Initial Code
**************************************************************************************************/
create table job_frmwrk.t_cust_acct
(
    cust_acct_id  number,
    first_name    varchar2 (100),
    last_name     varchar2 (100),
    home_phone_no varchar2 (15),
    work_phone_no varchar2 (15),
    ins_date      date,
    upd_date      date,
    primary key (cust_acct_id)
);

create sequence job_frmwrk.sq_cust_acct
    start with 1
    increment by 1
    noorder;

create table job_frmwrk.t_cust_acct_hist
(
    cust_acct_hist_id number,
    cust_acct_id      number,
    first_name        varchar2 (100),
    last_name         varchar2 (100),
    home_phone_no     varchar2 (15),
    work_phone_no     varchar2 (15),
    adt_evnt_typ_cd   varchar2 (5),
    ins_date          date,
    upd_date          date,
    primary key (cust_acct_hist_id)
);

create sequence job_frmwrk.sq_cust_acct_hist
    start with 1
    increment by 1
    noorder;

create table job_frmwrk.t_cust_addr
(
    cust_addr_id   number,
    cust_acct_id   number constraint fk_cad_cai references job_frmwrk.t_cust_acct (cust_acct_id),
    address_line_1 varchar2 (1000),
    address_line_2 varchar2 (1000),
    state          varchar2 (100),
    zipcode        varchar2 (50),
    country        varchar2 (1000),
    ins_date       date,
    upd_date       date,
    primary key (cust_addr_id)
);

create sequence job_frmwrk.sq_cust_addr
    start with 1
    increment by 1
    noorder;

create table job_frmwrk.t_cust_addr_hist
(
    cust_addr_hist_id number,
    cust_addr_id      number,
    cust_acct_id      number,
    address_line_1    varchar2 (1000),
    address_line_2    varchar2 (1000),
    state             varchar2 (100),
    zipcode           varchar2 (50),
    country           varchar2 (1000),
    adt_evnt_typ_cd   varchar2 (5),
    ins_date          date,
    upd_date          date,
    primary key (cust_addr_hist_id)
);

create sequence job_frmwrk.sq_cust_addr_hist
    start with 1
    increment by 1
    noorder;

create table job_frmwrk.t_cust_trnsctn
(
    cust_trnsctn_id number,
    cust_acct_id    number constraint fk_ct_cai references job_frmwrk.t_cust_acct (cust_acct_id),
    trnsctn_code    varchar2 (5),
    trnsctn_amt     number (20, 2),
    trnsctn_date    date,
    trnsctn_desc    varchar2 (100),
    ins_date        date,
    upd_date        date,
    primary key (cust_trnsctn_id)
);


create sequence job_frmwrk.sq_cust_trnsctn
    start with 1
    increment by 1
    noorder;

create table job_frmwrk.t_cust_trnsctn_hist
(
    cust_trnsctn_hist_id number,
    cust_trnsctn_id      number,
    cust_acct_id         number constraint fk_cai references job_frmwrk.t_cust_acct (cust_acct_id),
    trnsctn_code         varchar2 (5),
    trnsctn_amt          number (20, 2),
    trnsctn_date         date,
    trnsctn_desc         varchar2 (100),
    adt_evnt_typ_cd      varchar2 (5),
    ins_date             date,
    upd_date             date,
    primary key (cust_trnsctn_hist_id)
);

create sequence job_frmwrk.sq_cust_trnsctn_hist
    start with 1
    increment by 1
    noorder;
    
-- Triggers for above tables

create or replace trigger job_frmwrk.tr_cust_acct
    after insert or update or delete
    on job_frmwrk.t_cust_acct
    for each row
begin

    if inserting
    then

        insert into
            job_frmwrk.t_cust_acct_hist
            (
                cust_acct_hist_id,
                cust_acct_id,
                first_name,
                last_name,
                home_phone_no,
                work_phone_no,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_acct_hist.nextval,
                :new.cust_acct_id,
                :new.first_name,
                :new.last_name,
                :new.home_phone_no,
                :new.work_phone_no,
                'INS',
                sysdate
            );

    elsif updating
    then

        insert into
            job_frmwrk.t_cust_acct_hist
            (
                cust_acct_hist_id,
                cust_acct_id,
                first_name,
                last_name,
                home_phone_no,
                work_phone_no,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_acct_hist.nextval,
                :old.cust_acct_id,
                :old.first_name,
                :old.last_name,
                :old.home_phone_no,
                :old.work_phone_no,
                'UPD',
                sysdate
            );

    elsif deleting
    then

        insert into
            job_frmwrk.t_cust_acct_hist
            (
                cust_acct_hist_id,
                cust_acct_id,
                first_name,
                last_name,
                home_phone_no,
                work_phone_no,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_acct_hist.nextval,
                :old.cust_acct_id,
                :old.first_name,
                :old.last_name,
                :old.home_phone_no,
                :old.work_phone_no,
                'DEL',
                sysdate
            );


    end if;

end;
/


create or replace trigger job_frmwrk.tr_cust_addr
    after insert or update or delete
    on job_frmwrk.t_cust_addr
    for each row
begin

    if inserting
    then

        insert into
            job_frmwrk.t_cust_addr_hist
            (
                cust_addr_hist_id,
                cust_addr_id,
                cust_acct_id,
                address_line_1,
                address_line_2,
                state,
                zipcode,
                country,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_addr_hist.nextval,
                :old.cust_addr_id,
                :old.cust_acct_id,
                :old.address_line_1,
                :old.address_line_2,
                :old.state,
                :old.zipcode,
                :old.country,
                'INS',
                sysdate
            );

    elsif updating
    then

        insert into
            job_frmwrk.t_cust_addr_hist
            (
                cust_addr_hist_id,
                cust_addr_id,
                cust_acct_id,
                address_line_1,
                address_line_2,
                state,
                zipcode,
                country,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_addr_hist.nextval,
                :old.cust_addr_id,
                :old.cust_acct_id,
                :old.address_line_1,
                :old.address_line_2,
                :old.state,
                :old.zipcode,
                :old.country,
                'UPD',
                sysdate
            );

    elsif deleting
    then

        insert into
            job_frmwrk.t_cust_addr_hist
            (
                cust_addr_hist_id,
                cust_addr_id,
                cust_acct_id,
                address_line_1,
                address_line_2,
                state,
                zipcode,
                country,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_addr_hist.nextval,
                :old.cust_addr_id,
                :old.cust_acct_id,
                :old.address_line_1,
                :old.address_line_2,
                :old.state,
                :old.zipcode,
                :old.country,
                'DEL',
                sysdate
            );


    end if;

end;
/


create or replace trigger job_frmwrk.tr_cust_trnsctn
    after insert or update or delete
    on job_frmwrk.t_cust_trnsctn
    for each row
begin

    if inserting
    then

        insert into
            job_frmwrk.t_cust_trnsctn_hist
            (
                cust_trnsctn_hist_id,
                cust_trnsctn_id,
                trnsctn_code,
                trnsctn_amt,
                trnsctn_date,
                trnsctn_desc,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_trnsctn_hist.nextval,
                :new.cust_trnsctn_id,
                :new.trnsctn_code,
                :new.trnsctn_amt,
                :new.trnsctn_date,
                :new.trnsctn_desc,
                'INS',
                sysdate
            );

    elsif updating
    then

        insert into
            job_frmwrk.t_cust_trnsctn_hist
            (
                cust_trnsctn_hist_id,
                cust_trnsctn_id,
                trnsctn_code,
                trnsctn_amt,
                trnsctn_date,
                trnsctn_desc,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_trnsctn_hist.nextval,
                :old.cust_trnsctn_id,
                :old.trnsctn_code,
                :old.trnsctn_amt,
                :old.trnsctn_date,
                :old.trnsctn_desc,
                'UPD',
                sysdate
            );

    elsif deleting
    then

        insert into
            job_frmwrk.t_cust_trnsctn_hist
            (
                cust_trnsctn_hist_id,
                cust_trnsctn_id,
                trnsctn_code,
                trnsctn_amt,
                trnsctn_date,
                trnsctn_desc,
                adt_evnt_typ_cd,
                ins_date
            )
        values
            (
                job_frmwrk.sq_cust_trnsctn_hist.nextval,
                :old.cust_trnsctn_id,
                :old.trnsctn_code,
                :old.trnsctn_amt,
                :old.trnsctn_date,
                :old.trnsctn_desc,
                'DEL',
                sysdate
            );


    end if;

end;
/    