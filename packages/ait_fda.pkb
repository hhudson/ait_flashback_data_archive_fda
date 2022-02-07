create or replace package body ait_fda  is

    function my_context(p_xid       in raw,
                        p_namespace in varchar2,
                        p_parameter in varchar2)
                        return varchar2
    is

    l_context_value varchar2(256);
    fetch_is_null exception;
    pragma exception_init(fetch_is_null, -1405);
    begin
        
        select dbms_flashback_archive.get_sys_context(p_xid, p_namespace, p_parameter)
            into l_context_value
            from dual;
        
        return l_context_value;

    exception 
        when fetch_is_null then
            return null;
        when others then 
            raise;
    end my_context;
    
end ait_fda;