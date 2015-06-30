#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <biohazard>
#include <sqlx>
#include <colored_print>
#include <gozm>

#define DEFAULT_TOP_COUNT       15
#define MAX_BUFFER_LENGTH       2048

#define STATSX_SHELL_DESIGN3_STYLE  "<meta charset=UTF-8><style>body{background:#E6E6E6;font-family:Verdana}th{background:#F5F5F5;color:#A70000;padding:6px;text-align:left}td{padding:2px 6px}table{color:#333;background:#E6E6E6;font-size:10px;font-family:Georgia;border:2px solid #D9D9D9}h2,h3{color:#333;}#c{background:#FFF}img{height:10px;background:#14CC00;margin:0 3px}#r{height:10px;background:#CC8A00}#clr{background:none;color:#A70000;font-size:20px;border:0}</style>"
#define STATSX_SHELL_DESIGN7_STYLE  "<meta charset=UTF-8><style>body{background:#FFF;font-family:Verdana}th{background:#2E2E2E;color:#FFF;text-align:left}table{padding:6px 2px;background:#FFF;font-size:11px;color:#333;border:1px solid #CCC}h2,h3{color:#333}#c{background:#F0F0F0}img{height:7px;background:#444;margin:0 3px}#r{height:7px;background:#999}#clr{background:none;color:#2E2E2E;font-size:20px;border:0}</style>"
#define STATSX_SHELL_DESIGN8_STYLE  "<meta charset=UTF-8><style>body{background:#242424;margin:20px;font-family:Tahoma}th{background:#2F3034;color:#BDB670;text-align:left} table{padding:4px;background:#4A4945;font-size:10px;color:#FFF}h2,h3{color:#D2D1CF}#c{background:#3B3C37}img{height:12px;background:#99CC00;margin:0 3px}#r{height:12px;background:#999900}#clr{background:none;color:#FFF;font-size:20px}</style>"
#define STATSX_SHELL_DESIGN10_STYLE "<meta charset=UTF-8><style>body{background:#4C5844;font-family:Tahoma}th{background:#1E1E1E;color:#C0C0C0;padding:2px;text-align:left;}td{padding:2px 10px}table{color:#AAC0AA;background:#424242;font-size:13px}h2,h3{color:#C2C2C2;font-family:Tahoma}#c{background:#323232}img{height:3px;background:#B4DA45;margin:0 3px}#r{height:3px;background:#6F9FC8}#clr{background:none;color:#FFF;font-size:20px}</style>"

#define SELECT_STATEMENT            "(SELECT *, (@_c := @_c + 1) AS `rank`, ((`infect` + `zombiekills`*2 + `humankills` + `knife_kills`*5 + `best_zombie` + `best_human` + `best_player`*10 + `escape_hero`*3) / (`infected` + `death` + 300)) AS `skill` FROM (SELECT @_c := 0) r, `bio_players` ORDER BY `skill` DESC) AS `newtable`"

#define PDATA_SAFE              2
#define OFFSET_DEATH            444

#define TASKID_AUTHORIZE        670
#define TASKID_LASTSEEN         671

#define column(%1)              SQL_FieldNameToNum(query, %1)

enum
{
    ME_DMG,
    ME_INFECT,
    ME_NUM
}

new g_UserIP[MAX_PLAYERS][32]
new g_UserAuthID[MAX_PLAYERS][32]
new g_UserName[MAX_PLAYERS][32]
new g_UserDBId[MAX_PLAYERS]

new Handle:g_SQL_Tuple

new whois[32]

new g_CvarHost, g_CvarUser, g_CvarPassword, g_CvarDB
new g_CvarMaxInactiveDays, g_CvarMinPlayers

new g_Me[MAX_PLAYERS][ME_NUM]
new g_text[MAX_BUFFER_LENGTH]
new bool:gb_css_trigger = true

new g_maxplayers
new bool:g_enable_stats_querying
new bool:g_is_escape_map

enum
{
    ID_AUTH_1 = 1,
    ID_AUTH_2,
    ID_RANK,
    ID_TOP_1,
    ID_TOP_2,
    ID_THREAD
}

