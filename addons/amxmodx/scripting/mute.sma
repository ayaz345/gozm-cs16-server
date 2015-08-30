#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <colored_print>
#include <gozm>

new const g_preffix[] = "[MUTE]:"

new bool:g_muted_player[MAX_PLAYERS+1]

new Array:g_muted_array

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

    g_muted_array = ArrayCreate(16)
}

public plugin_end()
{
    ArrayDestroy(g_muted_array)
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
    if (g_muted_player[id])
    {
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

display_mutemenu(id)
{
    static i_menu
    i_menu = menu_create("\wКого \yзаткнем\w?", "mute_player_menu_handler" )

    static players[32], num, i
    get_players(players, num)
    for (i=0; i<num; i++)
    {
        static name[32], str_id[3]
        get_user_name(players[i], name, charsmax(name))
        num_to_str(players[i], str_id, charsmax(str_id))

        menu_additem(i_menu, name, str_id, _, menu_makecallback("check_for_muted_victim"))
    }

    menu_setprop(i_menu, MPROP_BACKNAME, "Назад")
    menu_setprop(i_menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(i_menu, MPROP_EXITNAME, "Закрыть")

    menu_display(id, i_menu, 0)

    return PLUGIN_HANDLED
}

public check_for_muted_victim(id, menu, item)
{
    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if (victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || g_muted_player[victim_id])
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
    cmd_mute_player(id, victim_id)

    return PLUGIN_HANDLED
}

display_speakmenu(id)
{
    static i_menu
    i_menu = menu_create("\wРазрешим \yговорить\w:", "umnute_player_menu_handler" )

    static players[32], num, i
    get_players(players, num)
    for (i = 0; i < num; i++)
    {
        static name[32], str_id[3]
        get_user_name(players[i], name, charsmax(name))
        num_to_str(players[i], str_id, charsmax(str_id))

        menu_additem(i_menu, name, str_id, _, menu_makecallback("check_for_speaking_victim"))
    }

    menu_setprop(i_menu, MPROP_BACKNAME, "Назад")
    menu_setprop(i_menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(i_menu, MPROP_EXITNAME, "Закрыть")

    menu_display(id, i_menu, 0)

    return PLUGIN_HANDLED
}

public check_for_speaking_victim(id, menu, item)
{
    static s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if (victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || !g_muted_player[victim_id])
        return ITEM_DISABLED

    return ITEM_ENABLED
}

public umnute_player_menu_handler(id, menu, item)
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
    cmd_umnute_player(id, victim_id)

    return PLUGIN_HANDLED
}

public block_gagged(id)
{
    if (g_muted_player[id])
    {
        colored_print(id, "^x04%s^x01 Тебя заткнули!", g_preffix)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

cmd_mute_player(VIP, VictimID)
{
    if (has_vip(VictimID) && VictimID != VIP)
        return PLUGIN_HANDLED;

    if (!is_user_connected(VictimID))
        return PLUGIN_HANDLED

    mute_player(VictimID)

    static AdminName[32], VictimName[32]
    get_user_name(VIP, AdminName, charsmax(AdminName))
    get_user_name(VictimID, VictimName, charsmax(VictimName))
    if (!has_rcon(VIP))
        colored_print(0, "^x04%s^x03 %s^x01 умолк благодаря випу %s", g_preffix, VictimName, AdminName)
    else
        console_print(VIP, "%s %s is silented", g_preffix, VictimName)
    log_amx("[MUTE]: %s has muted %s", AdminName, VictimName)

    return PLUGIN_HANDLED
}

cmd_umnute_player(VIP, VictimID)
{
    if (has_vip(VictimID) && VictimID != VIP)
        return PLUGIN_HANDLED

    umnute_player(VictimID)

    static AdminName[32], VictimName[32]
    get_user_name(VIP, AdminName, charsmax(AdminName))
    get_user_name(VictimID, VictimName, charsmax(VictimName))
    if (!has_rcon(VIP))
        colored_print(0, "^x04%s^x03 %s^x01 может говорить благодаря випу %s",
            g_preffix, VictimName, AdminName)
    else
        console_print(VIP, "%s %s is free", g_preffix, VictimName)
    log_amx("[MUTE]: %s let speak %s", AdminName, VictimName)

    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
    static player_ip[16]
    get_user_ip(id, player_ip, charsmax(player_ip), 1)
    if (ArrayFindString(g_muted_array, player_ip) != -1)
    {
        if(!has_vip(id))
        {
            mute_player(id)
        }
    }
}

public client_disconnect(id)
{
    if (g_muted_player[id])
    {
        umnute_player(id)
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
    if (has_vip(id) && g_muted_player[id])
        umnute_player(id)

    return PLUGIN_CONTINUE
}

mute_player(id)
{
    g_muted_player[id] = true
    set_speak(id, SPEAK_MUTED)

    static muted_ip[16]
    get_user_ip(id, muted_ip, charsmax(muted_ip), 1)
    ArrayPushString(g_muted_array, muted_ip)
}

umnute_player(id)
{
    if (g_muted_player[id] && is_user_connected(id))
    {
        set_speak(id, SPEAK_ALL)
    }
    g_muted_player[id] = false

    static muted_index, muted_ip[16]
    get_user_ip(id, muted_ip, charsmax(muted_ip), 1)
    while ((muted_index = ArrayFindString(g_muted_array, muted_ip) != -1))
        ArrayDeleteItem(g_muted_array, muted_index)
}
