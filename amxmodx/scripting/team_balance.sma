#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>

#define PLUGIN "Simple Team Balance"
#define VERSION "1.0"
#define AUTHOR "Alka"
#define ADMIN_IMMUNITY      (1<<0)

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_event("DeathMsg", "_Death_Msg", "a")
}

public _Death_Msg()
{
    new victim = read_data(2)
    new tplayers[32], ctplayers[32], tnum, ctnum;
    get_players(tplayers, tnum, "e", "TERRORIST");
    get_players(ctplayers, ctnum, "e", "CT");
    if(tnum - 2 > ctnum)
    {
        cs_set_user_team(victim, CS_TEAM_CT);
        spawn(victim);
        set_task(0.5,"spawnagain",victim); 
    }
    else if(tnum < ctnum - 2)
    {
        cs_set_user_team(victim, CS_TEAM_T);
        spawn(victim);
        set_task(0.5, "spawnagain", victim); 
    }
}

public spawnagain(id)
{
	if(is_user_connected(id))
    	spawn(id);
}