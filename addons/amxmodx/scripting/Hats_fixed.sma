#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colored_print>

#define PLUG_NAME 		"HATS"
#define PLUG_AUTH 		"SgtBane & Dumka"
#define PLUG_VERS 		"1.8.1"
#define PLUG_TAG 		"HATS"
#define PLUG_ADMIN		ADMIN_RCON			//Access flags required to give/remove hats
#define PLUG_VIP 		ADMIN_LEVEL_H		//Access flags required to set personal hat if admin only is enabled

#define HAT_ALL			0
#define HAT_DUMKA		4

#define menusize 		220
#define maxTry			15					//Number of tries to get someone a non-admin random hat before giving up.
#define modelpath		"models/hat"

stock fm_set_entity_visibility(index, visible = 1) set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

new g_HatEnt[33]
new CurrentHat[33]
new CurrentMenu[33]

new HatFile[64], UsersHats[64]
new MenuPages, TotalHats

#define MAX_HATS 64
new HATMDL[MAX_HATS][26]
new HATNAME[MAX_HATS][26]
new HATREST[MAX_HATS]
new PLAYERNAME[MAX_HATS][32]

new P_AdminOnly
new P_FileHat

public plugin_init() {
	register_plugin(PLUG_NAME, PLUG_VERS, PLUG_AUTH)
	register_logevent("event_roundstart", 	2,	"1=Round_Start")
	
	register_menucmd(register_menuid("\yHat Menu: [Page"),	(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9),"MenuCommand")
	register_clcmd("say /hats",			"ShowMenu", -1, 	"Shows Knife menu")
	register_clcmd("say /hats",			"ShowMenu", -1, 	"Shows Knife menu")
	
	P_AdminOnly		= register_cvar("hat_adminonly",	"1")	//Only admins can use the menu
	P_FileHat		= register_cvar("hat_file", 		"1")	//Load hats from file as player connects	
}

public ShowMenu(id) {
	if ((get_pcvar_num(P_AdminOnly) == 1 && get_user_flags(id) & PLUG_VIP)) {
		CurrentMenu[id] = 1
		ShowHats(id)
	} else {
		colored_print(id,"^x01[^x04%s^x01] Only^x03 VIPs^x01 may currently use this menu.",PLUG_TAG)
	}
	return PLUGIN_HANDLED
}

public ShowHats(id) {
	new keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	
	new szMenuBody[menusize + 1], WpnID
	new nLen = format(szMenuBody, menusize, "\yHat Menu: [Page %i/%i]^n",CurrentMenu[id],MenuPages)
	
	new MnuClr[3]
	// Get Hat Names And Add Them To The List
	for (new hatid=0; hatid < 8; hatid++) {
		WpnID = ((CurrentMenu[id] * 8) + hatid - 8)
		if (WpnID < TotalHats) {
			menucolor(id, WpnID, MnuClr)
			nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w%i.%s %s", hatid + 1, MnuClr, HATNAME[WpnID])
		}
	}
	
	// Next Page And Previous/Close
	if (CurrentMenu[id] == MenuPages) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\d9. Next Page")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\w9. Next Page")
	}
	
	if (CurrentMenu[id] > 1) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Previous Page")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Close")
	}
	show_menu(id, keys, szMenuBody, -1)
	return PLUGIN_HANDLED
}

