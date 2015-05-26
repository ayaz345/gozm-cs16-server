#include <amxmodx>
#include <gozm>

#define TASKID_CLEAN    411

new const COLCHAR[3][2] = {"^x03"/*командный*/, "^x04"/*зеленый*/, "^x01"/*желтый*/}

//vars to check if message has already been duplicated
new alv_sndr, alv_str2[26], alv_str4[101]
new g_msg[200], g_duplicate_msg[200]

new g_msg_saytext

public plugin_init()
{
    register_plugin("All Chat", "1.1", "Ian Cammarata")

    if(!is_server_licenced())
        return PLUGIN_CONTINUE

    g_msg_saytext = get_user_msgid("SayText")
    register_message(g_msg_saytext, "col_changer")

    set_task(1.0, "clean_next_file")

    return PLUGIN_CONTINUE
}

public clean_next_file()
{
    new next_log_file_path[128]
    new next_log_file[12]  // for logging
    new s_cur_date[3]
    new i_next_date

    get_localinfo("amxx_basedir", next_log_file_path, charsmax(next_log_file_path))

    get_time("%d", s_cur_date, charsmax(s_cur_date))
    i_next_date = str_to_num(s_cur_date) + 1
    if (i_next_date < 10)
        format(next_log_file, charsmax(next_log_file), "chat_0%d.log", i_next_date)
    else
        format(next_log_file, charsmax(next_log_file), "chat_%d.log", i_next_date)

    format(next_log_file_path, charsmax(next_log_file),
        "%s/logs/%s", next_log_file_path, next_log_file)

    if (file_exists(next_log_file_path))
    {
        log_amx("[ALLCHAT]: Clean next file '%s'", next_log_file)
        delete_file(next_log_file_path)
    }
}

public col_changer(msg_id, msg_dest, rcvr)
{
    new str2[26]
    get_msg_arg_string(2, str2, charsmax(str2))
    if(equal(str2, "#Cstrike_Chat", 13))
    {
        new str3[22]
        get_msg_arg_string(3, str3, charsmax(str3))

        if(!strlen(str3))
        {
            new str4[101]
            get_msg_arg_string(4, str4, charsmax(str4))
            trim(str4)
            new sndr = get_msg_arg_int(1)
            new bool:same_as_last = bool:(
                alv_sndr == sndr &&
                equal(alv_str2, str2) &&
                equal(alv_str4, str4)
            )

            if(!same_as_last)
            {
                new players[32], num
                get_players(players, num)
                buildmsg(sndr, 0, 2, str4)

                for(new i=0; i<num; i++)
                {
                    if(is_user_connected(players[i]))
                    {
                        message_begin(MSG_ONE_UNRELIABLE, g_msg_saytext, _, players[i])
                        write_byte(sndr)
                        write_string(g_msg)
                        message_end()

                        // duplicate russian messages
                        console_print(players[i], g_duplicate_msg)
                    }
                }

                alv_sndr = sndr
                alv_str2 = str2
                alv_str4 = str4
                if(task_exists(TASKID_CLEAN)) remove_task(TASKID_CLEAN)
                set_task(0.1, "task_clear_antiloop_vars", TASKID_CLEAN)
            }
        }
    }

    return PLUGIN_HANDLED
}

buildmsg(sndr, namecol, msgcol, str4[])
{
    new sndr_name[32]
    get_user_name(sndr, sndr_name, charsmax(sndr_name))

    format(g_msg, charsmax(g_msg), "%s%s :  %s%s",
        COLCHAR[namecol], sndr_name,
        COLCHAR[msgcol], str4)
    format(g_duplicate_msg, charsmax(g_duplicate_msg), "%s : %s", sndr_name, str4)

    // FOR LOGGING
    new cur_date[3], logfile[13]
    get_time("%d", cur_date, charsmax(cur_date))
    format(logfile, charsmax(logfile), "chat_%s.log", cur_date)
    log_to_file(logfile, "%s: %s", sndr_name, str4)

    return PLUGIN_HANDLED
}

public task_clear_antiloop_vars()
{
	alv_sndr = 0
	alv_str2 = ""
	alv_str4 = ""
	return PLUGIN_HANDLED
}
