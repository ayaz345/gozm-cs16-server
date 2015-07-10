#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#pragma semicolon 1
#pragma ctrlchar '\'

#pragma dynamic 32768

#define __PLUGIN_VERSION__  "1.2"

#define LOG_FOLDER          "SB"

enum {
    TASK_LOADCFG = 13980
}

new BannedReasons[33][256];

new g_menuPosition[33];
new g_menuPlayers[33][32];
new g_menuPlayersNum[33];
new g_menuOption[33];
new g_menuSettings[33];
new g_coloredMenus;

new Array:g_bantimes;
new Config[128];
new UserUIDs[33][32];

new Handle:g_h_Sql;

new g_szLogFile[64];
new SelectedID[33];
new SelectedTime[33];
new s_DB_Table[64];
new TimeGap = 0;

new pcvar_prefix1;
new pcvar_prefix2;
new pcvar_comment;

new g_Prefix[32];
new g_Comment[256];

new pcvar_ipban, pcvar_nameban, pcvar_lnameban, pcvar_steamban, pcvar_subnetban, pcvar_banurl,
    pcvar_checkurl, pcvar_hide, pcvar_log, pcvar_iptime, pcvar_nametime, pcvar_cookieban,
    pcvar_messages, pcvar_cookiewait, pcvar_config, pcvar_autoclear, pcvar_periods,
    pcvar_unbanflag, pcvar_sqltime, pcvar_utf8, pcvar_hideadmin;

new pcvar_chatprefix, pcvar_chatcolor, pcvar_motd, pcvar_kicktime;
//new pcvar_timetype;

new g_ChatPrefix[64], g_ChatPrefixColor[64];

new g_UseTimeMenu = false;

new g_maxplayers;

locate_players(identifier[], players[32], &players_num)
{
    static player, id;
    player = find_player("c", identifier);

    if (!player)
    {
        static szName[32];

        players_num = 0;
        for (id = 1; id <= g_maxplayers; id++)
        {
            if (is_user_connected(id))
            {
                get_user_name(id, szName, charsmax(szName));

                if (containi(szName, identifier) != -1)
                    players[players_num++] = id;
            }
        }

        if (players_num > 0)
            return;
    }

    if (!player && strfind(identifier, ".") != -1)
    {
        player = find_player("d", identifier);
    }

    if (!player && identifier[0] == '#' && identifier[1])
    {
        player = find_player("k", str_to_num(identifier[1]));
    }

    players[0] = player;
    players_num = player > 0 ? 1 : 0;
}

convert_period(id, sec)
{
    static result[64];
    static seconds, minutes, hours, days, months, years;

    if (sec <= 0)
    {
        formatex(result, charsmax(result), "%L", id, "SUPERBAN_PERMANENT");
    }
    if (sec < 60 && sec > 0)
    {
        seconds = floatround(float(sec), floatround_floor);
        formatex(result, charsmax(result), "%d %L", seconds, id, "SUPERBAN_SHORT_SECONDS");
    }
    if (sec > 59 && sec < 3600)
    {
        minutes = floatround(float(sec) / 60, floatround_floor);
        seconds = sec % 60;
        if (seconds)
        {
            formatex(result, charsmax(result), "%d %L %d %L", minutes, id, "SUPERBAN_SHORT_MINUTES", seconds, id, "SUPERBAN_SHORT_SECONDS");
        }
        else
            formatex(result, charsmax(result), "%d %L", minutes, id, "SUPERBAN_SHORT_MINUTES");
    }
    if (sec > 3599 && sec < 86400)
    {
        hours = floatround(float(sec) / 3600, floatround_floor);
        minutes = floatround(float(sec % 3600) / 60, floatround_floor);
        if (minutes)
        {
            formatex(result, charsmax(result), "%d %L %d %L", hours, id, (hours > 1 ? (hours < 5 ? "SUPERBAN_SHORT_HOURF" : "SUPERBAN_SHORT_HOURS") : "SUPERBAN_SHORT_HOUR"), minutes, id, "SUPERBAN_SHORT_MINUTES");
        }
        else
            formatex(result, charsmax(result), "%d %L", hours, id, (hours > 1 ? (hours < 5 ? "SUPERBAN_SHORT_HOURF" : "SUPERBAN_SHORT_HOURS") : "SUPERBAN_SHORT_HOUR"));
    }
    if (sec > 86399 && sec < 2592000)
    {
        days = floatround(float(sec) / 86400, floatround_floor);
        hours = floatround(float(sec % 86400) / 3600, floatround_floor);
        if (hours)
        {
            formatex(result, charsmax(result), "%d %L %d %L", days, id, (days > 1 ? (days < 5 ? "SUPERBAN_SHORT_DAYF" : "SUPERBAN_SHORT_DAYS") : "SUPERBAN_SHORT_DAY"), hours, id, (hours > 1 ? (hours < 5 ? "SUPERBAN_SHORT_HOURF" : "SUPERBAN_SHORT_HOURS") : "SUPERBAN_SHORT_HOUR"));
        }
        else
            formatex(result, charsmax(result), "%d %L", days, id, (days > 1 ? (days < 5 ? "SUPERBAN_SHORT_DAYF" : "SUPERBAN_SHORT_DAYS") : "SUPERBAN_SHORT_DAY"));
    }
    if (sec > 2591999 && sec < 31536000)
    {
        months = floatround(float(sec) / 2592000, floatround_floor);
        days = floatround(float(sec % 2592000) / 86400, floatround_floor);
        if (days)
        {
            formatex(result, charsmax(result), "%d %L %d %L", months, id, (months > 1 ? "SUPERBAN_SHORT_MONTHS" : "SUPERBAN_SHORT_MONTH"), days, id, (days > 1 ? (days < 5 ? "SUPERBAN_SHORT_DAYF" : "SUPERBAN_SHORT_DAYS") : "SUPERBAN_SHORT_DAY"));
        }
        else
            formatex(result, charsmax(result), "%d %L", months, id, (months > 1 ? "SUPERBAN_SHORT_MONTHS" : "SUPERBAN_SHORT_MONTH"));
    }
    if (sec > 31535999)
    {
        years = floatround(float(sec) / 31536000, floatround_floor);
        months = floatround(float(sec % 31536000) / 2592000, floatround_floor);
        if (months)
        {
            formatex(result, charsmax(result), "%d %L %d %L", years, id, (years > 1 ? "SUPERBAN_SHORT_YEARS" : "SUPERBAN_SHORT_YEAR"), months, id, (months > 1 ? "SUPERBAN_SHORT_MONTHS" : "SUPERBAN_SHORT_MONTH"));
        }
        else
            formatex(result, charsmax(result), "%d %L", years, id, (years > 1 ? "SUPERBAN_SHORT_YEARS" : "SUPERBAN_SHORT_YEAR"));
    }
    return result;
}

ExplodeString(p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter)
{
    static nIdx, l, nLen;
    nIdx = 0;
    l = strlen(p_szInput);
    nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter ));
    while( (nLen < l) && (++nIdx < p_nMax) )
        nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter ));
    return nIdx;
}

