CREATE SEQUENCE  "SYSTEM"."MANUT_SEQ_TBS_HIST"  MINVALUE 1 MAXVALUE 100000000 
INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  CYCLE;

  CREATE TABLE "SYSTEM"."MANUT_TB_TBS_HIST"
   (	"SEQ" NUMBER(5,0),
	"DATE_TBS" DATE,
	"HOST_NAME" VARCHAR2(60),
	"INST_NAME" VARCHAR2(30),
	"TABLESPACE" VARCHAR2(40),
	"CONTENTS" VARCHAR2(40),
	"NUM_DATAFILE" NUMBER(4,0),
	"TBS_SIZE_MB" NUMBER(12,0),
	"TBS_FREE_MB" NUMBER(12,0),
	"TBS_USED_MB" NUMBER(12,0)
   ) TABLESPACE "SYSAUX"
/

CREATE OR REPLACE PROCEDURE "SYSTEM"."MANUT_PRC_TBS_HIST" is

tvt_var number := 0;

begin

select SYSTEM.MANUT_SEQ_TBS_HIST.nextval into tvt_var from dual;

insert into SYSTEM.MANUT_TB_TBS_HIST (SEQ,DATE_TBS,HOST_NAME,INST_NAME,TABLESPACE,CONTENTS,NUM_DATAFILE,TBS_SIZE_MB,TBS_FREE_MB,TBS_USED_MB)
SELECT
   SYSTEM.MANUT_SEQ_TBS_HIST.currval,
   sysdate,
   inst.host_name,
   inst.instance_name,
   ts.tablespace_name,
   ts.contents,
   "File Count",
   round(TRUNC("SIZE(MB)", 2)) "Size(MB)",
   round(TRUNC(fr."FREE(MB)", 2)) "Free(MB)",
   round(TRUNC("SIZE(MB)" - "FREE(MB)", 2)) "Used(MB)"
FROM
   (SELECT tablespace_name,
   SUM (bytes) / (1024 * 1024) "FREE(MB)"
   FROM dba_free_space
    GROUP BY tablespace_name) fr,
(SELECT tablespace_name, SUM(bytes) / (1024 * 1024) "SIZE(MB)", COUNT(*) "File Count", SUM(maxbytes) / (1024 * 1024) "MAX_EXT"
FROM dba_data_files
GROUP BY tablespace_name) df,
(SELECT tablespace_name, CONTENTS
FROM dba_tablespaces) ts,
	v$instance inst
WHERE fr.tablespace_name = df.tablespace_name (+)
AND fr.tablespace_name = ts.tablespace_name (+);

commit;

end;
/


BEGIN
  -- Job defined entirely by the CREATE JOB procedure.
  DBMS_SCHEDULER.create_job (
    job_name        => 'JOB_TBS_HIST',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'SYSTEM.MANUT_PRC_TBS_HIST;',
    start_date      =>  to_date('2020-01-20 22:00:00','yyyy-mm-dd hh24:mi:ss'),
    repeat_interval => 'freq=daily;BYHOUR=22;BYMINUTE=00',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Coleta Crescimento das tablespaces');
end;
/

exec dbms_scheduler.enable('JOB_TBS_HIST');
--exec dbms_scheduler.disable('TVT_COLETA_INFO_BCO');
--exec dbms_scheduler.disable('TVT_CRESCIMENTO_TBS');

begin 
 dbms_scheduler.run_job('JOB_TBS_HIST',TRUE); 
end; 
/
