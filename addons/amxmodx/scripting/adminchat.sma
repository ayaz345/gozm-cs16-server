#include <amxmodx>
#include <amxmisc>
#include <colored_print>

new g_AdminChatFlag = ADMIN_CHAT;

public plugin_init()
{
	new admin_chat_id

	register_plugin("Admin Chat", AMXX_VERSION_STR, "AMXX Dev Team")
	register_dictionary("adminchat.txt")
	register_dictionary("common.txt")
	register_clcmd("say_team", "cmdSayAdmin", 0, "@<text> - displays message to admins")
	admin_chat_id = register_concmd("amx_chat", "cmdChat", ADMIN_CHAT, "<message> - sends message to admins")
	
	new str[1]
	get_concmd(admin_chat_id, str, 0, g_AdminChatFlag, str, 0, -1)
}

public cmdSayAdmin(id)
{
	new said[2]
	read_argv(1, said, 1)
	
	if (said[0] != '@')
		return PLUGIN_CONTINUE
		
	if (!is_user_admin(id))
		return PLUGIN_CONTINUE
	
	new message[192], name[32], authid[32], userid
	new players[32], inum
	
	read_args(message, 191)
	remove_quotes(message)
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	userid = get_user_userid(id)
	
	log_amx("Chat: ^"%s<%d><%s><>^" chat ^"%s^"", name, userid, authid, message[1])
	log_message("^"%s<%d><%s><>^" triggered ^"amx_chat^" (text ^"%s^")", name, userid, authid, message[1])
	
	format(message, 191, "^x04 %s^x03 %s^x01 : %s", "*VIP*", name, message[1])
	
	get_players(players, inum)
	
	for (new i = 0; i < inum; ++i)
	{
		// dont print the message to the client that used the cmd if he has ADMIN_CHAT to avoid double printing
		if (players[i] != id && (get_user_flags(players[i]) & g_AdminChatFlag || get_user_flags(players[i]) & ADMIN_RCON))
			colored_print(players[i], "%s", message)
	}
	
	colored_print(id, "%s", message)
	
	return PLUGIN_HANDLED
}

public cmdChat(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new message[192], name[32], players[32], inum, authid[32], userid
	
	read_args(message, 191)
	remove_quotes(message)
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	userid = get_user_userid(id)
	get_players(players, inum)
	
	log_amx("Chat: ^"%s<%d><%s><>^" chat ^"%s^"", name, userid, authid, message)
	log_message("^"%s<%d><%s><>^" triggered ^"amx_chat^" (text ^"%s^")", name, userid, authid, message)
	
	format(message, 191, "^x04 %s^x03 %s^x01 : %s", "VIP", name, message)
	console_print(id, "%s", message)
	
	for (new i = 0; i < inum; ++i)
	{
		if (access(players[i], g_AdminChatFlag) || get_user_flags(players[i]) & ADMIN_RCON)
			colored_print(players[i], "%s", message)
	}
	
	return PLUGIN_HANDLED
}
