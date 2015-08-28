#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <time>
#include <colored_print>
#include <gozm>

// Specify tablenames here
#define tbl_reasons             "amx_banreasons"
#define tbl_svrnfo              "amx_serverinfo"
#define tbl_bans                "amx_bans"
#define tbl_banhist             "amx_banhistory"
#define tbl_admins              "amx_amxadmins"

#define column(%1) SQL_FieldNameToNum(query, %1)

#define TASKID_DELAYED_KICK     123

#define MAX_UNBAN_OPTIONS       7

// Variables for menus
new g_BanMenuValues[12]
new g_coloredMenus
new g_banReasons[7][128]
new g_menuPlayers[MAX_PLAYERS][32]
new g_menuPlayersNum[MAX_PLAYERS]
new g_menuPosition[MAX_PLAYERS]
new g_menuOption[MAX_PLAYERS]
new g_menuSettings[MAX_PLAYERS]
new g_bannedPlayer
new g_lastCustom[MAX_PLAYERS][128]
new g_inCustomReason[MAX_PLAYERS]
/*****************************/

// pcvars
new server_nick
new complainurl
new banhistmotd_url
new consoleBanMax

/*****************************/

new Handle:g_SqlX

new g_aNum = 0
new g_server_ip[16]
new g_server_port[6]
new Float:kick_delay = 10.0
new g_bantimesnum

/*****************************/

// For the cmdBan
new g_steamidorusername[50] // Only used if the player is not on the server.
new g_ban_reason[64]
new g_ban_type[4] // String that contains "S" for steamID ban and "SI" for IP ban
new bool:g_being_banned[33]
new ga_PlayerIP[33][16]

// For the cmdUnban
new g_player_nick[50]
new g_unban_player_steamid[50]
new g_unban_admin_nick[100] //Big b/c it can also be the servername
new g_admin_steamid[50]
new g_unban_admin_team[10]

enum
{
    ID_INSERT_BANDETAILS = 1,
    ID_UNBAN_BY_NICK,
    ID_UNBAN_SELECT,
    ID_DELETE_SUPERBAN,
    ID_UNBAN_INSERT,
    ID_UNBAN_PRINT,
    ID_CHECK_PLAYER,
    ID_INSERT_BANHISTORY,
    ID_DELETE_EXPIRED,
    ID_FETCH_REASONS,
    ID_SQL_INIT
}

/*****************************/

new g_CvarHost, g_CvarUser, g_CvarPassword, g_CvarDB

public plugin_init()
{
    register_clcmd("amx_banmenu", "cmdBanMenu", ADMIN_FLAG, "- displays ban menu") //Changed this line to make this menu come up instead of the normal amxx ban menu
    register_clcmd("amxbans_custombanreason", "setCustomBanReason", ADMIN_FLAG, "- configures custom ban message")
    register_clcmd("amx_banhistorymenu", "cmdBanhistoryMenu", VIP_FLAG, "- displays banhistorymenu")

    register_menucmd(register_menuid("Ban Menu"), 1023, "actionBanMenu")
    register_menucmd(register_menuid("Ban Reason Menu"), 1023, "actionBanMenuReason")
    register_menucmd(register_menuid("Banhistory Menu"), 1023, "actionBanhistoryMenu")

    g_coloredMenus = colored_menus()

    register_plugin("AMXBans", "5.1.3", "GoZm")

    // store in amxbans.cfg
    g_CvarHost = register_cvar("amxbans_host", "141.101.203.23")
    g_CvarDB = register_cvar("amxbans_db", "b179761")
    g_CvarUser = register_cvar("amxbans_user", "u179761")
    g_CvarPassword = register_cvar("amxbans_password", "petyx")

    server_nick = register_cvar("amxbans_servernick", "") // Set this cvar to what the adminname should be if the server make the ban.
    complainurl = register_cvar("amxbans_complain_url", "www.yoursite.com") // Dont use http:// then the url will not show
    banhistmotd_url = register_cvar("amxbans_banhistmotd_url","http://pathToYour/findex.php?steamid=%s&ip=%s")
    consoleBanMax = register_cvar("amxbans_consolebanmax", "1440")

    register_concmd("amx_ban", "cmdBan", ADMIN_FLAG, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
    register_srvcmd("amx_ban", "cmdBan", -1, "<time in min> <steamID or nickname or #authid or IP> <reason>")
    register_concmd("amx_unban", "cmdUnBan", ADMIN_FLAG, "<steamID or nickname>")
    register_srvcmd("amx_unban", "cmdUnBan", -1, "<steamID or nickname>")
    register_srvcmd("amx_setbantimes", "setBantimes")

    register_dictionary("time.txt")  // for get_time_length()

    new configsDir[64], configfile[128]
    get_configsdir(configsDir, charsmax(configsDir))
    formatex(configfile, charsmax(configfile), "%s/amxbans.cfg", configsDir)
    if (file_exists(configfile))
    {
        server_cmd("exec %s", configfile)
    }

    new ip_port[23]
    new index_of_port
    get_user_ip(0, ip_port, charsmax(ip_port), 0)
    index_of_port = split_string(ip_port, ":", g_server_ip, charsmax(g_server_ip))
    formatex(g_server_port, charsmax(g_server_port), "%s", ip_port[index_of_port])

    set_task(0.5, "sql_init")
    set_task(5.0, "addBanhistMenu")
}

public addBanhistMenu()
    AddMenuItem("Banhistory Menu", "amx_banhistorymenu", ADMIN_FLAG, "amxbans" /* case-insensitive */)

public sql_init()
{
    new host[32], db[32], user[32], password[32]

    get_pcvar_string(g_CvarHost, host, charsmax(host))
    get_pcvar_string(g_CvarDB, db, charsmax(db))
    get_pcvar_string(g_CvarUser, user, charsmax(user))
    get_pcvar_string(g_CvarPassword, password, charsmax(password))

    g_SqlX = SQL_MakeDbTuple(host, user, password, db)

    if (!SQL_SetCharset(g_SqlX, "utf8"))
    {
        static query[32]
        formatex(query, charsmax(query), "SET NAMES utf8")
        SQL_ThreadQuery(g_SqlX, "_sql_init", query)
    }

    set_task(1.0, "fetchReasons")
}

public _sql_init(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    if (failstate)
    {
        new szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_SQL_INIT)
    }

    return PLUGIN_HANDLED
}

public client_connect(id)
{
    g_lastCustom[id][0] = '^0'
    g_inCustomReason[id] = 0
    g_being_banned[id] = false
}

