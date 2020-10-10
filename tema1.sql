set heading off;
set echo off;
set feedback off;
set verify off;
set termout off;
set showmode off;
set linesize 1500;
set pagesize 25000;

spool "/home/littlewho/projects/sgdb/tema1_output.sql";

select 'insert into departments (department_id, department_name, manager_id, location_id)' || chr(10) ||
       'values (' ||
       department_id || ', ' ||
       department_name || ', ' ||
       coalesce(to_char(manager_id), 'null') || ', ' ||
       location_id || ');' || chr(10) || chr(10)
from departments;

spool off;
