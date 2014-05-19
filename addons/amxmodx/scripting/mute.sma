//#define DefaultGagTime 1400.0	// The std gag time if no other time was entered. ( this is 10 min ), Remember the value MUST contain a .0
#define MaxPlayers 32

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <colored_print>

new g_GagPlayers[MaxPlayers+1]	// Used to check if a player is gagged
//
new g_menuposition[MaxPlayers+1]
new g_menuplayers[MaxPlayers+1][32]
new g_menuplayersnum[MaxPlayers+1]

new mutedIp[64][16]
new muted_num = 1

public plugin_init() 
{ 
	register_plugin("Admin Gag","1.8.3","EKS") 
	register_clcmd("say","block_gagged") 
	register_clcmd("say_team","block_gagged") 
// MINE	
	register_clcmd("say", "clcmd_say")
	register_clcmd("say_team", "clcmd_say")
	register_menucmd(register_menuid("mute menu"), 1023, "action_mutemenu")
	register_menucmd(register_menuid("speak menu"), 1023, "action_speakmenu")
	
//	register_concmd("amx_gag","CMD_GagPlayer",ADMIN_LEVEL_H,"<nick or #userid>") 
//	register_concmd("amx_ungag","CMD_UnGagPlayer",ADMIN_LEVEL_H,"<nick or #userid>") 
} 

// MINE
public clcmd_say(id)
{
	static say_args[10]
	read_args(say_args, 9)
	remove_quotes(say_args)
	
	if(say_args[0] == '/' && containi(say_args, "mute") != -1 && get_user_flags(id) & ADMIN_LEVEL_H)
	{
		display_mutemenu(id, g_menuposition[id] = 0)
		return PLUGIN_HANDLED_MAIN
	}
	else if (say_args[0] == '/' && containi(say_args, "speak") != -1 && get_user_flags(id) & ADMIN_LEVEL_H)
	{
		display_speakmenu(id, g_menuposition[id] = 0)
		return PLUGIN_HANDLED_MAIN
	}
	else if (say_args[0] == '/' && (containi(say_args, "speak") != -1 || containi(say_args, "mute") != -1) && !(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		colored_print(id,"^x04***^x01 Затычка доступна только ВИПам!")
	}
	return PLUGIN_CONTINUE
}

display_mutemenu(id, pos) 
{
	if(pos < 0)  
		return

	get_players(g_menuplayers[id], g_menuplayersnum[id])

  	new start = pos * 8
  	if(start >= g_menuplayersnum[id])
    		start = pos = g_menuposition[id]

  	new end = start + 8
	if(end > g_menuplayersnum[id])
    		end = g_menuplayersnum[id]
	
	static menubody[512]	
  	new len = format(menubody, 511, "\wMute menu:^n^n")

	static name[32]
	
	new b = 0, i
	new keys = MENU_KEY_0
	
  	for(new a = start; a < end; ++a)
	{
		i = g_menuplayers[id][a]
		get_user_name(i, name, 31)

		if( i == id || get_user_flags(i) & ADMIN_LEVEL_H  && !(get_user_flags(i) & ADMIN_RCON) || g_GagPlayers[i])
		{
			++b
			len += format(menubody[len], 511 - len, "\d#  %s\w^n", name)
		}
		else
		{
			keys |= (1<<b)
			len += format(menubody[len], 511 - len, "%d. %s\w^n", ++b, name)
		}
	}

  	if(end != g_menuplayersnum[id]) 
	{
    		format(menubody[len], 511 - len, "^n9. %s...^n0. %s", "Next", pos ? "Back" : "Exit")
    		keys |= MENU_KEY_9
  	}
  	else
		format(menubody[len], 511-len, "^n0. %s", pos ? "Back" : "Exit")
	
  	show_menu(id, keys, menubody, -1, "mute menu")
}


public action_mutemenu(id, key)
{
	switch(key) 
	{
		case 8: display_mutemenu(id, ++g_menuposition[id])
		case 9: display_mutemenu(id, --g_menuposition[id])
		default: 
		{
            new player = g_menuplayers[id][g_menuposition[id] * 8 + key]
            CMD_GagPlayer(id, player)
            display_mutemenu(id, g_menuposition[id])
    	}
  	}
	return PLUGIN_HANDLED
}

display_speakmenu(id, pos) 
{
	if(pos < 0)  
		return

	get_players(g_menuplayers[id], g_menuplayersnum[id])

  	new start = pos * 8
  	if(start >= g_menuplayersnum[id])
    		start = pos = g_menuposition[id]

  	new end = start + 8
	if(end > g_menuplayersnum[id])
    		end = g_menuplayersnum[id]
	
	static menubody[512]	
  	new len = format(menubody, 511, "\wSpeak menu:^n^n")

	static name[32]
	
	new b = 0, i
	new keys = MENU_KEY_0
	
  	for(new a = start; a < end; ++a)
	{
		i = g_menuplayers[id][a]
		get_user_name(i, name, 31)

		if( i == id || get_user_flags(i) & ADMIN_LEVEL_H  && !(get_user_flags(i) & ADMIN_RCON) || !g_GagPlayers[i])
		{
			++b
			len += format(menubody[len], 511 - len, "\d#  %s\w^n", name)
		}
		else
		{
			keys |= (1<<b)
			len += format(menubody[len], 511 - len, "%d. %s\w^n", ++b, name)
		}
	}

  	if(end != g_menuplayersnum[id]) 
	{
    		format(menubody[len], 511 - len, "^n9. %s...^n0. %s", "Next", pos ? "Back" : "Exit")
    		keys |= MENU_KEY_9
  	}
  	else
		format(menubody[len], 511-len, "^n0. %s", pos ? "Back" : "Exit")
	
  	show_menu(id, keys, menubody, -1, "speak menu")
}


public action_speakmenu(id, key)
{
	switch(key) 
	{
		case 8: display_speakmenu(id, ++g_menuposition[id])
		case 9: display_speakmenu(id, --g_menuposition[id])
		default: 
		{
			new player = g_menuplayers[id][g_menuposition[id] * 8 + key]
			CMD_UnGagPlayer(id, player)
    	}
  	}
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
			colored_print(id,"^x04***^x01 Тебя заткнули!") 
			return PLUGIN_HANDLED 
			} 
		} 
	else if (g_GagPlayers[id] & 1)   { 
			colored_print(id,"^x04***^x01 Тебя заткнули!") 
			return PLUGIN_HANDLED 
		} 
	return PLUGIN_CONTINUE 
} 

