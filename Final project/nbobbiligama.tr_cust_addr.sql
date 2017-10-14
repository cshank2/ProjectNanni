create or replace trigger dom_batch.tr_cust_addr
    after insert or update or delete
    on dom_batch.t_cust_addr
    for each row
begin

    if inserting
    then

        insert into
            dom_batch.t_cust_addr_hist
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
                dom_batch.sq_cust_addr_hist.nextval,
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
            dom_batch.t_cust_addr_hist
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
                dom_batch.sq_cust_addr_hist.nextval,
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
            dom_batch.t_cust_addr_hist
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
                dom_batch.sq_cust_addr_hist.nextval,
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