public plugin_init()
{
    register_plugin("SuperBan QM", __PLUGIN_VERSION__, "Lukmanov Ildar & Quckly");

    new configsDir[64];
    get_configsdir(configsDir, charsmax(configsDir));
    server_cmd("exec %s/superban.cfg", configsDir);
    get_localinfo("amx_logdir", g_szLogFile, charsmax(g_szLogFile));
    format(g_szLogFile, charsmax(g_szLogFile), "%s/%s", g_szLogFile, LOG_FOLDER);
    if (!dir_exists(g_szLogFile))
    {
        mkdir(g_szLogFile);
    }

    new szTime[32];
    get_time("SB%Y%m%d", szTime, charsmax(szTime));
    format(g_szLogFile, charsmax(g_szLogFile), "%s/%s.log", g_szLogFile, szTime);

    g_maxplayers = get_maxplayers();

    register_dictionary("superban.txt");

    register_cvar("q_sb_version", "SuperBan Q", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY|FCVAR_UNLOGGED);

    pcvar_ipban = register_cvar("amx_superban_ipban", "1");
    pcvar_nameban = register_cvar("amx_superban_nameban", "1");
    pcvar_lnameban = register_cvar("amx_superban_lnameban", "0");
    pcvar_steamban = register_cvar("amx_superban_steamban", "1");
    pcvar_subnetban = register_cvar("amx_superban_subnetban", "0");
    pcvar_banurl = register_cvar("amx_superban_banurl", "");
    pcvar_checkurl = register_cvar("amx_superban_checkurl", "");
    pcvar_hide = register_cvar("amx_superban_hide", "0");
    pcvar_log = register_cvar("amx_superban_log", "1");
    pcvar_iptime = register_cvar("amx_superban_iptime", "1440");
    pcvar_nametime = register_cvar("amx_superban_nametime", "1440");
    pcvar_cookieban = register_cvar("amx_superban_cookieban", "0");
    pcvar_messages = register_cvar("amx_superban_messages", "1");
    pcvar_cookiewait = register_cvar("amx_superban_cookiewait", "3.0");
    pcvar_config = register_cvar("amx_superban_config", "joystick");
    pcvar_autoclear = register_cvar("amx_superban_autoclear", "0");
    pcvar_periods = register_cvar("amx_superban_periods", "5,10,15,30,45,60,120,180,720,1440,10080,43200,525600,0");
    pcvar_unbanflag = register_cvar("amx_superban_unbanflag", "d");
    pcvar_sqltime = register_cvar("amx_superban_sqltime", "1");
    pcvar_utf8 = register_cvar("amx_superban_utf8", "1");
    pcvar_hideadmin = register_cvar("amx_superban_hideadmin", "0");

    pcvar_prefix1 = register_cvar("amx_superban_prefix1", "0");
    pcvar_prefix2 = register_cvar("amx_superban_prefix2", "4");
    pcvar_comment = register_cvar("amx_superban_comment", "");

    pcvar_chatprefix = register_cvar("q_sb_chatprefix", "^n[^gSUPERBAN^n] ");
    pcvar_chatcolor = register_cvar("q_sb_chatcolor", "1");
    pcvar_motd = register_cvar("q_sb_showmotd", "1");
    pcvar_kicktime = register_cvar("q_sb_delaykick", "10.0");
//  pcvar_timetype = register_cvar("q_sb_timetype", "0");

    register_clcmd("Reason", "Cmd_SuperbanReason", ADMIN_BAN, "");

    register_cvar("amx_superban_host", "127.0.0.1");
    register_cvar("amx_superban_user", "root");
    register_cvar("amx_superban_pass", "");
    register_cvar("amx_superban_db", "amx");
    register_cvar("amx_superban_table", "superban");

    register_menucmd(register_menuid("SBMENU", 0), 1023, "actionBanMenu");

    register_concmd("amx_superban", "SuperBan", ADMIN_BAN, "<name or #userid> <minutes> [reason]");
    register_concmd("amx_ban", "SuperBan", ADMIN_BAN, "<name or #userid> <minutes> [reason]");
    register_concmd("amx_banip", "SuperBan", ADMIN_BAN, "<name or #userid> <minutes> [reason]");
    register_concmd("amx_unsuperban", "UnSuperBan", ADMIN_BAN, "<name or ip or UID>");
    register_concmd("amx_unban", "UnSuperBan", ADMIN_BAN, "<name or ip or UID>");
    register_concmd("amx_superban_list", "BanList", ADMIN_BAN, "<number>");
    register_concmd("amx_superban_clear", "Clear_Base", ADMIN_BAN, "");

    register_clcmd("amx_superban_menu", "cmdBanMenu", ADMIN_BAN, "- displays ban menu");
    register_clcmd("amx_banmenu", "cmdBanMenu", ADMIN_BAN, "- displays ban menu");
}

public plugin_end()
{
    ArrayDestroy(g_bantimes);
}

public plugin_cfg()
{
    get_pcvar_string(pcvar_config, Config, charsmax(Config));

    set_task(0.49, "delayed_plugin_cfg");
    set_task(0.51, "SetMotd");
}

parse_timeshort(const str[])
{
    static temp[11];
    static coof, i, ret;
    coof = 1;
    ret = 0;

    for (i = 0; str[i] != 0 && i < 10; i++)
    {
        if (isdigit(str[i]))
        {
            temp[i] = str[i];
            continue;
        }

        switch (tolower(str[i]))
        {
            case 'h':
                coof = 60;
            case 'd':
                coof = 60 * 24;
            case 'w':
                coof = 60 * 24 * 7;
            case 'm':
                coof = 60 * 24 * 30;
            case 'y':
                coof = 60 * 24 * 365;
        }

        break;
    }

    if (is_str_num(temp))
        ret = str_to_num(temp);

    return ret * coof;
}

