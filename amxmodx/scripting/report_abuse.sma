#include <amxmodx>
#include <amxmisc>
#include <sqlx>


// Uncomment if you are going to use HLTV to record demos when players get reported
//#define USE_HLTV

#if defined USE_HLTV
    #include <sockets>
    new bool:recording = false
    new socket = 0
    new hltv_error
    new recording_time
#endif

new AUTH[] = "Gizmo"
new PLUGIN_NAME[] = "Report Abusive Players"
new VERSION[] = "1.0"

new Handle:g_SqlX
new g_table[32]

new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]

new g_coloredMenus

new reported_name[32]
new reported_authid[32]
new reporting_name[32]
new reporting_authid[32]
new lastreporttime[32]
new g_player

new motd_disabled
new show_reported
new MyMsgSync
new announcemsg
new min_time
new ar_debug
new not_report_admins
new hideAdmins

new g_Reasons[8][128]


public plugin_init()
{
	register_plugin(PLUGIN_NAME, VERSION, AUTH)
	register_cvar("reportabuse_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY)

	register_cvar("ar_sql_host", "127.0.0.1")
	register_cvar("ar_sql_user", "root")
	register_cvar("ar_sql_pass", "")
	register_cvar("ar_sql_db", "amx")
	register_cvar("ar_abuse_table", "amx_abuse_reports")

	register_cvar("ar_url", "http://www.yourhost.com/abusereports.php")
	register_cvar("ar_servernick", "myserver")
	register_cvar("ar_deletereportsflag", "l")
	register_cvar("ar_showreportsflag", "d")
#if defined USE_HLTV
	register_cvar("ar_hltv_proxypassword", "")
	recording_time = register_cvar("ar_recordingtime", "120.0")
#endif
	motd_disabled = register_cvar("ar_motddisabled", "1")
	show_reported = register_cvar("ar_showreported", "0")
	announcemsg = register_cvar("ar_announcemsg", "1")
	min_time = register_cvar("ar_nextreporttime", "60")
	ar_debug = register_cvar("ar_debug", "0")
	not_report_admins = register_cvar("ar_reportadmins", "0")
	hideAdmins = register_cvar("ar_hide_admins", "0")

	register_concmd("amx_deletereports", "delete_reports", -1, "amx_deletereports")
	register_concmd("amx_showreports", "showreports", -1, "amx_showreports")

	register_clcmd("say !report", "cmdabuseMenu")
	register_clcmd("say_team !report", "cmdabuseMenu")
	register_menucmd(register_menuid("Abuse Menu"), 1023, "actionAbuseMenu")
	
	register_menucmd(register_menuid("Report Reason Menu"), 1023, "actionReasonMenu")

	register_dictionary("report_abuse.txt")
	register_dictionary("common.txt")
	
	g_coloredMenus = colored_menus()
	MyMsgSync = CreateHudSyncObj()

	new configsDir[64]
	get_configsdir(configsDir, 63)

	server_cmd("exec %s/report_abuse.cfg", configsDir)
}

public plugin_cfg()
{
	new host[64], user[64], pass[64], db[64]

	get_cvar_string("ar_sql_host", host, 63)
	get_cvar_string("ar_sql_user", user, 63)
	get_cvar_string("ar_sql_pass", pass, 63)
	get_cvar_string("ar_sql_db", db, 63)
	get_cvar_string("ar_abuse_table", g_table, 31)

	g_SqlX = SQL_MakeDbTuple(host, user, pass, db)

	set_task(0.1, "create_table")
}

public create_table()
{
	new query[1024]
	new data[1]

	format(query, 1023, "CREATE TABLE IF NOT EXISTS `%s` (`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY , `reportingsteamid` VARCHAR(32) NOT NULL DEFAULT '0', `reportedsteamid` VARCHAR(32) NOT NULL DEFAULT '0', `reportingname` VARCHAR(32) NOT NULL DEFAULT 'Unknown', `reportedname` VARCHAR(32) NOT NULL DEFAULT 'Unknown', `reason` VARCHAR(100) NOT NULL DEFAULT '0', `date` TIMESTAMP NOT NULL) ENGINE = MYISAM", g_table)

	SQL_ThreadQuery(g_SqlX, "create_table_", query, data, 1)
	return
}

public create_table_(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 1 )
	}
	else
	{
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("Created table %s", g_table)
		
		new query[512]
		new data[1]

		format(query, 511, "SELECT * FROM %s", g_table)
		
		SQL_ThreadQuery(g_SqlX, "alter_table", query, data, 1)
	}
}

