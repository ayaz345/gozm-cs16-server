#include <amxmodx> 

new g_SaveTime=0;
new new_timelimit=0;
new lastLimit=0;
new done=0;

public plugin_init() { 
   register_plugin("Commencing Prevent", "Nipsu", "1.0")
   register_cvar("amx_commencing_prevent", "1")
   register_event("TextMsg", "eventGameCommencing", "a", "2=#Game_Commencing")
   register_event("TextMsg", "eventRestart", "a", "2=#Game_will_restart_in")
   set_task(5.0, "saveTime", 8648459, "", 0, "b")
} 

public eventGameCommencing() {
	remove_task(8648459)
	set_task(10.0, "resetTime")
}

public eventRestart() {
	if(done==1 && new_timelimit==get_cvar_num("mp_timelimit")) set_cvar_num("mp_timelimit", lastLimit);
	done=0;
}

public saveTime() {
	g_SaveTime = get_timeleft();
}

public resetTime() {
	if(g_SaveTime==0) return;

	if(done==0) lastLimit=get_cvar_num("mp_timelimit");

	if(get_cvar_num("amx_commencing_prevent")) {
		new_timelimit = g_SaveTime / 60;
		if(g_SaveTime%60>15 && !(new_timelimit>=get_cvar_num("mp_timelimit"))) new_timelimit++;
		if(new_timelimit<1) new_timelimit++;
		set_cvar_num("mp_timelimit", new_timelimit)
		done=1;
	}

	set_task(5.0, "saveTime", 8648459, "", 0, "b")
}