new g_isconnected[MAX_PLAYERS]
new g_isalive[MAX_PLAYERS]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

public plugin_init()
{
    register_plugin("[BIO] Statistics", "1.7", "GoZm")

    if(!is_server_licenced())
        return PLUGIN_CONTINUE

    g_CvarHost = register_cvar("bio_stats_host", "195.128.158.196")
    g_CvarDB = register_cvar("bio_stats_db", "b179761")
    g_CvarUser = register_cvar("bio_stats_user", "u179761")
    g_CvarPassword = register_cvar("bio_stats_password", "petyx")
    g_CvarMaxInactiveDays = register_cvar("bio_stats_max_inactive_days", "30")
    g_CvarMinPlayers = register_cvar("bio_stats_min_players", "5")

    register_clcmd("say", "handleSay")
    register_clcmd("say_team", "handleSay")

    RegisterHam(Ham_Killed, "player", "fw_HamKilled")
    RegisterHam(Ham_Spawn, "player", "fw_SpawnPlayer", 1)
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage", 1)

    register_event("HLTV", "event_newround", "a", "1=0", "2=0")

    register_logevent("logevent_endRound", 2, "1=Round_End")

    g_maxplayers = get_maxplayers()
    g_enable_stats_querying = true
    g_is_escape_map = false

    return PLUGIN_CONTINUE
}

public plugin_cfg()
{
    new cfgdir[32]
    get_configsdir(cfgdir, charsmax(cfgdir))
    server_cmd("exec %s/bio_stats.cfg", cfgdir)

    set_task(0.1, "sql_init")
    set_task(5.0, "is_map_escape")
}

public sql_init()
{
    if(!is_server_licenced())
        return

    new host[32], db[32], user[32], password[32]

    get_pcvar_string(g_CvarHost, host, charsmax(host))
    get_pcvar_string(g_CvarDB, db, charsmax(db))
    get_pcvar_string(g_CvarUser, user, charsmax(user))
    get_pcvar_string(g_CvarPassword, password, charsmax(password))

    g_SQL_Tuple = SQL_MakeDbTuple(host, user, password, db)

    if(!SQL_SetCharset(g_SQL_Tuple, "utf8"))
    {
        new query[16]
        formatex(query, charsmax(query), "SET NAMES utf8")
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query)
    }

    new map_name[32]
    get_mapname(map_name, charsmax(map_name))
    new query_map[128]
    formatex(query_map, charsmax(query_map), "\
        INSERT INTO `bio_maps` (`map`) \
        VALUES ('%s') \
        ON DUPLICATE KEY UPDATE `games` = `games` + 1", map_name)
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_map)

    new max_inactive_days = get_pcvar_num(g_CvarMaxInactiveDays)
    new inactive_period = get_systime() - max_inactive_days*24*60*60
    new query_last_seen[128]
    formatex(query_last_seen, charsmax(query_last_seen), "\
        DELETE FROM `bio_players` \
        WHERE `last_seen` < %d", inactive_period)
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_last_seen)
}

public is_map_escape()
{
    new current_map[32]
    get_mapname(current_map, charsmax(current_map))

    new cfgdir[32]
    get_configsdir(cfgdir, charsmax(cfgdir))

    new escape_maps_file[64]
    formatex(escape_maps_file, charsmax(escape_maps_file), "%s/bio_escape.ini", cfgdir)
    if (file_exists(escape_maps_file))
    {
        new line[64]
        new file = fopen(escape_maps_file, "rt")
        while (file && !feof(file))
        {
            fgets(file, line, charsmax(line))
            trim(line)

            // skip commented lines
            if (line[0] == ';' || strlen(line) < 1 || (line[0] == '/' && line[1] == '/'))
                continue
            else if (equal(current_map, line))
            {
                g_is_escape_map = true
                log_amx("[BIO STAT]: This is escape map")
                break
            }
        }
        if (file) fclose(file)
    }
}

public plugin_end()
{
    SQL_FreeHandle(g_SQL_Tuple)
}