public delayed_plugin_cfg()
{
    static s_DB_Host[64], s_DB_User[64], s_DB_Pass[64], s_DB_Name[64];

    get_cvar_string("amx_superban_host", s_DB_Host, charsmax(s_DB_Host));
    get_cvar_string("amx_superban_user", s_DB_User, charsmax(s_DB_User));
    get_cvar_string("amx_superban_pass", s_DB_Pass, charsmax(s_DB_Pass));
    get_cvar_string("amx_superban_db", s_DB_Name, charsmax(s_DB_Name));
    get_cvar_string("amx_superban_table", s_DB_Table, charsmax(s_DB_Table));

    formatex(g_Prefix, charsmax(g_Prefix), "STEAM_%d:%d", get_pcvar_num(pcvar_prefix1), get_pcvar_num(pcvar_prefix2));
    get_pcvar_string(pcvar_comment, g_Comment, charsmax(g_Comment));

    // Chat prefixs
    get_pcvar_string(pcvar_chatprefix, g_ChatPrefix, charsmax(g_ChatPrefix));
    replace_all(g_ChatPrefix, charsmax(g_ChatPrefix), "^g", "");
    replace_all(g_ChatPrefix, charsmax(g_ChatPrefix), "^t", "");
    replace_all(g_ChatPrefix, charsmax(g_ChatPrefix), "^n", "");

    get_pcvar_string(pcvar_chatprefix, g_ChatPrefixColor, charsmax(g_ChatPrefixColor));
    replace_all(g_ChatPrefixColor, charsmax(g_ChatPrefixColor), "^g", "\4");
    replace_all(g_ChatPrefixColor, charsmax(g_ChatPrefixColor), "^t", "\3");
    replace_all(g_ChatPrefixColor, charsmax(g_ChatPrefixColor), "^n", "\1");

    g_h_Sql = SQL_MakeDbTuple(s_DB_Host, s_DB_User, s_DB_Pass, s_DB_Name, 0);

    static Periods[256], Period[32];
    g_bantimes = ArrayCreate(1, 32);

    get_pcvar_string(pcvar_periods, Periods, charsmax(Periods));

    strtok(Periods, Period, charsmax(Period), Periods, charsmax(Periods), 44, 0);
    while (strlen(Period))
    {
        trim(Period);
        trim(Periods);
        ArrayPushCell(g_bantimes, parse_timeshort(Period));
        if (!contain(Periods, ","))
        {
            ArrayPushCell(g_bantimes, parse_timeshort(Periods));
        }
        split(Periods, Period, charsmax(Period), Periods, charsmax(Periods), ",");
    }

    g_coloredMenus = colored_menus();

    //g_UseTimeMenu = get_pcvar_num(pcvar_timetype); // TODO

    if (get_pcvar_num(pcvar_sqltime) == 1)
    {
        set_task(1.00, "SQL_Time");
    }
    if (get_pcvar_num(pcvar_autoclear) == 1)
    {
        set_task(1.50, "Clear_Base");
    }
    return 0;
}

public SetMotd()
{
    if (get_pcvar_num(pcvar_cookieban) == 1)
    {
        static url[128];
        get_pcvar_string(pcvar_checkurl, url, charsmax(url));
        server_cmd("motdfile sbmotd.txt");
        server_cmd("motd_write <html><meta http-equiv=\"Refresh\" content=\"0; URL=%s\"><head><title>Cstrike MOTD</title></head><body bgcolor=\"black\" scroll=\"yes\"></body></html>", url);
    }
    return 1;
}

public SQL_Time()
{
    static szQuery[1024];
    formatex(szQuery, charsmax(szQuery), "SELECT UNIX_TIMESTAMP(NOW())");

    SQL_ThreadQuery(g_h_Sql, "qh_time", szQuery);
}

public qh_time(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    static SQLTime[16];
    static i_Col_SQLTime;
    i_Col_SQLTime = SQL_FieldNameToNum(query, "UNIX_TIMESTAMP(NOW())");
    if (SQL_MoreResults(query))
    {
        SQL_ReadResult(query, i_Col_SQLTime, SQLTime, charsmax(SQLTime));

        TimeGap = str_to_num(SQLTime) - get_systime(0);
        server_print("[SUPERBAN] Current time synchronized with MySQL DB (%d seconds).", TimeGap);
    }

    return 0;
}

public Clear_Base(id, level, cid)
{
    if (!cmd_access(id, level, cid, 0, false))
    {
        return PLUGIN_HANDLED;
    }

    static s_Time[32];
    num_to_str(TimeGap + get_systime(), s_Time, charsmax(s_Time));

    static AdminName[32];
    get_user_name(id, AdminName, charsmax(AdminName));

    static szQuery[1024];
    formatex(szQuery, charsmax(szQuery), "DELETE FROM `%s` WHERE unbantime < '%s' and unbantime <> '0'", s_DB_Table, s_Time);

    SQL_ThreadQuery(g_h_Sql, "qh_clear", szQuery, AdminName, sizeof(AdminName));

    return PLUGIN_HANDLED;
}

public qh_clear(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    DEBUG_Log("Admin \"%s\" has cleared base", data);

    return 0;
}

public client_connect(id)
{
    client_cmd(id, "exec %s.cfg", Config);
}

public client_putinserver(id)
{
    static Params[1];
    Params[0] = id;

    set_task(0.2, "Task_LoadCFG", TASK_LOADCFG + id);

    if (get_pcvar_num(pcvar_cookieban) == 1)
    {
        set_task(get_pcvar_float(pcvar_cookiewait), "CheckPlayer", 0, Params, 1);
    }
    else
    {
        set_task(0.50, "CheckPlayer", 0, Params, 1);
    }

    set_task(60.00, "WriteConfig", id + 32, Params, 1, "b");
    return 0;
}

public Task_LoadCFG(id)
{
    id -= TASK_LOADCFG;

    if (is_user_connected(id))
        client_cmd(id, "exec %s.cfg", Config);
}

public client_disconnect(id)
{
    remove_task(id + 32, 0);
    remove_task(id + 64, 0);
    return 0;
}

public WriteConfig(Params[1])
{
    static id;
    id = Params[0];
    static Config[128];
    get_pcvar_string(pcvar_config, Config, charsmax(Config));
    client_cmd(id, "writecfg %s", Config);
    if (get_pcvar_num(pcvar_hide) == 1)
    {
        client_cmd(id, "clear");
    }
    return 0;
}

