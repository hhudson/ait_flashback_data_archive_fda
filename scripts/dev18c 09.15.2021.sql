select id, text, scope, extra
from logger_logs
where id > 85641
order by id
desc
/
with ait_audit as (
    select
        versions_operation,
        var_name,
        var_val,
        versions_startscn,
        versions_starttime,
        versions_endscn,
        versions_endtime,
        versions_xid,
        updated,
        updated_by,
        created,
        created_by,
        ait_fda.my_context( p_xid       => versions_xid,
                            p_namespace => 'USERENV',
                            p_parameter => 'SESSION_USER') as session_user,
        ait_fda.my_context( p_xid       => versions_xid,
                            p_namespace => 'USERENV',
                            p_parameter => 'CLIENT_IDENTIFIER') as client_identifier,
        ait_fda.my_context( p_xid       => versions_xid,
                            p_namespace => 'APEX$SESSION',
                            p_parameter => 'APP_USER') as apex_user
    from
        cv_env_var 
    versions between timestamp to_timestamp('20210916161348492495000', 'YYYYMMDDHH24MISSFF9') and maxvalue
    ),
    audit_updates as (
    select aa.versions_operation, aa.var_name, aa.var_val old_val, aa1.var_val new_value, aa.updated, aa.updated_by,
            apex_string.format(p_message => '%0 updated %1 on %4 : from "%2" to "%3" on %4', 
                                p0 => initcap(aa.updated_by),
                                p1 => aa.var_name,
                                p2 => aa1.var_val,
                                p3 => aa.var_val,
                                p4 => to_char(aa.updated, 'DD-MON')) summary
    from ait_audit aa
    inner join ait_audit aa1 on aa.versions_startscn = aa1.versions_endscn
                            and aa.var_name = aa1.var_name
    where aa.versions_operation = 'U'
    ),
    audit_inserts as (
    select aa.versions_operation, aa.var_name, aa.var_val, aa.updated, aa.updated_by,
           apex_string.format(p_message => '%0 inserted a record on %4: var_name "%2" and var_val "%3" ', 
                              p0 => initcap(aa.updated_by),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa.updated, 'DD-MON')) summary
    from ait_audit aa
    where aa.versions_operation ='I'
    ),
    audit_inserts as (
    select aa.versions_operation, aa.var_name, aa.var_val, aa.updated, aa.updated_by,
           apex_string.format(p_message => '%0 inserted a record on %4: var_name "%2" and var_val "%3" ', 
                              p0 => initcap(aa.updated_by),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa.updated, 'DD-MON')) summary
    from ait_audit aa
    where aa.versions_operation ='I'
    )
select summary, updated
from audit_updates
union all
select summary, updated
from audit_inserts
/
select *
from fda_audit_vw
/
select to_timestamp('20210916104404143915000', 'YYYYMMDDHH24MISSFF9')
from dual
/
select to_char(systimestamp,'YYYYMMDDHH24MISSFF9') from dual;
/
select *
from all_tab_cols
where column_name like '%context%' collate binary_ci
/
select apex_string.format('select ''%0'' var_name, ''%1'' var_val from dual union all', var_name, var_val) code
from cv_env_var;
/
SELECT *
FROM cv_env_var
/
select *
from cv_env_var_jn
/
update cv_env_var_jn
set jn_operation = upper(jn_operation)
where jn_operation = lower(jn_operation)
/
begin
DBMS_FLASHBACK_ARCHIVE.set_context_level('ALL');
end;
/
with ait_audit as (
    select
        versions_startscn,
        versions_starttime,
        versions_endscn,
        versions_endtime,
        versions_xid,
        versions_operation,
        var_name,
        var_val,
        created,
        created_by, 
        updated,
        updated_by
    from
        cv_env_var versions
    between timestamp to_timestamp('20210914034404143915000', 'YYYYMMDDHH24MISSFF9') and maxvalue
    ),
