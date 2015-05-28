#include <amxmodx>
#include <amxmisc>
#include <colored_print>
#include <gozm>

public plugin_init()
{
    register_plugin("Admin Chat", "2.0", "GoZm")

    if (!is_server_licenced())
        return PLUGIN_CONTINUE

    register_clcmd("say", "cmdSayAdmin", 0, "@<text> - displays message to admins")
    register_clcmd("say_team", "cmdSayAdmin", 0, "@<text> - displays message to admins")

    return PLUGIN_CONTINUE
}

public cmdSayAdmin(id)
{
    new said[2]
    read_argv(1, said, charsmax(said))

    if (said[0] != '@')
        return PLUGIN_CONTINUE

    new message[192], duplicate_message[192]
    new name[32]
    new players[32], inum

    read_args(message, charsmax(message))
    remove_quotes(message)
    get_user_name(id, name, charsmax(name))

    // FOR CHAT LOGGING
    new cur_date[3], logfile[13]
    new log_path[128]

    get_time("%d", cur_date, charsmax(cur_date))
    formatex(logfile, charsmax(logfile), "chat_%s.log", cur_date)
    get_basedir(log_path, charsmax(log_path))  // addons/amxmodx
    format(log_path, charsmax(log_path), "%s/logs/chat/%s", log_path, logfile)
    log_to_file(log_path, "*VIP* %s: %s", name, message[1])

    duplicate_message = message
    format(message, charsmax(message), "^x04 %s^x03 %s^x01 : %s", "*VIP*", name, message[1])

    get_players(players, inum)

    new target
    for (new i = 0; i < inum; ++i)
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
