merge into cv_env_var a
using(
    select 'FILE_DIRECTORY' var_name, '/Docs/Profile/AIT/files/' var_val from dual 
    union all
    select 'AOP_URL' var_name, 'https://www.apexofficeprint.com/dev/' var_val from dual 
    union all
    select 'FILE_DATE_FORMAT' var_name, 'dd_mon_yyyy' var_val from dual 
    union all
    select 'STORE_AS_FILE_OR_BLOB' var_name, 'BLOB' var_val from dual 
    union all
    select 'API_KEY' var_name, '0192IKI123090019910OI' var_val from dual 
    union all
    select 'USERNAME' var_name, 'ait_admin' var_val from dual 
    union all
    select 'IP_ADDRESS' var_name, '2611:1841:417f:6b0:7d15:1abd:2883:2eb9' var_val from dual
    union all
    select 'ADDRESS' var_name, '312 MAIN ST' var_val from dual
    union all
    select 'LANGUAGE' var_name, 'English' var_val from dual
    union all
    select 'TIMEZONE' var_name, 'EST' var_val from dual
      ) b
on (a.var_name  = b.var_name)
when matched then update set
    a.var_val = b.var_val 
when not matched then
    insert (  var_name,   var_val)
    values (b.var_name, b.var_val)
/
DELETE FROM cv_env_var
WHERE VAR_NAME = 'TIMEZONE'
/
DELETE FROM cv_env_var
WHERE VAR_NAME = 'ADDRESS'
/
DELETE FROM cv_env_var
WHERE VAR_NAME = 'LANGUAGE'
/
insert into cv_env_var (var_name, var_val)
values ('API_URL', 'c2dev.concept2completion.com');
/
insert into cv_env_var (var_name, var_val)
values ('API_KEY', '0192IKI123090019910OI');
/

UPDATE cv_env_var
SET VAR_VAL = '/Docs/Profile/AIT'
where var_name = 'FILE_DIRECTORY'
/
insert into cv_env_var (var_name, var_val)
values ('USERNAME', 'ait_admin');
/
insert into cv_env_var (var_name, var_val)
values ('IP_ADDRESS', '2611:1841:417f:6b0:7d15:1abd:2883:2eb9');
/