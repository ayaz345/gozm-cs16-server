#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colored_print>
#include <nvault>
#include <gozm>

#define PLUG_TAG 		    "HATS"

#define MAX_HATS            64
#define MODELPATH		    "models/hat"

#define PDATA_SAFE          2
#define OFFSET_LINUX        5
#define OFFSET_CSMENUCODE   205

new g_total_hats
new g_nvault_handle

new g_hat_ent[33]

new HATMDL[MAX_HATS][26]
new HATNAME[MAX_HATS][26]

public plugin_init() 
{
    register_plugin("Hats", "2.1", "Dumka")

    if (!is_server_licenced())
        return PLUGIN_CONTINUE

    register_clcmd("say /hats",	"access_hats_menu", -1, "Show Hats menu")
    register_clcmd("say_team /hats", "access_hats_menu", -1, "Show Hats menu")

    return PLUGIN_CONTINUE
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
    new cfg_dir[32], hat_file[64]
    get_configsdir(cfg_dir, charsmax(cfg_dir))
    formatex(hat_file, charsmax(hat_file), "%s/HatList.ini", cfg_dir)

    read_hats_from_file(hat_file)

    new tmpfile[101]
    for (new i = 1; i < g_total_hats; i++) 
    {
        formatex(tmpfile, charsmax(tmpfile), "%s/%s", MODELPATH, HATMDL[i])
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
        get_user_name(id, name, charsmax(name))
        if (nvault_lookup(g_nvault_handle, name, s_user_hat, charsmax(s_user_hat), ts))
        {
            new hat_id = nvault_get(g_nvault_handle, name)
            if (hat_id < g_total_hats)
                set_hat(id, hat_id, -1)
        }
    }

    return PLUGIN_CONTINUE
}

public client_disconnect(id) 
{
    if (g_hat_ent[id] > 0) 
    {
        fm_set_entity_visibility(g_hat_ent[id], false)
        g_hat_ent[id] = 0
    }
}

public client_infochanged(id)
{
    if (!is_user_connected(id))
        return PLUGIN_CONTINUE

    new newname[32], oldname[32]
    get_user_info(id, "name", newname, charsmax(newname))
    get_user_name(id, oldname, charsmax(oldname))

    if (!equal(oldname, newname) && !equal(oldname, ""))
        set_task(0.1, "check_access", id)

    return PLUGIN_CONTINUE
}

public check_access(id)
{
    if (has_vip(id) && !g_hat_ent[id])
    {
        new name[32], s_user_hat[3], ts
        get_user_name(id, name, charsmax(name))
        if (nvault_lookup(g_nvault_handle, name, s_user_hat, charsmax(s_user_hat), ts))
        {
            new hat_id = nvault_get(g_nvault_handle, name)
            set_hat(id, hat_id, -1)
        }
    }
    else if (!has_vip(id) && g_hat_ent[id] > 0)
    {
        fm_set_entity_visibility(g_hat_ent[id], false)
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
        colored_print(id, "^x01[^x04%s^x01] Только^x03 ВИПЫ^x01 могут использовать шапки", PLUG_TAG)
    }

    return PLUGIN_HANDLED
}

public show_hats_menu(id)
{
    if (pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)  // prevent from showing CS std menu

    new i_menu = menu_create("\yШапки:", "hats_menu_handler")

    for (new hat_id = 0; hat_id < g_total_hats; hat_id++) 
    {
        new s_hat_id[3]
        num_to_str(hat_id, s_hat_id, charsmax(s_hat_id))
        menu_additem(i_menu, HATNAME[hat_id], s_hat_id)
    }

    menu_setprop(i_menu, MPROP_BACKNAME, "Назад")
    menu_setprop(i_menu, MPROP_NEXTNAME, "Вперед")
    menu_setprop(i_menu, MPROP_EXITNAME, "Закрыть")

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
    menu_destroy(menu)

    new hat_id = str_to_num(s_hat_num)
    set_hat(id, hat_id, 0)

    new name[32]
    get_user_name(id, name, charsmax(name))
    nvault_set(g_nvault_handle, name, s_hat_num)

    return PLUGIN_HANDLED
}

public set_hat(player, imodelnum, targeter) 
{
    new name[32], tmpfile[101]

    formatex(tmpfile, charsmax(tmpfile), "%s/%s", MODELPATH, HATMDL[imodelnum])
    get_user_name(player, name, charsmax(name))

    if (imodelnum == 0) 
    {
        if(g_hat_ent[player] > 0) 
        {
            fm_set_entity_visibility(g_hat_ent[player], false)
        }
    } 
    else if (file_exists(tmpfile)) 
    {
        if(g_hat_ent[player] < 1) 
        {
            g_hat_ent[player] = 
                engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
            if (g_hat_ent[player] > 0) 
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

public read_hats_from_file(hat_file[])
{
	if (file_exists(hat_file)) 
    {
		HATMDL[0] = ""
		HATNAME[0] = "None"
		g_total_hats = 1
		new temp[2]
		new line[128]

		new file = fopen(hat_file, "rt")
		while (file && !feof(file)) 
        {
			fgets(file, line, charsmax(line))

			// skip commented lines
			if (line[0] == ';' || strlen(line) < 1 || (line[0] == '/' && line[1] == '/')) 
                continue

			// break it up
			parse(line, HATMDL[g_total_hats], 25, HATNAME[g_total_hats], 25, temp, 1)
			
			g_total_hats += 1
			if (g_total_hats >= MAX_HATS) 
            {
				log_amx("[%s] Break command_load()", PLUG_TAG)
				break
			}
		}
		if (file) fclose(file)
	}
}

public glowhat(id) 
{
	if (!pev_valid(g_hat_ent[id])) 
		return

	set_pev(g_hat_ent[id], pev_renderfx, kRenderFxNone)
	set_pev(g_hat_ent[id], pev_renderamt, 0.0)

	fm_set_entity_visibility(g_hat_ent[id], true)

	return
}

public fm_set_entity_visibility(index, bool:visible)
{
    set_pev(
        index, 
        pev_effects, 
        visible ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects)|EF_NODRAW
    )
}
