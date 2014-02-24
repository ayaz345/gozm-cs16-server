#include <amxmodx>
#include <colored_print>

#define PLUGIN_NAME "ChooseTeam Menu"
#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "Dimka"
#define AUTO_TEAM_JOIN_DELAY 0.1
#define TEAM_SELECT_VGUI_MENU_ID 2
#define T_SELECT_VGUI_MENU_ID 26
#define CT_SELECT_VGUI_MENU_ID 27
#define MPROP_EXITNAME  4
#define MAX_PLAYERS 25

new bool:already_changed[MAX_PLAYERS]

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
    
    register_event("HLTV", "event_newround", "a", "1=0", "2=0")

    register_message(get_user_msgid("ShowMenu"), "message_show_menu")
    register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")
    register_clcmd("chooseteam", "clcmd_changeteam")
    register_clcmd("jointeam", "clcmd_changeteam")
}

public message_show_menu(msgid, dest, id) {
    if (!should_autojoin(id))
        return PLUGIN_CONTINUE

    static team_select[] = "Team_Select"
    static ct_select[] = "#CT_Select"
    static t_select[] = "#Terrorist_Select"

    static menu_text_code[20]
    get_msg_arg_string(4, menu_text_code, charsmax(menu_text_code))
/*
    log_amx("CONTAIN: %s -> %s", menu_text_code, team_select)
    log_amx("CONTAIN: %d", contain(menu_text_code, team_select))
    log_amx("EQUAL: %s -> %s : %s", menu_text_code, ct_select, t_select)
    log_amx("EQUAL: CT-%d, T-%d", equal(menu_text_code, ct_select)?1:0, equal(menu_text_code, t_select)?1:0)
*/
    if (equal(menu_text_code, ct_select) || equal(menu_text_code, t_select)) {
        static msg_block
        msg_block = get_msg_block(msgid)
        set_msg_block(msgid, BLOCK_SET)
        set_msg_block(msgid, msg_block)
        return PLUGIN_HANDLED
    }
    else if (contain(menu_text_code, team_select) != -1) {
        static msg_block
        msg_block = get_msg_block(msgid)
        set_msg_block(msgid, BLOCK_SET)
        static param[1]
        param[0] = id
        set_task(AUTO_TEAM_JOIN_DELAY, "task_force_team_join", id, param, sizeof(param))
        set_msg_block(msgid, msg_block)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

public message_vgui_menu(msgid, dest, id) {
    new message_arg = get_msg_arg_int(1)
/*
    log_amx("VGUI: eq_team:%d-%d :%d", message_arg, TEAM_SELECT_VGUI_MENU_ID, message_arg==TEAM_SELECT_VGUI_MENU_ID?1:0)
    log_amx("VGUI: eq_t:%d-%d :%d", message_arg, T_SELECT_VGUI_MENU_ID, message_arg==T_SELECT_VGUI_MENU_ID?1:0)
    log_amx("VGUI: eq_ct:%d-%d :%d", message_arg, CT_SELECT_VGUI_MENU_ID, message_arg==CT_SELECT_VGUI_MENU_ID?1:0)
*/
    if (message_arg == T_SELECT_VGUI_MENU_ID || message_arg == CT_SELECT_VGUI_MENU_ID) {
        static msg_block
        msg_block = get_msg_block(msgid)
        set_msg_block(msgid, BLOCK_SET)
        set_msg_block(msgid, msg_block)
        return PLUGIN_HANDLED
    }
    else if (message_arg != TEAM_SELECT_VGUI_MENU_ID || !should_autojoin(id))
        return PLUGIN_CONTINUE
    
    static msg_block
    msg_block = get_msg_block(msgid)
    set_msg_block(msgid, BLOCK_SET)
    static param[1]
    param[0] = id
    set_task(AUTO_TEAM_JOIN_DELAY, "task_force_team_join", id, param, sizeof(param))
    set_msg_block(msgid, msg_block)
    return PLUGIN_HANDLED
}

bool:should_autojoin(id) {
    return (!get_user_team(id) && !task_exists(id))
}

public task_force_team_join(params[]) {
    new id = params[0]
    if (get_user_team(id))
        return
    draw_menu(id)
}

public draw_menu(id) {
    new i_Menu = menu_create("\yWelcome to GoZm Server!", "menu_handler" )
    menu_additem(i_Menu, "Join Zombies", "1")
    menu_additem(i_Menu, "Join Humans", "2")
    menu_additem(i_Menu, "-", "2")
    menu_additem(i_Menu, "-", "2")
    menu_additem(i_Menu, "-", "2")
    menu_additem(i_Menu, "Spectate", "6")
    menu_setprop(i_Menu, 4, "Close")
    menu_display(id, i_Menu, 0)
    
    return PLUGIN_HANDLED
}

public menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new s_Data[6], s_Name[64], i_Access, i_Callback
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback)
    new i_Key = str_to_num(s_Data)

    switch(i_Key)
    {
        case 1: {
            if(is_user_alive(id)) {
                colored_print(id, "^x04 ***^x01 You are in game!")
                return PLUGIN_HANDLED
            }
            engclient_cmd(id, "jointeam", "1")  // cts (humans)
            engclient_cmd(id, "joinclass", "1")  // random class
        }
        case 2: {
            if(is_user_alive(id)) {
                colored_print(id, "^x04 ***^x01 You are in game!")
                return PLUGIN_HANDLED
            }
            engclient_cmd(id, "jointeam", "2")  // ter (zombies)
            engclient_cmd(id, "joinclass", "2")  // random class
        }
        case 6: {
            if(is_user_alive(id))
                user_kill(id, 1)
            engclient_cmd(id, "jointeam", "6")  // spectate
        }
    }
    already_changed[id] = true
    
    return PLUGIN_HANDLED
}

public clcmd_changeteam(id)
{
    if (already_changed[id]) {
        colored_print(id, "^x04 ***^x01 Already changed team in this round.")
        return PLUGIN_HANDLED
    }
    else if (is_user_alive(id) && !(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_BAN)) {
        colored_print(id, "^x04 ***^x01 You cant change team when ALIVE!")
        return PLUGIN_HANDLED
    }

    draw_menu(id)
    return PLUGIN_HANDLED
}

public event_newround() {
    for (new i=0; i<MAX_PLAYERS; i++)
        already_changed[i] = false
}

public client_connect(id) {
	already_changed[id] = false
}

public client_putinserver(id) {
	already_changed[id] = false
}

public client_disconnect(id) {
    already_changed[id] = false
}