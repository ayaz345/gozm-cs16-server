new AUTHOR[] = "YoMama/Lux & lantz69 -Sqlx by Gizmo"
new PLUGIN_NAME[] = "AMXBans"
new VERSION[] = "5.0" // This is used in the plugins name

new amxbans_version[] = "amxx_5.0" // This is for the DB

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <time>
#include <colored_print>

// Amxbans .inl files
#include "amxbans/global_vars.inl"
#include "amxbans/init_functions.inl"
#include "amxbans/check_player.inl"
#include "amxbans/menu.inl"
#include "amxbans/cmdBan.inl"
#include "amxbans/cmdUnban.inl"
#include "amxbans/search.inl"

// 16k * 4 = 64k stack size
#pragma dynamic 16384 		// Give the plugin some extra memory to use

new g_CvarHost, g_CvarUser, g_CvarPassword, g_CvarDB

public plugin_init()
{
    register_concmd("amx_reloadreasons", "reasonReload", ADMIN_CFG)

    register_clcmd("amx_banmenu", "cmdBanMenu", ADMIN_BAN, "- displays ban menu") //Changed this line to make this menu come up instead of the normal amxx ban menu
    register_clcmd("amxbans_custombanreason", "setCustomBanReason", ADMIN_BAN, "- configures custom ban message")
    register_clcmd("amx_banhistorymenu", "cmdBanhistoryMenu", ADMIN_LEVEL_H, "- displays banhistorymenu")

    register_menucmd(register_menuid("Ban Menu"), 1023, "actionBanMenu")
    register_menucmd(register_menuid("Ban Reason Menu"), 1023, "actionBanMenuReason")
    register_menucmd(register_menuid("Banhistory Menu"), 1023, "actionBanhistoryMenu")

    g_coloredMenus = colored_menus()

    register_plugin(PLUGIN_NAME, VERSION, AUTHOR)
    register_cvar("amxbans_version", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

    // store in amxbans.cfg
    g_CvarHost = register_cvar("amxbans_host", "141.101.203.23")
    g_CvarDB = register_cvar("amxbans_db", "b179761")
    g_CvarUser = register_cvar("amxbans_user", "u179761")
    g_CvarPassword = register_cvar("amxbans_password", "petyx")

    amxbans_cmd_sql = register_cvar("amxbans_cmd_sql", "0") // A custom plugin that is not released yet so dont touch this cvar.
    amxbans_debug = register_cvar("amxbans_debug", "1") // Set this to 1 to enable debug
    server_nick = register_cvar("amxbans_servernick", "") // Set this cvar to what the adminname should be if the server make the ban.
                                                                                                              // Ie. amxbans_servernick "My Great server" put this in server.cfg or amxx.cfg
    ban_evenif_disconn = register_cvar("amxbans_ban_evenif_disconnected", "0") // 1 enabled and 0 disabled ban of players not in server
    complainurl = register_cvar("amxbans_complain_url", "www.yoursite.com") // Dont use http:// then the url will not show
    show_prebanned = register_cvar("amxbans_show_prebanned", "1") // Will show if a player has been banned before as amx_chat to admins. 0 to disable
    show_prebanned_num = register_cvar("amxbans_show_prebanned_num", "2") // How many offences should the player have to notify admins?
    max_time_to_show_preban = register_cvar("amxbans_max_time_to_show_preban", "9999") // How many days must go if the ban should not count
    banhistmotd_url = register_cvar("amxbans_banhistmotd_url","http://pathToYour/findex.php?steamid=%s&ip=%s")
    show_atacbans = register_cvar("amxbans_show_prebans_from_atac", "1") // neohasses custom to not count or count atac bans in the chat to admins
    show_name_evenif_mole = register_cvar("amxbans_show_name_evenif_mole", "1")
    firstBanmenuValue = register_cvar("amxbans_first_banmenu_value", "5")
    consoleBanMax = register_cvar("amxbans_consolebanmax", "1440")
    max_time_gone_to_unban = register_cvar("amxbans_max_time_gone_to_unban", "1440") // This is set in minutes
    higher_ban_time_admin = register_cvar("amxbans_higher_ban_time_admin", "n")
    admin_mole_access = register_cvar("amxbans_admin_mole_access", "r")
    show_in_hlsw = register_cvar("amxbans_show_in_hlsw", "1")
    add_mapname_in_servername = register_cvar("amxbans_add_mapname_in_servername", "0")

    register_dictionary("amxbans.txt")
    register_dictionary("common.txt")
    register_dictionary("time.txt")

    register_concmd("amx_ban", "cmdBan", ADMIN_BAN, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
    register_srvcmd("amx_ban", "cmdBan", -1, "<time in min> <steamID or nickname or #authid or IP> <reason>")
    register_concmd("amx_banip", "cmdBan", ADMIN_BAN, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
    register_srvcmd("amx_banip", "cmdBan", -1, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
    register_concmd("amx_unban", "cmdUnBan", ADMIN_BAN, "<steamID or nickname>")
    register_srvcmd("amx_unban", "cmdUnBan", -1, "<steamID or nickname>")
    register_concmd("amx_find", "amx_find", ADMIN_BAN, "<steamID>")
    register_srvcmd("amx_find", "amx_find", -1, "<steamID>")
    register_concmd("amx_findex", "amx_findex", ADMIN_BAN, "<steamID>")
    register_srvcmd("amx_findex", "amx_findex", -1, "<steamID>")
    register_srvcmd("amx_list", "cmdLst", -1, "Displays playerinfo")
    register_srvcmd("amx_sethighbantimes", "setHighBantimes")
    register_srvcmd("amx_setlowbantimes", "setLowBantimes")

    new configsDir[64]
    get_configsdir(configsDir, 63)

    new configfile[128]
    format(configfile, 127, "%s/amxbans.cfg", configsDir)

    if(file_exists(configfile))
    {
        server_cmd("exec %s", configfile)
    }
    else
    {
        loadDefaultBantimes(0)
        server_print("[AMXBANS] Could not find amxbans.cfg, loading default bantimes")
        log_amx("[AMXBANS] Could not find amxbans.cfg, loading default bantimes")
        log_amx("[AMXBANS] You should put amxbans.cfg in addons/amxmodx/configs/")
    }
    //server_exec() // Made other plugins dont work properly b/c settings in amxx.cfg was not read properly

    set_task(0.5, "sql_init")
    set_task(5.0, "addBanhistMenu")
}

public addBanhistMenu()
	AddMenuItem("Banhistory Menu", "amx_banhistorymenu", ADMIN_BAN, "AMXBans")

public sql_init()
{
    new host[32], db[32], user[32], password[32]
    get_pcvar_string(g_CvarHost, host, 31)
    get_pcvar_string(g_CvarDB, db, 31)
    get_pcvar_string(g_CvarUser, user, 31)
    get_pcvar_string(g_CvarPassword, password, 31)

    g_SqlX = SQL_MakeDbTuple(host, user, password, db)

    set_task(1.0, "banmod_online")
    set_task(1.0, "fetchReasons")
}

public reasonReload(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	else
	{	
		fetchReasons(id)
		
		if (id != 0)
		{
			if (g_aNum == 1)
				console_print(id,"[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASON" )
			else
				console_print(id,"[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASONS", g_aNum )
		}
	}

	return PLUGIN_HANDLED
}

public client_connect(id)
{
	if( (id > 0 || id < 32) && is_user_connected(id) )
	{
		g_lastCustom[id][0] = '^0'
		g_inCustomReason[id] = 0
		g_player_flagged[id] = false
		g_being_banned[id] = false
	}
	
}

public client_disconnect(id)
{
	g_lastCustom[id][0] = '^0'
	g_inCustomReason[id] = 0
	g_player_flagged[id] = false
	g_being_banned[id] = false
}

public client_authorized(id)
{
    if (get_pcvar_num(show_prebanned) == 1)
    {
        set_task(1.0, "prebanned_check", id)
    }
    if ((get_user_flags(id) & ADMIN_LEVEL_H) || (get_user_flags(id) & ADMIN_IMMUNITY))
    {
        return PLUGIN_CONTINUE
    }
    set_task(1.1, "check_player", id)
    return PLUGIN_CONTINUE
}

public delayed_kick(id_str[])
{
	new player_id = str_to_num(id_str)
	new userid = get_user_userid(player_id)
	new kick_message[128]
	format(kick_message,127,"%L", LANG_PLAYER,"KICK_MESSAGE")

	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[AMXBANS DEBUG] Delayed Kick ID: <%s>", id_str)

	server_cmd("kick #%d  %s",userid, kick_message)
	
	return PLUGIN_CONTINUE
}

/*********    This is used by live ban on the webpages     ************/
public cmdLst(id,level,cid)
{
	new players[32], inum, authid[32],name[32],ip[50]

	get_players(players,inum)
	console_print(id,"playerinfo")

	for(new a = 0; a < inum; a++)
	{
		get_user_ip(players[a],ip,49,1)
		get_user_authid(players[a],authid,31)
		get_user_name(players[a],name,31)
		console_print(id,"#WM#%s#WMW#%s#WMW#%s#WMW#",name,authid,ip)
	}

	return PLUGIN_HANDLED
}

public get_higher_ban_time_admin_flag()
{
	new flags[24]
	get_pcvar_string(higher_ban_time_admin, flags, 23)
	
	return(read_flags(flags))
}

public get_admin_mole_access_flag()
{
	new flags[24]
	get_pcvar_string(admin_mole_access, flags, 23)
	
	return(read_flags(flags))
}

/* This function will attempt to find a player based on the following options:
	- Partial Player Name
	- Steam ID
	- User ID
	- User IP Address
*/
public locate_player(id, identifier[])
{
    if ( get_pcvar_num(amxbans_debug) == 1 )
        log_amx("[AMXBANS DEBUG] identifier: %s", identifier)
    
    g_ban_type = "S"

    // Check based on steam ID
    new player = find_player("c", identifier)

    // Check based on a partial non-case sensitive name
    if (!player) {
        player = find_player("bl", identifier)
    }

    if (!player) {
        // Check based on IP address
        player = find_player("d", identifier)

        if ( player )
            g_ban_type = "SI"
    }

    // Check based on user ID
    if ( !player && identifier[0]=='#' && identifier[1] ) {
        player = find_player("k",str_to_num(identifier[1]))
    }

    if ( player )
    {
        /* Check for immunity */
        if (get_user_flags(player) & ADMIN_IMMUNITY) {
            new name[32]
            get_user_name(player, name, 31)
            if( id == 0 )
                server_print("[AMXBANS] Client ^"%s^" has immunity", name)
            else
                console_print(id,"[AMXBANS] Client ^"%s^" has immunity", name)
            return -1
        }
    }
    return player
}

public setHighBantimes()
{
	new arg[32]
	new argc = read_argc() - 1
	g_highbantimesnum = argc
	//server_print("args: %d", argc)

	if(argc < 1 || argc > 12)
	{
		log_amx("[AMXBANS] You have more than 12 or less than 1 bantimes set in amx_sethighbantimes")
		log_amx("[AMXBANS] Loading default bantimes")
		loadDefaultBantimes(1)

		return PLUGIN_HANDLED
	}

	new i = 0
	new num[32], flag[32]
	while (i < argc)
	{
		read_argv(i + 1, arg, 31)
		parse(arg, num, 31, flag, 31)
		//server_print("Num: %s, Flag: %s", num, flag)

		if(equali(flag, "m"))
		{ 
			g_HighBanMenuValues[i] = str_to_num(num)
		}
		else if(equali(flag, "h"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 60)
		}
		else if(equali(flag, "d"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 1440)
		}
		else if(equali(flag, "w"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 10080)
		}
		//server_print("HighBantime: %d", str_to_num(num))

		i++
	}
	return PLUGIN_HANDLED
}

public setLowBantimes()
{
	new arg[32]
	new argc = read_argc() - 1
	g_lowbantimesnum = argc
	//server_print("args: %d", argc)
	if(argc < 1 || argc > 12)
	{
		log_amx("[AMXBANS] You have more than 12 or less than 1 bantimes set in amx_setlowbantimes")
		log_amx("[AMXBANS] Loading default bantimes")
		loadDefaultBantimes(2)
		
		return PLUGIN_HANDLED
	}

	new i = 0
	new num[32], flag[32]
	while (i < argc)
	{
		read_argv(i + 1, arg, 31)
		parse(arg, num, 31, flag, 31)
		//server_print("Num: %s, Flag: %s", num, flag)

		if(equali(flag, "m"))
		{ 
			g_LowBanMenuValues[i] = str_to_num(num)
		}
		else if(equali(flag, "h"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 60)
		}
		else if(equali(flag, "d"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 1440)
		}
		else if(equali(flag, "w"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 10080)
		}
		//server_print("LowBantime: %d", str_to_num(num))

		i++
	}
	return PLUGIN_HANDLED
}

loadDefaultBantimes(num)
{
	if(num == 1 || num == 0)
		server_cmd("amx_sethighbantimes 5 60 240 600 6000 0 -1")
	if(num == 2 || num == 0)
		server_cmd("amx_setlowbantimes 5 30 60 480 600 1440 -1")
}

/*********  Error handler  ***************/
MySqlX_ThreadError(szQuery[], error[], errnum, failstate, id)
{
	if (failstate == TQUERY_CONNECT_FAILED)
	{
        log_amx("%L", LANG_SERVER, "TCONNECTION_FAILED")
	}
	else if (failstate == TQUERY_QUERY_FAILED)
	{
		log_amx("%L", LANG_SERVER, "TQUERY_FAILED")
	}
	log_amx("%L", LANG_SERVER, "TQUERY_ERROR", id)
	log_amx("%L", LANG_SERVER, "TQUERY_MSG", error, errnum)
	log_amx("%L", LANG_SERVER, "TQUERY_STATEMENT", szQuery)
}

public plugin_end()
{
	SQL_FreeHandle(g_SqlX)
}
