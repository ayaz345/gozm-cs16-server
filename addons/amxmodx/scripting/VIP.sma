#include <amxmodx>
#include <colored_print>

public plugin_init()
{
	register_plugin("VIP MOTD", "1.00", "Dumka")
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
	register_clcmd("say /flags","user_flag")
	register_clcmd("say_team /flags","user_flag")
}

public ShowInfo(id)
{
	colored_print(0,"^x01 Social:^x04 vk.com/go_zombie");
}

public ShowServer(id)
{
	colored_print(0,"^x01 IP adress:^x04 91.192.189.63:27018");
}

public AllServers(id)
{
	colored_print(0,"^x01 Zombie:^x04 91.192.189.63:27018");
	colored_print(0,"^x01 Public:^x04 91.192.189.63:27015");
}

public SwitchServer(id)
{
	console_cmd(id, "Connect 91.192.189.63:27015")
}

public ShowRules(id)
{
	show_motd(id, "rules.txt", "RULES")
}

public ShowBans(id)
{
	show_motd(id, "bans.txt", "BANS")
}

public user_flag(id){
	new flags = get_user_flags(id)
	colored_print(id, "Your flags are: %d, RCON: %d", flags, ADMIN_RCON)
	colored_print(id, "Do you have RCON? %s", flags & ADMIN_RCON ? "Yes." : "No.")
}