public alter_table(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 2 )
	}
	else
	{
		new columns = SQL_NumColumns(query)
		new cols[32]
		SQL_FieldNumToName(query, 6, cols, 31)

		if(get_pcvar_num(ar_debug) == 1)
			log_amx("columns: %d, Fieldname %s", columns, cols)

		if(equal(cols, "date"))
		{
			new query[512]
			new data[1]

			format(query, 511, "ALTER TABLE `%s` ADD `servername` VARCHAR( 100 ) NOT NULL DEFAULT 'unknown' AFTER `reason`", g_table)
			
			SQL_ThreadQuery(g_SqlX, "alter_table_", query, data, 1)
		}
		else
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public alter_table_(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 3 )
	}
}
/**************************************************

   Announcemessage function

**************************************************/
public client_putinserver(id)
{
	if(get_pcvar_num(announcemsg) == 1 && !is_user_admin(id) && !is_user_bot(id) && is_user_connected(id))
	{
		set_task(120.0, "print_announcemsg",  id, "", 0, "b")
	}
	return PLUGIN_HANDLED
}

public print_announcemsg(id)
{
	if(!is_user_admin(id) && !is_user_bot(id) && is_user_connected(id) && !is_user_hltv(id))
	{
		new msg[64]
		format(msg, 63, "%L", id, "ANNOUNCEMSG")
		set_hudmessage(0, 255, 0, 0.05, 0.35, 0, 6.0, 10.0 , 0.5, 0.15, -1)
		ShowSyncHudMsg(id, MyMsgSync, "%s", msg)
	}
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	if(task_exists(id))
		remove_task(id)
}
/***********************************************

   Menu

***********************************************/
public actionAbuseMenu(id, key)
{
	switch (key)
	{
		case 8: displayAbuseMenu(id, ++g_menuPosition[id])
		case 9: displayAbuseMenu(id, --g_menuPosition[id])
		default:
		{
			g_player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

			get_user_name(g_player, reported_name, 31)
			get_user_authid(g_player, reported_authid, 31)

			get_user_name(id, reporting_name, 31)
			get_user_authid(id, reporting_authid, 31)

			cmdReasonMenu(id)
		}
	}
	return PLUGIN_HANDLED
}

displayAbuseMenu(id, pos)
{
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 7

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "ABUSE_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
	new end = start + 7
	new keys = MENU_KEY_0|MENU_KEY_8

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (is_user_bot(i) || is_user_hltv(i) || is_user_admin(i) && get_pcvar_num(not_report_admins) == 0)
		{
			++b

			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, name)
			else
				len += format(menuBody[len], 511-len, "#. %s^n", name)
		} 
		else
		{
			keys |= (1<<b)
			if (is_user_admin(i) && get_pcvar_num(hideAdmins) == 1)
			   len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *   %s^n", ++b, name)
			else
			    len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s^n\w" : "%d. %s   %s^n", ++b, name)
		}
	}
	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Abuse Menu")
}

public cmdabuseMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	displayAbuseMenu(id, g_menuPosition[id] = 0)
	load_reasons(id)
	return PLUGIN_HANDLED
}

cmdReasonMenu(id)
{
	new menuBody[1024]
	new len = format(menuBody,1023, g_coloredMenus ? "\y%s\R^n\w^n" : "%s^n^n","Reason")
	new i = 0

	while (i<8)
	{
		if (strlen(g_Reasons[i]))
			len+=format(menuBody[len],1023-len,"%d. %s^n",i+1,g_Reasons[i])
		
		i++
	}

	len+=format(menuBody[len],1023-len,"^n0. %L^n",id,"EXIT")

	new keys = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_0


	show_menu(id,keys,menuBody,-1,"Report Reason Menu")
}

public actionReasonMenu(id,key)
{
	switch (key)
	{
		case 0: insert_report(id, 1, g_Reasons[key])
		case 1: insert_report(id, 2, g_Reasons[key])
		case 2: insert_report(id, 3, g_Reasons[key])
		case 3: insert_report(id, 4, g_Reasons[key])
		case 4: insert_report(id, 5, g_Reasons[key])
		case 5: insert_report(id, 6, g_Reasons[key])
		case 6: insert_report(id, 7, g_Reasons[key])
		case 7: insert_report(id, 8, g_Reasons[key])
	}

	return PLUGIN_HANDLED
}

