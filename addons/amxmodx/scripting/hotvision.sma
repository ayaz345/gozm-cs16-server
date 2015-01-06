#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME	"Nightvision"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Dimka"

#define m_fNvgState 129
#define NVG_ACTIVATED (1<<8) // 256
#define m_iFlashBattery 244

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

new g_iConnected;
new g_iAlive;
new g_iUpdateData;
new g_iInNvg;

new g_iMsgId_NVGToggle;
new g_iMsgId_Flashlight;

new g_iDefaultBrightness[32];

new g_iMaxPlayers;

new g_iFwdFM_AddToFullPack;
new g_iFwdFM_LightStyle;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Spawn, "player", "Ham_Spawn_player_Post", 1);
	RegisterHam(Ham_Killed, "player", "Ham_Killed_player_Post", 1);

	unregister_forward(FM_LightStyle, g_iFwdFM_LightStyle, 0);
	register_forward(FM_StartFrame, "FM_StartFrame_Pre", 0);

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");

	g_iMsgId_NVGToggle  = get_user_msgid("NVGToggle");
	g_iMsgId_Flashlight = get_user_msgid("Flashlight");
	
	register_message(g_iMsgId_NVGToggle, "Message_NVGToggle");

	if( !g_iDefaultBrightness[0] )
		g_iDefaultBrightness[0] = 'l';
	
	g_iMaxPlayers = clamp(get_maxplayers(), 1, 32);
}

public plugin_precache()
	g_iFwdFM_LightStyle = register_forward(FM_LightStyle, "FM_LightStyle_Pre", 0);

public plugin_cfg()
	Event_NewRound();

public Event_NewRound()
{
    if( !g_iFwdFM_AddToFullPack )
        g_iFwdFM_AddToFullPack = register_forward(FM_AddToFullPack, "FM_AddToFullPack_Post", 1);
}

public Message_NVGToggle(iMsgId, iMsgType, iPlrId)
{
	if( g_iFwdFM_AddToFullPack )
	{
        remove_task(iPlrId);

        set_pev(iPlrId, pev_effects, (pev(iPlrId, pev_effects) & ~EF_DIMLIGHT));

        message_begin(MSG_ONE_UNRELIABLE, g_iMsgId_Flashlight, _, iPlrId);
        write_byte(0);
        write_byte(get_pdata_int(iPlrId, m_iFlashBattery, 5));
        message_end();

        return PLUGIN_HANDLED;
	}
	else
		remove_task(iPlrId);
	
	return PLUGIN_CONTINUE;
}

public client_putinserver(iPlrId)
{
	SetPlayerBit(g_iConnected, iPlrId);
}

public client_disconnect(iPlrId)
{
	ClearPlayerBit(g_iConnected, iPlrId);
	ClearPlayerBit(g_iAlive, iPlrId);
	
	for( new iTaskId=iPlrId; iTaskId<=160; (iTaskId+=32) )
		remove_task(iTaskId);
}

public Ham_Spawn_player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) && CheckPlayerBit(g_iConnected, iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
}

public Ham_Killed_player_Post(iPlrId)
{
	if( !is_user_alive(iPlrId) )
		ClearPlayerBit(g_iAlive, iPlrId);
	
	for( new iTaskId=iPlrId; iTaskId<=160; (iTaskId+=32) )
		remove_task(iTaskId);
}

public FM_LightStyle_Pre(iStyle, iVal[])
{
	if( !iStyle )
		copy(g_iDefaultBrightness, 31, iVal);
}

public FM_StartFrame_Pre()
	g_iUpdateData = 4294967295; // 4294967296-1 == (((1<<31)*2)-1) == (1<<0)|(1<<1)|...|(1<<31) == (1<<32)-1

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet)
{
	if( 1<=iHost<=g_iMaxPlayers && get_orig_retval() )
		frame_nvg_update(iHost, iPlayer, iEsHandle, iEnt);
	
	return FMRES_IGNORED;
}

set_hotvision_plr(iEsHandle)
{
	set_es(iEsHandle, ES_Effects, (get_es(iEsHandle, ES_Effects)|EF_BRIGHTLIGHT));
}

bool:frame_nvg_update(iPlrId, iUpdatingPlayer, iEsHandle, iEnt)
{
	if( CheckPlayerBit(g_iConnected, iPlrId) )
	{
		static s_iSpectatedPerson[33];
		
		if( CheckPlayerBit(g_iUpdateData, iPlrId) )
		{
			static bool:s_bOldNvg;
			s_bOldNvg = (CheckPlayerBit(g_iInNvg, iPlrId) ? true : false);
			
			ClearPlayerBit(g_iUpdateData, iPlrId);
			
			if( CheckPlayerBit(g_iAlive, iPlrId) )
			{
				s_iSpectatedPerson[iPlrId] = iPlrId;
				if( get_pdata_int(iPlrId, m_fNvgState, 5) & NVG_ACTIVATED )
					SetPlayerBit(g_iInNvg, iPlrId);
				else
					ClearPlayerBit(g_iInNvg, iPlrId);
			}
			else if( pev(iPlrId, pev_iuser1)==4 )
			{
				s_iSpectatedPerson[iPlrId] = pev(iPlrId, pev_iuser2);
				if( s_iSpectatedPerson[iPlrId]>g_iMaxPlayers || s_iSpectatedPerson[iPlrId]<=0 )
					ClearPlayerBit(g_iInNvg, iPlrId);
				else if( CheckPlayerBit(g_iAlive, s_iSpectatedPerson[iPlrId]) )
				{
					if( get_pdata_int(s_iSpectatedPerson[iPlrId], m_fNvgState, 5) & NVG_ACTIVATED )
						SetPlayerBit(g_iInNvg, iPlrId);
					else
						ClearPlayerBit(g_iInNvg, iPlrId);
				}
				else
					ClearPlayerBit(g_iInNvg, iPlrId);
			}
			else
			{
				s_iSpectatedPerson[iPlrId] = 0;
				ClearPlayerBit(g_iInNvg, iPlrId);
			}
			
			if( s_bOldNvg )
			{
				if( !CheckPlayerBit(g_iInNvg, iPlrId) )
				{
					message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, _, iPlrId);
					write_byte(0);
					write_string(g_iDefaultBrightness);
					message_end();
				}
			}
		}
		
		if( CheckPlayerBit(g_iInNvg, iPlrId) )
		{
			if( iUpdatingPlayer )
			{
				if( iPlrId==s_iSpectatedPerson[iPlrId] || iPlrId!=iEnt )
					set_hotvision_plr(iEsHandle);
			}
			
			return true;
		}
	}
	return false;
}
