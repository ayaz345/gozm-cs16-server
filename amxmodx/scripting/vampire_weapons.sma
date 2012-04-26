#include <amxmodx>
#include <fun>

#define PLUGIN_NAME "Vampire Weapons"
#define PLUGIN_AUTHOR "Hafner"
#define PLUGIN_VERSION "1.0"

new cvar_maxHP, cvar_bonusHS, cvar_vampire_weapons

new const weapon_names[][10] = {
	"", "p228", "", "scout", "grenade", "xm1014", "", "mac10",
	"aug", "", "elite", "fiveseven", "ump45", "sg550",
	"galil", "famas", "usp", "glock18", "awp", "mp5navy",
	"m249",	"m3", "m4a1", "tmp", "g3sg1", "", "deagle",
	"sg552", "ak47", "knife", "p90"
}

new const weapon_hp[] = 
{
	0,	// ---
	30,	// P228
	0,	// ---
	55,	// SCOUT
	55,	// GRENADE
	30,	// XM1014
	0,	// ---
	30,	// MAC10
	30,	// AUG
	0,	// ---
	25,	// ELITE
	25,	// FIVESEVEN
	35,	// UMP45
	15,	// SG550
	25,	// GALIL
	25,	// FAMAS
	30,	// USP
	30,	// GLOCK18
	90,	// AWP
	30,	// MP5NAVY
	15,	// M249
	40,	// M3
	30,	// M4A1
	20,	// TMP
	15,	// G3SG1
	0,	// ---
	50,	// DEAGLE
	30,	// SG552
	30,	// AK47
	0,	// KNIFE
	25	// P90
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	cvar_vampire_weapons = register_cvar("vw_on", "1")
	cvar_maxHP = register_cvar("vw_max_hp", "100")
	cvar_bonusHS = register_cvar("vw_bonus_hs", "2.0")

	register_event("DeathMsg", "hook_death", "a", "1>0") 	
}

public hook_death()
{
	new Killer = read_data( 1 );
	new Victim = read_data( 2 );
	new szWeapon[20], vampireHP;
	read_data(4, szWeapon, 19);
       	new Health = get_user_health(Killer);

	if( (Killer != Victim) && get_pcvar_num(cvar_vampire_weapons) )
    	{
		for( new i = 0; i < sizeof( weapon_names ); i++ ) 
		{   
			if ( equali(szWeapon, weapon_names[i]) ) 
			{
				if( 1 <= Health < get_pcvar_num(cvar_maxHP) )
				{
					if( (read_data(3) == 1) && (i != 4) )
					{
						vampireHP = floatround(weapon_hp[i]*get_pcvar_float(cvar_bonusHS));
			            		set_user_health( Killer, min( Health + vampireHP, get_pcvar_num(cvar_maxHP) ) ); 
					}
					else
					{
						vampireHP = weapon_hp[i];
			            		set_user_health( Killer, min( Health + vampireHP, get_pcvar_num(cvar_maxHP) ) );
					}
					set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1)
					show_hudmessage(Killer, "Вылечил +%dхп", vampireHP)
					}
				break;	
			}	
		}
    	}
}