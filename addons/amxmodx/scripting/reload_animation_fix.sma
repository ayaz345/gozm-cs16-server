/**
 *
 * Reload Animation Fix
 *  by Numb
 *
 *
 * Description:
 *  This plugin fixes a glitch when your weapon reload animation isn't shown, even though
 *  you are currently reloading your weapon. Also this plugin fixes shotgun reload resume
 *  glitch, when you are deploying m3 or xm1014. And when shotgun is deployed while having
 *  0 bullets, reload animation is always accurate. Last, but not least, when spectating a
 *  person who has deagle, you don't get deploy or reload animation when you shouldn't.
 *
 *
 * Requires:
 *  FakeMeta
 *  HamSandWich
 *
 *
 * Additional Info:
 *  Tested in Counter-Strike 1.6 with amxmodx 1.8.2 (dev build hg21). If you want to execute
 *  and test this bug, buy an automatic weapon (mp5, ak47, m4a1..), with 2 backup clips,
 *  fire one clip until you hit reload, then once reload is done, start firing second clip,
 *  until you reach 0 ammunition and start reload again - that's when animation glitch
 *  happens. There are more scenarios when this bug happens, however this plugin should fix
 *  all of them.
 *
 *
 * Warnings:
 *  Animations are client-side, therefor there may be firing animation issue just when
 *  reload ended for people who are playing with high ping and are holding attack button at
 *  that moment.
 *
 *
 * Credits:
 *  Thanks to FOUTA ( http://forums.alliedmods.net/member.php?u=96050 ) for requesting this
 *  bug-fix.
 *
 *
 * ChangeLog:
 *
 *  + 1.1
 *  - Fixed: When deploying shotguns they don't resume previous reload.
 *  - Fixed: When switching to shotgun with 0 bullets, reload animation is always accurate.
 *  - Fixed: Shotguns lost their reload-stop animations.
 *  - Removed: No need to fix main glitch for shotguns - they don't have this bug anyway.
 *
 *  + 1.0
 *  - First release.
 *
 *
 * Downloads:
 *  Amx Mod X forums: http://forums.alliedmods.net/showthread.php?p=1620401#post1620401
 *
**/


#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME	"Reload Animation Fix"
#define PLUGIN_VERSION	"1.1"
#define PLUGIN_AUTHOR	"Numb"

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

#define m_pPlayer 41
#define m_iId 43
#define m_flTimeWeaponIdle 48
#define m_fInReload 54
#define m_fInSpecialReload 55
#define m_fWeaponState 74
#define WEAPONSTATE_USP_SILENCED (1<<0)
#define WEAPONSTATE_M4A1_SILENCED (1<<2)

#define m_pActiveItem 373
#define m_iUserPrefs 510
#define USERPREFS_HAS_SHIELD (1<<24)


new g_iMaxPlayers;
new g_iAlive;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Spawn,  "player", "Ham_Spawn_player_Post",  1);
	RegisterHam(Ham_Killed, "player", "Ham_Killed_player_Post", 1);
	
	RegisterHam(Ham_Item_PostFrame, "weapon_glock18",      "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_usp",          "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_deagle",       "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_p228",         "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_elite",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_fiveseven",    "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_mp5navy",      "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_mac10",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_tmp",          "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_p90",          "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_ump45",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_galil",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_famas",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_ak47",         "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_m4a1",         "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_sg552",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_aug",          "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_g3sg1",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_sg550",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_scout",        "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_awp",          "Ham_Item_PostFrame_Pre", 0);
	RegisterHam(Ham_Item_PostFrame, "weapon_m249",         "Ham_Item_PostFrame_Pre", 0);
	
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_deagle", "Ham_WeaponIdle_deagle_Pre", 0);
	
	RegisterHam(Ham_Item_Deploy, "weapon_m3",     "Ham_Item_Deploy_Pre", 0);
	RegisterHam(Ham_Item_Deploy, "weapon_xm1014", "Ham_Item_Deploy_Pre", 0);
	
	g_iMaxPlayers = clamp(get_maxplayers(), 1, 32);
}

public plugin_unpause()
{
	g_iAlive = 0;
	
	new iPlayers[32], iPlayerNum;
	get_players(iPlayers, iPlayerNum, "a");
	
	for( new iPlayer; iPlayer<iPlayerNum; iPlayer++ )
		SetPlayerBit(g_iAlive, iPlayers[iPlayer]);
}

public client_disconnect(iPlrId)
	ClearPlayerBit(g_iAlive, iPlrId);

public Ham_Spawn_player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}