parsing_audit as (
    select aa.versions_operation, aa.var_name, aa.var_val, aa1.var_val, aa.updated, aa.updated_by, aa.created, aa.created_by, aa.versions_starttime, aa.versions_endtime,
           apex_string.format(p_message => '%0 updated %1 on %4 : from "%2" to "%3" on %4', 
                              p0 => initcap(aa.updated_by),
                              p1 => aa.var_name,
                              p2 => aa1.var_val,
                              p3 => aa.var_val,
                              p4 => to_char(aa.updated, 'DD-MON HH:MI')) summary
    from ait_audit aa
    inner join ait_audit aa1 on aa.versions_startscn = aa1.versions_endscn
                             and aa.var_name = aa1.var_name
    where aa.versions_operation = 'U'
    union all
    select aa.versions_operation, aa.var_name, aa.var_val, null, aa.updated, aa.updated_by, aa.created, aa.created_by, aa.versions_starttime, aa.versions_endtime,
           apex_string.format(p_message => '%0 inserted a record on %4: var_name "%2" and var_val "%3" ', 
                              p0 => initcap(aa.updated_by),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa.updated, 'DD-MON HH24:MI')) summary
    from ait_audit aa
    where aa.versions_operation in ('I')
    union all
    select aa.versions_operation, aa.var_name, aa.var_val, null, aa1.versions_endtime, aa.updated_by, aa.created, aa.created_by, aa.versions_starttime, aa1.versions_endtime,
           apex_string.format(p_message => '%0 deleted a record on %4: var_name "%2" and var_val "%3" ', 
                              p0 => initcap(aa.updated_by),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa1.versions_endtime, 'DD-MON HH24:MI')) summary
    from ait_audit aa
    inner join ait_audit aa1 on aa.versions_startscn = aa1.versions_endscn
                             and aa.var_name = aa1.var_name
    where aa.versions_operation in ('D')
    )

select pa.summary, pa.updated, pa.updated_by, pa.created, pa.created_by, pa.versions_starttime, pa.versions_endtime
    from parsing_audit pa
    order by pa.updated desc
/
drop trigger cv_env_var_biu
/
drop trigger cv_env_var_biud
/
create or replace trigger cv_env_var_biu
    before insert or update
    on cv_env_var
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
    if inserting then
        :new.created := sysdate;
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
end cv_env_var_biu;
/
create or replace trigger cv_env_var_biud
    before insert or update or delete
    on cv_env_var
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
    if inserting then
        :new.created := sysdate;
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
end cv_env_var_biud;
/
select
    versions_operation,
    var_name,
    var_val old_value,
    null new_value,
    
    versions_startscn,
    versions_starttime,
    versions_endscn,
    versions_endtime,
    versions_xid
    ,DBMS_FLASHBACK_ARCHIVE.get_sys_context(versions_xid, 'USERENV','SESSION_USER') AS session_user
    ,DBMS_FLASHBACK_ARCHIVE.get_sys_context(versions_xid, 'USERENV','CLIENT_IDENTIFIER') AS client_identifier
    ,DBMS_FLASHBACK_ARCHIVE.get_sys_context(versions_xid, 'APEX$SESSION','APP_USER') AS apex_user
    -- place these functions to suppress these errors
    -- also demo "data at a certrain time"
from
    cv_env_var versions
between timestamp to_timestamp('20210914034404143915000', 'YYYYMMDDHH24MISSFF9') and maxvalue
where var_name = 'FILE_DIRECTORY'
and var_val = '/Docs/Profile/AIT/files/'
/
select  var_name, var_val, created_by, updated_by
from cv_env_var
versions between timestamp TO_TIMESTAMP('20210914034404143915000', 'YYYYMMDDHH24MISSFF9') and maxvalue
where versions_operation = 'U'
/

alter table CV_ENV_VAR flashback archive fda1year;
/
select *
from CV_ENV_VAR
/
insert into cv_env_var (var_name, var_val)
values ('API_URL', 'c2dev.concept2completion.com');
/
insert into cv_env_var (var_name, var_val)
values ('API_KEY', '0192IKI123090019910OI');
/
DELETE FROM cv_env_var
WHERE VAR_NAME = 'AOP_API_KEY'
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
select to_char(systimestamp,'YYYYMMDDHH24MISSFF9') from dual;