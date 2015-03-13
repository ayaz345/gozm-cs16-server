#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colored_print>
#include <nvault>

#define PLUG_NAME 		    "Hats"
#define PLUG_AUTH 		    "Dumka"
#define PLUG_VERS 		    "2.0"
#define PLUG_TAG 		    "HATS"

#define MAX_HATS            64
#define MODELPATH		    "models/hat"

#define PDATA_SAFE          2
#define OFFSET_LINUX        5
#define OFFSET_CSMENUCODE   205

new g_total_hats
new g_nvault_handle

new g_hat_ent[33]
new g_hat_file[64]

new HATMDL[MAX_HATS][26]
new HATNAME[MAX_HATS][26]

public plugin_init() 
{
    register_plugin(PLUG_NAME, PLUG_VERS, PLUG_AUTH)
    register_clcmd("say /hats",	"access_hats_menu", -1, "Show Hats menu")
    register_clcmd("say_team /hats", "access_hats_menu", -1, "Show Hats menu")
}

public plugin_cfg()
{
    new nvault_file[] = "gozm_hats"
    g_nvault_handle = nvault_open(nvault_file)
    if (g_nvault_handle == INVALID_HANDLE)
        set_fail_state("[%s]: Error opening nvault file '%s'", PLUG_TAG, nvault_file)

    return PLUGIN_CONTINUE
}

public plugin_precache() 
{
	new cfg_dir[32]
	get_configsdir(cfg_dir, 31)
	formatex(g_hat_file, 63, "%s/HatList.ini", cfg_dir)
	command_load()
	new tmpfile[101]
	for (new i=1; i<g_total_hats; i++) 
    {
        format(tmpfile, 100, "%s/%s", MODELPATH, HATMDL[i])
        if (file_exists(tmpfile)) 
        {
            precache_model(tmpfile)
        }
        else 
        {
            log_amx("[%s] Failed to precache: %d. %s", PLUG_TAG, i, tmpfile)
        }
	}
}

public client_putinserver(id) 
{
    g_hat_ent[id] = 0
    if (has_vip(id)) 
    {   
        new name[32], s_user_hat[3], ts
        get_user_name(id, name, 31)
        if (nvault_lookup(g_nvault_handle, name, s_user_hat, charsmax(s_user_hat), ts))
        {
            new i_user_hat
            i_user_hat = nvault_get(g_nvault_handle, name)
            if (i_user_hat < g_total_hats)
                set_hat(id, i_user_hat, -1)
        }
    }
    return PLUGIN_CONTINUE
}

public client_disconnect(id) 
{
    if(g_hat_ent[id] > 0) 
    {
        fm_set_entity_visibility(g_hat_ent[id], 0)
        g_hat_ent[id] = 0
    }
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE

    new newname[32], oldname[32]
    get_user_info(id, "name", newname, 31)
    get_user_name(id, oldname, 31)

    if (!equal(oldname,newname) && !equal(oldname,""))
        set_task(0.1, "check_access", id)

    return PLUGIN_CONTINUE
}

public check_access(id)
{
    if (has_vip(id) && !g_hat_ent[id])
    {
        new name[32], s_user_hat[3], ts
        get_user_name(id, name, 31)
        if (nvault_lookup(g_nvault_handle, name, s_user_hat, charsmax(s_user_hat), ts))
        {
            new i_user_hat
            i_user_hat = nvault_get(g_nvault_handle, name)
            set_hat(id, i_user_hat, -1)
        }
    }
    else if (!has_vip(id) && g_hat_ent[id] > 0)
    {
        fm_set_entity_visibility(g_hat_ent[id], 0)
        g_hat_ent[id] = 0
    }

    return PLUGIN_CONTINUE
}

public plugin_end()
{
    nvault_close(g_nvault_handle)
}

public access_hats_menu(id) 
{
    if (has_vip(id)) 
    {
        show_hats_menu(id)
    } 
    else 
    {
        colored_print(id,"^x01[^x04%s^x01] Только^x03 ВИПЫ^x01 могут использовать шапки", PLUG_TAG)
    }

    return PLUGIN_HANDLED
}

