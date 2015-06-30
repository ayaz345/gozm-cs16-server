#include <amxmodx>
#include <amxmisc>
#include <gozm>

// This is not a dynamic array because it would be bad for 24/7 map servers.
#define OLD_CONNECTION_QUEUE 10

// Old connection queue
new g_Names[OLD_CONNECTION_QUEUE][32]
new g_SteamIDs[OLD_CONNECTION_QUEUE][32]
new g_IPs[OLD_CONNECTION_QUEUE][32]
new g_Access[OLD_CONNECTION_QUEUE]
new g_Tracker
new g_Size

public plugin_init()
{
    register_plugin("Admin Commands", AMXX_VERSION_STR, "AMXX Dev Team")

    register_dictionary("admincmd.txt")
    register_dictionary("common.txt")
    register_dictionary("adminhelp.txt")

    register_concmd("amx_kick", "cmdKick", ADMIN_KICK, "<name or #userid> [reason]")
    register_concmd("amx_slay", "cmdSlay", ADMIN_SLAY, "<name or #userid>")
    register_concmd("amx_slap", "cmdSlap", ADMIN_SLAY, "<name or #userid> [power]")
    register_concmd("amx_who", "cmdWho", ADMIN_ADMIN, "- displays who is on server")
    register_concmd("amx_plugins", "cmdPlugins", ADMIN_ADMIN)
    register_concmd("amx_map", "cmdMap", ADMIN_MAP, "<mapname>")
    register_concmd("amx_nick", "cmdNick", ADMIN_SLAY, "<name or #userid> <new nick>")
    register_concmd("amx_last", "cmdLast", ADMIN_FLAG, "- list the last few disconnected clients info")
}

public plugin_cfg()
{
    new add_cvar[16]
    copy(add_cvar, charsmax(add_cvar), "amx_cvar add %s")

    // Cvars which can be changed only with rcon access
    server_cmd(add_cvar, "rcon_password")
    server_cmd(add_cvar, "amx_show_activity")
    server_cmd(add_cvar, "amx_mode")
    server_cmd(add_cvar, "amx_password_field")
    server_cmd(add_cvar, "amx_default_access")
    server_cmd(add_cvar, "amx_reserved_slots")
    server_cmd(add_cvar, "amx_reservation")
    server_cmd(add_cvar, "amx_sql_table")
    server_cmd(add_cvar, "amx_sql_host")
    server_cmd(add_cvar, "amx_sql_user")
    server_cmd(add_cvar, "amx_sql_pass")
    server_cmd(add_cvar, "amx_sql_db")
    server_cmd(add_cvar, "amx_sql_type")
}

public client_disconnect(id)
{
    InsertInfo(id)
}

stock InsertInfo(id)
{

    // Scan to see if this entry is the last entry in the list
    // If it is, then update the name and access
    // If it is not, then insert it again.

    if (g_Size > 0)
    {
        static ip[32], auth[32]

        get_user_authid(id, auth, charsmax(auth))
        get_user_ip(id, ip, charsmax(ip), 1 /*no port*/)

        static last
        last = 0

        if (g_Size < sizeof(g_SteamIDs))
        {
            last = g_Size - 1
        }
        else
        {
            last = g_Tracker - 1

            if (last < 0)
            {
                last = g_Size - 1
            }
        }

        if (equal(auth, g_SteamIDs[last]) &&
            equal(ip, g_IPs[last])) // need to check ip too, or all the nosteams will while it doesn't work with their illegitimate server
        {
            get_user_name(id, g_Names[last], charsmax(g_Names[]))
            g_Access[last] = get_user_flags(id)

            return
        }
    }

    // Need to insert the entry

    static target  // the slot to save the info at
    target = 0

    // Queue is not yet full
    if (g_Size < sizeof(g_SteamIDs))
    {
        target = g_Size

        ++g_Size

    }
    else
    {
        target = g_Tracker

        ++g_Tracker
        // If we reached the end of the array, then move to the front
        if (g_Tracker == sizeof(g_SteamIDs))
        {
            g_Tracker = 0
        }
    }

    get_user_authid(id, g_SteamIDs[target], charsmax(g_SteamIDs[]))
    get_user_name(id, g_Names[target], charsmax(g_Names[]))
    get_user_ip(id, g_IPs[target], charsmax(g_IPs[]), 1/*no port*/)

    g_Access[target] = get_user_flags(id)
}

