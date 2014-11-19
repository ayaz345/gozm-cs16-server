#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <colored_print>

new g_GagPlayers[MAX_PLAYERS+1]	// Used to check if a player is gagged

new mutedIp[64][16]
new muted_num = 1

public plugin_init() 
{ 
	register_plugin("Admin Gag", "1.8.3", "EKS") 
	register_clcmd("say", "block_gagged") 
	register_clcmd("say_team", "block_gagged")
	register_clcmd("say", "clcmd_say")
	register_clcmd("say_team", "clcmd_say")
} 

// MINE
public clcmd_say(id)
{
    static say_args[10]
    read_args(say_args, 9)
    remove_quotes(say_args)

    if ( 
        say_args[0] == '/' && 
        containi(say_args, "mute") != -1 && 
        is_priveleged_user(id) )
    {
        display_mutemenu(id)
        return PLUGIN_HANDLED_MAIN
    }
    else if ( 
        say_args[0] == '/' && 
        containi(say_args, "speak") != -1 && 
        is_priveleged_user(id) )
    {
        display_speakmenu(id)
        return PLUGIN_HANDLED_MAIN
    }
    else if ( 
        say_args[0] == '/' && 
        containi(say_args, "unmute") != -1 && 
        is_priveleged_user(id) )
    {
        display_speakmenu(id)
        return PLUGIN_HANDLED_MAIN
    }
    else if (
        say_args[0] == '/' && 
        (
            containi(say_args, "speak") != -1 || 
            containi(say_args, "mute") != -1 ||
            containi(say_args, "unmute") != -1
        ) && 
        !is_priveleged_user(id) )
    {
        colored_print(id, "^x04***^x01 Затычка доступна только ВИПам!")
        return PLUGIN_HANDLED_MAIN
    }
    return PLUGIN_CONTINUE
}

public has_vip(id)
    return get_user_flags(id) & ADMIN_LEVEL_H
    
public has_rcon(id)
    return get_user_flags(id) & ADMIN_RCON

public is_priveleged_user(id)
    return has_vip(id) || has_rcon(id)

