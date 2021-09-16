create table cv_env_var_jn
 (jn_operation char(3) not null
 ,jn_oracle_user varchar2(30) not null
 ,jn_datetime date not null
 ,jn_notes varchar2(240)
 ,jn_appln varchar2(35)
 ,jn_session number(38)
 ,id number not null
 ,var_name varchar2 (255 byte)
 ,var_val varchar2 (4000 byte)
 ,created date not null
 ,created_by varchar2 (255 byte) not null
 ,updated date not null
 ,updated_by varchar2 (255 byte) not null
 )
 /