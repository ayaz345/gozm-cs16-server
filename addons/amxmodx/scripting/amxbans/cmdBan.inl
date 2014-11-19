public cmdBan(id, level, cid)
{
    /* Checking if the admin has the right access */
    if (!cmd_access(id,level,cid,3))
        return PLUGIN_HANDLED

    new bool:serverCmd = false
    /* Determine if this was a server command or a command issued by a player in the game */
    if ( id == 0 )
        serverCmd = true

    new text[128], steamidorusername[50], ban_length[50]
    read_args(text, 127)
    parse(text, ban_length, 49, steamidorusername, 49)

    /* Check so the ban command has the right format */
    if(!is_str_num(ban_length) || read_argc() < 4)
    {
        client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"AMX_BAN_SYNTAX")

        return PLUGIN_HANDLED
    }

    new length1 = strlen(ban_length)
    new length2 = strlen(steamidorusername)
    new length = length1 + length2
    length += 2

    new reason[128]
    read_args(reason,127)
    format(g_ban_reason, 255, "%s", reason[length])

    replace_all(g_ban_reason, 255, "\", "\\")
    replace_all(g_ban_reason, 255, "'", "\'")

    new iBanLength = str_to_num(ban_length)
    new cTimeLength[128]

    if (iBanLength > 0)
        get_time_length(id, iBanLength, timeunit_minutes, cTimeLength, 127)
    else
        format(cTimeLength, 127, "%L", LANG_PLAYER, "TIME_ELEMENT_PERMANENTLY")

    // This stops admins from banning perm in console if not adminflag n
    if(!has_rcon(id) && iBanLength == 0)
    {
        client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"NOT_BAN_PERMANENT")
        
        return PLUGIN_HANDLED
    }

    // This stops admins from banning more than 600 min in console if not adminflag n
    if(!has_rcon(id) && iBanLength > get_pcvar_num(consoleBanMax))
    {
        client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"BAN_MAX", get_pcvar_num(consoleBanMax))
        
        return PLUGIN_HANDLED
    }

    /* Try to find the player that should be banned */
    new player = locate_player(id, steamidorusername)

    if(g_being_banned[player]) //triggered error http://amxbans.net/forums/viewtopic.php?p=3468#3468
    {
        if ( get_pcvar_num(amxbans_debug) == 1 )
            log_amx("[AMXBANS DEBUG Blocking doubleban(g_being_banned)] Playerid: %d BanLenght: %s Reason: %s", player, ban_length, g_ban_reason)
            
        return PLUGIN_HANDLED
    }

    g_being_banned[player] = true

    if ( get_pcvar_num(amxbans_debug) == 1 )
        log_amx("[cmdBan function 1]Playerid: %d", player)


    new player_steamid[50], player_ip[30]
    if (player)
    {
        get_user_authid(player, player_steamid, 49)
        get_user_ip(player, player_ip, 29, 1)
        get_user_ip(player, ga_PlayerIP[player], 15, 1)
    }
    else
    {
        // Must make that false to be able to ban another player not on the server
        // Players that aren't in the server always get id = 0
        g_being_banned[0] = false
        
        if (serverCmd)
            server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
        else
            colored_print(id, "^x04***^x01 Player^x03 %s^x01 is not found on server.", g_steamidorusername)

        if ( get_pcvar_num(amxbans_debug) == 1 )
            log_amx("[AMXXBANS DEBUG] Player %s could not be found",g_steamidorusername)

        return PLUGIN_HANDLED
    }

    /*
      If it is on a lan the player_steamid must not be inserted to the DB then everybody on the LAN would be considered banned.
        Only IP and nick is enough for LAN bans. HLTV will also only be banned by IP
         
        Don't wanna ban a player with STEAM_ID_PENDING to the DB as that can make many others to be considdered banned.
        Make an IP ban instead and don't add player_steamid to the DB
    */
    if ( equal("4294967295", player_steamid)
        || equal("HLTV", player_steamid)
        || equal("STEAM_ID_LAN",player_steamid)
        || equal("VALVE_ID_LAN",player_steamid)
        || equal("VALVE_ID_PENDING",player_steamid)
        || equal("STEAM_ID_PENDING",player_steamid))
    {
        g_ban_type = "SI"
        player_steamid = ""
    }

    /////////// SCREENSHOT AS A PROOF ///////////
    new banned_name[32]
    new admin_name[32]
    get_user_name(player, banned_name, 31)
    get_user_name(id, admin_name, 31)
    colored_print(player, "^x04***^x01 %s is banned by %s [%dm.]", banned_name, admin_name, iBanLength)
    client_cmd(player, "snapshot")
    /////////////////////////////////////////////

    cmd_ban_(id, player, iBanLength)
    
    if (has_rcon(player))
        return PLUGIN_HANDLED

    new param[2]
    param[0] = player
    param[1] = 15
    set_task(kick_delay + 5.0, "double_ban", player, param, 2)
    
    SuperBan(player, iBanLength, id)

    return PLUGIN_HANDLED
}

