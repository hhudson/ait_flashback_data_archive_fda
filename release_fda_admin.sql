PRO _________________________________________________
PRO . FLASKBACK DATA ARCHIVE ADMIN
-- create a tablespace for archive data named archive_data


-- now create an archive *in* that tablespace
create default flashback archive fda1year tablespace archive_data retention 1 year ;
exec dbms_flashback_archive.set_context_level('ALL');

grant execute on dbms_flashback_archive to hayden;

