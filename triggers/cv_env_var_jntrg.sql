create or replace trigger cv_env_var_jntrg
  after 
  insert or 
  update or 
  delete on cv_env_var for each row 
 declare 
  rec cv_env_var_jn%rowtype; 
  blank cv_env_var_jn%rowtype; 
  begin 
    rec := blank; 
    if inserting or updating then 
      rec.id := :new.id; 
      rec.var_name := :new.var_name; 
      rec.var_val := :new.var_val; 
      rec.created := :new.created; 
      rec.created_by := :new.created_by; 
      rec.updated := :new.updated; 
      rec.updated_by := :new.updated_by; 
      rec.jn_datetime := sysdate; 
      rec.jn_oracle_user := sys_context ('USERENV', 'SESSION_USER'); 
      rec.jn_appln := sys_context ('USERENV', 'MODULE'); 
      rec.jn_session := sys_context ('USERENV', 'SESSIONID'); 
      if inserting then 
        rec.jn_operation := 'INS'; 
      elsif updating then 
        rec.jn_operation := 'UPD'; 
      end if; 
    elsif deleting then 
      rec.id := :old.id; 
      rec.var_name := :old.var_name; 
      rec.var_val := :old.var_val; 
      rec.created := :old.created; 
      rec.created_by := :old.created_by; 
      rec.updated := :old.updated; 
      rec.updated_by := :old.updated_by; 
      rec.jn_datetime := sysdate; 
      rec.jn_oracle_user := sys_context ('USERENV', 'SESSION_USER'); 
      rec.jn_appln := sys_context ('USERENV', 'MODULE'); 
      rec.jn_session := sys_context ('USERENV', 'SESSIONID'); 
      rec.jn_operation := 'DEL'; 
    end if; 
    insert into cv_env_var_jn values rec; 
  end; 