#include <amxmodx>
#include <amxmisc>

new white_list[64]
new ips_list[64]

public plugin_init()
{
    register_plugin("GoZm Ban", "3.0", "Dimka")
    register_cvar("amx_subnet_msg", "Your subnet blocked in this server to play with old Non-Steam Patch. Please use Steam or latest client with revEmu")
    register_clcmd("subnet", "show_subnet_list")
    register_clcmd("whitelist", "show_white_list")
}

public plugin_precache() 
{
    new cfgDir[32]
    get_configsdir(cfgDir,31)
    formatex(white_list,63,"%s/white_list.ini",cfgDir)
    formatex(ips_list,63,"%s/ips.ini",cfgDir)
}

public client_putinserver(id)
{
    if (!has_vip(id))
        check_subnet(id)
    return PLUGIN_CONTINUE
}

public check_subnet(id)
{
    if (!is_user_bot(id)) {
        new subnetmsg[512]
        new readdata[50]
        new sipaddr1[16]
        new sipaddr2[16]
        new len, pos
        new userip[16]
        new userauth[32]
        new name[32]
        get_user_ip(id,userip,16,1)
        get_user_authid(id, userauth, 31)
        get_user_name(id, name, 31)
        get_cvar_string("amx_subnet_msg", subnetmsg, 512)
        
        new week_number[3], logfile[19]
        new bool:is_clear = true
        get_time("%W", week_number, 2)
        format(logfile, 18, "connections_%s.log", week_number)
        
        while(read_file(ips_list,pos++,readdata,50,len)) {
            if(readdata[0] == ';' || readdata[0] == '#') continue
            replace(readdata, 50, "/", " ")
            parse(readdata, sipaddr1, 16, sipaddr2, 16)

            if(is_ip_blocked(sipaddr1, userip, sipaddr2))
            {
                if(!in_white_list(id))
                {
                    server_cmd("kick #%d ^"%s^"", get_user_userid(id), subnetmsg);
                    log_to_file(logfile, "%s | %s | %s - FAILED to connect", name, userip, userauth)
                    is_clear = false
                }
            }
        }
        if(is_clear)
            log_to_file(logfile, "%s | %s | %s", name, userip, userauth)
        
    } else {
        set_user_flags(id,read_flags("z"))
    }
}

public is_ip_blocked(sipaddr1[16], userip[16], sipaddr2[16]) {
    new ip1_str[4][4], ip2_str[4][4], ip3_str[4][4]
    new ip1_octets[4], ip2_octets[4], ip3_octets[4]
    new uip[3][16]
    copy(uip[0], 16, sipaddr1)
    while(replace(uip[0], 16, ".", " ")) {}
    parse(uip[0], ip1_str[0], 4, ip1_str[1], 4, ip1_str[2], 4, ip1_str[3], 4)
    for(new i = 0; i <= 3; i++)
        ip1_octets[i] = str_to_num(ip1_str[i])

    copy(uip[1], 16, userip)
    while(replace(uip[1], 16, ".", " ")) {}
    parse(uip[1], ip2_str[0], 4, ip2_str[1], 4, ip2_str[2], 4, ip2_str[3], 4)
    for(new i = 0; i <= 3; i++) {
        ip2_octets[i] = str_to_num(ip2_str[i])
    }

    copy(uip[2], 16, sipaddr2)
    while(replace(uip[2], 16, ".", " ")) {}
    parse(uip[2], ip3_str[0], 4, ip3_str[1], 4, ip3_str[2], 4, ip3_str[3], 4)
    for(new i = 0; i <=3; i++)
        ip3_octets[i] = str_to_num(ip3_str[i])

    for(new i = 0; i <= 3; i++) {
        if(ip1_octets[i] <= ip2_octets[i] <= ip3_octets[i])
            continue
        else
            return 0
    }
    
    return 1
}

public in_white_list(id) {
    new player_name[32], white_name[32]
    get_user_name(id, player_name, 31)
    new sfLineData[32]
    new file = fopen(white_list,"rt")
    while(file && !feof(file)) {
        fgets(file,sfLineData,127)

        // Skip Comment ; // and Empty Lines 
        if (sfLineData[0] == ';' || 
            strlen(sfLineData) < 1 || 
            (sfLineData[0] == '/' && sfLineData[1] == '/') || 
            sfLineData[0] == '#') continue
        // BREAK IT UP!
        parse(sfLineData, white_name, 32)
        if (equal(white_name, player_name)) {
            fclose(file)
            return 1
        }
	}
    if(file) fclose(file)
    return 0
}

public show_subnet_list(id) {
    new sfLineData[32], counter = 1
    new file = fopen(ips_list,"rt")
    console_print(id, "==== Here is Banned Subnets ====")
    while(file && !feof(file)) {
        fgets(file,sfLineData,31)
        
        if (sfLineData[0] == ';' || 
            strlen(sfLineData) < 1 || 
            (sfLineData[0] == '/' && sfLineData[1] == '/') || 
            sfLineData[0] == '#') continue
        
        replace(sfLineData, 31, "^n", "")
        console_print(id, "%d. %s", counter, sfLineData)
        counter++
	}
    console_print(id, "==== End of Banned Subnets ====")
    if(file) fclose(file)
    
    return PLUGIN_HANDLED_MAIN
}

public show_white_list(id) {
    new sfLineData[32], counter = 1
    new file = fopen(white_list,"rt")
    console_print(id, "==== Here is White List ====")
    while(file && !feof(file)) {
        fgets(file,sfLineData,31)
        
        if (sfLineData[0] == ';' || 
            strlen(sfLineData) < 1 || 
            (sfLineData[0] == '/' && sfLineData[1] == '/') || 
            sfLineData[0] == '#') continue
        
        replace(sfLineData, 31, "^n", "")
        console_print(id, "%d. %s", counter, sfLineData)
        counter++
	}
    console_print(id, "==== End of White List ====")
    if(file) fclose(file)
    
    return PLUGIN_HANDLED_MAIN
}