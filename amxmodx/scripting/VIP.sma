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
	register_clcmd("say /rules","ShowInfo")
	register_clcmd("say_team /rules","ShowInfo")
}

public ShowInfo(id)
{
	colored_print(0,"^x01 Forum:^x04 bbs.unet.ws/phpbb");
	colored_print(0,"^x01 Social:^x04 vk.com/bbs.unet");
}