public Ham_Killed_player_Post(iPlrId, iAttackerId, iShouldGib)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}

public Ham_Item_PostFrame_Pre(iEnt)
{
	if( !get_pdata_int(iEnt, m_fInReload, 4) )
	{
		static s_iOwner;
		s_iOwner = get_pdata_cbase(iEnt, m_pPlayer, 4);
		
		if( 0<s_iOwner<=g_iMaxPlayers )
		{
			if( CheckPlayerBit(g_iAlive, s_iOwner) )
			{
				if( iEnt==get_pdata_cbase(s_iOwner, m_pActiveItem, 5) )
				{
					switch( get_pdata_int(iEnt, m_iId, 4) )
					{
						case CSW_GLOCK18:
						{
							if( pev(s_iOwner, pev_weaponanim)==((get_pdata_int(s_iOwner, m_iUserPrefs, 5)&USERPREFS_HAS_SHIELD)?4:7) )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
						case CSW_USP:
						{
							if( get_pdata_int(s_iOwner, m_iUserPrefs, 5)&USERPREFS_HAS_SHIELD )
							{
								if( pev(s_iOwner, pev_weaponanim)==4 )
									set_pev(s_iOwner, pev_weaponanim, 0);
							}
							else if( get_pdata_int(iEnt, m_fWeaponState, 4)&WEAPONSTATE_USP_SILENCED )
							{
								if( pev(s_iOwner, pev_weaponanim)==5 )
									set_pev(s_iOwner, pev_weaponanim, 0);
							}
							else
							{
								if( pev(s_iOwner, pev_weaponanim)==13 )
									set_pev(s_iOwner, pev_weaponanim, 8);
							}
						}
						case CSW_DEAGLE, CSW_FIVESEVEN, CSW_AWP:
						{
							if( pev(s_iOwner, pev_weaponanim)==4 ) //((get_pdata_int(s_iOwner, m_iUserPrefs, 5)&USERPREFS_HAS_SHIELD)?4:4) )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
						case CSW_P228:
						{
							if( pev(s_iOwner, pev_weaponanim)==((get_pdata_int(s_iOwner, m_iUserPrefs, 5)&USERPREFS_HAS_SHIELD)?4:5) )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
						case CSW_ELITE:
						{
							if( pev(s_iOwner, pev_weaponanim)==14 )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
						//case CSW_M3, CSW_XM1014: // there's no need to fix reload issue for this 2 weapons, cause animation #3 is impossible
						//{			   // before start of the reload.
						//	if( 3<=pev(s_iOwner, pev_weaponanim)<=5 ) // 3 for insert, 4 for stop, 5 for start
						//		set_pev(s_iOwner, pev_weaponanim, 0);
						//}
						case CSW_MP5NAVY, CSW_MAC10, CSW_TMP, CSW_P90, CSW_UMP45, CSW_GALIL, CSW_FAMAS, CSW_AK47, CSW_SG552, CSW_AUG:
						{
							if( pev(s_iOwner, pev_weaponanim)==1 )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
						case CSW_M4A1:
						{
							if( get_pdata_int(iEnt, m_fWeaponState, 4)&WEAPONSTATE_M4A1_SILENCED )
							{
								if( pev(s_iOwner, pev_weaponanim)==4 )
									set_pev(s_iOwner, pev_weaponanim, 0);
							}
							else
							{
								if( pev(s_iOwner, pev_weaponanim)==11 )
									set_pev(s_iOwner, pev_weaponanim, 7);
							}
						}
						case CSW_G3SG1, CSW_SG550, CSW_SCOUT, CSW_M249:
						{
							if( pev(s_iOwner, pev_weaponanim)==3 )
								set_pev(s_iOwner, pev_weaponanim, 0);
						}
					}
				}
			}
		}
	}
}

public Ham_WeaponIdle_deagle_Pre(iEnt)
{
	if( get_pdata_float(iEnt, m_flTimeWeaponIdle, 4)<=0.0 )
	{
		static s_iOwner;
		s_iOwner = get_pdata_cbase(iEnt, m_pPlayer, 4);
		
		if( 0<s_iOwner<=g_iMaxPlayers )
		{
			if( CheckPlayerBit(g_iAlive, s_iOwner) )
			{
				//if( pev(s_iOwner, pev_weaponanim)==5 ) // fix deploy animation glitch for deagle when spectating
				set_pev(s_iOwner, pev_weaponanim, 0);
			}
		}
	}
}

public Ham_Item_Deploy_Pre(iEnt)
	set_pdata_int(iEnt, m_fInSpecialReload, 0, 4);
