
/* AMX Mod script. 
* 
* (c) 2002-2003, OLO 
* modified by shadow
* This file is provided as is (no warranties). 
* 
* Players with immunity won't be checked 
*
*
* Settting					// Side effect when enabled
* --------					// -------------------------*/
#define CD_DONT_SEND_STEPSOUND		1	// Players won't hear their own footstep sounds.
#define CD_DONT_SEND_PUNCHANGLE		0	// Players won't see the actual weapon's recoil if using cl_lw 1.
#define CD_DONT_SEND_NEXTATTACK		0	// Players may see weapons fire when they shouldn't if using cl_lw 1.
#define CD_DONT_SEND_VELOCITY		0	// Players may experience sloppy movements.
#define ES_DONT_SEND_ORIGIN_SELF	1	// None that I can see.
#define ES_DONT_SEND_ANGLES_SELF	1	// If using 3rd person view, players will see themselves looking at an odd direction.
#define ES_DONT_SEND_FRAME_SELF		1	// If using 3rd person view, players will see their own weapon animations incorrectly.
#define ES_DONT_SEND_ANIMTIME_SELF	1	// If using 3rd person view, players will see their own weapon animations incorrectly.
#define ES_DONT_SEND_BLENDING_SELF	1	// None that I can see.
#define ES_DONT_SEND_ANGLES_OTHERS	0	// Players will see others looking at an odd direction
#define ES_DONT_SEND_FRAME_OTHERS	0	// Players will see others' weapon animations incorrectly.
#define ES_DONT_SEND_ANIMTIME_OTHERS	0	// Players will see others skipping around.
#define ES_DONT_SEND_BLENDING_OTHERS	1	// None that I can see.


#include <amxmodx> 
#include <fakemeta>

new g_Ping[33]
new g_Samples[33]
new g_Reduce[33]

new cvar_ping,cvar_check,cvar_tests,cvar_delay,cvar_immunity,cvar_c_ping,
cvar_bantime, cvar_punishtype

public plugin_init()
{
	register_plugin("High Ping Reducer","0.16.2","OLO/Empower/MeRcyLeZZ")
	cvar_ping  = register_cvar("amx_hpr_ping","100")
	cvar_c_ping  = register_cvar("amx_hpr_critical_ping","400")
	cvar_bantime = register_cvar("amx_hpr_bantime","5")
	cvar_check = register_cvar("amx_hpr_check","12")
	cvar_tests = register_cvar("amx_hpr_tests","5")
	cvar_delay = register_cvar("amx_hpr_delay","30")
	cvar_immunity = register_cvar("amx_hpr_immunity","1")
	
	// 0 - niche ne delat //1 - kick// 2 - ban
	cvar_punishtype = register_cvar("amx_hpr_punishtype","2")
	
	if ( get_pcvar_num( cvar_check ) < 5 ) set_pcvar_num( cvar_check , 5 )
	if ( get_pcvar_num( cvar_tests ) < 3 ) set_pcvar_num( cvar_tests , 3 )

	register_clcmd("rate","block")
	register_clcmd("cl_rate","block")
	register_clcmd("cl_updaterate","block")
	register_clcmd("cl_cmdrate","block")
	register_clcmd("cl_lc","block")
	register_clcmd("cl_lw","block")
	register_clcmd("ex_interp","block")
}

public block(id)
{
	if(g_Reduce[id])
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	remove_task( id )
	
	g_Reduce[id] = false;
}

public client_putinserver(id) 
{
	
	g_Ping[id] = 0 
	g_Samples[id] = 0
	
	static name[32]
	get_user_name(id,name,31)
	  
	if ( !is_user_bot(id) && !(cvar_immunity && get_user_flags(id) & ADMIN_IMMUNITY)) 
	{
		new param[1]
		param[0] = id 
		set_task( 10.0 , "showWarn" , id , param , 1 )
	    
		if (get_pcvar_num(cvar_tests) != 0)
			set_task( float(get_pcvar_num(cvar_delay)), "taskSetting", id, param , 1)
		else 	    
			set_task( float(get_pcvar_num( cvar_tests )) , "checkPing" , id , param , 1 , "b")
	}
} 

public showWarn(param[])
	client_print( param[0] ,print_chat,"* Игроки с пингом више %d будут переведены на низкие рейты!", get_pcvar_num( cvar_ping ) )


public taskSetting(param[]) 
{
	new name[32]
	get_user_name(param[0],name,31)
	set_task( float(get_pcvar_num( cvar_tests )) , "checkPing" , param[0] , param , 1 , "b" )
}

