/*================================================================================
	
	------------------------------------
	-*- Lame Connection Punisher 1.2 -*-
	------------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This plugin improves your server's gameplay experience by automatically
	rejecting clients with "bad" conections, so that you'll never have to
	deal with players skipping around the map or being hard to hit anymore.
	
	It can also detect clients running any background applications that may
	be affecting their connection, such as P2P programs using up too many
	bandwidth.
	
	~~~~~~~~~~~~~~~~~~~~
	- How Does It Work -
	~~~~~~~~~~~~~~~~~~~~
	
	It checks for player's ping fluctuations and packet loss rates, since
	these seem to be the most trustable factors in determining if there are
	any issues, in my experience.
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~
	- What Makes It Different -
	~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	Other solutions, such as Hing Ping Kickers, usually can't tell apart
	players with good or bad connections accurately. They may not detect
	a bad connection if the player's ping is too low, and likewise, they
	may end up kicking a player who's ping exceeds the limit but has a
	nice connection nonetheless, thus making you loose potential players.
	
	~~~~~~~~~
	- CVARS -
	~~~~~~~~~
	
	There are 2 main cvars to control the plugin's behavior (tolerance),
	though the default values are recommended.
	
	Please note that small ping fluctuations and packet loss occur even
	on the best connections, so DO NOT set these too low, unless you are
	in for some nasty results!
	
	* lcp_flux_limit [50] - Ping fluctuation limit (in ms.)
	* lcp_loss_limit [5] - Loss limit (% of packets)
	
	Additionally, you can specify whether the plugin should kick or ban
	these players by changing the following settings.
	
	* lcp_punishment [0/1/2] - 0 = Kick / 1 = Ban by SteamID / 2 = Ban by IP
	* lcp_ban_time [5] - Ban time in minutes (use 0 to permanently ban)
	
	Lastly, players with the immunity flags will not be checked at all.
	
	* lcp_immunity ["a"] - Immunity flags
	
	~~~~~~~~~~~~~
	- Changelog -
	~~~~~~~~~~~~~
	
	* v1.0: (Jan 05, 2009)
	   - Public release
	   - Added ban support
	   - Added immunity feature
	
	* v1.1: (Feb 08, 2009)
	   - Code optimized
	
	* v1.1a: (Feb 24, 2009)
	   - Fixed IP ban code retrieving unneeded port number
	
	* v1.2: (Jun 06, 2011)
	   - Fixed plugin so that it works on all HL mods
	
=================================================================================*/

#include <amxmodx>

const TASK_JOINMSG = 100
const TASK_DOCHECKS = 200
#define ID_JOINMSG (taskid-TASK_JOINMSG)

new cvar_flux, cvar_loss, cvar_punishment, cvar_bantime, cvar_immunity
new g_maxplayers, g_connected[33]
new g_lastping[33], g_fluxcounter[33], g_losscounter[33], g_immune[33]

// I wouldn't recommend lowering these unless
// you wanna pick up a lot of false positives
const Float:CHECK_FREQ = 5.0
const FLUX_TESTS = 12
const LOSS_TESTS = 12

public plugin_init()
{
	register_plugin("Lame Connection Punisher", "1.2", "MeRcyLeZZ")
	register_dictionary("lame_connection_punisher.txt")
	
	cvar_flux = register_cvar("lcp_flux_limit", "50")
	cvar_loss = register_cvar("lcp_loss_limit", "5")
	cvar_punishment = register_cvar("lcp_punishment", "2")
	cvar_bantime = register_cvar("lcp_ban_time", "15")
	cvar_immunity = register_cvar("lcp_immunity", "a")
	g_maxplayers = get_maxplayers()
}

public plugin_cfg()
{
	// Start checking players
	set_task(CHECK_FREQ, "do_checks", TASK_DOCHECKS, _, _, "b")
}

public client_putinserver(id)
{
	set_task(20.0, "join_message", id+TASK_JOINMSG)
	g_connected[id] = true
	check_flags(id)
}

public client_authorized(id)
{
	check_flags(id)
}

public client_infochanged(id)
{
	check_flags(id)
}

public client_disconnect(id)
{
	remove_task(id+TASK_JOINMSG)
	g_fluxcounter[id] = 0
	g_losscounter[id] = 0
	g_lastping[id] = 0
	g_immune[id] = 0
	g_connected[id] = false
}

