#define VERSION	"2.00 Beta 3"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <engine>
#include <fun>
#include <cs_player_models_api>
#include <cs_maxspeed_api>
#include <cs_team_changer>
#include <cs_weap_models_api>
#include <colored_print>
#include <dhudmessage>

#tryinclude "biohazard.cfg"

#if !defined _biohazardcfg_included
	#assert Biohazard configuration file required!
#elseif AMXX_VERSION_NUM < 180
	#assert AMX Mod X v1.8.0 or greater required!
#endif

#define OFFSET_DEATH 444
#define OFFSET_TEAM 114
#define OFFSET_ARMOR 112
#define OFFSET_NVG 129
#define OFFSET_CSMONEY 115
#define OFFSET_PRIMARYWEAPON 116
#define OFFSET_WEAPONTYPE 43
#define OFFSET_CLIPAMMO	51
#define EXTRAOFFSET_WEAPONS 4

#define OFFSET_AMMO_338MAGNUM 377
#define OFFSET_AMMO_762NATO 378
#define OFFSET_AMMO_556NATOBOX 379
#define OFFSET_AMMO_556NATO 380
#define OFFSET_AMMO_BUCKSHOT 381
#define OFFSET_AMMO_45ACP 382
#define OFFSET_AMMO_57MM 383
#define OFFSET_AMMO_50AE 384
#define OFFSET_AMMO_357SIG 385
#define OFFSET_AMMO_9MM 386

#define OFFSET_LASTPRIM 368
#define OFFSET_LASTSEC 369
#define OFFSET_LASTKNI 370

#define TASKID_STRIPNGIVE 698
#define TASKID_NEWROUND	641
#define TASKID_INITROUND 222
#define TASKID_STARTROUND 153
#define TASKID_BALANCETEAM 375
#define TASKID_NIGHTVISION 376
#define TASKID_UPDATESCR 264
#define TASKID_SPAWNDELAY 786
#define TASKID_WEAPONSMENU 564
#define TASKID_CHECKSPAWN 423
#define TASKID_CZBOTPDATA 312
#define TASKID_TERBUG 666
#define TASKID_RESTOREFADE 1598
#define ID_RESTOREFADE (taskid - TASKID_RESTOREFADE)
#define TASKID_SHOWCLEAN 667
#define TASKID_SHOWINFECT 668

#define EQUIP_PRI (1<<0)
#define EQUIP_SEC (1<<1)
#define EQUIP_GREN (1<<2)
/////////////////// prohibit grenade equipment ////////////////////
#define EQUIP_ALL (1<<0 | 1<<1 | 1<<2)

#define HAS_NVG (1<<0)
#define ATTRIB_BOMB (1<<1)
#define DMG_HEGRENADE (1<<24)

#define MODEL_CLASSNAME "player_model"
#define IMPULSE_FLASHLIGHT 100
#define UNIT_SECOND (1<<12)
#define FFADE_STAYOUT 0x0004

#define MAX_SPAWNS 128
#define MAX_CLASSES 10
#define MAX_DATA 11

#define DATA_HEALTH 0
#define DATA_SPEED 1
#define DATA_GRAVITY 2
#define DATA_ATTACK 3
#define DATA_DEFENCE 4
#define DATA_HEDEFENCE 5
#define DATA_HITSPEED 6
#define DATA_HITDELAY 7
#define DATA_REGENDLY 8
#define DATA_HITREGENDLY 9
#define DATA_KNOCKBACK 10

#define fm_get_user_model(%1,%2,%3) engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, %1), "model", %2, %3) 

#define fm_lastprimary(%1) get_pdata_cbase(%1, OFFSET_LASTPRIM)
#define fm_lastsecondry(%1) get_pdata_cbase(%1, OFFSET_LASTSEC)
#define _random(%1) random_num(0, %1 - 1)
#define AMMOWP_NULL (1<<0 | 1<<CSW_KNIFE | 1<<CSW_FLASHBANG | 1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_C4)

stock const INGAME_JOIN_MSG[] =		"#IG_Team_Select";
stock const INGAME_JOIN_MSG_SPEC[] =	"#IG_Team_Select_Spect";
// New VGUI Menus
stock const VGUI_JOIN_TEAM_NUM =		2;
const iMaxLen = sizeof(INGAME_JOIN_MSG_SPEC);

enum
{
	MAX_CLIP = 0,
	MAX_AMMO
}

enum
{
	MENU_PRIMARY = 1,
	MENU_SECONDARY
}

enum
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

enum
{
	CS_ARMOR_NONE = 0,
	CS_ARMOR_KEVLAR,
	CS_ARMOR_VESTHELM
}

enum
{
	KBPOWER_357SIG = 0,
	KBPOWER_762NATO,
	KBPOWER_BUCKSHOT,
	KBPOWER_45ACP,
	KBPOWER_556NATO,
	KBPOWER_9MM,
	KBPOWER_57MM,
	KBPOWER_338MAGNUM,
	KBPOWER_556NATOBOX,
	KBPOWER_50AE
}

new const g_weapon_ammo[][] =
{
	{ -1, -1 },
	{ 13, 52 },
	{ -1, -1 },
	{ 2, 90 },
	{ -1, -1 },
	{ 7, 32 },
	{ -1, -1 },
	{ 30, 100 },
	{ 30, 90 },
	{ -1, -1 },
	{ 30, 120 },
	{ 20, 100 },
	{ 25, 100 },
	{ 30, 90 },
	{ 35, 90 },
	{ 25, 90 },
	{ 12, 100 },
	{ 20, 120 },
	{ 2, 30 },
	{ 30, 120 },
	{ 30, 200 },
	{ 8, 32 },
	{ 30, 90 },
	{ 30, 120 },
	{ 10, 90 },
	{ -1, -1 },
	{ 7, 35 },
	{ 10, 90 },
	{ 30, 90 },
	{ -1, -1 },
	{ 30, 100 }
}

new const g_weapon_knockback[] =
{
	-1, 
	KBPOWER_357SIG, 
	-1, 
	KBPOWER_762NATO, 
	-1, 
	KBPOWER_BUCKSHOT, 
	-1, 
	KBPOWER_45ACP, 
	KBPOWER_556NATO, 
	-1, 
	KBPOWER_9MM, 
	KBPOWER_57MM,
	KBPOWER_45ACP, 
	KBPOWER_556NATO, 
	KBPOWER_556NATO, 
	KBPOWER_556NATO, 
	KBPOWER_45ACP,
	KBPOWER_9MM, 
	KBPOWER_338MAGNUM,
	KBPOWER_9MM, 
	KBPOWER_556NATOBOX,
	KBPOWER_BUCKSHOT, 
	KBPOWER_556NATO, 
	KBPOWER_9MM, 
	KBPOWER_762NATO, 
	-1, 
	KBPOWER_50AE, 
	KBPOWER_556NATO, 
	KBPOWER_762NATO, 
	-1, 
	KBPOWER_57MM
}

new const g_remove_entities[][] = 
{ 
	"func_bomb_target",    
	"info_bomb_target", 
	"hostage_entity",      
	"monster_scientist", 
	"func_hostage_rescue", 
	"info_hostage_rescue",
	"info_vip_start",      
	"func_vip_safetyzone", 
	"func_escapezone",     
	"func_buyzone"
}

new const g_dataname[][] = 
{ 
	"HEALTH", 
	"SPEED", 
	"GRAVITY", 
	"ATTACK", 
	"DEFENCE", 
	"HEDEFENCE", 
	"HITSPEED", 
	"HITDELAY", 
	"REGENDLY", 
	"HITREGENDLY", 
	"KNOCKBACK" 
}
new const g_teaminfo[][] = 
{ 
	"UNASSIGNED", 
	"TERRORIST",
	"CT",
	"SPECTATOR" 
}

new g_maxplayers, g_spawncount, g_buyzone, g_botclient_pdata,
    g_sync_msgdisplay, g_fwd_spawn, g_fwd_result, g_fwd_infect, g_fwd_gamestart,
    g_msg_flashlight, g_msg_teaminfo, g_msg_scoreattrib, g_msg_scoreinfo, 
    g_msg_deathmsg , g_msg_screenfade, g_msgScreenShake, Float:g_buytime,  Float:g_spawns[MAX_SPAWNS+1][9],
    Float:g_vecvel[3], bool:g_brestorevel, bool:g_infecting, bool:g_gamestarted,
    bool:g_roundstarted, bool:g_roundended, g_class_name[MAX_CLASSES+1][32], 
    g_classcount, g_class_desc[MAX_CLASSES+1][32], g_class_pmodel[MAX_CLASSES+1][64], 
    g_class_wmodel[MAX_CLASSES+1][64], Float:g_class_data[MAX_CLASSES+1][MAX_DATA], last_zombie
    
new cvar_randomspawn, cvar_skyname, cvar_autoteambalance[4], cvar_starttime, cvar_autonvg, 
    cvar_weaponsmenu, cvar_lights, cvar_killbonus, cvar_enabled, 
    cvar_gamedescription, cvar_botquota, cvar_maxzombies, cvar_flashbang, cvar_buytime, 
	cvar_punishsuicide, cvar_showtruehealth,
    cvar_obeyarmor, cvar_impactexplode,
    cvar_knockback, cvar_knockback_dist, cvar_ammo,
	cvar_killreward, cvar_painshockfree, cvar_zombie_class,
    cvar_shootobjects, cvar_pushpwr_weapon, cvar_pushpwr_zombie,
	cvar_nvgcolor_hum[3], cvar_nvgcolor_zm[3], cvar_nvgcolor_spec[3], cvar_nvgradius
    
new bool:g_zombie[25], bool:g_falling[25], bool:g_disconnected[25], bool:g_blockmodel[25], 
    bool:g_showmenu[25], bool:g_menufailsafe[25], bool:g_preinfect[25], 
    bool:g_suicide[25], g_mutate[25], g_victim[25],
    g_modelent[33], g_menuposition[25], g_player_class[25], g_player_weapons[25][2],
	lights[2], bool:stop_changing_name[25],
	activate_nv[25]