public client_putinserver(id)
{
    g_UserDBId[id] = 0
    g_isconnected[id] = true

    reset_player_statistic(id)
    set_task(0.1, "auth_player", TASKID_AUTHORIZE + id)
}

public client_disconnect(id)
{
    g_UserDBId[id] = 0
    g_isconnected[id] = false
    g_isalive[id] = false

    reset_player_statistic(id)
    remove_task(TASKID_AUTHORIZE + id)
    remove_task(TASKID_LASTSEEN + id)
}

public auth_player(taskid)
{
    static id
    id = taskid - TASKID_AUTHORIZE
    if (!is_user_valid_connected(id) || !id || id > g_maxplayers)
        return PLUGIN_HANDLED

    static unquoted_name[64]
    get_user_name(id, unquoted_name, charsmax(unquoted_name))
    mysql_escape_string(unquoted_name, charsmax(unquoted_name))
    copy(g_UserName[id], charsmax(unquoted_name), unquoted_name)
    get_user_authid(id, g_UserAuthID[id], charsmax(g_UserAuthID[]))
    get_user_ip(id, g_UserIP[id], charsmax(g_UserIP[]), 1)

    static query_select_id[128]
    formatex(query_select_id, charsmax(query_select_id), "\
        SELECT `id` FROM `bio_players` \
        WHERE BINARY `nick`='%s'", g_UserName[id])

    static data[2]
    data[0] = id
    data[1] = get_user_userid(id)
    SQL_ThreadQuery(g_SQL_Tuple, "ClientAuth_QueryHandler_Part1", query_select_id, data, sizeof(data))

    return PLUGIN_HANDLED
}

public ClientAuth_QueryHandler_Part1(failstate, Handle:query, error[], err, data[], size, Float:querytime)
{
    if(failstate)
    {
        static szQuery[1024]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_AUTH_1)

        return PLUGIN_HANDLED
    }

    static id
    id = data[0]

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    if(SQL_NumResults(query))
    {
        g_UserDBId[id] = SQL_ReadResult(query, column("id"))
        set_task(10.0, "update_last_seen", TASKID_LASTSEEN + id)
    }
    else
    {
        static insert_query[512]
        formatex(insert_query, charsmax(insert_query), "\
            INSERT INTO `bio_players` \
            SET `nick`='%s', `ip`='%s', `steam_id`='%s'",
            g_UserName[id], g_UserIP[id], g_UserAuthID[id])
        SQL_ThreadQuery(g_SQL_Tuple, "ClientAuth_QueryHandler_Part2", insert_query, data, size)
    }

    return PLUGIN_HANDLED
}

public ClientAuth_QueryHandler_Part2(failstate, Handle:query, error[], err, data[], size, Float:querytime)
{
    if(failstate)
    {
        static szQuery[1024]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_AUTH_2)

        return PLUGIN_HANDLED
    }

    static id
    id = data[0]
    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    g_UserDBId[id] = SQL_GetInsertId(query)
    set_task(10.0, "update_last_seen", TASKID_LASTSEEN + id)

    return PLUGIN_HANDLED
}

public update_last_seen(taskid)
{
    static id
    id = taskid - TASKID_LASTSEEN

    static last_seen
    last_seen = get_systime()
    static query_last_seen[256]
    formatex(query_last_seen, charsmax(query_last_seen), "\
        UPDATE `bio_players` \
        SET `last_seen` = %d, `ip`='%s', `steam_id`='%s' \
        WHERE `id`=%d", last_seen, g_UserIP[id], g_UserAuthID[id], g_UserDBId[id])
    SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_last_seen)

    return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
    if (!is_user_valid_connected(id))
        return PLUGIN_CONTINUE

    static newname[32], oldname[32]
    get_user_info(id, "name", newname, charsmax(newname))
    get_user_name(id, oldname, charsmax(oldname))

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

        if (g_UserDBId[id] && g_enable_stats_querying)
        {
            static query_infected[128]
            formatex(query_infected, charsmax(query_infected), "\
                UPDATE `bio_players` \
                SET `infected` = `infected` + 1 \
                WHERE `id`=%d", g_UserDBId[id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_infected)
        }
        if (g_UserDBId[infector] && g_enable_stats_querying)
        {
            static query_infect[128]
            formatex(query_infect, charsmax(query_infect), "\
                UPDATE `bio_players` \
                SET `infect` = `infect` + 1 \
                WHERE `id`=%d", g_UserDBId[infector])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_infect)
        }
    }
    else if (g_UserDBId[id] && g_enable_stats_querying)
    {
        static query_first_zombie[128]
        formatex(query_first_zombie, charsmax(query_first_zombie), "\
            UPDATE `bio_players` \
            SET `first_zombie` = `first_zombie` + 1 \
            WHERE `id`=%d", g_UserDBId[id])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_first_zombie)
    }

    return PLUGIN_CONTINUE
}

