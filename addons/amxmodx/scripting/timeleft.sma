#include <amxmodx>
#include <colored_print>

new g_TimeSet[32][2]
new g_LastTime
new g_CountDown
new g_Switch

public plugin_init()
{
    register_plugin("Time Left", "1.1", "GoZm")

    register_dictionary("timeleft.txt")

    register_srvcmd("amx_time_display", "setDisplaying")

    register_cvar("amx_timeleft", "00:00", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

    register_clcmd("say timeleft", "sayTimeLeft", 0, "- displays timeleft")
    register_clcmd("say_team timeleft", "sayTimeLeft", 0, "- displays timeleft")
    register_clcmd("say thetime", "sayTheTime", 0, "- displays current time")
    register_clcmd("say_team thetime", "sayTheTime", 0, "- displays current time")
    register_clcmd("say time", "sayTime", 0, "- displays current time")
    register_clcmd("say_team time", "sayTime", 0, "- displays current time and timeleft")
    register_clcmd("say /timeleft", "sayTimeLeft", 0, "- displays current time")
    register_clcmd("say_team /timeleft", "sayTimeLeft", 0, "- displays current time and timeleft")
    register_clcmd("say /time", "sayTime", 0, "- displays current time")
    register_clcmd("say_team /time", "sayTime", 0, "- displays current time and timeleft")

    register_srvcmd("timeleft", "srvTimeLeft", 0, "- displays timeleft for server console")

    set_task(0.8, "timeRemain", 8648458, "", 0, "b")
}

public sayTheTime(id)
{
    static ctime[64]
    get_time("%m/%d/%Y - %H:%M:%S", ctime, charsmax(ctime))
    colored_print(id, "^x01Сейчас:^x04 %s", ctime)

    return PLUGIN_HANDLED
}

public sayTimeLeft(id)
{
    if (get_cvar_float("mp_timelimit"))
    {
        static left
        left = get_timeleft()
        colored_print(id, "^x01Осталось:^x04 %d:%02d", (left / 60), (left % 60))
    }
    else
        colored_print(id, "^x01Это^x04 последний^x01 раунд.")

    return PLUGIN_HANDLED
}

public srvTimeLeft(id)
{
    if (get_cvar_float("mp_timelimit"))
    {
        static left
        left = get_timeleft()
        server_print("Осталось: %d:%02d", (left / 60), (left % 60))
    }
    else
        server_print("Это последний раунд.")

    return PLUGIN_CONTINUE
}

public sayTime(id)
{
    sayTheTime(id)
    sayTimeLeft(id)

    return PLUGIN_HANDLED
}

setTimeText(text[], len, tmlf, id)
{
    static mins, secs
    secs = tmlf % 60
    mins = tmlf / 60

    if (secs == 0)
        formatex(text, len, "%d %L", mins, id, (mins > 1) ? "MINUTES" : "MINUTE")
    else if (mins == 0)
        formatex(text, len, "%d %L", secs, id, (secs > 1) ? "SECONDS" : "SECOND")
    else
        formatex(text, len, "%d %L %d %L",
            mins, id, (mins > 1) ? "MINUTES" : "MINUTE", secs, id, (secs > 1) ? "SECONDS" : "SECOND")
}

setTimeVoice(text[], len, flags, tmlf)
{
    static temp[7][32]
    static mins, secs
    secs = tmlf % 60
    mins = tmlf / 60

    static a
    for (a = 0; a < 7; ++a)
        temp[a][0] = 0

    if (secs > 0)
    {
        num_to_word(secs, temp[4], charsmax(temp[]))

        if (!(flags & 8))
            copy(temp[5], charsmax(temp[]), "seconds ")      /* there is no "second" in default hl */
    }

    if (mins > 59)
    {
        static hours
        hours = mins / 60

        num_to_word(hours, temp[0], charsmax(temp[]))

        if (!(flags & 8))
            copy(temp[1], charsmax(temp[]), "hours ")

        mins = mins % 60
    }

    if (mins > 0)
    {
        num_to_word(mins, temp[2], charsmax(temp[]))

        if (!(flags & 8))
            copy(temp[3], charsmax(temp[]), "minutes ")
    }

    if (!(flags & 4))
        copy(temp[6], charsmax(temp[]), "remaining ")

    return formatex(text, len, "spk ^"vox/%s%s%s%s%s%s%s^"", temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6])
}

findDispFormat(time)
{
    static i
    for (i = 0; g_TimeSet[i][0]; ++i)
    {
        if (g_TimeSet[i][1] & 16)
        {
            if (g_TimeSet[i][0] > time)
            {
                if (!g_Switch)
                {
                    g_CountDown = g_Switch = time
                    remove_task(8648458)
                    set_task(1.0, "timeRemain", 34543, "", 0, "b")
                }

                return i
            }
        }
        else if (g_TimeSet[i][0] == time)
        {
            return i
        }
    }

    return -1
}

public setDisplaying()
{
    static arg[32], flags[32], num[32]
    static argc, i

    argc = read_argc() - 1
    i = 0

    while (i < argc && i < 32)
    {
        read_argv(i + 1, arg, charsmax(arg))
        parse(arg, flags, charsmax(flags), num, charsmax(num))

        g_TimeSet[i][0] = str_to_num(num)
        g_TimeSet[i][1] = read_flags(flags)

        i++
    }
    g_TimeSet[i][0] = 0

    return PLUGIN_HANDLED
}

public timeRemain(param[])
{
    static stimel[12]
    static gmtm, tmlf

    gmtm = get_timeleft()
    tmlf = g_Switch ? --g_CountDown : gmtm

    formatex(stimel, charsmax(stimel), "%02d:%02d", gmtm / 60, gmtm % 60)
    set_cvar_string("amx_timeleft", stimel)

    if (g_Switch && gmtm > g_Switch)
    {
        remove_task(34543)
        g_Switch = 0
        set_task(0.8, "timeRemain", 8648458, "", 0, "b")

        return
    }

    if (tmlf > 0 && g_LastTime != tmlf)
    {
        g_LastTime = tmlf

        static tm_set
        tm_set = findDispFormat(tmlf)

        if (tm_set != -1)
        {
            static flags
            static arg[128]

            flags = g_TimeSet[tm_set][1]

            if (flags & 1)
            {
                static players[32], pnum
                get_players(players, pnum, "c")

                static i
                for (i = 0; i < pnum; i++)
                {
                    setTimeText(arg, charsmax(arg), tmlf, players[i])

                    if (flags & 16)
                        set_hudmessage(255, 255, 255, -1.0, 0.85, 0, 0.0, 1.1, 0.1, 0.5, -1)
                    else
                        set_hudmessage(255, 255, 255, -1.0, 0.85, 0, 0.0, 3.0, 0.0, 0.5, -1)

                    show_hudmessage(players[i], "%s", arg)
                }
            }

            if (flags & 2)
            {
                setTimeVoice(arg, charsmax(arg), flags, tmlf)
                client_cmd(0, "%s", arg)
            }
        }
    }
}
