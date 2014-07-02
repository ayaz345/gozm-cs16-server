/*
     This function will UnBan by steamID amx_unban <STEAMID or NICKNAME>   
*/

public cmdUnBan(id,level,cid)
{
    if(!(get_user_flags(id) & level))
        return PLUGIN_HANDLED

    new steamid_or_nick[50]

    read_args(steamid_or_nick, 50)
    trim(steamid_or_nick)

    if (equal(steamid_or_nick, ""))
    {
        client_print(id, print_console, "Usage: amx_unban <STEAM_ID or NICKNAME>")
        return PLUGIN_HANDLED
    }
    else if (equal(steamid_or_nick, "STEAM_ID_LAN"))
    {
        colored_print(id, "^x04 ***^x01 Can't unban STEAM_ID_LAN")
        return PLUGIN_HANDLED
    }
    else if (contain(steamid_or_nick, "STEAM_") != -1)
    {
        g_unban_player_steamid = steamid_or_nick
    }
    else
    {
        new query[512]
        new data[1]
        
        replace_all(steamid_or_nick, 99, "\", "\\")
        replace_all(steamid_or_nick, 99, "'", "\'")

        format(query, 511, "SELECT \
            bid,ban_created,ban_length,ban_reason,admin_nick,admin_id, \
            player_nick,player_ip,player_id,ban_type,server_ip,server_name \
            FROM `%s` WHERE player_nick LIKE '%%%s%%'", 
            tbl_bans, steamid_or_nick)
            
        data[0] = id
        SQL_ThreadQuery(g_SqlX, "cmd_unban_by_nick", query, data, 1)

        return PLUGIN_HANDLED
    }
    
    new query[512]
    new data[1]

    format(query, 511, "SELECT \
        bid,ban_created,ban_length,ban_reason,admin_nick,admin_id, \
        player_nick,player_ip,player_id,ban_type,server_ip,server_name \
        FROM `%s` WHERE player_id='%s'", 
        tbl_bans, g_unban_player_steamid)
    
    data[0] = id
    SQL_ThreadQuery(g_SqlX, "cmd_unban_select", query, data, 1)

    return PLUGIN_HANDLED
}

public cmd_unban_by_nick(failstate, Handle:query, error[], errnum, data[], size)
{
    new id = data[0]

    if (failstate)
    {
        new szQuery[256]
        MySqlX_ThreadError( szQuery, error, errnum, failstate, 11 )
    }
    else
    {
        new res_count = SQL_NumResults(query)
        log_amx("UNBAN: res_count: %d", res_count)
        new requested_query[512]
        SQL_GetQueryString(query, requested_query, charsmax(requested_query))
        log_amx("UNBAN: query: %s", requested_query)
        
        if(!res_count)
        {
            //client_print(id, print_console, "[AMXBANS] Player with that part of nickname is NOT found in bans")
            colored_print(id, "^x04 ***^x01 Player with that part of nickname is NOT found in bans")
            server_print("[AMXBANS] Player with that part of nickname is NOT found in bans")

            return PLUGIN_HANDLED
        }
        else if(res_count <= 7)
        {
            new i_Menu = menu_create("\yUnban Menu", "unban_menu_handler" )
            new c
            
            for(c=1; c<=res_count; c++)
            {
                new player_name[32]
                new player_steamid[50]
            
                SQL_ReadResult(query, column("player_nick"), player_name, 31)
                SQL_ReadResult(query, column("player_id"), player_steamid, 49)
                
                menu_additem(i_Menu, player_name, player_steamid)
                
                SQL_NextRow(query)
            }
            
            menu_setprop(i_Menu, 2, "Back")
            menu_setprop(i_Menu, 3, "Next")
            menu_setprop(i_Menu, 4, "Close")

            menu_display(id, i_Menu, 0)

            return PLUGIN_HANDLED
        }
        else
        {
            colored_print(id, "^x04 ***^x01 Too many output results: %d", res_count)
            colored_print(id, "^x04 ***^x01 Try to clarify nickname", g_unban_player_steamid)
            return PLUGIN_HANDLED
        }
    }
    
    return PLUGIN_HANDLED
}

public unban_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
    
    new query[512]
    new data[1]
    
    replace_all(s_Name, 99, "\", "\\")
    replace_all(s_Name, 99, "'", "\'")

    format(query, 511, "SELECT \
        bid,ban_created,ban_length,ban_reason,admin_nick,admin_id, \
        player_nick,player_ip,player_id,ban_type,server_ip,server_name \
        FROM `%s` WHERE BINARY player_nick='%s'", 
        tbl_bans, s_Name)
    
    data[0] = id
    SQL_ThreadQuery(g_SqlX, "cmd_unban_select", query, data, 1)
    
    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public cmd_unban_select(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new bool:serverCmd = false

	// Determine if this was a server command or a command issued by a player in the game
	if ( id == 0 )
		serverCmd = true
	
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 11 )
	}
	else
	{
        new res_count = SQL_NumResults(query)
        log_amx("UNBAN_SELECT: res_count: %d", res_count)
        new requested_query[512]
        SQL_GetQueryString(query, requested_query, charsmax(requested_query))
        log_amx("UNBAN_SELECT: query: %s", requested_query)
        
        if (!SQL_NumResults(query))
        {
            //client_print(id, print_console, "[AMXBANS] %L",LANG_PLAYER,"AMX_FIND_NORESULT", g_unban_player_steamid)
            server_print("[AMXBANS] %L",LANG_PLAYER,"AMX_FIND_NORESULT", g_unban_player_steamid)
            colored_print(id, "^x04 ***^x01 Не могу найти запрошенный ник в базе!")

            return PLUGIN_HANDLED
        }
        else
        {
            client_print(id, print_console, "[AMXBANS] %L", LANG_PLAYER, "AMX_FIND_RESULT_1", g_unban_player_steamid)

            new ban_created[50], ban_length[50], ban_reason[255], admin_nick[100]
            new ban_created_int, current_time_int
            new player_ip[30],player_steamid[50], ban_type[10], server_ip[30], server_name[100]

            new bid = SQL_ReadResult(query, 0)
            SQL_ReadResult(query, 1, ban_created, 49)
            SQL_ReadResult(query, 2, ban_length, 49)
            SQL_ReadResult(query, 3, ban_reason, 254)
            SQL_ReadResult(query, 4, admin_nick, 99)
            SQL_ReadResult(query, 5, g_admin_steamid, 49)
            SQL_ReadResult(query, 6, g_player_nick, 49)
            SQL_ReadResult(query, 7, player_ip, 29)
            SQL_ReadResult(query, 8, player_steamid, 49)
            SQL_ReadResult(query, 9, ban_type, 9)
            SQL_ReadResult(query, 10, server_ip, 29)
            SQL_ReadResult(query, 11, server_name, 99)

            //// MINE
            new unbanning_nick[50]
            get_user_name(id, unbanning_nick, 49)
            trim(unbanning_nick)
            log_amx("UNBAN_SELECT: U.NAME: %s, A.NAME %s, B.NAME: %s, B.IP: %s",
                unbanning_nick, admin_nick, g_player_nick, player_ip)

            if(!equal(unbanning_nick, admin_nick) && !(get_user_flags(id) & ADMIN_BAN))
            {
                colored_print(id, "^x04 ***^x01 It's not your ban! Banned by %s.", admin_nick)
                log_amx("UNBAN_SELECT: NOT YOUR BAN: VIP'%s' vs ADM'%s'", unbanning_nick, admin_nick)
                return PLUGIN_HANDLED
            }
            
/*
            log_amx("UNBAN_SELECT: amx_unsuperban %s", player_ip)
            client_cmd(id, "amx_unsuperban %s", player_ip)
            server_cmd("amx_unsuperban %s", player_ip)
            server_cmd("removeip %s", player_ip)
*/

            server_cmd("removeip %s", player_ip)
            new sub_query[512]
            new banned_player_name[50]
            banned_player_name = g_player_nick
            
            replace_all(banned_player_name, 99, "\", "\\")
            replace_all(banned_player_name, 99, "'", "\'")
            
            format(sub_query, 511, "UPDATE `superban` SET unbantime = -1 WHERE BINARY banname = '%s'",
                banned_player_name)
            SQL_ThreadQuery(g_SqlX, "cmd_delete_superban", sub_query)

            current_time_int = get_systime(0)
            ban_created_int = str_to_num(ban_created)

            /* Check how many minutes have gone since the ban was created */
            new banned_minutes_ago = (current_time_int - ban_created_int)/60
            new banned_ago_str[128], banned_ago_str2[128]
            get_time_length(id, get_pcvar_num(max_time_gone_to_unban), timeunit_minutes, banned_ago_str, 127)
            get_time_length(id, banned_minutes_ago, timeunit_minutes, banned_ago_str2, 127)
                
            if (banned_minutes_ago > get_pcvar_num(max_time_gone_to_unban) && !(get_user_flags(id)&get_higher_ban_time_admin_flag()) )
            {
                client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"UNBAN_TO_OLD_BAN", banned_ago_str)
                client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"UNBAN_TO_OLD_BAN2", banned_ago_str2)

                return PLUGIN_HANDLED
            }

            client_print(id,print_console," ")
            client_print(id,print_console,"[AMXBANS] =================")
            client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"AMX_FIND_RESULT_2", bid, g_player_nick)
            client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"AMX_FIND_RESULT_3", admin_nick, g_admin_steamid, ban_reason)
            client_print(id,print_console,"[AMXBANS] =================")
            client_print(id,print_console," ")

            server_print(" ")
            server_print("[AMXBANS] =================")
            server_print("[AMXBANS] %L",LANG_SERVER,"AMX_FIND_RESULT_2", bid, g_player_nick)
            server_print("[AMXBANS] %L",LANG_SERVER,"AMX_FIND_RESULT_3", admin_nick, g_admin_steamid, ban_reason)
            server_print("[AMXBANS] =================")
            server_print(" ")

            new unban_admin_steamid[32]
            if (!serverCmd)
            {
                get_user_authid(id, unban_admin_steamid, 31)
                get_user_team(id, g_unban_admin_team, 9)
                get_user_name(id, g_unban_admin_nick, 99)
            }
            else
            {
                /* If the server does the ban you cant get any steam_ID or team */
                unban_admin_steamid = ""
                g_unban_admin_team = ""

                /* This is so you can have a shorter name for the servers hostname.
                Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad */
                new servernick[100]
                get_pcvar_string(server_nick, servernick, 99)
                if (strlen(servernick))
                    g_unban_admin_nick = servernick
                else
                    get_cvar_string("hostname", g_unban_admin_nick, 99)
            }

            new unban_created = get_systime(0)

            new query[512]
            format(query, 511, "INSERT INTO `%s` \
                (player_id,player_ip,player_nick,admin_id,admin_nick,ban_type,\
                ban_reason,ban_created,ban_length,server_ip,server_name,\
                unban_created,unban_reason,unban_admin_nick) \
                VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%i','UnBanned in Game','%s %s')",
                tbl_banhist,g_unban_player_steamid,player_ip,banned_player_name,
                g_admin_steamid,admin_nick,ban_type,ban_reason,ban_created,
                ban_length,server_ip,server_name,unban_created, g_unban_admin_nick, 
                unban_admin_steamid)

            new data[2]
            data[0] = id
            data[1] = bid
            SQL_ThreadQuery(g_SqlX, "cmd_unban_insert", query, data, 2)

            if ( get_pcvar_num(amxbans_debug) == 1 )
                log_amx("[AMXBANS DEBUG] UNBAN IN GAME: INSERT INTO `%s` (VALUES('%s','%s','%s', '%s')",tbl_banhist,g_unban_player_steamid,g_player_nick,ban_length, g_unban_admin_nick)
        }
	}
	return PLUGIN_HANDLED
}