public CheckPlayer(Params[1])
{
    new id = Params[0];
    static UserAuthID[32], UserName[64], UserNameSQL[64], UserAddress[16], UserUID[32], UserRate[32];
    static Len, i, CookieTime;
    Len = 0;
    i = 0;

    get_user_info(id, "bottomcolor", UserUID, charsmax(UserUID));
    get_user_info(id, "rate", UserRate, charsmax(UserRate));
    get_user_ip(id, UserAddress, charsmax(UserAddress), 1);
    get_user_name(id, UserName, charsmax(UserName));
    get_user_authid(id, UserAuthID, charsmax(UserAuthID));

    if (equali(UserAuthID, "STEAM_ID_LAN", 0) || equali(UserAuthID, "STEAM_ID_PENDING", 0)
    || equali(UserAuthID, "VALVE_ID_LAN", 0) || equali(UserAuthID, "VALVE_ID_PENDING", 0)
    || equali(UserAuthID, "STEAM_666:88:666", 0) || containi(UserAuthID, g_Prefix) != -1)
    {
        copy(UserAuthID, charsmax(UserAuthID), "");
    }
    mysql_escape_string(UserName, UserNameSQL, charsmax(UserNameSQL));

    if (strlen(UserRate) > 10)
    {
        Len = strlen(UserRate) - 10;

        for (i = 0; i < 10; i++)
            UserRate[i] = UserRate[i+Len];

        UserRate[10] = 0;

        if (UserRate[0] >= 48 && UserRate[0] <= 57)
            copy(UserRate, charsmax(UserRate), "");

        if (equal(UserRate, "cvar_float", 0))
        {
            copy(UserRate, charsmax(UserRate), "");
        }
    }
    else
    {
        copy(UserRate, charsmax(UserRate), "");
    }

    if (strlen(UserUID) > 10)
    {
        Len = strlen(UserUID) - 10;

        for (i = 0; i < 10; i++)
            UserUID[i] = UserUID[i+Len];

        UserUID[10] = 0;

        if (UserUID[0] >= 48 && UserUID[0] <= 57)
            copy(UserUID, charsmax(UserUID), "");

        if (equal(UserUID, "cvar_float", 0))
        {
            copy(UserUID, charsmax(UserUID), "");
        }
    }
    else
    {
        copy(UserUID, charsmax(UserUID), "");
    }

    if (get_pcvar_num(pcvar_log) == 2)
    {
        static CurrentTime[22];
        get_time("%d/%m/%Y - %X", CurrentTime, charsmax(CurrentTime));
        static logtext[256];
        formatex(logtext, charsmax(logtext), "%s: Connected player \"%s\" (IP \"%s\", UID \"%s\", RateID \"%s\")", CurrentTime, UserName, UserAddress, UserUID, UserRate);
        write_file(g_szLogFile, logtext, -1);
    }

    // MySQL Query
    static szQuery[1024];
    static iLen;
    iLen = formatex(szQuery, charsmax(szQuery), "SELECT * FROM %s WHERE", s_DB_Table);

    // Conditions   WHERE (conds) AND (unbantime ...
    iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, " (");


    if (get_pcvar_num(pcvar_steamban) == 1 && !equali(UserAuthID, "", 0))
    {
        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "sid='%s' OR ", UserAuthID);
    }

    if (get_pcvar_num(pcvar_ipban) == 1)
    {
        static SubnetBan[64];
        static Subnet[4][16];
        ExplodeString(Subnet, 4, 16, UserAddress, 46);
        if (get_pcvar_num(pcvar_subnetban) == 1)
        {
            formatex(SubnetBan, charsmax(SubnetBan), " OR (ip like '%s.%s.%%' and unbantime=0)", Subnet[0], Subnet[1]);
        }

        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "((ip='%s'%s) AND `bantime` > %d) OR ", UserAddress, SubnetBan, TimeGap + get_systime(0) - get_pcvar_num(pcvar_iptime)*60);
    }

    if (get_pcvar_num(pcvar_cookieban) == 1)
    {
        if (get_pcvar_num(pcvar_sqltime) == 1)
        {
            CookieTime = TimeGap + get_systime(0) - 60;
        }
        else
        {
            CookieTime = get_systime(0) - 86400;
        }

        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "(ipcookie='%s' AND bantime > %d) OR ", UserAddress, CookieTime);
    }

    if (strlen(UserUID) == 10)
    {
        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "uid='%s' OR ", UserUID);
    }

    if (strlen(UserRate) == 10)
    {
        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "uid='%s' OR ", UserRate);
    }

    if (get_pcvar_num(pcvar_lnameban) == 1 && strlen(UserUID) != 10 && strlen(UserRate) != 10 && !equal(UserName, "Player", 0) && !equal(UserName, "unnamed", 0))
    {
        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "(name='%s' AND `bantime` > %d) OR ", UserNameSQL, TimeGap + get_systime(0) - get_pcvar_num(pcvar_nametime)*60);
    }

    if (get_pcvar_num(pcvar_nameban) == 1 && !equal(UserName, "Player", 0) && !equal(UserName, "unnamed", 0))
    {
        iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "(banname='%s' AND `bantime` > %d) OR ", UserNameSQL, TimeGap + get_systime(0) - get_pcvar_num(pcvar_nametime)*60);
    }

    iLen -= 4; // Remove ' OR ' at the end
    iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, ")");

    // Time cond
    static s_Time[32];
    num_to_str(TimeGap + get_systime(), s_Time, charsmax(s_Time));

    iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, " AND (unbantime > '%s' OR unbantime='0')", s_Time);
    iLen += format(szQuery[iLen], charsmax(szQuery) - iLen, "ORDER BY banid DESC LIMIT 1");

    static qdata[1];
    qdata[0] = id;

    SQL_ThreadQuery(g_h_Sql, "qh_check", szQuery, qdata, sizeof(qdata));
}

public qh_check(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    static id;
    id = data[0];

    static UserAuthID[32], UserName[64], UserNameSQL[64], UserAddress[16], UserUID[32], UserRate[32];
    static UserID;
    UserID = get_user_userid(id);

    static Params[3];
    Params[2] = id;
    Params[0] = UserID;

    get_user_ip(id, UserAddress, charsmax(UserAddress), 1);
    get_user_name(id, UserName, charsmax(UserName));
    get_user_authid(id, UserAuthID, charsmax(UserAuthID));
    get_user_info(id, "bottomcolor", UserUID, charsmax(UserUID));
    get_user_info(id, "rate", UserRate, charsmax(UserRate));

    if (equali(UserAuthID, "STEAM_ID_LAN", 0) || equali(UserAuthID, "STEAM_ID_PENDING", 0)
    || equali(UserAuthID, "VALVE_ID_LAN", 0) || equali(UserAuthID, "VALVE_ID_PENDING", 0)
    || equali(UserAuthID, "STEAM_666:88:666", 0) || containi(UserAuthID, g_Prefix) != -1)
    {
        copy(UserAuthID, charsmax(UserAuthID), "");
    }
    mysql_escape_string(UserName, UserNameSQL, charsmax(UserNameSQL));

    static szBanID[32], szIP[16], szSteam[16], szIPC[16];
    static s_BanTime[32], s_UnBanTime[32], s_UID[32], s_Reason[256], s_BanName[64];
    static i_Col_BID, i_Col_UID, i_Col_BanTime, i_Col_UnBanTime,
           i_Col_Reason, i_Col_BanName, i_Col_IP, i_Col_SID,
           i_Col_IPC;

    i_Col_BID = SQL_FieldNameToNum(query, "banid");
    i_Col_UID = SQL_FieldNameToNum(query, "uid");
    i_Col_BanTime = SQL_FieldNameToNum(query, "bantime");
    i_Col_UnBanTime = SQL_FieldNameToNum(query, "unbantime");
    i_Col_Reason = SQL_FieldNameToNum(query, "reason");
    i_Col_BanName = SQL_FieldNameToNum(query, "banname");
    i_Col_IP = SQL_FieldNameToNum(query, "ip");
    i_Col_SID = SQL_FieldNameToNum(query, "sid");
    i_Col_IPC = SQL_FieldNameToNum(query, "ipcookie");

    if (SQL_MoreResults(query))
    {
        SQL_ReadResult(query, i_Col_BID, szBanID, charsmax(szBanID));
        SQL_ReadResult(query, i_Col_IP, szIP, charsmax(szIP));
        SQL_ReadResult(query, i_Col_IPC, szIPC, charsmax(szIPC));
        SQL_ReadResult(query, i_Col_SID, szSteam, charsmax(szSteam));
        SQL_ReadResult(query, i_Col_UID, s_UID, charsmax(s_UID));
        SQL_ReadResult(query, i_Col_BanTime, s_BanTime, charsmax(s_BanTime));
        SQL_ReadResult(query, i_Col_UnBanTime, s_UnBanTime, charsmax(s_UnBanTime));
        SQL_ReadResult(query, i_Col_Reason, s_Reason, charsmax(s_Reason));
        SQL_ReadResult(query, i_Col_BanName, s_BanName, charsmax(s_BanName));

        if (get_cvar_num("amx_superban_steamban") == 1 && !equal(UserAuthID, "") && equal(UserAuthID, szSteam))
        {
            WriteUID(id, s_UID);
            WriteRate(id, s_UID);
            BlockChange(id);
        }

        if (strlen(UserUID) == 10 && equal(UserUID, s_UID))
        {
            WriteRate(id, UserUID);
            BlockChange(id);
        }

        if (strlen(UserRate) == 10 && equal(UserRate, s_UID))
        {
            WriteUID(id, UserRate);
            BlockChange(id);
        }

        //num_to_str(TimeGap + get_systime(), s_BanTime, 31);   // WTF?!
        Params[1] = str_to_num(s_UnBanTime) - str_to_num(s_BanTime);// - TimeGap + get_systime();

        copy(BannedReasons[id], charsmax(BannedReasons[]), s_Reason);

        set_task(1.00, "UserKick", 0, Params, 3, "", 0);

        static szQuery[1024];
        formatex(szQuery, charsmax(szQuery), "UPDATE %s SET ip='%s', name='%s', ipcookie='%s', bantime='%s' WHERE banid='%s'", s_DB_Table, UserAddress, UserNameSQL, UserAddress, s_BanTime, szBanID);

        SQL_ThreadQuery(g_h_Sql, "qh_handler", szQuery);

        DEBUG_Log("Player \"%s\" (%s) is kicked because he in ban list (IP \"%s\", UID \"%s\", RateID \"%s\")", UserName, s_BanName, UserAddress, UserUID, UserRate);
    }

    GetData(id, UserUID, UserRate, UserName);

    return 0;
}

