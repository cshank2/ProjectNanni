create or replace trigger dom_batch.tr_cust_acct
    after insert or update or delete
    on dom_batch.t_cust_acct
    for each row
begin

    if inserting
    then

        insert into
            dom_batch.t_cust_acct_hist
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
                dom_batch.sq_cust_acct_hist.nextval,
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
            dom_batch.t_cust_acct_hist
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
                dom_batch.sq_cust_acct_hist.nextval,
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
            dom_batch.t_cust_acct_hist
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
                dom_batch.sq_cust_acct_hist.nextval,
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