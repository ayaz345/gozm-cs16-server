#include <amxmodx>
#include <amxmisc>
#include <biohazard>
#include <sqlx>
#include <hamsandwich>
#include <time>
#include <fakemeta>
#include <colored_print>

#pragma dynamic 16384

#define PLUGIN "[BIO] Statistics"
#define VERSION "0.9"
#define AUTHOR "Dimka"

#define TASKID_AUTHORIZE 670
#define TASKID_LASTSEEN 671
 
#define column(%1) SQL_FieldNameToNum(query, %1)

enum 
{
	ME_DMG,
	ME_INFECT,
	ME_NUM
}

new g_UserIP[33][32], g_UserAuthID[33][32], g_UserName[33][32]
new g_UserDBId[33]

new Handle:g_SQL_Tuple

new g_Query[3024]
new whois[1024]

new g_CvarMaxInactiveDays

new const g_types[][] = {
    "first_zombie", 
    "infect", 
    "zombiekills", 
    "humankills", 
    "nemkills", 
    "survkills", 
    "suicide", 
    "extra"
}

new g_Me[33][ME_NUM]
new g_text[5096]

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_cvar("bio_statistics_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
    g_CvarMaxInactiveDays = register_cvar("bio_stats_max_inactive_days", "30")
	
    register_clcmd("say", "handleSay")
    register_clcmd("say_team", "handleSay")
	
    RegisterHam(Ham_Killed, "player", "fw_HamKilled")
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage", 1)
	
    register_event("HLTV", "event_newround", "a", "1=0", "2=0")
    register_logevent("logevent_endRound", 2, "1=Round_End")
	
    register_dictionary("time.txt")
    register_dictionary("bio_stats.txt")
}

public plugin_cfg()
{
    set_task(0.1, "sql_init")
}

public sql_init()
{
    if(!is_server_licenced())
        return

    g_SQL_Tuple = SQL_MakeStdTuple(30)

    format(g_Query, charsmax(g_Query), "SET NAMES utf8")
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)

    new map_name[32]
    get_mapname(map_name, 31)
    format(g_Query, charsmax(g_Query), "INSERT INTO `bio_maps` (`map`) VALUES ('%s') \
        ON DUPLICATE KEY UPDATE `games` = `games` + 1", map_name)
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    
    new max_inactive_days = get_pcvar_num(g_CvarMaxInactiveDays)
    new inactive_period = get_systime() - max_inactive_days*24*60*60
    format(g_Query,charsmax(g_Query),"DELETE FROM `bio_players` \
            WHERE `last_leave` < %d", inactive_period)
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
}

public plugin_end()
{
    SQL_FreeHandle(g_SQL_Tuple)
}

public client_authorized(id)
{
    g_UserDBId[id] = 0
    reset_player_statistic(id)
    set_task(0.5, "auth_player", TASKID_AUTHORIZE + id)

    return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
    g_UserDBId[id] = 0
    reset_player_statistic(id)
    remove_task(TASKID_AUTHORIZE + id)
    remove_task(TASKID_LASTSEEN + id)
}

public auth_player(taskid)
{
    new id = taskid - TASKID_AUTHORIZE
    
    new unquoted_name[64]
    get_user_name(id, unquoted_name, 63)
    mysql_escape_string(unquoted_name, 63)
    copy(g_UserName[id], 63, unquoted_name)
    get_user_authid(id, g_UserAuthID[id], 31)
    get_user_ip(id, g_UserIP[id], 31, 1)

    format(g_Query, charsmax(g_Query), "SELECT `id` FROM `bio_players` \
            WHERE BINARY `nick`='%s'", g_UserName[id])

    new data[2]
    data[0] = id
    data[1] = get_user_userid(id)

    SQL_ThreadQuery(g_SQL_Tuple, "ClientAuth_QueryHandler_Part1", g_Query, data, 2)
	
    return PLUGIN_HANDLED
}

public ClientAuth_QueryHandler_Part1(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 1)
        return PLUGIN_HANDLED
    }

    new id = data[0]

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    if(SQL_NumResults(query))
    {
        g_UserDBId[id] = SQL_ReadResult(query, column("id"))
        set_task(10.0, "update_last_seen", TASKID_LASTSEEN + id)
    }
    else
    {
        format(g_Query,charsmax(g_Query),
            "INSERT INTO `bio_players` SET `nick`='%s', `ip`='%s', `steam_id`='%s'",
            g_UserName[id], g_UserIP[id], g_UserAuthID[id])
        SQL_ThreadQuery(g_SQL_Tuple, "ClientAuth_QueryHandler_Part2", g_Query, data, 2)
    }
    return PLUGIN_HANDLED
}

