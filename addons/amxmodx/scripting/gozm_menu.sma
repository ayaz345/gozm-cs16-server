#include <amxmodx>
#include <fakemeta>
#include <cs_teams_api>
#include <colored_print>

#define OFFSET_CSMENUCODE	205
#define MPROP_BACKNAME  2
#define MPROP_NEXTNAME  3
#define MPROP_EXITNAME  4
#define OFFSET_TEAM 114
#define TASKID_NEWROUND	641

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
    register_clcmd("gozm_menu", "mainMenu", _, "GoZm Menu")
    
    register_clcmd("chooseteam", "clcmd_changeteam")
    register_clcmd("jointeam", "clcmd_changeteam")

    register_clcmd("say /history", "player_history")
    register_clcmd("say_team /history", "player_history")
    register_clcmd("say /bans", "show_bans")
    register_clcmd("say_team /bans", "show_bans")

    register_event("HLTV", "event_newround", "a", "1=0", "2=0")
}

public mainMenu(id, page)
{
    set_pdata_int(id, OFFSET_CSMENUCODE, 0)  // prevent from showing CS std menu

    new i_Menu = menu_create("\yGoZm Меню:", "menu_handler" )

    menu_additem(i_Menu, "Выбрать оружие", "1")
    menu_additem(i_Menu, "Выбрать карту", "2")
    menu_additem(i_Menu, "Бан", "3")
    menu_additem(i_Menu, "Заглушка", "4")
    menu_additem(i_Menu, "Лучшие игроки", "5")
    menu_additem(i_Menu, "В наблюдатели", "6")
    menu_additem(i_Menu, "В игру", "7")
    menu_additem(i_Menu, "Застрял!", "8")
    menu_additem(i_Menu, "Список банов", "9")
    menu_additem(i_Menu, "Разбан", "10")
    menu_additem(i_Menu, "Разрешить говорить", "11")
    menu_additem(i_Menu, "История игрока", "12")
    menu_additem(i_Menu, "Шапки", "13")
    menu_additem(i_Menu, "Почистить setinfo", "14")
    
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
            allow_join_spec(id)
        case 7:
            allow_join_game(id)
        case 8:
            client_cmd(id, "say /unstuck")
        case 9:
            show_bans(id)
        case 10:
            client_cmd(id, "amx_unban_by_name")  // voteban.amxx
        case 11:
            client_cmd(id, "say /speak")
        case 12:
            player_history(id)
        case 13:
            client_cmd(id, "say /hats")
        case 14:
            clear_setinfo(id)
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public allow_join_spec(id)
{
    new specs[32], specsnum
    get_players(specs, specsnum, "e", "SPECTATOR")
    if(specsnum > 1 && !(has_vip(id) || has_admin(id)))
    {
        colored_print(id, "^x04***^x01 Место в наблюдателях занято!")
        return PLUGIN_HANDLED
    }
    if(fm_get_user_team(id) == TEAM_SPECTATOR)
    {
        colored_print(id, "^x04***^x01 Ты уже в наблюдателях!")
        return PLUGIN_HANDLED
    }
    if(is_user_alive(id) && !(has_vip(id) || has_admin(id)))
    {
        colored_print(id, "^x04***^x01 Живой - играй!")
        return PLUGIN_HANDLED
    }
    
    user_silentkill(id)
    cs_set_player_team(id, CS_TEAM_SPECTATOR)
    return PLUGIN_HANDLED
}

public allow_join_game(id)
{
    if(fm_get_user_team(id) == TEAM_SPECTATOR)
        cs_set_player_team(id, CS_TEAM_CT)
    else
        colored_print(id, "^x04***^x01 Ты уже в игре!")
    return PLUGIN_HANDLED
}

public clear_setinfo(id)
{
    client_cmd(id, "setinfo ^"_gm^" ^"^"")
    client_cmd(id, "setinfo ^"clan^" ^"^"")
    client_cmd(id, "setinfo ^"lang^" ^"^"")
    client_cmd(id, "setinfo ^"dm^" ^"^"")
    client_cmd(id, "setinfo ^"bottomcolor^" ^"^"")
    colored_print(id, "^x04***^x01 Setinfo почищен! Теперь установи свой пароль.")
}

public player_history(id)
{
    client_cmd(id, "amx_banhistorymenu")
    return PLUGIN_HANDLED
}

public show_bans(id)
{
    show_motd(id, "bans.txt", "BANS")
    return PLUGIN_HANDLED
}

public event_newround()
{
    remove_task(TASKID_NEWROUND)
    set_task(0.1, "task_newround", TASKID_NEWROUND)
}

// that function saves opened menu in a new round
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
