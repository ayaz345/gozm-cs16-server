#define DefaultGagTime 900.0	// The std gag time if no other time was entered. ( this is 10 min ), Remember the value MUST contain a .0
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

public plugin_init() 
{ 
	register_plugin("Admin Gag","1.8.3","EKS") 
	register_clcmd("say","block_gagged") 
	register_clcmd("say_team","block_gagged") 
// MINE	
	register_clcmd("say", "clcmd_say")
	register_clcmd("say_team", "clcmd_say")
	register_menucmd(register_menuid("mute menu"), 1023, "action_mutemenu")
	
	register_concmd("amx_gag","CMD_GagPlayer",ADMIN_LEVEL_H,"<nick or #userid>") 
	register_concmd("amx_ungag","CMD_UnGagPlayer",ADMIN_LEVEL_H,"<nick or #userid>") 
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
	else if (say_args[0] == '/' && containi(say_args, "mute") != -1 && !(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		colored_print(id,"^x01 MUTE is only for ^x03 VIPs!")
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
  	new len = format(menubody, 511, "\wМеню заглушки^n^n")

	static name[32]
	
	new b = 0, i
	new keys = MENU_KEY_0
	
  	for(new a = start; a < end; ++a)
	{
		i = g_menuplayers[id][a]
		get_user_name(i, name, 31)
		
		if( i == id || get_user_flags(i) & ADMIN_LEVEL_H)
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
    		format(menubody[len], 511 - len, "^n9. %s...^n0. %s", "Еще", pos ? "Назад" : "Выход")
    		keys |= MENU_KEY_9
  	}
  	else
		format(menubody[len], 511-len, "^n0. %s", pos ? "Назад" : "Выход")
	
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
			
			static name[32]
			get_user_name(player, name, 31)
			console_cmd ( id, "amx_gag %s", name)
    	}
  	}
	return PLUGIN_HANDLED
}

////////////////// PART 2 ////////////////////

public block_gagged(id)
{  // This function is what check the say / team_say messages & block them if the client is blocked.
	if(!g_GagPlayers[id]) return PLUGIN_CONTINUE // Is true if the client is NOT blocked.
	new cmd[5] 
	read_argv(0,cmd,4) 
	if ( cmd[3] == '_' )
		{ 
		if (g_GagPlayers[id] & 2){ 
			colored_print(id,"^x04//////^x01 You have been muted!^x04 //////") 

			return PLUGIN_HANDLED 
			} 
		} 
	else if (g_GagPlayers[id] & 1)   { 
			colored_print(id,"^x04//////^x01 You have been muted!^x04 //////") 
			
			return PLUGIN_HANDLED 
		} 
	return PLUGIN_CONTINUE 
} 

public CMD_GagPlayer(id,level,cid) 
{ 
	if(!cmd_access (id,level,cid,1)) return PLUGIN_HANDLED
	new arg[32],VictimID
	
	read_argv(1,arg,31)  			// Arg contains Targets nick or Userid
	VictimID = cmd_target(id,arg,8)		// This code here tryes to find out the player index. Either from a nick or #userid
	
	if ((get_user_flags(VictimID) & ADMIN_LEVEL_H) && VictimID != id)  
		return PLUGIN_HANDLED;  
	
	new s_Flags[4],VictimName[32],AdminName[32],flags,Float:f_GagTime

	f_GagTime = DefaultGagTime
	format(s_Flags,7,"abc")

	flags = read_flags(s_Flags) // Converts the string flags ( a,b or c ) into a int
	g_GagPlayers[VictimID] = flags

	set_speak(VictimID, SPEAK_MUTED)

	new TaskParm[1]		// For some reason set_task requires a array. So i make a array :)
	TaskParm[0] = VictimID
	set_task( f_GagTime,"task_UnGagPlayer",VictimID,TaskParm,1) 

	get_user_name(id,AdminName,31)
	get_user_name(VictimID,VictimName,31)
	
	colored_print(0,"^x04//////^x03 VIP %s^x01 has muted^x03 %s^x01 for^x04 %d^x01 minutes^x04 //////",AdminName,VictimName,floatround(f_GagTime / 60)) 
	
	return PLUGIN_HANDLED
} 

public CMD_UnGagPlayer(id,level,cid)   /// Removed gagged player ( done via console command )
{
	new arg[32],VictimID
	read_argv(1,arg,31)  			// Arg contains Targets nick
	
	VictimID = cmd_target(id,arg,8)		// This code here tryes to find out the player index. Either from a nick or #userid
	if ((get_user_flags(VictimID) & ADMIN_IMMUNITY) && VictimID != id || !cmd_access (id,level,cid,2) ) 
	{ return PLUGIN_HANDLED; } // This code is kind of "long", its job is to. Stop actions against admins with immunity, Stop actions action if the user lacks access, or is a bot/hltv

	new AdminName[32],VictimName[32] 

	get_user_name(id,AdminName,31)		// Gets Admin name
	get_user_name(VictimID,VictimName,31)

	if(!g_GagPlayers[VictimID])		// Checks if player has gagged flag
	{
		console_print(id,"%s Is Not Gagged & Cannot Be Ungagged.",arg)
		return PLUGIN_HANDLED
	}
	
	colored_print(0,"^x04//////^x03 VIP %s^x01 let^x03 %s^x01 speak^x04 //////",AdminName,VictimName)
  	
	remove_task(VictimID)		// Removes the set_task set to ungag the player
	UnGagPlayer(VictimID)		// This is the function that does the actual removal of the gag info
	return PLUGIN_HANDLED
} 

public client_disconnect(id) 
{ 
	if(g_GagPlayers[id]) // Checks if disconnected player is gagged, and removes flags from his id.
	{
		new Nick[32]
		get_user_name(id,Nick,31)
		colored_print(0,"^x04//////^x01 Muted player^x03 %s^x01 disconnected^x04 //////",Nick)
		remove_task(id)		// Removes the set_task set to ungag the player
		UnGagPlayer(id)		// This is the function that does the actual removal of the gag info
	}
}

public client_infochanged(id)
{
	new newname[32]
	get_user_info(id, "name", newname,31)
	new oldname[32]
	get_user_name(id,oldname,31)
	
	if (equal(newname,"Game Destroyed"))
	{
		colored_print(id,"^x04***^x03 %s^x01 bye-bye, bitch =*", oldname)
		set_user_info(id,"name",oldname)
		
		return PLUGIN_HANDLED
	}

	if(g_GagPlayers[id])
	{
		if (!equal(oldname,newname))
		{
			colored_print(id,"^x04//////^x01 Muted players can't change nicknames!^x04 //////")
			set_user_info(id,"name",oldname)
		}
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public task_UnGagPlayer(TaskParm[])	// This function is called when the task expires
{
	new VictimName[32]
	get_user_name(TaskParm[0],VictimName,31)
	colored_print(0,"^x04//////^x03 %s^x01 can speak^x04 //////",VictimName)
	UnGagPlayer(TaskParm[0])
}

stock UnGagPlayer(id) // This code is what removes the gag.
{ 
	if(g_GagPlayers[id] & 4)	// Unmutes the player if he had voicecomm muted.
	{
		set_speak(id, SPEAK_ALL)
	}
	g_GagPlayers[id] = 0
}