#include <amxmodx>
#include <cs_team_changer>
#include <fakemeta>

#define VIP_FLAG ADMIN_LEVEL_H
#define ADMIN_FLAG ADMIN_BAN
#define OFFSET_CSMENUCODE	205
#define MPROP_BACKNAME  2
#define MPROP_NEXTNAME  3
#define MPROP_EXITNAME  4

new GOZM_CMD[] = "gozm_menu"

public plugin_init()
{
    register_plugin("GoZm Menu", "1.0", "Dimka")
    register_clcmd(GOZM_CMD, "mainMenu", _, "GoZm Menu")
}

public mainMenu(id)
{
    set_pdata_int(id, OFFSET_CSMENUCODE, 0)  // prevent from showing CS std menu

    new i_Menu = menu_create("\yGoZm Menu", "menu_handler" )

    menu_additem(i_Menu, "Re-Pick Weapons", "1")
    menu_additem(i_Menu, "Nominate Map", "2")
    menu_additem(i_Menu, "Ban", "3", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "Mute", "4", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "History", "5", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "BanList", "6")
    menu_additem(i_Menu, "Rank", "7")
    menu_additem(i_Menu, "Top Players", "8")
    menu_additem(i_Menu, "Statistics", "9")
    menu_additem(i_Menu, "UnBan", "10", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "UnMute", "11", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "Hats", "12", VIP_FLAG|ADMIN_FLAG)
    menu_additem(i_Menu, "List Players", "13")
    menu_additem(i_Menu, "Damage", "14")
    menu_additem(i_Menu, "Time", "15")
    menu_additem(i_Menu, "Nextmap", "16")
    menu_additem(i_Menu, "Rules", "17")
    menu_additem(i_Menu, "Vips", "18")
    menu_additem(i_Menu, "Info", "19")
    menu_additem(i_Menu, "Join Spectators", "20")
    menu_additem(i_Menu, "Join Game", "21")
    
    menu_setprop(i_Menu, 2, "Back")
    menu_setprop(i_Menu, 3, "Next")
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
        case 1:
            client_cmd(id, "say /guns")
        case 2: 
            client_cmd(id, "say nominate")
        case 3: 
            client_cmd(id, "say /ban")
        case 4: 
            client_cmd(id, "say /mute")
        case 5: 
            client_cmd(id, "amx_banhistorymenu")
        case 6: 
            client_cmd(id, "say /bans")
        case 7: 
            client_cmd(id, "say /rank")
        case 8: 
            client_cmd(id, "say /top")
        case 9: 
            client_cmd(id, "say /stats")
        case 10:
            client_cmd(id, "amx_unban_by_name")
        case 11: 
            client_cmd(id, "say /speak")
        case 12: 
            client_cmd(id, "say /hats")
        case 13:
        {
            client_cmd(id, "amx_who")
            client_print(id, print_chat, "See Result in Console")
        }
        case 14: 
            client_cmd(id, "say /me")
        case 15: 
            client_cmd(id, "say thetime")
        case 16: 
            client_cmd(id, "say nextmap")
        case 17: 
            client_cmd(id, "say /rules")
        case 18: 
            client_cmd(id, "say /vips")
        case 19:
        {
            client_print(id, print_chat, "3om6u cepBep (x_x(O_o)x_x) Go Zombie !!!")
            client_print(id, print_chat, "77.220.185.29:27051")
            client_print(id, print_chat, "vk.com/go_zombie")
        }
        case 20:
        {
            if(!is_user_alive(id))
                cs_set_team(id, TEAM_SPECTATOR)
            else if(get_user_flags(id) & VIP_FLAG || get_user_flags(id) & ADMIN_FLAG)
            {
                user_silentkill(id)
                cs_set_team(id, TEAM_SPECTATOR)
            }
        }
        case 21:
        {
            if(!is_user_alive(id))
                cs_set_team(id, TEAM_CT)
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}
