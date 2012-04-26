#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colored_print>

#define PLUG_NAME 		"HATS"
#define PLUG_AUTH 		"SgtBane"
#define PLUG_VERS 		"1.8"
#define PLUG_TAG 		"HATS"
#define VIP		ADMIN_LEVEL_H		//Access flags required to give/remove hats
#define ADMIN 	ADMIN_IMMUNITY		//Access flags required to set personal hat if admin only is enabled

#define menusize 		220
#define modelpath		"models/hat"

stock fm_set_entity_visibility(index, visible = 1) set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

new g_HatEnt[33]
new CurrentHat[33]
new CurrentMenu[33]

new HatFile[64]
new MenuPages, TotalHats

#define MAX_HATS 64
new HATMDL[MAX_HATS][26]
new HATNAME[MAX_HATS][26]

public plugin_init() {
	register_plugin(PLUG_NAME, PLUG_VERS, PLUG_AUTH)
	
	register_menucmd(register_menuid("\yHat Menu: [Page"),	(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9),"MenuCommand")
	register_clcmd("say /hats",			"ShowMenu")
	register_clcmd("say_team /hats",			"ShowMenu")
}

public ShowMenu(id) {
	if (get_user_flags(id) & VIP || get_user_flags(id) & ADMIN)
	{
		CurrentMenu[id] = 1
		ShowHats(id)
	} 
	else 
	{
		colored_print(id,"^x01[^x04%s^x01] Доступны только для ^x03VIP^x01.",PLUG_TAG)
	}
	return PLUGIN_HANDLED
}

public ShowHats(id) {
	new keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	
	new szMenuBody[menusize + 1], WpnID
	new nLen = format(szMenuBody, menusize, "\yHat Menu: [Page %i/%i]^n",CurrentMenu[id],MenuPages)
	
	// Get Hat Names And Add Them To The List
	for (new hatid=0; hatid < 8; hatid++) {
		WpnID = ((CurrentMenu[id] * 8) + hatid - 8)
		if (WpnID < TotalHats) 
		{
			nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w%i. %s", hatid + 1, HATNAME[WpnID])
		}
	}
	
	// Next Page And Previous/Close
	if (CurrentMenu[id] == MenuPages) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\d9. Вперед")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\w9. Вперед")
	}
	
	if (CurrentMenu[id] > 1) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Назад")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Закрыть")
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
			if (HatID < TotalHats) 
			{
				Set_Hat(id,HatID,id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public plugin_precache() {
	new cfgDir[32]
	get_configsdir(cfgDir,31)
	formatex(HatFile,63,"%s/HatList.ini",cfgDir)
	command_load()
	new tmpfile [101]
	for (new i = 1; i < TotalHats; ++i) {
		format(tmpfile, 100, "%s/%s", modelpath, HATMDL[i])
		if (file_exists (tmpfile)) {
			precache_model(tmpfile)
			server_print("[%s] Precached %s", PLUG_TAG, HATMDL[i])
		} else {
			server_print("[%s] Failed to precache %s", PLUG_TAG, tmpfile)
		}
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
		if (targeter != 0) {
			colored_print(targeter, "^x01[^x04%s^x01] ^x03%s ^x01снял шапку",PLUG_TAG,name)
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
		CurrentHat[player] = imodelnum
		
		colored_print(0, "^x01[^x04%s^x01] VIP ^x03%s ^x01надел шапку ^x04%s",PLUG_TAG,name,HATNAME[imodelnum])
		
	}
}

public command_load() {
	if(file_exists(HatFile)) {
		HATMDL[0] = ""
		HATNAME[0] = "Снять"
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
			
			TotalHats += 1
			if(TotalHats >= MAX_HATS) {
				server_print("[%s] Reached hat limit",PLUG_TAG)
				break
			}
		}
		if(file) fclose(file)
	}
	MenuPages = floatround((TotalHats / 8.0), floatround_ceil)
	server_print("[%s] Loaded %i hats, and Generated %i pages",PLUG_TAG,TotalHats,MenuPages)
}