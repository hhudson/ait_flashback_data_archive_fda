create or replace force view fda_audit_vw
as
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
    versions between timestamp to_timestamp('20210916061348492495000', 'YYYYMMDDHH24MISSFF9') and maxvalue
    ),
    audit_updates as (
    select aa.versions_operation, aa.var_name, aa.var_val old_val, aa1.var_val new_value, aa.updated, aa.updated_by,
            apex_string.format(p_message => '%0 updated a record on %4: value of %1 changed from "%2" to "%3"', 
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
           apex_string.format(p_message => '%0 inserted a record on %4: name "%2" and value "%3" ', 
                              p0 => initcap(aa.updated_by),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa.updated, 'DD-MON')) summary
    from ait_audit aa
    where aa.versions_operation ='I'
    ),
    audit_deletions as (
    select aa.versions_operation, aa.var_name, aa.var_val, aa.updated_by, aa1.versions_endtime updated,
           apex_string.format(p_message => '%0 deleted a record on %4: name "%2" and value "%3" ', 
                              p0 => initcap(coalesce(aa1.apex_user,aa1.session_user, 'unknown user')),
                              p2 => aa.var_name,
                              p3 => aa.var_val,
                              p4 => to_char(aa1.versions_endtime, 'DD-MON')) summary
    from ait_audit aa
    inner join ait_audit aa1 on aa.versions_startscn = aa1.versions_endscn
                             and aa.var_name = aa1.var_name
    where aa.versions_operation = 'D'
    )
select summary, updated
    from audit_updates
union all
select summary, updated
    from audit_inserts
union all
select summary, updated
    from audit_deletions
/