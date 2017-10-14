create or replace procedure emp_salary_increase
(emp_id in employees.employee_id%type, salary_inout in out employees.salary%type)
is
  tmp_sal number;
begin
  select salary
  into tmp_sal
  from employees
  where employee_id = emp_id;
  
  if tmp_sal between 5000 and 10000 then
    salary_inout := tmp_sal *1.2;
  elsif tmp_sal between 10000 and 20000 then
    salary_inout := tmp_sal * 1.3;
  elsif tmp_sal > 20000 then
    salary_inout := tmp_sal * 1.4;
  end if;
end;
/

create or replace function employee_details_func(eid in  number)
  return varchar
is
  ename varchar(20);
begin
  select first_name 
  into ename
  from employees
  where employee_id = eid;
  return ename;
end;
/

declare 
  cursor updated_sal is
    select employee_id, salary
    from employees;
  pre_sal number;
  counter number := 0;
  empname varchar(20);
begin
  for emp_rec in updated_sal loop
    pre_sal :=emp_rec.salary;
    emp_salary_increase(emp_rec.employee_id, emp_rec.salary);
    if (emp_rec.salary > pre_sal) then
      counter := counter + 1;
      empname := employee_details_func(emp_rec.employee_id);
      dbms_output.put_line('The salary of employee with employee id ' || emp_rec.employee_id || 'and employee ename ' || empname || ' increased from '|| pre_sal || ' to '|| emp_rec.salary);
    end if;
  end loop;
  dbms_output.put_line('The total number of employees who got hike is ' || counter);
end;
/   
  
  