public logevent_endRound()
{
    if (get_playersnum())
    {
        // pause to calculate critical hits
        set_task(0.1, "task_announce_best_human_and_zombie")

        if (g_is_escape_map && g_enable_stats_querying)
            set_task(0.2, "task_celebrate_escape_heroes")
    }
}

public task_announce_best_human_and_zombie()
{
    static players[32], playersNum, i
    static maxInfectName[32], maxDmgName[32]
    static maxInfectId, maxDmgId, extraMaxInfectNum
    new maxInfectList[32]
    maxInfectId = 0
    maxDmgId = 0
    extraMaxInfectNum = 0

    get_players(players, playersNum)
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
    get_user_name(players[maxInfectId], maxInfectName, charsmax(maxInfectName))
    get_user_name(players[maxDmgId], maxDmgName, charsmax(maxDmgName))

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
        fm_add_frags(players[maxInfectId], 1.0)
        fm_add_frags(players[maxDmgId], 1.0)

        if (g_UserDBId[players[maxInfectId]] && g_enable_stats_querying)
        {
            static query_best_zombie[128]
            formatex(query_best_zombie, charsmax(query_best_zombie), "\
                UPDATE `bio_players` \
                SET `best_zombie` = `best_zombie` + 1 \
                WHERE `id`=%d", g_UserDBId[players[maxInfectId]])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_best_zombie)
        }
        if (g_UserDBId[players[maxDmgId]] && g_enable_stats_querying)
        {
            static query_best_human[128]
            formatex(query_best_human, charsmax(query_best_human), "\
                UPDATE `bio_players` \
                SET `best_human` = `best_human` + 1 \
                WHERE `id`=%d", g_UserDBId[players[maxDmgId]])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_best_human)
        }
    }
}

public task_celebrate_escape_heroes()
{
    static query_escape_heroes[256]
    new db_ids_as_string[MAX_PLAYERS][7]
    static db_ids_full_string[128]
    static hero_counter
    hero_counter = 0

    static players[32], playersNum
    static id, i
    get_players(players, playersNum)
    for (i = 0; i < playersNum; i++)
    {
        id = players[i]
        if (is_user_valid_alive(id) && !is_user_zombie(id))
        {
            fm_add_frags(id, 3.0)

            if (g_UserDBId[id])
            {
                static db_id_as_string[7]
                num_to_str(g_UserDBId[id], db_id_as_string, charsmax(db_id_as_string))
                copy(db_ids_as_string[hero_counter], charsmax(db_id_as_string), db_id_as_string)
                hero_counter++
            }
        }
    }
    if (hero_counter > 0)
    {
        implode_strings(db_ids_as_string, hero_counter, ",", db_ids_full_string, charsmax(db_ids_full_string))
        formatex(query_escape_heroes, charsmax(query_escape_heroes), "\
            UPDATE `bio_players` \
            SET `escape_hero` = `escape_hero` + 1 \
            WHERE `id` IN (%s)", db_ids_full_string)
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_escape_heroes)
    }
}

