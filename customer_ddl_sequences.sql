-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/sequence_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified sequence, or all sequences.
-- Call Syntax  : @ddl_sequence (schema-name) (sequence-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
--              : 26/03/2022 - Diogo Nomura - Few additions to spooling
-- -----------------------------------------------------------------------------------
ACCEPT OWNER CHAR PROMPT 'Enter the owner name > '

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
Var var1 varchar2(1000)

begin
select 'backup_sequence_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
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

SELECT DBMS_METADATA.get_ddl ('SEQUENCE', sequence_name, sequence_owner)
FROM   all_sequences
WHERE  sequence_owner = UPPER('&&OWNER');
-- AND    sequence_name  = DECODE(UPPER('&2'), 'ALL', sequence_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

spool off;
