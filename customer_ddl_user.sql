-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/user_ddl.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific user.
-- Call Syntax  : @user_ddl (username)
-- Last Modified: 07/08/2018
--              : 26/03/2022 - Diogo Nomura - Altered the order of objects creation,
--                                            it was wrong at the first edition
--                           - Diogo Nomura - Included Password Verify Function DDL
--                           - Diogo Nomura - Included Spooling
-- -----------------------------------------------------------------------------------

set long 99999999 longchunksize 99999999 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

Var var1 varchar2(1000)

begin
select 'backup_user_att_&&OWNER'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.sql' into :var1
from v$instance a,
dual b;
end;
/

COLUMN spoolcol NEW_VALUE spoolname
SELECT :var1 AS spoolcol FROM DUAL;

spool &spoolname
spool

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/
 
variable v_username VARCHAR2(30);

exec :v_username := upper('&OWNER');

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('FUNCTION', OBJECT_NAME, OWNER)
FROM   dba_objects
WHERE  OBJECT_NAME =(select 
                        limit 
                    from 
                        dba_profiles 
                    where 
                        RESOURCE_NAME='PASSWORD_VERIFY_FUNCTION' 
                        and profile=(select profile from dba_users where USERNAME = :v_username));

select to_clob('/* Start profile creation script in case they are missing') AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
and    rownum = 1
union all
select dbms_metadata.get_ddl('PROFILE', u.profile) AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
union all
select to_clob('End profile creation script */') AS ddl
from   dba_users u
where  u.username = :v_username
and    u.profile <> 'DEFAULT'
and    rownum = 1
union all
select dbms_metadata.get_ddl('USER', u.username) AS ddl
from   dba_users u
where  u.username = :v_username
union all
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', tq.username) AS ddl
from   dba_ts_quotas tq
where  tq.username = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee = :v_username
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_username
and    rp.default_role = 'YES'
and    rownum = 1
/

set linesize 80 pagesize 14 feedback on trimspool on verify on

spool off;