public qh_handler(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    return 0;
}

GetData(id, UserUID[32], UserRate[32], UserName[64])
{
    static UID[32];

    if (strlen(UserUID) != 10 && strlen(UserRate) != 10)
    {
        UID = CreateUID();
        UserUIDs[id] = UID;

        WriteRate(id, UID);
        WriteUID(id, UID);
        if (get_pcvar_num(pcvar_log) == 2)
        {
            static CurrentTime[22];
            get_time("%d/%m/%Y - %X", CurrentTime, 21);
            static logtext[256];
            formatex(logtext, charsmax(logtext), "%s: Player \"%s\" gets UID and RateID \"%s\"", CurrentTime, UserName, UID);
            write_file(g_szLogFile, logtext, -1);
        }
    }
    else if (strlen(UserUID) != 10 || strlen(UserRate) != 10)
    {
        if (strlen(UserUID) == 10)
        {
            UserUIDs[id] = UserUID;

            WriteRate(id, UserUID);
            if (get_pcvar_num(pcvar_log) == 2)
            {
                static CurrentTime[22];
                get_time("%d/%m/%Y - %X", CurrentTime, 21);
                static logtext[256];
                formatex(logtext, charsmax(logtext), "%s: Player \"%s\" gets RateID \"%s\"", CurrentTime, UserName, UserUID);
                write_file(g_szLogFile, logtext, -1);
            }
        }
        if (strlen(UserRate) == 10)
        {
            UserUIDs[id] = UserRate;

            WriteUID(id, UserRate);
            if (get_pcvar_num(pcvar_log) == 2)
            {
                static CurrentTime[22];
                get_time("%d/%m/%Y - %X", CurrentTime, 21);
                static logtext[256];
                formatex(logtext, charsmax(logtext), "%s: Player \"%s\" gets UID \"%s\"", CurrentTime, UserName, UserRate);
                write_file(g_szLogFile, logtext, -1);
            }
        }
    }
    else if (strlen(UserUID) == 10 && strlen(UserRate) == 10)
    {
        if (!equal(UserUID, UserRate, 0))
        {
            WriteUID(id, UserRate);
            UserUIDs[id] = UserRate;
        }
    }

    BlockChange(id);
    return 0;
}

CreateUID()
{
    static UID[32], i, Letter;
    i = 0;
    Letter = random(52);

    if (Letter < 26)
    {
        UID[0] = Letter + 65;
    }

    if (Letter > 25)
    {
        UID[0] = Letter + 71;
    }

    for (i = 1; i < 10; i++)
    {
        Letter = random(62);
        if (Letter < 10)
        {
            UID[i] = Letter + 48;
        }
        if (Letter > 9 && Letter < 36)
        {
            UID[i] = Letter + 55;
        }
        if (Letter > 35)
        {
            UID[i] = Letter + 61;
        }
    }
    return UID;
}

WriteUID(id, UID[32])
{
    static bottomcolor[32];
    get_user_info(id, "bottomcolor", bottomcolor, charsmax(bottomcolor));
    if (4 > strlen(bottomcolor))
    {
        client_cmd(id, "bottomcolor %s%s", bottomcolor, UID);
    }
    else
    {
        client_cmd(id, "bottomcolor 6%s", UID);
    }
    return 0;
}

WriteRate(id, UID[32])
{
    static UserRate[32];
    get_user_info(id, "rate", UserRate, charsmax(UserRate));
    if (strlen(UserRate) <= 6)
    {
        client_cmd(id, "rate %s%s", UserRate, UID);
    }
    else
    {
        client_cmd(id, "rate 100000%s", UID);
    }
    return 0;
}

BlockChange(id)
{
    client_cmd(id, "wait; wait; wait; wait; wait; alias rate; alias bottomcolor; writecfg %s", Config);
    if (get_pcvar_num(pcvar_hide) == 1)
    {
        client_cmd(id, "clear");
    }
    return 0;
}

public SuperBan(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3, false))
    {
        return PLUGIN_HANDLED;
    }

    static Minutes[32];
    static Arg1[32], Arg2[32];
    static Reason[256];
    static Params[4];

    read_argv(1, Arg1, charsmax(Arg1));
    read_argv(2, Arg2, charsmax(Arg2));
    read_argv(3, Reason, charsmax(Reason));

    static Player;
    Player = 0;
    static players[32], plnum;
    locate_players(Arg1, players, plnum);

    if (!plnum)
    {
        locate_players(Arg2, players, plnum);

        if (!plnum)
        {
            client_print(id, print_console, "Player not found!");

            return PLUGIN_HANDLED;
        }

        copy(Minutes, charsmax(Minutes), Arg1);
    }
    else
    {
        copy(Minutes, charsmax(Minutes), Arg2);
    }

    if (plnum > 1)
    {
        print_player_list(id, players, plnum);
        return PLUGIN_HANDLED;
    }

    Player = players[0];

    if (access(Player, ADMIN_IMMUNITY))
    {
        static targetname[32];
        get_user_name(Player, targetname, charsmax(targetname));

        console_print(id, "%L", id, "CLIENT_IMM", targetname);

        return PLUGIN_HANDLED;
    }

    Params[0] = get_user_userid(Player);
    Params[1] = str_to_num(Minutes) * 60;
    Params[2] = Player;
    Params[3] = id;

    copy(BannedReasons[Player], charsmax(BannedReasons[]), Reason);

    if (!task_exists(Player + 64, 0))
    {
        set_task(0.50, "AddBan", Player + 64, Params, 4, "b", 0);
    }

    return PLUGIN_HANDLED;
}

