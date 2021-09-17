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
    )
select *
    from ait_audit
/