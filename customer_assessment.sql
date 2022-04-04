set echo on
set feedback on
set serveroutput on
set lines 160

Var var1 varchar2(100)

begin
select 'assessment_'||a.host_name||'_'||a.instance_name||'_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS')||'.txt' into :var1
from v$instance a,
dual b;
end;
/

COLUMN spoolcol NEW_VALUE spoolname
SELECT :var1 AS spoolcol FROM DUAL;

spool &spoolname

alter session set nls_date_format = 'DD/MM/YYYY hh24:mi:ss';


-- Environment

/*-- This cursors checkst how the database was open */
  select open_mode
  from v$database;

/*-- This cursor checks it is a physical standy database */
  select database_role
  from v$database;

/*-- This cursor checks the database instances status  */
  select 'Thread '||thread#||', Instance '||instance||', Status '||status
  from v$thread
  where status='CLOSED';

/*-- This cursor checks the database instances status  */
  select 'File# '||file#||', Name '||name||', Need Recover: '||recover
  from v$datafile_headerselect
    count(*), owner
from
    dba_objects
where
    owner not in (  'OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					,'XS$NULL'
					,'APEX_INSTANCE_ADMIN_USER'
					)
group by
    owner
order by 
    1;
  where recover<>'NO';

/*-- This cursor checks the redo logs files status  */
  select 'Redo File '||Member||', Status '||status
  from v$logfile
  where status  is not null;

/*-- This cursor checks if a database is in archivelog mode  */
  select log_mode 
  from v$database;

/*-- This cursor checks if ASM is in using */
  select count(*) from dba_Data_Files where file_name like ('+%');

/*-- This cursor check if each asm diskgroup has at least 20 percent of free space */
  SELECT 
		sum(b.total_mb/1024) SAIDA
  FROM 
		v$asm_diskgroup b, v$asm_client a
  where 
        a.group_number = b.group_number
  and
		state <>'DISMOUNTED';

  select round(sum(Bytes/1024/1024/1024))
  from dba_data_Files;

  select round(sum(Bytes/1024/1024/1024))
  from dba_segments;

  select value
  from v$parameter
  where name='cluster_database';

  select log_mode
  from v$database;

  select db_unique_name
  from v$database;
  
  select host_name
  from v$instance;

  select PLATFORM_NAME
  from v$database;

  select to_char(startup_time,'DD/MM/YYYY hh24:mi:ss')
  from v$instance;

  select version
  from v$instance;

show parameter cpu;

-- CPU / Memory / Architecture

set echo on

-- Database Properties

SET LINES 200
SET PAGESIZE 50
col PROPERTY_VALUE format a40
col PROPERTY_NAME format a40
SELECT property_name,
property_value
FROM database_properties
ORDER BY property_name;

-- NLS

col PARAMETER format a60
col VALUE format a60

select * from NLS_SESSION_PARAMETERS;
select * from NLS_INSTANCE_PARAMETERS;
prompt "TERRAFORM"
prompt "CHARACTER-SET"
select * from NLS_DATABASE_PARAMETERS;


-- Names

col NAME_COL_PLUS_SHOW_PARAM format a50

show parameter db_name;
show parameter db_unique_name;
show parameter service_name;


-- Directories

show parameter utl_file_dir;

col DIRECTORY_NAME format a40
col DIRECTORY_NAME format a80

select * from dba_directories;

-- Database Properties
-- Force Logging

select force_logging from v$database;

select force_logging, tablespace_name from dba_tablespaces;

-- Tablespaces

select distinct owner, tablespace_name from dba_extents;

-- Undo Properties

show parameter undo

-- Temp

-- Invalid Objects

SET LINESIZE 180
SET PAGESIZE 9999
clear columns
clear breaks
clear computes
column owner format a25 heading 'Owner'
column object_name format a50 heading 'Object Name'
column object_type format a20 heading 'Object Type'
column status format a10 heading 'Status'
break on owner skip 2 on report
compute count label "" of object_name on owner
compute count label "Grand Total: " of object_name on report
SELECT
owner
, object_name
, object_type
, status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY owner, object_name
/


