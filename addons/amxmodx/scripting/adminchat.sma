#include <amxmodx>
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
    read_argv(1, said, 1)

    if (said[0] != '@')
        return PLUGIN_CONTINUE

    new message[192], duplicate_message[192]
    new name[32], authid[32]
    new players[32], inum

    read_args(message, 191)
    remove_quotes(message)
    get_user_authid(id, authid, 31)
    get_user_name(id, name, 31)

    // FOR CHAT LOGGING
    new cur_date[3], logfile[13]
    get_time("%d", cur_date, 2)
    format(logfile, 12, "chat_%s.log", cur_date)
    log_to_file(logfile, "*VIP* %s: %s", name, message[1])

    duplicate_message = message
    format(message, 191, "^x04 %s^x03 %s^x01 : %s", "*VIP*", name, message[1])

    get_players(players, inum)

    for (new i = 0; i < inum; ++i)
    {
        // dont print the message to the client that used the cmd if he has ADMIN_CHAT to avoid double printing
        if (players[i] != id && (has_vip(players[i]) || has_rcon(players[i])))
        {
            colored_print(players[i], "%s", message)

            // duplicate russian messages
            console_print(players[i], "%s: %s", name, duplicate_message[1])
        }
    }

    colored_print(id, "%s", message)
    console_print(id, "%s : %s", name, duplicate_message[1])

    return PLUGIN_HANDLED
}
