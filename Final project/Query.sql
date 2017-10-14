select
    ca.cust_acct_id cust_acct_id,
    ca.first_name first_name,
    ca.last_name last_name,
    cad.address_line_1 address_line_1,
    cad.address_line_2 address_line_2,
    cad.state state,
    cad.zipcode zipcode,
    sum (ct.trnsctn_amt) total_trnsctn_amt
from
    dom_batch.t_cust_acct ca,
    dom_batch.t_cust_addr cad,
    dom_batch.t_cust_trnsctn ct
where
    ca.cust_acct_id = cad.cust_acct_id and
    ca.cust_acct_id = ct.cust_acct_id and
    ct.trnsctn_date between sysdate - 30 and sysdate
group by
    ca.cust_acct_id,
    ca.first_name,
    ca.last_name,
    cad.address_line_1,
    cad.address_line_2,
    cad.state,
    cad.zipcode
order by
    ca.last_name;