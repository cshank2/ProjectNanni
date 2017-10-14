#!/bin/sh
unset NLS_LANG
export ORACLE_HOME='/u01/app/oracle/product/11.2.0/xe'
/u01/app/oracle/product/11.2.0/xe/bin/sqlplus job_frmwrk/job19@xe <<EOF
set serveroutput on pages 0 lines 120;
set timing on;
begin
job_frmwrk.g_sp_execute_cust_xport;
end;
/
exit
