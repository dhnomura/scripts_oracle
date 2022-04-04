column tablespace_name format a30
column free_GB format 9999999.99
column tam_GB format 9999999.99
column pct_free format 999.99
set pages 100
select df.tablespace_name, fss.free_GB/1024/1024/1024
free_GB,sum(df.bytes)/1024/1024/1024 tam_GB,fss.free_gb/sum(df.bytes)*100
pct_free
from dba_data_files df,
(select tablespace_name, sum(bytes) free_gb
from dba_free_space
group by tablespace_name
union
(select tablespace_name, (select 0 from dual) from dba_tablespaces
minus
select distinct tablespace_name, (select 0 from dual) from dba_free_space))fss
where df.tablespace_name = fss.tablespace_name
and df.tablespace_name = UPPER(DECODE('&&tablespace', 'ALL',df.tablespace_name, '&tablespace'))
group by df.tablespace_name,fss.free_gb
order by 4 desc;