stock GetInfo(i, name[], namesize, auth[], authsize, ip[], ipsize, &access)
{
    if (i >= g_Size)
    {
        abort(AMX_ERR_NATIVE, "GetInfo: Out of bounds (%d:%d)", i, g_Size)
    }

    static target
    target = (g_Tracker + i) % sizeof(g_SteamIDs)

    copy(name, namesize, g_Names[target])
    copy(auth, authsize, g_SteamIDs[target])
    copy(ip,   ipsize,   g_IPs[target])
    access = g_Access[target]
}

public cmdKick(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    static arg[32], player
    read_argv(1, arg, 31)
    player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

    if (!player)
        return PLUGIN_HANDLED

    static authid[32], authid2[32], name2[32], name[32], userid2, reason[32]

    get_user_authid(id, authid, charsmax(authid))
    get_user_authid(player, authid2, charsmax(authid2))
    get_user_name(player, name2, charsmax(name2))
    get_user_name(id, name, charsmax(name))
    userid2 = get_user_userid(player)
    read_argv(2, reason, charsmax(reason))
    remove_quotes(reason)

    log_amx("Kick: ^"%s<%d><%s><>^" kick ^"%s<%d><%s><>^" (reason ^"%s^")", name, get_user_userid(id), authid, name2, userid2, authid2, reason)

    show_activity_key("ADMIN_KICK_1", "ADMIN_KICK_2", name, name2)

    if (reason[0])
        server_cmd("kick #%d ^"%s^"", userid2, reason)
    else
        server_cmd("kick #%d", userid2)

    console_print(id, "[AMXX] Client ^"%s^" kicked", name2)

    return PLUGIN_HANDLED
}

public cmdSlay(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    static arg[32]

    read_argv(1, arg, charsmax(arg))

    static player
    player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE)

    if (!player)
        return PLUGIN_HANDLED

    if (has_rcon(id))
        user_kill(player, 1)
    else
        user_silentkill(player)

    static authid[32], name2[32], authid2[32], name[32]

    get_user_authid(id, authid, charsmax(authid))
    get_user_name(id, name, charsmax(name))
    get_user_authid(player, authid2, charsmax(authid2))
    get_user_name(player, name2, charsmax(name2))

    if(!has_rcon(id))
        log_amx("Cmd: ^"%s<%d><%s><>^" slay ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2)

    show_activity_key("ADMIN_SLAY_1", "ADMIN_SLAY_2", name, name2)

    console_print(id, "[AMXX] %L", id, "CLIENT_SLAYED", name2)

    return PLUGIN_HANDLED
}

public cmdSlap(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    static arg[32]

    read_argv(1, arg, charsmax(arg))
    static player
    player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE)

    if (!player)
        return PLUGIN_HANDLED

    static spower[32], authid[32], name2[32], authid2[32], name[32]

    read_argv(2, spower, charsmax(spower))

    static damage
    damage = str_to_num(spower)

    user_slap(player, damage)

    get_user_authid(id, authid, charsmax(authid))
    get_user_name(id, name, charsmax(name))
    get_user_authid(player, authid2, charsmax(authid2))
    get_user_name(player, name2, charsmax(name2))

    if(!has_rcon(id))
        log_amx("Cmd: ^"%s<%d><%s><>^" slap with %d damage ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, damage, name2, get_user_userid(player), authid2)

    show_activity_key("ADMIN_SLAP_1", "ADMIN_SLAP_2", name, name2, damage)

    console_print(id, "[AMXX] %L", id, "CLIENT_SLAPED", name2, damage)

    return PLUGIN_HANDLED
}

