#include <amxmodx>
#include <cs_teams_api>
#include <fakemeta>
#include <colored_print>

#define VIP_FLAG ADMIN_LEVEL_H
#define ADMIN_FLAG ADMIN_BAN
#define OFFSET_CSMENUCODE	205
#define MPROP_BACKNAME  2
#define MPROP_NEXTNAME  3
#define MPROP_EXITNAME  4
#define OFFSET_TEAM 114
#define TASKID_NEWROUND	641

new GOZM_CMD[] = "gozm_menu"

enum
{
	TEAM_UNASSIGNED = 0,
	TEAM_TERRORIST,
	TEAM_CT,
    TEAM_SPECTATOR
}

public plugin_init()
{
    register_plugin("GoZm Menu", "1.0", "Dimka")
    register_clcmd(GOZM_CMD, "mainMenu", _, "GoZm Menu")
    
    register_clcmd("chooseteam", "clcmd_changeteam")
    register_clcmd("jointeam", "clcmd_changeteam")
    
    register_event("HLTV", "event_newround", "a", "1=0", "2=0")
}

public mainMenu(id, page)
{
    set_pdata_int(id, OFFSET_CSMENUCODE, 0)  // prevent from showing CS std menu

    new i_Menu = menu_create("\yGoZm Меню:", "menu_handler" )

    menu_additem(i_Menu, "Выбрать оружие", "1")
    menu_additem(i_Menu, "Выбрать карту", "2")
    menu_additem(i_Menu, "Бан", "3", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "Заглушка", "4", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "Лучшие игроки", "5")
    menu_additem(i_Menu, "В наблюдатели", "6", 0, menu_makecallback("cb_allow_join_spec"))
    menu_additem(i_Menu, "В игру", "7", 0, menu_makecallback("cb_allow_join_game"))
    menu_additem(i_Menu, "Общение", "8")
    menu_additem(i_Menu, "Список банов", "9")
    menu_additem(i_Menu, "Разбан", "10", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "Разрешить говорить", "11", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "История банов", "12")
    menu_additem(i_Menu, "Шапки", "13", VIP_FLAG|ADMIN_FLAG)
    
    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Вперед")
    menu_setprop(i_Menu, 4, "Закрыть меню")

    menu_display(id, i_Menu, page)

    return PLUGIN_HANDLED
}

public menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
    new i_Key = str_to_num(s_Data)

    switch(i_Key)
    {
        case 1:
            client_cmd(id, "say /guns")
        case 2: 
            client_cmd(id, "say nominate")
        case 3: 
            client_cmd(id, "say /ban")
        case 4: 
            client_cmd(id, "say /mute")
        case 5:
            client_cmd(id, "say /top")
        case 6:
        {
            user_silentkill(id)
            cs_set_player_team(id, CS_TEAM_SPECTATOR)
        }
        case 7:
        {
            cs_set_player_team(id, CS_TEAM_CT)
        }
        case 8:
        {
            colored_print(id, "3om6u cepBep (x_x(O_o)x_x) Go Zombie !!!")
            colored_print(id, "^x01  =======^x04 77.220.185.29:27051^x01 =======   ")
            colored_print(id, "^x01               ^x03 vk.com/go_zombie ^x01           ")
        }
        case 9:
            client_cmd(id, "say /bans")
        case 10:
            client_cmd(id, "amx_unban_by_name")
        case 11: 
            client_cmd(id, "say /speak")
        case 12: 
            client_cmd(id, "amx_banhistorymenu")
        case 13: 
            client_cmd(id, "say /hats")
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public cb_allow_join_spec(id, menu, item)
{
    new specs[32], specsnum
    get_players(specs, specsnum, "e", "SPECTATOR")
    if(specsnum > 1)
        return ITEM_DISABLED
    if(fm_get_user_team(id) == TEAM_SPECTATOR)
        return ITEM_DISABLED
        
    if(!is_user_alive(id))
        return ITEM_ENABLED
    else if(get_user_flags(id) & VIP_FLAG || get_user_flags(id) & ADMIN_FLAG)
        return ITEM_ENABLED
    return ITEM_DISABLED
}

public cb_allow_join_game(id, menu, item)
{
    if(fm_get_user_team(id) == TEAM_SPECTATOR)
        return ITEM_ENABLED
    return ITEM_DISABLED
}

public event_newround()
{
    remove_task(TASKID_NEWROUND)
    set_task(0.1, "task_newround", TASKID_NEWROUND)
}

public task_newround()
{
    static players[32], num, id
    get_players(players, num)

    for(new i=0; i<num; i++)
    {
        new old_menu, new_menu, menupage
        id = players[i]
        player_menu_info(id, old_menu, new_menu, menupage)
        if (new_menu != -1)
        {
            menu_destroy(new_menu)
            mainMenu(id, menupage)
        }
    }
}

public clcmd_changeteam(id)
{
    mainMenu(id, 0)
    return PLUGIN_HANDLED
}

stock fm_get_user_team(id)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return TEAM_SPECTATOR
	
	return get_pdata_int(id, OFFSET_TEAM, 5)
}