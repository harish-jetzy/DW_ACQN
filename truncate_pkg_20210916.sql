create or replace PACKAGE BODY IDW_TRUNCATE_PKG as
v_num number(10):=0;
v_user varchar2(100);
v_owner varchar2(100);

sql_stmt varchar2(200);

PROCEDURE TRUNCATE_TABLE(v_name IN varchar2) IS

begin
 
select username into v_owner from user_users;
select sys_context('USERENV','SESSION_USER') into v_user from dual;

sql_stmt:=' truncate table '||v_owner||'.'|| v_name;

if (v_owner = v_user) then
   execute immediate sql_stmt; 
   
else
   select SUM(totcounts) into v_num from (
     select count(*) totcounts
     from all_tab_privs
     where table_name = upper(v_name)
     and  table_schema = upper(v_owner)
     and grantee = v_user
     and privilege in 'DELETE'
    union
     SELECT COUNT(*) totcounts  FROM ROLE_TAB_PRIVS A
      WHERE ROLE IN (SELECT GRANTED_ROLE FROM USER_ROLE_PRIVS)
     AND OWNER =upper(v_owner)
     AND TABLE_NAME=upper(v_name)
    AND PRIVILEGE='DELETE');

  if (v_num > 0 or v_num = 0) then
     execute immediate sql_stmt;
  else
     raise_application_error(-20001,'The user does not have Delete privilege as per all_tab_privs');
  end if;
end if;


exception

when others then
raise_application_error(-20002,'The user has insufficient privileges');
END TRUNCATE_TABLE;

end IDW_TRUNCATE_PKG;