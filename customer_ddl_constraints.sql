-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/table_constraints_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the UK & PK constraint DDL for specified table, or all tables.
-- Call Syntax  : @ddl_constraints.sql (schema-name) (table-name or all)
-- Last Modified: 26/03/2022 - Diogo Nomura - Filter for a single user
--                                          - Include spool
-- -----------------------------------------------------------------------------------
ACCEPT OWNER CHAR PROMPT 'Enter the owner name > '

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
Var var1 varchar2(1000)

begin
select 'backup_table_constraints_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
from v$instance a,
dual b;
end;
/

COLUMN spoolcol NEW_VALUE spoolname
SELECT :var1 AS spoolcol FROM DUAL;

spool &spoolname
spool

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', constraint_name, owner)
FROM   all_constraints
WHERE  owner      = UPPER('&&OWNER')
AND    constraint_type IN ('U', 'P');

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

spool off;