public event_newround()
{
    if (get_playersnum() < get_pcvar_num(g_CvarMinPlayers))
    {
        if (g_enable_stats_querying)
        {
            g_enable_stats_querying = false
            log_amx("[BIO STAT]: Querying disabled")
        }
    }
    else if (!g_enable_stats_querying)
    {
        g_enable_stats_querying = true
        log_amx("[BIO STAT]: Querying enabled")
    }

    static players[32], playersNum, i
    get_players(players, playersNum)
    for (i = 0; i < playersNum; i++)
        reset_player_statistic(players[i])

    if(get_playersnum() && !get_cvar_float("mp_timelimit"))  // galileo
    {
        new Float:player_total[33]
        new player_total_max = 0
        new best_id = 0

        for (i = 0; i < playersNum; i++)
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

        set_task(8.0, "task_announce_best_player", best_id)

        if (g_UserDBId[best_id] && g_enable_stats_querying)
        {
            static query_best_player[128]
            formatex(query_best_player, charsmax(query_best_player), "\
                UPDATE `bio_players` \
                SET `best_player` = `best_player` + 1 \
                WHERE `id`=%d", g_UserDBId[best_id])
            SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_best_player)
        }
    }
}

public task_announce_best_player(best_id)
{
    static best_name[32]
    get_user_name(best_id, best_name, charsmax(best_name))
/*
    colored_print(0, "^x04***^x01 Поздравляем!", best_name)
    colored_print(0, "^x04***^x01 Лучшим игроком карты признан^x03 %s^x01", best_name)
*/
    set_hudmessage(_, _, _, _, _, _, _, 8.0)
    ShowSyncHudMsg(0, CreateHudSyncObj(), "Лучший игрок карты^n^n %s", best_name)
}

public fw_HamKilled(victim, attacker, shouldgib)
{
    static type[16]
    static killer_frags
    killer_frags = 1

    g_isalive[victim] = false

    if (g_UserDBId[victim] && is_user_valid_connected(attacker) && g_enable_stats_querying)
    {
        static query_death[128]
        formatex(query_death, charsmax(query_death), "\
            UPDATE `bio_players` \
            SET `death` = `death` + 1 \
            WHERE `id`=%d", g_UserDBId[victim])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_death)
    }

    if (victim == attacker || !is_user_valid_connected(attacker))
    {
        copy(type, charsmax(type), "suicide")
    }
    else if (is_user_zombie(attacker))
    {
        copy(type, charsmax(type), "infect")
        g_Me[attacker][ME_INFECT]++
    }
    else
    {
        show_me(attacker)

        if (is_user_zombie(victim))
        {
            copy(type, charsmax(type), "zombiekills")

            if(g_UserDBId[attacker] && get_user_weapon(attacker) == CSW_KNIFE && g_enable_stats_querying)
            {
                // extra
                static query_knife_kills[128]
                formatex(query_knife_kills, charsmax(query_knife_kills), "\
                    UPDATE `bio_players` \
                    SET `knife_kills` = `knife_kills` + 1 \
                    WHERE `id`=%d", g_UserDBId[attacker])
                SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_knife_kills)
            }
        }
    }

    // connection check first
    if (is_user_valid_connected(attacker) && g_UserDBId[attacker] && g_enable_stats_querying)
    {
        static query_type_frag[128]
        formatex(query_type_frag, charsmax(query_type_frag), "\
            UPDATE `bio_players` \
            SET `%s` = `%s` + %d \
            WHERE `id`=%d",
            type, type, killer_frags, g_UserDBId[attacker])
        SQL_ThreadQuery(g_SQL_Tuple, "threadQueryHandler", query_type_frag)
    }

    return HAM_IGNORED
}

public fw_SpawnPlayer(id)
{
    if(!is_user_alive(id))
        return HAM_IGNORED

    g_isalive[id] = true

    return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    if (victim == attacker ||
        !is_user_valid_alive(attacker) ||
        !is_user_valid_connected(victim) ||
        !is_user_zombie(victim)
        )
        return HAM_IGNORED

    if (is_user_valid_alive(attacker) && !is_user_zombie(attacker))
        g_Me[attacker][ME_DMG] += floatround(damage)

    return HAM_IGNORED
}

reset_player_statistic(id)
{
    static i
    for (i = 0; i < ME_NUM; i++)
        g_Me[id][i] = 0
}