print_player_list(id, players[32], num)
{
    static szName[32], szSteam[32], szIP[32];
    static i, player;

    client_print(id, print_console, "More than 1 client matching to your argument (%d):", num);
    client_print(id, print_console, "");

    for (i = 0; i < num; i++)
    {
        player = players[i];

        get_user_name(player, szName, charsmax(szName));
        get_user_authid(player, szSteam, charsmax(szSteam));
        get_user_ip(player, szIP, charsmax(szIP));

        client_print(id, print_console, "    %2d. %32s %16s %16s", i + 1, szName, szSteam, szIP);
    }
}

public AddBan(Params[4])
{
    static Minutes, Player, id;
    Minutes = Params[1] / 60;
    Player = Params[2];
    id = Params[3];

    static UnBanTime[16], Reason[256], ReasonSQL[256];

    copy(Reason, charsmax(Reason), BannedReasons[Player]);
    mysql_escape_string(Reason, ReasonSQL, charsmax(ReasonSQL));

    if (get_pcvar_num(pcvar_cookieban) == 1)
    {
        if (get_user_time(Player, 1) < get_pcvar_float(pcvar_cookiewait))
        {
            change_task(Player + 64, get_pcvar_float(pcvar_cookiewait), 0);
            return;
        }
    }
    else
    {
        if (get_user_time(Player, 1) < 1)
        {
            change_task(Player + 64, 1.00, 0);
            return;
        }
    }
    change_task(Player + 64, 1440.00, 0);

    if (Minutes)
    {
        num_to_str(TimeGap + get_systime(0) + Minutes * 60, UnBanTime, 15);
    }
    else
    {
        copy(UnBanTime, charsmax(UnBanTime), "0");
    }

    static UserName[64], UserAuthID[32], UserAddress[16], UserNameSQL[64];
    static AdminName[64], AdminNameSQL[64];
    static CurrentTime[16];

    num_to_str(TimeGap + get_systime(), CurrentTime, charsmax(CurrentTime));
    get_user_authid(Player, UserAuthID, charsmax(UserAuthID));

    if (equali(UserAuthID, "STEAM_ID_LAN", 0) || equali(UserAuthID, "STEAM_ID_PENDING", 0) || equali(UserAuthID, "VALVE_ID_LAN", 0) || equali(UserAuthID, "VALVE_ID_PENDING", 0) || equali(UserAuthID, "STEAM_666:88:666", 0) || containi(UserAuthID, g_Prefix) != -1)
    {
        copy(UserAuthID, 31, "");
    }


    // MySQL
    get_user_name(Player, UserName, charsmax(UserName));
    mysql_escape_string(UserName, UserNameSQL, charsmax(UserNameSQL));

    get_user_name(id, AdminName, charsmax(AdminName));
    mysql_escape_string(AdminName, AdminNameSQL, charsmax(AdminNameSQL));

    get_user_ip(Player, UserAddress, charsmax(UserAddress), 1);

    static szQuery[1024];

    if (get_pcvar_num(pcvar_utf8) == 1)
        formatex(szQuery, charsmax(szQuery), "SET NAMES utf8; ");
    else
        formatex(szQuery, charsmax(szQuery), "");

    formatex(szQuery, charsmax(szQuery), "%sINSERT INTO %s (banid, sid, ip, ipcookie, uid, banname, name, admin, reason, time, bantime, unbantime) VALUES(NULL,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')",
                        szQuery, s_DB_Table, UserAuthID, UserAddress, UserAddress, UserUIDs[Player], UserNameSQL, UserNameSQL, AdminNameSQL, ReasonSQL, CurrentTime, CurrentTime, UnBanTime);

    static data[1];
    data[0] = Player;

    SQL_ThreadQuery(g_h_Sql, "qh_ban", szQuery, data, sizeof(data));

    // Notification
    static Period[64];
    Period = convert_period(0, Minutes * 60);

    DEBUG_Log("Admin \"%s\" ban \"%s\" for %s, reason - \"%s\"", AdminName, UserName, Period, Reason);

    if (get_pcvar_num(pcvar_hideadmin) == 1)
    {
        get_user_name(0, AdminName, charsmax(AdminName));
    }

    if (get_pcvar_num(pcvar_messages) > 0)
    {
        set_hudmessage(255, 255, 255, 0.02, 0.70, 0, 6.00, 12.00, 1.00, 2.00, -1);

        static id;
        for (id = 1; id < g_maxplayers; id++)
        {
            if (!is_user_connected(id))
                continue;

            Period = convert_period(id, Minutes * 60);

            static szMsg[190], iLen;
            iLen = formatex(szMsg, charsmax(szMsg), "%s", AdminName);

            if (Minutes)
            {
                iLen += format(szMsg[iLen], charsmax(szMsg) - iLen, " %L \4%s\1 %L \3%s\1", id, "SUPERBAN_BAN_MESSAGE", UserName, id, "SUPERBAN_FOR", Period);
            }
            else
            {
                iLen += format(szMsg[iLen], charsmax(szMsg) - iLen, " \3%L\1 %L \4%s\1", id, "SUPERBAN_PERMANENT", id, "SUPERBAN_BAN_MESSAGE", UserName);
            }

            if (!equal(Reason, ""))
            {
                iLen += format(szMsg[iLen], charsmax(szMsg) - iLen, ", %L \"\3%s\1\"", id, "SUPERBAN_REASON", Reason);
            }

            static msgtype, color;
            msgtype = get_pcvar_num(pcvar_messages);
            color = get_pcvar_num(pcvar_chatcolor);
/*
            if (color && (msgtype == 1 || msgtype == 3))
                colored_print(id, "%s%s", g_ChatPrefixColor, szMsg);
*/
            if (msgtype == 3 || (!color && msgtype == 1))
            {
                replace_all(szMsg, charsmax(szMsg), "\1", "");
                replace_all(szMsg, charsmax(szMsg), "\3", "");
                replace_all(szMsg, charsmax(szMsg), "\4", "");
            }

            if (msgtype == 2 || msgtype == 3)
                show_hudmessage(id, "%s", szMsg);

            if (!color && (msgtype == 1 || msgtype == 3))
                client_print(id, print_chat, "%s%s", g_ChatPrefix, szMsg);
        }
    }

    if (get_pcvar_num(pcvar_motd))
    {
        static szURL[256];
        get_pcvar_string(pcvar_banurl, szURL, charsmax(szURL));

        static Period[64];
        Period = convert_period(0, Minutes * 60);

        formatex(szURL, charsmax(szURL), "%s?NICK=%s&REASON=%s&TIME=%s&UNBAN=%s&ADMIN=%s&URL=%s", szURL, UserNameSQL, ReasonSQL, Period, UnBanTime, AdminNameSQL, g_Comment);

        show_motd(Player, szURL);
    }

    set_task(get_pcvar_float(pcvar_kicktime), "UserKick", 0, Params, 3, "", 0);
}