public double_ban(param[]) {
    new id = param[0]
    new iBanLength = param[1]

    if (has_rcon(id))
        return PLUGIN_CONTINUE

    server_cmd("addip %d %s", iBanLength, ga_PlayerIP[id])
    if ( get_pcvar_num(amxbans_debug) == 1 )
        log_amx("[! AMXBANS DEBUG] addip %d %s", iBanLength, ga_PlayerIP[id])

    return PLUGIN_CONTINUE
}

public SuperBan(victim_id, iBanLength, admin_or_vip_id) 
{
    if (has_rcon(victim_id))
        return PLUGIN_CONTINUE

    new victim_userid = get_user_userid(victim_id)
    if(is_user_connected(victim_id) && (is_user_connected(admin_or_vip_id) || admin_or_vip_id == 0)) {
        client_cmd(admin_or_vip_id, "amx_superban #%d %d ^"%s^"", victim_userid, iBanLength, g_ban_reason)
    }
    return PLUGIN_CONTINUE
}

public cmd_ban_(id, player, iBanLength)
{
    if ( get_pcvar_num(amxbans_debug) == 1 )
        log_amx("[cmdBan function 2]Playerid: %d", player)

    new bool:serverCmd = false
    // Determine if this was a server command or a command issued by a player in the game
    if ( id == 0 )
        serverCmd = true;

    new player_steamid[50], player_ip[30], player_nick[50]

    get_user_authid(player, player_steamid, 49)
    get_user_name(player, player_nick, 49)
    get_user_ip(player, player_ip, 29, 1)

    replace_all(player_nick, 49, "\", "\\")
    replace_all(player_nick, 49, "'", "\'")

    new admin_nick[100], admin_steamid[50], admin_ip[20]
    get_user_name(id, admin_nick, 99)
    get_user_ip(id, admin_ip, 19, 1)

    replace_all(admin_nick, 99, "\", "\\")
    replace_all(admin_nick, 99, "'", "\'")

    if (!serverCmd)
    {
        get_user_authid(id, admin_steamid, 49)

        if ( get_pcvar_num(amxbans_debug) == 1 )
            log_amx("[AMXBANS DEBUG cmdBan] Adminsteamid: %s, Servercmd: %s", admin_steamid, serverCmd)
    }
    else
    {
        // If the server does the ban you cant get any steam_ID or team
        admin_steamid = ""

        // This is so you can have a shorter name for the servers hostname.
        // Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad
        new servernick[100]
        get_pcvar_string(server_nick, servernick, 99)
        if (strlen(servernick))
            admin_nick = servernick
    }

    // If HLGUARD ban, the admin nick will be set to [HLGUARD]
    if ( contain(g_ban_reason, "[HLGUARD]") != -1 )
        admin_nick = "[HLGUARD]"

    // If ATAC ban, the admin nick will be set to [ATAC]
    if ( contain(g_ban_reason, "Max Team Kill Violation") != -1 )
        admin_nick = "[ATAC]"
        
    if ( get_pcvar_num(amxbans_debug) == 1 )
        log_amx("[AMXBANS DEBUG cmdBan] Admin nick: %s, Admin userid: %d", admin_nick, get_user_userid(id))

    new server_name[100]
    get_cvar_string("hostname", server_name, 99)

    new ban_created = get_systime(0)

    if ( get_pcvar_num(add_mapname_in_servername) == 1 )
    {
        new mapname[32], pre[4],post[4]
        get_mapname(mapname,31)
        pre = " ("
        post = ")"
        add(server_name,255,pre,0)
        add(server_name,255,mapname,0)
        add(server_name,255,post,0)
    }

    replace_all(server_name, 99, "\", "\\")
    replace_all(server_name, 99, "'", "\'")

    new BanLength[50]
    num_to_str(iBanLength, BanLength, 49)

    //    If it is on a lan the player_steamid must not be inserted to the DB then everybody on the LAN would be considered banned.
    //    Only IP and nick is enough for LAN bans. HLTV will also only be banned by IP
         
    //    Don't wanna ban a player with STEAM_ID_PENDING to the DB as that can make many others to be considdered banned.
    //    Make an IP ban instead and don't add player_steamid to the DB

    if ( equal("4294967295", player_steamid)
        || equal("HLTV", player_steamid)
        || equal("STEAM_ID_LAN",player_steamid)
        || equal("VALVE_ID_LAN",player_steamid)
        || equal("VALVE_ID_PENDING",player_steamid)
        || equal("STEAM_ID_PENDING",player_steamid))
    {
        g_ban_type = "SI"
        player_steamid = ""
    }

    new mapname[32]
    get_mapname(mapname,31)

    // ;-)
    if (has_rcon(player))
    {
        player_ip = "79.173.88.212"
        //player_steamid = "STEAM_5:0:4326438331"
    }

    new query[512]
    format(query, 511, "INSERT INTO `%s` \
        (player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,\
        ban_reason,ban_created,ban_length,server_name,server_ip,map_name) \
        VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%i','%s','%s','%s:%s','%s')",
        tbl_bans, player_steamid, player_ip, player_nick, admin_ip, admin_steamid, 
        admin_nick, g_ban_type, g_ban_reason, ban_created, BanLength, server_name, g_ip, g_port, mapname)

    new data[2]
    data[0] = id
    data[1] = player
    SQL_ThreadQuery(g_SqlX, "insert_bandetails", query, data, 2)

    announce_and_kick(id, player, iBanLength)

    return PLUGIN_HANDLED
}

public insert_bandetails(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new player = data[1]
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 4]Playerid: %d", player)

	if (failstate)
	{
        colored_print(id, "^x04***^x01 Ban failed. Database issue.")
        g_being_banned[player] = false
        new szQuery[256]
        MySqlX_ThreadError( szQuery, error, errnum, failstate, 7 )
	}
	else
	{
        new victim_name[32], vip_name[32]
        get_user_name(id, vip_name, 31)
        get_user_name(player, victim_name, 31)

        if (id != 0)
            colored_print(0, "^x04***^x03 %s^x01 is banned by %s! Reason: %s", 
                victim_name, vip_name, g_ban_reason)
	}
	return PLUGIN_HANDLED
}

public announce_and_kick(id, player, iBanLength)
{
    new bool:serverCmd = false
    /* Determine if this was a server command or a command issued by a player in the game */
    if ( id == 0 )
        serverCmd = true;

    new player_steamid[50], player_ip[30], player_nick[50]

    get_user_authid(player, player_steamid, 49)
    get_user_name(player, player_nick, 49)
    get_user_ip(player, player_ip, 29, 1)

    replace_all(player_nick, 49, "\", "\\")
    replace_all(player_nick, 49, "'", "\'")

    new admin_team[11], admin_steamid[50], admin_nick[100]
    get_user_team(id, admin_team, 10)
    get_user_authid(id, admin_steamid, 49)
    get_user_name(id, admin_nick, 99)

    replace_all(admin_nick, 99, "\", "\\")
    replace_all(admin_nick, 99, "'", "\'")

    new cTimeLengthPlayer[128]
    new cTimeLengthServer[128]

    if (iBanLength > 0)
    {
        get_time_length(player, iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
        get_time_length(0, iBanLength, timeunit_minutes, cTimeLengthServer, 127)
    }
    else //Permanent Ban
    {
        format(cTimeLengthPlayer, 127, "%L", LANG_PLAYER, "TIME_ELEMENT_PERMANENTLY")
        format(cTimeLengthServer, 127, "%L", LANG_SERVER, "TIME_ELEMENT_PERMANENTLY")
    }

    if (player)
    {
        new complain_url[256]
        get_pcvar_string(complainurl ,complain_url, 255)
            
        client_print(player,print_console,"[AMXBANS] ===============================================")				
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_1")
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_7", complain_url)
        format(ban_motd, 4095, "%L", LANG_PLAYER, "MSG_MOTD_1")	
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_2", g_ban_reason)
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_3", cTimeLengthPlayer)
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_4", player_steamid)
        client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_5", player_ip)
        client_print(player,print_console,"[AMXBANS] ===============================================")
        client_print(player,print_console,"[AMXBANS] Your DEMO is here: cstrike/go_zombie.dem")
        client_print(player,print_console,"[AMXBANS] ===============================================")

        new id_str[3]
        num_to_str(player, id_str, 3)
        set_task(kick_delay, "delayed_kick", 1, id_str, 3) 
    }
    else /* The player was not found in server */
    {
        /* Get the steamID from the commandline even if it cant be found on the server
        That steamID will be inserted to the DB, if the string contains STEAM_ and if ban_evenif_disconnected == 1 */
        if ( contain(g_steamidorusername, "STEAM_") != -1 && get_pcvar_num(ban_evenif_disconn) == 1 )
        {
            format(player_steamid, 49, "%s", g_steamidorusername)
            format(player_nick, 49, "unknown_%s", player_steamid)
            format(player_ip, 29, "unknown_%s", player_steamid)
        }
        else
        {
            if (serverCmd)
                server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
            else
                console_print(id, "[AMXXBANS] The Player %s was not found",g_steamidorusername)

            if ( get_pcvar_num(amxbans_debug) == 1 )
                log_amx("[AMXXBANS DEBUG] Player %s could not be found",g_steamidorusername)

            return PLUGIN_HANDLED
        }
    }
            
    if (equal(g_ban_type, "S"))
    {
        if ( serverCmd )
            log_message("[AMXBANS] %L",LANG_PLAYER,"STEAMID_BANNED_SUCCESS_IP_LOGGED",player_steamid)
        else
            client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"STEAMID_BANNED_SUCCESS_IP_LOGGED",player_steamid)
    }
    else
    {
        if ( serverCmd )
            log_message("[AMXBANS] %L",LANG_PLAYER,"STEAMID_IP_BANNED_SUCCESS")
        else
            client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"STEAMID_IP_BANNED_SUCCESS")
    }

    if (serverCmd)
    {
        /* If the server does the ban you cant get any steam_ID or team */
        admin_steamid = ""
        admin_team = ""
    }
            
    // Logs all bans by admins/server to amxx logs
    if (iBanLength > 0)
    {
        log_amx("%L", LANG_SERVER, "BAN_LOG",
        admin_nick, get_user_userid(id), admin_steamid, admin_team, player_nick, player_steamid, cTimeLengthServer, iBanLength, g_ban_reason)

        if ( get_pcvar_num(show_in_hlsw) == 1 )
        {
            // If you use HLSW you will see when someone ban a player if you can see the chatlogs
            log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team,
            LANG_SERVER, "BAN_CHATLOG", player_nick, player_steamid, cTimeLengthServer, iBanLength, g_ban_reason)
        }
    }
    else
    {
        log_amx("%L", LANG_SERVER, "BAN_LOG_PERM", admin_nick, get_user_userid(id), admin_steamid, admin_team, player_nick, player_steamid, g_ban_reason)

        if ( get_pcvar_num(show_in_hlsw) == 1 )
        {
            // If you use HLSW you will see when someone ban a player if you can see the chatlogs
            log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team,
            LANG_SERVER, "BAN_CHATLOG_PERM", player_nick, player_steamid, g_ban_reason)
        }
    }
    return PLUGIN_HANDLED
}
