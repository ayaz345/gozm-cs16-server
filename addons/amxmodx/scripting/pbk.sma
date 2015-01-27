#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <logging>
#include <time>
#include <cstrike>

new const PLUGIN[]  = "Play or Be Kicked";
new const RELEASE[] = "1.5.243";
new const AUTHOR[]  = "Brad Jones";

#define CHECK_FREQ 5

// team flags
#define TEAM_T  1
#define TEAM_CT 2

// event flags
#define EVENT_JOIN 1
#define EVENT_SPEC 2
#define EVENT_AFK  4

// player 
#define MAX_PLAYER_CNT 33	// really 32, but 32 is 0-31 and we want 1-32, so... 33


new g_playerJoined[MAX_PLAYER_CNT], g_playerSpawned[MAX_PLAYER_CNT];
new g_timeJoin[MAX_PLAYER_CNT], g_timeSpec[MAX_PLAYER_CNT], g_timeAFK[MAX_PLAYER_CNT], g_timeSpecQuery[MAX_PLAYER_CNT];
new Float:g_prevDistance[MAX_PLAYER_CNT];
new g_joinImmunity[32], g_specImmunity[32], g_afkImmunity[32];

new bool:g_roundInProgress = false;

new g_cvar_joinMinPlayers, g_cvar_joinTime, g_cvar_joinImmunity;
new g_cvar_specMinPlayers, g_cvar_specTime, g_cvar_specImmunity, g_cvar_specQuery;
new g_cvar_afkMinPlayers, g_cvar_afkTime, g_cvar_afkImmunity;
new g_cvar_log, g_cvar_logCnt;
new g_cvar_kick2ip, g_cvar_kick2port;

public plugin_init()
{
	register_plugin(PLUGIN, RELEASE, AUTHOR);
	
	register_cvar("pbk_debug", "-1");
	register_cvar("pbk_version", RELEASE, FCVAR_SERVER|FCVAR_SPONLY);  // For GameSpy/HLSW and such

	register_dictionary("pbk.txt");
	register_dictionary("time.txt");

	register_event("ResetHUD", "event_resethud", "be");

	register_forward(FM_PlayerPostThink, "fm_playerPostThink");
	register_logevent("event_round_start", 2, "0=World triggered", "1=Round_Start");
	register_logevent("event_round_end", 2, "0=World triggered", "1=Round_End")	;
	
	g_cvar_joinMinPlayers		= register_cvar("pbk_join_min_players", "4");
	g_cvar_joinTime					= register_cvar("pbk_join_time", "120");
	g_cvar_joinImmunity			= register_cvar("pbk_join_immunity_flags", "");
	
	g_cvar_specMinPlayers		= register_cvar("pbk_spec_min_players", "4");
	g_cvar_specTime					= register_cvar("pbk_spec_time", "120");
	g_cvar_specImmunity			= register_cvar("pbk_spec_immunity_flags", "");
	g_cvar_specQuery				= register_cvar("pbk_spec_query", "0");
	
	g_cvar_afkMinPlayers		= register_cvar("pbk_afk_min_players", "4");
	g_cvar_afkTime					= register_cvar("pbk_afk_time", "90");
	g_cvar_afkImmunity			= register_cvar("pbk_afk_immunity_flags", "");

	g_cvar_log 							= register_cvar("pbk_log", "3");
	g_cvar_logCnt 					= register_cvar("pbk_log_cnt", "2");

	g_cvar_kick2ip					= register_cvar("pbk_kick2_ip", "");
	g_cvar_kick2port				= register_cvar("pbk_kick2_port", "27015");
	
}

