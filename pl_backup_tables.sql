-- -----------------------------------------------------------------------------------
-- File Name    : pl_bkp_tables
-- Author       : Diogo Hikaru Nomura
-- Description  : Makes a SQL file backup from roles and grants in database
-- Requirements : Access to the V$ views and dba views
-- Call Syntax  : @pl_bkp_tbs
-- Last Modified: 22/01/2015
-- -----------------------------------------------------------------------------------

exec DBMS_OUTPUT.ENABLE(10000000);
set pages 0
set serveroutput on
set lines 160

create global temporary table system.dbkp_tables
 (script varchar2(3000))
on commit preserve rows;

  set serveroutput on
  exec DBMS_OUTPUT.ENABLE(1000000);
  DECLARE
    x NUMBER := 0;
    y NUMBER := 0;
    vv_query varchar2(30000);

  CURSOR c_backup_db_tables is

        select 'select DBMS_METADATA.get_ddl ('''||'TABLE'||''','''||table_name||''','''||owner||''') from dual' string1
        from dba_tables
		where owner='&owner';

  BEGIN

      FOR i IN c_backup_db_tables LOOP
        --dbms_output.put_line('Iniciando :'||i.string1);
        BEGIN
          execute immediate  i.string1 into vv_query;
          --dbms_output.put(vv_query);
           x:=x+1;
           insert into system.dbkp_tables (script) values (vv_query||';');
        EXCEPTION
        WHEN OTHERS THEN
                dbms_output.put_line('error:' || sqlerrm);
           y:=y+1;
        END;
      END LOOP;
        dbms_output.put_line('Numeros de execucoes: '||x);
        dbms_output.put_line('Numeros de falhas: '||y);
  END;
/

Var var1 varchar2(1000)

begin
select 'backup_tbs_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS') into :var1
from v$instance a,
dual b;
end;
/

COLUMN spoolcol NEW_VALUE spoolname
SELECT :var1 AS spoolcol FROM DUAL;

set head off;
set feedback off;
set pages 0
set serveroutput on
set lines 160

spool &spoolname
spool

select * from system.dbkp_tables;

spool off;