load_reasons(id)
{
	format(g_Reasons[0], 127, "%L", id, "REASON_1")
	format(g_Reasons[1], 127, "%L", id, "REASON_2")
	format(g_Reasons[2], 127, "%L", id, "REASON_3")
	format(g_Reasons[3], 127, "%L", id, "REASON_4")
	format(g_Reasons[4], 127, "%L", id, "REASON_5")
	format(g_Reasons[5], 127, "%L", id, "REASON_6")
	format(g_Reasons[6], 127, "%L", id, "REASON_7")
	format(g_Reasons[7], 127, "%L", id, "REASON_8")
	return PLUGIN_HANDLED
}

printClientsChat(id, Reason[])
{
	client_print(id, print_chat, "%L", id, "ARTITLE")
	client_print(id, print_chat, "%L", id, "REPORTED", reported_name, Reason)
	client_print(id, print_chat, "%L", id, "ADMIN_ACTION")
	client_print(id, print_chat, "%L", id, "LINE")
	if(get_pcvar_num(show_reported) == 1)
	{
		client_print(g_player, print_chat, "%L", id, "ARTITLE")
		client_print(g_player, print_chat, "%L", id, "REPORTEDBY", reporting_name, Reason)
		client_print(g_player, print_chat, "%L", id, "ADMIN_ACTION")
		client_print(g_player, print_chat, "%L", id, "LINE")
	}
	return PLUGIN_HANDLED
}

insert_report(id, key, Reason[])
{
	new currenttime = get_user_time(id)
	new timeelapsed = currenttime - lastreporttime[id]

	if(get_pcvar_num(ar_debug) == 1)
		log_amx("timeelapsed: %d, currenttime: %d, lastreporttime: %d", timeelapsed, currenttime ,lastreporttime[id])
	
	if(timeelapsed < get_pcvar_num(min_time))
	{
		client_print(id, print_chat, "%L", id, "NEXT_REPORT", get_pcvar_num(min_time) - timeelapsed)
		return PLUGIN_HANDLED
	}
	else
	{
		new reason[32]
		switch(key)
		{
			case 1: format(reason, 31 , "%L" , LANG_SERVER , "REASON_1")
			case 2: format(reason, 31 , "%L" , LANG_SERVER , "REASON_2")
			case 3: format(reason, 31 , "%L" , LANG_SERVER , "REASON_3")
			case 4: format(reason, 31 , "%L" , LANG_SERVER , "REASON_4")
			case 5: format(reason, 31 , "%L" , LANG_SERVER , "REASON_5")
			case 6: format(reason, 31 , "%L" , LANG_SERVER , "REASON_6")
			case 7: format(reason, 31 , "%L" , LANG_SERVER , "REASON_7")
			case 8: format(reason, 31 , "%L" , LANG_SERVER , "REASON_8")
		}
		new hostname[32]
		get_cvar_string("ar_servernick", hostname, 31)
		new query[512]
		new data[1]
	
		format(query, 511, "INSERT INTO `%s` ( `id` , `reportingsteamid` , `reportedsteamid` , `reportingname` , `reportedname` , `reason` , `servername`) VALUES ( NULL , '%s', '%s', '%s' , '%s', '%s', '%s')", g_table, reporting_authid, reported_authid, reporting_name, reported_name, reason, hostname)
	
		data[0] = id
		SQL_ThreadQuery(g_SqlX, "reporting", query, data, 1)
	}
	printClientsChat(id, Reason)
	return PLUGIN_HANDLED
}

public reporting(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 4)
	}
	else
	{
		lastreporttime[id] = get_user_time(id)

#if defined USE_HLTV
		new timeleft = get_timeleft()
		if(timeleft < get_pcvar_float(recording_time) + 5.0)
		{
			return PLUGIN_HANDLED
		}
		else
		{
			hltv_start()
			set_task(get_pcvar_float(recording_time), "hltv_stop", 3536)
		}
#endif
	}
	return PLUGIN_HANDLED
}

