-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/synonym_public_remote_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for public synonyms to remote objects.
-- Call Syntax  : @ddl_public_synonym.sql
-- Last Modified: 08/07/2013 - Rewritten to use DBMS_METADATA
--              : 26/03/2022 - Diogo Nomura - Few additions to spooling
--              :                           - Removed Remote Objects
-- -----------------------------------------------------------------------------------
ACCEPT OWNER CHAR PROMPT 'Enter the owner name > '

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
Var var1 varchar2(1000)

begin
select 'backup_public_synonym_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
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

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   dba_synonyms
WHERE  owner = 'PUBLIC'
AND    TABLE_OWNER='&&OWNER'
AND    db_link IS NULL;

SET PAGESIZE 14 FEEDBACK ON VERIFY ON

spool off;
