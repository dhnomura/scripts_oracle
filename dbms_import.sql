-- https://docs.oracle.com/database/121/SUTIL/GUID-5AAC848B-5A2B-4FD1-97ED-D3A048263118.htm#SUTIL977
-- https://docs.oracle.com/database/121/SUTIL/GUID-C9664F8C-19C5-4177-AC20-5682AEABA07F.htm#SUTIL936
-- https://docs.oracle.com/database/121/ARPLS/d_datpmp.htm#ARPLS66053

DECLARE
  v_hdnl NUMBER;
BEGIN
  v_hdnl := DBMS_DATAPUMP.OPEN(
    operation => 'IMPORT',
    job_mode  => 'SCHEMA',
    job_name  => null);
  DBMS_DATAPUMP.ADD_FILE(
    handle    => v_hdnl,
    filename  => 'file_name.dmp',
    directory => 'DATA_PUMP_DIR',
    filetype  => dbms_datapump.ku$_file_type_dump_file);
  DBMS_DATAPUMP.ADD_FILE(
    handle    => v_hdnl,
    filename  => 'imp.log',
    directory => 'DATA_PUMP_DIR',
    filetype  => dbms_datapump.ku$_file_type_log_file);
  DBMS_DATAPUMP.SET_PARAMETER(v_hdnl,'TABLE_EXISTS_ACTION','APPEND');
  DBMS_DATAPUMP.START_JOB(v_hdnl);
END;
/