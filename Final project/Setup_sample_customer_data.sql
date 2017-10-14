declare
    cursor cur_acct
    is
        select
            cust_acct_id
        from
            dom_batch.t_cust_acct;

    type l_typ_cur_var is table of cur_acct%rowtype;
    l_v_cur_var      l_typ_cur_var;

    l_v_cust_acct_id number;
begin

    for i in 1 .. 1000000 loop

        insert into
            dom_batch.t_cust_acct
            (
                cust_acct_id,
                first_name,
                last_name,
                home_phone_no,
                work_phone_no,
                ins_date
            )
        values
            (
                dom_batch.sq_cust_acct.nextval,
                'first_name' || i,
                'last_name' || i,
                '4109175595',
                '4107042000',
                sysdate
            )
        returning
            cust_acct_id
        into
            l_v_cust_acct_id;


        insert into
            dom_batch.t_cust_addr
            (
                cust_addr_id,
                cust_acct_id,
                address_line_1,
                address_line_2,
                state,
                zipcode,
                country,
                ins_date
            )
        values
            (
                dom_batch.sq_cust_addr.nextval,
                l_v_cust_acct_id,
                'address_line_1 st',
                'apt',
                'MD',
                '21030',
                'USA',
                sysdate
            );

        commit;

    end loop;



    open cur_acct;

    loop

        fetch cur_acct
            bulk
                collect into l_v_cur_var
            limit 10000;

        exit when l_v_cur_var.count = 0;

        forall i in 1 .. l_v_cur_var.count

            insert into
                dom_batch.t_cust_trnsctn
                (
                    cust_trnsctn_id,
                    cust_acct_id,
                    trnsctn_code,
                    trnsctn_amt,
                    trnsctn_date,
                    trnsctn_desc,
                    ins_date
                )
            values
                (
                    dom_batch.sq_cust_trnsctn.nextval,
                    l_v_cur_var (i).cust_acct_id,
                    'PRCHS',
                    round (dbms_random.value (100, 2000), 2),
                    sysdate - round (dbms_random.value (1, 365)),
                    'Sample transaction description',
                    sysdate
                );
       commit;
    end loop;
    
    close cur_acct;

end;
/