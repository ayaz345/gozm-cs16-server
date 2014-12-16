#include <amxmodx>
#include <amxmisc>

new g_server_is_empty, g_restart_logfile[64]

public plugin_init()
{
    register_plugin("Restart Empty Server", "1.0", "Dimka");

    new cur_date[3]
    get_time("%d", cur_date, 2)
    get_basedir(g_restart_logfile, 63)  // addons/amxmodx
    format(g_restart_logfile, 63, "%s/logs/server_restart_%s.log", g_restart_logfile, cur_date)
    if(!file_exists(g_restart_logfile))
        set_task(60.0, "restart_empty_server", _, _, _, "b")
}

public restart_empty_server()
{
    if(!get_playersnum(1))  // with connecting people
    {
        if(++g_server_is_empty >= 3)
        {
            log_to_file(g_restart_logfile, "Going to restart...")
            server_cmd("quit")
        }
    }
    else
        g_server_is_empty = 0
}