public client_disconnect(id)
{
    g_lastCustom[id][0] = '^0'
    g_inCustomReason[id] = 0
    g_being_banned[id] = false
}

public client_authorized(id)
{
    if (has_vip(id) || has_admin(id))
    {
        return PLUGIN_CONTINUE
    }
    set_task(1.1, "check_player", id)

    return PLUGIN_CONTINUE
}

public delayed_kick(reason[], task_id)
{
    static player_id, userid, kick_message[128]
    player_id = task_id - TASKID_DELAYED_KICK
    userid = get_user_userid(player_id)

    static complain_url[64]
    get_pcvar_string(complainurl, complain_url, charsmax(complain_url))

    formatex(kick_message, charsmax(kick_message), " Ты забанен: %s. Разбан: %s", reason, complain_url)

    server_cmd("kick #%d %s", userid, kick_message)

    return PLUGIN_CONTINUE
}

/* This function will attempt to find a player based on the following options:
	- Partial Player Name
	- Steam ID
	- User ID
	- User IP Address
*/
locate_player(identifier[])
{
    copy(g_ban_type, charsmax(g_ban_type), "SI")

    static player
    player = 0

    // Check based on user ID
    if (identifier[0] == '#' && identifier[1])
    {
        player = find_player("k", str_to_num(identifier[1]))
    }

    // Check based on steam ID
    if (!player)
    {
        player = find_player("c", identifier)
    }

    // Check based on a partial non-case sensitive name
    if (!player)
    {
        player = find_player("bl", identifier)
    }

    if (!player)
    {
        // Check based on IP address
        player = find_player("d", identifier)

        if (player)
            copy(g_ban_type, charsmax(g_ban_type), "SI")
    }

    if (player)
    {
        /* Check for immunity */
        if (has_vip(player) || has_admin(player))
        {
            return -1
        }
    }

    return player
}

public setBantimes()
{
    new arg[32]
    new argc = read_argc() - 1
    g_bantimesnum = argc

    if (argc < 1 || argc > 12)
    {
        log_amx("[AMXBANS]: You have more than 12 or less than 1 bantimes set in amx_setbantimes")
        log_amx("[AMXBANS]: Loading default bantimes")
        loadDefaultBantimes()
        return PLUGIN_HANDLED
    }

    new i = 0
    new num[32], flag[32]

    while (i < argc)
    {
        read_argv(i + 1, arg, charsmax(arg))
        parse(arg, num, charsmax(num), flag, charsmax(flag))

        if (equal(flag, "m"))
        {
            g_BanMenuValues[i] = str_to_num(num)
        }
        else if (equal(flag, "h"))
        {
            g_BanMenuValues[i] = (str_to_num(num) * 60)
        }
        else if (equal(flag, "d"))
        {
            g_BanMenuValues[i] = (str_to_num(num) * 1440)
        }
        else if (equal(flag, "w"))
        {
            g_BanMenuValues[i] = (str_to_num(num) * 10080)
        }
        else if (equal(flag, "M"))
        {
            g_BanMenuValues[i] = (str_to_num(num) * 43200)
        }

        i++
    }

    return PLUGIN_HANDLED
}

loadDefaultBantimes()
{
    server_cmd("amx_setbantimes ^"15 m^" ^"1 h^" ^"1 d^" ^"1 w^" ^"4 w^"")
}

/* ------------ BAN ---------------- */

