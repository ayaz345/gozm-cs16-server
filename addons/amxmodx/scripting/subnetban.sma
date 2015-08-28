#include <amxmodx>
#include <amxmisc>
#include <gozm>

#define SUBNET_FILE     "subnet_ips.ini"
#define WHITE_FILE      "white_list.ini"

new pcvar_kick_msg

new g_white_file[64]
new g_ips_file[64]
new g_log_folder[64]
new g_log_file[128]

new Array:g_subnet_array
new Array:g_white_array
new g_subnet_array_size
new g_white_array_size

public plugin_init()
{
    register_plugin("Subnet Ban", "5.1", "GoZm")

    register_clcmd("subnet", "show_subnet_list")
    register_clcmd("whitelist", "show_white_list")
    register_clcmd("reload_subnet", "reload_subnet_list")

    register_srvcmd("subnet", "show_subnet_list")
    register_srvcmd("whitelist", "show_white_list")
    register_srvcmd("reload_subnet", "reload_subnet_list")

    pcvar_kick_msg = register_cvar("amx_subnet_kick_msg", "vk.com/go_zombie")

    g_subnet_array = ArrayCreate(32)
    g_white_array = ArrayCreate(32)

    new cfgDir[32]
    get_configsdir(cfgDir, charsmax(cfgDir))
    formatex(g_ips_file, charsmax(g_ips_file), "%s/%s", cfgDir, SUBNET_FILE)
    formatex(g_white_file, charsmax(g_white_file), "%s/%s", cfgDir, WHITE_FILE)

    new base_dir[32], week_number[3]
    get_basedir(base_dir, charsmax(base_dir))
    formatex(g_log_folder, charsmax(g_log_folder), "%s/logs/connections", base_dir)
    if (!dir_exists(g_log_folder))
        mkdir(g_log_folder)
    get_time("%W", week_number, charsmax(week_number))
    formatex(g_log_file, charsmax(g_log_file), "%s/connections_%s.log", g_log_folder, week_number)
}

public plugin_cfg()
{
    load_subnets()
    load_whites()
}

public reload_subnet_list(id)
{
    ArrayClear(g_subnet_array)
    load_subnets()
    show_subnet_list(id)
}

load_subnets()
{
    new readdata[40]
    new ips_file = fopen(g_ips_file, "rt")
    while (ips_file && !feof(ips_file))
    {
        fgets(ips_file, readdata, charsmax(readdata))

        if (readdata[0] == ';' || readdata[0] == '#' || strlen(readdata) < 15 ||
            (readdata[0] == '/' && readdata[1] == '/'))
            continue

        replace(readdata, charsmax(readdata), "/", " ")
        replace(readdata, charsmax(readdata), "-", " ")
        replace(readdata, charsmax(readdata), "^n", "")
        ArrayPushString(g_subnet_array, readdata)
    }
    if (ips_file) fclose(ips_file)

    g_subnet_array_size = ArraySize(g_subnet_array)
}

load_whites()
{
    new readdata[32]
    new white_file = fopen(g_white_file, "rt")
    while (white_file && !feof(white_file))
    {
        fgets(white_file, readdata, charsmax(readdata))

        if (readdata[0] == ';' || readdata[0] == '#' || strlen(readdata) < 1 ||
            (readdata[0] == '/' && readdata[1] == '/'))
            continue

        replace(readdata, charsmax(readdata), "^n", "")
        ArrayPushString(g_white_array, readdata)
    }
    if (white_file) fclose(white_file)

    g_white_array_size = ArraySize(g_white_array)
}

public plugin_end()
{
    ArrayDestroy(g_subnet_array)
    ArrayDestroy(g_white_array)
}

public client_putinserver(id)
{
    static userip[16], userauth[32], name[32]

    get_user_ip(id, userip, charsmax(userip), 1)
    get_user_authid(id, userauth, charsmax(userauth))
    get_user_name(id, name, charsmax(name))

    if (!has_vip(id) && check_subnet(id, userip))
    {
        new kick_msg[32]
        get_pcvar_string(pcvar_kick_msg, kick_msg, charsmax(kick_msg))
        server_cmd("kick #%d ^"%s^"", get_user_userid(id), kick_msg)
        log_to_file(g_log_file, "%s | %s | %s - FAILED to connect", name, userip, userauth)
    }
    else
        log_to_file(g_log_file, "%s | %s | %s", name, userip, userauth)
}

