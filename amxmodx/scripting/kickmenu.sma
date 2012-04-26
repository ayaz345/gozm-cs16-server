#include <amxmodx>
//#include <amxmisc>
#include <colored_print>

new playerName[32]

public plugin_init()
{
  register_plugin("kickmenu","0.1","Dimka")
  register_clcmd("say /kickmenu","SayIt" )
  register_clcmd("say_team /kickmenu","SayIt" )
}

public SayIt(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		get_user_name( id, playerName, 31 )
		log_amx("[KICKMENU] %s opens menu.", playerName)
		client_cmd(id, "amx_kickmenu")
	}
	
	else
	{
		colored_print(id,"^x01Only ^x04VIP^x01 can use ^x03/kickmenu^x01!")
	}
	return 0
}