public cmdBan(id, level, cid)
{
    /* Checking if the admin has the right access */
    if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED

    static bool:serverCmd
    serverCmd = false
    /* Determine if this was a server command or a command issued by a player in the game */
    if (id == 0)
        serverCmd = true

    static text[128], steamidorusername[50], ban_length[50]
    read_args(text, charsmax(text))
    parse(text, ban_length, charsmax(ban_length), steamidorusername, charsmax(steamidorusername))

    /* Check so the ban command has the right format */
    if (!is_str_num(ban_length) || read_argc() < 4)
    {
        client_print(id, print_console, "[AMXBANS]: amx_ban <время> <steamID или ник> <причина>")
        return PLUGIN_HANDLED
    }

    static length1, length2, length
    length1 = strlen(ban_length)
    length2 = strlen(steamidorusername)
    length = length1 + length2 + 2

    static reason[64]
    read_args(reason, charsmax(reason))
    formatex(g_ban_reason, charsmax(g_ban_reason), "%s", reason[length])

    replace_all(g_ban_reason, charsmax(g_ban_reason), "\", "\\")
    replace_all(g_ban_reason, charsmax(g_ban_reason), "'", "\'")

    static iBanLength
    iBanLength = str_to_num(ban_length)

    // This stops admins from banning perm in console
    if (!has_rcon(id) && iBanLength == 0)
    {
        client_print(id, print_console, "[AMXBANS]: Нельзя банить в консоле навсегда!")
        return PLUGIN_HANDLED
    }

    // This stops admins from banning more than %d min in console
    if (!has_rcon(id) && iBanLength > get_pcvar_num(consoleBanMax))
    {
        client_print(id, print_console, "[GOZM]: Максимум для бана %i минут!",
            get_pcvar_num(consoleBanMax))
        return PLUGIN_HANDLED
    }

    /* Try to find the player that should be banned */
    static player
    player = locate_player(steamidorusername)
    if (player == -1)
    {
        colored_print(id, "^x04***^x01 У этого игрока есть иммунитет")
        return PLUGIN_HANDLED
    }

    if (g_being_banned[player]) //triggered error http://amxbans.net/forums/viewtopic.php?p=3468#3468
    {
        return PLUGIN_HANDLED
    }

    g_being_banned[player] = true

    static player_steamid[50], player_ip[30]
    if (player)
    {
        get_user_authid(player, player_steamid, charsmax(player_steamid))
        get_user_ip(player, player_ip, charsmax(player_ip), 1)
        get_user_ip(player, ga_PlayerIP[player], charsmax(ga_PlayerIP[]), 1)
    }
    else
    {
        // Must make that false to be able to ban another player not on the server
        // Players that aren't in the server always get id = 0
        g_being_banned[0] = false

        if (serverCmd)
            server_print("[AMXXBANS] The Player %s was not found", g_steamidorusername)
        else
            colored_print(id, "^x04***^x01 Игрок^x03 %s^x01 не найден на сервере", g_steamidorusername)

        return PLUGIN_HANDLED
    }

    /*
      If it is on a lan the player_steamid must not be inserted to the DB then everybody on the LAN would be considered banned.
        Only IP and nick is enough for LAN bans. HLTV will also only be banned by IP

        Don't wanna ban a player with STEAM_ID_PENDING to the DB as that can make many others to be considdered banned.
        Make an IP ban instead and don't add player_steamid to the DB
    */
    if (equal("4294967295", player_steamid)
        || equal("HLTV", player_steamid)
        || equal("STEAM_ID_LAN",player_steamid)
        || equal("VALVE_ID_LAN",player_steamid)
        || equal("VALVE_ID_PENDING",player_steamid)
        || equal("STEAM_ID_PENDING",player_steamid))
    {
        copy(g_ban_type, charsmax(g_ban_type), "SI")
        copy(player_steamid, charsmax(player_steamid), "")
    }

    /////////// SCREENSHOT AS A PROOF ///////////
    static banned_name[32], admin_name[32]
    get_user_name(player, banned_name, charsmax(banned_name))
    get_user_name(id, admin_name, charsmax(admin_name))
    colored_print(player, "^x04***^x01 %s забанен випом^x04 %s^x01 [на %dм.]", banned_name, admin_name, iBanLength)
    client_cmd(player, "snapshot")
    /////////////////////////////////////////////

    cmd_ban_(id, player, iBanLength)

    if (has_rcon(player))
        return PLUGIN_HANDLED

    static param[2]
    param[0] = player
    param[1] = 15
    set_task(kick_delay + 5.0, "double_ban", player, param, sizeof(param))

    SuperBan(player, iBanLength, id)

    return PLUGIN_HANDLED
}

public double_ban(param[]) {
    static id, iBanLength
    id = param[0]
    iBanLength = param[1]

    if (has_rcon(id))
        return PLUGIN_CONTINUE

    server_cmd("addip %d %s", iBanLength, ga_PlayerIP[id])

    return PLUGIN_CONTINUE
}

SuperBan(victim_id, iBanLength, admin_or_vip_id)
{
    if (has_rcon(victim_id))
        return PLUGIN_CONTINUE

    static victim_userid
    victim_userid = get_user_userid(victim_id)
    if (is_user_connected(victim_id) && (is_user_connected(admin_or_vip_id) || admin_or_vip_id == 0))
    {
        client_cmd(admin_or_vip_id, "amx_superban #%d %d ^"%s^"",
            victim_userid, iBanLength, g_ban_reason)
    }
    return PLUGIN_CONTINUE
}

cmd_ban_(id, player, iBanLength)
{
    static bool:serverCmd
    serverCmd = false
    // Determine if this was a server command or a command issued by a player in the game
    if (id == 0)
        serverCmd = true

    static player_steamid[50], player_ip[30], player_nick[50]

    get_user_authid(player, player_steamid, charsmax(player_steamid))
    get_user_name(player, player_nick, charsmax(player_nick))
    get_user_ip(player, player_ip, charsmax(player_ip), 1)

    replace_all(player_nick, charsmax(player_nick), "\", "\\")
    replace_all(player_nick, charsmax(player_nick), "'", "\'")

    static admin_nick[100], admin_steamid[50], admin_ip[20]
    get_user_name(id, admin_nick, charsmax(admin_nick))
    get_user_ip(id, admin_ip, charsmax(admin_ip), 1)

    replace_all(admin_nick, charsmax(admin_nick), "\", "\\")
    replace_all(admin_nick, charsmax(admin_nick), "'", "\'")

    if (!serverCmd)
    {
        get_user_authid(id, admin_steamid, charsmax(admin_steamid))
    }
    else
    {
        // If the server does the ban you cant get any steam_ID or team
        copy(admin_steamid, charsmax(admin_steamid), "")

        // This is so you can have a shorter name for the servers hostname.
        // Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad
        static servernick[100]
        get_pcvar_string(server_nick, servernick, charsmax(servernick))
        if (strlen(servernick))
            admin_nick = servernick
    }

    static server_name[100]
    get_cvar_string("hostname", server_name, charsmax(server_name))

    static ban_created
    ban_created = get_systime(0)

    replace_all(server_name, charsmax(server_name), "\", "\\")
    replace_all(server_name, charsmax(server_name), "'", "\'")

    static BanLength[50]
    num_to_str(iBanLength, BanLength, charsmax(BanLength))

    static mapname[32]
    get_mapname(mapname, charsmax(mapname))

    static query[512]
    formatex(query, charsmax(query), "INSERT INTO `%s` \
        (player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,\
        ban_reason,ban_created,ban_length,server_name,server_ip,map_name) \
        VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%i','%s','%s','%s:%s','%s')",
        tbl_bans, player_steamid, player_ip, player_nick, admin_ip, admin_steamid,
        admin_nick, g_ban_type, g_ban_reason, ban_created, BanLength, server_name,
        g_server_ip, g_server_port, mapname)

    static data[2]
    data[0] = id
    data[1] = player
    SQL_ThreadQuery(g_SqlX, "insert_bandetails", query, data, sizeof(data))

    announce_and_kick(id, player, iBanLength)

    return PLUGIN_HANDLED
}

public insert_bandetails(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id, player
    id = data[0]
    player = data[1]

    if (failstate)
    {
        colored_print(id, "^x04***^x01 Проблемы соединения с базой данных")
        g_being_banned[player] = false
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_INSERT_BANDETAILS)
    }
    else
    {
        static victim_name[32]
        get_user_name(player, victim_name, charsmax(victim_name))

        if (id != 0)
            colored_print(0, "^x04***^x03 %s^x01 забанен по причине^x04 %s", victim_name, g_ban_reason)
    }
    return PLUGIN_HANDLED
}

announce_and_kick(id, player, iBanLength)
{
    static bool:serverCmd
    serverCmd = false
    /* Determine if this was a server command or a command issued by a player in the game */
    if (id == 0)
        serverCmd = true

    static player_steamid[50], player_ip[30], player_nick[50]

    get_user_authid(player, player_steamid, charsmax(player_steamid))
    get_user_name(player, player_nick, charsmax(player_nick))
    get_user_ip(player, player_ip, charsmax(player_ip), 1)

    replace_all(player_nick, charsmax(player_nick), "\", "\\")
    replace_all(player_nick, charsmax(player_nick), "'", "\'")

    static admin_team[11], admin_steamid[50], admin_nick[100]
    get_user_team(id, admin_team, charsmax(admin_team))
    get_user_authid(id, admin_steamid, charsmax(admin_steamid))
    get_user_name(id, admin_nick, charsmax(admin_nick))

    replace_all(admin_nick, charsmax(admin_nick), "\", "\\")
    replace_all(admin_nick, charsmax(admin_nick), "'", "\'")

    static cTimeLengthPlayer[128]
    static cTimeLengthServer[128]

    if (iBanLength > 0)
    {
        get_time_length(player, iBanLength, timeunit_minutes, cTimeLengthPlayer, charsmax(cTimeLengthPlayer))
        get_time_length(0, iBanLength, timeunit_minutes, cTimeLengthServer, charsmax(cTimeLengthServer))
    }
    else //Permanent Ban
    {
        formatex(cTimeLengthPlayer, charsmax(cTimeLengthPlayer), "Permanent")
        formatex(cTimeLengthServer, charsmax(cTimeLengthServer), "Permanent")
    }

    if (player)
    {
        static complain_url[64]
        get_pcvar_string(complainurl, complain_url, charsmax(complain_url))

        client_print(player, print_console, "[GOZM] ===============================================")
        client_print(player, print_console, "[GOZM] Nick: '%s'", player_nick)
        client_print(player, print_console, "[GOZM] Ban time: '%s'", cTimeLengthPlayer)
        client_print(player, print_console, "[GOZM] Reason: '%s'", g_ban_reason)
        client_print(player, print_console, "[GOZM] IP: '%s'", player_ip)
        client_print(player, print_console, "[GOZM] SteamID: '%s'", player_steamid)
        client_print(player, print_console, "[GOZM] Banned by %s", admin_nick)
        client_print(player, print_console, "[GOZM] Unban: %s", complain_url)
        client_print(player, print_console, "[GOZM] ===============================================")
        client_print(player, print_console, "[GOZM] Demo: cstrike/go_zombie.dem")
        client_print(player, print_console, "[GOZM] ===============================================")

        set_task(kick_delay, "delayed_kick", TASKID_DELAYED_KICK + player, g_ban_reason, sizeof(g_ban_reason))
    }
    else /* The player was not found in server */
    {
        if (serverCmd)
            server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
        else
            console_print(id, "[AMXXBANS] The Player %s was not found",g_steamidorusername)

        return PLUGIN_HANDLED
    }

    if (equal(g_ban_type, "S"))
    {
        if (serverCmd)
            log_message("[GOZM]: SteamID '%s' successfully banned. Kicking...",player_steamid)
        else
            client_print(id, print_console,"[GOZM]: SteamID '%s' успешно забанен. Ща кикнет...",
                player_steamid)
    }
    else
    {
        if (serverCmd)
            log_message("[GOZM]: IP successfully banned. Kicking...")
        else
            client_print(id, print_console,"[GOZM]: IP успешно забанен. Ща кикнет...")
    }

    if (serverCmd)
    {
        /* If the server does the ban you cant get any steam_ID or team */
        copy(admin_steamid, charsmax(admin_steamid), "")
        copy(admin_team, charsmax(admin_team), "")
    }

    // Logs all bans by admins/server to amxx logs
    if (iBanLength > 0)
    {
        log_amx("[AMXBANS]: ^"%s^" ban ^"%s^" for %s. Reason: %s.",
            admin_nick, player_nick, cTimeLengthServer, g_ban_reason)
    }
    else
    {
        log_amx("[AMXBANS]: ^"%s^" ban ^"%s^" forever. Reason: %s.",
            admin_nick, player_nick, g_ban_reason)
    }
    return PLUGIN_HANDLED
}

/* ------------ UNBAN ---------------- */
/*
     This function will UnBan by steamID amx_unban <STEAMID or NICKNAME>
*/

public cmdUnBan(id, level, cid)
{
    if (!(get_user_flags(id) & level))
        return PLUGIN_HANDLED

    static steamid_or_nick[50]

    read_args(steamid_or_nick, charsmax(steamid_or_nick))
    trim(steamid_or_nick)

    static admin_name[32]
    get_user_name(id, admin_name, charsmax(admin_name))

    if (equal(steamid_or_nick, ""))
    {
        log_amx("[AMXBANS]: Empty steamid_or_nick")
        client_print(id, print_console, "Применение: amx_unban <steam_id или ник>")
        return PLUGIN_HANDLED
    }
    else if (equal(steamid_or_nick, "STEAM_ID_LAN"))
    {
        log_amx("[AMXBANS]: Can't unban STEAM_ID_LAN")
        colored_print(id, "^x04***^x01 Не могу разбанить STEAM_ID_LAN")
        return PLUGIN_HANDLED
    }
    // STEAM_ID
    else if (contain(steamid_or_nick, "STEAM_") != -1)
    {
        log_amx("[AMXBANS]: %s is unbanning by steam: %s", admin_name, steamid_or_nick)
        g_unban_player_steamid = steamid_or_nick

        static query[512]
        static data[1]
        formatex(query, charsmax(query), "SELECT \
            bid,ban_created,ban_length,ban_reason,admin_nick,admin_id, \
            player_nick,player_ip,player_id,ban_type,server_ip,server_name \
            FROM `%s` WHERE player_id='%s'",
            tbl_bans, g_unban_player_steamid)

        data[0] = id
        SQL_ThreadQuery(g_SqlX, "cmd_unban_select", query, data, sizeof(data))

        return PLUGIN_HANDLED
    }
    // nick
    else
    {
        log_amx("[AMXBANS]: %s is unbanning by nick: %s", admin_name, steamid_or_nick)
        g_player_nick = steamid_or_nick

        static query[512]
        static data[1]

        replace_all(steamid_or_nick, charsmax(steamid_or_nick), "\", "\\")
        replace_all(steamid_or_nick, charsmax(steamid_or_nick), "'", "\'")

        formatex(query, charsmax(query), "SELECT \
            bid, player_nick, admin_nick \
            FROM `%s` WHERE player_nick LIKE '%%%s%%' LIMIT %d",
            tbl_bans, steamid_or_nick, MAX_UNBAN_OPTIONS + 1)

        data[0] = id
        SQL_ThreadQuery(g_SqlX, "cmd_unban_by_nick", query, data, sizeof(data))

        return PLUGIN_HANDLED
    }
}

public cmd_unban_by_nick(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_UNBAN_BY_NICK)
    }
    else
    {
        static res_count
        res_count = SQL_NumResults(query)
        if (!res_count)
        {
            log_amx("[AMXBANS]: Player with that part of nickname is NOT found in bans")
            colored_print(id, "^x04***^x01 Такой ник (или часть) не найден в списке банов:^x04 %s",
                g_player_nick)
            return PLUGIN_HANDLED
        }
        else if (res_count <= MAX_UNBAN_OPTIONS)
        {
            static i_Menu, c
            i_Menu = menu_create("\yМеню разбана:", "unban_menu_handler")
            log_amx("[AMXBANS]: Found %d results", res_count)

            for (c = 1; c <= res_count; c++)
            {
                static player_name[64], admin_name[32], i_player_bid, s_player_bid[6]

                SQL_ReadResult(query, column("player_nick"), player_name, charsmax(player_name))
                SQL_ReadResult(query, column("admin_nick"), admin_name, charsmax(admin_name))
                i_player_bid = SQL_ReadResult(query, column("bid"))

                formatex(player_name, charsmax(player_name), "%s (\y%s\w)", player_name, admin_name)
                num_to_str(i_player_bid, s_player_bid, charsmax(s_player_bid))
                menu_additem(i_Menu, player_name, s_player_bid)

                SQL_NextRow(query)
            }

            menu_setprop(i_Menu, MPROP_BACKNAME, "Назад")
            menu_setprop(i_Menu, MPROP_NEXTNAME, "Дальше")
            menu_setprop(i_Menu, MPROP_EXITNAME, "Выход")

            menu_display(id, i_Menu, 0)
            return PLUGIN_HANDLED
        }
        else
        {
            log_amx("[AMXBANS]: Too many: %d on %s", res_count, g_player_nick)
            colored_print(id, "^x04***^x01 Много совпадений, уточни ник:^x04 %s", g_player_nick)
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

    static s_Bid[6], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Bid, charsmax(s_Bid), s_Name, charsmax(s_Name), i_Callback)

    static query[512]
    static data[1]
    formatex(query, charsmax(query), "SELECT \
        bid,ban_created,ban_length,ban_reason,admin_nick,admin_id, \
        player_nick,player_ip,player_id,ban_type,server_ip,server_name \
        FROM `%s` WHERE bid=%d",
        tbl_bans, str_to_num(s_Bid))

    data[0] = id
    SQL_ThreadQuery(g_SqlX, "cmd_unban_select", query, data, sizeof(data))

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public cmd_unban_select(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id, bool:serverCmd
    id = data[0]
    serverCmd = false

    // Determine if this was a server command or a command issued by a player in the game
    if (id == 0)
    	serverCmd = true

    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_UNBAN_SELECT)
    }
    else
    {
        if (!SQL_NumResults(query))
        {
            log_amx("[AMXBANS]: Can't find nick in database database")
            colored_print(id, "^x04***^x01 Не могу найти запрошенный ник в базе!")
            return PLUGIN_HANDLED
        }
        else
        {
            static ban_created[50], ban_length[50], ban_reason[64], admin_nick[100]
            static player_ip[30],player_steamid[50], ban_type[10], server_ip[30], server_name[100]

            static bid
            bid = SQL_ReadResult(query, 0)
            SQL_ReadResult(query, 1, ban_created, charsmax(ban_created))
            SQL_ReadResult(query, 2, ban_length, charsmax(ban_length))
            SQL_ReadResult(query, 3, ban_reason, charsmax(ban_reason))
            SQL_ReadResult(query, 4, admin_nick, charsmax(admin_nick))
            SQL_ReadResult(query, 5, g_admin_steamid, charsmax(g_admin_steamid))
            SQL_ReadResult(query, 6, g_player_nick, charsmax(g_player_nick))
            SQL_ReadResult(query, 7, player_ip, charsmax(player_ip))
            SQL_ReadResult(query, 8, player_steamid, charsmax(player_steamid))
            SQL_ReadResult(query, 9, ban_type, charsmax(ban_type))
            SQL_ReadResult(query, 10, server_ip, charsmax(server_ip))
            SQL_ReadResult(query, 11, server_name, charsmax(server_name))

            //// MINE
            static unbanning_nick[50]
            get_user_name(id, unbanning_nick, charsmax(unbanning_nick))
            trim(unbanning_nick)

            if (!equal(unbanning_nick, admin_nick) && !has_admin(id))
            {
                log_amx("[AMXBANS]: NOT YOUR BAN: VIP'%s' vs ADM'%s'", unbanning_nick, admin_nick)
                colored_print(id, "^x04***^x01 Игрок забанен випом^x04 %s", admin_nick)
                return PLUGIN_HANDLED
            }

            server_cmd("removeip %s", player_ip)
            static sub_query[512]
            static banned_player_name[50]
            formatex(banned_player_name, charsmax(banned_player_name), "%s", g_player_nick)

            replace_all(banned_player_name, charsmax(banned_player_name), "\", "\\")
            replace_all(banned_player_name, charsmax(banned_player_name), "'", "\'")

            formatex(sub_query, charsmax(sub_query), "\
                UPDATE `superban` \
                SET unbantime = -1 \
                WHERE BINARY banname = '%s' and admin = '%s'",
                banned_player_name, admin_nick)
            SQL_ThreadQuery(g_SqlX, "cmd_delete_superban", sub_query)

            client_print(id,print_console," ")
            client_print(id,print_console,"[GOZM] =================")
            client_print(id,print_console,"[GOZM] BanID: '%s', Nick: '%s'", bid, g_player_nick)
            client_print(id,print_console,"[GOZM] Ban for '%s'['%s'], Reason: '%s'",
                admin_nick, g_admin_steamid, ban_reason)
            client_print(id,print_console,"[GOZM] =================")
            client_print(id,print_console," ")

            static unban_admin_steamid[32]
            if (!serverCmd)
            {
                get_user_authid(id, unban_admin_steamid, charsmax(unban_admin_steamid))
                get_user_team(id, g_unban_admin_team, charsmax(g_unban_admin_team))
                get_user_name(id, g_unban_admin_nick, charsmax(g_unban_admin_nick))
            }
            else
            {
                /* If the server does the ban you cant get any steam_ID or team */
                copy(unban_admin_steamid, charsmax(unban_admin_steamid), "")
                copy(g_unban_admin_team, charsmax(g_unban_admin_team), "")

                /* This is so you can have a shorter name for the servers hostname.
                Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad */
                static servernick[100]
                get_pcvar_string(server_nick, servernick, charsmax(servernick))
                if (strlen(servernick))
                    formatex(g_unban_admin_nick, charsmax(g_unban_admin_nick), "%s", servernick)
                else
                    get_cvar_string("hostname", g_unban_admin_nick, charsmax(g_unban_admin_nick))
            }

            static unban_created
            unban_created = get_systime(0)

            static query[512]
            formatex(query, charsmax(query), "INSERT INTO `%s` \
                (player_id,player_ip,player_nick,admin_id,admin_nick,ban_type,\
                ban_reason,ban_created,ban_length,server_ip,server_name,\
                unban_created,unban_reason,unban_admin_nick) \
                VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%i','UnBanned in Game','%s %s')",
                tbl_banhist,g_unban_player_steamid,player_ip,banned_player_name,
                g_admin_steamid,admin_nick,ban_type,ban_reason,ban_created,
                ban_length,server_ip,server_name,unban_created, g_unban_admin_nick,
                unban_admin_steamid)

            static data[2]
            data[0] = id
            data[1] = bid
            SQL_ThreadQuery(g_SqlX, "cmd_unban_insert", query, data, sizeof(data))
        }
    }
    return PLUGIN_HANDLED
}

public cmd_delete_superban(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_DELETE_SUPERBAN)
    }
    else
    {
        static affected_rows
        affected_rows = SQL_AffectedRows(query)
        log_amx("[SuperBan]: Deleted rows: %d", affected_rows)
    }

    return PLUGIN_HANDLED
}

public cmd_unban_insert(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id, bid
    id = data[0]
    bid = data[1]

    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_UNBAN_INSERT)
    }
    else
    {
        static query[512]
        static data[1]

        formatex(query, charsmax(query), "DELETE FROM `%s` WHERE bid=%d", tbl_bans, bid)

        data[0] = id
        SQL_ThreadQuery(g_SqlX, "cmd_unban_delete_and_print", query, data, sizeof(data))
    }
    return PLUGIN_HANDLED
}

public cmd_unban_delete_and_print(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_UNBAN_PRINT)
    }
    else
    {
        log_amx("[AMXBANS]: %s successfully unbanned %s", g_unban_admin_nick, g_player_nick)

        client_print(id,print_console," ")
        client_print(id,print_console,"[GOZM] =================")
        client_print(id,print_console,"'%s' is unbanned", g_player_nick)
        client_print(id,print_console,"[GOZM] =================")
        client_print(id,print_console," ")

        colored_print(id, "^x04***^x01 Игрок успешно разбанен:^x04 %s", g_player_nick)
    }

    return PLUGIN_HANDLED
}

