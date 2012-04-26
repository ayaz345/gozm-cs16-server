#include <amxmodx>

#define TASKID 123412

new g_SaveTime, new_timelimit, lastLimit, done

//pcvars
new pOn

public plugin_init()
{ 
	register_plugin("Commencing Prevent", "Nipsu", "1.0")
	pOn = register_cvar("amx_commencing_prevent", "1")
	register_event("TextMsg", "eventGameCommencing", "a", "2=#Game_Commencing")
	register_event("TextMsg", "eventRestart", "a", "2=#Game_will_restart_in")
	set_task(5.0, "saveTime", TASKID)
} 

public eventGameCommencing()
{
	remove_task(TASKID)
	
	set_task(10.0, "resetTime")
}

public eventRestart()
{
	if(done==1 && new_timelimit==get_cvar_num("mp_timelimit"))
		set_cvar_num("mp_timelimit", lastLimit)
	
	done = 0
}

public saveTime()
{
	remove_task(TASKID)
	
	g_SaveTime = get_timeleft()
	
	set_task(5.0, "saveTime", TASKID)
}

public resetTime()
{
	if(!g_SaveTime)
		return
	
	if(!done)
		lastLimit = get_cvar_num("mp_timelimit")
	
	if(get_pcvar_num(pOn))
	{
		new_timelimit = g_SaveTime / 60
		
		if(g_SaveTime % 60 > 15 && new_timelimit < get_cvar_num("mp_timelimit"))
			new_timelimit++
		
		if(new_timelimit < 1)
			new_timelimit++
		
		set_cvar_num("mp_timelimit", new_timelimit)
		
		done = 1
	}
	
	set_task(5.0, "saveTime", TASKID)
}