public cmd_delete_superban(failstate, Handle:query, error[], errnum, data[], size)
{
    if (failstate)
	{
        new szQuery[256]
        MySqlX_ThreadError(szQuery, error, errnum, failstate, 12)
	}
	else
	{
        new affected_rows = SQL_AffectedRows(query)
        log_amx("UNBAN: deleted rows: %d", affected_rows)
    }
    
    return PLUGIN_HANDLED
}

public cmd_unban_insert(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new bid = data[1]

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 12 )
	}
	else
	{
		new query[512]
		new data[1]
	
		format(query, 511, "DELETE FROM `%s` WHERE bid=%d", tbl_bans, bid)
		
		data[0] = id
		SQL_ThreadQuery(g_SqlX, "cmd_unban_delete_and_print", query, data, 1)
		
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[AMXBANS DEBUG] UNBAN IN GAME: DELETE FROM `%s` WHERE bid=%d",tbl_bans, bid)
	}
	
	return PLUGIN_HANDLED
}

public cmd_unban_delete_and_print(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 13 )
	}
	else
	{
        log_amx("%L", LANG_SERVER, "UNBAN_LOG",	g_unban_admin_nick, get_user_userid(id), g_admin_steamid, g_unban_admin_team, g_player_nick, g_unban_player_steamid)

        if ( get_pcvar_num(show_in_hlsw) == 1 )
        {
            // If you use HLSW you will see when someone ban a player if you can see the chatlogs
            log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", g_unban_admin_nick, get_user_userid(id) , g_admin_steamid, g_unban_admin_team,
            LANG_SERVER, "UNBAN_CHATLOG", g_player_nick, g_unban_player_steamid)
        }
            
        new show_activity = get_cvar_num("amx_show_activity")

        if( (get_user_flags(id)&get_admin_mole_access_flag() || id == 0) && (get_pcvar_num(show_name_evenif_mole) == 0) )
            show_activity = 1
            
        if (show_activity == 1)
        {
            client_print(0,print_chat,"%L",LANG_PLAYER,"PUBLIC_UNBAN_ANNOUNCE", g_player_nick)
        }

        if (show_activity == 2)
        {
            client_print(0,print_chat,"%L",LANG_PLAYER,"PUBLIC_UNBAN_ANNOUNCE_2", g_player_nick, g_unban_admin_nick)
        }
            
        client_print(id,print_console," ")
        client_print(id,print_console,"[AMXBANS] =================")
        client_print(id,print_console,"%L",LANG_PLAYER,"PUBLIC_UNBAN_ANNOUNCE", g_player_nick)
        client_print(id,print_console,"[AMXBANS] =================")
        client_print(id,print_console," ")

        server_print(" ")
        server_print("[AMXBANS] =================")
        server_print("[AMXBANS] %L",LANG_SERVER,"PUBLIC_UNBAN_ANNOUNCE", g_player_nick)
        server_print("[AMXBANS] =================")
        server_print(" ")

        colored_print(id, "^x04***^x01 Successfully UnBanned:^x04 %s", g_player_nick)
	}
	
	return PLUGIN_HANDLED
}
