#include <amxmodx>
#include <colored_print>
#include <gozm>

#define PREFIX      "***"

new cvar_info_delay
new cvar_forum
new cvar_demo_name

new g_server_ip[32]

new g_maxplayers

public plugin_init()
{
    register_plugin("Informer", "2.1", "GoZm")

    cvar_info_delay = register_cvar("amx_info_delay", "7")
    cvar_forum = register_cvar("amx_info_forum", "vk.com/go_zombie")
    cvar_demo_name = register_cvar("amx_info_demoname", "go_zombie")

    g_maxplayers = get_maxplayers()

    get_user_ip(0, g_server_ip, charsmax(g_server_ip), 0)

    set_task(1.0, "task_showserverinfo", _, _, _, "b")
}

public client_putinserver(id)
{
    set_task(float(get_pcvar_num(cvar_info_delay)), "record_demo", id)
}

public record_demo(id)
{
    /*
    1/3 - vkontakte
    */
    static forum[32]
    get_pcvar_string(cvar_forum, forum, charsmax(forum))
    if(forum[0])
        colored_print(id, "^x04%s^x01 Общайся:^x04 %s", PREFIX, forum)

    /*
    2/3 - demo
    */
    static demo_name[32]
    get_pcvar_string(cvar_demo_name, demo_name, charsmax(demo_name))
    if(demo_name[0])
    {
        colored_print(id, "^x04%s^x01 Записывается демка:^x03 %s.dem", PREFIX, demo_name)
        client_cmd(id, "stop")
        if (has_vip(id) && !has_rcon(id))
        {
            static CurrentTime[32], CurrentDate[32]
            static mapname[32]

            get_time("%H%M", CurrentTime, charsmax(CurrentTime))
            get_time("%y-%m-%d", CurrentDate, charsmax(CurrentDate))
            get_mapname(mapname, charsmax(mapname))

            client_cmd( id,"record %s_%s_%s_%s", demo_name, CurrentDate, CurrentTime, mapname)
        }
        else
        {
            client_cmd(id, "record %s", demo_name)
        }
    }

    /*
    3/3 - server menu
    */
    colored_print(id, "^x04%s^x01 Меню сервера на^x04 M", PREFIX)
}

public task_showserverinfo()
{
    static id
    for (id = 1; id <= g_maxplayers; id++)
        if (is_user_connected(id) && !is_user_alive(id))
        {
            set_dhudmessage(0, 255, 0, 0.045, 0.18, 0, _, 1.1, 0.0, 0.0)
            show_dhudmessage(id, "%s^n%s", g_server_ip, "vk.com/go_zombie")
        }
}