/* ------------- CHECK PLAYER ------------*/
public check_player(id)
{
    static player_steamid[32], player_ip[20]
    get_user_authid(id, player_steamid, charsmax(player_steamid))
    get_user_ip(id, player_ip, charsmax(player_ip), 1)

    static query[512]
    static data[1]

    if (equal(player_steamid, "BOT"))
        return PLUGIN_HANDLED

    if (equal(player_steamid, "STEAM_ID_LAN") || equal(player_steamid, ""))
        formatex(query, charsmax(query), "\
        SELECT \
            bid, ban_created, ban_length, \
            ban_reason, admin_nick, admin_id, \
            admin_ip, player_nick, player_id, \
            player_ip, server_name, server_ip, \
            ban_type, map_name \
        FROM `%s` WHERE player_ip='%s'\
        ",tbl_bans, player_ip)
    else
        formatex(query, charsmax(query), "\
        SELECT \
            bid, ban_created, ban_length,\
            ban_reason, admin_nick, admin_id, \
            admin_ip, player_nick, player_id, \
            player_ip, server_name, server_ip, \
            ban_type, map_name \
        FROM `%s` WHERE player_id='%s' OR player_ip='%s'\
        ",tbl_bans, player_steamid, player_ip)

    data[0] = id
    SQL_ThreadQuery(g_SqlX, "check_player_", query, data, sizeof(data))

    return PLUGIN_HANDLED
}

