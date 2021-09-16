create or replace package ait_fda authid definer is

    function my_context(p_xid       in raw,
                        p_namespace in varchar2,
                        p_parameter in varchar2)
                        return varchar2;
    
end ait_fda;