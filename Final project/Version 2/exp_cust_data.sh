ls -ltr
sqlplus -S job_frmwrk/job19 
set timing on
set serveroutput on
whenever sqlerror exit failure;
whenever oserror exit failure;
begin
job_frmwrk.g_sp_execute_cust_xport;
end;
/
exit $?
