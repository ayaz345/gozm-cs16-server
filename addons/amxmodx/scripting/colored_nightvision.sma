#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <colored_print>

#define PDATA_SAFE          2
#define OFFSET_LINUX        5
#define OFFSET_CSMENUCODE   205

#define IMPULSE_FLASHLIGHT  100
#define TASKID_NIGHTVISION  376
#define DEFAULT_NVG         3

new g_nvault_handle

new g_maxplayers
new active_nv[MAX_PLAYERS + 1]
new active_bl[MAX_PLAYERS + 1]

new g_isconnected[MAX_PLAYERS + 1]
new g_isalive[MAX_PLAYERS + 1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

new g_UserNVG[MAX_PLAYERS + 1]

new const g_Radius = 110
new const g_Colors[][3] =
{
//	R	    G	    B
	{150,	0,	    0},	    // 0
	{0,	    150,	0},	    // 1
	{0,	    0,	    150},	// 2
	{0,	    150,	150},	// 3
	{102,	0,	    255},	// 4
	{255,   222,    173},	// 5
	{255,	255,	0}	    // 6
}

public plugin_init()
{
    register_plugin("Bio Colored Nightvision", "1.0", "Dimka")

    register_clcmd("say /nv", "clcmd_nvg")
    register_clcmd("say_team /nv", "clcmd_nvg")
    register_clcmd("say /nvg", "clcmd_nvg")
    register_clcmd("say_team /nvg", "clcmd_nvg")
    register_clcmd("nightvision", "nightvision")

    register_forward(FM_CmdStart, "fwd_cmdstart")
    register_forward(FM_ClientDisconnect, "fwd_client_disconnect")
    register_forward(FM_AddToFullPack, "FM_AddToFullPack_Post", 1)

    RegisterHam(Ham_Killed, "player", "bacon_killed_player")
    RegisterHam(Ham_Spawn, "player", "bacon_spawn_player_post", 1)

    g_maxplayers = get_maxplayers()
}

public plugin_cfg()
{
    new nvault_file[] = "gozm_nvg"
    g_nvault_handle = nvault_open(nvault_file)
    if (g_nvault_handle == INVALID_HANDLE)
        set_fail_state("[NVG]: Error opening nvault file '%s'", nvault_file)

    nvault_prune(g_nvault_handle, 0, get_systime() - 31*86400)

    return PLUGIN_CONTINUE
}

public clcmd_nvg(id)
{
    nvg_menu(id)
    
    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
    g_isconnected[id] = true
    active_nv[id] = false
    active_bl[id] = false
    g_UserNVG[id] = DEFAULT_NVG

    new name[32], user_nvg[2], ts
    get_user_name(id, name, 31)
    if (nvault_lookup(g_nvault_handle, name, user_nvg, charsmax(user_nvg), ts))
    {
        g_UserNVG[id] = nvault_get(g_nvault_handle, name)
        nvault_touch(g_nvault_handle, name)
    }

    return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
    if (!is_user_valid_connected(id))
        return PLUGIN_CONTINUE

    new newname[32]
    get_user_info(id, "name", newname, 31)
    new oldname[32]
    get_user_name(id, oldname, 31)
    
    if (!equal(oldname, newname) && !equal(oldname, ""))
    {
        if (g_UserNVG[id] != DEFAULT_NVG)
        {
            new s_user_nvg[3]
            num_to_str(g_UserNVG[id], s_user_nvg, charsmax(s_user_nvg))
            nvault_set(g_nvault_handle, newname, s_user_nvg)
        }
    }

    return PLUGIN_CONTINUE
}

public fwd_client_disconnect(id)
{
    g_isconnected[id] = false
    g_isalive[id] = false
    active_nv[id] = false
    active_bl[id] = false
    g_UserNVG[id] = DEFAULT_NVG
    
    remove_task(TASKID_NIGHTVISION + id)
    
    return FMRES_IGNORED
}

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet)
{
	if (1<=iHost<=g_maxplayers && get_orig_retval())
    {
        if (iPlayer && g_isconnected[iHost] && active_bl[iHost])
        {
            if (iHost==iEnt)
                set_es(iEsHandle, ES_Effects, (get_es(iEsHandle, ES_Effects)|EF_BRIGHTLIGHT))
        }
    }
	
	return FMRES_IGNORED
}

