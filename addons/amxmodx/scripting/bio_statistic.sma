#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <biohazard>
#include <sqlx>
#include <time>
#include <fun>
#include <colored_print>

#pragma dynamic 16384

#define PLUGIN "[BIO] Statistics"
#define VERSION "1.01"
#define AUTHOR "Dimka"

#define DEFAULT_TOP_COUNT 10

#define OFFSET_DEATH 444

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

new g_Query[1024]
new whois[1024]

new g_CvarHost, g_CvarUser, g_CvarPassword, g_CvarDB
new g_CvarMaxInactiveDays

new const g_types[][] = {
    "first_zombie",
    "infect",
    "zombiekills",
    "humankills",
    "nemkills",
    "survkills",
    "suicide"
}

new g_Me[33][ME_NUM]
new g_text[5096]

new g_select_statement[] = "\
    (SELECT *, (@_c := @_c + 1) AS `rank`, \
    ((`infect` + `zombiekills`*2 + `humankills` + \
    `knife_kills`*5 + `best_zombie` + `best_human` + `best_player`*10 + `extra`) / \
    (`infected` + `death` + 300)) AS `skill` \
    FROM (SELECT @_c := 0) r, `bio_players` ORDER BY `skill` DESC) AS `newtable`"

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    if(!is_server_licenced())
        return

    g_CvarHost = register_cvar("bio_stats_host", "195.128.158.196")
    g_CvarDB = register_cvar("bio_stats_db", "b179761")
    g_CvarUser = register_cvar("bio_stats_user", "u179761")
    g_CvarPassword = register_cvar("bio_stats_password", "petyx")
	
    register_cvar("bio_statistics_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
    g_CvarMaxInactiveDays = register_cvar("bio_stats_max_inactive_days", "30")
	
    register_clcmd("say", "handleSay")
    register_clcmd("say_team", "handleSay")
	
    RegisterHam(Ham_Killed, "player", "fw_HamKilled")
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage", 1)
	
    register_event("HLTV", "event_newround", "a", "1=0", "2=0")
    register_logevent("logevent_endRound", 2, "1=Round_End")
}

public plugin_cfg()
{
    new cfgdir[32]
    get_configsdir(cfgdir, charsmax(cfgdir))
    server_cmd("exec %s/bio_stats.cfg", cfgdir)

    set_task(0.1, "sql_init")
}

