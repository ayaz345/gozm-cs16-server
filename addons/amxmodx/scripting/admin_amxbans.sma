#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#define MAX_ADMINS 64

#define ADMIN_LOOKUP	(1<<0)
#define ADMIN_NORMAL	(1<<1)
#define ADMIN_STEAM		(1<<2)
#define ADMIN_IPADDR	(1<<3)
#define ADMIN_NAME		(1<<4)

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

	format(g_cmdLoopback, 15, "amxauth%c%c%c%c", random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'), random_num('A', 'Z'))

	register_clcmd(g_cmdLoopback, "ackSignal")

	remove_user_flags(0, read_flags("z"))		// Remove 'user' flag from server rights

	new configsDir[64]
	get_configsdir(configsDir, 63)
	
	server_cmd("exec %s/amxx.cfg", configsDir)	// Execute main configuration file
	server_cmd("exec %s/sql.cfg", configsDir)
    
	server_cmd("amx_sqladmins")
}

public plugin_cfg()
{
	new configFile[64], curMap[32]

	get_configsdir(configFile, 31)
	get_mapname(curMap, 31)

	new len = format(configFile, 63, "%s/maps/%s.cfg", configFile, curMap)

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
	new a, pos = 0

	while (g_aNum < MAX_ADMINS && read_file(szFilename, pos++, szText, 255, a))
	{
		if (szText[0] == ';')
			continue

		if (parse(szText, g_aName[g_aNum], 31, g_aPassword[g_aNum], 31, szAccess, 31, szFlags, 31) < 2)
			continue

		g_aAccess[g_aNum] = read_flags(szAccess)
		g_aFlags[g_aNum] = read_flags(szFlags)
		++g_aNum
	}
	
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
    new Handle:sql = SQL_Connect(info, errno, error, 127)

    // This is a new way of getting the port number
    new ip_port[42], ip_tmp[32], ip[32] , port[10]
    get_user_ip(0, ip_port, 41)
    strtok(ip_port, ip_tmp, 31, port, 9, ':')
    get_cvar_string("ip",ip,32)

    SQL_GetAffinity(type, 11)

    if (sql == Empty_Handle)
    {
        server_print("[AMX_ADMINS] Cant connect to database: %s", error)
        
        //backup to users.ini
        new configsDir[64]
        
        get_configsdir(configsDir, 63)
        format(configsDir, 63, "%s/users.ini", configsDir)
        loadSettings(configsDir) // Load admins accounts

        return PLUGIN_HANDLED
    }

    new Handle:query
    query = SQL_PrepareQuery(sql, "\
        SELECT amx_amxadmins.username, \
               amx_amxadmins.password, \
               amx_amxadmins.access, \
               amx_amxadmins.flags \
        FROM amx_amxadmins\
    ")

    if (!SQL_Execute(query))
    {
        SQL_QueryError(query, error, 127)
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
            SQL_ReadResult(query, qcolAuth, g_aName[g_aNum], 31)
            SQL_ReadResult(query, qcolPass, g_aPassword[g_aNum], 31)
            SQL_ReadResult(query, qcolAccess, szAccess, 31)
            SQL_ReadResult(query, qcolFlags, szFlags, 31)

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
		get_user_name(pv, name, 31)
		accessUser(pv, name)
	}

	return PLUGIN_HANDLED
}

getAccess(id, name[], authid[], ip[], password[])
{
	new index = -1
	new result = 0
	
	for (new i = 0; i < g_aNum; ++i)
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
			new c = strlen(g_aName[i])
			
			if (g_aName[i][c - 1] == '.')		/* check if this is not a xxx.xxx. format */
			{
				if (equal(g_aName[i], ip, c))
				{
					index = i
					break
				}
			}									/* in other case an IP must just match */
			else if (equal(ip, g_aName[i]))
			{
				index = i
				break
			}
		} else {
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
			
            get_flags(g_aAccess[index], sflags, 31)
            set_user_flags(id, g_aAccess[index])
			
            if(!has_rcon(id))
                log_amx("^"%s<%s><%s>^", account ^"%s^", access ^"%s^"", name, authid, ip, g_aName[index], sflags)
		}
		else if (equal(password, g_aPassword[index]))
		{
			result |= 12
			set_user_flags(id, g_aAccess[index])
			
			new sflags[32]
			get_flags(g_aAccess[index], sflags, 31)
			
			log_amx("^"%s<%s><%s>^", account ^"%s^", access ^"%s^"", name, authid, ip, g_aName[index], sflags)
		} else {
			result |= 1
			
			if (g_aFlags[index] & FLAG_KICK)
			{
				result |= 2
				log_amx("^"%s<%d><%s><>^" kicked due to invalid password (account ^"%s^") (address ^"%s^") (_pw ^"%s^") (password ^"%s^")", name, get_user_userid(id), authid, g_aName[index], ip, password, g_aPassword[index])
			}
		}
	}
	else if (get_cvar_float("amx_mode") == 2.0)
	{
		result |= 2
	} else {
		new defaccess[32]
		
		get_cvar_string("amx_default_access", defaccess, 31)
		new idefaccess = read_flags(defaccess)
		
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
	
	new userip[32], userauthid[32], password[32], passfield[32], username[32]
	
	get_user_ip(id, userip, 31, 1)
	get_user_authid(id, userauthid, 31)
	
	if (name[0])
		copy(username, 31, name)
	else
		get_user_name(id, username, 31)
	
	get_cvar_string("amx_password_field", passfield, 31)
	get_user_info(id, passfield, password, 31)
	
	new result = getAccess(id, username, userauthid, userip, password)
	
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

	new newname[32], oldname[32]
	
	get_user_name(id, oldname, 31)
	get_user_info(id, "name", newname, 31)

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
	return accessUser(id)  // PLUGIN_CONTINUE