public CMD_GagPlayer(VIP, VictimID) 
{
    if ((get_user_flags(VictimID) & ADMIN_LEVEL_H) && VictimID != VIP)  
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
    colored_print(0,"^x04***^x03 %s^x01 умолк благодаря %s",VictimName, AdminName) 

    return PLUGIN_HANDLED
} 

public CMD_UnGagPlayer(VIP, VictimID)   /// Removed gagged player ( done via console command )
{
    if ((get_user_flags(VictimID) & ADMIN_LEVEL_H) && VictimID != VIP)  
        return PLUGIN_HANDLED;
        
    new AdminName[32],VictimName[32] 

    get_user_name(VIP,AdminName,31)		// Gets Admin name
    get_user_name(VictimID,VictimName,31)

    if(!g_GagPlayers[VictimID])		// Checks if player has gagged flag
    {
        console_print(VIP,"%s Is Not Gagged & Cannot Be Ungagged.",VictimName)
        return PLUGIN_HANDLED
    }

    colored_print(0,"^x04***^x03 %s^x01 может говорить благодаря %s", VictimName, AdminName)
/*
    new muted_flag
    muted_flag = get_speak(VictimID)
	log_amx("MUTE: %s had %d flag", VictimName, muted_flag)
*/
    UnGagPlayer(VictimID)		// This is the function that does the actual removal of the gag info
    return PLUGIN_HANDLED
}

public client_putinserver(id) 
{ 
	new checkIp[16], i
	get_user_ip(id, checkIp, 15, 1)
	
	for (i=1; i<30; i++)
		if(contain(mutedIp[i], checkIp) != -1)
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

stock UnGagPlayer(id) // This code is what removes the gag.
{ 
	if((g_GagPlayers[id] & 4) && is_user_connected(id))	// Unmutes the player if he had voicecomm muted.
	{
		set_speak(id, SPEAK_ALL)
	}
	g_GagPlayers[id] = 0
}