public check_player_(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    static id
    id = data[0]

    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_CHECK_PLAYER)
    }
    else
    {
        if (!SQL_NumResults(query))
        {
        	return PLUGIN_HANDLED
        }
        else
        {
            static ban_length[50], ban_reason[255], admin_nick[100],admin_steamid[50],admin_ip[30],ban_type[4]
            static player_nick[50], player_steamid[50], player_ip[30], server_name[100], server_ip[30]
            static map_name[32]

            static bid, ban_created, current_time_int, ban_length_int
            bid = SQL_ReadResult(query, 0)
            ban_created = SQL_ReadResult(query, 1)
            SQL_ReadResult(query, 2, ban_length, charsmax(ban_length))
            SQL_ReadResult(query, 3, ban_reason, charsmax(ban_reason))
            SQL_ReadResult(query, 4, admin_nick, charsmax(admin_nick))
            SQL_ReadResult(query, 5, admin_steamid, charsmax(admin_steamid))
            SQL_ReadResult(query, 6, admin_ip, charsmax(admin_ip))
            SQL_ReadResult(query, 7, player_nick, charsmax(player_nick))
            SQL_ReadResult(query, 8, player_steamid, charsmax(player_steamid))
            SQL_ReadResult(query, 9, player_ip, charsmax(player_ip))
            SQL_ReadResult(query, 10, server_name, charsmax(server_name))
            SQL_ReadResult(query, 11, server_ip, charsmax(server_ip))
            SQL_ReadResult(query, 12, ban_type, charsmax(ban_type))
            SQL_ReadResult(query, 13, map_name, charsmax(map_name))

            current_time_int = get_systime(0)
            ban_length_int = str_to_num(ban_length) * 60 // in secs

            // A ban was found for the connecting player!! Lets see how long it is or if it has expired
            if ((ban_length_int == 0) || (ban_created ==0) || (ban_created+ban_length_int > current_time_int))
            {
                static complain_url[256]
                get_pcvar_string(complainurl, complain_url, charsmax(complain_url))

                static cTimeLength[128]
                static iSecondsLeft
                iSecondsLeft = (ban_created + ban_length_int - current_time_int)
                get_time_length(id, iSecondsLeft, timeunit_seconds, cTimeLength, charsmax(cTimeLength))

                client_cmd(id, "echo [GOZM]: ===============================================")
                client_cmd(id, "echo [GOZM]: Nick: %s", player_nick)
                client_cmd(id, "echo [GOZM]: Ban left in %s", cTimeLength)
                client_cmd(id, "echo [GOZM]: Reason: '%s'", ban_reason)
                client_cmd(id, "echo [GOZM]: IP: '%s'", player_ip)
                client_cmd(id, "echo [GOZM]: SteamID: '%s'", player_steamid)
                client_cmd(id, "echo [GOZM]: Banned by %s", admin_nick)
                client_cmd(id, "echo [GOZM]: Unban: %s", complain_url)
                client_cmd(id, "echo [GOZM]: ===============================================")
                client_cmd(id, "echo [GOZM]: Demo: cstrike/go_zombie.dem")
                client_cmd(id, "echo [GOZM]: ===============================================")

                set_task(3.5, "delayed_kick", TASKID_DELAYED_KICK + id, ban_reason, sizeof(ban_reason))
                return PLUGIN_HANDLED
            }
            else // The ban has expired
            {
                static has_name[32]
                get_user_name(id, has_name, charsmax(has_name))
                client_cmd(id, "echo [GOZM]: Ban expired...")

                static unban_created
                unban_created = get_systime(0)

                //make sure there are no single quotes in these 4 vars
                replace_all(player_nick, charsmax(player_nick), "\", "")
                replace_all(player_nick, charsmax(player_nick), "'", "ґ")

                replace_all(admin_nick, charsmax(admin_nick), "\", "")
                replace_all(admin_nick, charsmax(admin_nick), "'", "ґ")

                replace_all(ban_reason, charsmax(ban_reason), "\", "")
                replace_all(ban_reason, charsmax(ban_reason), "'", "ґ")

                replace_all(server_name, charsmax(server_name), "\", "")
                replace_all(server_name, charsmax(server_name), "'", "ґ")

                // INSERT INTO BANHISTORY
                static insert_query[512]
                formatex(insert_query, charsmax(insert_query),
                    "INSERT INTO `%s` ( \
                        player_id, player_ip, player_nick, \
                        admin_id, admin_nick, admin_ip, \
                        ban_type, ban_reason, ban_created, \
                        ban_length, server_ip, unban_created, \
                        unban_reason, unban_admin_nick, map_name) \
                    VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%d','%s','%s','%i',\
                        'Bantime expired','amxbans','%s')\
                    ",
                    tbl_banhist,
                    player_steamid, player_ip, player_nick,
                    admin_steamid, admin_nick, admin_ip,
                    ban_type, ban_reason, ban_created,
                    ban_length, server_ip, unban_created,
                    map_name)
                SQL_ThreadQuery(g_SqlX, "insert_to_banhistory", insert_query)

                // DELETE EXPIRED BAN
                static delete_query[512]
                formatex(delete_query, charsmax(delete_query),"DELETE FROM `%s` WHERE bid='%d'",tbl_bans, bid)
                SQL_ThreadQuery(g_SqlX, "delete_expired_ban", delete_query)
            }
        }
    }
    return PLUGIN_HANDLED
}

public insert_to_banhistory(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_INSERT_BANHISTORY)
    }
    return PLUGIN_HANDLED
}

public delete_expired_ban(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_DELETE_EXPIRED)
    }
    return PLUGIN_HANDLED
}

