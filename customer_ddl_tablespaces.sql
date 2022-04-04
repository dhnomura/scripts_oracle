-- -----------------------------------------------------------------------------------
-- File Name    : ddl_tablespaces.sql
-- Author       : Diogo Hikaru Nomura
-- Description  : Creates the DDL for users tablespaces
-- Call Syntax  : @ddl_tablespaces.sql
-- Last Modified: 26/03/2022 - Diogo Nomura - First Version
-- -----------------------------------------------------------------------------------
ACCEPT OWNER CHAR PROMPT 'Enter the owner name > '

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
Var var1 varchar2(1000)

begin
select 'backup_tablespace_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
from v$instance a,
dual b;
end;
/

COLUMN spoolcol NEW_VALUE spoolname
SELECT :var1 AS spoolcol FROM DUAL;

spool &spoolname
spool

select 'create bigfile tablespace '|| df.tablespace_name ||' datafile size '|| (to_number(round(sum(df.bytes)/1024/1024/1024)) + 1 )|| 'g autoextend on;'
from dba_data_files df,
(select tablespace_name, sum(bytes) free_gb
from dba_free_space
group by tablespace_name
union
(select tablespace_name, (select 0 from dual) from dba_tablespaces
minus
select distinct tablespace_name, (select 0 from dual) from dba_free_space))fss
where df.tablespace_name = fss.tablespace_name
and df.tablespace_name in (select tablespace_name from dba_extents where owner= '&&OWNER')
group by df.tablespace_name,fss.free_gb;


set pages 180
select 'create bigfile TEMPORARY tablespace '|| df.tablespace_name ||' tempfile size '|| (to_number(round(sum(df.bytes)/1024/1024/1024)) + 1 )|| 'g ;'
from dba_temp_files df,
(select tablespace_name, sum(bytes) free_gb
from dba_free_space
group by tablespace_name
union
(select tablespace_name, (select 0 from dual) from dba_tablespaces
minus
select distinct tablespace_name, (select 0 from dual) from dba_free_space))fss
where df.tablespace_name = fss.tablespace_name
and df.tablespace_name in (select TEMPORARY_TABLESPACE from dba_users where username= '&&OWNER')
group by df.tablespace_name,fss.free_gb;

SET PAGESIZE 14 FEEDBACK ON VERIFY ON

spool off;

