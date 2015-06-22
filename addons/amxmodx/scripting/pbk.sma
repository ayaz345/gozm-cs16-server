#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <colored_print>
#include <gozm>

#define CHECK_FREQ		5

#define TEAM_T 		    1
#define TEAM_CT 		2

#define EVENT_JOIN 		1
#define EVENT_SPEC 		2
#define EVENT_AFK  		4

new g_playerJoined[MAX_PLAYERS], g_playerSpawned[MAX_PLAYERS]
new g_timeJoin[MAX_PLAYERS], g_timeSpec[MAX_PLAYERS],
    g_timeAFK[MAX_PLAYERS], g_timeSpecQuery[MAX_PLAYERS]
new g_joinImmunity[32], g_specImmunity[32], g_afkImmunity[32]

new bool:g_roundInProgress = false

new g_cvar_joinMinPlayers, g_cvar_joinTime, g_cvar_joinImmunity
new g_cvar_specMinPlayers, g_cvar_specTime, g_cvar_specImmunity, g_cvar_specQuery
new g_cvar_afkMinPlayers, g_cvar_afkTime, g_cvar_afkImmunity
new g_cvar_kick2ip, g_cvar_kick2port

public plugin_init()
{
    register_plugin("Play or Be Kicked", "1.1", "GoZm")

    register_event("ResetHUD", "event_resethud", "be")

    register_forward(FM_PlayerPostThink, "fm_playerPostThink")

    register_logevent("event_round_start", 2, "0=World triggered", "1=Round_Start")
    register_logevent("event_round_end", 2, "0=World triggered", "1=Round_End")

    g_cvar_joinMinPlayers	= register_cvar("pbk_join_min_players", "4")
    g_cvar_joinTime			= register_cvar("pbk_join_time", "120")
    g_cvar_joinImmunity		= register_cvar("pbk_join_immunity_flags", "")

    g_cvar_specMinPlayers	= register_cvar("pbk_spec_min_players", "4")
    g_cvar_specTime			= register_cvar("pbk_spec_time", "120")
    g_cvar_specImmunity		= register_cvar("pbk_spec_immunity_flags", "")
    g_cvar_specQuery		= register_cvar("pbk_spec_query", "0")

    g_cvar_afkMinPlayers	= register_cvar("pbk_afk_min_players", "4")
    g_cvar_afkTime			= register_cvar("pbk_afk_time", "90")
    g_cvar_afkImmunity		= register_cvar("pbk_afk_immunity_flags", "")

    g_cvar_kick2ip			= register_cvar("pbk_kick2_ip", "")
    g_cvar_kick2port		= register_cvar("pbk_kick2_port", "27015")
}

public plugin_cfg()
{
    new configDir[255]
    formatex(configDir[get_configsdir(configDir, charsmax(configDir))], charsmax(configDir), "/")
    server_cmd("exec %spbk.cfg", configDir)
    server_exec()

    get_pcvar_string(g_cvar_joinImmunity, g_joinImmunity, charsmax(g_joinImmunity))
    get_pcvar_string(g_cvar_specImmunity, g_specImmunity, charsmax(g_specImmunity))
    get_pcvar_string(g_cvar_afkImmunity, g_afkImmunity, charsmax(g_afkImmunity))

    set_task(float(CHECK_FREQ), "check_players", _, _, _, "b")
}

public fm_playerPostThink(id)
{
    if (!g_playerJoined[id])
    {
        new team[2]
        new teamID = get_user_team(id, team, 1)
        if (teamID == TEAM_T || teamID == TEAM_CT || team[0] == 'S')
            g_playerJoined[id] = true
    }
    return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
    g_playerJoined[id] = false
    g_playerSpawned[id] = false

    g_timeJoin[id] = 0
    g_timeSpec[id] = 0
    g_timeAFK[id] = 0
}

public event_resethud(id)
{
    if (!g_playerSpawned[id])
    {
        g_playerSpawned[id] = true
        cs_set_user_lastactivity(id, get_gametime())
    }
}

public event_round_end()
{
    g_roundInProgress = false
}

public event_round_start()
{
    g_roundInProgress = true
}

