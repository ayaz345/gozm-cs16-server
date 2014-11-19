#include <amxmodx>
#include <amxmisc>
#include <colored_print>

#define MPROP_BACKNAME  2
#define MPROP_NEXTNAME  3
#define MPROP_EXITNAME  4

new g_chosen_userid[MAX_PLAYERS]
new g_ban_time
new ban_reason[128]

public plugin_init()
{
    register_plugin("GoZm Ban", "3.0", "Dimka")
    register_clcmd("say", "say_it" )
    register_clcmd("say_team", "say_it" )
    register_clcmd("VIP_REASON", "set_custom_ban_reason")
    register_clcmd("amx_unban_by_name", "custom_unban")
    register_clcmd("BANNED_NICKNAME", "unban_by_nickname")
    
    g_ban_time=register_cvar("amxx_voteban_bantime", "30")
}

public say_it(id)
{
    static say_args[11]
    read_args(say_args, 10)
    remove_quotes(say_args)

    if(say_args[0] == '/' && containi(say_args, "voteban") != -1)
    {
        if(get_user_flags(id) & ADMIN_LEVEL_H) 
        {
            show_player_menu(id)
            return PLUGIN_HANDLED_MAIN
        }
        else 
        {
            colored_print(id,"^x04***^x01 Только ВИПы могут использовать^x04 /voteban")
            return PLUGIN_HANDLED_MAIN
        }
    }
    else if(say_args[0] == '/' && equali(say_args, "/ban")) 
    {
        if(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_BAN) 
        {
            show_player_menu(id)
            return PLUGIN_HANDLED_MAIN
        }
        else
        {
            colored_print(id,"^x04***^x01 Только ВИПы могут использовать^x04 /ban")
            return PLUGIN_HANDLED_MAIN
        }
    }
    return PLUGIN_CONTINUE
}

public show_player_menu(id)
{
    new i_Menu = menu_create("\wКого будем \yбанить\w?", "show_player_menu_handler" )

    static players[32], num
    get_players(players, num)
    for(new i=0; i<num; i++)
    {
        new name[32], userid, str_userid[6]
        get_user_name(players[i], name, 31)
        userid = get_user_userid(players[i])
        num_to_str(userid, str_userid, 5)
        
        menu_additem(i_Menu, name, str_userid, _, menu_makecallback("check_for_victim"))
    }

    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Дальше")
    menu_setprop(i_Menu, 4, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public check_for_victim(id, menu, item)
{
    new s_Name[32], s_Userid[6], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Userid, charsmax(s_Userid), s_Name, charsmax(s_Name), i_Callback)

    new player_id
    player_id = get_user_index(s_Name)
    //log_amx("[GOZM_BAN]: %d for %s", player_id, s_Name)

    if(player_id == id || get_user_flags(player_id) & ADMIN_LEVEL_H)
        return ITEM_DISABLED
    return ITEM_ENABLED
}

public show_player_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Name[32], s_Userid[6], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Userid, charsmax(s_Userid), s_Name, charsmax(s_Name), i_Callback)
    g_chosen_userid[id] = str_to_num(s_Userid)

    menu_destroy(menu)
    choose_ban_reason(id)

    return PLUGIN_HANDLED
}

public choose_ban_reason(id)
{
    new i_Menu = menu_create("\yПричина:", "reason_menu_handler" )

    menu_additem(i_Menu, "WallHack", "20160")
    menu_additem(i_Menu, "SpeedHack & AIM", "40320")
    menu_additem(i_Menu, "Block", "30")
    menu_additem(i_Menu, "Reconnect", "15")
    menu_additem(i_Menu, "Mat", "60")
    menu_additem(i_Menu, "Auto B-Hop", "10080")
    menu_additem(i_Menu, "Custom", "1")
    menu_additem(i_Menu, "OCKOP6JIEHU9I", "1440")
    menu_additem(i_Menu, "O6XOD", "10080")
    
    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Дальше")
    menu_setprop(i_Menu, 4, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public reason_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Reason[6], s_Length[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Length, charsmax(s_Length), s_Reason, charsmax(s_Reason), i_Callback)
    new ban_length = str_to_num(s_Length)
    
    if(ban_length == 1)
        client_cmd(id, "messagemode VIP_REASON")
    else
        actual_ban(id, ban_length, s_Reason)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public set_custom_ban_reason(id, level, cid)
{
    new szReason[128]
    read_argv(1, szReason, 127)
    copy(ban_reason, 127, szReason)
    if(strlen(ban_reason) == 0) {
        colored_print(id,"^x04***^x01 Введи причину бана!")
        return PLUGIN_HANDLED
    }

    actual_ban(id, get_pcvar_num(g_ban_time), ban_reason)
    return PLUGIN_HANDLED
}

public actual_ban(vip_id, time, reason[])
{
    //log_amx("[GOZM_BAN]: amx_ban %d #%d %s", time, g_chosen_userid[vip_id], reason)
    client_cmd(vip_id, "amx_ban %d #%d %s", time, g_chosen_userid[vip_id], reason)
    return PLUGIN_HANDLED
}

public custom_unban(id, level, cid) {
    if (!(get_user_flags(id) & ADMIN_LEVEL_H))
    {
        colored_print(id,"^x04***^x01 Только ВИПы могут использовать^x04 UNBAN")
        return PLUGIN_HANDLED
    }

    client_cmd(id, "messagemode BANNED_NICKNAME")
    return PLUGIN_HANDLED
}

public unban_by_nickname(id, level, cid)
{
    new banned_nickname[32]
    read_argv(1, banned_nickname, 31)
    if(strlen(banned_nickname) == 0) {
        colored_print(id,"^x04***^x01 Введи ник!")
        return PLUGIN_HANDLED
    }

    client_cmd(id, "amx_unban %s", banned_nickname)
    return PLUGIN_HANDLED
}