public display_mutemenu(id)
{
    new i_Menu = menu_create("\wКого \yзаткнем\w?", "mute_player_menu_handler" )

    static players[32], num
    get_players(players, num)
    for(new i=0; i<num; i++)
    {
        new name[32], str_id[3]
        get_user_name(players[i], name, 31)
        num_to_str(players[i], str_id, 2)
        
        menu_additem(i_Menu, name, str_id, _, menu_makecallback("check_for_muted_victim"))
    }

    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Дальше")
    menu_setprop(i_Menu, 4, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public check_for_muted_victim(id, menu, item)
{
    new s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if(victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || g_GagPlayers[victim_id])
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

    new s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)
    victim_id = str_to_num(s_Id)
    CMD_GagPlayer(id, victim_id)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public display_speakmenu(id)
{
    new i_Menu = menu_create("\wРазрешим \yговорить\w:", "speak_player_menu_handler" )

    static players[32], num
    get_players(players, num)
    for(new i=0; i<num; i++)
    {
        new name[32], str_id[3]
        get_user_name(players[i], name, 31)
        num_to_str(players[i], str_id, 2)
        
        menu_additem(i_Menu, name, str_id, _, menu_makecallback("check_for_speaking_victim"))
    }

    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Дальше")
    menu_setprop(i_Menu, 4, "Закрыть")

    menu_display(id, i_Menu, 0)

    return PLUGIN_HANDLED
}

public check_for_speaking_victim(id, menu, item)
{
    new s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)

    victim_id = str_to_num(s_Id)
    if(victim_id == id || has_vip(victim_id) && !has_rcon(victim_id) || !g_GagPlayers[victim_id])
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

    new s_Name[32], s_Id[3], i_Access, i_Callback, victim_id
    menu_item_getinfo(menu, item, i_Access, s_Id, charsmax(s_Id), s_Name, charsmax(s_Name), i_Callback)
    victim_id = str_to_num(s_Id)
    CMD_UnGagPlayer(id, victim_id)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public block_gagged(id)
{  // This function is what check the say / team_say messages & block them if the client is blocked.
	if(!g_GagPlayers[id]) return PLUGIN_CONTINUE // Is true if the client is NOT blocked.
	new cmd[5] 
	read_argv(0,cmd,4) 
	if ( cmd[3] == '_' )
		{ 
		if (g_GagPlayers[id] & 2){ 
			colored_print(id, "^x04***^x01 Тебя заткнули!") 
			return PLUGIN_HANDLED 
			} 
		} 
	else if (g_GagPlayers[id] & 1)   { 
			colored_print(id, "^x04***^x01 Тебя заткнули!") 
			return PLUGIN_HANDLED 
		} 
	return PLUGIN_CONTINUE 
} 

public CMD_GagPlayer(VIP, VictimID) 
{
    if (has_vip(VictimID) && VictimID != VIP)  
        return PLUGIN_HANDLED;
        
    if (!is_user_connected(VictimID))  
        return PLUGIN_HANDLED;
        
    new s_Flags[4],AdminName[32],VictimName[32],flags
    format(s_Flags,7,"abc")

    flags = read_flags(s_Flags) // Converts the string flags ( a,b or c ) into a int
    g_GagPlayers[VictimID] = flags

    set_speak(VictimID, SPEAK_MUTED)

    get_user_name(VIP,AdminName,31)
    get_user_name(VictimID,VictimName,31)
    if (!has_rcon(VIP))
        colored_print(0, "^x04***^x03 %s^x01 умолк благодаря випу %s", VictimName, AdminName)
    else
        console_print(VIP, "*** %s is silented", VictimName)

    return PLUGIN_HANDLED
} 

public CMD_UnGagPlayer(VIP, VictimID)   /// Removed gagged player ( done via console command )
{
    if (has_vip(VictimID) && VictimID != VIP)  
        return PLUGIN_HANDLED;
        
    new AdminName[32],VictimName[32] 

    get_user_name(VIP,AdminName,31)		// Gets Admin name
    get_user_name(VictimID,VictimName,31)

    if(!g_GagPlayers[VictimID])		// Checks if player has gagged flag
    {
        console_print(VIP, "%s Is Not Gagged & Cannot Be Ungagged.",VictimName)
        return PLUGIN_HANDLED
    }

    if (!has_rcon(VIP))
        colored_print(0, "^x04***^x03 %s^x01 может говорить благодаря випу %s", VictimName, AdminName)
    else
        console_print(VIP, "*** %s is free", VictimName)
    
    UnGagPlayer(VictimID)		// This is the function that does the actual removal of the gag info
    return PLUGIN_HANDLED
}

public client_putinserver(id) 
{ 
	new checkIp[16], i
	get_user_ip(id, checkIp, 15, 1)
	
	for (i=1; i<30; i++)
		if(contain(mutedIp[i], checkIp) != -1 && !has_vip(id))
		{
			new s_Flags[4],flags
			format(s_Flags,7,"abc")
			flags = read_flags(s_Flags) // Converts the string flags ( a,b or c ) into a int
			g_GagPlayers[id] = flags
			
			set_speak(id, SPEAK_MUTED)
		}
}

public client_disconnect(id) 
{ 
	if(g_GagPlayers[id]) // Checks if disconnected player is gagged, and removes flags from his id.
	{
		UnGagPlayer(id)		// This is the function that does the actual removal of the gag info
		new gaggedIp[16]
		get_user_ip(id, gaggedIp, 15, 1)
		mutedIp[muted_num] = gaggedIp
		muted_num++
	}
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE
    
    new newname[32]
    get_user_info(id, "name", newname, 31)
    new oldname[32]
    get_user_name(id, oldname, 31)
    
    if (!equal(oldname,newname) && !equal(oldname,""))
        set_task(0.2, "check_access", id)
    
    return PLUGIN_CONTINUE
}

public check_access(id)
{
    if (has_vip(id) && g_GagPlayers[id])
        UnGagPlayer(id)
    return PLUGIN_CONTINUE
}

stock UnGagPlayer(id) // This code is what removes the gag.
{ 
	if((g_GagPlayers[id] & 4) && is_user_connected(id))	// Unmutes the player if he had voicecomm muted.
	{
		set_speak(id, SPEAK_ALL)
	}
	g_GagPlayers[id] = 0
}
