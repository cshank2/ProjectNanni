create or replace package emp_details as
  procedure emp_table;
end emp_details;
/

create or replace package body emp_details as
  procedure emp_table is 
    p_file utl_file.file_type;
    l_table hr.employees%ROWTYPE;
    l_delimited varchar2(1) := '|';
  begin
    p_file:= utl_file.fopen('UTL_FILE_DIR','file2'||to_char(sysdate,'yyyy-mm-dd hh:mm:ss')||'.txt','W');
    for l_table in (select * from HR.employees) loop
      utl_file.put_line(p_file,l_table.employee_id||l_delimited||l_table.first_name||l_delimited||l_table.last_name||l_delimited||l_table.email||l_delimited||l_table.phone_number||l_delimited||l_table.hire_date||l_delimited||l_table.job_id||l_delimited||l_table.salary||l_delimited||l_table.commission_pct||l_delimited||l_table.manager_id||l_delimited||l_table.department_id||chr(10));
    end loop;    
    utl_file.fclose_all();
  end emp_table;
end emp_details;
/

declare
begin
  EMP_DETAILS.EMP_TABLE;
end;
/

BEGIN 
EMP_DETAILS.EMP_TABLE; 
END;



 BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'TEST_SCH_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN EMP_DETAILS.EMP_TABLE; END; ',
    start_date      => '27-feb-2016 03:10:00 pm',
    repeat_interval => 'freq=MINUTELY; BYSECOND=0',
    end_date        => '27-FEB-2016 03:30:00 PM',
    comments        => 'Job defined entirely by the CREATE JOB procedure.',
    ENABLED         => TRUE);
END;
/


 BEGIN
  DBMS_SCHEDULER.set_attribute(
    name        => 'test_job',
--    attribute   => 'start_date',
--    value       => '27-feb-2016 02:55:00 pm',
    attribute   => 'end_date',
    value       => '27-FEB-2016 03:10:00 PM');
END;
/

begin
dbms_scheduler.stop_job(job_name  => 'test_job1');
end;
/

select to_char(sysdate,'yyyy-mm-dd hh:mm:ss') from dual;

begin
dbms_scheduler.disable ('test_job1');
end;
/

begin
dbms_scheduler.disable ('test_job');
end;
/