public check_players()
{
    new playerCnt = get_playersnum()
    new team[2], eventType

    new bool:checkJoinStatus =
        (get_pcvar_num(g_cvar_joinTime) && playerCnt >= get_pcvar_num(g_cvar_joinMinPlayers))
    new bool:checkSpecStatus =
        (get_pcvar_num(g_cvar_specTime) && playerCnt >= get_pcvar_num(g_cvar_specMinPlayers))
    new bool:checkAFKStatus  =
        (get_pcvar_num(g_cvar_afkTime)  && playerCnt >= get_pcvar_num(g_cvar_afkMinPlayers) && g_roundInProgress)

    new players[32], id
    get_players(players, playerCnt)

    for (new playerIdx = 0; playerIdx < playerCnt; playerIdx++)
    {
        id = players[playerIdx]

        if (g_playerJoined[id])
        {
            get_user_team(id, team, 1)
            eventType = (team[0] == 'S') ? EVENT_SPEC : EVENT_AFK

            if (eventType == EVENT_AFK && checkAFKStatus && g_playerSpawned[id] && is_user_alive(id))
            {
                g_timeAFK[id] = floatround(get_gametime() - cs_get_user_lastactivity(id))
            }
            else if (eventType == EVENT_SPEC && checkSpecStatus)
            {
                g_timeSpec[id] += determine_spec_time_elapsed(id)
            }
            else
                continue
        }
        else
        {
            eventType = EVENT_JOIN
            if (checkJoinStatus)
                g_timeJoin[id] += CHECK_FREQ
            else
                continue
        }

        handle_time_elapsed(id, eventType)
    }
}

determine_spec_time_elapsed(id)
{
    new timeElapsed = 0

    if (get_pcvar_num(g_cvar_specQuery))
    {
        g_timeSpecQuery[id] += CHECK_FREQ

        if (g_timeSpecQuery[id] >= 55)
        {
            timeElapsed = g_timeSpecQuery[id] - CHECK_FREQ
            g_timeSpecQuery[id] = CHECK_FREQ
        }
    }
    else
    {
        timeElapsed = CHECK_FREQ
    }

    return timeElapsed
}

handle_time_elapsed(id, eventType)
{
    new maxSeconds, elapsedSeconds, eventImmunity
    if (eventType == EVENT_JOIN)
    {
        maxSeconds = get_pcvar_num(g_cvar_joinTime)
        elapsedSeconds = g_timeJoin[id]
        eventImmunity = has_flag(id, g_joinImmunity)
    }
    else if (eventType == EVENT_SPEC)
    {
        maxSeconds = get_pcvar_num(g_cvar_specTime)
        elapsedSeconds = g_timeSpec[id]
        eventImmunity = has_flag(id, g_specImmunity) || has_rcon(id)
    }
    else if (eventType == EVENT_AFK)
    {
        maxSeconds = get_pcvar_num(g_cvar_afkTime)
        elapsedSeconds = g_timeAFK[id]
        eventImmunity = has_flag(id, g_afkImmunity)
    }
    else
        return

    if (elapsedSeconds >= maxSeconds)
    {
        // if players have immunity for this event abort
        if (eventImmunity)
            return;

        // get the correct message formats for this event type
        new msgReason[64], msgAnnounce[64]
        switch (eventType)
        {
            case EVENT_JOIN:
            {
                formatex(msgReason, charsmax(msgReason), " Не выбрал команду за %d секунд", maxSeconds)
                formatex(msgAnnounce, charsmax(msgAnnounce), "was kicked for failing to choose a team within %ds", maxSeconds)
            }
            case EVENT_SPEC:
            {
                formatex(msgReason, charsmax(msgReason), " Был в спектрах более %d секунд", maxSeconds)
                formatex(msgAnnounce, charsmax(msgAnnounce), "was kicked for spectating longer than %ds", maxSeconds)
            }
            case EVENT_AFK:
            {
                formatex(msgReason, charsmax(msgReason), " Был AFK более %d секунд", maxSeconds)
                formatex(msgAnnounce, charsmax(msgAnnounce), "was kicked for being AFK longer than %ds", maxSeconds)
            }
        }

        new kick2ip[32];
        get_pcvar_string(g_cvar_kick2ip, kick2ip, charsmax(kick2ip))

        if (kick2ip[0] == 0)
        {
            // kick the player into the nether
            server_cmd("kick #%d %s", get_user_userid(id), msgReason)
        }
        else
        {
            // kick the player into another server
            new kick2port[16]
            get_pcvar_string(g_cvar_kick2port, kick2port, charsmax(kick2port))

            client_cmd(id, "Connect %s:%s", kick2ip, kick2port)
        }

        // log the kick
        new logText[128]
        format(logText, charsmax(logText), "%s", msgAnnounce)
        trim(logText)
        new name[32]
        get_user_name(id, name, charsmax(name))
        log_amx("[PBK]: ^"%s^" %s", name, logText)
    }
    else if (0 < elapsedSeconds > maxSeconds - 3*CHECK_FREQ)
    {
        new time_left = elapsedSeconds > maxSeconds - 2*CHECK_FREQ ? CHECK_FREQ : 2*CHECK_FREQ
        switch (eventType)
        {
            case EVENT_JOIN:
                colored_print(id, "^x04***^x01 У вас есть^x04 %d^x01 секунд, чтобы выбрать сторону", time_left)
            case EVENT_SPEC:
                colored_print(id, "^x04***^x01 У вас есть^x04 %d^x01 секунд, чтобы выбрать команду", time_left)
            case EVENT_AFK:
                colored_print(id, "^x04***^x01 У вас есть^x04 %d^x01 секунд, чтобы начать играть", time_left)
        }
    }
}
