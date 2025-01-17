#include <amxmodx>
#include <amxmisc>
#include <gozm>

/** skip autoloading since it's optional */
#define AMXMODX_NOAUTOLOAD
#include <cstrike>

new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_menuOption[33]
new g_menuSettings[33]

new g_menuSelect[33][64]
new g_menuSelectNum[33]

#define MAX_CLCMDS 24

new g_clcmdName[MAX_CLCMDS][32]
new g_clcmdCmd[MAX_CLCMDS][64]
new g_clcmdMisc[MAX_CLCMDS][2]
new g_clcmdNum

new g_coloredMenus
new g_cstrike = 0

new Array:g_bantimes;
new Array:g_slapsettings;

new g_CSTeamNames[3][] = {
    "TERRORIST",
    "CT",
    "SPECTATOR"
}
new g_CSTeamNumbers[3][] = {
    "1",
    "2",
    "6"
}
new g_CSTeamiNumbers[3] = {
    1,
    2,
    6
}


public plugin_natives()
{
    set_module_filter("module_filter")
    set_native_filter("native_filter")
}

public plugin_init()
{
    register_plugin("Players Menu", AMXX_VERSION_STR, "AMXX Dev Team")
    register_dictionary("common.txt")
    register_dictionary("admincmd.txt")
    register_dictionary("plmenu.txt")

    register_clcmd("amx_kickmenu", "cmdKickMenu", ADMIN_KICK, "- displays kick menu")
    register_clcmd("amx_banmenu", "cmdBanMenu", ADMIN_FLAG, "- displays ban menu")
    register_clcmd("amx_slapmenu", "cmdSlapMenu", ADMIN_SLAY, "- displays slap/slay menu")
    register_clcmd("amx_teammenu", "cmdTeamMenu", ADMIN_LEVEL_A, "- displays team menu")
    register_clcmd("amx_clcmdmenu", "cmdClcmdMenu", ADMIN_LEVEL_A, "- displays client cmds menu")

    register_menucmd(register_menuid("Ban Menu"), 1023, "actionBanMenu")
    register_menucmd(register_menuid("Kick Menu"), 1023, "actionKickMenu")
    register_menucmd(register_menuid("Slap/Slay Menu"), 1023, "actionSlapMenu")
    register_menucmd(register_menuid("Team Menu"), 1023, "actionTeamMenu")
    register_menucmd(register_menuid("Client Cmds Menu"), 1023, "actionClcmdMenu")


    g_bantimes = ArrayCreate()
    // Load up the old default values
    ArrayPushCell(g_bantimes, 0)
    ArrayPushCell(g_bantimes, 5)
    ArrayPushCell(g_bantimes, 10)
    ArrayPushCell(g_bantimes, 15)
    ArrayPushCell(g_bantimes, 30)
    ArrayPushCell(g_bantimes, 45)
    ArrayPushCell(g_bantimes, 60)


    g_slapsettings = ArrayCreate()
    // Old default values
    ArrayPushCell(g_slapsettings, 0) // First option is ignored - it is slay
    ArrayPushCell(g_slapsettings, 0); // slap 0 damage
    ArrayPushCell(g_slapsettings, 1)
    ArrayPushCell(g_slapsettings, 5)


    register_srvcmd("amx_plmenu_bantimes", "plmenu_setbantimes")
    register_srvcmd("amx_plmenu_slapdmg", "plmenu_setslapdmg")

    g_coloredMenus = colored_menus()

    new clcmds_ini_file[64]
    get_configsdir(clcmds_ini_file, charsmax(clcmds_ini_file))
    format(clcmds_ini_file, charsmax(clcmds_ini_file), "%s/clcmds.ini", clcmds_ini_file)
    load_settings(clcmds_ini_file)

    if (module_exists("cstrike"))
        g_cstrike = 1
}

public plugin_end()
{
    ArrayDestroy(g_bantimes)
    ArrayDestroy(g_slapsettings)
}

public plmenu_setbantimes()
{
    static buff[32]
    static args
    args = read_argc()

    if (args <= 1)
    {
        server_print("usage: amx_plmenu_bantimes <time1> [time2] [time3] ...")
        server_print("   use time of 0 for permanent.")

        return
    }

    ArrayClear(g_bantimes)

    static i
    for (i = 1; i < args; i++)
    {
        read_argv(i, buff, charsmax(buff))

        ArrayPushCell(g_bantimes, str_to_num(buff))
    }

}
public plmenu_setslapdmg()
{
    static buff[32]
    static args
    args = read_argc()

    if (args <= 1)
    {
        server_print("usage: amx_plmenu_slapdmg <dmg1> [dmg2] [dmg3] ...")
        server_print("   slay is automatically set for the first value.")

        return;
    }

    ArrayClear(g_slapsettings)

    ArrayPushCell(g_slapsettings, 0) // compensate for slay

    for (new i = 1; i < args; i++)
    {
        read_argv(i, buff, charsmax(buff))

        ArrayPushCell(g_slapsettings, str_to_num(buff))

    }
}

