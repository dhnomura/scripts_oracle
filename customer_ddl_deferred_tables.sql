-- -----------------------------------------------------------------------------------
-- File Name    : ddl_deferred_tables.sql
-- Author       : Diogo Hikaru Nomura
-- Description  : Creates the DDL for users tablespaces
-- Call Syntax  : @ddl_deferred_tables.sql
-- Last Modified: 26/03/2022 - Diogo Nomura - First Version
-- -----------------------------------------------------------------------------------
ACCEPT OWNER CHAR PROMPT 'Enter the owner name > '

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
Var var1 varchar2(1000)

begin
select 'backup_deferred_tables_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
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

SELECT DBMS_METADATA.get_ddl ('TABLE', TABLE_NAME, owner)
FROM   dba_tables
WHERE table_name NOT IN (select segment_name from dba_Segments where owner ='&&OWNER')
AND OWNER='&&OWNER';

SET PAGESIZE 14 FEEDBACK ON VERIFY ON

spool off;