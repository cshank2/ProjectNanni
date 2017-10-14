create or replace trigger dom_batch.tr_cust_trnsctn
    after insert or update or delete
    on dom_batch.t_cust_trnsctn
    for each row
begin

    if inserting
    then

        insert into
            dom_batch.t_cust_trnsctn_hist
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
                dom_batch.sq_cust_trnsctn_hist.nextval,
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
            dom_batch.t_cust_trnsctn_hist
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
                dom_batch.sq_cust_trnsctn_hist.nextval,
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
            dom_batch.t_cust_trnsctn_hist
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
                dom_batch.sq_cust_trnsctn_hist.nextval,
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