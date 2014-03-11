#include <amxmodx>
#include <hamsandwich>
#include <biohazard>

new g_iMaxPlayers  

new bool:g_bIsConnected[25]

new g_MsgSync
new g_MsgSync2

#define IsConnected(%1) (1 <= %1 <= g_iMaxPlayers && g_bIsConnected[%1])

#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "meTaLiCroSS"

public plugin_init() 
{
	register_plugin("HP Displayer", PLUGIN_VERSION, PLUGIN_AUTHOR)
	RegisterHam(Ham_TakeDamage, "player", "fw_Player_TakeDamage_Post", 1)
	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(iId) g_bIsConnected[iId] = true
public client_disconnect(iId) g_bIsConnected[iId] = false

public fw_Player_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, iDamageType)
{
	if(!IsConnected(iAttacker) || iVictim == iAttacker)
        return HAM_IGNORED
    
	if(is_user_zombie(iVictim) && !(is_user_zombie(iAttacker)))
	{
        static iVictimHealth
        iVictimHealth = get_user_health(iVictim)
        if(iVictimHealth < 0)
            iVictimHealth = 0
            
        static iDamage 
        iDamage = floatround(flDamage)
        
        if (iDamage > 0)
        {
            set_hudmessage(0, 100, 200, 0.55, 0.49, 0, 0.1, 2.0, 0.1, 0.1, -1)
            ShowSyncHudMsg(iAttacker, g_MsgSync, "%d", iDamage)

            set_hudmessage(0, 150, 20, 0.49, 0.55, 0, 0.1, 2.0, 0.1, 0.1, -1)
            ShowSyncHudMsg(iAttacker, g_MsgSync2, "%d", iVictimHealth)

            set_hudmessage(200, 0, 0, 0.40, 0.49, 0, 0.1, 2.0, 0.1, 0.1, -1)
            ShowSyncHudMsg(iVictim, g_MsgSync, "%d", iDamage)
        }
	}
    
	return HAM_IGNORED
}