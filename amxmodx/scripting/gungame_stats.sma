#include <amxmodx>
#include <sqlx>

#define PLUGIN "GunGame Stats"
#define VERSION "2.0"
#define AUTHOR "GmStaff"

new gg_sql_host, gg_sql_user, gg_sql_pass, gg_sql_db, gg_sql_table
new gg_stats_invalid_steam

new Handle:tuple, Handle:db

new g_query[512]
new g_sqlTable[32]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	gg_sql_host = get_cvar_pointer("gg_sql_host")
	gg_sql_user = get_cvar_pointer("gg_sql_user")
	gg_sql_pass = get_cvar_pointer("gg_sql_pass")
	gg_sql_db = get_cvar_pointer("gg_sql_db")
	gg_sql_table = get_cvar_pointer("gg_sql_table")
	
	gg_stats_invalid_steam = register_cvar("gg_stats_invalid_steam", "'STEAM_ID_LAN', 'STEAM_ID_PENDING', 'VALVE_ID_LAN', 'VALVE_ID_PENDING'")
	
	set_task(1.5, "sql_init")
}

public sql_init()
{
	new host[32], user[32], pass[32], dbname[32]
	get_pcvar_string(gg_sql_host,host,31)
	get_pcvar_string(gg_sql_user,user,31)
	get_pcvar_string(gg_sql_pass,pass,31)
	get_pcvar_string(gg_sql_db,dbname,31)

	new sqlErrorCode, sqlError[1024]
	
	
	tuple = SQL_MakeDbTuple(host,user,pass,dbname)
	
	if(tuple == Empty_Handle)
	{
		log_amx("Could not create database tuple. Error #%i: %s",sqlErrorCode,sqlError)
		return
	}
	
	db = SQL_Connect(tuple,sqlErrorCode,sqlError,1023)

	if(db == Empty_Handle)
	{
		log_amx("Could not connect to database. Error #%i: %s",sqlErrorCode,sqlError)
		return
	}
	
	SQL_FreeHandle(db)
	
	get_pcvar_string(gg_sql_table,g_sqlTable,31)
	
	formatex(g_query, charsmax(g_query), "ALTER TABLE  `%s` ADD  `rank` INT NOT NULL DEFAULT  '0'", g_sqlTable)
	SQL_ThreadQuery(tuple, "threadQueryHandler", g_query, "1", 2)
}

public threadQueryHandler(failstate,Handle:query,error[],errnum,data[],size,Float:queuetime)
{
	static status
	if (!status)
	{
		status = 1
		new invalid_steam[256]
		get_pcvar_string(gg_stats_invalid_steam, invalid_steam, charsmax(invalid_steam))
		formatex(g_query, charsmax(g_query), "SET @r = 0;UPDATE `%s` SET `rank` = (@r := @r + 1) WHERE `authid` NOT IN (%s) ORDER BY `wins` DESC, `points` DESC", g_sqlTable, invalid_steam)
		SQL_ThreadQuery(tuple, "threadQueryHandler", g_query)
	}
	else
	{
		SQL_FreeHandle(tuple)
	}
}