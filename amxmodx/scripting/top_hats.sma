/* 
Суть плагина
Плагин надевает шапочку на человека чей ранг от 4 до 15
А чей от 1 до 3 - плащ супермена

Версия 0.1
Автор - Я
Модули
<amxmodx> 
<fakemeta> 
<hamsandwich> 
<csstats>

В исходнике 13 и 14 строчки
new MODEL_TOP15[] = "models/pp_top15.mdl"
new MODEL_TOP3[] = "models/pp_top3.mdl"

Тут вы можете поставить свою модель если вам не нравится то,что выбрал я.

Кредиты: xPaw за его плагин SantaHats & sgtbane за модельки шапок
*/

#include <amxmodx> 
#include <fakemeta> 
#include <hamsandwich> 
#include <csstats>

#define PLUGIN "TOP Hats"
#define VERSION "0.1"
#define AUTHOR "TTuCTOH"

new g_topEnt[33]
new MODEL_TOP15[] = "models/jamacahat2.mdl"
new MODEL_TOP3[] = "models/pp_top3.mdl"
new g_CachedStringInfoTarget

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	g_CachedStringInfoTarget = engfunc( EngFunc_AllocString, "info_target" );
}

public plugin_precache()
{
	precache_model(MODEL_TOP15)
	precache_model(MODEL_TOP3)
}

public fwHamPlayerSpawnPost(id) 
{
	new stats[8], bodyhits[8]
	new iRank;
 	iRank = get_user_stats(id, stats, bodyhits)
	
	if(1 <= iRank <= 3)
	{
		if(is_user_alive(id))
		{
			new iEnt = g_topEnt[id]
			if( !pev_valid(iEnt))
			{
				g_topEnt[id] = iEnt = engfunc(EngFunc_CreateNamedEntity, g_CachedStringInfoTarget)
				set_pev(iEnt, pev_movetype, MOVETYPE_FOLLOW)
				set_pev(iEnt, pev_aiment, id)
				engfunc(EngFunc_SetModel, iEnt, MODEL_TOP3)
			}
		}
	}
	if(4 <= iRank <= 15)
	{
		if(is_user_alive(id))
		{
			new iEnt = g_topEnt[id]
			if( !pev_valid(iEnt))
			{
				g_topEnt[id] = iEnt = engfunc(EngFunc_CreateNamedEntity, g_CachedStringInfoTarget)
				set_pev(iEnt, pev_movetype, MOVETYPE_FOLLOW)
				set_pev(iEnt, pev_aiment, id)
				engfunc(EngFunc_SetModel, iEnt, MODEL_TOP15)
			}
		}
	}
	else
	{
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}