/* ------------ INIT FUNCTIONS -----------*/
/************  Start fetch reasons  *****************/
public fetchReasons(id)
{
    static query[512]
    static data[1]
    formatex(query, charsmax(query), "SELECT reason FROM %s", tbl_reasons)
    data[0] = id
    SQL_ThreadQuery(g_SqlX, "fetchReasons_", query, data, sizeof(data))
}

public fetchReasons_(failstate, Handle:query, error[], errnum, data[], size, Float:querytime)
{
    if (failstate)
    {
        static szQuery[512]
        SQL_GetQueryString(query, szQuery, charsmax(szQuery))
        MySqlX_ThreadError(szQuery, error, errnum, failstate, floatround(querytime), ID_FETCH_REASONS)
    }
    else
    {
        if (!SQL_NumResults(query))
        {
            formatex(g_banReasons[0], charsmax(g_banReasons[]), "Wallhack")
            formatex(g_banReasons[1], charsmax(g_banReasons[]), "Speedhack")
            formatex(g_banReasons[2], charsmax(g_banReasons[]), "Mat")
            formatex(g_banReasons[3], charsmax(g_banReasons[]), "Block")
            formatex(g_banReasons[4], charsmax(g_banReasons[]), "Noob")
            formatex(g_banReasons[5], charsmax(g_banReasons[]), "Reconnect")
            formatex(g_banReasons[6], charsmax(g_banReasons[]), "Obxod")

            log_amx("[AMXBANS]: Static reasons loaded")

            g_aNum = 7

            return PLUGIN_HANDLED
        }
        else
        {
            g_aNum = 0
            while(SQL_MoreResults(query))
            {
                SQL_ReadResult(query, 0, g_banReasons[g_aNum], charsmax(g_banReasons[]))
                SQL_NextRow(query)
                g_aNum++
            }
        }
    }

    return PLUGIN_HANDLED
}