-- All Objects

select
    count(*), owner
from
    dba_objects
where
    owner not in (  'OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					,'XS$NULL'
					,'APEX_INSTANCE_ADMIN_USER'
					)
group by
    owner
order by 
    1;

-- Objects By Type

select
    count(*), owner, object_type, status
from
    dba_objects
where  
        owner not in (  'OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					)
group by
    object_type, owner, status
order by   
    owner, object_type, status;

-- Size

select sum(bytes/1024/1024/1024) from dba_data_files;

select sum(bytes/1024/1024/1024) from dba_segments;

prompt "TERRAFORM"
prompt "Schema-Size-GB"
select owner, round(sum(bytes/1024/1024/1024))
from dba_segments
where owner not in ('OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					,'XS$NULL'
					,'APEX_INSTANCE_ADMIN_USER'
					,'GGADMIN'
					)
group by owner
order by owner;

select owner, segment_type, round(sum(bytes/1024/1024/1024))
from dba_segments
where owner not in ('OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					,'XS$NULL'
					,'APEX_INSTANCE_ADMIN_USER'
					,'GGADMIN'
					)
group by owner, segment_type
order by owner, segment_type;


select owner, tablespace_name, sum(bytes/1024/1024/1024)
from dba_segments
where owner not in ('OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
					,'XS$NULL'
					,'APEX_INSTANCE_ADMIN_USER'
					,'GGADMIN'
					)
group by owner, tablespace_name
order by owner, tablespace_name;

select
    owner,
    segment_name, 
    segment_type, 
    round(bytes/1024/1024), 
    tablespace_name
from
    dba_segments
where
    segment_name in (select 
                        segment_name
                    from 
                    	dba_lobs
                    where 
	                    owner not in (  'SYS',
                                        'SYSTEM',
                                        'DBSNMP',
                                        'CTXSYS',
                                        'AUDSYS',
                                        'OJVMSYS',
                                        'DVSYS',
                                        'GSMADMIN_INTERNAL',
                                        'ORDDATA',
                                        'MDSYS',
                                        'LBACSYS',
                                        'APEX_180200',
                                        'DEVOPS',
                                        'XDB',
                                        'WMSYS',
                                        'ORDSYS',
                                        'C##DONO_STATS',
                                        'APEX_050000',
                                        'C##ORACLETASK',
                                        'OUTLN',
                                        'FLOWS_FILES',
                                        'GGADMIN')	
                    );

-- Database Options

-- Database Features

select name, version, detected_usages, aux_count, feature_info,last_usage_date from dba_feature_usage_statistics;

-- Database Link

col DB_LINK format a30
col USERNAME format a20
col HOST format a40

select * from dba_db_links;

-- Memory

show parameter sga;
show parameter pga;
show parameter memory;

-- Schemas

select 
    owner,
    segment_type,
    tablespace_name,
    sum(bytes/1024/1024/1024)
from 
    dba_segments
group by
    owner,
    segment_type,
    tablespace_name
order by
    owner,
    segment_type,
    tablespace_name;

-- Storage Structure

-- lob files

set serveroutput on
DECLARE
    v_TableCol VARCHAR2(100) := '';
    v_Size NUMBER := 0;
    v_TotalSize NUMBER := 0;
BEGIN
    FOR v_Rec IN (
                  SELECT OWNER || '.' || TABLE_NAME || '.' || COLUMN_NAME AS TableAndColumn,
                      'SELECT SUM(DBMS_LOB.GetLength("' || COLUMN_NAME || '"))/1024/1024 AS SizeMB FROM ' || OWNER || '.' || TABLE_NAME AS sqlstmt
                  FROM DBA_TAB_COLUMNS
                  WHERE DATA_TYPE LIKE '_LOB'
                        AND OWNER not in ('SYS','SYSTEM','AUDSYS','GSMADMIN_INTERNAL','XDB','WMSYS','OJVMSYS','CTXSYS','MDSYS','GGADMIN','OUTLN'))
    LOOP
        DBMS_OUTPUT.PUT_LINE (v_Rec.sqlstmt);
        EXECUTE IMMEDIATE v_Rec.sqlstmt INTO v_Size;
 
        DBMS_OUTPUT.PUT_LINE (v_Rec.TableAndColumn || ' size in MB is ' || ROUND(NVL(v_Size,0),2));
        v_TotalSize := v_TotalSize + NVL(v_Size,0);
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE ('Total size in MB is ' || ROUND(v_TotalSize,2));
END;
/


set lines 160
col OWNER format a10
col TABLE_NAME format a32
col COLUMN_NAME format a32
col SEGMENT_NAME format a32
col TABLESPACE_NAME format a32

select 
	owner,
    table_name,
    column_name,
    segment_name,
    tablespace_name,
    compression,
    PARTITIONED,
    SECUREFILE
from 
	dba_lobs
where 
	owner not in (  'OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
                    ,'GGADMIN'
					);

select
    owner,
    segment_name, 
    segment_type, 
    round(bytes/1024/1024), 
    tablespace_name
from
    dba_segments
where
    segment_name in (select 
                        segment_name
                    from 
                    	dba_lobs
                    where 
	                    owner not in (  'SYS',
                                        'SYSTEM',
                                        'DBSNMP',
                                        'CTXSYS',
                                        'AUDSYS',
                                        'OJVMSYS',
                                        'DVSYS',
                                        'GSMADMIN_INTERNAL',
                                        'ORDDATA',
                                        'MDSYS',
                                        'LBACSYS',
                                        'APEX_180200',
                                        'DEVOPS',
                                        'XDB',
                                        'WMSYS',
                                        'ORDSYS',
                                        'C##DONO_STATS',
                                        'APEX_050000',
                                        'C##ORACLETASK',
                                        'OUTLN',
                                        'FLOWS_FILES',
                                        'GGADMIN')	
                    );

-- Options

    -- ASM
    -- Compression
    -- Data Masking
    -- VLD

-- Archive

prompt

select log_mode from v$database;


Ttitle "Switch in a Hour" skip 2


col banco format a20
COL pico format 9999990.00
col media format 9999990.00
select banco, pico * tamanho_megas/1024 PICO, media * tamanho_megas/1024 MEDIA
FROM (select i.HOST_NAME||'-'||i.INSTANCE_NAME banco,
d.log_mode,
max(qtd) pico,
avg(qtd)media,
(select max(BYTES)/1024/1024 megas from v$log) tamanho_megas
from v$database d,v$instance i, (select to_char(FIRST_TIME,'dd/mm/yy hh24') dt, count(*) qtd from v$log_history where
FIRST_TIME>sysdate -15 group by to_char(FIRST_TIME,'dd/mm/yy hh24'))
GROUP BY i.HOST_NAME||'-'||i.INSTANCE_NAME, d.log_mode);


column Total format 9999
column status format a8
column member format a40
column archived heading "Archived" format a8
column bytes heading "Bytes|(MB)" format 9999
Ttitle "Log Info" skip 2
select l.group#,f.member,l.archived,l.bytes/1078576 bytes,l.status,f.type
from v$log l, v$logfile f
where l.group# = f.group#
/

prompt
set lines 200
--heading 'Day'
column d_0 format a3 heading '00'
column d_1 format a3 heading '01'
column d_2 format a3 heading '02'
column d_3 format a3 heading '03'
column d_4 format a3 heading '04'
column d_5 format a3 heading '05'
column d_6 format a3 heading '06'
column d_7 format a3 heading '07'
column d_8 format a3 heading '08'
column d_9 format a3 heading '09'
column d_10 format a3 heading '10'
column d_11 format a3 heading '11'
column d_12 format a3 heading '12'
column d_13 format a3 heading '13'
column d_14 format a3 heading '14'
column d_15 format a3 heading '15'
column d_16 format a3 heading '16'
column d_17 format a3 heading '17'
column d_18 format a3 heading '18'
column d_19 format a3 heading '19'
column d_20 format a3 heading '20'
column d_21 format a3 heading '21'
column d_22 format a3 heading '22'
column d_23 format a3 heading '23'

select to_char(FIRST_TIME,'DY, DD-MON-YYYY') day,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_5,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
count(trunc(FIRST_TIME)) "Total"
from v$log_history
group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) )
/