public sql_init()
{
    if(!is_server_licenced())
        return

    new host[32], db[32], user[32], password[32]
    get_pcvar_string(g_CvarHost, host, 31)
    get_pcvar_string(g_CvarDB, db, 31)
    get_pcvar_string(g_CvarUser, user, 31)
    get_pcvar_string(g_CvarPassword, password, 31)

    g_SQL_Tuple = SQL_MakeDbTuple(host, user, password, db)

    if(!SQL_SetCharset(g_SQL_Tuple, "utf8"))
    {
        format(g_Query, charsmax(g_Query), "SET NAMES utf8")
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }

    new map_name[32]
    get_mapname(map_name, 31)
    format(g_Query, charsmax(g_Query), "\
        INSERT INTO `bio_maps` (`map`) \
        VALUES ('%s') \
        ON DUPLICATE KEY UPDATE `games` = `games` + 1", map_name)
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    
    new max_inactive_days = get_pcvar_num(g_CvarMaxInactiveDays)
    new inactive_period = get_systime() - max_inactive_days*24*60*60
    format(g_Query, charsmax(g_Query), "\
        DELETE FROM `bio_players` \
        WHERE `last_seen` < %d", inactive_period)
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

    format(g_Query, charsmax(g_Query), "\
        SELECT `id` FROM `bio_players` \
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
            "INSERT INTO `bio_players` \
            SET `nick`='%s', `ip`='%s', `steam_id`='%s'",
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
    
    new last_seen = get_systime()
    format(g_Query, charsmax(g_Query), "\
        UPDATE `bio_players` \
        SET `last_seen` = %d, `ip`='%s', `steam_id`='%s' \
        WHERE `id`=%d", last_seen, g_UserIP[id], g_UserAuthID[id], g_UserDBId[id])
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)

    return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE

    new newname[32]
    get_user_info(id, "name", newname, 31)
    new oldname[32]
    get_user_name(id, oldname, 31)
    
    if (!equal(oldname, newname) && !equal(oldname, ""))
    {
        if (g_UserDBId[id])
        {
            set_task(0.1, "update_last_seen", TASKID_LASTSEEN + id)
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
        show_me(infector)

        if (g_UserDBId[id])
        {
            format(g_Query, charsmax(g_Query), "\
            UPDATE `bio_players` \
                SET `infected` = `infected` + 1 \
                WHERE `id`=%d", g_UserDBId[id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
        if (g_UserDBId[infector])
        {
            format(g_Query, charsmax(g_Query),
                "UPDATE `bio_players` \
                SET `infect` = `infect` + 1 \
                WHERE `id`=%d", g_UserDBId[infector])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
    }
    else if (g_UserDBId[id])
    {
        format(g_Query, charsmax(g_Query), "\
            UPDATE `bio_players` \
            SET `first_zombie` = `first_zombie` + 1 \
            WHERE `id`=%d", g_UserDBId[id])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }
    
    return PLUGIN_CONTINUE
}

public logevent_endRound()
{
	if (get_playersnum())
	{
        // to calculate critical hits
        set_task(0.1, "task_announce_best_human_and_zombie")
	}
}

public task_announce_best_human_and_zombie()
{
    new players[32], playersNum, i, maxInfectId = 0, maxDmgId = 0
    new maxInfectName[32], maxDmgName[32]
    new extraMaxInfectNum = 0, maxInfectList[32]
    get_players(players, playersNum, "ch")
    for (i = 0; i < playersNum; i++)
    {
        if (g_Me[players[i]][ME_INFECT] > g_Me[players[maxInfectId]][ME_INFECT])
        {
            maxInfectId = i
            extraMaxInfectNum = 0
            maxInfectList[extraMaxInfectNum] = i
        }
        else if (g_Me[players[i]][ME_INFECT] == g_Me[players[maxInfectId]][ME_INFECT] && (i != 0))
        {
            extraMaxInfectNum++
            maxInfectList[extraMaxInfectNum] = i
        }
        if (g_Me[players[i]][ME_DMG] > g_Me[players[maxDmgId]][ME_DMG])
        {
            maxDmgId = i
        }
    }

    maxInfectId = maxInfectList[random_num(0, extraMaxInfectNum)]
    get_user_name(players[maxInfectId], maxInfectName, 31)
    get_user_name(players[maxDmgId], maxDmgName, 31)

    if (g_Me[players[maxInfectId]][ME_INFECT] ||
        g_Me[players[maxDmgId]][ME_DMG])
    {
        colored_print(0, "^x04***^x01 Лучший человек:^x04 %s^x01  ->  [^x03  %d^x01 дамаги  ]",
            maxDmgName, g_Me[players[maxDmgId]][ME_DMG])
        if (g_Me[players[maxInfectId]][ME_INFECT])
            colored_print(0, "^x04***^x01 Лучший зомби:^x04 %s^x01  ->  [^x03  %d^x01 заражени%s  ]",
                maxInfectName, g_Me[players[maxInfectId]][ME_INFECT], 
                set_word_completion(g_Me[players[maxInfectId]][ME_INFECT]))
        
        // extra
        if (g_UserDBId[players[maxInfectId]])
        {
            set_user_frags(players[maxInfectId], get_user_frags(players[maxInfectId])+1)

            format(g_Query, charsmax(g_Query), "\
                UPDATE `bio_players` \
                SET `best_zombie` = `best_zombie` + 1 \
                WHERE `id`=%d", g_UserDBId[players[maxInfectId]])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
        if (g_UserDBId[players[maxDmgId]])
        {
            set_user_frags(players[maxDmgId], get_user_frags(players[maxDmgId])+1)

            format(g_Query, charsmax(g_Query), "\
                UPDATE `bio_players` \
                SET `best_human` = `best_human` + 1 \
                WHERE `id`=%d", g_UserDBId[players[maxDmgId]])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
    }
}

public event_newround()
{
    new players[32], playersNum
    get_players(players, playersNum, "ch")
    for (new i = 0; i < playersNum; i++)
        reset_player_statistic(players[i])

    if(get_playersnum() && !get_cvar_float("mp_timelimit"))  // galileo
    {
        new Float:player_total[33]
        new player_total_max = 0
        new best_id = 0

        for (new i = 0; i < playersNum; i++)
        {
            new id = players[i]
            new frags, deaths

            frags = get_user_frags(id)
            deaths = fm_get_user_deaths(id)
            player_total[i] = float(frags) / (float(deaths) + 4.0)
            if (player_total[i] >= player_total[player_total_max])
            {
                player_total_max = i
                best_id = id
            }
        }

        set_task(1.5, "task_announce_best_player", best_id)

        if (g_UserDBId[best_id])
        {
            format(g_Query, charsmax(g_Query), "\
                UPDATE `bio_players` \
                SET `best_player` = `best_player` + 10 \
                WHERE `id`=%d", g_UserDBId[best_id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
        }
    }
}

public task_announce_best_player(best_id)
{
    new best_name[32]
    get_user_name(best_id, best_name, 31)
    colored_print(0, "^x04***^x01 Поздравляем!", best_name)
    colored_print(0, "^x04***^x01 Лучшим игроком карты признан^x03 %s^x01", best_name)
}

public fw_HamKilled(victim, attacker, shouldgib)
{
    new type
    new killer_frags = 1
    
    if (g_UserDBId[victim] && is_user_connected(attacker))
    {
        format(g_Query, charsmax(g_Query), "\
            UPDATE `bio_players` \
            SET `death` = `death` + 1 \
            WHERE `id`=%d", g_UserDBId[victim])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }

    if (victim == attacker || !is_user_connected(attacker))
    {
        type = 6
    }
    else if (is_user_zombie(attacker))
    {
        type = 1
        g_Me[attacker][ME_INFECT]++
    }
    else
    {
        show_me(attacker)
        
        if (g_UserDBId[victim])
        {
            type = 2

            if(get_user_weapon(attacker) == CSW_KNIFE)
            {
                // extra
                format(g_Query, charsmax(g_Query), "\
                    UPDATE `bio_players` \
                    SET `knife_kills` = `knife_kills` + 1 \
                    WHERE `id`=%d", g_UserDBId[attacker])
                SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
            }
        }
    }

    if (is_user_connected(attacker) && g_UserDBId[attacker])
    {
        format(g_Query, charsmax(g_Query), "\
            UPDATE `bio_players` \
            SET `%s` = `%s` + %d \
            WHERE `id`=%d",
            g_types[type], g_types[type], killer_frags, g_UserDBId[attacker])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", g_Query)
    }
    
    return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    if (victim == attacker || 
        !is_user_alive(attacker) || 
        !is_user_connected(victim) || 
        !is_user_zombie(victim)
        )
        return HAM_IGNORED

    if (is_user_alive(attacker) && !is_user_zombie(attacker))
        g_Me[attacker][ME_DMG] += floatround(damage)
    
    return HAM_IGNORED
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
            show_top(id, DEFAULT_TOP_COUNT)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

public show_me(id)
{
    if (!is_user_zombie(id))
        colored_print(id, "^x04***^x01 Нанес^x04 %d^x01 дамаги",
            g_Me[id][ME_DMG])
    else
        colored_print(id, "^x04***^x01 Заразил^x04 %d^x01 человек%s", 
            g_Me[id][ME_INFECT],
            0 < g_Me[id][ME_INFECT] < 5 ? "а" : "")

    return PLUGIN_HANDLED
}

public show_rank(id, unquoted_whois[])
{
    if (!unquoted_whois[0])
    {
        format(g_Query, charsmax(g_Query), "\
            SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` \
            FROM %s WHERE `id`=%d", 
            g_select_statement, g_UserDBId[id])
    }
    else
    {
        mysql_escape_string(unquoted_whois, 31)
        copy(whois, 31, unquoted_whois)
    
        format(g_Query, charsmax(g_Query), "\
            SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` \
            FROM %s \
            WHERE `nick` LIKE BINARY '%%%s%%' LIMIT 1",
            g_select_statement, whois)
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
        colored_print(id, "^x04***^x01 Команда^x04 /rank^x01 временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    new name[32]
    new rank
    new Float:res
    new total

    if (SQL_MoreResults(query))
    {
    	SQL_ReadResult(query, column("nick"), name, 31)
    	rank = SQL_ReadResult(query, column("rank"))
        SQL_ReadResult(query, column("skill"), res)
        total = SQL_ReadResult(query, column("total"))
    		
    	colored_print(id, "^x04***^x03 %s^x01 находится на^x04 %d^x01 из %d позиций!",
            name, rank, total)
    } 
    else
    	colored_print(id, "^x04*** Игрок^x03 %s^x01 не найден. Проверь заглавные буквы!", whois)
        
    return PLUGIN_HANDLED
}

public show_stats(id, unquoted_whois[])
{
    colored_print(id, "^x04***^x01 Подробная статистика скоро появится на сайте")
}

public show_top(id, top)
{
    format(g_Query, charsmax(g_Query), "SELECT COUNT(*) FROM `bio_players`")
    new data[3]
    data[0] = id
    data[1] = get_user_userid(id)
    data[2] = top
    SQL_ThreadQuery(g_SQL_Tuple, "ShowTop_QueryHandler_Part1", g_Query, data, 3)
//    colored_print(id, "^x04***^x01 Список лучших сейчас загрузится")

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
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")
        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
    	return PLUGIN_HANDLED

    new count

    if(SQL_MoreResults(query))
        count = SQL_ReadResult(query, 0)
    else
    {
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")
        return PLUGIN_HANDLED
    }

    new top = data[2]
    format(g_Query, charsmax(g_Query), "\
        SELECT `nick`, `rank`, `skill` \
        FROM %s \
        WHERE `rank` <= %d ORDER BY `rank` DESC LIMIT %d", 
        g_select_statement, top, DEFAULT_TOP_COUNT)
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
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")

        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
    	return PLUGIN_HANDLED

    new max_len = charsmax(g_text)

    new lTop[32], lLooserTop[32]
    format(lTop, 31, "ТОП игроков")
    format(lLooserTop, 31, "ТОП лузеров")

    new title[32]
    new top = data[2]

    new count = data[3]
    if (top <= DEFAULT_TOP_COUNT)
        format(title, 31, "%s %d", lTop, top)
    else
    if (top < count)
        format(title, 31, "%s %d - %d", lTop, top - DEFAULT_TOP_COUNT - 1, top)
    else
    {
        top = count
        format(title, 31, "%s", lLooserTop)
    }

    setc(g_text, max_len, 0)

    new name[32], rank, skill
    new Float:pre_skill
    new len

    while (SQL_MoreResults(query))
    {
        rank = SQL_ReadResult(query, column("rank"))
        SQL_ReadResult(query, column("nick"), name, 31)
        SQL_ReadResult(query, column("skill"), pre_skill)
        skill = floatround(pre_skill*1000.0)

        format(g_text, max_len, "<tr><td>%d<td>%s<td>%d<td>%s",
            rank, name, skill, g_text)
        
        SQL_NextRow(query)
    }

    new lNick[32], result[32]
    format(lNick, 31, "Ник")
    format(result, 31, "Скилл")

    len = format(g_text, max_len, 
        "<html>\
        <head>\
        <meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^" />\
        </head>\
        <body bgcolor=#000000>\
        <table style=^"color: #FFB000^">\
        <tr><td>%s<td>%s<td>%s<td>%s",
        "#", lNick, result, g_text)
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

stock fm_get_user_deaths(id)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return 0;
	
	return get_pdata_int(id, OFFSET_DEATH);
}
