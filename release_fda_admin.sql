PRO _________________________________________________
PRO . FLASKBACK DATA ARCHIVE ADMIN

create flashback archive fda1year tablespace users retention 1 year ;
exec dbms_flashback_archive.set_context_level('ALL');

alter table cv_env_var flashback archive fda1year;