public MenuCommand(id, key) {
	switch(key)
	{
		case 8:		//9 - [Next Page]
		{
			if (CurrentMenu[id] < MenuPages) CurrentMenu[id]++
			ShowHats(id)
			return PLUGIN_HANDLED
		}
		case 9:		//0 - [Close]
		{
			CurrentMenu[id]--
			if (CurrentMenu[id] > 0) ShowHats(id)
			return PLUGIN_HANDLED
		}
		default:
		{
			new HatID = ((CurrentMenu[id] * 8) + key - 8)
			new player_on_line
			if (HatID < TotalHats) {
				if (HATREST[HatID] == HAT_DUMKA && !(get_user_flags(id) & PLUG_ADMIN))
					colored_print(id, "^x01[^x04%s^x01] This Hat is too^x03 COOL^x01 for you!", PLUG_TAG)
				else {
					Set_Hat(id, HatID, 0)
					player_on_line = get_player_from_file(id)
					write_player_to_file(id, HatID, player_on_line)
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public plugin_precache() {
	new cfgDir[32]
	get_configsdir(cfgDir,31)
	formatex(HatFile,63,"%s/HatList.ini",cfgDir)
	formatex(UsersHats,63,"%s/UsersHats.ini",cfgDir)
	command_load()
	new tmpfile [101]
	for (new i = 1; i < TotalHats; ++i) {
		format(tmpfile, 100, "%s/%s", modelpath, HATMDL[i])
		if (file_exists (tmpfile)) {
			precache_model(tmpfile)
		} else {
			log_amx("[%s] Failed to precache %s", PLUG_TAG, tmpfile)
		}
	}
}

public client_putinserver(id) {
	if (get_pcvar_num(P_FileHat) == 1 && get_user_flags(id) & PLUG_VIP) {
		load_hat_from_file(id)
	}
	return PLUGIN_CONTINUE
}

public event_roundstart() {
	for (new i = 0; i < get_maxplayers(); ++i) {
		if (is_user_connected(i)) {
			add_delay(i, "Reload_Hat")
		}
	}
	return PLUGIN_CONTINUE
}

public Reload_Hat(id)
{
	Set_Hat(id, 0, -1)
	if (get_user_flags(id) & PLUG_VIP) {
		load_hat_from_file(id)
	}
}

public Set_Hat(player, imodelnum, targeter) {
	new name[32]
	new tmpfile[101]
	format(tmpfile, 100, "%s/%s", modelpath, HATMDL[imodelnum])
	get_user_name(player, name, 31)
	if (imodelnum == 0) {
		if(g_HatEnt[player] > 0) {
			fm_set_entity_visibility(g_HatEnt[player], 0)
		}
	} else if (file_exists(tmpfile)) {
		if(g_HatEnt[player] < 1) {
			g_HatEnt[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
			if(g_HatEnt[player] > 0) {
				set_pev(g_HatEnt[player], pev_movetype, MOVETYPE_FOLLOW)
				set_pev(g_HatEnt[player], pev_aiment, player)
				set_pev(g_HatEnt[player], pev_rendermode, 	kRenderNormal)
				engfunc(EngFunc_SetModel, g_HatEnt[player], tmpfile)
			}
		} else {
			engfunc(EngFunc_SetModel, g_HatEnt[player], tmpfile)
		}
		glowhat(player)
		CurrentHat[player] = imodelnum
		if (targeter != -1) {
			colored_print(targeter, "^x01[^x04%s^x01] Set %s on^x03 %s",PLUG_TAG,HATNAME[imodelnum],name)
		}
	}
}

public get_player_from_file(id) {
	new name[32]
	get_user_name(id, name, 31)
	new hat_name[25]
	new hat_model[3]
	new TotalPlayers=1
	new sfLineData[128]
	new file = fopen(UsersHats,"rt")
	while(file && !feof(file)) {
		fgets(file,sfLineData,127)
		
		// Skip Comment ; // and Empty Lines 
		if (sfLineData[0] == ';' || strlen(sfLineData) < 1 || (sfLineData[0] == '/' && sfLineData[1] == '/')) continue
		
		// BREAK IT UP!
		parse(sfLineData, PLAYERNAME[TotalPlayers], 32, hat_name, 25, hat_model, 3)
		if ((containi(PLAYERNAME[TotalPlayers], name) != -1)) {
			fclose(file)
			return TotalPlayers-1
		}
		TotalPlayers += 1
	}
	if(file) fclose(file)
	return -1
}

public write_player_to_file(id, model_id, str_num) {
	new name[32]
	get_user_name(id, name, 31)
	new file = fopen(UsersHats,"r+")
	new data[64], string[10]
	num_to_str(model_id,string,5)
	formatex(data, 63, "^"%s^" ^"%s^" ^"%s^"", name, HATNAME[model_id], string)
	write_file(UsersHats, data, str_num)
	if(file) fclose(file)
}

public command_load() {
	if(file_exists(HatFile)) {
		HATMDL[0] = ""
		HATNAME[0] = "None"
		TotalHats = 1
		new TempCrapA[2]
		new sfLineData[128]
		new file = fopen(HatFile,"rt")
		while(file && !feof(file)) {
			fgets(file,sfLineData,127)
			
			// Skip Comment ; // and Empty Lines 
			if (sfLineData[0] == ';' || strlen(sfLineData) < 1 || (sfLineData[0] == '/' && sfLineData[1] == '/')) continue
			
			// BREAK IT UP!
			parse(sfLineData, HATMDL[TotalHats], 25, HATNAME[TotalHats], 25, TempCrapA, 1)
			
			if (TempCrapA[0] == '4') {
				HATREST[TotalHats] = HAT_DUMKA
			} else {
				HATREST[TotalHats] = HAT_ALL
			}
			TotalHats += 1
			if(TotalHats >= MAX_HATS) {
				break
			}
		}
		if(file) fclose(file)
	}
	MenuPages = floatround((TotalHats / 8.0), floatround_ceil)
}

public menucolor(id, ItemID, MnuClr[3]) {
	//If its the hat they currently have on
	if (ItemID == CurrentHat[id]) {
		MnuClr = "\d"
		return
	}
	if (HATREST[ItemID] == HAT_DUMKA) {
		MnuClr = "\r"
	} else {
		MnuClr = "\w"
	}
	return
}

public glowhat(id) {
	if (!pev_valid(g_HatEnt[id])) 
		return
		
	set_pev(g_HatEnt[id], pev_renderfx,	kRenderFxNone)
	set_pev(g_HatEnt[id], pev_renderamt,	0.0)

	fm_set_entity_visibility(g_HatEnt[id], 1)
	return
}

public load_hat_from_file(id) {
	new player_name[32]
	get_user_name(id, player_name, 31)
	new hat_name[25]
	new hat_model[3]
	new TotalPlayers=1
	new sfLineData[128]
	new file = fopen(UsersHats,"rt")
	while(file && !feof(file)) {
		fgets(file,sfLineData,127)
		
		// Skip Comment ; // and Empty Lines 
		if (sfLineData[0] == ';' || strlen(sfLineData) < 1 || (sfLineData[0] == '/' && sfLineData[1] == '/')) continue
		
		// BREAK IT UP!
		parse(sfLineData, PLAYERNAME[TotalPlayers], 32, hat_name, 25, hat_model, 3)
		if ((containi(PLAYERNAME[TotalPlayers], player_name) != -1)) {
			fclose(file)
			Set_Hat(id, str_to_num(hat_model), -1)
			return
		}
		TotalPlayers += 1
	}
	if(file) fclose(file)
	write_player_to_file(id, 0, -1)
}

public add_delay(index, const task[])
{
	switch(index)
	{
		case 1..6:   set_task(0.2, task, index)
		case 7..12:  set_task(0.3, task, index)
		case 13..18: set_task(0.4, task, index)
		case 19..24: set_task(0.5, task, index)
	}
}