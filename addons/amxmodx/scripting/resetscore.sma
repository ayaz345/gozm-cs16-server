#include <amxmodx>
#include <cstrike>
#include <fun>
#include <colored_print>

public plugin_init()
{
    register_plugin("Reset Score", "1.0", "Silenttt")

    register_clcmd("say /rs", "reset_score")
    register_clcmd("say_team /rs", "reset_score")	
}

public reset_score(id)
{
    //These both NEED to be done twice, otherwise your frags wont
    //until the next round
    cs_set_user_deaths(id, 0)
    set_user_frags(id, 0)
    cs_set_user_deaths(id, 0)
    set_user_frags(id, 0)

    colored_print(id, "^x04***^x01 Ты успешно сбросил свой счет")
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10250\\ f0\\ fs16 \n\\ par }
*/
