#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

new P_Cvars[31],Max_Players,Float:DmgValue
public plugin_init()
{
	register_plugin("Damage Control", "1.22", "Fxfighter")
	
	RegisterHam(Ham_TakeDamage, "player", "hook_TakeDamage")
	
	P_Cvars[0] = register_cvar("amx_dmg_mode","1")
	P_Cvars[1] = register_cvar("amx_dmg_p228","#")
	P_Cvars[2] = register_cvar("amx_dmg_fall","#")
	P_Cvars[3] = register_cvar("amx_dmg_scout","#")
	P_Cvars[4] = register_cvar("amx_dmg_grenade","0*")
	P_Cvars[5] = register_cvar("amx_dmg_xm1014","#")
	P_Cvars[7] = register_cvar("amx_dmg_mac10","#")
	P_Cvars[8] = register_cvar("amx_dmg_aug","#")
	P_Cvars[9] = register_cvar("amx_dmg_all","1.0*")
	P_Cvars[10] = register_cvar("amx_dmg_elite","#")
	P_Cvars[11] = register_cvar("amx_dmg_fiveseven","#")
	P_Cvars[12] = register_cvar("amx_dmg_ump45","#")
	P_Cvars[13] = register_cvar("amx_dmg_sg550","#")
	P_Cvars[14] = register_cvar("amx_dmg_galil","#")
	P_Cvars[15] = register_cvar("amx_dmg_famas","#")
	P_Cvars[16] = register_cvar("amx_dmg_usp","#")
	P_Cvars[17] = register_cvar("amx_dmg_glock18","#")
	P_Cvars[18] = register_cvar("amx_dmg_awp","#")
	P_Cvars[19] = register_cvar("amx_dmg_mp5navy","#")
	P_Cvars[20] = register_cvar("amx_dmg_m249","#")
	P_Cvars[21] = register_cvar("amx_dmg_m3","#")
	P_Cvars[22] = register_cvar("amx_dmg_m4a1","#")
	P_Cvars[23] = register_cvar("amx_dmg_tmp","#")
	P_Cvars[24] = register_cvar("amx_dmg_g3sg1","#")
	P_Cvars[26] = register_cvar("amx_dmg_deagle","#")
	P_Cvars[27] = register_cvar("amx_dmg_sg552","#")
	P_Cvars[28] = register_cvar("amx_dmg_ak47","#")
	P_Cvars[29] = register_cvar("amx_dmg_knife","#")
	P_Cvars[30] = register_cvar("amx_dmg_p90","#")
	
	Max_Players = get_maxplayers()
	
}
public hook_TakeDamage(Victim, Useless, Attacker, Float:damage, damagebits)
{
	static cvar
	cvar = get_pcvar_num(P_Cvars[0])
	
	if(!cvar)return HAM_IGNORED
	
	static Gun
	if(Useless <= Max_Players && Useless != 0)Gun = get_user_weapon(Attacker)
	else
	{
		static classname[32]
		pev(Useless,pev_classname,classname,31)
		if(equal(classname,"grenade"))Gun = 4
		else if(!Useless)Gun = 2
	}
	if(!Gun)return HAM_IGNORED
	
	static Dmg[5]
	Useless = 0
	get_pcvar_string(P_Cvars[Gun],Dmg,4)
	
	if(Dmg[0] == '#')
	{
		get_pcvar_string(P_Cvars[9],Dmg,4)
		if(Dmg[0] == '#')return HAM_IGNORED
		Useless = 1
	}
	if(contain(Dmg,"*") != -1)
	{
		replace(Dmg,4,"*","")
		DmgValue = str_to_float(Dmg)
		if(DmgValue == 1.0)return HAM_IGNORED
		damage*=DmgValue
	}
	else if(contain(Dmg,"-") != -1)
	{
		replace(Dmg,4,"-","")
		DmgValue = str_to_float(Dmg)
		if(!DmgValue)return HAM_IGNORED
		damage-=DmgValue
		if(damage < 0.0)damage = 0.0
	}
	else if(contain(Dmg,"+") != -1)
	{
		replace(Dmg,4,"+","")
		DmgValue = str_to_float(Dmg)
		if(!DmgValue)return HAM_IGNORED
		damage+=str_to_float(Dmg)
	}
	else damage=str_to_float(Dmg)
	
	if(cvar == 2 && !Useless)
	{
		get_pcvar_string(P_Cvars[9],Dmg,4)
		if(Dmg[0] == '#')
		{
			SetHamParamFloat(4, damage)
			return HAM_IGNORED
		}
		if(contain(Dmg,"*") != -1)
		{
			replace(Dmg,4,"*","")
			DmgValue = str_to_float(Dmg)
			if(DmgValue == 1.0)return HAM_IGNORED
			damage*=DmgValue
		}
		else if(contain(Dmg,"-") != -1)
		{
			replace(Dmg,4,"-","")
			DmgValue = str_to_float(Dmg)
			if(!DmgValue)return HAM_IGNORED
			damage-=DmgValue
			if(damage < 0.0)damage = 0.0
		}
		else if(contain(Dmg,"+") != -1)
		{
			replace(Dmg,4,"+","")
			DmgValue = str_to_float(Dmg)
			if(!DmgValue)return HAM_IGNORED
			damage+=str_to_float(Dmg)
		}
		else damage=str_to_float(Dmg)
	}
	SetHamParamFloat(4, damage)
	return HAM_HANDLED
}

new Debug
public client_putinserver(id)
{	
	if(Debug == 1)return	
	new classname[32]
	pev(id,pev_classname,classname,31)
		
	if(!equal(classname,"player"))
	{
		Debug=1
		set_task(10.0,"_Debug",id)	
	}
}
public _Debug(id)
{
	RegisterHamFromEntity(Ham_TakeDamage,id,"hook_TakeDamage")
	client_print(0,print_console,"[Damage Control]bots debuged")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
