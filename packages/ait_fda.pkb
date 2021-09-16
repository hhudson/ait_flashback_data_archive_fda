create or replace package body ait_fda  is

    gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

    function my_context(p_xid       in raw,
                        p_namespace in varchar2,
                        p_parameter in varchar2)
                        return varchar2
    is
    l_scope  logger_logs.scope%type := gc_scope_prefix || 'my_context'; 
    l_params logger.tab_param;

    l_context_value varchar2(256);
    fetch_is_null exception;
    pragma exception_init(fetch_is_null, -1405);
    begin
        logger.append_param(l_params, 'p_xid', p_xid);
        logger.append_param(l_params, 'p_namespace', p_namespace);
        logger.append_param(l_params, 'p_parameter', p_parameter);
        --logger.log('START', l_scope, null, l_params);
        
        select dbms_flashback_archive.get_sys_context(p_xid, p_namespace, p_parameter)
            into l_context_value
            from dual;
        
        --logger.log('END', l_scope);
        return l_context_value;

    exception 
        when fetch_is_null then
            return null;
        when others then 
            logger.log_error('Unhandled Exception', l_scope, null, l_params); 
            raise;
    end my_context;
    
end ait_fda;