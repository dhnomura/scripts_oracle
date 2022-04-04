set long 999000 longchunksize 999000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

Var var1 varchar2(1000)

begin
select '01'||'_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYYMMDDHH24')||'.sql' into :var1
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
and df.tablespace_name not in ('SYSTEM','SYSAUX')
group by df.tablespace_name,fss.free_gb;

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
and df.tablespace_name not in ('TEMP')
group by df.tablespace_name,fss.free_gb;


SELECT  DBMS_METADATA.get_ddl ('FUNCTION', OBJECT_NAME, OWNER)
FROM   dba_objects
WHERE  OBJECT_NAME in (select 
                        limit 
                    from 
                        dba_profiles 
                    where 
                        RESOURCE_NAME='PASSWORD_VERIFY_FUNCTION' 
                        and profile in (select profile from dba_users where oracle_maintained <> 'Y'));

select to_clob('/* Start profile creation script in case they are missing') AS ddl
from   dba_users u
where  u.username in (select profile from dba_users where oracle_maintained <> 'Y')
and    u.oracle_maintained <> 'Y'
and    rownum = 1
union all
select dbms_metadata.get_ddl('PROFILE', u.profile) AS ddl
from   dba_users u
where  u.oracle_maintained <> 'Y'
and    u.profile <> 'DEFAULT'
union all
select to_clob('End profile creation script */') AS ddl
from   dba_users u
where  u.oracle_maintained <> 'Y'
and    u.profile <> 'DEFAULT'
and    rownum = 1
union all
select dbms_metadata.get_ddl('USER', u.username) AS ddl
from   dba_users u
where  u.oracle_maintained <> 'Y'
union all
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', tq.username) AS ddl
from   dba_ts_quotas tq
where  tq.username in (select username from dba_users where oracle_maintained <> 'Y')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee in (select username from dba_users where oracle_maintained <> 'Y')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee in (select username from dba_users where oracle_maintained <> 'Y')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee in (select username from dba_users where oracle_maintained <> 'Y')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee in (select username from dba_users where oracle_maintained <> 'Y')
and    rp.default_role = 'YES'
and    rownum = 1
/