public plugin_cfg()
{
	new configDir[255];
	formatex(configDir[get_configsdir(configDir, sizeof(configDir)-1)], sizeof(configDir)-1, "/");
	server_cmd("exec %spbk.cfg", configDir);
	server_exec();
	
	get_pcvar_string(g_cvar_joinImmunity, g_joinImmunity, sizeof(g_joinImmunity)-1);
	get_pcvar_string(g_cvar_specImmunity, g_specImmunity, sizeof(g_specImmunity)-1);
	get_pcvar_string(g_cvar_afkImmunity, g_afkImmunity, sizeof(g_afkImmunity)-1);	

	cycle_log_files("pbk", clamp(get_pcvar_num(g_cvar_logCnt), 0, 11)); // must keep between 0 and 11 months

	register_menucmd(register_menuid("pbk_AreYouThere"), (1<<0)|(1<<1), "query_answered");
	
	set_task(float(CHECK_FREQ), "check_players", _, _, _, "b");
}

public fm_playerPostThink(id)
{
	if (!g_playerJoined[id])
	{
		// if the player is on the T or CT team or is spectating, they have "fully joined"
		new team[2], teamID = get_user_team(id, team, 1);
		if (teamID == TEAM_T || teamID == TEAM_CT || team[0] == 'S') g_playerJoined[id] = true;
	}
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	g_playerJoined[id] = false;
	g_playerSpawned[id] = false;
	
	g_timeJoin[id] = 0;
	g_timeSpec[id] = 0;
	g_timeAFK[id] = 0;
}

public event_resethud(id)
{
	if (!g_playerSpawned[id]) g_playerSpawned[id] = true;
}

public event_round_end()
{
	g_roundInProgress = false;
}

public event_round_start()
{
	// reset the coords of each player (for use in AFK checking)
	new players[32], playerCnt, id;
	get_players(players, playerCnt, "ch"); // skip bots and hltv
	
	for (new playerIdx = 0; playerIdx < playerCnt; playerIdx++)
	{
		id = players[playerIdx];
		new target, body
		g_prevDistance[id] = get_user_aiming(id, target, body)
	}
	
	// note that the round has started
	g_roundInProgress = true;
}

public check_players()
{
	new playerCnt = get_playersnum();
	new team[2], eventType, Float:curDistance, Float:prevDistance;

	new bool:checkJoinStatus = (get_pcvar_num(g_cvar_joinTime) && playerCnt >= get_pcvar_num(g_cvar_joinMinPlayers));
	new bool:checkSpecStatus = (get_pcvar_num(g_cvar_specTime) && playerCnt >= get_pcvar_num(g_cvar_specMinPlayers));
	new bool:checkAFKStatus  = (get_pcvar_num(g_cvar_afkTime)  && playerCnt >= get_pcvar_num(g_cvar_afkMinPlayers) && g_roundInProgress);

	new players[32], id;
	get_players(players, playerCnt, "ch"); // skip bots and hltv
	
	for (new playerIdx = 0; playerIdx < playerCnt; playerIdx++)
	{
		id = players[playerIdx];

		if (g_playerJoined[id])
		{
			get_user_team(id, team, 1);
			eventType = (team[0] == 'S') ? EVENT_SPEC : EVENT_AFK;

			if (eventType == EVENT_AFK && checkAFKStatus && g_playerSpawned[id] && is_user_alive(id))
			{
				// grab the current distance of the player
				static target, body
				curDistance = get_user_aiming(id, target, body);
				
				// compare to previous coords
				prevDistance = g_prevDistance[id];
				if (prevDistance == curDistance)
				{
					g_timeAFK[id] += CHECK_FREQ;
				}
				else
				{
					g_prevDistance[id] = curDistance;
					g_timeAFK[id] = 0;
				}
			}
			else if (eventType == EVENT_SPEC && checkSpecStatus)
			{
				g_timeSpec[id] += determine_spec_time_elapsed(id);
			}
			else continue;
		}
		else 
		{
			eventType = EVENT_JOIN;
			if (checkJoinStatus) g_timeJoin[id] += CHECK_FREQ;
			else continue;
		}
		handle_time_elapsed(id, eventType);
	}
}

