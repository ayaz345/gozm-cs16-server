#include <amxmodx>
#include <colored_print>

new zombie_server[] = "77.220.185.29:27051"
new zombie_group[] = "vk.com/go_zombie"
new public_server[] = "77.220.185.29:27051"

public plugin_init()
{
    register_plugin("INFO MOTD'S", "1.0", "Dumka")
    register_clcmd("say /vip","ShowInfo")
    register_clcmd("say_team /vip","ShowInfo")
    register_clcmd("say /admin","ShowInfo")
    register_clcmd("say_team /admin","ShowInfo")
    register_clcmd("say /vips","ShowInfo")
    register_clcmd("say_team /vips","ShowInfo")
    register_clcmd("say /server","ShowServer")
    register_clcmd("say_team /server","ShowServer")
    register_clcmd("say /servers","AllServers")
    register_clcmd("say_team /servers","AllServers")
    register_clcmd("say /public","SwitchServer")
    register_clcmd("say_team /public","SwitchServer")
    register_clcmd("say /rules","ShowRules")
    register_clcmd("say_team /rules","ShowRules")
    register_clcmd("say /bans","ShowBans")
    register_clcmd("say_team /bans","ShowBans")
    register_clcmd("say /lm","ShowClassic")
    register_clcmd("say_team /lm","ShowClassic")
    register_clcmd("say /shop","ShowClassic")
    register_clcmd("say_team /shop","ShowClassic")
    register_clcmd("say /coins","ShowClassic")
    register_clcmd("say_team /coins","ShowClassic")
    register_clcmd("say /bank","ShowClassic")
    register_clcmd("say_team /bank","ShowClassic")
    register_clcmd("say /class","ShowClassic")
    register_clcmd("say_team /class","ShowClassic")
    register_clcmd("say /history","ShowBanHistory")
    register_clcmd("say_team /history","ShowBanHistory")
}

public ShowInfo(id)
{
	colored_print(0,"^x01 Social:^x04 %s", zombie_group);
}

public ShowServer(id)
{
	colored_print(0,"^x01 IP adress:^x04 %s", zombie_server);
}

public AllServers(id)
{
	colored_print(0,"^x01 Zombie:^x04 %s", zombie_server);
//	colored_print(0,"^x01 Public:^x04 %s", public_server);
}

public SwitchServer(id)
{
	console_cmd(id, "Connect %s", public_server)
}

public ShowRules(id)
{
	show_motd(id, "rules.txt", "RULES")
}

public ShowBans(id)
{
	show_motd(id, "bans.txt", "BANS")
}

public ShowClassic(id)
{
	colored_print(id,"^x01 This is^x04 classic^x01 zombie server");
}

public ShowBanHistory(id)
{
    client_cmd(id, "amx_banhistorymenu")
}