public plugin_precache()
{
	register_plugin("Biohazard", VERSION, "cheap_suit")
	register_cvar("bh_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	set_cvar_string("bh_version", VERSION)
	
	cvar_enabled = register_cvar("bh_enabled", "1")

	if(!get_pcvar_num(cvar_enabled)) 
		return
	
	cvar_gamedescription = register_cvar("bh_gamedescription", "[ ZOMBIE BIO ]")
	cvar_skyname = register_cvar("bh_skyname", "")
	cvar_lights = register_cvar("bh_lights", "m")
	cvar_starttime = register_cvar("bh_starttime", "15.0")
	cvar_buytime = register_cvar("bh_buytime", "30")
	cvar_randomspawn = register_cvar("bh_randomspawn", "1")
	cvar_punishsuicide = register_cvar("bh_punishsuicide", "0")
	cvar_autonvg = register_cvar("bh_autonvg", "0")
	cvar_painshockfree = register_cvar("bh_painshockfree", "1")
	cvar_knockback = register_cvar("bh_knockback", "1")
	cvar_knockback_dist = register_cvar("bh_knockback_dist", "280.0")
	cvar_obeyarmor = register_cvar("bh_obeyarmor", "0")
	cvar_weaponsmenu = register_cvar("bh_weaponsmenu", "1")
	cvar_ammo = register_cvar("bh_ammo", "1")
	cvar_maxzombies = register_cvar("bh_maxzombies", "23")
	cvar_flashbang = register_cvar("bh_flashbang", "1")
	cvar_impactexplode = register_cvar("bh_impactexplode", "1")
	cvar_showtruehealth = register_cvar("bh_showtruehealth", "1")
	cvar_zombie_class = register_cvar("bh_zombie_class", "0")
	cvar_killbonus = register_cvar("bh_kill_bonus", "1")
	cvar_killreward = register_cvar("bh_kill_reward", "2")
	cvar_shootobjects = register_cvar("bh_shootobjects", "1")
	cvar_pushpwr_weapon = register_cvar("bh_pushpwr_weapon", "3.0")
	cvar_pushpwr_zombie = register_cvar("bh_pushpwr_zombie", "3.0")
	cvar_nvgcolor_hum[0] = register_cvar("bh_nvg_color_hum_r", "0")
	cvar_nvgcolor_hum[1] = register_cvar("bh_nvg_color_hum_g", "30")
	cvar_nvgcolor_hum[2] = register_cvar("bh_nvg_color_hum_b", "30")
	cvar_nvgcolor_zm[0] = register_cvar("bh_nvg_color_zm_r", "0")
	cvar_nvgcolor_zm[1] = register_cvar("bh_nvg_color_zm_g", "150")
	cvar_nvgcolor_zm[2] = register_cvar("bh_nvg_color_zm_b", "2")
	cvar_nvgcolor_spec[0] = register_cvar("bh_nvg_color_spec_r", "30")
	cvar_nvgcolor_spec[1] = register_cvar("bh_nvg_color_spec_g", "30")
	cvar_nvgcolor_spec[2] = register_cvar("bh_nvg_color_spec_b", "0")	
	cvar_nvgradius = register_cvar("bh_nvg_radius", "255")
	
	new file[64]
	get_configsdir(file, 63)
	format(file, 63, "%s/bh_cvars.cfg", file)
	
	if(file_exists(file)) 
		server_cmd("exec %s", file)
	
	new mapname[32]
	get_mapname(mapname, 31)
	register_spawnpoints(mapname)
		
	register_zombieclasses("bh_zombieclass.ini")
	register_dictionary("biohazard.txt")
	
	precache_model(DEFAULT_PMODEL)
	precache_model(DEFAULT_WMODEL)
	
	new i
	for(i = 0; i < g_classcount; i++)
	{
		precache_model(g_class_pmodel[i])
		precache_model(g_class_wmodel[i])
	}
	
	for(i = 0; i < sizeof g_zombie_miss_sounds; i++)
		precache_sound(g_zombie_miss_sounds[i])
	
	for(i = 0; i < sizeof g_zombie_hit_sounds; i++) 
		precache_sound(g_zombie_hit_sounds[i])
	
	for(i = 0; i < sizeof g_scream_sounds; i++) 
		precache_sound(g_scream_sounds[i])
	
	for(i = 0; i < sizeof g_zombie_die_sounds; i++)
		precache_sound(g_zombie_die_sounds[i])
	
	g_fwd_spawn = register_forward(FM_Spawn, "fwd_spawn")
	
	g_buyzone = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if(g_buyzone) 
	{
		dllfunc(DLLFunc_Spawn, g_buyzone)
		set_pev(g_buyzone, pev_solid, SOLID_NOT)
	}
	
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_bomb_target"))
	if(ent) 
	{
		dllfunc(DLLFunc_Spawn, ent)
		set_pev(ent, pev_solid, SOLID_NOT)
	}
}

public plugin_init()
{
	if(!get_pcvar_num(cvar_enabled)) 
		return
	
	cvar_botquota = get_cvar_pointer("bot_quota")
	cvar_autoteambalance[0] = get_cvar_pointer("mp_autoteambalance")
	cvar_autoteambalance[1] = get_pcvar_num(cvar_autoteambalance[0])
	set_pcvar_num(cvar_autoteambalance[0], 0)

	register_clcmd("jointeam", "cmd_jointeam")
	register_clcmd("say /guns", "cmd_enablemenu")
	register_clcmd("say_team /guns", "cmd_enablemenu")
	register_clcmd("amx_infect", "cmd_infectuser", ADMIN_RCON|ADMIN_BAN, "<name or #userid>")
	register_clcmd("amx_cure", "cmd_cureuser", ADMIN_RCON|ADMIN_BAN, "<name or #userid>")
	register_clcmd("amx_drop", "cmd_dropuser", ADMIN_RCON|ADMIN_BAN, "<name or #userid>")
	register_clcmd("redirect_players", "cmd_redirect")
	register_clcmd("nightvision", "nightvision")
	
	register_menu("Equipment", 1023, "action_equip")
	register_menu("Primary", 1023, "action_prim")
	register_menu("Secondary", 1023, "action_sec")
	
	unregister_forward(FM_Spawn, g_fwd_spawn)
	register_forward(FM_CmdStart, "fwd_cmdstart")
	register_forward(FM_EmitSound, "fwd_emitsound")
	register_forward(FM_GetGameDescription, "fwd_gamedescription")
///////// to remove dropped weapon //////////	
	register_forward(FM_SetModel, "fw_SetModel")
/////////////////////////////////////////////	
	register_forward(FM_CreateNamedEntity, "fwd_createnamedentity")
	register_forward(FM_ClientKill, "fwd_clientkill")
	register_forward(FM_PlayerPreThink, "fwd_player_prethink")
	register_forward(FM_PlayerPreThink, "fwd_player_prethink_post", 1)
	register_forward(FM_PlayerPostThink, "fwd_player_postthink")
	register_forward(FM_SetClientKeyValue, "fwd_setclientkeyvalue")

	RegisterHam(Ham_TakeDamage, "player", "bacon_takedamage_player")
	RegisterHam(Ham_Killed, "player", "bacon_killed_player")
	RegisterHam(Ham_Spawn, "player", "bacon_spawn_player_post", 1)
	RegisterHam(Ham_TraceAttack, "player", "bacon_traceattack_player")
	RegisterHam(Ham_TraceAttack, "func_pushable", "bacon_traceattack_pushable")
	RegisterHam(Ham_Use, "func_tank", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tankmortar", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tankrocket", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_tanklaser", "bacon_use_tank")
	RegisterHam(Ham_Use, "func_pushable", "bacon_use_pushable")
	RegisterHam(Ham_Touch, "func_pushable", "bacon_touch_pushable")
	RegisterHam(Ham_Touch, "weaponbox", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "armoury_entity", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "weapon_shield", "bacon_touch_weapon")
	RegisterHam(Ham_Touch, "grenade", "bacon_touch_grenade")
	
	register_message(get_user_msgid("Health"), "msg_health")
	register_message(get_user_msgid("TextMsg"), "msg_textmsg")
////// added adiomsg //////	
	register_message(get_user_msgid("SendAudio"), "msg_audiomsg")
//////////////////////////	
	register_message(get_user_msgid("SayText"), "block_changename")
	register_message(get_user_msgid("StatusIcon"), "msg_statusicon")
	register_message(get_user_msgid("ScoreAttrib"), "msg_scoreattrib")
	register_message(get_user_msgid("DeathMsg"), "msg_deathmsg")
	register_message(get_user_msgid("ScreenFade"), "msg_screenfade")
	register_message(get_user_msgid("TeamInfo"), "msg_teaminfo")
	register_message(get_user_msgid("ClCorpse"), "msg_clcorpse")
	register_message(get_user_msgid("WeapPickup"), "msg_weaponpickup")
	register_message(get_user_msgid("AmmoPickup"), "msg_ammopickup")
///////////////////////// AutoJoin //////////////////////	
	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu")
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu")
	register_message(g_msg_screenfade, "msg_screenfade")
	
	register_event("TextMsg", "event_textmsg", "a", "2=#Game_will_restart_in")
	register_event("TextMsg", "event_textmsg", "a", "2=#Game_Commencing")
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	register_event("ArmorType", "event_armortype", "be")
	register_event("Damage", "event_damage", "be")
	register_event("StatusValue","show_status","be")
	
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	g_msg_flashlight = get_user_msgid("Flashlight")
	g_msg_teaminfo = get_user_msgid("TeamInfo")
	g_msg_scoreattrib = get_user_msgid("ScoreAttrib")
	g_msg_scoreinfo = get_user_msgid("ScoreInfo")
	g_msg_deathmsg = get_user_msgid("DeathMsg")
	g_msg_screenfade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	
	g_fwd_infect = CreateMultiForward("event_infect", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwd_gamestart = CreateMultiForward("event_gamestart", ET_IGNORE)

	g_sync_msgdisplay = CreateHudSyncObj()
	
	g_maxplayers = get_maxplayers()
	
	new skyname[32]
	get_pcvar_string(cvar_skyname, skyname, 31)
		
	if(strlen(skyname) > 0)
		set_cvar_string("sv_skyname", skyname)
	
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	get_pcvar_string(cvar_lights, lights, 1)
	if(strlen(lights) > 0) engfunc(EngFunc_LightStyle, 0, lights);
	
	if(get_pcvar_num(cvar_showtruehealth))
		set_task(0.5, "task_showtruehealth", _, _, _, "b")
		
//	set_task(1.0, "change_rcon", _, _, _, "b")
}
/*
public change_rcon()
{
	new rcon
	rcon = random_num(1000000, 9999999)
	server_cmd("rcon_password %d", rcon)
}
*/
public plugin_end()
{
	if(get_pcvar_num(cvar_enabled))
		set_pcvar_num(cvar_autoteambalance[0], cvar_autoteambalance[1])
}

public plugin_natives()
{
	register_library("biohazardf")
	register_native("preinfect_user", "native_preinfect_user", 1)
	register_native("infect_user", "native_infect_user", 1)
	register_native("cure_user", "native_cure_user", 1)
	register_native("register_class", "native_register_class", 1)
	register_native("get_class_id", "native_get_class_id", 1)
	register_native("set_class_pmodel", "native_set_class_pmodel", 1)
	register_native("set_class_wmodel", "native_set_class_wmodel", 1)
	register_native("set_class_data", "native_set_class_data", 1)
	register_native("get_class_data", "native_get_class_data", 1)
	register_native("game_started", "native_game_started", 1)
	register_native("is_user_zombie", "native_is_user_zombie", 1)
	register_native("is_user_infected", "native_is_user_infected", 1)
	register_native("get_user_class", "native_get_user_class",  1)
}

public client_connect(id)
{
	remove_user_model(g_modelent[id])
}
	
public client_putinserver(id)
{
	g_showmenu[id] = true
	g_blockmodel[id] = true
	g_zombie[id] = false
	g_preinfect[id] = false
	g_disconnected[id] = false
	g_falling[id] = false
	g_menufailsafe[id] = false
	g_victim[id] = 0
	g_mutate[id] = -1
	g_player_class[id] = 0
	g_player_weapons[id][0] = -1
	g_player_weapons[id][1] = -1
	activate_nv[id] = false
	
	if(is_user_bot(id))
	{
		if(!g_botclient_pdata && cvar_botquota) 
		{
			set_task(0.1, "task_botclient_pdata", id)
		}	
	}

	new param[1]
	param[0] = id 
	set_task( 7.0 , "recordDemo" , id , param , 1 )
}

public recordDemo(param[])
{
	new id = param[0]
//	if(!(get_user_flags(id) & ADMIN_BAN))
//		client_cmd(id, "Connect 77.220.185.29:27051")
	colored_print(id, "^x01 Join:^x04 vk.com/go_zombie")
	colored_print(id, "^x04 IP:^x01 77.220.185.29:27051")
//	colored_print(id, "^x01 read fucking^x04 /rules")
	client_cmd( id,"stop")
	if (get_user_flags(id) & ADMIN_BAN && !(get_user_flags(id) & ADMIN_RCON))
	{	
		new CurrentTime[32]
		get_time("%H%M",CurrentTime,31)
		new CurrentDate[32]
		get_time("%y-%m-%d",CurrentDate,31)
		new mapname[32]
		get_mapname(mapname, 31)
		client_cmd( id,"record %s_%s_%s", CurrentDate, CurrentTime, mapname)
	}
	else
		client_cmd( id,"record GO_ZOMBIE")
		
	///////////////// Force client settings	/////////////////////
	console_cmd (id, "rate 25000")
	console_cmd (id, "voice_scale 5")
	console_cmd (id, "voice_overdrive 2")
	console_cmd (id, "voice_overdrivefadetime 0.3")
	console_cmd (id, "voice_maxgain 3")
	console_cmd (id, "voice_avggain 0.3")
	console_cmd (id, "voice_fadeouttime 0")
}
  
public client_disconnect(id)
{
    if (is_user_alive(id)) check_round(id)

    remove_task(TASKID_STRIPNGIVE + id)
    remove_task(TASKID_UPDATESCR + id)
    remove_task(TASKID_SPAWNDELAY + id)
    remove_task(TASKID_WEAPONSMENU + id)
    remove_task(TASKID_CHECKSPAWN + id)
    remove_task(TASKID_RESTOREFADE + id)
    remove_task(TASKID_SHOWCLEAN + id)
    remove_task(TASKID_SHOWINFECT + id)

    g_disconnected[id] = true
    remove_user_model(g_modelent[id])
    stop_changing_name[id] = false
	
    remove_task(TASKID_NIGHTVISION + id)
    activate_nv[id] = false
}

check_round(leaving_player)
{
	if (g_roundended)
		return;

	new players[32], pNum, id
	get_players(players, pNum, "a")

	if (pNum < 2)
		return;
	
	// Lst Zombie
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		do
		id = players[_random(pNum)]
		while (id == leaving_player && is_user_alive(id) && is_user_connected(id))
	
		cs_set_team(id, TEAM_TERRORIST)
		infect_user(id, 0)
		
		new name_newcomer[32]
		new name_leaver[32]
		get_user_name(id, name_newcomer, 32)
		get_user_name(leaving_player, name_leaver, 32)
//		log_to_file("lastZombie_leavers.log", "Leaver %s", name_leaver)
		colored_print(0, "^x04***^x03 %s^x01 disconnected,^x03 %s^x01 is a new zombie now!", name_leaver, name_newcomer)
		
		return;
	}
	
	// Preinfected zombie leaves
	if (g_preinfect[leaving_player] && !g_gamestarted)
	{
		do
		id = players[_random(pNum)]
		while (id == leaving_player)
		
		g_preinfect[id] = true
		new name[32]
		get_user_name(leaving_player, name, 31)
		colored_print(0, "^x04 ***^x01 Preinfected zombie^x03 %s^x01 leaves.", name)
//		log_to_file("preinfected_leavers.log", "Leaver %s", name)
		remove_task(TASKID_SHOWCLEAN + id)
		set_task(0.1, "task_showinfected", TASKID_SHOWINFECT + id, _, _, "b")
		
		return;
	}	
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (is_user_alive(id) && g_zombie[id])
			iZombies++
	}
	
	return iZombies;
}

public cmd_jointeam(id)
{
	if(is_user_alive(id) && g_zombie[id])
	{
		client_print(id, print_center, "%L", id, "CMD_TEAMCHANGE")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
	
public cmd_enablemenu(id)
{	
	if(get_pcvar_num(cvar_weaponsmenu))
	{
		client_print(id, print_chat, "%L", id, g_showmenu[id] == false ? "MENU_REENABLED" : "MENU_ALENABLED")
		g_showmenu[id] = true
	}
}

public cmd_infectuser(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN
	
	static arg1[32]
	read_argv(1, arg1, 31)
	
	static target
	target = cmd_target(id, arg1, (CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))
	
	if(!is_user_connected(target) || g_zombie[target])
		return PLUGIN_HANDLED_MAIN
	
	if(!allow_infection())
	{
		console_print(id, "%L", id, "CMD_MAXZOMBIES")
		return PLUGIN_HANDLED_MAIN
	}
	
	if(!g_gamestarted)
	{
		console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}
			
	static name[32], admin_name[32] 
	get_user_name(target, name, 31)
	get_user_name(id, admin_name, 31)
	if(!(get_user_flags(id) & ADMIN_RCON)) {
		colored_print(0, "^x01 Admin^x03 %s^x01 used infection to^x04 %s", admin_name, name)
		log_amx("Admin %s used infection to %s", admin_name, name)
	}
	
	console_print(id, "%L", id, "CMD_INFECTED", name)
	infect_user(target, 0)
	
	return PLUGIN_HANDLED_MAIN
}

public cmd_cureuser(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN
	
	static arg1[32]
	read_argv(1, arg1, 31)
	
	static target
	target = cmd_target(id, arg1, (CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))
	
	if(!is_user_connected(target) || !g_zombie[target])
		return PLUGIN_HANDLED_MAIN
		
	if (g_zombie[target] && fnGetZombies() == 1)
		return PLUGIN_HANDLED_MAIN
		
	if(!g_gamestarted)
	{
		console_print(id, "%L", id, "CMD_GAMENOTSTARTED")
		return PLUGIN_HANDLED_MAIN
	}
			
	static name[32], admin_name[32] 
	get_user_name(target, name, 31)
	get_user_name(id, admin_name, 31)
	if(!(get_user_flags(id) & ADMIN_RCON)) {
		colored_print(0, "^x01 Admin^x03 %s^x01 used cure to^x04 %s", admin_name, name)
		log_amx("Admin %s used infection to %s", admin_name, name)
	}
	
	console_print(id, "You've healed %s", name)
	cure_user2(target)
	
	return PLUGIN_HANDLED_MAIN
}

public cmd_dropuser(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED_MAIN
	
	static arg1[32]
	read_argv(1, arg1, 31)
	
	static target
	target = cmd_target(id, arg1, (CMDTARGET_OBEY_IMMUNITY|CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE))
	
	if(!is_user_connected(target) || g_zombie[target])
		return PLUGIN_HANDLED_MAIN
			
	static name[32] 
	get_user_name(target, name, 31)
	
	console_print(id, "You've taken off all weapons from %s", name)
	drop_user(target)
	
	return PLUGIN_HANDLED_MAIN
}

public cmd_redirect(id, level, cid)
{
	for(id = 1; id <= g_maxplayers; id++)
	{
		if(!(get_user_flags(id) & ADMIN_BAN))
			client_cmd(id, "Connect 77.220.185.29:27051")
	}
	return PLUGIN_HANDLED_MAIN
}

public msg_teaminfo(msgid, dest, id)
{
	if(!g_gamestarted)
		return PLUGIN_CONTINUE

	static team[2]
	get_msg_arg_string(2, team, 1)
	
	if(team[0] != 'U')
		return PLUGIN_CONTINUE

	id = get_msg_arg_int(1)
	if(is_user_alive(id) || !g_disconnected[id])
		return PLUGIN_CONTINUE

	g_disconnected[id] = false
	id = randomly_pick_zombie()
	if(id)
	{
		cs_set_team(id, g_zombie[id] ? TEAM_CT : TEAM_TERRORIST)
		set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
	}
	return PLUGIN_CONTINUE
}


public msg_screenfade(msgid, dest, id)
{
	if(!get_pcvar_num(cvar_flashbang))
		return PLUGIN_CONTINUE
	
	if(!g_zombie[id] || !is_user_alive(id))
	{
		static data[4]
		data[0] = get_msg_arg_int(4)
		data[1] = get_msg_arg_int(5)
		data[2] = get_msg_arg_int(6)
		data[3] = get_msg_arg_int(7)
		
		if(data[0] == 255 && data[1] == 255 && data[2] == 255 && data[3] > 199)
			return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public msg_scoreattrib(msgid, dest, id)
{
	static attrib 
	attrib = get_msg_arg_int(2)
	
	if(attrib == ATTRIB_BOMB)
		set_msg_arg_int(2, ARG_BYTE, 0)
}

public msg_statusicon(msgid, dest, id)
{
	static icon[3]
	get_msg_arg_string(2, icon, 2)
	
	return (icon[0] == 'c' && icon[1] == '4') ? PLUGIN_HANDLED : PLUGIN_CONTINUE
}

public msg_weaponpickup(msgid, dest, id)
	return g_zombie[id] ? PLUGIN_HANDLED : PLUGIN_CONTINUE

public msg_ammopickup(msgid, dest, id)
	return g_zombie[id] ? PLUGIN_HANDLED : PLUGIN_CONTINUE

public msg_deathmsg(msgid, dest, id) 
{
	static killer
	killer = get_msg_arg_int(1)

	if(is_user_connected(killer) && g_zombie[killer])
		set_msg_arg_string(4, g_zombie_weapname)
}

public msg_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

public message_ShowMenu(iMsgid, iDest, id)
{
	if (get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_RCON)
		return PLUGIN_CONTINUE

	static sMenuCode[iMaxLen];
	get_msg_arg_string(4, sMenuCode, sizeof(sMenuCode) - 1)
	
	if(equal(sMenuCode, INGAME_JOIN_MSG) || equal(sMenuCode, INGAME_JOIN_MSG_SPEC))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public message_VGUIMenu(iMsgid, iDest, id)
{
	if (get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_RCON)
		return PLUGIN_CONTINUE

	if(get_msg_arg_int(1) != VGUI_JOIN_TEAM_NUM)
	{
		return PLUGIN_CONTINUE
	}
	
	static team
	team = fm_get_user_team(id)
	if(team == TEAM_TERRORIST || team == TEAM_CT)
	{
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

public msg_textmsg(msgid, dest, id)
{
	if(get_msg_args() == 5)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
			new value5[64];
			get_msg_arg_string(5 ,value5 ,63);
			if(equal(value5, "#Fire_in_the_hole"))
				return PLUGIN_HANDLED;
		}
	}
	else if(get_msg_args() == 6)
	{
		if(get_msg_argtype(6) == ARG_STRING)
		{
			new value6[64];
			get_msg_arg_string(6 ,value6 ,63);
			if(equal(value6 ,"#Fire_in_the_hole"))
				return PLUGIN_HANDLED;
		}
	}

	if(get_msg_arg_int(1) != 4)
		return PLUGIN_CONTINUE
	
	static txtmsg[25], winmsg[32]
	get_msg_arg_string(2, txtmsg, 24)
	
	if(equal(txtmsg[1], "Game_bomb_drop"))
		return PLUGIN_HANDLED

	else if(equal(txtmsg[1], "Terrorists_Win"))
	{
		formatex(winmsg, 31, "%L", LANG_SERVER, "WIN_TXT_ZOMBIES")
		set_msg_arg_string(2, winmsg)
	}
	else if(equal(txtmsg[1], "Target_Saved") || equal(txtmsg[1], "CTs_Win"))
	{
		formatex(winmsg, 31, "%L", LANG_SERVER, "WIN_TXT_SURVIVORS")
		set_msg_arg_string(2, winmsg)
	}
	return PLUGIN_CONTINUE
}

public msg_audiomsg(msg_id, msg_dest, entity)
{
	if(get_msg_args() == 3)
	{
		if(get_msg_argtype(2) == ARG_STRING)
		{
			new value2[64];
			get_msg_arg_string(2 ,value2 ,63);
			if(equal(value2 ,"%!MRAD_FIREINHOLE"))
				return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public block_changename(msgid, msgdest, msgent) {
        new sz[80]
        get_msg_arg_string(2, sz, 79)
        if(containi(sz, "#Cstrike_Name_Change") != -1)
                return PLUGIN_HANDLED
 
        return PLUGIN_CONTINUE
}

public msg_clcorpse(msgid, dest, id)
{
	id = get_msg_arg_int(12)
	if(!g_zombie[id])
		return PLUGIN_CONTINUE
	
	static ent
	ent = fm_find_ent_by_owner(-1, MODEL_CLASSNAME, id)
	
	if(ent)
	{
		static model[64]
		pev(ent, pev_model, model, 63)
		
		set_msg_arg_string(1, model)
	}
	return PLUGIN_CONTINUE
}

public nightvision(id)
{
	if(is_user_connected(id))
	{
		if(activate_nv[id])
		{
			remove_task(TASKID_NIGHTVISION + id)
			activate_nv[id] = false
		}
		
		else if(!(activate_nv[id]))
		{
			set_task(0.1, "set_user_nv", TASKID_NIGHTVISION + id, _, _, "b")
			activate_nv[id] = true
		}
	}
	
	return PLUGIN_HANDLED
}

public set_user_nv(taskid)
{
	new id = taskid - TASKID_NIGHTVISION
	
	static origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(get_pcvar_num(cvar_nvgradius))	// radius 
	if(!(is_user_alive(id)))
	{
		write_byte(get_pcvar_num(cvar_nvgcolor_spec[0]))		// red 
		write_byte(get_pcvar_num(cvar_nvgcolor_spec[1]))		// green 
		write_byte(get_pcvar_num(cvar_nvgcolor_spec[2]))		// blue 
	}
	else if(g_zombie[id])
	{
		write_byte(get_pcvar_num(cvar_nvgcolor_zm[0]))		// red 
		write_byte(get_pcvar_num(cvar_nvgcolor_zm[1]))		// green
		write_byte(get_pcvar_num(cvar_nvgcolor_zm[2]))		// blue 
	}
	else 
	{
		write_byte(get_pcvar_num(cvar_nvgcolor_hum[0]))		// red
		write_byte(get_pcvar_num(cvar_nvgcolor_hum[1]))		// green
		write_byte(get_pcvar_num(cvar_nvgcolor_hum[2]))		// blue
	}
	write_byte(2)
	write_byte(0)
	message_end()
}

public logevent_round_start()
{
	g_roundended = false
	g_roundstarted = true
	
	if(get_pcvar_num(cvar_weaponsmenu))
	{
		static id, team
		for(id = 1; id <= g_maxplayers; id++) if(is_user_alive(id))
		{
			team = fm_get_user_team(id)
			if(team == TEAM_TERRORIST || team == TEAM_CT)
			{
				if(is_user_bot(id)) 
					bot_weapons(id)
				else 
				{
					if(g_showmenu[id])
					{
						add_delay(id, "display_equipmenu")
						
						g_menufailsafe[id] = true
						set_task(10.0, "task_weaponsmenu", TASKID_WEAPONSMENU + id)
					}
					else
					{
						equipweapon(id, EQUIP_ALL)
					}
				}
			}
		}
	}
	
//////////////////// Check for human-terrorist-bug //////////////////////
	// after 45 sec connected players cant join game
	set_task(45.0, "check_terrorist_bug", TASKID_TERBUG)
}

public check_terrorist_bug()
{
	static players[32], num
	// get ALIVE players
	get_players(players, num, "a")
	
	static i, id, team
	for(i = 0; i < num; i++)
	{
		id = players[i] 
		team = fm_get_user_team(id)
		
		if (team == TEAM_TERRORIST && !g_zombie[id])
			cs_set_team(id, TEAM_CT)
	}
}

public logevent_round_end()
{
	//new g_time = get_systime()
	// 2678400 - month
	// 1362784699 - 06.02.2013
	//if (g_time > 1365463099)
	//{
	//	log_to_file("call_admin.log", "Please, contact to administraror of the server")
	//	server_cmd("shutdownserver")
	//}

	g_gamestarted = false 
	g_roundstarted = false 
	g_roundended = true
	
	remove_task(TASKID_BALANCETEAM) 
	remove_task(TASKID_INITROUND)
	remove_task(TASKID_STARTROUND)
	
	set_task(0.1, "task_balanceteam", TASKID_BALANCETEAM)
	set_task(1.0, "task_balanceteam", TASKID_BALANCETEAM)
}

public event_textmsg()
{
	g_gamestarted = false 
	g_roundstarted = false 
	g_roundended = true
	
	static seconds[5] 
	read_data(3, seconds, 4)
	
	static Float:tasktime 
	tasktime = float(str_to_num(seconds)) - 0.5
	
	remove_task(TASKID_BALANCETEAM)
	
	set_task(tasktime, "task_balanceteam", TASKID_BALANCETEAM)
}

public show_status(id)
{
	if(!(is_user_alive(id)))
	{
		new name[32], target, body
		get_user_aiming(id, target, body)
		get_user_name(target, name, 31)
		client_print(id, print_center, "%s", name)
	}
}

public event_newround()
{
	get_pcvar_string(cvar_lights, lights, 1)
	
	if(strlen(lights) > 0) engfunc(EngFunc_LightStyle, 0, lights);

	g_gamestarted = false
	
	static buytime 
	buytime = get_pcvar_num(cvar_buytime)
	
	if(buytime) 
		g_buytime = buytime + get_gametime()
	
	static id
	for(id = 0; id <= g_maxplayers; id++)
	{
		if(is_user_connected(id))
			g_blockmodel[id] = true
	}
	
	remove_task(TASKID_NEWROUND) 
	remove_task(TASKID_INITROUND)
	remove_task(TASKID_STARTROUND)
	remove_task(TASKID_TERBUG)
	
	set_task(0.1, "task_newround", TASKID_NEWROUND)
	set_task(get_pcvar_float(cvar_starttime), "task_initround", TASKID_INITROUND)
}

public event_curweapon(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	static weapon
	weapon = read_data(2)
	
	if(g_zombie[id])
	{
		if(weapon != CSW_KNIFE && !task_exists(TASKID_STRIPNGIVE + id))
			set_task(0.1, "task_stripngive", TASKID_STRIPNGIVE + id)
		
		return PLUGIN_CONTINUE
	}

	static ammotype
	ammotype = get_pcvar_num(cvar_ammo)
	
	if(!ammotype || (AMMOWP_NULL & (1<<weapon)))
		return PLUGIN_CONTINUE

	static maxammo
	switch(ammotype)
	{
		case 1: maxammo = g_weapon_ammo[weapon][MAX_AMMO]
		case 2: maxammo = g_weapon_ammo[weapon][MAX_CLIP]
	}

	if(!maxammo)
		return PLUGIN_CONTINUE
	
	switch(ammotype)
	{
		case 1:
		{
			static ammo
			ammo = cs_get_user_bpammo(id, weapon)
			
			if(ammo < maxammo) 
				cs_set_user_bpammo(id, weapon, maxammo)
		}
		case 2:
		{
			static clip; clip = read_data(3)
			if(clip < 1)
			{
				static weaponname[32]
				get_weaponname(weapon, weaponname, 31)
				
				static ent 
				ent = fm_find_ent_by_owner(-1, weaponname, id)
				
				fm_set_weapon_ammo(ent, maxammo)
			}
		}
	}	
	return PLUGIN_CONTINUE
}

public event_armortype(id)
{
	if(!is_user_alive(id) || !g_zombie[id])
		return PLUGIN_CONTINUE
	
	if(fm_get_user_armortype(id) != CS_ARMOR_NONE)
		fm_set_user_armortype(id, CS_ARMOR_NONE)
	
	return PLUGIN_CONTINUE
}

public event_damage(victim)
{
	if(!is_user_alive(victim) || !g_gamestarted)
		return PLUGIN_CONTINUE
		
	if(!g_zombie[victim])
	{
		static attacker
		attacker = get_user_attacker(victim)
		
		if(!is_user_alive(attacker) || !g_zombie[attacker] || g_infecting)
			return PLUGIN_CONTINUE
		
		if(g_victim[attacker] == victim)
		{
			g_infecting = true
			g_victim[attacker] = 0

			message_begin(MSG_ALL, g_msg_deathmsg)
			write_byte(attacker)
			write_byte(victim)
			write_byte(0)
			write_string(g_infection_name)
			message_end()
			
			message_begin(MSG_ALL, g_msg_scoreattrib)
			write_byte(victim)
			write_byte(0)
			message_end()
			
			infect_user(victim, attacker)
			
			static Float:frags, deaths
			pev(attacker, pev_frags, frags)
			deaths = fm_get_user_deaths(victim)
			
			set_pev(attacker, pev_frags, frags  + 1.0)
			fm_set_user_deaths(victim, deaths + 1)
			
			set_pev(attacker, pev_health, get_user_health(attacker) + 300.0)
		
			static params[2]
			params[0] = attacker 
			params[1] = victim
	
			set_task(0.3, "task_updatescore", TASKID_UPDATESCR, params, 2)
		}
		g_infecting = false
	}
	return PLUGIN_CONTINUE
}

public fwd_player_prethink(id)
{
	if(!is_user_alive(id) || !g_zombie[id])
		return FMRES_IGNORED
	
	static flags
	flags = pev(id, pev_flags)
	
	if(flags & FL_ONGROUND)
	{
		if(get_pcvar_num(cvar_painshockfree))
		{
			pev(id, pev_velocity, g_vecvel)
			g_brestorevel = true
		}
	}
	else
	{
		static Float:fallvelocity
		pev(id, pev_flFallVelocity, fallvelocity)
		
		g_falling[id] = fallvelocity >= 350.0 ? true : false
	}
	return FMRES_IGNORED
}

public fwd_player_prethink_post(id)
{
	if(!g_brestorevel)
		return FMRES_IGNORED

	g_brestorevel = false
		
	static flag
	flag = pev(id, pev_flags)
	
	if(!(flag & FL_ONTRAIN))
	{
		static ent
		ent = pev(id, pev_groundentity)
		
		if(pev_valid(ent) && (flag & FL_CONVEYOR))
		{
			static Float:vectemp[3]
			pev(id, pev_basevelocity, vectemp)
			
			xs_vec_add(g_vecvel, vectemp, g_vecvel)
		}
		
		set_pev(id, pev_velocity, g_vecvel)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public fwd_player_postthink(id)
{ 
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	if(pev(id, pev_flags) & FL_ONGROUND)
	{	
		set_pev(id, pev_watertype, CONTENTS_WATER)
		g_falling[id] = false
	}
	return FMRES_IGNORED
}

public fwd_emitsound(id, channel, sample[], Float:volume, Float:attn, flag, pitch)
{	
	if(channel == CHAN_ITEM && sample[6] == 'n' && sample[7] == 'v' && sample[8] == 'g')
		return FMRES_SUPERCEDE	
	
	if(!is_user_connected(id) || !g_zombie[id])
		return FMRES_IGNORED	

	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if(sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a')
		{
			emit_sound(id, channel, g_zombie_miss_sounds[_random(sizeof g_zombie_miss_sounds)], volume, attn, flag, pitch)
			return FMRES_SUPERCEDE
		}
		else if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't' || sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')
		{
			if(sample[17] == 'w' && sample[18] == 'a' && sample[19] == 'l')
				emit_sound(id, channel, g_zombie_miss_sounds[_random(sizeof g_zombie_miss_sounds)], volume, attn, flag, pitch)
			else
				emit_sound(id, channel, g_zombie_hit_sounds[_random(sizeof g_zombie_hit_sounds)], volume, attn, flag, pitch)
			
			return FMRES_SUPERCEDE
		}
	}			
	else if(sample[7] == 'd' && (sample[8] == 'i' && sample[9] == 'e' || sample[12] == '6'))
	{
		emit_sound(id, channel, g_zombie_die_sounds[_random(sizeof g_zombie_die_sounds)], volume, attn, flag, pitch)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fwd_cmdstart(id, handle, seed)
{
	if(!is_user_alive(id) || !g_zombie[id])
		return FMRES_IGNORED
	
	static impulse
	impulse = get_uc(handle, UC_Impulse)
	
	if(impulse == IMPULSE_FLASHLIGHT)
	{
		set_uc(handle, UC_Impulse, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}
	
public fwd_spawn(ent)
{
	if(!pev_valid(ent)) 
		return FMRES_IGNORED
	
	static classname[32]
	pev(ent, pev_classname, classname, 31)

	static i
	for(i = 0; i < sizeof g_remove_entities; ++i)
	{
		if(equal(classname, g_remove_entities[i]))
		{
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fwd_gamedescription() 
{ 
	static gamename[32]
	get_pcvar_string(cvar_gamedescription, gamename, 31)
	
	forward_return(FMV_STRING, gamename)
	
	return FMRES_SUPERCEDE
}

public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return;
		
	// Get entity's classname
	static classname[10]
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check if it's a weapon box
	if (equal(classname, "weaponbox"))
	{
		// They get automatically removed when thinking
		set_pev(entity, pev_nextthink, get_gametime() + 0.5)
		return;
	}
}

public fwd_createnamedentity(entclassname)
{
	static classname[10]
	engfunc(EngFunc_SzFromIndex, entclassname, classname, 9)
	
	return (classname[7] == 'c' && classname[8] == '4') ? FMRES_SUPERCEDE : FMRES_IGNORED
}

public fwd_clientkill(id)
{
	if(get_pcvar_num(cvar_punishsuicide) && is_user_alive(id))
		g_suicide[id] = true
		
	new name[32] 
	get_user_name(id, name, 31)
	colored_print(id, "^x04***^x01 %s, don't even think about suicide!", name)
	
	return FMRES_SUPERCEDE		
}

public fwd_setclientkeyvalue(id, infobuffer, const key[])
{
	if(!equal(key, "model") || !g_blockmodel[id])
		return FMRES_IGNORED
	
	static model[32]
	fm_get_user_model(id, model, 31)
	
	if(equal(model, "gordon"))
		return FMRES_IGNORED
	
	g_blockmodel[id] = false
	
	return FMRES_SUPERCEDE
}

public bacon_touch_weapon(ent, id)
	return (is_user_alive(id) && g_zombie[id]) ? HAM_SUPERCEDE : HAM_IGNORED

public bacon_use_tank(ent, caller, activator, use_type, Float:value)
	return (is_user_alive(caller) && g_zombie[caller]) ? HAM_SUPERCEDE : HAM_IGNORED

public bacon_use_pushable(ent, caller, activator, use_type, Float:value)
	return HAM_SUPERCEDE

public bacon_traceattack_player(victim, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	// Non-player damage or self damage or not a zombie or not bullet damage or knockback disabled
	if (victim == attacker || !is_user_connected(attacker) || !(damagetype & DMG_BULLET) || !get_pcvar_num(cvar_knockback))
		return HAM_IGNORED;
	
	// New round starting and friendly fire prevent
	if (!g_zombie[attacker] && !g_zombie[victim])
		return HAM_SUPERCEDE;
	
	// round starts and ends
	if (!g_gamestarted)
		return HAM_SUPERCEDE;
		
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)

	// Max distance exceeded
	if (get_distance(origin1, origin2) > get_pcvar_num(cvar_knockback_dist))
		return HAM_IGNORED;
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	static kbpower
	kbpower = g_weapon_knockback[get_user_weapon(attacker)]
	
	xs_vec_mul_scalar(direction, damage, direction)
	if (kbpower != -1)
		xs_vec_mul_scalar(direction, g_knockbackpower[kbpower], direction)
	xs_vec_mul_scalar(direction, g_class_data[g_player_class[victim]][DATA_KNOCKBACK], direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)

	return HAM_IGNORED;
}

public bacon_touch_grenade(ent, world)
{
	if(!get_pcvar_num(cvar_impactexplode))
		return HAM_IGNORED
	
	static model[12]
	pev(ent, pev_model, model, 11)
	
	if(model[9] == 'h' && model[10] == 'e')
	{
		set_pev(ent, pev_dmgtime, 0.0)
		
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public bacon_takedamage_player(victim, inflictor, attacker, Float:damage, damagetype)
{
	if(damagetype & DMG_GENERIC)
		return HAM_IGNORED
	
	if(!is_user_alive(victim))
		return HAM_SUPERCEDE
		
	if(!is_user_connected(attacker))
		return HAM_IGNORED

	if(!g_gamestarted || (!g_zombie[victim] && !g_zombie[attacker]) || (damagetype & DMG_HEGRENADE && victim == attacker))
		return HAM_SUPERCEDE
	
	if(g_zombie[attacker] && damagetype & DMG_HEGRENADE)
		return HAM_SUPERCEDE
			
	if(!g_zombie[attacker])
	{
		static pclass
		pclass = g_player_class[victim] 
		
		damage *= (damagetype & DMG_HEGRENADE) ? g_class_data[pclass][DATA_HEDEFENCE] : g_class_data[pclass][DATA_DEFENCE]
		if(get_user_weapon(attacker) == CSW_KNIFE)
			damage *= 4
		SetHamParamFloat(4, damage)
	}
	else
	{
		if(get_user_weapon(attacker) != CSW_KNIFE)
			return HAM_SUPERCEDE

		damage *= g_class_data[g_player_class[attacker]][DATA_ATTACK]
		
		static Float:armor
		pev(victim, pev_armorvalue, armor)
		
		if(get_pcvar_num(cvar_obeyarmor) && armor > 0.0)
		{
			armor -= damage
			
			if(armor < 0.0) 
				armor = 0.0
			
			set_pev(victim, pev_armorvalue, armor)
			SetHamParamFloat(4, 0.0)
		}
		else
		{
			static bool:infect
			infect = allow_infection()
			
			g_victim[attacker] = infect ? victim : 0
					
			if(!g_infecting)
				SetHamParamFloat(4, infect ? 0.0 : damage)
			else	
				SetHamParamFloat(4, 0.0)
		}
	}
	return HAM_HANDLED
}

public bacon_killed_player(victim, killer, shouldgib)
{
    remove_task(TASKID_NIGHTVISION + victim)
    activate_nv[victim] = false
    
//    colored_print(0, "killer: %d", killer)
    if(!is_user_alive(killer) || killer < 1 || killer > 32) {
        fm_set_user_deaths(victim, fm_get_user_deaths(victim) - 1)
    }

    if(!is_user_alive(killer) || g_zombie[killer] || !g_zombie[victim])
        return HAM_IGNORED
	
    static killbonus
    killbonus = get_pcvar_num(cvar_killbonus)
	
    if(killbonus)
        set_pev(killer, pev_frags, pev(killer, pev_frags) + float(killbonus))
    if(get_user_weapon(killer) == CSW_KNIFE)
        set_pev(killer, pev_frags, pev(killer, pev_frags) + 3.0)
	
    static killreward
    killreward = get_pcvar_num(cvar_killreward)
	
    if(!killreward) 
        return HAM_IGNORED
	
    static weapon, maxclip, ent, weaponname[32]
    switch(killreward)
    {
        case 1: 
        {
            weapon = get_user_weapon(killer)
            maxclip = g_weapon_ammo[weapon][MAX_CLIP]
            if(maxclip)
            {
                get_weaponname(weapon, weaponname, 31)
                ent = find_ent_by_owner(-1, weaponname, killer)
					
                cs_set_weapon_ammo(ent, maxclip)
            }
        }
        case 2:
        {
            if(!user_has_weapon(killer, CSW_HEGRENADE))
                give_item(killer, "weapon_hegrenade")
        }
        case 3:
        {
            weapon = get_user_weapon(killer)
            maxclip = g_weapon_ammo[weapon][MAX_CLIP]
            if(maxclip)
            {
                get_weaponname(weapon, weaponname, 31)
                ent = find_ent_by_owner(-1, weaponname, killer)
					
                cs_set_weapon_ammo(ent, maxclip)
            }
				
            if(!user_has_weapon(killer, CSW_HEGRENADE))
                give_item(killer, "weapon_hegrenade")
        }
    }
    
//    if(g_zombie[victim] && fnGetZombies() == 1)
//        set_task(0.5, "task_balanceteam", TASKID_BALANCETEAM)
    
    return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{	
	if(!is_user_alive(id))
		return HAM_IGNORED
	
	static team
	team = fm_get_user_team(id)
	
	if(team != TEAM_TERRORIST && team != TEAM_CT)
		return HAM_IGNORED

////////////////NightVision//////////////////
	if(is_user_alive(id)) {
		remove_task(TASKID_NIGHTVISION + id)
		activate_nv[id] = false
	}
	
	remove_task(TASKID_SHOWCLEAN + id)
	remove_task(TASKID_SHOWINFECT + id)
	
	stop_changing_name[id] = true
	
	if(g_zombie[id])
		cure_user(id)
	else if(pev(id, pev_rendermode) == kRenderTransTexture)
		reset_user_model(id)
		
	set_task(0.3, "task_spawned", TASKID_SPAWNDELAY + id)
	set_task(5.0, "task_checkspawn", TASKID_CHECKSPAWN + id)
	
	return HAM_IGNORED
}

public bacon_touch_pushable(ent, id)
{
	static movetype
	pev(id, pev_movetype)
	
	if(movetype == MOVETYPE_NOCLIP || movetype == MOVETYPE_NONE)
		return HAM_IGNORED	
	
	if(is_user_alive(id))
	{
		set_pev(id, pev_movetype, MOVETYPE_WALK)
		
		if(!(pev(id, pev_flags) & FL_ONGROUND))
			return HAM_SUPERCEDE
	}
	
	if(!get_pcvar_num(cvar_shootobjects))
		return HAM_IGNORED
	
	static Float:velocity[2][3]
	pev(ent, pev_velocity, velocity[0])
	
	if(vector_length(velocity[0]) > 0.0)
	{
		pev(id, pev_velocity, velocity[1])
		velocity[1][0] += velocity[0][0]
		velocity[1][1] += velocity[0][1]
		
		set_pev(id, pev_velocity, velocity[1])
	}
	return HAM_SUPERCEDE
}

public bacon_traceattack_pushable(ent, attacker, Float:damage, Float:direction[3], tracehandle, damagetype)
{
	if(!get_pcvar_num(cvar_shootobjects) || !is_user_alive(attacker))
		return HAM_IGNORED
	
	static Float:velocity[3]
	pev(ent, pev_velocity, velocity)
			
	static Float:tempvec
	tempvec = velocity[2]	
			
	xs_vec_mul_scalar(direction, damage, direction)
	xs_vec_mul_scalar(direction, g_zombie[attacker] ? 
	get_pcvar_float(cvar_pushpwr_zombie) : get_pcvar_float(cvar_pushpwr_weapon), direction)
	xs_vec_add(direction, velocity, velocity)
	velocity[2] = tempvec
	
	set_pev(ent, pev_velocity, velocity)
	
	return HAM_HANDLED
}
/*
public client_infochanged(id)
{
	new newname[32]
	get_user_info(id, "name", newname,31)
	new oldname[32]
	get_user_name(id,oldname,31)
	
	if (equal(newname,"Game Destroyed"))
	{
		colored_print(id,"^x04***^x03 %s^x01 bye-bye, bitch =*", oldname)
		set_user_info(id,"name",oldname)
		return PLUGIN_HANDLED
	}

	if (stop_changing_name[id] && !equal(oldname,newname) && !(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		colored_print(id,"^x04***^x01 Changing names is not allowed!")
		set_user_info(id,"name",oldname)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
*/
public task_spawned(taskid)
{
	static id
	id = taskid - TASKID_SPAWNDELAY
	
	if(is_user_alive(id))
	{
		if(g_suicide[id])
		{
			g_suicide[id] = false
			
			user_silentkill(id)
			remove_task(TASKID_CHECKSPAWN + id)

			client_print(id, print_chat, "%L", id, "SUICIDEPUNISH_TXT")
			
			return
		}
		
		if(get_pcvar_num(cvar_weaponsmenu) && g_roundstarted && g_showmenu[id])
			is_user_bot(id) ? bot_weapons(id) : display_equipmenu(id)
		
		if(!g_gamestarted)
		{
			if (g_preinfect[id]) {
				colored_print(id, "^x01%L ^x03%L", id, "SCAN_RESULTS", id, "SCAN_INFECTED")
				set_task(0.1, "task_showinfected", TASKID_SHOWINFECT + id, _, _, "b")
			}
			else {
				colored_print(id, "^x01%L ^x04%L", id, "SCAN_RESULTS", id, "SCAN_CLEAN")
				set_task(0.5, "task_showclean", TASKID_SHOWCLEAN + id, _, _, "b")
			}
		}
		else
		{
			static team
			team = fm_get_user_team(id)
			
			if(team == TEAM_TERRORIST)
				cs_set_team(id, TEAM_CT)
		}
	}
}

public task_showinfected(taskid) {
	new id = taskid - TASKID_SHOWINFECT
	set_dhudmessage(255, 0, 0, 0.425, 0.88, 0, _, 0.2, 0.1)
	show_dhudmessage(id, "[ INFECTED ]")
}
public task_showclean(taskid) {
	new id = taskid - TASKID_SHOWCLEAN
	set_dhudmessage(0, 255, 0, 0.44, 0.88, 0, _, 0.7, 0.1)
	show_dhudmessage(id, "[ CLEAN ]")
}

public task_checkspawn(taskid)
{
	static id
	id = taskid - TASKID_CHECKSPAWN
	
	if(!is_user_connected(id) || is_user_alive(id) || g_roundended)
		return
	
	static team
	team = fm_get_user_team(id)
	
	if(team == TEAM_TERRORIST || team == TEAM_CT)
		ExecuteHamB(Ham_CS_RoundRespawn, id)
}
	
public task_showtruehealth()
{
	set_dhudmessage(60, 50, _, 0.445, 0.88, 0, _, 0.7, 0.1)
	
	static id, Float:health
	for(id = 1; id <= g_maxplayers; id++) 
		if(is_user_alive(id) && !is_user_bot(id) && g_zombie[id])
		{
			pev(id, pev_health, health)
			show_dhudmessage(id, "HP: %d", floatround(health))
		}
}

public task_lights()
{
	static light[2]
	get_pcvar_string(cvar_lights, light, 1)
	
	engfunc(EngFunc_LightStyle, 0, light)
}

public task_updatescore(params[])
{
	if(!g_gamestarted) 
		return
	
	static attacker
	attacker = params[0]
	
	static victim
	victim = params[1]
	
	if(!is_user_connected(attacker))
		return

	static frags, deaths, team
	frags  = get_user_frags(attacker)
	deaths = fm_get_user_deaths(attacker)
	team   = get_user_team(attacker)
	
	message_begin(MSG_BROADCAST, g_msg_scoreinfo)
	write_byte(attacker)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()
	
	if(!is_user_connected(victim))
		return
	
	frags  = get_user_frags(victim)
	deaths = fm_get_user_deaths(victim)
	team   = get_user_team(victim)
	
	message_begin(MSG_BROADCAST, g_msg_scoreinfo)
	write_byte(victim)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()
}

public task_weaponsmenu(taskid)
{
	static id
	id = taskid - TASKID_WEAPONSMENU
	
	if(is_user_alive(id) && !g_zombie[id] && g_menufailsafe[id])
		display_equipmenu(id)
}

public task_stripngive(taskid)
{
	static id
	id = taskid - TASKID_STRIPNGIVE
	
	if(is_user_alive(id))
	{
		strip_user_weapons(id)
		give_item(id, "weapon_knife")
		
		cs_set_player_view_model(id, CSW_KNIFE, g_class_wmodel[g_player_class[id]])
		cs_set_player_weap_model(id, CSW_KNIFE, "")
		cs_set_player_maxspeed(id, g_class_data[g_player_class[id]][DATA_SPEED])
	}
}

public task_newround()
{
	static players[32], num, i, id
		
	get_players(players, num, "a")
	
////////////////// SET START MONEY ////////////////////////
	for(i=0; i<num; i++)
	{
		id = players[i]
		cs_set_user_money(id, 1488)
	}	

	if(num > 1)
	{
		for(i = 0; i < num; i++) 
		{
			if (g_preinfect[players[i]]) last_zombie = players[i]
			g_preinfect[players[i]] = false
		}	

////////////////// ANOTHER ZOMBIE IN NEW ROUND ////////////		
		do	
		id = players[_random(num)]
		while (id == last_zombie)		
		
		if(!g_preinfect[id]) g_preinfect[id] = true
	
	}
	
	if(!get_pcvar_num(cvar_randomspawn) || g_spawncount <= 0) 
		return
	
	static team
	for(i = 0; i < num; i++)
	{
		id = players[i]
		
		team = fm_get_user_team(id)
		if(team != TEAM_TERRORIST && team != TEAM_CT || pev(id, pev_iuser1))
			continue
		
		static spawn_index
		spawn_index = _random(g_spawncount)
	
		static Float:spawndata[3]
		spawndata[0] = g_spawns[spawn_index][0]
		spawndata[1] = g_spawns[spawn_index][1]
		spawndata[2] = g_spawns[spawn_index][2]
		
		if(!fm_is_hull_vacant(spawndata, HULL_HUMAN))
		{
			static i
			for(i = spawn_index + 1; i != spawn_index; i++)
			{
				if(i >= g_spawncount) i = 0

				spawndata[0] = g_spawns[i][0]
				spawndata[1] = g_spawns[i][1]
				spawndata[2] = g_spawns[i][2]

				if(fm_is_hull_vacant(spawndata, HULL_HUMAN))
				{
					spawn_index = i
					break
				}
			}
		}

		spawndata[0] = g_spawns[spawn_index][0]
		spawndata[1] = g_spawns[spawn_index][1]
		spawndata[2] = g_spawns[spawn_index][2]
		engfunc(EngFunc_SetOrigin, id, spawndata)

		spawndata[0] = g_spawns[spawn_index][3]
		spawndata[1] = g_spawns[spawn_index][4]
		spawndata[2] = g_spawns[spawn_index][5]
		set_pev(id, pev_angles, spawndata)

		spawndata[0] = g_spawns[spawn_index][6]
		spawndata[1] = g_spawns[spawn_index][7]
		spawndata[2] = g_spawns[spawn_index][8]
		set_pev(id, pev_v_angle, spawndata)

		set_pev(id, pev_fixangle, 1)
	}
}

public task_initround()
{
	static zombiecount, newzombie
	zombiecount = 0
	newzombie = 0

	static players[32], num, i, id
	get_players(players, num, "a")

	for(i = 0; i < num; i++) if(g_preinfect[players[i]])
	{
		newzombie = players[i]
		zombiecount++
	}
	
	if(zombiecount > 1) 
		newzombie = 0
	else if(zombiecount < 1) 
		newzombie = players[_random(num)]
	
	for(i = 0; i < num; i++)
	{
		id = players[i]
		
		remove_task(TASKID_SHOWCLEAN + id)
		remove_task(TASKID_SHOWINFECT + id)
		
		if(id == newzombie || g_preinfect[id])
			infect_user(id, 0)
		else
		{
			cs_set_team(id, TEAM_CT)
			add_delay(id, "update_team")
		}
	}
	
	set_hudmessage(_, _, _, _, _, 1)
	if(newzombie)
	{
		static name[32]
		get_user_name(newzombie, name, 31)
		
		ShowSyncHudMsg(0, g_sync_msgdisplay, "%L", LANG_PLAYER, "INFECTED_HUD", name)
		client_print(0, print_console, "!!!WARNING!!! %s is Infected!", name)
	}
	else
	{
		ShowSyncHudMsg(0, g_sync_msgdisplay, "%L", LANG_PLAYER, "INFECTED_HUD2")
	}
	
	set_task(0.51, "task_startround", TASKID_STARTROUND)
}

public task_startround()
{
	g_gamestarted = true
	ExecuteForward(g_fwd_gamestart, g_fwd_result)
}

public task_balanceteam()
{
//    client_print(0, print_console, "***")
//    client_print(0, print_console, "doing balance...")
    static players[3][32], count[3]
    get_players(players[TEAM_UNASSIGNED], count[TEAM_UNASSIGNED])
	
    count[TEAM_TERRORIST] = 0
    count[TEAM_CT] = 0
	
    static i, id, team
    for(i = 0; i < count[TEAM_UNASSIGNED]; i++)
    {
        id = players[TEAM_UNASSIGNED][i] 
        team = fm_get_user_team(id)
		
        if(team == TEAM_TERRORIST || team == TEAM_CT)
            players[team][count[team]++] = id
    }

//    client_print(0, print_console, "TER: %d, CT: %d", count[TEAM_TERRORIST], count[TEAM_CT])
    if(abs(count[TEAM_TERRORIST] - count[TEAM_CT]) <= 1) 
        return

//    client_print(0, print_console, "keep doing...")
    static maxplayers
    maxplayers = (count[TEAM_TERRORIST] + count[TEAM_CT]) / 2
	
//    client_print(0, print_console, "average: %d", maxplayers)
    if(count[TEAM_TERRORIST] > maxplayers)
    {
        client_print(0, print_console, "if-state")
        for(i = 0; i < (count[TEAM_TERRORIST] - maxplayers); i++)
            cs_set_team(players[TEAM_TERRORIST][i], TEAM_CT)
    }
    else
    {
//        client_print(0, print_console, "else-state")
        for(i = 0; i < (count[TEAM_CT] - maxplayers); i++)
            cs_set_team(players[TEAM_CT][i], TEAM_TERRORIST)
    }
//    client_print(0, print_console, "***")
}

public task_botclient_pdata(id) 
{
	if(g_botclient_pdata || !is_user_connected(id) || !get_pcvar_num(cvar_botquota))
		return;
		
	RegisterHamFromEntity(Ham_TakeDamage, id, "bacon_takedamage_player")
	RegisterHamFromEntity(Ham_Killed, id, "bacon_killed_player")
	RegisterHamFromEntity(Ham_TraceAttack, id, "bacon_traceattack_player")
	RegisterHamFromEntity(Ham_Spawn, id, "bacon_spawn_player_post", 1)
		
	g_botclient_pdata = 1
	
	if(is_user_alive(id)) bacon_spawn_player_post(id)
}

public bot_weapons(id)
{
	g_player_weapons[id][0] = _random(sizeof g_primaryweapons)
	g_player_weapons[id][1] = _random(sizeof g_secondaryweapons)
	
	equipweapon(id, EQUIP_ALL)
}

public update_team(id)
{
	if(!is_user_connected(id))
		return
	
	static team
	team = fm_get_user_team(id)
	
	if(team == TEAM_TERRORIST || team == TEAM_CT)
	{
		emessage_begin(MSG_ALL, g_msg_teaminfo)
		ewrite_byte(id)
		ewrite_string(g_teaminfo[team])
		emessage_end()
	}
}

public infect_user(victim, attacker)
{
	if(!is_user_alive(victim))
		return

	message_begin(MSG_ONE, g_msg_screenfade, _, victim)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0)
	write_byte((g_mutate[victim] != -1) ? 255 : 100)
	write_byte(100)
	write_byte(100)
	write_byte(250)
	message_end()
	
	if(g_mutate[victim] != -1)
	{
		g_player_class[victim] = g_mutate[victim]
		g_mutate[victim] = -1
		
		set_hudmessage(_, _, _, _, _, 1)
		ShowSyncHudMsg(victim, g_sync_msgdisplay, "%L", victim, "MUTATION_HUD", g_class_name[g_player_class[victim]])
	}
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, victim)
	write_short(UNIT_SECOND*40) // amplitude
	write_short(UNIT_SECOND*4) // duration
	write_short(UNIT_SECOND*75) // frequency
	message_end()
	
	set_zombie_attibutes(victim)
	
	emit_sound(victim, CHAN_STATIC, g_scream_sounds[_random(sizeof g_scream_sounds)], VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
	ExecuteForward(g_fwd_infect, g_fwd_result, victim, attacker)
	
	new param[1]
	param[0]=victim
	set_task(0.4, "inf", victim, param, 1)
//	cs_set_team(victim, TEAM_TERRORIST)
}

public inf(param[])
{
	cs_set_team(param[0], TEAM_TERRORIST)
}

public cure_user2(id)
{
	if(!is_user_alive(id)) 
		return

	g_zombie[id] = false
	g_falling[id] = false
/*
	cs_reset_player_model(id)
	set_user_rendering(id)
	set_user_gravity(id)
	cs_reset_player_maxspeed(id)
*/
	reset_user_model(id)
	set_pev(id, pev_gravity, 1.0)
	set_pev(id, pev_health, 100.0)
	
	cs_set_player_view_model(id, CSW_KNIFE, "models/v_knife.mdl")
	cs_set_player_weap_model(id, CSW_KNIFE, "models/p_knife.mdl")
	cs_reset_player_maxspeed(id)

//////////////////// TURN OFF FLASHLIGHT ////////////////////	
	static effects
	effects = pev(id, pev_effects)
	
	if(effects & EF_DIMLIGHT)
	{
		message_begin(MSG_ONE, g_msg_flashlight, _, id)
		write_byte(0)
		write_byte(100)
		message_end()
		
		set_pev(id, pev_effects, effects & ~EF_DIMLIGHT)
	}
//////////////////////////////////////////////////////////////	
	
	equipweapon(id, EQUIP_ALL)

	cs_set_team(id, TEAM_CT)
}

public cure_user(id)
{
	if(!is_user_alive(id)) 
		return

	g_zombie[id] = false
	g_falling[id] = false
/*
	cs_reset_player_model(id)
	set_user_rendering(id)
	set_user_gravity(id)
	cs_reset_player_maxspeed(id)
*/
	reset_user_model(id)
	set_pev(id, pev_gravity, 1.0)
	
	cs_set_player_view_model(id, CSW_KNIFE, "models/v_knife.mdl")
	cs_set_player_weap_model(id, CSW_KNIFE, "models/p_knife.mdl")
	cs_reset_player_maxspeed(id)

//////////////////// TURN OFF FLASHLIGHT ////////////////////	
	static effects
	effects = pev(id, pev_effects)
	
	if(effects & EF_DIMLIGHT)
	{
		message_begin(MSG_ONE, g_msg_flashlight, _, id)
		write_byte(0)
		write_byte(100)
		message_end()
		
		set_pev(id, pev_effects, effects & ~EF_DIMLIGHT)
	}
//////////////////////////////////////////////////////////////	
}

public drop_user(id)
{
	if(!is_user_alive(id)) 
		return
		
	strip_user_weapons(id)
	give_item(id, "weapon_knife")
}

public display_equipmenu(id)
{
	static menubody[512], len
  	len = formatex(menubody, 511, "\y%L^n^n", id, "MENU_TITLE1")
	
	static bool:hasweap
	hasweap = ((g_player_weapons[id][0]) != -1 && (g_player_weapons[id][1] != -1)) ? true : false
	
	len += formatex(menubody[len], 511 - len,"\w1. %L^n", id, "MENU_NEWWEAPONS")
	len += formatex(menubody[len], 511 - len,"%s2. %L^n", hasweap ? "\w" : "\d", id, "MENU_PREVSETUP")
	len += formatex(menubody[len], 511 - len,"%s3. %L^n^n", hasweap ? "\w" : "\d", id, "MENU_DONTSHOW")
	len += formatex(menubody[len], 511 - len,"\w5. %L^n", id, "MENU_EXIT")
	
	static keys
	keys = (MENU_KEY_1|MENU_KEY_5)
	
	if(hasweap) 
		keys |= (MENU_KEY_2|MENU_KEY_3)
	
	show_menu(id, keys, menubody, -1, "Equipment")
}

public action_equip(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED
		
	if (0 < g_buytime < get_gametime())
	{
		colored_print(id, "^x04 ***^x01 Buy time is OFF!")
		return PLUGIN_HANDLED
	}
	
	switch(key)
	{
		case 0: display_weaponmenu(id, MENU_PRIMARY, g_menuposition[id] = 0)
		case 1: equipweapon(id, EQUIP_ALL)
		case 2:
		{
			g_showmenu[id] = false
			equipweapon(id, EQUIP_ALL)
			client_print(id, print_chat, "Print /guns in chat to re-order weapons.")
		}
	}
	
	if(key > 0)
	{
		g_menufailsafe[id] = false
		remove_task(TASKID_WEAPONSMENU + id)
	}
	return PLUGIN_HANDLED
}


public display_weaponmenu(id, menuid, pos)
{
	if(pos < 0 || menuid < 0)
		return
	
	static start
	start = pos * 8
	
	static maxitem
	maxitem = menuid == MENU_PRIMARY ? sizeof g_primaryweapons : sizeof g_secondaryweapons

  	if(start >= maxitem)
    		start = pos = g_menuposition[id]
	
	static menubody[512], len
  	len = formatex(menubody, 511, "\y%L\w^n^n", id, menuid == MENU_PRIMARY ? "MENU_TITLE2" : "MENU_TITLE3")

	static end
	end = start + 8
	if(end > maxitem)
    		end = maxitem
	
	static keys
	keys = MENU_KEY_0
	
	static a, b
	b = 0
	
  	for(a = start; a < end; ++a) 
	{
		keys |= (1<<b)
		len += formatex(menubody[len], 511 - len,"%d. %s^n", ++b, menuid == MENU_PRIMARY ? g_primaryweapons[a][0]: g_secondaryweapons[a][0])
  	}

  	if(end != maxitem)
	{
    		formatex(menubody[len], 511 - len, "^n9. %L^n0. %L", id, "MENU_MORE", id, pos ? "MENU_BACK" : "MENU_EXIT")
    		keys |= MENU_KEY_9
  	}
  	else	
		formatex(menubody[len], 511 - len, "^n0. %L", id, pos ? "MENU_BACK" : "MENU_EXIT")
	
  	show_menu(id, keys, menubody, -1, menuid == MENU_PRIMARY ? "Primary" : "Secondary")
}

public action_prim(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED

	if (0 < g_buytime < get_gametime())
	{
		colored_print(id, "^x04 ***^x01 Buy time is OFF!")
		return PLUGIN_HANDLED
	}
		
	switch(key)
	{
    		case 8: display_weaponmenu(id, MENU_PRIMARY, ++g_menuposition[id])
		case 9: display_weaponmenu(id, MENU_PRIMARY, --g_menuposition[id])
    		default:
		{
			g_player_weapons[id][0] = g_menuposition[id] * 8 + key
			equipweapon(id, EQUIP_PRI)
			
			display_weaponmenu(id, MENU_SECONDARY, g_menuposition[id] = 0)
		}
	}
	
	return PLUGIN_HANDLED
}

public action_sec(id, key)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_HANDLED
	
	if (0 < g_buytime < get_gametime())
	{
		colored_print(id, "^x04 ***^x01 Buy time is OFF!")
		return PLUGIN_HANDLED
	}
	
	switch(key) 
	{
    		case 8: display_weaponmenu(id, MENU_SECONDARY, ++g_menuposition[id])
		case 9: display_weaponmenu(id, MENU_SECONDARY, --g_menuposition[id])
    		default:
		{
			g_menufailsafe[id] = false
			remove_task(TASKID_WEAPONSMENU + id)
			
			g_player_weapons[id][1] = g_menuposition[id] * 8 + key
			equipweapon(id, EQUIP_SEC)
////////////////// Grenade equipment /////////////////////////////			
			equipweapon(id, EQUIP_GREN)
		}
	}
	
	return PLUGIN_HANDLED
}

public register_spawnpoints(const mapname[])
{
	new configdir[32]
	get_configsdir(configdir, 31)
	
	new csdmfile[64], line[64], data[10][6]
	formatex(csdmfile, 63, "%s/csdm/%s.spawns.cfg", configdir, mapname)

	if(file_exists(csdmfile))
	{
		new file
		file = fopen(csdmfile, "rt")
		
		while(file && !feof(file))
		{
			fgets(file, line, 63)
			if(!line[0] || str_count(line,' ') < 2) 
				continue

			parse(line, data[0], 5, data[1], 5, data[2], 5, data[3], 5, data[4], 5, data[5], 5, data[6], 5, data[7], 5, data[8], 5, data[9], 5)

			g_spawns[g_spawncount][0] = floatstr(data[0]), g_spawns[g_spawncount][1] = floatstr(data[1])
			g_spawns[g_spawncount][2] = floatstr(data[2]), g_spawns[g_spawncount][3] = floatstr(data[3])
			g_spawns[g_spawncount][4] = floatstr(data[4]), g_spawns[g_spawncount][5] = floatstr(data[5])
			g_spawns[g_spawncount][6] = floatstr(data[7]), g_spawns[g_spawncount][7] = floatstr(data[8])
			g_spawns[g_spawncount][8] = floatstr(data[9])
			
			if(++g_spawncount >= MAX_SPAWNS) 
				break
		}
		if(file) 
			fclose(file)
	}
}

public register_zombieclasses(filename[])
{
	new configdir[32]
	get_configsdir(configdir, 31)
	
	new configfile[64]
	formatex(configfile, 63, "%s/%s", configdir, filename)

	if(get_pcvar_num(cvar_zombie_class) && file_exists(configfile))
	{			
		new line[128], leftstr[32], rightstr[64],  classname[32], data[MAX_DATA], i
		
		new file
		file = fopen(configfile, "rt")
		
		while(file && !feof(file))
		{
			fgets(file, line, 127), trim(line)
			if(!line[0] || line[0] == ';') continue
			
			if(line[0] == '[' && line[strlen(line) - 1] == ']')
			{
				copy(classname, strlen(line) - 2, line[1])

				if(register_class(classname) == -1)
					break
				
				continue
			}
			strtok(line, leftstr, 31, rightstr, 63, '=', 1)
				
			if(equali(leftstr, "DESC"))
				copy(g_class_desc[g_classcount - 1], 31, rightstr)
			else if(equali(leftstr, "PMODEL"))
				copy(g_class_pmodel[g_classcount - 1], 63, rightstr)
			else if(equali(leftstr, "WMODEL"))
				copy(g_class_wmodel[g_classcount - 1], 63, rightstr)
				
			for(i = 0; i < MAX_DATA; i++)
				data[i] = equali(leftstr, g_dataname[i])
				
			for(i = 0; i < MAX_DATA; i++) if(data[i])
			{
				g_class_data[g_classcount - 1][i] = floatstr(rightstr)
				break
			}
		}
		if(file) fclose(file)
	} 
	else 
		register_class("default")
}

public register_class(classname[])
{
	if(g_classcount >= MAX_CLASSES)
		return -1
	
	copy(g_class_name[g_classcount], 31, classname)
	copy(g_class_pmodel[g_classcount], 63, DEFAULT_PMODEL)
	copy(g_class_wmodel[g_classcount], 63, DEFAULT_WMODEL)
		
	g_class_data[g_classcount][DATA_HEALTH] = DEFAULT_HEALTH
	g_class_data[g_classcount][DATA_SPEED] = DEFAULT_SPEED	
	g_class_data[g_classcount][DATA_GRAVITY] = DEFAULT_GRAVITY
	g_class_data[g_classcount][DATA_ATTACK] = DEFAULT_ATTACK
	g_class_data[g_classcount][DATA_DEFENCE] = DEFAULT_DEFENCE
	g_class_data[g_classcount][DATA_HEDEFENCE] = DEFAULT_HEDEFENCE
	g_class_data[g_classcount][DATA_HITSPEED] = DEFAULT_HITSPEED
	g_class_data[g_classcount][DATA_HITDELAY] = DEFAULT_HITDELAY
	g_class_data[g_classcount][DATA_REGENDLY] = DEFAULT_REGENDLY
	g_class_data[g_classcount][DATA_HITREGENDLY] = DEFAULT_HITREGENDLY
	g_class_data[g_classcount++][DATA_KNOCKBACK] = DEFAULT_KNOCKBACK
	
	return (g_classcount - 1)
}

public native_register_class(classname[], description[])
{
	param_convert(1)
	param_convert(2)
	
	static classid
	classid = register_class(classname)
	
	if(classid != -1)
		copy(g_class_desc[classid], 31, description)

	return classid
}

public native_set_class_pmodel(classid, player_model[])
{
	param_convert(2)
	copy(g_class_pmodel[classid], 63, player_model)
}

public native_set_class_wmodel(classid, weapon_model[])
{
	param_convert(2)
	copy(g_class_wmodel[classid], 63, weapon_model) 
}

public native_is_user_zombie(index)
	return g_zombie[index] == true ? 1 : 0

public native_get_user_class(index)
	return g_player_class[index]

public native_is_user_infected(index)
	return g_preinfect[index] == true ? 1 : 0

public native_game_started()
	return g_gamestarted

public native_preinfect_user(index, bool:yesno)
{
	if(is_user_alive(index) && !g_gamestarted)
		g_preinfect[index] = yesno
}

public native_infect_user(victim, attacker)
{
	if(allow_infection() && g_gamestarted)
		infect_user(victim, attacker)
}

public native_cure_user(index)
	cure_user(index)

public native_get_class_id(classname[])
{
	param_convert(1)
	
	static i
	for(i = 0; i < g_classcount; i++)
	{
		if(equali(classname, g_class_name[i]))
			return i
	}
	return -1
}

public Float:native_get_class_data(classid, dataid)
	return g_class_data[classid][dataid]

public native_set_class_data(classid, dataid, Float:value)
	g_class_data[classid][dataid] = value

bool:fm_is_hull_vacant(const Float:origin[3], hull)
{
	static tr
	tr = 0
	
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr)
	return (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen)) ? true : false
}

stock fm_find_ent_by_owner(index, const classname[], owner) 
{
	static ent
	ent = index
	
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) && pev(ent, pev_owner) != owner) {}
	
	return ent
}

bacon_strip_weapon(index, weapon[])
{
	if(!equal(weapon, "weapon_", 7)) 
		return 0

	static weaponid 
	weaponid = get_weaponid(weapon)
	
	if(!weaponid) 
		return 0

	static weaponent
	weaponent = find_ent_by_owner(-1, weapon, index)
	
	if(!weaponent) 
		return 0

	if(get_user_weapon(index) == weaponid) 
		ExecuteHamB(Ham_Weapon_RetireWeapon, weaponent)

	if(!ExecuteHamB(Ham_RemovePlayerItem, index, weaponent)) 
		return 0
	
	ExecuteHamB(Ham_Item_Kill, weaponent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))

	return 1
}

stock str_count(str[], searchchar)
{
	static maxlen
	maxlen = strlen(str)
	
	static i, count
	count = 0
	
	for(i = 0; i <= maxlen; i++) if(str[i] == searchchar)
		count++

	return count
}

set_zombie_attibutes(index)
{
	if(!is_user_alive(index)) 
		return

	g_zombie[index] = true

	if(!task_exists(TASKID_STRIPNGIVE + index))
		set_task(0.1, "task_stripngive", TASKID_STRIPNGIVE + index)

	static Float:health
	health = g_class_data[g_player_class[index]][DATA_HEALTH]
	
	set_pev(index, pev_health, health)
	set_pev(index, pev_gravity, g_class_data[g_player_class[index]][DATA_GRAVITY])
	set_pev(index, pev_body, 0)
	set_pev(index, pev_armorvalue, 0.0)
	set_pev(index, pev_renderamt, 0.0)
	set_pev(index, pev_rendermode, kRenderTransTexture)
	
/*	
	// it requires name of folder in models path
	new szFilePath[] = DEFAULT_PMODEL
	new szFile[32], MODEL[16], extension[4]
	remove_filepath(szFilePath, szFile, 31)
	strtok(szFile, MODEL, 15, extension, 3, '.', 0)
	cs_set_player_model(index, MODEL)
	
	set_user_rendering(index)
	cs_set_player_maxspeed(index, DEFAULT_SPEED)
*/

	if(!pev_valid(g_modelent[index]))
	{
		static ent
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(pev_valid(ent))
		{
			engfunc(EngFunc_SetModel, ent, g_class_pmodel[g_player_class[index]])
			set_pev(ent, pev_classname, MODEL_CLASSNAME)
			set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
			set_pev(ent, pev_aiment, index)
			set_pev(ent, pev_owner, index)
				
			g_modelent[index] = ent
		}
	}
	else
	{
		engfunc(EngFunc_SetModel, g_modelent[index], g_class_pmodel[g_player_class[index]])
		fm_set_entity_visibility(g_modelent[index], 1)
	}
	
	if(get_pcvar_num(cvar_autonvg)) 
		engclient_cmd(index, "nightvision")
	
	static effects
	effects = pev(index, pev_effects)
	
	if(effects & EF_DIMLIGHT)
	{
		message_begin(MSG_ONE, g_msg_flashlight, _, index)
		write_byte(0)
		write_byte(100)
		message_end()
		
		set_pev(index, pev_effects, effects & ~EF_DIMLIGHT)
	}
}

bool:allow_infection()
{
	static count[2]
	count[0] = 0
	count[1] = 0
	
	static index, maxzombies
	for(index = 1; index <= g_maxplayers; index++)
	{
		if(is_user_connected(index) && g_zombie[index]) 
			count[0]++
		else if(is_user_alive(index)) 
			count[1]++
	}
	
	maxzombies = clamp(get_pcvar_num(cvar_maxzombies), 1, 31)
	return (count[0] < maxzombies && count[1] > 1) ? true : false
}

randomly_pick_zombie()
{
	static data[4]
	data[0] = 0 
	data[1] = 0 
	data[2] = 0 
	data[3] = 0
	
	static index, players[2][24]
	for(index = 1; index <= g_maxplayers; index++)
	{
		if(!is_user_alive(index)) 
			continue
		
		if(g_zombie[index])
		{
			data[0]++
			players[0][data[2]++] = index
		}
		else 
		{
			data[1]++
			players[1][data[3]++] = index
		}
	}

	if(data[0] > 0 &&  data[1] < 1) 
		return players[0][_random(data[2])]
	
	return (data[0] < 1 && data[1] > 0) ?  players[1][_random(data[3])] : 0
}

equipweapon(id, weapon)
{
	if(!is_user_alive(id)) 
		return

	static weaponid[2], weaponent, weapname[32]
	
	if(weapon & EQUIP_PRI)
	{
		weaponent = fm_lastprimary(id)
		weaponid[1] = get_weaponid(g_primaryweapons[g_player_weapons[id][0]][1])
		
		if(pev_valid(weaponent))
		{
			weaponid[0] = cs_get_weapon_id(weaponent)
			if(weaponid[0] != weaponid[1])
			{
				get_weaponname(weaponid[0], weapname, 31)
				bacon_strip_weapon(id, weapname)
			}
		}
		else
			weaponid[0] = -1
		
		if(weaponid[0] != weaponid[1])
			give_item(id, g_primaryweapons[g_player_weapons[id][0]][1])
		
		cs_set_user_bpammo(id, weaponid[1], g_weapon_ammo[weaponid[1]][MAX_AMMO])
	}

	if(weapon & EQUIP_SEC)
	{
		weaponent = fm_lastsecondry(id)
		weaponid[1] = get_weaponid(g_secondaryweapons[g_player_weapons[id][1]][1])
		
		if(pev_valid(weaponent))
		{
			weaponid[0] = cs_get_weapon_id(weaponent)
			if(weaponid[0] != weaponid[1])
			{
				get_weaponname(weaponid[0], weapname, 31)
				bacon_strip_weapon(id, weapname)
			}
		}
		else
			weaponid[0] = -1
		
		if(weaponid[0] != weaponid[1])
			give_item(id, g_secondaryweapons[g_player_weapons[id][1]][1])
		
		cs_set_user_bpammo(id, weaponid[1], g_weapon_ammo[weaponid[1]][MAX_AMMO])
	}
	
	new mapName[32]
	get_mapname(mapName,31)
	if(weapon & EQUIP_GREN && !equal(mapName, "ze_lift_escape_b5"))
	{
		static i
		for(i = 0; i < sizeof g_grenades; i++) if(!user_has_weapon(id, get_weaponid(g_grenades[i])))
			give_item(id, g_grenades[i])
	}
}

add_delay(index, const task[])
{
	switch(index)
	{
		case 1..6:   set_task(0.4, task, index)
		case 7..12:  set_task(0.6, task, index)
		case 13..18: set_task(0.8, task, index)
		case 19..24: set_task(1.0, task, index)
	}
}

// Get User Team
stock fm_get_user_team(id)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return TEAM_SPECTATOR;
	
	return get_pdata_int(id, OFFSET_TEAM, 5);
}

stock fm_get_user_deaths(id)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return 0;
	
	return get_pdata_int(id, OFFSET_DEATH);
}

stock fm_set_user_deaths(id, value)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return;
	
	set_pdata_int(id, OFFSET_DEATH, value);
}

stock fm_get_user_armortype(id)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return 0;
	
	return get_pdata_int(id, OFFSET_ARMOR);
}

stock fm_set_user_armortype(id, ARMOR)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return;
	
	set_pdata_int(id, OFFSET_ARMOR, ARMOR);
}

stock fm_set_weapon_ammo(id, max)
{
	// Prevent server crash if entity is not safe for pdata retrieval
	if (pev_valid(id) != 2)
		return;
	
	set_pdata_int(id, OFFSET_CLIPAMMO, max, EXTRAOFFSET_WEAPONS);
}

stock reset_user_model(index)
{
	set_pev(index, pev_rendermode, kRenderNormal)
	set_pev(index, pev_renderamt, 0.0)

	if(pev_valid(g_modelent[index]))
		fm_set_entity_visibility(g_modelent[index], 0)
}

stock remove_user_model(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	if(pev_valid(ent)) 
		engfunc(EngFunc_RemoveEntity, ent)

	g_modelent[id] = 0
}

stock fm_set_entity_visibility(index, visible = 1)
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)