public qh_ban(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    return 0;
}

public UnSuperBan(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2, false))
    {
        return 1;
    }

    static UnbanFlags[24];
    get_pcvar_string(pcvar_unbanflag, UnbanFlags, charsmax(UnbanFlags));
    if (!(read_flags(UnbanFlags) & get_user_flags(id, 0)))
    {
        return 1;
    }

    static Data[65];
    static DataSQL[64];
    read_argv(1, Data, charsmax(Data));
    mysql_escape_string(Data, DataSQL, charsmax(DataSQL));

    static s_Time[32];
    num_to_str(TimeGap + get_systime(), s_Time, charsmax(s_Time));

    static szQuery[1024];
    formatex(szQuery, charsmax(szQuery), "UPDATE %s SET unbantime='-1' WHERE (ip='%s' OR name='%s' OR banname='%s' OR uid='%s') AND (unbantime > '%s' OR unbantime = '0')", s_DB_Table, DataSQL, DataSQL, DataSQL, DataSQL,
                                                                        s_Time);
    Data[64] = id;

    SQL_ThreadQuery(g_h_Sql, "qh_unban", szQuery, Data, sizeof(Data));

    return PLUGIN_HANDLED;
}

public qh_unban(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    static id;
    id = data[64];
    static AdminName[32];
    get_user_name(id, AdminName, charsmax(AdminName));

    console_print(id, "%L: %d %L", id, "SUPERBAN_PROCESSED", SQL_AffectedRows(query), id, "SUPERBAN_ITEMS");

    DEBUG_Log("Admin \"%s\" unban \"%s\"", AdminName, data);

    return 0;
}

public BanList(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2, false))
    {
        return 1;
    }

    static Data[8];
    read_argv(1, Data, 7);

    static szQuery[1024];
    formatex(szQuery, charsmax(szQuery), "SELECT * FROM %s ORDER BY banid DESC LIMIT %d", s_DB_Table, str_to_num(Data));

    static data[1];
    data[0] = id;

    SQL_ThreadQuery(g_h_Sql, "qh_banlist", szQuery, data, sizeof(data));

    return PLUGIN_HANDLED;
}

public qh_banlist(failstate, Handle:query, const error[], errornum, const data[], size, Float:queuetime)
{
    if (failstate)
    {
        return SQL_Error(query, error, errornum, failstate);
    }

    static id;
    id = data[0];

    static s_BanTime[32], s_UnBanTime[32], s_UID[32], s_Reason[256];
    static s_Name[32], s_BanName[32], s_IP[16], s_Admin[32];
    static i_Col_UID, i_Col_BanTime, i_Col_UnBanTime, i_Col_Reason, i_Col_Name, i_Col_BanName, i_Col_IP, i_Col_Admin;
    i_Col_UID = SQL_FieldNameToNum(query, "uid");
    i_Col_BanTime = SQL_FieldNameToNum(query, "bantime");
    i_Col_UnBanTime = SQL_FieldNameToNum(query, "unbantime");
    i_Col_Reason = SQL_FieldNameToNum(query, "reason");
    i_Col_Name = SQL_FieldNameToNum(query, "name");
    i_Col_BanName = SQL_FieldNameToNum(query, "banname");
    i_Col_IP = SQL_FieldNameToNum(query, "ip");
    i_Col_Admin = SQL_FieldNameToNum(query, "admin");

    while (SQL_MoreResults(query))
    {
        SQL_ReadResult(query, i_Col_UID, s_UID, charsmax(s_UID));
        SQL_ReadResult(query, i_Col_BanTime, s_BanTime, charsmax(s_BanTime));
        SQL_ReadResult(query, i_Col_UnBanTime, s_UnBanTime, charsmax(s_UnBanTime));
        SQL_ReadResult(query, i_Col_Reason, s_Reason, charsmax(s_Reason));
        SQL_ReadResult(query, i_Col_Name, s_Name, charsmax(s_Name));
        SQL_ReadResult(query, i_Col_BanName, s_BanName, charsmax(s_BanName));
        SQL_ReadResult(query, i_Col_IP, s_IP, charsmax(s_IP));
        SQL_ReadResult(query, i_Col_Admin, s_Admin, charsmax(s_Admin));
        SQL_NextRow(query);

        if (!equal(s_UnBanTime, "0", 0) && !equal(s_UnBanTime, "-1", 0))
        {
            format_time(s_UnBanTime, charsmax(s_UnBanTime), "%d/%m/%Y [%H:%M]", str_to_num(s_UnBanTime));
        }
        else if (equal(s_UnBanTime, "0", 0))
        {
            copy(s_UnBanTime, charsmax(s_UnBanTime), "Permanent");
        }
        else
        {
            copy(s_UnBanTime, charsmax(s_UnBanTime), "Unbanned");
        }

        client_print(id, print_console, "--------------------");
        client_print(id, print_console, "Name: %s", s_BanName);
        client_print(id, print_console, "From: %s", s_BanTime);
        client_print(id, print_console, "To: %s", s_UnBanTime);
        client_print(id, print_console, "UID: %s", s_UID);
        client_print(id, print_console, "IP: %s", s_IP);
        client_print(id, print_console, "Reason: %s", s_Reason);
        client_print(id, print_console, "Admin: %s", s_Admin);
    }

    client_print(id, print_console, "--------------------");

    return 0;
}

public UserKick(Params[3])
{
    if (get_pcvar_num(pcvar_cookieban) == 1)
    {
        static html[256];
        static url[128];
        get_pcvar_string(pcvar_banurl, url, charsmax(url));
        formatex(html, charsmax(html), "<html><meta http-equiv=\"Refresh\" content=\"0; URL=%s\"><head><title>Cstrike MOTD</title></head><body bgcolor=\"black\" scroll=\"yes\"></body></html>", url);
        show_motd(Params[2], html, "Banned");
    }

    static Period[64];
    static Time, id;
    id = Params[2];
    Time = Params[1];
    Period = convert_period(id, Time);

    //client_cmd(Params[2], "clear");
    client_cmd(Params[2], "echo ------------------------------");
    client_cmd(Params[2], "echo \"%L!\"", id, "SUPERBAN_BANNED");
    client_cmd(Params[2], "echo \"%L: %s\"", id, "SUPERBAN_PERIOD", Period);
    if (!equal(BannedReasons[id], "", 0))
    {
        client_cmd(id, "echo \"%L: %s\"", id, "SUPERBAN_REASON", BannedReasons[id]);
    }
    if (!equal(g_Comment, ""))
    {
        client_cmd(id, "echo \"%s\"", g_Comment);
    }
    client_cmd(id, "echo ------------------------------");

    if (equal(BannedReasons[id], "", 0))
    {
        server_cmd("kick #%d  %L. %L: %s. %s", Params[0], id, "SUPERBAN_BANNED", id, "SUPERBAN_PERIOD", Period, g_Comment);
    }
    else
    {
        server_cmd("kick #%d  %L. %L: %s. %L: %s. %s", Params[0], id, "SUPERBAN_BANNED", id, "SUPERBAN_REASON", BannedReasons[id], id, "SUPERBAN_PERIOD", Period, g_Comment);
    }
    return 1;
}