select dbms_metadata.get_ddl('ROLE', r.role) AS ddl
from   dba_roles r
where  r.role not in (
'CONNECT','RESOURCE','DBA','PDB_DBA','AUDIT_ADMIN'
,'AUDIT_VIEWER','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','CAPTURE_ADMIN'
,'EXP_FULL_DATABASE','IMP_FULL_DATABASE','CDB_DBA','APPLICATION_TRACE_VIEWER'
,'LOGSTDBY_ADMINISTRATOR','DBFS_ROLE','GSMUSER_ROLE','GSMROOTUSER_ROLE'
,'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE'
,'ADM_PARALLEL_EXECUTE_TASK','PROVISIONER','XS_SESSION_ADMIN','XS_NAMESPACE_ADMIN'
,'XS_CACHE_ADMIN','XS_CONNECT','GATHER_SYSTEM_STATISTICS','OPTIMIZER_PROCESSING_RATE'
,'DBMS_MDX_INTERNAL','BDSQL_ADMIN','BDSQL_USER','RECOVERY_CATALOG_OWNER'
,'RECOVERY_CATALOG_OWNER_VPD','RECOVERY_CATALOG_USER','EM_EXPRESS_BASIC','EM_EXPRESS_ALL'
,'SYSUMF_ROLE','SCHEDULER_ADMIN','HS_ADMIN_SELECT_ROLE','HS_ADMIN_EXECUTE_ROLE'
,'HS_ADMIN_ROLE','GLOBAL_AQ_USER_ROLE','OEM_ADVISOR','OEM_MONITOR'
,'JAVAIDPRIV','GSMADMIN_ROLE','GSM_POOLADMIN_ROLE','GDS_CATALOG_SELECT'
,'GGSYS_ROLE','XDBADMIN','XDB_SET_INVOKER','AUTHENTICATEDUSER'
,'XDB_WEBSERVICES','XDB_WEBSERVICES_WITH_PUBLIC','XDB_WEBSERVICES_OVER_HTTP','SODA_APP'
,'DATAPATCH_ROLE','WM_ADMIN_ROLE','JAVAUSERPRIV','RDFCTX_ADMIN'
,'JAVASYSPRIV','AVADEBUGPRIV','JAVADEBUGPRIV','EJBCLIENT'
,'JMXSERVER','DBJAVASCRIPT','JAVA_ADMIN','CTXAPP'
,'ORDADMIN','OLAP_XS_ADMIN','OLAP_DBA','OLAP_USER','GGS_GGSUSER_ROLE'
)
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee in (
    select r.role
    from   dba_roles r
    where  r.role not in (
        'CONNECT','RESOURCE','DBA','PDB_DBA','AUDIT_ADMIN'
        ,'AUDIT_VIEWER','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','CAPTURE_ADMIN'
        ,'EXP_FULL_DATABASE','IMP_FULL_DATABASE','CDB_DBA','APPLICATION_TRACE_VIEWER'
        ,'LOGSTDBY_ADMINISTRATOR','DBFS_ROLE','GSMUSER_ROLE','GSMROOTUSER_ROLE'
        ,'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE'
        ,'ADM_PARALLEL_EXECUTE_TASK','PROVISIONER','XS_SESSION_ADMIN','XS_NAMESPACE_ADMIN'
        ,'XS_CACHE_ADMIN','XS_CONNECT','GATHER_SYSTEM_STATISTICS','OPTIMIZER_PROCESSING_RATE'
        ,'DBMS_MDX_INTERNAL','BDSQL_ADMIN','BDSQL_USER','RECOVERY_CATALOG_OWNER'
        ,'RECOVERY_CATALOG_OWNER_VPD','RECOVERY_CATALOG_USER','EM_EXPRESS_BASIC','EM_EXPRESS_ALL'
        ,'SYSUMF_ROLE','SCHEDULER_ADMIN','HS_ADMIN_SELECT_ROLE','HS_ADMIN_EXECUTE_ROLE'
        ,'HS_ADMIN_ROLE','GLOBAL_AQ_USER_ROLE','OEM_ADVISOR','OEM_MONITOR'
        ,'JAVAIDPRIV','GSMADMIN_ROLE','GSM_POOLADMIN_ROLE','GDS_CATALOG_SELECT'
        ,'GGSYS_ROLE','XDBADMIN','XDB_SET_INVOKER','AUTHENTICATEDUSER'
        ,'XDB_WEBSERVICES','XDB_WEBSERVICES_WITH_PUBLIC','XDB_WEBSERVICES_OVER_HTTP','SODA_APP'
        ,'DATAPATCH_ROLE','WM_ADMIN_ROLE','JAVAUSERPRIV','RDFCTX_ADMIN'
        ,'JAVASYSPRIV','AVADEBUGPRIV','JAVADEBUGPRIV','EJBCLIENT'
        ,'JMXSERVER','DBJAVASCRIPT','JAVA_ADMIN','CTXAPP'
        ,'ORDADMIN','OLAP_XS_ADMIN','OLAP_DBA','OLAP_USER','GGS_GGSUSER_ROLE'
    )
)
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee in (
    select r.role
    from   dba_roles r
    where  r.role not in (
        'CONNECT','RESOURCE','DBA','PDB_DBA','AUDIT_ADMIN'
        ,'AUDIT_VIEWER','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','CAPTURE_ADMIN'
        ,'EXP_FULL_DATABASE','IMP_FULL_DATABASE','CDB_DBA','APPLICATION_TRACE_VIEWER'
        ,'LOGSTDBY_ADMINISTRATOR','DBFS_ROLE','GSMUSER_ROLE','GSMROOTUSER_ROLE'
        ,'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE'
        ,'ADM_PARALLEL_EXECUTE_TASK','PROVISIONER','XS_SESSION_ADMIN','XS_NAMESPACE_ADMIN'
        ,'XS_CACHE_ADMIN','XS_CONNECT','GATHER_SYSTEM_STATISTICS','OPTIMIZER_PROCESSING_RATE'
        ,'DBMS_MDX_INTERNAL','BDSQL_ADMIN','BDSQL_USER','RECOVERY_CATALOG_OWNER'
        ,'RECOVERY_CATALOG_OWNER_VPD','RECOVERY_CATALOG_USER','EM_EXPRESS_BASIC','EM_EXPRESS_ALL'
        ,'SYSUMF_ROLE','SCHEDULER_ADMIN','HS_ADMIN_SELECT_ROLE','HS_ADMIN_EXECUTE_ROLE'
        ,'HS_ADMIN_ROLE','GLOBAL_AQ_USER_ROLE','OEM_ADVISOR','OEM_MONITOR'
        ,'JAVAIDPRIV','GSMADMIN_ROLE','GSM_POOLADMIN_ROLE','GDS_CATALOG_SELECT'
        ,'GGSYS_ROLE','XDBADMIN','XDB_SET_INVOKER','AUTHENTICATEDUSER'
        ,'XDB_WEBSERVICES','XDB_WEBSERVICES_WITH_PUBLIC','XDB_WEBSERVICES_OVER_HTTP','SODA_APP'
        ,'DATAPATCH_ROLE','WM_ADMIN_ROLE','JAVAUSERPRIV','RDFCTX_ADMIN'
        ,'JAVASYSPRIV','AVADEBUGPRIV','JAVADEBUGPRIV','EJBCLIENT'
        ,'JMXSERVER','DBJAVASCRIPT','JAVA_ADMIN','CTXAPP'
        ,'ORDADMIN','OLAP_XS_ADMIN','OLAP_DBA','OLAP_USER','GGS_GGSUSER_ROLE'
        )
    )
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee in (
    select r.role
    from   dba_roles r
    where  r.role not in (
        'CONNECT','RESOURCE','DBA','PDB_DBA','AUDIT_ADMIN'
        ,'AUDIT_VIEWER','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','CAPTURE_ADMIN'
        ,'EXP_FULL_DATABASE','IMP_FULL_DATABASE','CDB_DBA','APPLICATION_TRACE_VIEWER'
        ,'LOGSTDBY_ADMINISTRATOR','DBFS_ROLE','GSMUSER_ROLE','GSMROOTUSER_ROLE'
        ,'AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE'
        ,'ADM_PARALLEL_EXECUTE_TASK','PROVISIONER','XS_SESSION_ADMIN','XS_NAMESPACE_ADMIN'
        ,'XS_CACHE_ADMIN','XS_CONNECT','GATHER_SYSTEM_STATISTICS','OPTIMIZER_PROCESSING_RATE'
        ,'DBMS_MDX_INTERNAL','BDSQL_ADMIN','BDSQL_USER','RECOVERY_CATALOG_OWNER'
        ,'RECOVERY_CATALOG_OWNER_VPD','RECOVERY_CATALOG_USER','EM_EXPRESS_BASIC','EM_EXPRESS_ALL'
        ,'SYSUMF_ROLE','SCHEDULER_ADMIN','HS_ADMIN_SELECT_ROLE','HS_ADMIN_EXECUTE_ROLE'
        ,'HS_ADMIN_ROLE','GLOBAL_AQ_USER_ROLE','OEM_ADVISOR','OEM_MONITOR'
        ,'JAVAIDPRIV','GSMADMIN_ROLE','GSM_POOLADMIN_ROLE','GDS_CATALOG_SELECT'
        ,'GGSYS_ROLE','XDBADMIN','XDB_SET_INVOKER','AUTHENTICATEDUSER'
        ,'XDB_WEBSERVICES','XDB_WEBSERVICES_WITH_PUBLIC','XDB_WEBSERVICES_OVER_HTTP','SODA_APP'
        ,'DATAPATCH_ROLE','WM_ADMIN_ROLE','JAVAUSERPRIV','RDFCTX_ADMIN'
        ,'JAVASYSPRIV','AVADEBUGPRIV','JAVADEBUGPRIV','EJBCLIENT'
        ,'JMXSERVER','DBJAVASCRIPT','JAVA_ADMIN','CTXAPP'
        ,'ORDADMIN','OLAP_XS_ADMIN','OLAP_DBA','OLAP_USER','GGS_GGSUSER_ROLE'
        )
    )
and    rownum = 1
/

set linesize 80 pagesize 14 feedback on trimspool on verify on

spool off;