determine_spec_time_elapsed(id)
{
	new timeElapsed = 0;

	if (get_pcvar_num(g_cvar_specQuery))
	{
		g_timeSpecQuery[id] += CHECK_FREQ;
		
		if (g_timeSpecQuery[id] == 45)
		{
			display_spec_query(id);
		}
		else if (g_timeSpecQuery[id] >= 55)
		{
			timeElapsed = g_timeSpecQuery[id] - CHECK_FREQ;
			g_timeSpecQuery[id] = CHECK_FREQ;
		}
	}
	else
	{	
		timeElapsed = CHECK_FREQ;
	}

	return timeElapsed;
}

display_spec_query(id)
{
	new query[192];
	formatex(query, sizeof(query)-1, "\r%L\R^n^n\y1.\w %L^n\y2.\w %L", id, "KICK_SPEC_AREYOUTHERE", id, "YES", id, "NO");
	show_menu(id, (1<<0)|(1<<1), query, 4, "pbk_AreYouThere");
}

public query_answered(id, key)
{
	//g_timeSpec[id] -= g_timeSpecQuery[id];
	g_timeSpecQuery[id] = 0;
}

public handle_time_elapsed(id, eventType)
{
	new maxSeconds, elapsedSeconds, eventImmunity;
	if (eventType == EVENT_JOIN)
	{
		maxSeconds = get_pcvar_num(g_cvar_joinTime);
		elapsedSeconds = g_timeJoin[id];
		eventImmunity = has_flag(id, g_joinImmunity);
	}
	else if (eventType == EVENT_SPEC)
	{
		maxSeconds = get_pcvar_num(g_cvar_specTime);
		elapsedSeconds = g_timeSpec[id];
		eventImmunity = has_flag(id, g_specImmunity) || has_rcon(id);
	}
	else if (eventType == EVENT_AFK)
	{
		maxSeconds = get_pcvar_num(g_cvar_afkTime);
		elapsedSeconds = g_timeAFK[id];
		eventImmunity = has_flag(id, g_afkImmunity);
	}
	else return;
	
	if (elapsedSeconds >= maxSeconds) 
	{
		// if players have immunity for this event abort
		if (eventImmunity) return;

		// get the correct message formats for this event type
		new msgReason[32], msgAnnounce[32];
		switch (eventType)
		{
			case EVENT_JOIN:
			{
				copy(msgReason, 31, "KICK_JOIN_REASON");
				copy(msgAnnounce, 31, "KICK_JOIN_ANNOUNCE");
			}
			case EVENT_SPEC:
			{
				copy(msgReason, 31, "KICK_SPEC_REASON");
				copy(msgAnnounce, 31, "KICK_SPEC_ANNOUNCE");
			}
			case EVENT_AFK:
			{
				copy(msgReason, 31, "KICK_AFK_REASON");
				copy(msgAnnounce, 31, "KICK_AFK_ANNOUNCE");
			}
		}

		new maxTime[128];
		get_time_length(id, maxSeconds, timeunit_seconds, maxTime, 127);

		new kick2ip[32];
		get_pcvar_string(g_cvar_kick2ip, kick2ip, sizeof(kick2ip)-1);

		if (kick2ip[0] == 0)
		{
			// kick the player into the nether
			server_cmd("kick #%d %L", get_user_userid(id), id, msgReason, maxTime);
		}
		else
		{
			// kick the player into another server
			new kick2port[16];
			get_pcvar_string(g_cvar_kick2port, kick2port, sizeof(kick2port)-1);
	
			client_cmd(id, "Connect %s:%s", kick2ip, kick2port);
		}

		// log the kick
		new logFlags = get_pcvar_num(g_cvar_log);
		if (logFlags)
		{
            get_time_length(0, maxSeconds, timeunit_seconds, maxTime, 127);

            new logText[128];
            format(logText, 127, "%L", LANG_SERVER, msgAnnounce, "", maxTime);
            // remove the single space that not providing a name added
            trim(logText);

            //create_log_entry(id, "PBK", logFlags, logText);
            new name[32];
            get_user_name(id, name, 31);
            log_amx("[PBK]: ^"%s^" %s", name, logText);
		}
	}
}