/* ---------------- MENUS --------------- */
displayBanMenu(id,pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id],g_menuPlayersNum[id])

    static menuBody[512], name[32]
    static a, b, i, len, start, end, keys
    b = 0
    start = pos * 7

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
        g_coloredMenus ? "\yКого забаним?\R%d/%d^n\w^n" : "Кого забаним? %d/%d^n^n", pos+1,
        (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))

    end = start + 7
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]


    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (has_vip(i))
        {
            ++b
            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody) - len,"\d%d. %s\w^n", b, name)
            else
                len += format(menuBody[len], charsmax(menuBody) - len,"#. %s^n", name)

        }
        else
        {
            keys |= (1<<b)
            if (has_vip(i))
                len += format(menuBody[len],
                    charsmax(menuBody) - len, g_coloredMenus ? "\w%d. %s \r* \w^n" : "%d. %s *^n", ++b, name)
            else
                len += format(menuBody[len],
                    charsmax(menuBody) - len, g_coloredMenus ? "\w%d. %s \r \w^n" : "%d. %s^n", ++b, name)
        }
    }

    static iBanLength
    iBanLength = g_menuSettings[id]
    static cTimeLength[128]
    if (iBanLength == 0)
        len += format(menuBody[len], charsmax(menuBody) - len, g_coloredMenus ? "\w^n8. Навсегда^n" : "^n8. Навсегда^n")
    else
    {
        get_time_length(id, iBanLength, timeunit_minutes, cTimeLength, charsmax(cTimeLength))

        len += format(menuBody[len], charsmax(menuBody) - len,
            g_coloredMenus ? "\w^n8. На %s^n" : "^n8. На %s^n", cTimeLength)
    }

    if (end != g_menuPlayersNum[id])
    {
        len += format(menuBody[len], charsmax(menuBody) - len,"^n9. %s...^n0. Выход", pos ? "Назад" : "Дальше")
        keys |= MENU_KEY_9
    }
    else
        len += format(menuBody[len], charsmax(menuBody) - len,"^n0. %s", pos ? "Назад" : "Выход")

    show_menu(id, keys, menuBody, -1 , "Ban Menu")
}