col name format a100
set lines 240
select 
    stamp, 
    name, 
    dest_id,
    SEQUENCE#,
    thread#, 
    to_char(resetlogs_time,'MON/DD/YYYY hh24:mi:ss'), 
    first_change#, 
    next_change#, 
    status, 
    to_char(completion_time,'MON/DD/YYYY hh24:mi:ss')
from 
    v$archived_log
order by  
    completion_time
/

set lines 160

-- Suplemental Logging

-- ASM

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    group_number
  , name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
FROM
    v$asm_diskgroup
ORDER BY
    name
/


SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
		  a.name                                     
  ||';'|| trunc(a.total_mb/1024)
  ||';'|| trunc(round((a.total_mb - a.free_mb)/1024))
  ||';'|| trunc(round(a.free_mb/1024))
  ||';'|| trunc(ROUND((1- (a.free_mb / a.total_mb))*100, 2)  )
  ||';'|| db_name
FROM
    v$asm_diskgroup a,
	v$asm_client b
where
	    a.GROUP_NUMBER=b.group_number
	and State<>'DISMOUNTED'
	and b.db_name <>'+ASM'
ORDER BY
    name
/


-- Audit

-- Scheduler

-- 

-- All parameter 

col VALUE_COL_PLUS_SHOW_PARAM format a60
col NAME_COL_PLUS_SHOW_PARAM format a60
col Type format a40

