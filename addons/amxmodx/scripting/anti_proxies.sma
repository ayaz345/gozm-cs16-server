#include <amxmodx>

public plugin_init()
{
    register_plugin("Anti Proxies", "1.0", "Sho0ter")

    return PLUGIN_CONTINUE
}

public client_connect(id)
{
    static inf[32]
    get_user_info(id, "_ip", inf, 31)
    if(strlen(inf))
    {
        static name[32], steam[32], ip[16]
        get_user_name(id, name, charsmax(name))
        get_user_authid(id, steam, charsmax(steam))
        get_user_ip(id, ip, charsmax(ip), 1)

        log_amx("[PROXIES]: %s uses proxy! (%s, %s)", name, steam, ip)
        set_user_info(id, "_ip", "")
        client_cmd(id, "Setinfo ^"_ip^" ^"^";Disconnect;Connect %s;Clear", inf)
    }

    return PLUGIN_CONTINUE
}
