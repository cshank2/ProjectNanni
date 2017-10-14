declare 
p_file utl_file.file_type;
l_table hr.employees%ROWTYPE;
l_delimited varchar2(1) := '|';
begin
p_file:= utl_file.fopen('UTL_FILE_DIR','file2.txt','W');
for l_table in (select * from HR.employees) loop
utl_file.put_line(p_file,l_table.employee_id||l_delimited||l_table.first_name||l_delimited||l_table.last_name||l_delimited||l_table.email||l_delimited||l_table.phone_number||l_delimited||l_table.hire_date||l_delimited||l_table.job_id||l_delimited||l_table.salary||l_delimited||l_table.commission_pct||l_delimited||l_table.manager_id||l_delimited||l_table.department_id||chr(10));
end loop;    
utl_file.fclose_all();
end;
/
