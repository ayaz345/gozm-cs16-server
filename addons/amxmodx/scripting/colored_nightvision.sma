#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <colored_print>

#define IMPULSE_FLASHLIGHT 100
#define TASKID_NIGHTVISION 376

new g_maxplayers
new activate_nv[MAX_PLAYERS + 1]

new g_isconnected[MAX_PLAYERS + 1]
new g_isalive[MAX_PLAYERS + 1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

new const g_Colors[][3] =
{
//	R	    G	    B
    {0,	    30,	    5},	    // 0
	{150,	0,	    0},	    // 1
	{0,	    150,	0},	    // 2
	{0,	    0,	    150},	// 3
	{0,	    150,	150},	// 4
	{102,	0,	    255},	// 5
	{202,	31,	    123},	// 6
	{255,	255,	0}	    // 7
}
new const g_Radius = 100

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
    colored_print(id, "^x04***^x01 Скоро ты сможешь выбирать цвет ночного!")
    
    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
    g_isconnected[id] = true
    activate_nv[id] = false
    
    return PLUGIN_CONTINUE
}

public fwd_client_disconnect(id)
{
    g_isconnected[id] = false
    g_isalive[id] = false
    activate_nv[id] = false
    
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

    write_byte(g_Colors[0][0])		// red
    write_byte(g_Colors[0][1])		// green
    write_byte(g_Colors[0][2])		// blue

    write_byte(2)
    write_byte(0)
    message_end()
}

public bacon_killed_player(victim, killer, shouldgib)
{
    g_isalive[victim] = false
    activate_nv[victim] = false
    
    remove_task(TASKID_NIGHTVISION + victim)

    return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{
    if(!is_user_alive(id))
        return HAM_IGNORED

    g_isalive[id] = true
    activate_nv[id] = false
    
    remove_task(TASKID_NIGHTVISION + id)

    return HAM_IGNORED
}
