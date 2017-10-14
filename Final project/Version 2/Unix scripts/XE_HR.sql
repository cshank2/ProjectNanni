DECLARE
  VAR_SALARY NUMBER(8,2);
 -- var_employee_id number(6) := 188;
  var_employee_id number(6);
BEGIN
var_employee_id := 188;
select salary 
  into var_salary 
  from employees
  where employee_id = var_employee_id;
  dbms_output.put_line('Current salary' || VAR_SALARY);
  DECLARE
    var_hike number(3,2) := 0.1;
    var_new_salary number(8,2);
  BEGIN
    var_new_salary := var_salary + var_salary * var_hike;
    dbms_output.put_line('New Salary' || var_new_salary);
  END;
END;
/


DECLARE
  VAR_EMPLOYEE_ID NUMBER(6);
  VAR_SALARY NUMBER(6);
  VAR_DEPARTMENT_NAME VARCHAR2(50);
  VAR_COUNTRY_NAME VARCHAR2(40);
BEGIN
SELECT EMPLOYEE_ID, SALARY, DEPARTMENT_NAME
INTO VAR_EMPLOYEE_ID, VAR_SALARY, VAR_DEPARTMENT_NAME
FROM EMPLOYEES, DEPARTMENTS
WHERE
  EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID; 
END;
/


select * from countries;
select * from departments;
select * from locations;
select * from employees where employee_id = 178;

select employee_id, EMPLOYEES.FIRST_NAME, EMPLOYEES.LAST_NAME, 
departments.DEPARTMENT_NAME, 
LOCATIONS.STREET_ADDRESS, LOCATIONS.POSTAL_CODE, LOCATIONS.CITY, LOCATIONS.STATE_PROVINCE, 
REGIONS.REGION_NAME, 
COUNTRIES.COUNTRY_NAME
from EMPLOYEES, departments, LOCATIONS, COUNTRIES, REGIONS
where employees.department_id = departments.department_id and
departments.location_id = LOCATIONS.LOCATION_ID and
LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID and
COUNTRIES.REGION_ID = REGIONS.REGION_ID;

DECLARE
var_employee_id employees.employee_id%TYPE;
var_first_name employees.first_name%TYPE;
var_last_name employees.last_name%TYPE;
var_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
var_street_address LOCATIONS.STREET_ADDRESS%TYPE;
var_postal_code LOCATIONS.POSTAL_CODE%TYPE;
var_city LOCATIONS.CITY%TYPE;
var_state_province LOCATIONS.STATE_PROVINCE%TYPE;
var_region_name REGIONS.REGION_NAME%TYPE;
var_country_name COUNTRIES.COUNTRY_NAME%TYPE;
BEGIN
select employee_id, EMPLOYEES.FIRST_NAME, EMPLOYEES.LAST_NAME, 
departments.DEPARTMENT_NAME, 
LOCATIONS.STREET_ADDRESS, LOCATIONS.POSTAL_CODE, LOCATIONS.CITY, LOCATIONS.STATE_PROVINCE, 
REGIONS.REGION_NAME, 
COUNTRIES.COUNTRY_NAME
INTO
  var_employee_id, var_first_name, var_last_name, var_department_name,
  var_street_address, var_postal_code, var_city, var_state_province, var_region_name, var_country_name
from EMPLOYEES, departments, LOCATIONS, COUNTRIES, REGIONS
where employees.department_id = departments.department_id and
departments.location_id = LOCATIONS.LOCATION_ID and
LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID and
COUNTRIES.REGION_ID = REGIONS.REGION_ID;
EXCEPTION
  when no_data_found then
    dbms_output.put_line('Select statement did not return any rows');
  when too_many_rows then
    dbms_output.put_line('Select statement returns more than one row. Declare cursor or change the condition');
    raise;
end;
/

DECLARE
var_employee_id employees.employee_id%TYPE;
var_first_name employees.first_name%TYPE;
var_last_name employees.last_name%TYPE;
var_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
var_street_address LOCATIONS.STREET_ADDRESS%TYPE;
var_postal_code LOCATIONS.POSTAL_CODE%TYPE;
var_city LOCATIONS.CITY%TYPE;
var_state_province LOCATIONS.STATE_PROVINCE%TYPE;
var_region_name REGIONS.REGION_NAME%TYPE;
var_country_name COUNTRIES.COUNTRY_NAME%TYPE;
CURSOR emp_details IS
select employee_id, EMPLOYEES.FIRST_NAME, EMPLOYEES.LAST_NAME, 
departments.DEPARTMENT_NAME, 
LOCATIONS.STREET_ADDRESS, LOCATIONS.POSTAL_CODE, LOCATIONS.CITY, LOCATIONS.STATE_PROVINCE, 
REGIONS.REGION_NAME, 
COUNTRIES.COUNTRY_NAME
from EMPLOYEES, departments, LOCATIONS, COUNTRIES, REGIONS
where employees.department_id = departments.department_id and
departments.location_id = LOCATIONS.LOCATION_ID and
LOCATIONS.COUNTRY_ID = COUNTRIES.COUNTRY_ID and
COUNTRIES.REGION_ID = REGIONS.REGION_ID;
BEGIN
OPEN emp_details;
FETCH emp_details into  
  var_employee_id, var_first_name, var_last_name, var_department_name,
  var_street_address, var_postal_code, var_city, var_state_province, var_region_name, var_country_name;
CLOSE emp_details;
dbms_output. put_line (var_employee_id || '| ' ||var_first_name || '| ' || var_last_name || '| ' || var_department_name ||
 '| ' || var_street_address || '| ' || var_postal_code || '| ' || var_city || '| ' || var_state_province || '| ' 
 || var_region_name || '| ' || var_country_name);
END;
/
  

create or replace procedure emp_name(id in number, emp_name out varchar)
is
begin
  SELECT FIRST_NAME INTO emp_name from EMPLOYEES where employee_id = id;
end;
/

declare
  empName varchar(20);
  cursor empid_cur is 
    SELECT employee_id 
    from employees; 
    emp_rec empid_cur%rowtype;
begin
  for emp_rec in empid_cur
  loop
    emp_name(emp_rec.employee_id, empName);
    dbms_output.put_line('The employee ' || empName || ' has id ' || emp_rec.employee_id);
  end loop;
end;
/

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

declare 
  cursor updated_sal is
    select employee_id, salary
    from employees;
  pre_sal number;
  counter number := 0;
begin
  for emp_rec in updated_sal loop
    pre_sal :=emp_rec.salary;
    emp_salary_increase(emp_rec.employee_id, emp_rec.salary);
    if (emp_rec.salary > pre_sal) then
      counter := counter + 1;
      dbms_output.put_line('The salary of ' || emp_rec.employee_id || ' increased from '|| pre_sal || ' to '|| emp_rec.salary);
    end if;
  end loop;
  dbms_output.put_line('The total number of employees who got hike is ' || counter);
end;
/   

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

create or replace function employee_details_func(eid in number)
  return varchar 
is
  ename varchar(20);
begin
  select first_name into ename from employees where employee_id = eid;
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
      dbms_output.put_line('The salary of employee with employee id ' || emp_rec.employee_id || ' and employee name ' || empname || ' increased from '|| pre_sal || ' to '|| emp_rec.salary);
    end if;
  end loop;
  dbms_output.put_line('The total number of employees who got hike is ' || counter);
end;
/   