public module_filter(const module[])
{
    if (equali(module, "cstrike"))
        return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}

public native_filter(const name[], index, trap)
{
    if (!trap)
        return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}

/* Ban menu */
public actionBanMenu(id, key)
{
    switch (key)
    {
        case 7:
        {
            /* BEGIN OF CHANGES BY MISTAGEE ADDED A FEW MORE OPTIONS */
            ++g_menuOption[id]
            g_menuOption[id] %= ArraySize(g_bantimes);

            g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id])

            displayBanMenu(id, g_menuPosition[id])
        }
        case 8: displayBanMenu(id, ++g_menuPosition[id])
        case 9: displayBanMenu(id, --g_menuPosition[id])
        default:
        {
            static player, userid2
            static name[32], name2[32], authid[32], authid2[32]

            get_user_name(player, name2, charsmax(name2))
            get_user_authid(id, authid, charsmax(authid))
            get_user_authid(player, authid2, charsmax(authid2))
            get_user_name(id, name, charsmax(name))

            player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]
            userid2 = get_user_userid(player)

            if(!has_rcon(id))
                log_amx("Ban: ^"%s<%d><%s><>^" ban and kick ^"%s<%d><%s><>^" (minutes ^"%d^")", name, get_user_userid(id), authid, name2, userid2, authid2, g_menuSettings[id])

            if (g_menuSettings[id]==0) // permanent
            {
                static maxpl, i
                maxpl = get_maxplayers()
                for (i = 1; i <= maxpl; i++)
                {
                    show_activity_id(i, id, name, "%L %s %L", i, "BAN", name2, i, "PERM")
                }
            }
            else
            {
                static tempTime[32]
                formatex(tempTime, charsmax(tempTime), "%d",g_menuSettings[id])

                static maxpl, i
                maxpl = get_maxplayers()
                for (i = 1; i <= maxpl; i++)
                {
                    show_activity_id(i, id, name, "%L %s %L", i, "BAN", name2, i, "FOR_MIN", tempTime)
                }
            }
            /* ---------- check for Steam ID added by MistaGee --------------------
            IF AUTHID == 4294967295 OR VALVE_ID_LAN OR HLTV, BAN PER IP TO NOT BAN EVERYONE */

            if (equal("4294967295", authid2)
                || equal("HLTV", authid2)
                || equal("STEAM_ID_LAN", authid2)
                || equali("VALVE_ID_LAN", authid2))
            {
                /* END OF MODIFICATIONS BY MISTAGEE */
                static ipa[32]
                get_user_ip(player, ipa, charsmax(ipa), 1)

                server_cmd("addip %d %s;writeip", g_menuSettings[id], ipa)
            }
            else
            {
                server_cmd("banid %d #%d kick;writeid", g_menuSettings[id], userid2)
            }

            server_exec()

            displayBanMenu(id, g_menuPosition[id])
        }
    }

    return PLUGIN_HANDLED
}

displayBanMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], name[32], keys
    static a, i, b, start, end, len

    b = 0
    start = pos * 7

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
                       g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n",
                       id, "BAN_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
    end = start + 7
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (has_vip(i) && !has_rcon(i))
        {
            ++b

            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody)-len, "\d%d. %s^n\w", b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "#. %s^n", name)
        } else {
            keys |= (1<<b)

            if (has_vip(i) && !has_rcon(i))
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "%d. %s^n", ++b, name)
        }
    }

    if (g_menuSettings[id])
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %L^n", id, "BAN_FOR_MIN", g_menuSettings[id])
    else
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %L^n", id, "BAN_PERM")

    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody)-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody)-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Ban Menu")
}

public cmdBanMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    g_menuOption[id] = 0

    if (ArraySize(g_bantimes) > 0)
    {
        g_menuSettings[id] = ArrayGetCell(g_bantimes, g_menuOption[id]);
    }
    else
    {
        // should never happen, but failsafe
        g_menuSettings[id] = 0
    }
    displayBanMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

