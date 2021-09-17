create or replace force view journal_table_audit_vw
as
select jn_operation, jn_oracle_user, var_name, var_val, created, updated, updated_by,
       case when jn_operation = 'UPD'
            then apex_string.format(p_message => '%0 updated a record on %4 : the new value of %1 changed is "%2"', 
                                    p0 => initcap(jn_oracle_user),
                                    p1 => var_name,
                                    p2 => var_val,
                                    p4 => to_char(updated, 'DD-MON'))
            else apex_string.format(p_message => '%0 %3 a record on %4 : name "%1", value "%2"', 
                                    p0 => initcap(jn_oracle_user),
                                    p1 => var_name,
                                    p2 => var_val,
                                    p3 => case when jn_operation = 'INS'
                                               then 'inserted'
                                               when jn_operation = 'DEL'
                                               then 'deleted'
                                               end,
                                    p4 => to_char(updated, 'DD-MON'))
            end as summary
from cv_env_var_jn
/