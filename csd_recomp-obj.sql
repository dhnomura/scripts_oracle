set serveroutput on
exec DBMS_OUTPUT.ENABLE(1000000);
DECLARE
X Number:=0;
Y Number:=0;

CURSOR c1 is
	select count(*) s_count_inv
	from dba_objects
	where status = 'INVALID'
	and owner not in ('SYS','SYSTEM');

CURSOR c2 is
	select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)||' '||owner||'.'||object_name||' compile '||
	decode(object_type,'PACKAGE BODY','body','PACKAGE','BODY') s_recp_inv
	from dba_objects
	where status='INVALID' 
	and owner not in ('SYS','SYSTEM');

BEGIN

    FOR i IN c1 LOOP
	dbms_output.put_line('Numeros de Objetos Invalidos: '||i.s_count_inv); 
    END LOOP;

    FOR i IN c2 LOOP
	dbms_output.put_line(i.s_recp_inv); 
	BEGIN
		dbms_output.put_line('SQL >> '|| i.s_recp_inv); 
        execute immediate i.s_recp_inv;
		X:=X+1;		
	EXCEPTION
		WHEN OTHERS THEN
		dbms_output.put_line('error:' || sqlerrm);
		Y:=Y+1;
	END;
    END LOOP;
    dbms_output.put_line('Success Recompiled: '||X); 
    dbms_output.put_line('Failed Recompiled: '||Y);
END;
/