/* Slap/Slay */
public actionSlapMenu(id, key)
{
    switch (key)
    {
        case 7:
        {
            ++g_menuOption[id]

            g_menuOption[id] %= ArraySize(g_slapsettings);

            g_menuSettings[id] = ArrayGetCell(g_slapsettings, g_menuOption[id]);

            displaySlapMenu(id, g_menuPosition[id]);
        }
        case 8: displaySlapMenu(id, ++g_menuPosition[id])
        case 9: displaySlapMenu(id, --g_menuPosition[id])
        default:
        {
            static name2[32], player
            player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

            get_user_name(player, name2, charsmax(name2))

            if (!is_user_alive(player))
            {
                client_print(id, print_chat, "%L", id, "CANT_PERF_DEAD", name2)
                displaySlapMenu(id, g_menuPosition[id])

                return PLUGIN_HANDLED
            }

            static authid[32], authid2[32], name[32]

            get_user_authid(id, authid, charsmax(authid))
            get_user_authid(player, authid2, charsmax(authid2))
            get_user_name(id, name, charsmax(name))

            if (g_menuOption[id])
            {
                if(!has_rcon(id))
                    log_amx("Cmd: ^"%s<%d><%s><>^" slap with %d damage ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, g_menuSettings[id], name2, get_user_userid(player), authid2)

                show_activity_key("ADMIN_SLAP_1", "ADMIN_SLAP_2", name, name2, g_menuSettings[id]);
            } else {
                if(!has_rcon(id))
                    log_amx("Cmd: ^"%s<%d><%s><>^" slay ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)

                show_activity_key("ADMIN_SLAY_1", "ADMIN_SLAY_2", name, name2);
            }

            if (g_menuOption[id])
                user_slap(player, (get_user_health(player) > g_menuSettings[id]) ? g_menuSettings[id] : 0)
            else if (has_rcon(id))
                user_silentkill(player)
            else
                user_kill(player, 1)

            displaySlapMenu(id, g_menuPosition[id])
        }
    }

    return PLUGIN_HANDLED
}

displaySlapMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], keys
    static a, i, b, start, end, len
    static name[32], team[4]

    b = 0
    start = pos * 7

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
                        g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n",
                        id, "SLAP_SLAY_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
    end = start + 7
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (g_cstrike)
        {
            if (cs_get_user_team(i) == CS_TEAM_T)
            {
                copy(team, charsmax(team), "TE")
            }
            else if (cs_get_user_team(i) == CS_TEAM_CT)
            {
                copy(team, charsmax(team), "CT")
            } else {
                get_user_team(i, team, 3)
            }
        } else {
            get_user_team(i, team, charsmax(team))
        }

        if (!is_user_alive(i) || has_vip(i) && !has_rcon(i))
        {
            ++b

            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody)-len, "\d%d. %s\R%s^n\w", b, name, team)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "#. %s   %s^n", name, team)
        } else {
            keys |= (1<<b)

            if (has_vip(i) && !has_rcon(i))
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s \r*\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
            else
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s\y\R%s^n\w" : "%d. %s   %s^n", ++b, name, team)
        }
    }

    if (g_menuOption[id])
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %L^n", id, "SLAP_WITH_DMG", g_menuSettings[id])
    else
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %L^n", id, "SLAY")

    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody)-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody)-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Slap/Slay Menu")
}

public cmdSlapMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    g_menuOption[id] = 0
    if (ArraySize(g_slapsettings) > 0)
    {
        g_menuSettings[id] = ArrayGetCell(g_slapsettings, g_menuOption[id]);
    }
    else
    {
        // should never happen, but failsafe
        g_menuSettings[id] = 0
    }

    displaySlapMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

/* Kick */
public actionKickMenu(id, key)
{
    switch (key)
    {
        case 8: displayKickMenu(id, ++g_menuPosition[id])
        case 9: displayKickMenu(id, --g_menuPosition[id])
        default:
        {
            static authid[32], authid2[32], name[32], name2[32], player, userid2

            player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]

            get_user_authid(id, authid, charsmax(authid))
            get_user_authid(player, authid2, charsmax(authid2))
            get_user_name(id, name, charsmax(name))
            get_user_name(player, name2, charsmax(name2))

            userid2 = get_user_userid(player)

            if(!has_rcon(id))
                log_amx("Kick: ^"%s<%d><%s><>^" kick ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, userid2, authid2)

            show_activity_key("ADMIN_KICK_1", "ADMIN_KICK_2", name, name2)


            server_cmd("kick #%d", userid2)
            server_exec()

            displayKickMenu(id, g_menuPosition[id])
        }
    }

    return PLUGIN_HANDLED
}

displayKickMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], name[32], keys
    static a, i, b, start, end, pos, len

    b  = 0
    start = pos * 8

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
                       g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n",
                       id, "KICK_MENU", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
    end = start + 8
    keys = MENU_KEY_0

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (has_vip(i) && !has_rcon(i))
        {
            ++b

            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody)-len, "\d%d. %s^n\w", b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "#. %s^n", name)
        } else {
            keys |= (1<<b)

            if (has_vip(i) && !has_rcon(i))
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "%d. %s^n", ++b, name)
        }
    }

    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody)-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody)-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Kick Menu")
}

public cmdKickMenu(id, level, cid)
{
    if (cmd_access(id, level, cid, 1))
        displayKickMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

/* Team menu */
public actionTeamMenu(id, key)
{
    switch (key)
    {
        case 7:
        {
            g_menuOption[id] = (g_menuOption[id] + 1) % (g_cstrike ? 3 : 2)
            displayTeamMenu(id, g_menuPosition[id])
        }
        case 8: displayTeamMenu(id, ++g_menuPosition[id])
        case 9: displayTeamMenu(id, --g_menuPosition[id])
        default:
        {
            static authid[32], authid2[32], name[32], name2[32], player

            player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]

            get_user_name(player, name2, charsmax(name2))
            get_user_authid(id, authid, charsmax(authid))
            get_user_authid(player, authid2, charsmax(authid2))
            get_user_name(id, name, charsmax(name))

            log_amx("Cmd: ^"%s<%d><%s><>^" transfer ^"%s<%d><%s><>^" (team ^"%s^")", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, g_menuOption[id] ? "TERRORIST" : "CT")

            show_activity_key("ADMIN_TRANSF_1", "ADMIN_TRANSF_2", name, name2, g_CSTeamNames[g_menuOption[id] % 3])

            if (g_cstrike)
            {
                if (is_user_alive(player))
                {
                    static deaths
                    deaths = cs_get_user_deaths(player)
                    user_silentkill(player)
                    cs_set_user_deaths(player, deaths)
                }
                // This modulo math just aligns the option to the CsTeams-corresponding number
                cs_set_user_team(player, (g_menuOption[id] % 3) + 1)
                cs_reset_user_model(player)
            }
            else
            {
                static limit_setting
                limit_setting = get_cvar_num("mp_limitteams")

                set_cvar_num("mp_limitteams", 0)
                engclient_cmd(player, "jointeam", g_CSTeamNumbers[g_menuOption[id] % 2])
                engclient_cmd(player, "joinclass", "1")
                set_cvar_num("mp_limitteams", limit_setting)
            }

            displayTeamMenu(id, g_menuPosition[id])
        }
    }

    return PLUGIN_HANDLED
}

displayTeamMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], name[32], team[4], keys
    static a, i, b, start, end, pos, len, iteam

    b = 0
    start = pos * 7

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
                       g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n",
                       id, "TEAM_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
    end = start + 7
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (g_cstrike)
        {
            iteam = _:cs_get_user_team(i)

            if (iteam == 1)
            {
                copy(team, charsmax(team), "TE")
            }
            else if (iteam == 2)
            {
                copy(team, charsmax(team), "CT")
            }
            else if (iteam == 3)
            {
                copy(team, charsmax(team), "SPE");
                iteam = 6;
            } else {
                iteam = get_user_team(i, team, charsmax(team))
            }
        } else {
            iteam = get_user_team(i, team, charsmax(team))
        }

        if ((iteam == g_CSTeamiNumbers[g_menuOption[id] % (g_cstrike ? 3 : 2)]) || has_vip(i) && !has_rcon(i) && (i != id))
        {
            ++b

            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody)-len, "\d%d. %s\R%s^n\w", b, name, team)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "#. %s   %s^n", name, team)
        } else {
            keys |= (1<<b)

            if (has_vip(i) && !has_rcon(i) && (i != id))
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s \r*\y\R%s^n\w" : "%d. %s *   %s^n", ++b, name, team)
            else
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s\y\R%s^n\w" : "%d. %s   %s^n", ++b, name, team)
        }
    }

    len += format(menuBody[len], charsmax(menuBody)-len,
                  "^n8. %L^n", id, "TRANSF_TO", g_CSTeamNames[g_menuOption[id] % (g_cstrike ? 3 : 2)])

    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody)-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody)-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Team Menu")
}

public cmdTeamMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    g_menuOption[id] = 0

    displayTeamMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

