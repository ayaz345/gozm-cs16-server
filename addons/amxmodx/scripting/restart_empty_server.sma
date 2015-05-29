#include <amxmodx>
#include <amxmisc>

#define MAX_CHECKS      3

#define LOG_FOLDER      "RR"

new g_server_is_empty, g_restart_logfile[64]

public plugin_init()
{
    register_plugin("Restart Empty Server", "1.1", "GoZm")

    new cur_date[11]
    get_time("%Y.%m.%d", cur_date, charsmax(cur_date))
    get_basedir(g_restart_logfile, charsmax(g_restart_logfile))
    format(g_restart_logfile, charsmax(g_restart_logfile), 
        "%s/logs/%s", g_restart_logfile, LOG_FOLDER)
    if (!dir_exists(g_restart_logfile))
        mkdir(g_restart_logfile)
    format(g_restart_logfile, charsmax(g_restart_logfile), 
        "%s/restart_%s.log", g_restart_logfile, cur_date)

    if (!file_exists(g_restart_logfile))
        set_task(60.0, "restart_empty_server", _, _, _, "b")
}

public restart_empty_server()
{
    if (!get_playersnum(1))  // with connecting people
    {
        if (++g_server_is_empty >= MAX_CHECKS)
        {
            log_to_file(g_restart_logfile, "Going to restart...")
            server_cmd("quit")
        }
    }
    else
        g_server_is_empty = 0
}
