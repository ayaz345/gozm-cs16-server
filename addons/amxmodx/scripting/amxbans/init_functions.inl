/************  Start fetch reasons  *****************/
public fetchReasons(id)
{
	new query[512]
	new data[1]
	
	format(query, 511, "SELECT reason FROM %s", tbl_reasons)
	
	data[0] = id
	
	SQL_ThreadQuery(g_SqlX, "fetchReasons_", query, data, 1)
}

public fetchReasons_(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 5 )
	}
	else
	{
		if (!SQL_NumResults(query))
		{
			server_print("[AMXBANS] %L",LANG_SERVER,"NO_REASONS")
			
			format(g_banReasons[0], 127, "%L", LANG_SERVER, "REASON_1")
			format(g_banReasons[1], 127, "%L", LANG_SERVER, "REASON_2")
			format(g_banReasons[2], 127, "%L", LANG_SERVER, "REASON_3")
			format(g_banReasons[3], 127, "%L", LANG_SERVER, "REASON_4")
			format(g_banReasons[4], 127, "%L", LANG_SERVER, "REASON_5")
			format(g_banReasons[5], 127, "%L", LANG_SERVER, "REASON_6")
			format(g_banReasons[6], 127, "%L", LANG_SERVER, "REASON_7")
		
			server_print("[AMXBANS] %L",LANG_SERVER,"SQL_LOADED_STATIC_REASONS")
			log_amx("[AMXBANS] %L",LANG_SERVER,"SQL_LOADED_STATIC_REASONS")

			g_aNum = 7
	
			return PLUGIN_HANDLED
		}
		else
		{
			g_aNum = 0
			while(SQL_MoreResults(query))
			{
				SQL_ReadResult(query, 0, g_banReasons[g_aNum], 127)
				SQL_NextRow(query)
				g_aNum++
			}
		}
		
		if (g_aNum == 1)
			server_print("[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASON" )
		else
			server_print("[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASONS", g_aNum )
	}
	
	return PLUGIN_HANDLED
}