public fwd_cmdstart(id, handle, seed)
{
    static impulse
    impulse = get_uc(handle, UC_Impulse)

    if(impulse == IMPULSE_FLASHLIGHT)
    {
        set_uc(handle, UC_Impulse, 0)
        toggle_brightlight(id)
        
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}

public toggle_brightlight(id)
{
    if(active_bl[id] && active_nv[id])
    {
        active_bl[id] = false
    }
    else if(active_bl[id] && !active_nv[id])
    {
        active_bl[id] = false
    }
    else if(!active_bl[id] && active_nv[id])
    {
        toggle_nightvision(id)
        active_bl[id] = true
    }
    else if(!active_bl[id] && !active_nv[id])
    {
        active_bl[id] = true
    }
}

public nightvision(id)
{
	if(is_user_valid_connected(id))
		toggle_nightvision(id)
	
	return PLUGIN_HANDLED
}

public toggle_nightvision(id)
{
    if(active_nv[id] && active_bl[id])
    {
        remove_task(TASKID_NIGHTVISION + id)
        active_nv[id] = false
    }
    else if(active_nv[id] && !active_bl[id])
    {
        remove_task(TASKID_NIGHTVISION + id)
        active_nv[id] = false
    }
    else if(!active_nv[id] && active_bl[id])
    {
        active_bl[id] = false

        set_user_nv(TASKID_NIGHTVISION + id)
        set_task(0.1, "set_user_nv", TASKID_NIGHTVISION + id, _, _, "b")
        active_nv[id] = true
    }
    else if(!active_nv[id] && !active_bl[id])
    {
        set_user_nv(TASKID_NIGHTVISION + id)
        set_task(0.1, "set_user_nv", TASKID_NIGHTVISION + id, _, _, "b")
        active_nv[id] = true
    }
}

public set_user_nv(taskid)
{
    new id = taskid - TASKID_NIGHTVISION
    if(!is_user_valid_connected(id))
        return

    static origin[3]
    get_user_origin(id, origin)

    message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
    write_byte(TE_DLIGHT)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2])
    write_byte(g_Radius)	                    // radius 

    write_byte(g_Colors[g_UserNVG[id]][0])		// red
    write_byte(g_Colors[g_UserNVG[id]][1])		// green
    write_byte(g_Colors[g_UserNVG[id]][2])		// blue

    write_byte(2)
    write_byte(0)
    message_end()
}

public bacon_killed_player(victim, killer, shouldgib)
{
    g_isalive[victim] = false
    active_nv[victim] = false
    active_bl[victim] = false
    
    remove_task(TASKID_NIGHTVISION + victim)

    return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{
    if(!is_user_alive(id))
        return HAM_IGNORED

    g_isalive[id] = true
    active_nv[id] = false
    active_bl[id] = false
    
    remove_task(TASKID_NIGHTVISION + id)

    return HAM_IGNORED
}

public nvg_menu(id)
{
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)  // prevent from showing CS std menu

    new i_Menu = menu_create("\yЦвет NVG:", "nvg_menu_handler" )

    menu_additem(i_Menu, "Красный", "0")
    menu_additem(i_Menu, "Зеленый", "1")
    menu_additem(i_Menu, "Синий", "2")
    menu_additem(i_Menu, "Бирюзовый", "3")
    menu_additem(i_Menu, "Фиолетовый", "4")
    menu_additem(i_Menu, "Белый", "5")
    menu_additem(i_Menu, "Желтый", "6")

    menu_setprop(i_Menu, 2, "Назад")
    menu_setprop(i_Menu, 3, "Вперед")
    menu_setprop(i_Menu, 4, "Закрыть")

    menu_display(id, i_Menu)

    return PLUGIN_HANDLED
}

public nvg_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Data[3], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
    new i_Key = str_to_num(s_Data)
    g_UserNVG[id] = i_Key

    new name[32]
    get_user_name(id, name, 31)
    nvault_set(g_nvault_handle, name, s_Data)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public plugin_end()
{
    nvault_close(g_nvault_handle)
}