show parameter;


-- Primary Keys

col table_name format a40

select at.owner, at.table_name
from dba_tables at
where not exists (select 1
                  from dba_constraints ac
                  where ac.owner = at.owner
                    and ac.table_name = at.table_name
                    and ac.constraint_type = 'P'
                  )
and at.owner not in ('OJVMSYS'
                    ,'APEX_180200'
                    ,'DEVOPS'
                    ,'C##DONO_STATS'
                    ,'C##ORACLETASK'
                    ,'OLAPSYS'
                    ,'SI_INFORMTN_SCHEMA'
                    ,'PUBLIC'
					,'ANONYMOUS'
					,'APEX_050000'
					,'APEX_PUBLIC_USER'
					,'APPQOSSYS'
					,'AUDSYS'
					,'CTXSYS'
					,'DBSFWUSER'
					,'DBSNMP'
					,'DIP'
					,'DVSYS'
					,'DVF'
					,'FLOWS_FILES'
					,'GGSYS'
					,'GSMADMIN_INTERNAL'
					,'GSMCATUSER'
					,'GSMUSER'
					,'HR'
					,'LBACSYS'
					,'MDDATA'
					,'MDSYS'
					,'ORDPLUGINS'
					,'ORDSYS'
					,'ORDDATA'
					,'OUTLN'
					,'ORACLE_OCM'
					,'REMOTE_SCHEDULER_AGENT'
					,'SI_INFORMTN_SCHEMA'
					,'SPATIAL_CSW_ADMIN_USR'
					,'SYS'
					,'SYSTEM'
					,'SYSBACKUP'
					,'SYSKM'
					,'SYSDG'
					,'SYSRAC'
					,'SYS$UMF'
					,'WMSYS'
					,'XDB'
                    ,'GGADMIN'
);

set echo off
spool off;

