#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PDATA_SAFE          2
#define OFFSET_LINUX        5
#define OFFSET_CSMENUCODE   205

#define IMPULSE_FLASHLIGHT  100
#define TASKID_NIGHTVISION  376
#define DEFAULT_NVG         3

new g_maxplayers
new active_nv[MAX_PLAYERS + 1]

new g_isconnected[MAX_PLAYERS + 1]
new g_isalive[MAX_PLAYERS + 1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

new g_UserNVG[MAX_PLAYERS + 1]

new const g_Radius = 100
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

    RegisterHam(Ham_Killed, "player", "bacon_killed_player")
    RegisterHam(Ham_Spawn, "player", "bacon_spawn_player_post", 1)

    g_maxplayers = get_maxplayers()
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
    g_UserNVG[id] = DEFAULT_NVG
    
    return PLUGIN_CONTINUE
}

public fwd_client_disconnect(id)
{
    g_isconnected[id] = false
    g_isalive[id] = false
    active_nv[id] = false
    g_UserNVG[id] = DEFAULT_NVG
    
    remove_task(TASKID_NIGHTVISION + id)
    
    return FMRES_IGNORED
}

public fwd_cmdstart(id, handle, seed)
{
    static impulse
    impulse = get_uc(handle, UC_Impulse)

    if(impulse == IMPULSE_FLASHLIGHT)
    {
        set_uc(handle, UC_Impulse, 0)
        toggle_nightvision(id)
        
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}

public nightvision(id)
{
	if(is_user_valid_connected(id))
		toggle_nightvision(id)
	
	return PLUGIN_HANDLED
}

public toggle_nightvision(id)
{
    if(active_nv[id])
    {
        remove_task(TASKID_NIGHTVISION + id)
        active_nv[id] = false
    }
    else if(!(active_nv[id]))
    {
        set_user_nv(TASKID_NIGHTVISION + id)
        set_task(0.3, "set_user_nv", TASKID_NIGHTVISION + id, _, _, "b")
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
    write_byte(g_Radius)	        // radius 

    write_byte(g_Colors[g_UserNVG[id]][0])		// red
    write_byte(g_Colors[g_UserNVG[id]][1])		// green
    write_byte(g_Colors[g_UserNVG[id]][2])		// blue

    write_byte(4)
    write_byte(0)
    message_end()
}

public bacon_killed_player(victim, killer, shouldgib)
{
    g_isalive[victim] = false
    active_nv[victim] = false
    
    remove_task(TASKID_NIGHTVISION + victim)

    return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{
    if(!is_user_alive(id))
        return HAM_IGNORED

    g_isalive[id] = true
    active_nv[id] = false
    
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

    new s_Data[2], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
    new i_Key = str_to_num(s_Data)
    g_UserNVG[id] = i_Key

    menu_destroy(menu)
    return PLUGIN_HANDLED
}
