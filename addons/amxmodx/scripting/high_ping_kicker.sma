#include <amxmodx>
#include <colored_print>
#include <gozm>

new g_Ping[33]
new g_Samples[33]

new p_amx_hpk_ping, p_amx_hpk_tests, p_amx_hpk_delay

public plugin_init()
{
    register_plugin("High Ping Kicker", "1.0", "GoZm")

    p_amx_hpk_ping = register_cvar("amx_hpk_ping","200")
    p_amx_hpk_tests = register_cvar("amx_hpk_tests","5")
    p_amx_hpk_delay = register_cvar("amx_hpk_delay","60")

    if (get_pcvar_num(p_amx_hpk_tests) < 3)
        set_cvar_num("amx_hpk_tests", 3)
}

public client_putinserver(id)
{
    g_Ping[id] = 0
    g_Samples[id] = 0

    if (has_vip(id))
        return PLUGIN_CONTINUE

    new param[1]
    param[0] = id
    set_task(float(get_pcvar_num(p_amx_hpk_delay)), "checkPing", id, param, 1, "b")

    return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
    remove_task(id)
}

public checkPing(param[])
{
    new id = param[0]

    new ping, loss
    get_user_ping(id, ping, loss)

    g_Ping[id] += ping
    ++g_Samples[id]

    if (g_Samples[id] > get_pcvar_num(p_amx_hpk_tests))
    {
        if (g_Ping[id] / g_Samples[id] > get_pcvar_num(p_amx_hpk_ping))
        {
            kickPlayer(id)
        }
        else
        {
            g_Samples[id] = 1
            g_Ping[id] = ping
        }
    }
    else if (g_Samples[id] == get_pcvar_num(p_amx_hpk_tests)-1)
    {
        if (g_Ping[id] / g_Samples[id] > get_pcvar_num(p_amx_hpk_ping))
            colored_print(id, "^x04***^x01 У тебя высокий пинг: %d", g_Ping[id] / g_Samples[id])
    }
}

public kickPlayer(id)
{
    new name[32], authid[32]
    get_user_name(id, name, 31)
    get_user_authid(id, authid, 31)
    server_cmd("kick #%d Высокий пинг - %d", get_user_userid(id), g_Ping[id] / g_Samples[id])

    log_amx("[HPK]: ^"%s^" was kicked due to highping %d", name, g_Ping[id] / g_Samples[id])
}