public actionBanMenu(id,key)
{
    switch (key)
    {
        case 7:
        {
            ++g_menuOption[id]
            g_menuOption[id] %= g_bantimesnum

            static i
            for (i = 0; i < g_bantimesnum; i++)
            {
                if (g_menuOption[id] == i)
                    g_menuSettings[id] = g_BanMenuValues[i]
                else if (g_menuOption[id] == -1)
                    g_menuSettings[id] = -1
            }

            displayBanMenu(id, g_menuPosition[id])
        }

        case 8: displayBanMenu(id, ++g_menuPosition[id])
        case 9: displayBanMenu(id, --g_menuPosition[id])

        default:
        {
            g_bannedPlayer = g_menuPlayers[id][g_menuPosition[id] * 7 + key]
            displayBanMenuReason(id)
        }
    }
    return PLUGIN_HANDLED
}

public cmdBanMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    g_menuSettings[id] = g_BanMenuValues[0]   // This is the first menu option that is used
    displayBanMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

/* Here comes the reason menu */
public actionBanMenuReason(id,key)
{
    switch (key)
    {
        case 9: // go back to ban menu
        {
            displayBanMenu(id, g_menuPosition[id])
        }
        case 7:
        {
            g_inCustomReason[id] = 1
            client_cmd(id, "messagemode amxbans_custombanreason")
            return PLUGIN_HANDLED
        }
        case 8:
        {
            banUser(id, g_lastCustom[id])
        }
        default:
        {
            banUser(id, g_banReasons[key])
        }
    }
    displayBanMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

// cmdBanReasonMenu(id)
displayBanMenuReason(id)
{
    static menuBody[1024], len, i, keys
    len = formatex(menuBody, charsmax(menuBody), g_coloredMenus ? "\y%s\R^n\w^n" : "%s^n^n", "Причина")
    i = 0

    while (i < g_aNum)
    {
        if (strlen(g_banReasons[i])) // Checks if there is a reason text
            len+=format(menuBody[len], charsmax(menuBody) - len, "%d. %s^n",i+1,g_banReasons[i])

        i++
    }

    len += format(menuBody[len], charsmax(menuBody) - len, "^n8. Своя^n")
    if (g_lastCustom[id][0] != '^0')
        len += format(menuBody[len], charsmax(menuBody) - len, "^n9. %s^n", g_lastCustom[id])

    len += format(menuBody[len], charsmax(menuBody) - len, "^n0. %s^n", "Выход")

    keys = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_0

    if (g_lastCustom[id][0] != '^0')
        keys |= MENU_KEY_9

    show_menu(id, keys, menuBody, -1, "Ban Reason Menu")
}

/* This function only sets the custom ban reason */
public setCustomBanReason(id,level,cid)
{
    if (!cmd_access(id,level,cid,1))
    {
        return PLUGIN_HANDLED
    }

    static szReason[128]
    read_argv(1, szReason, charsmax(szReason))
    copy(g_lastCustom[id], charsmax(g_lastCustom[]), szReason)

    if (g_inCustomReason[id])
    {
        g_inCustomReason[id] = 0
        banUser(id, g_lastCustom[id])
    }

    return PLUGIN_HANDLED
}


/* id is the player banning, not player being banned :] */
banUser(id, banReason[])
{
    static player
    player = g_bannedPlayer
    static ip[16]
    get_user_ip(player, ip, charsmax(ip), 1)
    console_cmd(id, "amx_ban %d %s %s", g_menuSettings[id], ip, banReason)
}


/*************************************************************

   Check banhistory menu

*************************************************************/

public cmdBanhistoryMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    displayBanhistoryMenu(id, g_menuPosition[id] = 0)
    return PLUGIN_HANDLED
}

displayBanhistoryMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], name[32]
    static a, b, i, len, start, end, keys

    b = 0
    start = pos * 8

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
        g_coloredMenus ? "\yИстория банов\R%d/%d^n\w^n" : "История банов %d/%d^n^n",
        pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
    end = start + 8
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        keys |= (1<<b)
        if (has_vip(i))
           len += format(menuBody[len],
                charsmax(menuBody) - len, g_coloredMenus ? "%d. %s \r*\w^n" : "%d. %s *   %s^n", ++b, name)
        else
            len += format(menuBody[len],
                charsmax(menuBody) - len, g_coloredMenus ? "%d. %s\w^n" : "%d. %s   %s^n", ++b, name)
    }
    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody) - len, "^n9. %s...^n0. Выход", pos ? "Назад" : "Дальше")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody) - len, "^n0. %s", pos ? "Назад" : "Выход")

    show_menu(id, keys, menuBody, -1, "Banhistory Menu")
}

public actionBanhistoryMenu(id, key)
{
    switch (key)
    {
        case 8: displayBanhistoryMenu(id, ++g_menuPosition[id])
        case 9: displayBanhistoryMenu(id, --g_menuPosition[id])
        default:
        {
            static authid[32]
            static player
            player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]

            static banhistMOTD_url[256], msg[2048]
            static player_ip[20]
            get_user_authid(player, authid, charsmax(authid))
            get_user_ip(player, player_ip, charsmax(player_ip), 1)

            get_pcvar_string(banhistmotd_url, banhistMOTD_url, charsmax(banhistMOTD_url))
            formatex(msg, charsmax(msg), banhistMOTD_url, authid, player_ip)

            show_motd(id, msg, "Banhistory")
            displayBanhistoryMenu(id, g_menuPosition[id])
        }
    }
    return PLUGIN_HANDLED
}

/*********  Error handler  *********/
MySqlX_ThreadError(szQuery[], error[], errnum, failstate, req_time, id)
{
    if (failstate == TQUERY_CONNECT_FAILED)
    {
        log_amx("[AMXBANS]: Connect failed!")
    }
    else if (failstate == TQUERY_QUERY_FAILED)
    {
        log_amx("[AMXBANS]: Query failed!")
    }
    log_amx("[AMXBANS]: Error id: %d", id)
    log_amx("[AMXBANS]: Error message: %s (%d)", error, errnum)
    log_amx("[AMXBANS]: Query: %ds to '%s'", req_time, szQuery)
}

public plugin_end()
{
    SQL_FreeHandle(g_SqlX)
}
