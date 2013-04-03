#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("Amx Subnet Ban", "2.0", "sjgunner")
	register_cvar("amx_subnet_mode", "2") //0 - off subnet checking, 1 (default) - block users with no unique ID from subnets in ips.ini, 2 - block all users from subnets in ips.ini, 3 - allow users from subnets in ips.ini only. 
	register_cvar("amx_subnet_msg", "Your subnet blocked in this server to play with old Non-Steam Patch. Please use Steam or latest client with revEmu")
	register_concmd("amx_bansubnet", "cmdAddSubnet", ADMIN_RCON, "<ip range>")
	register_concmd("amx_unbansubnet", "cmdRemoveSubnet", ADMIN_RCON, "<ip range>")
}
public client_putinserver(id)
{
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
		new mode = get_cvar_num("amx_subnet_mode")
		new allowed = 0
		get_user_ip(id,userip,16,1)
		get_user_authid(id, userauth, 31)
		get_cvar_string("amx_subnet_msg", subnetmsg, 512)
		while(read_file("addons/amxmodx/configs/ips.ini",pos++,readdata,50,len)) {
			if(readdata[0] == ';' || readdata[0] == '#') continue
			replace(readdata, 50, "/", " ")
			parse(readdata, sipaddr1, 16, sipaddr2, 16)
			switch(mode)
			{
				case 1:
				{
					if (((ip_to_number(sipaddr1) <= ip_to_number(userip)) && (ip_to_number(userip) <= ip_to_number(sipaddr2))) && !((get_user_flags(id) & ADMIN_USER)) && !((get_user_flags(id) & ADMIN_RESERVATION)) && ((containi(userauth, "LAN")!=-1) || (containi(userauth, "PENDING")!=-1)))
					server_cmd("kick #%d ^"%s^"", get_user_userid(id), subnetmsg);
				}
				case 2:
				{
					if (((ip_to_number(sipaddr1) <= ip_to_number(userip)) && (ip_to_number(userip) <= ip_to_number(sipaddr2))) && !((get_user_flags(id) & ADMIN_RCON)) && !((get_user_flags(id) & ADMIN_LEVEL_H)))
					server_cmd("kick #%d ^"%s^"", get_user_userid(id), subnetmsg);
				}
				case 3:
				{
					if ((ip_to_number(sipaddr1) <= ip_to_number(userip)) && (ip_to_number(userip) <= ip_to_number(sipaddr2)))
					allowed = 1;
				}
			}
		}
		if((mode==3) && (allowed==0) && !((get_user_flags(id) & ADMIN_USER)) && !((get_user_flags(id) & ADMIN_RESERVATION)))
		server_cmd("kick #%d ^"%s^"", get_user_userid(id), subnetmsg);
	} else {
		set_user_flags(id,read_flags("z"))
	}
}

public cmdAddSubnet(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1, arg, 31)
	write_file("addons/amxmodx/configs/ips.ini", arg, -1)
	return PLUGIN_HANDLED
}

public cmdRemoveSubnet(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32]
	read_argv(1, arg, 31)
	new len, pos
	new readdata[50]
	while(read_file("addons/amxmodx/configs/ips.ini",pos++,readdata,50,len)){
	if(readdata[0] == ';' || readdata[0] == '#') continue
	if(containi(readdata, arg)!=-1) write_file("addons/amxmodx/configs/ips.ini", "", pos-1);
	}
	return PLUGIN_HANDLED
}
	
stock ip_to_number(userip[16]) {
    new ipb1[12], ipb2[12], ipb3[12], ipb4[12], ip, nipb1, nipb2, nipb3, nipb4, uip[16]
    copy(uip, 16, userip)
    while(replace(uip, 16, ".", " ")) {}
    parse(uip, ipb1, 12, ipb2, 12, ipb3, 12, ipb4, 12)
    nipb1 = str_to_num(ipb1)
    nipb2 = str_to_num(ipb2)
    nipb3 = str_to_num(ipb3)
    nipb4 = str_to_num(ipb4)
    ip = ((((nipb1 * 256) + nipb2) * 256) + nipb3) + ((((((nipb1 * 256) + nipb2) * 256) + nipb3) * 255) + nipb4)
    return ip
}