public ClientAuth_QueryHandler_Part2(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 2)
        return PLUGIN_HANDLED
    }
    
    new id = data[0]
    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED
    
    g_UserDBId[id] = SQL_GetInsertId(query)
    set_task(10.0, "update_last_seen", TASKID_LASTSEEN + id)

    return PLUGIN_HANDLED
}

public update_last_seen(taskid)
{
    new id = taskid - TASKID_LASTSEEN
    
    new last_leave = get_systime()
    format(g_Query,charsmax(g_Query),"UPDATE `bio_players` SET `last_leave` = %d WHERE `id`=%d", 
        last_leave, g_UserDBId[id])
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    return PLUGIN_HANDLED
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
    {
        if (g_UserDBId[id])
        {
            new last_leave = get_systime()
            format(g_Query,charsmax(g_Query),"UPDATE `bio_players` SET `last_leave` = %d WHERE `id`=%d", 
                last_leave, g_UserDBId[id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
        
        g_UserDBId[id] = 0
        reset_player_statistic(id)
        set_task(0.1, "auth_player", TASKID_AUTHORIZE + id)
    }
    return PLUGIN_CONTINUE
}

public event_infect(id, infector)
{
    if (infector)
    {
        g_Me[infector][ME_INFECT]++

        if (g_UserDBId[id])
        {
            format(g_Query, charsmax(g_Query), 
                "UPDATE `bio_players` SET `infected` = `infected` + 1 WHERE `id`=%d", g_UserDBId[id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
        if (g_UserDBId[infector])
        {
            format(g_Query, charsmax(g_Query),
                "UPDATE `bio_players` SET `infect` = `infect` + 1 WHERE `id`=%d", g_UserDBId[infector])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
    }
    else if (g_UserDBId[id])
    {
        format(g_Query, charsmax(g_Query),
            "UPDATE `bio_players` SET `first_zombie` = `first_zombie` + 1 WHERE `id`=%d", g_UserDBId[id])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }
}

public logevent_endRound()
{
	if (get_playersnum())
	{
        new players[32], playersNum, i, maxInfectId = 0, maxDmgId = 0
        new maxInfectName[32], maxDmgName[32]
        new extraMaxInfectNum = 0, maxInfectList[32]
        get_players(players, playersNum, "ch")
        for (i = 0; i < playersNum; i++)
        {
            if (g_Me[players[i]][ME_INFECT] > g_Me[players[maxInfectId]][ME_INFECT]) {
                maxInfectId = i
                extraMaxInfectNum = 0
                maxInfectList[extraMaxInfectNum] = i
            }
            else if (g_Me[players[i]][ME_INFECT] == g_Me[players[maxInfectId]][ME_INFECT] && (i != 0)) {
                extraMaxInfectNum++
                maxInfectList[extraMaxInfectNum] = i
            }
            if (g_Me[players[i]][ME_DMG] > g_Me[players[maxDmgId]][ME_DMG]) {
                maxDmgId = i
            }
        }
        
        maxInfectId = maxInfectList[random_num(0, extraMaxInfectNum)]
        get_user_name(players[maxInfectId], maxInfectName, 31)
        get_user_name(players[maxDmgId], maxDmgName, 31)
        
        if (g_Me[players[maxInfectId]][ME_INFECT] ||
            g_Me[players[maxDmgId]][ME_DMG])
        {
            for (i = 0; i < playersNum; i++)
            {
                //colored_print(players[i], "^x04======================================")
                colored_print(players[i],
                    "^x04***^x01 Лучший человек:^x04 %s^x01  ->  [^x03  %d^x01 дамаги  ]",
                    maxDmgName, g_Me[players[maxDmgId]][ME_DMG])
                if (g_Me[players[maxInfectId]][ME_INFECT])
                    colored_print(players[i], 
                        "^x04***^x01 Лучший зомби:^x04 %s^x01  ->  [^x03  %d^x01 заражени%s  ]",
                        maxInfectName, g_Me[players[maxInfectId]][ME_INFECT], 
                        set_word_completion(g_Me[players[maxInfectId]][ME_INFECT]))
            }
            
            // extra
            if (g_UserDBId[players[maxInfectId]])
            {
                format(g_Query, charsmax(g_Query),
                    "UPDATE `bio_players` SET `extra` = `extra` + 1 WHERE `id`=%d",
                    g_UserDBId[players[maxInfectId]])
                SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
            }
            if (g_UserDBId[players[maxDmgId]])
            {
                format(g_Query, charsmax(g_Query),
                    "UPDATE `bio_players` SET `extra` = `extra` + 1 WHERE `id`=%d",
                    g_UserDBId[players[maxDmgId]])
                SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
            }
        }
	}
}

public event_newround()
{
    new players[32], playersNum, i
    get_players(players, playersNum, "ch")
    for (i = 0; i < playersNum; i++)
        reset_player_statistic(players[i])
}

public fw_HamKilled(id, attacker, shouldgib)
{
    new type, player = attacker
    new killer_frags = 1
    
    if (g_UserDBId[id] && is_user_connected(attacker))
    {
        format(g_Query, charsmax(g_Query),
            "UPDATE `bio_players` SET `death` = `death` + 1 WHERE `id`=%d", g_UserDBId[id])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }

    if (id == attacker || !is_user_connected(attacker))
    {
        type = 6
        player = id
    }
    else
    if (is_user_zombie(attacker))
    {
        type = 1
        g_Me[attacker][ME_INFECT]++
    }
    else
    {
        if (g_UserDBId[id])
        {
            type = 2

            if(get_user_weapon(attacker) == CSW_KNIFE)
            {
                // extra
                format(g_Query, charsmax(g_Query),
                    "UPDATE `bio_players` SET `extra` = `extra` + 5 WHERE `id`=%d",
                    g_UserDBId[player])
                SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
            }
        }
    }

    if (g_UserDBId[player])
    {
        format(g_Query, charsmax(g_Query), "UPDATE `bio_players` SET `%s` = `%s` + %d WHERE `id`=%d",
            g_types[type], g_types[type], killer_frags, g_UserDBId[player])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }
    
    return PLUGIN_CONTINUE
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    if (victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || !is_user_zombie(victim))
        return PLUGIN_CONTINUE	

    if (is_user_alive(attacker) && !is_user_zombie(attacker))
        g_Me[attacker][ME_DMG] += floatround(damage)
    
    return PLUGIN_CONTINUE
}

public reset_player_statistic(id)
{
	for (new i = 0; i < ME_NUM; i++)
		g_Me[id][i] = 0
}

public handleSay(id)
{
    new args[64]

    read_args(args, charsmax(args))
    remove_quotes(args)

    new arg1[16]
    new arg2[32]

    argbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2))
    if (equal(arg1, "/me"))
    {
        show_me(id)
        return PLUGIN_HANDLED
    }
    else if (equal(arg1, "/rank"))
    {
        show_rank(id, arg2)
        return PLUGIN_HANDLED
    }
    else if (equal(arg1, "/rankstats") || equal(arg1, "/stats"))
    {
        show_stats(id, arg2)
        return PLUGIN_HANDLED
    }
    else if (equal(arg1, "/top", 4))
    {
        if (arg1[4])
            show_top(id, str_to_num(arg1[4]))
        else
            show_top(id, 15)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

public show_me(id)
{
    if (!is_user_zombie(id))
        colored_print(id, "^x04***^x01 Ты нанес:^x04 %d^x01 дамаги", g_Me[id][ME_DMG])
    else
    {
        new client_message[64]
        format(client_message, charsmax(client_message), "и^x04 %d^x01 дамаги", g_Me[id][ME_DMG])
        colored_print(id, "^x04***^x01 Ты сделал:^x04 %d^x01 заражени%s %s", 
            g_Me[id][ME_INFECT],
            set_word_completion(g_Me[id][ME_INFECT]),
            g_Me[id][ME_DMG] ? client_message : "")
    }
    
    return PLUGIN_HANDLED
}

public show_rank(id, unquoted_whois[])
{
    if (!unquoted_whois[0])
    {
        format(g_Query, charsmax(g_Query), "SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` FROM \
            (SELECT *, (@_c := @_c + 1) AS `rank`, \
            ((`infect` + `zombiekills`*2 + `humankills` + `extra`) / (`infected` + `death` + 300)) AS `skill` \
            FROM (SELECT @_c := 0) r, `bio_players` ORDER BY `skill` DESC) AS `newtable` WHERE `id`=%d", 
            g_UserDBId[id])
    }
    else
    {
        mysql_escape_string(unquoted_whois, 31)
        copy(whois, 31, unquoted_whois)
    
        format(g_Query, charsmax(g_Query), "SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` FROM \
            (SELECT *, (@_c := @_c + 1) AS `rank`, \
            ((`infect` + `zombiekills`*2 + `humankills` + `extra`) / (`infected` + `death` + 300)) AS `skill` \
            FROM (SELECT @_c := 0) r, `bio_players` ORDER BY `skill` DESC) AS `newtable` \
            WHERE `nick` LIKE BINARY '%%%s%%' LIMIT 1",
            whois, whois)
    }

    new data[2]
    data[0] = id
    data[1] = get_user_userid(id)
    
    SQL_ThreadQuery(g_SQL_Tuple, "ShowRank_QueryHandler", g_Query, data, 2)
    
    return PLUGIN_HANDLED
}

public ShowRank_QueryHandler(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    new id = data[0]

    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 3)
        colored_print(id, "^x04***^x01 Команда ^"/rank^" временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    new name[32]
    new rank
    new Float:res//, skill
    new total

    if (SQL_MoreResults(query))
    {
    	SQL_ReadResult(query, column("nick"), name, 31)
    	rank = SQL_ReadResult(query, column("rank"))
        SQL_ReadResult(query, column("skill"), res)
//        skill = floatround(res*1000)
        total = SQL_ReadResult(query, column("total"))
    		
    	colored_print(id, "^x04***^x03 %s^x01 находится на^x04 %d^x01 из %d позиций!",
            name, rank, total)
    } 
    else
    	colored_print(id, "^x04***^x03 %s^x01 игрок не найден. Проверь заглавные буквы!", whois)
        
    return PLUGIN_HANDLED
}

public show_stats(id, unquoted_whois[])
{
    if (!unquoted_whois[0])
    {
        format(g_Query, charsmax(g_Query), "SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` FROM \
            (SELECT *, (@_c := @_c + 1) AS `rank`, \
            ((`infect` + `zombiekills`*2 + `humankills` + `extra`) / (`infected` + `death` + 300)) AS `skill` \
            FROM (SELECT @_c := 0) r, `bio_players` \
            ORDER BY `skill` DESC) AS `newtable` WHERE `id`=%d", 
            g_UserDBId[id])
    }
    else
    {
        mysql_escape_string(unquoted_whois, 31)
        copy(whois, 31, unquoted_whois)
    
        format(g_Query, charsmax(g_Query), "SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` FROM \
            (SELECT *, (@_c := @_c + 1) AS `rank`, \
            ((`infect` + `zombiekills`*2 + `humankills` + `extra`) / (`infected` + `death` + 300)) AS `skill` \
            FROM (SELECT @_c := 0) r, `bio_players` ORDER BY `skill` DESC) AS `newtable` \
            WHERE `nick` LIKE BINARY '%%%s%%' OR `ip` LIKE BINARY '%%%s%%' \
            LIMIT 1",
            whois, whois)
    }

    new data[2]
    data[0] = id
    data[1] = get_user_userid(id)
    SQL_ThreadQuery(g_SQL_Tuple, "ShowStats_QueryHandler", g_Query, data, 2)
    
    return PLUGIN_HANDLED
}

public ShowStats_QueryHandler(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    new id = data[0]

    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 4)
        colored_print(id, "^x04***^x01 Команда ^"/stats^" временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
    	return PLUGIN_HANDLED

    new name[32], ip[32], steam_id[32]
    new len
    new infect, zombiekills
    new death, infected, rank, total, Float:res, first_zombie, skill, extra

    if (SQL_MoreResults(query))
    {
    	SQL_ReadResult(query, column("nick"), name, 31)
    	SQL_ReadResult(query, column("ip"), ip, 31)
    	SQL_ReadResult(query, column("steam_id"), steam_id, 31)
    	first_zombie = SQL_ReadResult(query, column("first_zombie"))
    	infect = SQL_ReadResult(query, column("infect"))
    	zombiekills = SQL_ReadResult(query, column("zombiekills"))
    	death = SQL_ReadResult(query, column("death"))
    	infected = SQL_ReadResult(query, column("infected"))
    	rank = SQL_ReadResult(query, column("rank"))
        extra = SQL_ReadResult(query, column("extra"))
    	SQL_ReadResult(query, column("skill"), res)
        
        skill = floatround(res*1000)
    	total = SQL_ReadResult(query, column("total"))
    	
    	replace_all(name, 32, ">", "gt;")
    	replace_all(name, 32, "<", "lt;")
    	
    	new lStats[32]
    	format(lStats, 31, "%L", id, "STATS")
    	new lRank[32]
    	format(lRank, 31, "%L", id, "RANK_STATS")
        new lSkill[32]
        format(lSkill, 31, "%L", id, "RESULT")
    	new lInfect[32]
    	format(lInfect, 31, "%L", id, "INFECT_STATS")
    	new lZKills[32]
    	format(lZKills, 31, "%L", id, "ZKILLS_STATS")
    	new lHKills[32]
    	format(lHKills, 31, "%L", id, "HKILLS_STATS")
    	new lDeath[32]
    	format(lDeath, 31, "%L", id, "DEATH")
    	new lInfected[32]
    	format(lInfected, 31, "%L", id, "INFECTED")
    	new lFirstZombie[32]
    	format(lFirstZombie, 31, "%L", id, "FIRST_ZOMBIE")
        new lExtra[32]
        format(lExtra, 31, "%L", id, "EXTRA")
    		
    	new max_len = charsmax(g_text)
    	len = format(g_text, max_len, 
            "<html><head><meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^" /></head><body bgcolor=#000000>")
    	len += format(g_text[len], max_len - len, 
            "%s %s:<table style=^"color: #FFB000^"><tr><td>%s</td><td>%d/%d</td></tr><tr><td>%s</td><td>%d</td><tr><td>%s</td><td>%d</td>",
    		lStats, name, lRank, rank, total, lSkill, skill, lInfect, infect)
    	len += format(g_text[len], max_len - len, "<tr><td>%s</td><td>%d</td></tr>",
    		lZKills, zombiekills)
    	len += format(g_text[len], max_len - len, "<tr><td>%s</td><td>%d</td></tr><tr><td>%s</td><td>%d</td></tr>",
    		lDeath, death, lInfected, infected)
    	len += format(g_text[len], max_len - len, "<tr><td>%s</td><td>%d</td></tr>",
    		lFirstZombie, first_zombie)
        len += format(g_text[len], max_len - len, "<tr><td>%s</td><td>%d</td></tr>",
    		lExtra, extra)
    	
    	len += format(g_text[len], max_len - len, "<tr><td>%s</td><td>%s</td></tr><tr><td>%s</td><td>%s</td></tr>",
    		"IP", ip, "Steam ID", steam_id)
    	
    	len += format(g_text[len], max_len - len, "</table></body></html>")
    		
    	show_motd(id, g_text, "Stats")
    	
    	setc(g_text, max_len, 0)
    } 
    else
    	colored_print(id, "^x04***^x01 Команда ^"/stats^" временно недоступна")
    
    return PLUGIN_HANDLED
}

public show_top(id, top)
{
    format(g_Query, charsmax(g_Query), "SELECT COUNT(*) FROM `bio_players`")
    new data[3]
    data[0] = id
    data[1] = get_user_userid(id)
    data[2] = top
    SQL_ThreadQuery(g_SQL_Tuple, "ShowTop_QueryHandler_Part1", g_Query, data, 3)
    
    return PLUGIN_HANDLED
}

public ShowTop_QueryHandler_Part1(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    new id = data[0]

    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 5)
        colored_print(id, "^x04***^x01 Команда ^"/top^" временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
    	return PLUGIN_HANDLED

    new count

    if(SQL_MoreResults(query))
        count = SQL_ReadResult(query, 0)
    else
    {
        colored_print(id, "^x04***^x01 Команда ^"/top^" временно недоступна")
        return PLUGIN_HANDLED
    }

    new top = data[2]
    format(g_Query, charsmax(g_Query), "SELECT `nick`, `zombiekills`, `humankills`, \
            `infect`, `death`, `infected`, `rank`, `extra` FROM \
            (SELECT *, (@_c := @_c + 1) AS `rank`, \
            ((`infect` + `zombiekills`*2 + `humankills` + `extra`) / (`infected` + `death` + 300)) AS `skill` \
            FROM (SELECT @_c := 0) r, `bio_players` \
            ORDER BY `skill` DESC) AS `newtable` WHERE `rank` <= %d ORDER BY `rank` DESC LIMIT 15", 
            top)
    new more_data[4]
    more_data[0] = data[0]
    more_data[1] = data[1]
    more_data[2] = data[2]
    more_data[3] = count
    SQL_ThreadQuery(g_SQL_Tuple, "ShowTop_QueryHandler_Part2", g_Query, more_data, 4)
    
    return PLUGIN_HANDLED
}

public ShowTop_QueryHandler_Part2(FailState, Handle:query, error[], err, data[], size, Float:querytime)
{
    new id = data[0]

    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 6)
        colored_print(id, "^x04***^x01 Команда ^"/top^" временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
    	return PLUGIN_HANDLED

    new max_len = charsmax(g_text)

    new lTop[32]
    format(lTop, 31, "%L", id, "TOP")

    new lLooserTop[32]
    format(lLooserTop, 31, "%L", id, "TOP_LOOSERS")

    new title[32]
    new top = data[2]

    new count = data[3]
    if (top <= 15)
        format(title, 31, "%s %d", lTop, top)
    else
    if (top < count)
        format(title, 31, "%s %d - %d", lTop, top - 14, top)
    else
    {
        top = count
        format(title, 31, "%s", lLooserTop)
    }

    setc(g_text, max_len, 0)

    new zombiekills, humankills, infect, name[32], rank, infected, death, extra
    new Float:res, skill
    new len

    while (SQL_MoreResults(query))
    {
        SQL_ReadResult(query, column("nick"), name, 31)
        zombiekills = SQL_ReadResult(query, column("zombiekills"))
        humankills = SQL_ReadResult(query, column("humankills"))
        infect = SQL_ReadResult(query, column("infect"))
        infected = SQL_ReadResult(query, column("infected"))
        death = SQL_ReadResult(query, column("death"))
        rank = SQL_ReadResult(query, column("rank"))
        extra = SQL_ReadResult(query, column("extra"))
        res = float(zombiekills*2 + humankills + infect + extra) / float(death + infected + 300)
        skill = floatround(res*1000)
        
        format(g_text, max_len, "<tr><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%s",
            rank, name, zombiekills, infect, death, infected, skill, g_text)
        
        SQL_NextRow(query)
    }

    new lInfect[32]
    format(lInfect, 31, "%L", id, "INFECT_STATS")
    new lZKills[32]
    format(lZKills, 31, "%L", id, "ZKILLS_STATS")
    new lHKills[32]
    format(lHKills, 31, "%L", id, "HKILLS_STATS")
    new lDeaths[32]
    format(lDeaths, 31, "%L", id, "DEATH")
    new lInfected[32]
    format(lInfected, 31, "%L", id, "INFECTED")
    new result[32]
    format(result, 31, "%L", id, "RESULT")
    new lNick[32]
    format(lNick, 31, "%L", id, "NICK")

    len = format(g_text, max_len, 
        "<html>\
        <head>\
        <meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^" />\
        </head>\
        <body bgcolor=#000000>\
        <table style=^"color: #FFB000^">\
        <tr><td>%s<td>%s<td>%s | <td>%s | <td>%s | <td>%s | <td>%s     <td>%s",
        "#", lNick, lZKills, lInfect, lDeaths, lInfected, result, g_text)
    format(g_text[len], max_len - len, "</table></body></html>")    

    show_motd(id, g_text, title)

    setc(g_text, max_len, 0)
    
    return PLUGIN_HANDLED
}

public threadQueryHandler(FailState, Handle:Query, error[], err, data[], size, Float:querytime)
{
    if(FailState)
    {
        new szQuery[1024]
        SQL_GetQueryString(Query, szQuery, 1023)
        MySqlX_ThreadError(szQuery, error, err, FailState, floatround(querytime), 99)
    }
    return PLUGIN_HANDLED
}

/*********  Error handler  ***************/
MySqlX_ThreadError(szQuery[], error[], errnum, failstate, request_time, id)
{
    if (failstate == TQUERY_CONNECT_FAILED)
    {
        log_amx("[BIO STAT]: Connection failed")
    }
    else if (failstate == TQUERY_QUERY_FAILED)
    {
        log_amx("[BIO STAT]: Query failed")
    }
    log_amx("[BIO STAT]: Called from id=%d, errnum=%d, error=%s", id, errnum, error)
    log_amx("[BIO STAT]: Query: %ds to '%s'", request_time, szQuery)
}

stock set_word_completion(number)
{
    new word_completion[8]
    if (number == 0 || number > 4)
        word_completion = "й"
    else if (number == 1)
        word_completion = "е"
    else
        word_completion = "я"
    return word_completion
}

stock mysql_escape_string(dest[], len)
{
    replace_all(dest, len, "\\", "\\\\")
    replace_all(dest, len, "\0", "\\0")
    replace_all(dest, len, "\n", "\\n")
    replace_all(dest, len, "\r", "\\r")
    replace_all(dest, len, "\x1a", "\Z")
    replace_all(dest, len, "'", "\'")
    replace_all(dest, len, "^"", "\^"")
}
