#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <gozm>

#define MAX_ADMINS 64

#define ADMIN_LOOKUP    (1<<0)
#define ADMIN_NORMAL    (1<<1)
#define ADMIN_STEAM     (1<<2)
#define ADMIN_IPADDR    (1<<3)
#define ADMIN_NAME      (1<<4)

new g_aPassword[MAX_ADMINS][32]
new g_aName[MAX_ADMINS][32]
new g_aFlags[MAX_ADMINS]
new g_aAccess[MAX_ADMINS]
new g_aNum = 0
new g_cmdLoopback[16]

public plugin_init()
{
    register_plugin("AmxBans Admin Base", AMXX_VERSION_STR, "AMXX Dev Team")

    register_dictionary("admin.txt")
    register_dictionary("common.txt")

    register_cvar("amx_mode", "1")
    register_cvar("amx_password_field", "_pw")
    register_cvar("amx_default_access", "")

    register_cvar("amx_vote_ratio", "0.02")
    register_cvar("amx_vote_time", "10")
    register_cvar("amx_vote_answers", "1")
    register_cvar("amx_vote_delay", "60")
    register_cvar("amx_last_voting", "0")
    register_cvar("amx_show_activity", "2")
    register_cvar("amx_votekick_ratio", "0.40")
    register_cvar("amx_voteban_ratio", "0.40")
    register_cvar("amx_votemap_ratio", "0.40")

    set_cvar_float("amx_last_voting", 0.0)

    register_srvcmd("amx_sqladmins", "adminSql")

    register_cvar("amx_sql_table", "admins")
    register_cvar("amx_sql_host", "141.101.203.23")
    register_cvar("amx_sql_user", "u179761")
    register_cvar("amx_sql_pass", "petyx")
    register_cvar("amx_sql_db", "b179761")
    register_cvar("amx_sql_type", "mysql")

    register_concmd("amx_reloadadmins", "cmdReload", ADMIN_CFG)

    formatex(g_cmdLoopback, 15, "amxauth%c%c%c%c", random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'))

    register_clcmd(g_cmdLoopback, "ackSignal")

    remove_user_flags(0, read_flags("z"))       // Remove 'user' flag from server rights

    new configsDir[64]
    get_configsdir(configsDir, charsmax(configsDir))

    server_cmd("exec %s/amxx.cfg", configsDir)  // Execute main configuration file
    server_cmd("exec %s/sql.cfg", configsDir)

    server_cmd("amx_sqladmins")
}

public plugin_cfg()
{
    new configFile[64], curMap[32]

    get_configsdir(configFile, charsmax(configFile))
    get_mapname(curMap, charsmax(curMap))

    new len = format(configFile, charsmax(configFile), "%s/maps/%s.cfg", configFile, curMap)

    if (file_exists(configFile))
        set_task(6.1, "delayed_load", 0, configFile, len + 1)
}

public delayed_load(configFile[])
{
    server_cmd("exec %s", configFile)
}

loadSettings(szFilename[])
{
    if (!file_exists(szFilename))
        return 0

    new szText[256], szFlags[32], szAccess[32]

    new file = fopen(szFilename, "rt")
    while (g_aNum < MAX_ADMINS && file && !feof(file))
    {
        fgets(file, szText, charsmax(szText))
        trim(szText)

        // skip commented lines
        if (szText[0] == ';' || strlen(szText) < 1 || (szText[0] == '/' && szText[1] == '/'))
            continue

        if (parse(szText, g_aName[g_aNum], charsmax(g_aName[]),
                          g_aPassword[g_aNum], charsmax(g_aPassword[]),
                          szAccess, charsmax(szAccess),
                          szFlags, charsmax(szFlags) ) < 2)
            continue

        g_aAccess[g_aNum] = read_flags(szAccess)
        g_aFlags[g_aNum] = read_flags(szFlags)
        ++g_aNum
    }
    if (file) fclose(file)

    if (g_aNum == 1)
        server_print("[AMX_ADMINS] %L", LANG_SERVER, "LOADED_ADMIN")
    else
        server_print("[AMX_ADMINS] %L", LANG_SERVER, "LOADED_ADMINS", g_aNum)

    return 1
}

public adminSql()
{
    new error[128], type[12], errno

    new Handle:info = SQL_MakeStdTuple()
    new Handle:sql = SQL_Connect(info, errno, error, charsmax(error))

    // This is a new way of getting the port number
    new ip_port[42], ip_tmp[32], ip[32] , port[10]
    get_user_ip(0, ip_port, charsmax(ip_port))
    strtok(ip_port, ip_tmp, charsmax(ip_tmp), port, charsmax(port), ':')
    get_cvar_string("ip", ip, charsmax(ip))

    SQL_GetAffinity(type, charsmax(type))

    if (sql == Empty_Handle)
    {
        server_print("[AMX_ADMINS] Cant connect to database: %s", error)

        //backup to users.ini
        new configsDir[64]

        get_configsdir(configsDir, charsmax(configsDir))
        format(configsDir, charsmax(configsDir), "%s/users.ini", configsDir)
        loadSettings(configsDir) // Load admins accounts

        return PLUGIN_HANDLED
    }

    new Handle:query
    query = SQL_PrepareQuery(sql, "\
        SELECT username, password, access, flags \
        FROM amx_amxadmins \
        WHERE is_active=1")

    if (!SQL_Execute(query))
    {
        SQL_QueryError(query, error, charsmax(error))
        server_print("[AMX_ADMINS] Cant load admins: %s", error)
    } else if (!SQL_NumResults(query)) {
        server_print("[AMX_ADMINS] No Admins found!")
    } else {
        new szFlags[32], szAccess[32]

        g_aNum = 0

        /** do this incase people change the query order and forget to modify below */
        new qcolAuth = SQL_FieldNameToNum(query, "username")
        new qcolPass = SQL_FieldNameToNum(query, "password")
        new qcolAccess = SQL_FieldNameToNum(query, "access")
        new qcolFlags = SQL_FieldNameToNum(query, "flags")

        while (SQL_MoreResults(query))
        {
            SQL_ReadResult(query, qcolAuth, g_aName[g_aNum], charsmax(g_aName[]))
            SQL_ReadResult(query, qcolPass, g_aPassword[g_aNum], charsmax(g_aPassword[]))
            SQL_ReadResult(query, qcolAccess, szAccess, charsmax(szAccess))
            SQL_ReadResult(query, qcolFlags, szFlags, charsmax(szFlags))

            g_aAccess[g_aNum] = read_flags(szAccess)

            g_aFlags[g_aNum] = read_flags(szFlags)

            ++g_aNum
            SQL_NextRow(query)
        }

        if (g_aNum == 1)
            server_print("[AMX_ADMINS] %L", LANG_SERVER, "SQL_LOADED_ADMIN")
        else
            server_print("[AMX_ADMINS] %L", LANG_SERVER, "SQL_LOADED_ADMINS", g_aNum)

        SQL_FreeHandle(query)
        SQL_FreeHandle(sql)
        SQL_FreeHandle(info)
    }

    return PLUGIN_HANDLED
}

public cmdReload(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    //strip original flags (patch submitted by mrhunt)
    remove_user_flags(0, read_flags("z"))

    g_aNum = 0
    adminSql()

    if (id != 0)
    {
        if (g_aNum == 1)
            console_print(id, "[AMX_ADMINS] %L", LANG_SERVER, "SQL_LOADED_ADMIN")
        else
            console_print(id, "[AMX_ADMINS] %L", LANG_SERVER, "SQL_LOADED_ADMINS", g_aNum)
    }

    new players[32], num, pv
    new name[32]
    get_players(players, num)
    for (new i=0; i<num; i++)
    {
        pv = players[i]
        get_user_name(pv, name, charsmax(name))
        accessUser(pv, name)
    }

    return PLUGIN_HANDLED
}

getAccess(id, name[], authid[], ip[], password[])
{
    static index, result, i
    index = -1
    result = 0

    for (i = 0; i < g_aNum; ++i)
    {
        if (g_aFlags[i] & FLAG_AUTHID)
        {
            if (equal(authid, g_aName[i]))
            {
                index = i
                break
            }
        }
        else if (g_aFlags[i] & FLAG_IP)
        {
            static c
            c = strlen(g_aName[i])

            if (g_aName[i][c - 1] == '.')       /* check if this is not a xxx.xxx. format */
            {
                if (equal(g_aName[i], ip, c))
                {
                    index = i
                    break
                }
            }                                   /* in other case an IP must just match */
            else if (equal(ip, g_aName[i]))
            {
                index = i
                break
            }
        }
        else
        {
            if (g_aFlags[i] & FLAG_TAG)
            {
                if (contain(name, g_aName[i]) != -1)
                {
                    index = i
                    break
                }
            }
            else if (equal(name, g_aName[i]))
            {
                index = i
                break
            }
        }
    }

    if (index != -1)
    {
        if (g_aFlags[index] & FLAG_NOPASS)
        {
            result |= 8
            new sflags[32]

            get_flags(g_aAccess[index], sflags, charsmax(sflags))
            set_user_flags(id, g_aAccess[index])

            if(!has_rcon(id))
                log_amx("^"%s^", access ^"%s^"", name, sflags)
        }
        else if (equal(password, g_aPassword[index]))
        {
            result |= 12
            set_user_flags(id, g_aAccess[index])

            static sflags[32]
            get_flags(g_aAccess[index], sflags, charsmax(sflags))

            log_amx("^"%s^", access ^"%s^"", name, sflags)
        }
        else
        {
            result |= 1

            if (g_aFlags[index] & FLAG_KICK)
            {
                result |= 2
                log_amx("^"%s^" has invalid password (_pw ^"%s^") (password ^"%s^")", name, password, g_aPassword[index])
            }
        }
    }
    else if (get_cvar_float("amx_mode") == 2.0)
    {
        result |= 2
    }
    else
    {
        static defaccess[32]
        get_cvar_string("amx_default_access", defaccess, charsmax(defaccess))
        static idefaccess
        idefaccess = read_flags(defaccess)

        if (idefaccess)
        {
            result |= 8
            set_user_flags(id, idefaccess)
        }
    }

    return result
}

accessUser(id, name[] = "")
{
    remove_user_flags(id)

    static userip[32], userauthid[32], password[32], passfield[32], username[32]

    get_user_ip(id, userip, charsmax(userip), 1)
    get_user_authid(id, userauthid, charsmax(userauthid))

    if (name[0])
        copy(username, charsmax(username), name)
    else
        get_user_name(id, username, charsmax(username))

    get_cvar_string("amx_password_field", passfield, charsmax(passfield))
    get_user_info(id, passfield, password, charsmax(password))

    static result
    result = getAccess(id, username, userauthid, userip, password)

    if (result & 1)
        client_cmd(id, "echo ^"* %L^"", id, "INV_PAS")

    if (result & 2)
    {
        client_cmd(id, "%s", g_cmdLoopback)
        return PLUGIN_HANDLED
    }

    if (result & 4)
        client_cmd(id, "echo ^"* %L^"", id, "PAS_ACC")

    if (result & 8)
        client_cmd(id, "echo ^"* %L^"", id, "PRIV_SET")

    return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE

    static newname[32], oldname[32]

    get_user_name(id, oldname, charsmax(oldname))
    get_user_info(id, "name", newname, charsmax(newname))

    if (!equal(newname, oldname))
        accessUser(id, newname)

    return PLUGIN_CONTINUE
}

public ackSignal(id)
{
    server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "NO_ENTRY")
    return PLUGIN_HANDLED
}

public client_authorized(id)
{
    accessUser(id)
    return PLUGIN_CONTINUE
}
