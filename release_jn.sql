PRO _________________________________________________
PRO . JOURNALING TABLE OBJECTS

@tables/cv_env_var_jn.sql
@triggers/cv_env_var_jntrg.sql
@views/journal_table_audit_vw.sql

select *
from journal_table_audit_vw
/
update cv_env_var_jn
set jn_operation = upper(jn_operation)
where jn_operation = lower(jn_operation)
/
select jn_operation, jn_oracle_user, var_name, var_val, created, updated, updated_by,
       case when jn_operation = 'UPD'
            then apex_string.format(p_message => '%0 updated a record on %4 : the value of %1 changed from "%2" to "%3"', 
                                    p0 => initcap(jn_oracle_user),
                                    p1 => var_name,
                                    p2 => var_val,
                                    p4 => to_char(updated, 'DD-MON'))
            else ''
            end as summary
from cv_env_var_jn