public do_checks()
{
	static id, ping, loss, name[32], auth[32], userid, minutes
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (!g_connected[id] || g_immune[id])
			continue;
		
		get_user_ping(id, ping, loss)
		
		if (loss > get_pcvar_num(cvar_loss))
			g_losscounter[id]++
		else if (g_losscounter[id] > 0)
			g_losscounter[id]--
		
		if (g_losscounter[id] >= LOSS_TESTS)
		{
			get_user_name(id, name , sizeof name - 1)
			userid = get_user_userid(id)
			
			switch (get_pcvar_num(cvar_punishment))
			{
				case 1:
				{
					get_user_authid(id, auth, sizeof auth - 1)
					minutes = get_pcvar_num(cvar_bantime)
					
					if (minutes > 0)
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_BAN", name, minutes)
						log_amx("%L", LANG_SERVER, "MSG_ALL_BAN", name, minutes)
						server_cmd("kick #%d ^"%L^";wait;banid %d ^"%s^";wait;writeid", userid, id, "MSG_TARGET_LOSS", minutes, auth)
					}
					else
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_PBAN", name)
						log_amx("%L", LANG_SERVER, "MSG_ALL_PBAN", name)
						server_cmd("kick #%d ^"%L^";wait;banid 0 ^"%s^";wait;writeid", userid, id, "MSG_TARGET_LOSS", auth)
					}
				}
				case 2:
				{
					get_user_ip(id, auth, sizeof auth - 1, 1)
					minutes = get_pcvar_num(cvar_bantime)
					
					if (minutes > 0)
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_BAN", name, minutes)
						log_amx("%L", LANG_SERVER, "MSG_ALL_BAN", name, minutes)
						server_cmd("kick #%d ^"%L^";wait;addip %d ^"%s^";wait;writeip", userid, id, "MSG_TARGET_LOSS", minutes, auth)
					}
					else
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_PBAN", name)
						log_amx("%L", LANG_SERVER, "MSG_ALL_PBAN", name)
						server_cmd("kick #%d ^"%L^";wait;addip 0 ^"%s^";wait;writeip", userid, id, "MSG_TARGET_LOSS", auth)
					}
				}
				default:
				{
					client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_KICK", name)
					log_amx("%L", LANG_SERVER, "MSG_ALL_KICK", name)
					server_cmd("kick #%d ^"%L^"", userid, id, "MSG_TARGET_LOSS")
				}
			}
			continue;
		}
		
		if (abs(ping - g_lastping[id]) > get_pcvar_num(cvar_flux))
			g_fluxcounter[id]++
		else if (g_fluxcounter[id] > 0)
			g_fluxcounter[id]--
		
		if (g_fluxcounter[id] >= FLUX_TESTS)
		{
			get_user_name(id, name , sizeof name - 1)
			userid = get_user_userid(id)
			
			switch (get_pcvar_num(cvar_punishment))
			{
				case 1:
				{
					get_user_authid(id, auth, sizeof auth - 1)
					minutes = get_pcvar_num(cvar_bantime)
					
					if (minutes > 0)
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_BAN", name, minutes)
						log_amx("%L", LANG_SERVER, "MSG_ALL_BAN", name, minutes)
						server_cmd("kick #%d ^"%L^";wait;banid %d ^"%s^";wait;writeid", userid, id, "MSG_TARGET_FLUX", minutes, auth)
					}
					else
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_PBAN", name)
						log_amx("%L", LANG_SERVER, "MSG_ALL_PBAN", name)
						server_cmd("kick #%d ^"%L^";wait;banid 0 ^"%s^";wait;writeid", userid, id, "MSG_TARGET_FLUX", auth)
					}
				}
				case 2:
				{
					get_user_ip(id, auth, sizeof auth - 1, 1)
					minutes = get_pcvar_num(cvar_bantime)
					
					if (minutes > 0)
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_BAN", name, minutes)
						log_amx("%L", LANG_SERVER, "MSG_ALL_BAN", name, minutes)
						server_cmd("kick #%d ^"%L^";wait;addip %d ^"%s^";wait;writeip", userid, id, "MSG_TARGET_FLUX", minutes, auth)
					}
					else
					{
						client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_PBAN", name)
						log_amx("%L", LANG_SERVER, "MSG_ALL_PBAN", name)
						server_cmd("kick #%d ^"%L^";wait;addip 0 ^"%s^";wait;writeip", userid, id, "MSG_TARGET_FLUX", auth)
					}
				}
				default:
				{
					client_print(0, print_chat, "[AMXX] %L", LANG_PLAYER, "MSG_ALL_KICK", name)
					log_amx("%L", LANG_SERVER, "MSG_ALL_KICK", name)
					server_cmd("kick #%d ^"%L^"", userid, id, "MSG_TARGET_FLUX")
				}
			}
			continue;
		}
		
		g_lastping[id] = ping
	}
}

public join_message(taskid)
{
	client_print(ID_JOINMSG, print_chat, "[AMXX] %L", ID_JOINMSG, "JOIN_MSG", get_pcvar_num(cvar_flux), get_pcvar_num(cvar_loss))
}

check_flags(id)
{
	new flags[6]
	get_pcvar_string(cvar_immunity, flags, charsmax(flags))
	g_immune[id] = get_user_flags(id) & read_flags(flags)
}
