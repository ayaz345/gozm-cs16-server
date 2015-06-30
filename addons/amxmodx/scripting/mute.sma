#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <colored_print>
#include <gozm>

new const g_preffix[] = "[MUTE]:"

new g_GagPlayers[MAX_PLAYERS]

new mutedIp[64][16]
new muted_num = 1

public plugin_init()
{
    register_plugin("Mute Menu", "2.1", "GoZm")

    register_clcmd("say /mute", "clcmd_mute")
    register_clcmd("say_team /mute", "clcmd_mute")
    register_clcmd("say /speak", "clcmd_speak")
    register_clcmd("say_team /speak", "clcmd_speak")
    register_clcmd("say /unmute", "clcmd_speak")
    register_clcmd("say_team /unmute", "clcmd_speak")

    register_clcmd("say", "block_gagged")
    register_clcmd("say_team", "block_gagged")

    register_concmd("radio1", "hook_radio")
    register_concmd("radio2", "hook_radio")
    register_concmd("radio3", "hook_radio")
}

public clcmd_mute(id)
{
    if (is_priveleged_user(id))
        display_mutemenu(id)
    else
        colored_print(id, "^x04%s^x01 Затычка доступна только ВИПам!", g_preffix)

    return PLUGIN_HANDLED
}

public clcmd_speak(id)
{
    if (is_priveleged_user(id))
        display_speakmenu(id)
    else
        colored_print(id, "^x04%s^x01 Затычка доступна только ВИПам!", g_preffix)

    return PLUGIN_HANDLED
}