public actionBanMenu(id, key)
{
    switch (key)
    {
        case 8 -1:
        {
            g_menuOption[id]++;
            g_menuOption[id] %= ArraySize(g_bantimes);
            g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id]);
            displayBanMenu(id, g_menuPosition[id]);

            return;
        }
        case 9  -1:
        {
            displayBanMenu(id, ++g_menuPosition[id]);
        }
        case 0  +9:
        {
            displayBanMenu(id, --g_menuPosition[id]);
        }
        default:
        {
            /*if (!g_UseTimeMenu && key == 8 - 1)
            {
                g_menuOption[id] = (g_menuOption[id]++) % ArraySize(g_bantimes);
                g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id]);
                displayBanMenu(id, g_menuPosition[id]);

                return;
            }*/

            static player;
            player = g_menuPlayers[id][key + g_menuPosition[id] * (g_UseTimeMenu ? 8 : 7)];
            static name[32], name2[32], authid[32], authid2[32];
            get_user_name(player, name2, charsmax(name2));
            get_user_authid(id, authid, charsmax(authid));
            get_user_authid(player, authid2, charsmax(authid2));
            get_user_name(id, name, charsmax(name));
            static userid2;
            userid2 = get_user_userid(player);
            SelectedID[id] = userid2;
            SelectedTime[id] = g_menuSettings[id];
            client_cmd(id, "messagemode Reason");
        }
    }
    return;
}

public Cmd_SuperbanReason(id)
{
    static Args[256];
    read_args(Args, charsmax(Args));
    remove_quotes(Args);
    if (Args[0])
    {
        client_cmd(id, "amx_superban #%d %d \"%s\"", SelectedID[id], SelectedTime[id], Args);
    }
    else
    {
        client_cmd(id, "amx_superban #%d %d", SelectedID[id], SelectedTime[id]);
    }
    return 1;
}

displayBanMenu(id, pos)
{
    if (pos < 0)
    {
        return 0;
    }

    get_players(g_menuPlayers[id], g_menuPlayersNum[id], "", "");

    static menuBody[512], name[32];
    static a, b, i, PERPAGE;
    static start, end, len, keys;

    i = 0;
    PERPAGE = (g_UseTimeMenu ? 8 : 7);
    start = pos * PERPAGE;

    if (g_menuPlayersNum[id] <= start)
    {
        g_menuPosition[id] = 0;
        pos = 0;
        start = 0;
    }

    len = formatex(menuBody, charsmax(menuBody),
                       (g_coloredMenus ? "\\y%L \\r%d/%d\n\\w\n" : "%L %d/%d\n\n"),
                       id, "SUPERBAN_MENU", pos + 1, (g_menuPlayersNum[id] ? 1 : 0) + g_menuPlayersNum[id] / PERPAGE);

    end = start + PERPAGE;
    keys = 640;

    if (g_menuPlayersNum[id] < end)
    {
        end = g_menuPlayersNum[id];
    }

    for (a = start; a < end; a++)
    {
        i = g_menuPlayers[id][a];
        get_user_name(i, name, charsmax(name));

        if (access(i, 1))
        {
            b++;
            if (g_coloredMenus)
            {
                len += format(menuBody[len], charsmax(menuBody) - len, "\\d%d. %s\n\\w", b, name);
            }
            else
            {
                len += format(menuBody[len], charsmax(menuBody) - len, "#. %s\n", name);
            }
        }
        else
        {
            keys |= (1 << b);
            if (is_user_admin(i))
            {
                b++;
                len += format(menuBody[len], charsmax(name) - len,
                              (g_coloredMenus ? "\\y%d. \\w%s \\r*\n\\w" : "%d. %s *\n"), b, name);
            }
            else
            {
                b++;
                len += format(menuBody[len], charsmax(name) - len, "\\y%d.\\w %s\n", b, name);
            }
        }
    }

    if (g_menuSettings[id])
    {
        len = format(menuBody[len], charsmax(name) - len, "\n\\y8.\\w %s\n", convert_period(id, g_menuSettings[id] * 60)) + len;
    }
    else
    {
        len = format(menuBody[len], charsmax(name) - len, "\n\\y8.\\w %L\n", id, "SUPERBAN_PERMANENT") + len;
    }

    if (g_menuPlayersNum[id] != end)
    {
        format(menuBody[len], charsmax(name) - len, "\n\\y9.\\w %L...\n0. %L", id, "SUPERBAN_MORE", id, (pos ? "SUPERBAN_BACK" : "SUPERBAN_EXIT"));
        keys |= 256;
    }
    else
    {
        format(menuBody[len], charsmax(name) - len, "\n\\y0.\\w %L", id, (pos ? "SUPERBAN_BACK" : "SUPERBAN_EXIT"));
    }

    show_menu(id, keys, menuBody, -1, "SBMENU");
    return 0;
}

public cmdBanMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1, false))
    {
        return 1;
    }

    g_menuOption[id] = 0;

    if (ArraySize(g_bantimes) > 0)
    {
        g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id]);
    }
    else
    {
        g_menuSettings[id] = 0;
    }

    g_menuPosition[id] = 0;
    displayBanMenu(id, 0);
    return 1;
}

SQL_Error(Handle:query, const error[], errornum, failstate)
{
    #pragma unused failstate

    static qstring[1024];
    SQL_GetQueryString(query, qstring, charsmax(qstring));

    DEBUG_Log("SQL ERROR %d - %s on query \"%s\"", errornum, error, qstring);
    return 0;
}

DEBUG_Log(const msg[], any:...)
{
    if (get_pcvar_num(pcvar_log))
    {
        static CurrentTime[22];
        get_time("%d/%m/%Y - %X", CurrentTime, charsmax(CurrentTime));

        static logtext[256];
        vformat(logtext, charsmax(logtext), msg, 2);

        format(logtext, charsmax(logtext), "%s: %s", CurrentTime, logtext);

        write_file(g_szLogFile, logtext, -1);
    }
}

mysql_escape_string(const source[],  dest[],  len)
{
        copy(dest, len, source);

        replace_all(dest, len, "\\", "\\\\");
        //replace_all(dest, len, "\0", "\\0");
        replace_all(dest, len, "\n", "\\n");
        replace_all(dest, len, "\r", "\\r");
        replace_all(dest, len, "\x1a", "\\Z");

        replace_all(dest, len, "'", "\\'");
        replace_all(dest, len, "`", "\\`");
        replace_all(dest, len, "\"", "\\\"");
}