ReducePing( id ) 
{ 
	new name[32],authid[32]
	get_user_authid(id,authid,31)
	get_user_name(id,name,31)

	// postavit nizkie reiti igroku
	client_print(0,print_chat,"** %s был переведён на низкие рейты игры из-за высого пинга",name)	
	client_cmd(id,"rate 4250.0;cl_rate 4250.0;cl_updaterate 10;cl_cmdrate 25;cl_lc 1;cl_lw 1;ex_interp 0")
	
	g_Reduce[id] = true
	
	
	/*
  	client_print(0,print_chat,"** %s был забанен из-за высого пинга",name)
	client_cmd(id,"echo ^"** Sorry but you have too high ping, try later...^"")
	server_cmd("addip 0 %s",ip)*/
	
	remove_task(id)
	log_amx("Highpingkick: ^"%s<%d><%s>^" was reduced due highping (Average Ping ^"%d^")", 
    name,get_user_userid(id),authid,(g_Ping[id] / g_Samples[id]))

}

public PunishPing(id)
{
	new punish = get_pcvar_num(cvar_punishtype)
	
	if(!punish)
	{
		ReducePing(id)
		return;
	}

	new ip[16],name[32],authid[32]
	get_user_authid(id,authid,31)
	get_user_name(id,name,31)
	get_user_ip(id,ip,15,1)
	
	client_print(0,print_chat,"** %s был забанен из-за высого пинга",name)
	client_cmd(id,"echo ^"** Sorry but you have too high ping, try later...^"")
	
	if(punish==2)
		server_cmd("addip %i %s",get_pcvar_num(cvar_bantime),ip)
	else if(punish==1)
		server_cmd("kick #%d ^"Sorry but your ping is too high, try again later...^"",get_user_userid(id))
	
	remove_task(id)
	log_amx("Highpingkick: ^"%s<%d><%s>^" punished due highping (Average Ping ^"%d^")", 
    name,get_user_userid(id),authid,(g_Ping[id] / g_Samples[id]))
}

public checkPing(param[]) 
{ 
	new id = param[ 0 ] 

	new p, l 

	get_user_ping( id , p , l ) 

	g_Ping[ id ] += p
	++g_Samples[ id ]
	
	if ( (g_Samples[ id ] > get_pcvar_num( cvar_tests )) && (g_Ping[id] / g_Samples[id] > get_pcvar_num( cvar_c_ping ))  )    
		PunishPing(id) 
	
	else if ( (g_Samples[ id ] > get_pcvar_num( cvar_tests )) && (g_Ping[id] / g_Samples[id] > get_pcvar_num( cvar_ping ))  )    
		ReducePing(id) 
}

public fw_UpdateClientData(player, sendweapons, handle)
{
	if(!g_Reduce[player])
		return;
		
#if CD_DONT_SEND_STEPSOUND
	set_cd(handle, CD_flTimeStepSound, 999 )
#endif
#if CD_DONT_SEND_PUNCHANGLE
	set_cd(handle, CD_PunchAngle, Float:{ 0.0, 0.0, 0.0 } )
#endif
#if CD_DONT_SEND_NEXTATTACK
	set_cd(handle, CD_flNextAttack, 0.0 )
#endif
#if CD_DONT_SEND_VELOCITY
	set_cd(handle, CD_Velocity, Float:{ 0.0, 0.0, 0.0 } )
#endif
}

public fw_AddToFullPack(handle, e, ent, host, hostflags, player, pset)
{
	if (!player || !g_Reduce[player]) return;
	
	if (host == ent)
	{
#if ES_DONT_SEND_ORIGIN_SELF
		set_es(handle, ES_Origin, Float:{ 0.0, 0.0, 0.0 })
#endif
#if ES_DONT_SEND_ANGLES_SELF
		set_es(handle, ES_Angles, Float:{ 0.0, 0.0, 0.0 })
#endif
#if ES_DONT_SEND_FRAME_SELF
		set_es(handle, ES_Frame, 1.0 )
#endif
#if ES_DONT_SEND_ANIMTIME_SELF
		set_es(handle, ES_AnimTime, 1.0 )
#endif
#if ES_DONT_SEND_BLENDING_SELF
		set_es(handle, ES_Blending, { 0, 0, 0, 0} )
#endif
	}
	else
	{
#if ES_DONT_SEND_ANGLES_OTHERS
		set_es(handle, ES_Angles, Float:{ 0.0, 0.0, 0.0 })
#endif
#if ES_DONT_SEND_FRAME_OTHERS
		set_es(handle, ES_Frame, 1.0 )
#endif
#if ES_DONT_SEND_ANIMTIME_OTHERS
		set_es(handle, ES_AnimTime, 1.0 )
#endif
#if ES_DONT_SEND_BLENDING_OTHERS
		set_es(handle, ES_Blending, { 0, 0, 0, 0} )
#endif
	}
}
