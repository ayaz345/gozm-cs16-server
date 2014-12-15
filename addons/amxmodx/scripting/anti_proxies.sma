#include <amxmodx>

public plugin_init()
{
    return register_plugin("Anti Proxies", "1.0", "Sho0ter");
}

public client_connect(id)
{
    new inf[32];
    get_user_info(id, "_ip", inf, 31);
    if(strlen(inf))
    {
        new name[32]
        get_user_name(id, name, 31)
        log_amx("[PROXIES]: %s uses proxy!", name)
        set_user_info(id, "_ip", "");
        client_cmd(id, "Setinfo ^"_ip^" ^"^";Disconnect;Connect %s;Clear", inf);
    }
    return PLUGIN_CONTINUE;
}