/* Client cmds menu */
public actionClcmdMenu(id, key)
{
    switch (key)
    {
        case 7:
        {
            ++g_menuOption[id]
            g_menuOption[id] %= g_menuSelectNum[id]
            displayClcmdMenu(id, g_menuPosition[id])
        }
        case 8: displayClcmdMenu(id, ++g_menuPosition[id])
        case 9: displayClcmdMenu(id, --g_menuPosition[id])
        default:
        {
            static player, flags
            player = g_menuPlayers[id][g_menuPosition[id] * 7 + key]
            flags = g_clcmdMisc[g_menuSelect[id][g_menuOption[id]]][1]

            if (is_user_connected(player))
            {
                static command[512], authid[32], name[32], userid[32]

                copy(command, charsmax(command), g_clcmdCmd[g_menuSelect[id][g_menuOption[id]]])
                get_user_authid(player, authid, charsmax(authid))
                get_user_name(player, name, charsmax(name))
                num_to_str(get_user_userid(player), userid, charsmax(userid))

                replace(command, charsmax(command), "%userid%", userid)
                replace(command, charsmax(command), "%authid%", authid)
                replace(command, charsmax(command), "%name%", name)

                if (flags & 1)
                {
                    server_cmd("%s", command)
                    server_exec()
                } else if (flags & 2)
                    client_cmd(id, "%s", command)
                else if (flags & 4)
                    client_cmd(player, "%s", command)
            }

            if (flags & 8)
                displayClcmdMenu(id, g_menuPosition[id])
        }
    }

    return PLUGIN_HANDLED
}

displayClcmdMenu(id, pos)
{
    if (pos < 0)
        return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    static menuBody[512], name[32], keys
    static a, i, b, start, end, len, pos

    b = 0
    start = pos * 7

    if (start >= g_menuPlayersNum[id])
        start = pos = g_menuPosition[id] = 0

    len = formatex(menuBody, charsmax(menuBody),
                       g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n",
                       id, "CL_CMD_MENU", pos + 1, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
    end = start + 7
    keys = MENU_KEY_0|MENU_KEY_8

    if (end > g_menuPlayersNum[id])
        end = g_menuPlayersNum[id]

    for (a = start; a < end; ++a)
    {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, charsmax(name))

        if (!g_menuSelectNum[id] || (access(i, ADMIN_IMMUNITY) && i != id) && !has_rcon(i))
        {
            ++b

            if (g_coloredMenus)
                len += format(menuBody[len], charsmax(menuBody)-len, "\d%d. %s^n\w", b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "#. %s^n", name)
        } else {
            keys |= (1<<b)

            if (is_user_admin(i) && !has_rcon(i))
                len += format(menuBody[len], charsmax(menuBody)-len,
                              g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
            else
                len += format(menuBody[len], charsmax(menuBody)-len, "%d. %s^n", ++b, name)
        }
    }

    if (g_menuSelectNum[id])
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %s^n", g_clcmdName[g_menuSelect[id][g_menuOption[id]]])
    else
        len += format(menuBody[len], charsmax(menuBody)-len, "^n8. %L^n", id, "NO_CMDS")

    if (end != g_menuPlayersNum[id])
    {
        format(menuBody[len], charsmax(menuBody)-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], charsmax(menuBody)-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Client Cmds Menu")
}

public cmdClcmdMenu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    g_menuSelectNum[id] = 0

    static a
    for (a = 0; a < g_clcmdNum; ++a)
        if (access(id, g_clcmdMisc[a][0]))
            g_menuSelect[id][g_menuSelectNum[id]++] = a

    g_menuOption[id] = 0

    displayClcmdMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}

load_settings(szFilename[])
{
    if (!file_exists(szFilename))
        return 0

    new text[256], szFlags[32], szAccess[32]

    new file = fopen(szFilename, "rt")
    while (g_clcmdNum < MAX_CLCMDS && file && !feof(file))
    {
        fgets(file, text, charsmax(text))
        trim(text)

        // skip commented lines
        if (text[0] == ';' || strlen(text) < 1 || (text[0] == '/' && text[1] == '/'))
            continue

        if (parse(text, g_clcmdName[g_clcmdNum], charsmax(g_clcmdCmd[]),
                        g_clcmdCmd[g_clcmdNum], charsmax(g_clcmdCmd[]),
                        szFlags, charsmax(szFlags),
                        szAccess, charsmax(szAccess)) > 3)
        {
            while (replace(g_clcmdCmd[g_clcmdNum], charsmax(g_clcmdCmd[]), "\'", "^""))
            {
                // do nothing
            }

            g_clcmdMisc[g_clcmdNum][1] = read_flags(szFlags)
            g_clcmdMisc[g_clcmdNum][0] = read_flags(szAccess)
            g_clcmdNum++
        }
    }
    if (file) fclose(file)

    return 1
}