public chMap(map[])
{
    server_cmd("changelevel %s", map)
}

public cmdMap(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    static arg[32], arglen
    arglen = read_argv(1, arg, charsmax(arg))

    if (!is_map_valid(arg))
    {
        console_print(id, "[AMXX] %L", id, "MAP_NOT_FOUND")
        return PLUGIN_HANDLED
    }

    static authid[32], name[32]

    get_user_authid(id, authid, charsmax(authid))
    get_user_name(id, name, charsmax(name))

    show_activity_key("ADMIN_MAP_1", "ADMIN_MAP_2", name, arg)

    log_amx("Cmd: ^"%s<%d><%s><>^" changelevel ^"%s^"", name, get_user_userid(id), authid, arg)

    static _modName[10]
    get_modname(_modName, charsmax(_modName))

    if (!equal(_modName, "zp"))
    {
        message_begin(MSG_BROADCAST, SVC_INTERMISSION)
        message_end()
    }

    set_task(2.0, "chMap", 0, arg, arglen + 1)

    return PLUGIN_HANDLED
}

stock bool:onlyRcon(const name[])
{
    static ptr
    ptr = get_cvar_pointer(name)
    if (ptr && get_pcvar_flags(ptr) & FCVAR_PROTECTED)
    {
        return true
    }
    return false
}

public cmdPlugins(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    if (id == 0) // If server executes redirect this to "amxx plugins" for more in depth output
    {
        server_cmd("amxx plugins")
        server_exec()
        return PLUGIN_HANDLED
    }

    static name[32], version[32], author[32], filename[32], status[32]
    static lName[32], lVersion[32], lAuthor[32], lFile[32], lStatus[32]

    formatex(lName, charsmax(lName), "%L", id, "NAME")
    formatex(lVersion, charsmax(lVersion), "%L", id, "VERSION")
    formatex(lAuthor, charsmax(lAuthor), "%L", id, "AUTHOR")
    formatex(lFile, charsmax(lFile), "%L", id, "FILE")
    formatex(lStatus, charsmax(lStatus), "%L", id, "STATUS")

    static StartPLID, EndPLID, num
    StartPLID = 0

    static Temp[96]

    num = get_pluginsnum()

    if (read_argc() > 1)
    {
        read_argv(1, Temp, charsmax(Temp))
        StartPLID = str_to_num(Temp) - 1 // zero-based
    }

    EndPLID = min(StartPLID + 10, num)

    static running
    running = 0

    console_print(id, "----- %L -----", id, "LOADED_PLUGINS")
    console_print(id, "%-18.17s %-11.10s %-17.16s %-16.15s %-9.8s", lName, lVersion, lAuthor, lFile, lStatus)

    static i
    i = StartPLID
    while (i < EndPLID)
    {
        get_plugin(i++, filename, charsmax(filename),
                        name, charsmax(name),
                        version, charsmax(version),
                        author, charsmax(author),
                        status, charsmax(status))
        console_print(id, "%-18.17s %-11.10s %-17.16s %-16.15s %-9.8s", name, version, author, filename, status)

        if (status[0]=='d' || status[0]=='r') // "debug" or "running"
            running++
    }
    console_print(id, "%L", id, "PLUGINS_RUN", EndPLID-StartPLID, running)
    console_print(id, "----- %L -----",id,"HELP_ENTRIES",StartPLID + 1,EndPLID,num)

    if (EndPLID < num)
    {
        formatex(Temp, charsmax(Temp), "----- %L -----", id, "HELP_USE_MORE", EndPLID + 1)
        replace_all(Temp, charsmax(Temp), "amx_help", "amx_plugins")
        console_print(id, "%s", Temp)
    }
    else
    {
        formatex(Temp, charsmax(Temp), "----- %L -----", id, "HELP_USE_BEGIN")
        replace_all(Temp, charsmax(Temp), "amx_help", "amx_plugins")
        console_print(id, "%s", Temp)
    }

    return PLUGIN_HANDLED
}