bool:check_subnet(id, ip[])
{
    static sipaddr1[16], sipaddr2[16]
    static subnet[32], i

    for (i = 0; i < g_subnet_array_size; i++)
    {
        ArrayGetString(g_subnet_array, i, subnet, charsmax(subnet))
        parse(subnet, sipaddr1, charsmax(sipaddr1), sipaddr2, charsmax(sipaddr2))

        if (is_ip_blocked(sipaddr1, ip, sipaddr2))
        {
            if (!in_white_list(id))
            {
                return true
            }
        }
    }

    return false
}

bool:in_white_list(id)
{
    static player_name[32]

    get_user_name(id, player_name, charsmax(player_name))

    if (ArrayFindString(g_white_array, player_name) != -1)
        return true

    return false
}

bool:is_ip_blocked(sipaddr1[], userip[], sipaddr2[])
{
    const octets_num = 4
    static ip1_str[octets_num][4], ip2_str[octets_num][4], ip3_str[octets_num][4]
    static ip1_octets[octets_num], ip2_octets[octets_num], ip3_octets[octets_num]
    static uip[3][16]
    static i

    copy(uip[0], charsmax(uip[]), sipaddr1)
    replace_all(uip[0], charsmax(uip[]), ".", " ")
    parse(uip[0], ip1_str[0], charsmax(ip1_str[]), ip1_str[1], charsmax(ip1_str[]),
                  ip1_str[2], charsmax(ip1_str[]), ip1_str[3], charsmax(ip1_str[]))
    for (i = 0; i < octets_num; i++)
        ip1_octets[i] = str_to_num(ip1_str[i])

    copy(uip[1], charsmax(uip[]), userip)
    replace_all(uip[1], charsmax(uip[]), ".", " ")
    parse(uip[1], ip2_str[0], charsmax(ip2_str[]), ip2_str[1], charsmax(ip2_str[]),
                  ip2_str[2], charsmax(ip2_str[]), ip2_str[3], charsmax(ip2_str[]))
    for (i = 0; i < octets_num; i++)
        ip2_octets[i] = str_to_num(ip2_str[i])

    copy(uip[2], charsmax(uip[]), sipaddr2)
    replace_all(uip[2], charsmax(uip[]), ".", " ")
    parse(uip[2], ip3_str[0], charsmax(ip3_str[]), ip3_str[1], charsmax(ip3_str[]),
                  ip3_str[2], charsmax(ip3_str[]), ip3_str[3], charsmax(ip3_str[]))
    for (i = 0; i < octets_num; i++)
        ip3_octets[i] = str_to_num(ip3_str[i])

    for (i = 0; i < octets_num; i++)
    {
        if (!(ip1_octets[i] <= ip2_octets[i] <= ip3_octets[i]))
            return false
    }

    return true
}

public show_subnet_list(id)
{
    static line[50], i

    if (id)
        console_print(id, "==== Here are Banned Subnets ====")
    else
        server_print("==== Here are Banned Subnets ====")

    for (i = 0; i < g_subnet_array_size; i++)
    {
        ArrayGetString(g_subnet_array, i, line, charsmax(line))
        if (id)
            console_print(id, "%d. %s", i+1, line)
        else
            server_print("%d. %s", i+1, line)
    }

    if (id)
        console_print(id, "==== End of Banned Subnets ====")
    else
        server_print("==== End of Banned Subnets ====")
}

public show_white_list(id)
{
    static line[50], i

    if (id)
        console_print(id, "==== Here is White List ====")
    else
        server_print("==== Here is White List ====")

    for (i = 0; i < g_white_array_size; i++)
    {
        ArrayGetString(g_white_array, i, line, charsmax(line))
        if (id)
            console_print(id, "%d. %s", i+1, line)
        else
            server_print("%d. %s", i+1, line)

    }

    if (id)
        console_print(id, "==== End of White List ====")
    else
        server_print("==== End of White List ====")
}