public handleSay(id)
{
    static args[64]

    read_args(args, charsmax(args))
    remove_quotes(args)

    static arg1[16]
    static arg2[32]

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
        show_stats(id)
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

show_me(id)
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

show_rank(id, unquoted_whois[])
{
    static query_rank[512]

    if (!unquoted_whois[0])
    {
        formatex(query_rank, charsmax(query_rank), "\
            SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` \
            FROM %s WHERE `id`=%d",
            SELECT_STATEMENT, g_UserDBId[id])
    }
    else
    {
        mysql_escape_string(unquoted_whois, charsmax(whois))
        copy(whois, charsmax(whois), unquoted_whois)

        formatex(query_rank, charsmax(query_rank), "\
            SELECT *,(SELECT COUNT(*) FROM `bio_players`) AS `total` \
            FROM %s \
            WHERE `nick` LIKE BINARY '%%%s%%' LIMIT 1",
            SELECT_STATEMENT, whois)
    }

    static data[2]
    data[0] = id
    data[1] = get_user_userid(id)

    SQL_ThreadQuery(g_SQL_Tuple, "ShowRank_QueryHandler", query_rank, data, sizeof(data))

    return PLUGIN_HANDLED
}

public ShowRank_QueryHandler(failstate, Handle:query, error[], err, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if(failstate)
    {
        static szQuery[1024]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_RANK)
        colored_print(id, "^x04***^x01 Команда^x04 /rank^x01 временно недоступна")

        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    static name[32]
    static rank
    static total

    if (SQL_MoreResults(query))
    {
        SQL_ReadResult(query, column("nick"), name, charsmax(name))
        rank = SQL_ReadResult(query, column("rank"))
        total = SQL_ReadResult(query, column("total"))

        colored_print(id, "^x04***^x03 %s^x01 находится на^x04 %d^x01 из %d позиций!",
            name, rank, total)
    }
    else
        colored_print(id, "^x04*** Игрок^x03 %s^x01 не найден. Проверь заглавные буквы!", whois)

    return PLUGIN_HANDLED
}

show_stats(id)
{
    colored_print(id, "^x04***^x01 Подробная статистика^x04 http://gozm.myarena.ru/top")
}

show_top(id, top)
{
    static query_top[64]
    formatex(query_top, charsmax(query_top), "SELECT COUNT(*) FROM `bio_players`")
    static data[3]
    data[0] = id
    data[1] = get_user_userid(id)
    data[2] = top
    SQL_ThreadQuery(g_SQL_Tuple, "ShowTop_QueryHandler_Part1", query_top, data, sizeof(data))

    return PLUGIN_HANDLED
}

public ShowTop_QueryHandler_Part1(failstate, Handle:query, error[], err, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if(failstate)
    {
        static szQuery[1024]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_TOP_1)
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")

        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    if(!SQL_MoreResults(query))
    {
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")
        return PLUGIN_HANDLED
    }

    static count
    count = SQL_ReadResult(query, 0)

    static top
    top = data[2]
    if (top <= DEFAULT_TOP_COUNT)
        top = DEFAULT_TOP_COUNT
    if (top >= count)
        top = count

    static query_show_top[512]
    formatex(query_show_top, charsmax(query_show_top), "\
        SELECT `nick`, `rank`, `skill` \
        FROM %s \
        WHERE `rank` <= %d ORDER BY `rank` ASC LIMIT %d, %d",
        SELECT_STATEMENT, top, top - DEFAULT_TOP_COUNT, DEFAULT_TOP_COUNT)
    static more_data[4]
    more_data[0] = data[0]
    more_data[1] = data[1]
    more_data[2] = data[2]
    more_data[3] = count
    SQL_ThreadQuery(g_SQL_Tuple, "ShowTop_QueryHandler_Part2", query_show_top, more_data, sizeof(more_data))

    return PLUGIN_HANDLED
}

public ShowTop_QueryHandler_Part2(failstate, Handle:query, error[], err, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if(failstate)
    {
        static szQuery[1024]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_TOP_2)
        colored_print(id, "^x04***^x01 Команда^x04 /top^x01 временно недоступна")

        return PLUGIN_HANDLED
    }

    if (data[1] != get_user_userid(id))
        return PLUGIN_HANDLED

    static title[32]
    static top
    top = data[2]

    static count
    count = data[3]
    if (top <= DEFAULT_TOP_COUNT)
        formatex(title, charsmax(title), "ТОП игроков 1-%d", top)
    else if (top < count)
        formatex(title, charsmax(title), "ТОП игроков %d-%d", top - DEFAULT_TOP_COUNT + 1, top)
    else
    {
        top = count
        formatex(title, charsmax(title), "ТОП игроков %d-%d ", top - DEFAULT_TOP_COUNT + 1, top)
    }

    static iLen
    iLen = 0
    setc(g_text, MAX_BUFFER_LENGTH, 0)

    iLen = format_all_themes(g_text, iLen, id)
    iLen += format(g_text[iLen], MAX_BUFFER_LENGTH - iLen,
        "<body><table width=100%% border=0 align=center cellpadding=0 cellspacing=1>")

    static lNick[32], lResult[32]
    formatex(lNick, charsmax(lNick), "Ник")
    formatex(lResult, charsmax(lResult), "Скилл")
    iLen += format(g_text[iLen], MAX_BUFFER_LENGTH - iLen,
        "<body><tr><th>%s<th>%s<th>%s</tr>", "#", lNick, lResult)

    static name[32], rank, skill
    static Float:pre_skill
    gb_css_trigger = true

    while (SQL_MoreResults(query))
    {
        rank = SQL_ReadResult(query, column("rank"))
        SQL_ReadResult(query, column("nick"), name, charsmax(name))
        SQL_ReadResult(query, column("skill"), pre_skill)
        skill = floatround(pre_skill * 1000.0)

        iLen += format(g_text[iLen], MAX_BUFFER_LENGTH - iLen,
            "<tr%s><td>%d<td>%s<td>%d</tr>", gb_css_trigger ? "" : " id=c", rank, name, skill)

        SQL_NextRow(query)
        gb_css_trigger = gb_css_trigger ? false : true
    }

    show_motd(id, g_text, title)

    setc(g_text, MAX_BUFFER_LENGTH, 0)

    return PLUGIN_HANDLED
}

