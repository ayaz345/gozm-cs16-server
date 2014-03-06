#include <amxmodx>

#define PLUGIN_NAME "Auto Join on Connect"
#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "VEN"

#define IMMUNITY_ACCESS_LEVEL ADMIN_IMMUNITY

#define AUTO_TEAM_JOIN_DELAY 0.1

#define TEAM_SELECT_VGUI_MENU_ID 2

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    register_message(get_user_msgid("ShowMenu"), "message_show_menu")
    register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")

    register_clcmd("chooseteam", "clcmd_changeteam")
    register_clcmd("jointeam", "clcmd_changeteam")
}

public message_show_menu(msgid, dest, id) {
	if (!should_autojoin(id))
		return PLUGIN_CONTINUE

	static team_select[] = "#Team_Select"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE

	set_force_team_join_task(id, msgid)

	return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id) {
	if (get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID || !should_autojoin(id))
		return PLUGIN_CONTINUE

	set_force_team_join_task(id, msgid)

	return PLUGIN_HANDLED
}

bool:should_autojoin(id) {
	return (!get_user_team(id) && !task_exists(id))
}

set_force_team_join_task(id, menu_msgid) {
	static param_menu_msgid[2]
	param_menu_msgid[0] = menu_msgid
	set_task(AUTO_TEAM_JOIN_DELAY, "task_force_team_join", id, param_menu_msgid, sizeof param_menu_msgid)
}

public task_force_team_join(menu_msgid[], id) {
	if (get_user_team(id))
		return

	force_team_join(id, menu_msgid[0])
}

stock force_team_join(id, menu_msgid) {
    static jointeam[] = "jointeam"
    static joinclass[] = "joinclass"
    static msg_block
    msg_block = get_msg_block(menu_msgid)
    set_msg_block(menu_msgid, BLOCK_SET)
    engclient_cmd(id, jointeam, "5")
    engclient_cmd(id, joinclass, "5")
    set_msg_block(menu_msgid, msg_block)
}

public clcmd_changeteam(id) {
    client_cmd(id, "gozm_menu")
    return PLUGIN_HANDLED
}