#include <amxmodx>
#include <colored_print>
#include <gozm>

new cvar_forum, cvar_demo_name

public plugin_init()
{
    register_plugin("Demo recorder & Info", "1.0", "Dimka")
}

public plugin_precache()
{
    cvar_forum = register_cvar("info_forum", "vk.com/go_zombie")
    cvar_demo_name = register_cvar("info_demoname", "go_zombie")
}

public client_putinserver(id)
{
    set_task(7.0, "record_demo", id)
}

public record_demo(id)
{
    new forum[32]
    get_pcvar_string(cvar_forum, forum, 31)
    if(forum[0])
        colored_print(id, "^x01 Общайся:^x04 %s", forum)

    static demo_name[32]
    get_pcvar_string(cvar_demo_name, demo_name, 31)
    if(demo_name[0])
    {
        colored_print(id, "^x01 Записывается демка:^x03 %s.dem", demo_name)
        client_cmd(id, "stop")
        if (has_vip(id) && !has_rcon(id))
        {
            new CurrentTime[32]
            get_time("%H%M",CurrentTime,31)
            new CurrentDate[32]
            get_time("%y-%m-%d",CurrentDate,31)
            new mapname[32]
            get_mapname(mapname, 31)
            client_cmd( id,"record %s_%s_%s", CurrentDate, CurrentTime, mapname)
        }
        else
            client_cmd(id, "record %s", demo_name)
    }
}