public cmdWho(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    static players[32], inum, cl_on_server[64], ip[16], name[32], flags, sflags[32], player_status[6]
    static lAccess[16], usrid, steam_id[32], map_name[32]
    static vnum, a

    vnum = 0

    formatex(lAccess, charsmax(lAccess), "%L", id, "ACCESS")

    get_players(players, inum)
    get_mapname(map_name, charsmax(map_name))
    formatex(cl_on_server, charsmax(cl_on_server), "GoZm Players:")
    console_print(id,
        "^n%s^n#          %-24.15s    %-15s       %-15s                    %s",
        cl_on_server, "Name", "IP adress", "STEAM id", lAccess)

    for (a = 0; a < inum; ++a)
    {
        get_user_ip(players[a], ip, charsmax(ip), 1)
        usrid = get_user_userid(players[a])
        get_user_name(players[a], name, charsmax(name))
        get_user_authid(players[a], steam_id, charsmax(steam_id))
        flags = get_user_flags(players[a])
        get_flags(flags, sflags, charsmax(sflags))

        if (has_rcon(players[a]))
        {
            formatex(sflags, 1, "z")
        }

        if (equal(sflags, "z"))
            copy(player_status, charsmax(player_status), "-")
        else if (equal(sflags, "t"))
        {
            copy(player_status, charsmax(player_status), "VIP")
            vnum++
        }
        else
        {
            copy(player_status, charsmax(player_status), "ADMIN")
            vnum++
        }
        console_print(id, "%d     %-23.15s%-18s%-18s        %s", usrid, name, ip, steam_id, player_status)
    }
    console_print(id, "Total %d(%d) on %s", inum, vnum, map_name)

    get_user_ip(id, ip, charsmax(ip), 1)
    get_user_name(id, name, charsmax(name))
    if(!has_rcon(id))
        log_amx("Cmd: ^"%s<%d><%s><>^" ask for players list", name, get_user_userid(id), ip)

    return PLUGIN_HANDLED
}

public cmdNick(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED

    static arg1[32], arg2[32], authid[32], name[32], authid2[32], name2[32]

    read_argv(1, arg1, charsmax(arg1))
    read_argv(2, arg2, charsmax(arg2))

    static player
    player = cmd_target(id, arg1, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

    if (!player)
        return PLUGIN_HANDLED

    get_user_authid(id, authid, charsmax(authid))
    get_user_name(id, name, charsmax(name))
    get_user_authid(player, authid2, charsmax(authid2))
    get_user_name(player, name2, charsmax(name2))

    client_cmd(player, "name ^"%s^"", arg2)

    if(!has_rcon(id))
        log_amx("Cmd: ^"%s<%d><%s><>^" change nick to ^"%s^" ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, arg2, name2, get_user_userid(player), authid2)

    show_activity_key("ADMIN_NICK_1", "ADMIN_NICK_2", name, name2, arg2)

    console_print(id, "[AMXX] %L", id, "CHANGED_NICK", name2, arg2)

    return PLUGIN_HANDLED
}

public cmdLast(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
    {
        return PLUGIN_HANDLED
    }

    static name[32], authid[32], ip[32], flags[32], access, i

    // This alignment is a bit weird (it should grow if the name is larger)
    // but otherwise for the more common shorter name, it'll wrap in server console
    // Steam client display is all skewed anyway because of the non fixed font.
    console_print(id, "%19s %20s %15s %s", "name", "authid", "ip", "access")

    for (i = 0; i < g_Size; i++)
    {
        GetInfo(i, name, charsmax(name), authid, charsmax(authid), ip, charsmax(ip), access)

        get_flags(access, flags, charsmax(flags))

        console_print(id, "%19s %20s %15s %s", name, authid, ip, flags)
    }

    console_print(id, "%d old connections saved.", g_Size)

    return PLUGIN_HANDLED
}
