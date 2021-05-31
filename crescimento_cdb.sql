grant select on cdb_free_space 		to system;
grant select on cdb_temp_free_space to system;
grant select on cdb_temp_files 		to system;
grant select on cdb_data_files 		to system;
grant select on cdb_tablespaces 	to system;
grant select on v_$pdbs 			to system;
grant select on v_$instance			to system;

CREATE SEQUENCE  "SYSTEM"."MANUT_SEQ_CDB_TBS_HIST"  MINVALUE 1 MAXVALUE 100000000 
INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  CYCLE;

  CREATE TABLE "SYSTEM"."MANUT_TB_CDB_TBS_HIST"
   (   
    "SEQ" NUMBER(5,0),
	"PDB" VARCHAR(30),
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

count_var number := 0;

begin

select SYSTEM.MANUT_SEQ_CDB_TBS_HIST.nextval into count_var from dual;

insert into SYSTEM.MANUT_TB_CDB_TBS_HIST (SEQ,PDB,DATE_TBS,HOST_NAME,INST_NAME,TABLESPACE,CONTENTS,NUM_DATAFILE,TBS_SIZE_MB,TBS_FREE_MB,TBS_USED_MB)
SELECT
   SYSTEM.MANUT_SEQ_CDB_TBS_HIST.currval,
   pdbs.name,
   sysdate,
   substr(inst.host_name,1,instr(inst.host_name,'.')-1) HOST_NAME,
   inst.instance_name,
   ts.tablespace_name,
   ts.contents,
   "File Count",
   round(TRUNC("SIZE(MB)", 2)) "Size_MB",
   round(TRUNC(fr."FREE(MB)", 2)) "Free_MB",
   round(TRUNC("SIZE(MB)" - "FREE(MB)", 2)) "Used_MB"
FROM
   (SELECT
		con_id,
		tablespace_name,
		SUM (bytes) / (1024 * 1024) "FREE(MB)"
	FROM 
		cdb_free_space
    GROUP BY 
		con_id, tablespace_name
	union all
	SELECT
		con_id,
		tablespace_name,
		sum(FREE_SPACE/1024)  / (1024 * 1024)
	FROM 
		cdb_temp_free_space
    GROUP BY 
		con_id, tablespace_name) 
	fr,
	(SELECT 
		con_id,
		tablespace_name, 
		SUM(bytes) / (1024 * 1024) "SIZE(MB)", 
		COUNT(*) "File Count", 
		SUM(maxbytes) / (1024 * 1024) "MAX_EXT"
	FROM 
		cdb_data_files
	GROUP BY 
		tablespace_name, con_id
	union all
	SELECT 
		con_id,
		tablespace_name, 
		SUM(bytes) / (1024 * 1024) "SIZE(MB)", 
		COUNT(*) "File Count", 
		SUM(maxbytes) / (1024 * 1024) "MAX_EXT"
	FROM 
		cdb_temp_files
	GROUP BY 
		tablespace_name, con_id) 
	df,
	(SELECT 
		con_id,
		tablespace_name, 
		CONTENTS
	FROM 
		cdb_tablespaces) 
	ts,
	v$instance inst,
	v$pdbs pdbs
WHERE 
	fr.tablespace_name = df.tablespace_name (+) AND
	fr.tablespace_name = ts.tablespace_name (+) AND
	fr.con_id          = df.con_id          (+) AND
	fr.con_id          = ts.con_id          (+) AND
	fr.con_id          = pdbs.con_id        (+);

commit;

end;
/


BEGIN
  -- Job defined entirely by the CREATE JOB procedure.
  DBMS_SCHEDULER.create_job (
    job_name        => 'JOB_CDB_TBS_HIST',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'SYSTEM.MANUT_PRC_TBS_HIST;',
    start_date      =>  to_date('2021-05-31 22:00:00','yyyy-mm-dd hh24:mi:ss'),
    repeat_interval => 'freq=daily;BYHOUR=22;BYMINUTE=00',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Coleta Crescimento das tablespaces');
end;
/

exec dbms_scheduler.enable('JOB_CDB_TBS_HIST');

begin 
 dbms_scheduler.run_job('JOB_CDB_TBS_HIST',TRUE); 
end; 
/