public show_hats_menu(id)
{
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)  // prevent from showing CS std menu

    new i_menu = menu_create("\yШапки:", "hats_menu_handler")

    for (new hat_id=0; hat_id<g_total_hats; hat_id++) 
    {
        new s_hat_id[3]
        num_to_str(hat_id, s_hat_id, charsmax(s_hat_id))
        menu_additem(i_menu, HATNAME[hat_id], s_hat_id)
    }

    menu_setprop(i_menu, 2, "Назад")
    menu_setprop(i_menu, 3, "Вперед")
    menu_setprop(i_menu, 4, "Закрыть")

    menu_display(id, i_menu)

    return PLUGIN_HANDLED
}

public hats_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_hat_num[3], s_hat_name[64], i_access, i_callback
    menu_item_getinfo(
        menu, item, i_access, 
        s_hat_num, charsmax(s_hat_num),
        s_hat_name, charsmax(s_hat_name), 
        i_callback
    )
    new i_hat_num = str_to_num(s_hat_num)
    set_hat(id, i_hat_num, 0)

    new name[32]
    get_user_name(id, name, 31)
    nvault_set(g_nvault_handle, name, s_hat_num)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public set_hat(player, imodelnum, targeter) 
{
    new name[32]
    new tmpfile[101]
    format(tmpfile, 100, "%s/%s", MODELPATH, HATMDL[imodelnum])
    get_user_name(player, name, 31)
    if (imodelnum == 0) 
    {
        if(g_hat_ent[player] > 0) 
        {
            fm_set_entity_visibility(g_hat_ent[player], 0)
        }
    } 
    else if (file_exists(tmpfile)) 
    {
        if(g_hat_ent[player] < 1) 
        {
            g_hat_ent[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
            if(g_hat_ent[player] > 0) 
            {
                set_pev(g_hat_ent[player], pev_movetype, MOVETYPE_FOLLOW)
                set_pev(g_hat_ent[player], pev_aiment, player)
                set_pev(g_hat_ent[player], pev_rendermode, 	kRenderNormal)
                engfunc(EngFunc_SetModel, g_hat_ent[player], tmpfile)
            }
        } 
        else 
        {
            engfunc(EngFunc_SetModel, g_hat_ent[player], tmpfile)
        }
        glowhat(player)
        if (targeter != -1) 
        {
            colored_print(targeter, "^x04***^x03 %s^x01 надел шапку^x04 %s", name, HATNAME[imodelnum])
        }
    }
    else 
    {
        log_amx("[%s] %s not found!", PLUG_TAG, tmpfile)
    }
}

public command_load() {
	if(file_exists(g_hat_file)) 
    {
		HATMDL[0] = ""
		HATNAME[0] = "None"
		g_total_hats = 1
		new TempCrapA[2]
		new sfLineData[128]
		new file = fopen(g_hat_file,"rt")
		while(file && !feof(file)) 
        {
			fgets(file,sfLineData,127)

			// Skip Comment ; // and Empty Lines 
			if (sfLineData[0] == ';' || strlen(sfLineData) < 1 || (sfLineData[0] == '/' && sfLineData[1] == '/')) continue

			// BREAK IT UP!
			parse(sfLineData, HATMDL[g_total_hats], 25, HATNAME[g_total_hats], 25, TempCrapA, 1)
			
			g_total_hats += 1
			if(g_total_hats >= MAX_HATS) 
            {
				log_amx("[%s] Break command_load()", PLUG_TAG)
				break
			}
		}
		if(file) fclose(file)
	}
}

public glowhat(id) 
{
	if (!pev_valid(g_hat_ent[id])) 
		return

	set_pev(g_hat_ent[id], pev_renderfx, kRenderFxNone)
	set_pev(g_hat_ent[id], pev_renderamt, 0.0)

	fm_set_entity_visibility(g_hat_ent[id], 1)
	return
}

stock fm_set_entity_visibility(index, visible=1)
{
    set_pev(
        index, 
        pev_effects, 
        visible == 1 ? pev(index, pev_effects)&~EF_NODRAW : pev(index, pev_effects)|EF_NODRAW
    )
}