public threadQueryHandler(failstate, Handle:Query, error[], err, data[], size, Float:querytime)
{
    if(failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(Query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, err, failstate, floatround(querytime), ID_THREAD)
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

format_all_themes(sBuffer[MAX_BUFFER_LENGTH], iLen, player_id)
{
    //new iDesign = get_pcvar_num(g_pcvar_design)
    static iDesign
    iDesign = player_id % 4
    switch(iDesign)
    {
        case 0:
            iLen = format(sBuffer, MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN3_STYLE)
        case 1:
            iLen = format(sBuffer, MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN7_STYLE)
        case 2:
            iLen = format(sBuffer, MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN8_STYLE)
        case 3:
            iLen = format(sBuffer, MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN10_STYLE)
        default:
            iLen = format(sBuffer, MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN10_STYLE)
    }

    return iLen
}

set_word_completion(number)
{
    static word_completion[4]
    if (number == 0 || number > 4)
        copy(word_completion, charsmax(word_completion), "й")
    else if (number == 1)
        copy(word_completion, charsmax(word_completion), "е")
    else
        copy(word_completion, charsmax(word_completion), "я")

    return word_completion
}

mysql_escape_string(dest[], len)
{
    replace_all(dest, len, "\\", "\\\\")
    replace_all(dest, len, "\0", "\\0")
    replace_all(dest, len, "\n", "\\n")
    replace_all(dest, len, "\r", "\\r")
    replace_all(dest, len, "\x1a", "\Z")
    replace_all(dest, len, "'", "\'")
    replace_all(dest, len, "^"", "\^"")
}

fm_get_user_deaths(id)
{
    // Prevent server crash if entity is not safe for pdata retrieval
    if (pev_valid(id) != PDATA_SAFE)
        return 0

    return get_pdata_int(id, OFFSET_DEATH)
}

fm_add_frags(id, Float:appending)
{
    static Float:frags
    pev(id, pev_frags, frags)
    set_pev(id, pev_frags, frags + appending)
}