public hook_radio(id)
{
    if (g_GagPlayers[id])
    {
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

display_mutemenu(id)
{
    static i_Menu
    i_Menu = menu_create("\wКого \yзаткнем\w?", "mute_player_menu_handler" )

    static players[32], num, i
    get_players(players, num)
    for (i=0; i<num; i++)
    {
        static name[32], str_id[3]
        get_user_name(players[i], name, charsmax(name))
        num_to_str(players[i], str_id, charsmax(str_id))

        menu_additem(i_Menu, name, str_id, _, menu_makecallback("check_for_muted_victim"))
    }

    menu_setprop(i_Menu, MPROP_BACKNAME, "Назад")
    menu_setprop(i_Menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(i_Menu, MPROP_EXITNAME, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public check_for_muted_victim(id, menu, item)
{
    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if (victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || g_GagPlayers[victim_id])
        return ITEM_DISABLED

    return ITEM_ENABLED
}

public mute_player_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)
    menu_destroy(menu)

    victim_id = str_to_num(s_Id)
    CMD_GagPlayer(id, victim_id)

    return PLUGIN_HANDLED
}

display_speakmenu(id)
{
    static i_Menu
    i_Menu = menu_create("\wРазрешим \yговорить\w:", "speak_player_menu_handler" )

    static players[32], num, i
    get_players(players, num)
    for (i = 0; i < num; i++)
    {
        static name[32], str_id[3]
        get_user_name(players[i], name, charsmax(name))
        num_to_str(players[i], str_id, charsmax(str_id))

        menu_additem(i_Menu, name, str_id, _, menu_makecallback("check_for_speaking_victim"))
    }

    menu_setprop(i_Menu, MPROP_BACKNAME, "Назад")
    menu_setprop(i_Menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(i_Menu, MPROP_EXITNAME, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public check_for_speaking_victim(id, menu, item)
{
    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if (victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || !g_GagPlayers[victim_id])
        return ITEM_DISABLED

    return ITEM_ENABLED
}

public speak_player_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)
    menu_destroy(menu)

    victim_id = str_to_num(s_Id)
    CMD_UnGagPlayer(id, victim_id)

    return PLUGIN_HANDLED
}

public block_gagged(id)
{
    if (!g_GagPlayers[id])
        return PLUGIN_CONTINUE

    static cmd[5]
    read_argv(0, cmd, charsmax(cmd))
    if (cmd[3] == '_')
    {
        if (g_GagPlayers[id] & 2)
        {
            colored_print(id, "^x04%s^x01 Тебя заткнули!", g_preffix)
            return PLUGIN_HANDLED
        }
    }
    else if (g_GagPlayers[id] & 1)
    {
        colored_print(id, "^x04%s^x01 Тебя заткнули!", g_preffix)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

CMD_GagPlayer(VIP, VictimID)
{
    if (has_vip(VictimID) && VictimID != VIP)
        return PLUGIN_HANDLED;

    if (!is_user_connected(VictimID))
        return PLUGIN_HANDLED;

    static s_Flags[4], flags
    formatex(s_Flags, charsmax(s_Flags), "abc")
    flags = read_flags(s_Flags) // Converts the string flags ( a,b or c ) into a int
    g_GagPlayers[VictimID] = flags

    set_speak(VictimID, SPEAK_MUTED)

    static AdminName[32], VictimName[32]
    get_user_name(VIP, AdminName, charsmax(AdminName))
    get_user_name(VictimID, VictimName, charsmax(VictimName))

    if (!has_rcon(VIP))
        colored_print(0, "^x04%s^x03 %s^x01 умолк благодаря випу %s", g_preffix, VictimName, AdminName)
    else
        console_print(VIP, "%s %s is silented", g_preffix, VictimName)

    return PLUGIN_HANDLED
}

CMD_UnGagPlayer(VIP, VictimID)
{
    if (has_vip(VictimID) && VictimID != VIP)
        return PLUGIN_HANDLED

    static AdminName[32], VictimName[32]
    get_user_name(VIP, AdminName, charsmax(AdminName))
    get_user_name(VictimID, VictimName, charsmax(VictimName))

    if (!g_GagPlayers[VictimID])
    {
        console_print(VIP, "%s %s Is Not Gagged & Cannot Be Ungagged", g_preffix, VictimName)
        return PLUGIN_HANDLED
    }

    if (!has_rcon(VIP))
        colored_print(0, "^x04%s^x03 %s^x01 может говорить благодаря випу %s",
            g_preffix, VictimName, AdminName)
    else
        console_print(VIP, "%s %s is free", g_preffix, VictimName)

    UnGagPlayer(VictimID)

    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
    static checkIp[16]
    get_user_ip(id, checkIp, charsmax(checkIp), 1)

    static i
    for (i = 1; i < 30; i++)
    {
        if(contain(mutedIp[i], checkIp) != -1 && !has_vip(id))
        {
            static s_Flags[4], flags
            formatex(s_Flags, charsmax(s_Flags), "abc")
            flags = read_flags(s_Flags) // Converts the string flags ( a,b or c ) into a int
            g_GagPlayers[id] = flags

            set_speak(id, SPEAK_MUTED)
        }
    }
}

public client_disconnect(id)
{
    if (g_GagPlayers[id])
    {
        UnGagPlayer(id)

        static gaggedIp[16]
        get_user_ip(id, gaggedIp, charsmax(gaggedIp), 1)
        mutedIp[muted_num] = gaggedIp
        muted_num++
    }
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE

    static newname[32], oldname[32]
    get_user_info(id, "name", newname, charsmax(newname))
    get_user_name(id, oldname, charsmax(oldname))

    if (!equal(oldname, newname) && !equal(oldname, ""))
        set_task(0.2, "check_access", id)

    return PLUGIN_CONTINUE
}

public check_access(id)
{
    if (has_vip(id) && g_GagPlayers[id])
        UnGagPlayer(id)

    return PLUGIN_CONTINUE
}

UnGagPlayer(id)
{
    if ((g_GagPlayers[id] & 4) && is_user_connected(id))
    {
        set_speak(id, SPEAK_ALL)
    }
    g_GagPlayers[id] = 0
}
