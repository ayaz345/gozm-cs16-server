#include <amxmodx>
#include <fakemeta>

#define KEYS_STR_LEN 31
#define LIST_STR_LEN 610
#define BOTH_STR_LEN KEYS_STR_LEN + LIST_STR_LEN

new g_maxplayers;
new g_isconnected[MAX_PLAYERS+1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])

new cl_keys[33]
new keys_string[33][KEYS_STR_LEN+1]

public plugin_init()
{
    register_plugin("SpecInfo", "2.0", "GoZm");

    register_forward(FM_ClientDisconnect, "fwd_client_disconnect")

    g_maxplayers = get_maxplayers()

    set_task(0.1, "keys_update", _, _, _, "b")
}

public client_putinserver(id)
{
    g_isconnected[id] = true
    
    return PLUGIN_CONTINUE
}

public fwd_client_disconnect(id)
{
    g_isconnected[id] = false

    return FMRES_IGNORED
}

public keys_update()
{
	new players[32], num, id, id2

	get_players(players, num, "a")
	for (new i=0; i<num; i++)
    {
        id = players[i]
        formatex(keys_string[id], KEYS_STR_LEN, " ^n^t^t%s^t^t^t%s^n^t%s %s %s^t^t%s",
            cl_keys[id] & IN_FORWARD ? "W" : " .",
            "%s",
            cl_keys[id] & IN_MOVELEFT ? "A" : ".",
            cl_keys[id] & IN_BACK ? "S" : ".",
            cl_keys[id] & IN_MOVERIGHT ? "D" : ".",
            "%s"
        )

        //Flags stored in string to fill translation char in clmsg function
        keys_string[id][0] = 0
        if (cl_keys[id] & IN_JUMP)
            keys_string[id][0] |= IN_JUMP
        if (cl_keys[id] & IN_DUCK)
            keys_string[id][0] |= IN_DUCK

        cl_keys[id] = 0
	}

	get_players(players, num, "ch")
	for (new i=0; i<num; i++)
    {
        id = players[i]
        id2 = pev(id, pev_iuser2)
        if (id2 && id2 != id)
            clmsg(id)
	}
}

public client_PreThink(id)
{
    if (!is_user_valid_connected(id)) 
        return PLUGIN_CONTINUE
    
    new user_button = pev(id, pev_button)
    if (user_button == 0) 
        return PLUGIN_CONTINUE // saves a lot of cpu

    if (user_button & IN_FORWARD)
        cl_keys[id] |= IN_FORWARD
    if (user_button & IN_BACK)
        cl_keys[id] |= IN_BACK
    if (user_button & IN_MOVELEFT)
        cl_keys[id] |= IN_MOVELEFT
    if (user_button & IN_MOVERIGHT)
        cl_keys[id] |= IN_MOVERIGHT
    if (user_button & IN_DUCK)
        cl_keys[id] |= IN_DUCK
    if (user_button & IN_JUMP)
        cl_keys[id] |= IN_JUMP

    return PLUGIN_CONTINUE
}

clmsg(id)
{
    if (!id)
        return

    new id2 = pev(id, pev_iuser2)
    if (!id2)
        return

    set_hudmessage(
        45, /*red*/
        89, /*grn*/
        116, /*blu*/
        0.48, /*x*/
        0.44, /*y*/
        0, /*fx*/
        0.0, /*fx time*/
        0.1, /*hold time*/
        0.1, /*fade in*/
        0.1, /*fade out*/
        3 /*chan*/
    )
    new msg[BOTH_STR_LEN+1]
    msg ="^n^n^n^n^n^n^n^n^n^n^n^n"
        
    format(msg, BOTH_STR_LEN, "%s%s", msg, keys_string[id2][1])
    format(msg, BOTH_STR_LEN, msg,
        keys_string[id2][0] & IN_JUMP ? "jump" : "-",
        keys_string[id2][0] & IN_DUCK ? "duck" : "-"
    )
    show_hudmessage(id, msg)
}