/****************************************************

   Delete reports function

****************************************************/
public delete_reports(id, level, cid)
{
	if(id && !(get_user_flags(id) & get_admin_deletereports_flag()))
	{
		client_print(id, print_console, "%L", id, "NO_ACC_COM")
		return PLUGIN_HANDLED
	}
	
	new arg[32]
	read_argv(1, arg, 31)
	if(equali(arg, "all"))
	{
		new query[512]
		new data[1]
	
		format(query, 511, "TRUNCATE TABLE `%s`", g_table)

		data[0] = id
		SQL_ThreadQuery(g_SqlX, "truncate_table", query, data, 1)
		
		console_print(id, "%L", id, "REPORTS_DELETED")
		return PLUGIN_HANDLED
	}
	else if(containi(arg, "STEAM") != -1)
	{
		new query[512]
		new data[1]

		format(query, 511, "DELETE FROM `%s` WHERE `reportedsteamid`='%s'", g_table, arg)

		data[0] = id
		SQL_ThreadQuery(g_SqlX, "delete_user", query, data, 1)

		console_print(id, "%L", id, "USER_DELETED", arg)
		return PLUGIN_HANDLED
	}
	else if(str_to_num(arg) > 0)
	{
		new query[512]
		new data[1]
	
		format(query, 511, "DELETE FROM `%s` WHERE `id`='%d'", g_table, str_to_num(arg))

		data[0] = id
		SQL_ThreadQuery(g_SqlX, "delete_userid", query, data, 1)
		
		console_print(id, "%L", id, "USERID_DELETED", str_to_num(arg))
		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "%L", id, "USAGE_DELETE")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public truncate_table(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 5)
	}
	return PLUGIN_HANDLED
}
public delete_user(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 6)
	}
	return PLUGIN_HANDLED
}
public delete_userid(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 7)
	}
	return PLUGIN_HANDLED
}


/*****************************************************

   Show reports function

*****************************************************/
public showreports(id, level, cid)
{
	if(id && !(get_user_flags(id) & get_admin_showreports_flag()))
	{
		client_print(id, print_console, "%L", id, "NO_ACC_COM")
		return PLUGIN_HANDLED
	}
	new arg[32]
	read_argv(1, arg, 31)
	
	if(equal(arg, "motd"))
	{
		if(get_pcvar_num(motd_disabled) == 1)
		{
			client_print(id, print_chat, "%L", id, "COMMAND_DISABLED")
			console_print(id, "%L", id, "COMMAND_DISABLED")
			return PLUGIN_HANDLED
		}
		else
		{
			new info_url[256], msg[2048]
			get_cvar_string("ar_url", info_url, 255)
			format(msg, 2047, info_url)
			show_motd(id, msg, "Abuse reports")
		}
	}
	else if(equal(arg, "console"))
	{
		new query[1024]
		new data[1]
	
		format(query, 1023, "SELECT  id,reportingsteamid,reportedsteamid,reportingname,reportedname,reason,servername,date FROM `%s`", g_table)

		data[0] = id
		SQL_ThreadQuery(g_SqlX, "reports", query, data, 1)
	}
	else
	{
		console_print(id, "%L", id, "USAGE_SHOW")
	}
	return PLUGIN_HANDLED
}

public reports(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 8)
	}
	else
	{
		if(!SQL_NumResults(query))
		{
			client_print(id, print_chat, "%L", id, "NO_REPORTS")
			console_print(id, "%L", id, "NO_REPORTS")
			return PLUGIN_HANDLED
		}
		else
		{
			new str[7][32]
			console_print(id, "%L", id, "TITLE")
			while(SQL_MoreResults(query))
			{
				new dbid = SQL_ReadResult(query, 0)
				SQL_ReadResult(query, 1, str[0], 31)
				SQL_ReadResult(query, 2, str[1], 31)
				SQL_ReadResult(query, 3, str[2], 31)
				SQL_ReadResult(query, 4, str[3], 31)
				SQL_ReadResult(query, 5, str[4], 31)
				SQL_ReadResult(query, 6, str[5], 31)
				SQL_ReadResult(query, 7, str[6], 31)
				console_print(id, "%d | %s | %s | %s | %s | %s | %s | %s", dbid, str[2], str[0], str[3], str[1], str[4], str[5], str[6])
				SQL_NextRow(query)
			}
		}
	}
	return PLUGIN_HANDLED
}

