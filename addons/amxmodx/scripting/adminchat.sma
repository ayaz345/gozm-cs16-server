#include <amxmodx>
#include <amxmisc>
#include <colored_print>
#include <gozm>

#define LOG_FOLDER      "chat"

new g_log_folder[64]

public plugin_init()
{
    register_plugin("Admin Chat", "2.0", "GoZm")

    if (!is_server_licenced())
        return PLUGIN_CONTINUE

    register_clcmd("say", "cmdSayAdmin", 0, "@<text> - displays message to admins")
    register_clcmd("say_team", "cmdSayAdmin", 0, "@<text> - displays message to admins")

    get_basedir(g_log_folder, charsmax(g_log_folder))
    format(g_log_folder, charsmax(g_log_folder), "%s/logs/%s", g_log_folder, LOG_FOLDER)
    if (!dir_exists(g_log_folder))
        mkdir(g_log_folder)

    return PLUGIN_CONTINUE
}

public cmdSayAdmin(id)
{
    static said[2]
    read_argv(1, said, charsmax(said))

    if (said[0] != '@')
        return PLUGIN_CONTINUE

    /*
    Make sure:
    message is not longer than 192 character as chat message,
    duplicate_message is not longer than 128 character as console message,
    otherwise it will crash the server
    */
    static message[191], duplicate_message[127]
    static name[32]
    static players[32], inum

    read_args(message, charsmax(message))
    remove_quotes(message)
    get_user_name(id, name, charsmax(name))

    // FOR CHAT LOGGING
    static cur_date[3], logfile[13]
    static log_path[128]

    get_time("%d", cur_date, charsmax(cur_date))
    formatex(logfile, charsmax(logfile), "chat_%s.log", cur_date)
    formatex(log_path, charsmax(log_path), "%s/%s", g_log_folder, logfile)
    log_to_file(log_path, "*VIP* %s: %s", name, message[1])

    copy(duplicate_message, charsmax(duplicate_message), message)
    format(message, charsmax(message), "^x04 %s^x03 %s^x01 : %s", "*VIP*", name, message[1])

    get_players(players, inum)

    static target, i
    for (i = 0; i < inum; ++i)
    {
        // don't print the message to the client that used the cmd
        // if he has ADMIN_CHAT to avoid double printing
        target = players[i]

        if (target != id && is_priveleged_user(target))
        {
            colored_print(target, "%s", message)

            // duplicate russian messages
            console_print(target, "%s: %s", name, duplicate_message[1])
        }
    }

    colored_print(id, "%s", message)
    console_print(id, "%s: %s", name, duplicate_message[1])

    return PLUGIN_HANDLED
}