/*******************************************************

    Error handler

*******************************************************/
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
	return PLUGIN_HANDLED
}

/*********************************************************

   HLTV Stuff
   
*********************************************************/
#if defined USE_HLTV
public hltv_start()
{
	if(recording)
	{
		change_task(3536, get_pcvar_float(recording_time), 0)

		if(get_pcvar_num(ar_debug) == 1)
			log_amx("Already recording a demo, adding %f seconds", get_pcvar_float(recording_time))

		return PLUGIN_HANDLED
	}
	new ip[32], address[32], hltvid
	new players[32], num
	get_players(players, num)
	for(new i = 0; i < num; i++)
	{
		new hid = players[i]
		if (is_user_hltv(hid))
		{
			hltvid = get_user_userid(hid)
		}
	}
	new hltv = find_player("k", hltvid)
	if(hltv)
	{
		new rconid[13]
		new rcv[256],snd[256]
		get_user_ip(hltv, ip, 31)
		new pos = copyc(address,31,ip,':') + 1
		
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("HLTV found: %s:%s", address, ip[pos])

		new pass[64]
		get_cvar_string("ar_hltv_proxypassword", pass, 63)
		socket = socket_open(address, str_to_num(ip[pos]), SOCKET_UDP, hltv_error)
		if (hltv_error != 0)
		{
			if(get_pcvar_num(ar_debug) == 1)
				log_amx("connection failed")
			return PLUGIN_HANDLED
		}
		setc(snd, 4, 0xff)
		copy(snd[4], 255, "challenge rcon")
		setc(snd[18], 1, '^n')
		socket_send(socket, snd, 255)
		socket_recv(socket, rcv, 255)

		copy(rconid, 12, rcv[19])
		replace(rconid, 255, "^n", "")

		setc(snd, 255, 0x00)
		setc(snd, 4, 0xff)
		format(snd[4], 255, "rcon %s %s  record demo^n", rconid, pass)

		socket_send(socket, snd, 255)
		socket_close(socket)
		
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("Recording demo")
		
		recording = true
	}
	else
	{
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("HLTV not found")
	}
	return PLUGIN_HANDLED
}

public hltv_stop()
{
	if(!recording)
	{
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("Not recording any demo right now")
		return PLUGIN_HANDLED
	}
	new ip[32], address[32], hltvid
	new players[32], num
	get_players(players, num)
	for(new i = 0; i < num; i++)
	{
		new hid = players[i]
		if (is_user_hltv(hid))
		{
			hltvid = get_user_userid(hid)
		}
	}
	new hltv = find_player("k", hltvid)
	if(hltv)
	{
		new rconid[13]
		new rcv[256],snd[256]
		get_user_ip(hltv, ip, 31)
		new pos = copyc(address,31,ip,':') + 1
		
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("HLTV found: %s:%s",address,ip[pos])

		new pass[64]
		get_cvar_string("ar_hltv_proxypassword", pass, 63)
		socket = socket_open(address, str_to_num(ip[pos]), SOCKET_UDP, hltv_error)
		if (hltv_error != 0)
		{
			if(get_pcvar_num(ar_debug) == 1)
				log_amx("connection failed")
			return PLUGIN_HANDLED
		}

		setc(snd, 4, 0xff)
		copy(snd[4], 255, "challenge rcon")
		setc(snd[18], 1, '^n')
		socket_send(socket, snd, 255)
		socket_recv(socket, rcv, 255)

		copy(rconid, 12, rcv[19])
		replace(rconid, 255, "^n", "")

		setc(snd, 255, 0x00)
		setc(snd, 4, 0xff)
		format(snd[4], 255, "rcon %s %s  stoprecording^n", rconid, pass)

		socket_send(socket, snd, 255)
		socket_close(socket)
		
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("Recording stopped")
		
		recording = false
	}
	else
	{
		if(get_pcvar_num(ar_debug) == 1)
			log_amx("HLTV not found")
	}
	return PLUGIN_HANDLED
}
#endif
   
public get_admin_deletereports_flag()
{
	new flags[24]
	get_cvar_string("ar_deletereportsflag", flags, 23)
	
	return(read_flags(flags))
}

public get_admin_showreports_flag()
{
	new flags[24]
	get_cvar_string("ar_showreportsflag", flags, 23)
	
	return(read_flags(flags))
}

