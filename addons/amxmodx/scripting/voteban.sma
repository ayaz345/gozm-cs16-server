#include <amxmodx>
#include <amxmisc>
#include <colored_print>

#define MAX_players 32
#define MAX_menudata 1024

new ga_PlayerName[MAX_players][32]
new ga_PlayerAuthID[MAX_players][35]
new ga_PlayerID[MAX_players]
new ga_PlayerIP[MAX_players][16]
new gi_VoteStarter
new gi_MenuPosition
new gi_Sellection
new gi_TotalPlayers
new i
//pcvars
new gi_BanTime
new gi_BanType

new ban_reason[128]

public plugin_init()
{
    register_plugin("voteban menu","1.2","hjvl")
    register_clcmd("say","SayIt" )
    register_clcmd("say_team","SayIt" )
    register_clcmd("VIP_REASON", "setCustomBanReason")
    register_menucmd(register_menuid("ChoosePlayer"), 1023, "ChooseMenu")

    gi_BanTime=register_cvar("amxx_voteban_bantime","30")
    gi_BanType=register_cvar("amxx_voteban_type","1")
}

public SayIt(id)
{
    static say_args[11]
    read_args(say_args, 10)
    remove_quotes(say_args)

    if(say_args[0] == '/' && containi(say_args, "voteban") != -1)
    {
        if(get_user_flags(id) & ADMIN_BAN) {
            colored_print(id,"^x04***^x01 Use AdminMenu!")
            return PLUGIN_HANDLED_MAIN
        }
        if(get_user_flags(id) & ADMIN_LEVEL_H) {
            colored_print(id,"^x04***^x01 Use^x04 /ban")
            return PLUGIN_HANDLED_MAIN
        }
        else {
            colored_print(id,"^x04***^x01 Only VIP-players can use^x04 /voteban")
            return PLUGIN_HANDLED_MAIN
        }
        
    }
    
    else if(say_args[0] == '/' && equali(say_args, "/ban")) {
        if(get_user_flags(id) & ADMIN_BAN) {
            colored_print(id,"^x04***^x01 Use AdminMenu!")
            return PLUGIN_HANDLED_MAIN
        }
        if(get_user_flags(id) & ADMIN_LEVEL_H) {
            get_players( ga_PlayerID, gi_TotalPlayers )
            for(i=0; i<gi_TotalPlayers; i++)
            {
                new TempID = ga_PlayerID[i]

                if(TempID == id)
                    gi_VoteStarter=i

                get_user_name( TempID, ga_PlayerName[i], 31 )
                get_user_authid( TempID, ga_PlayerAuthID[i], 34 )
                get_user_ip( TempID, ga_PlayerIP[i], 15, 1 )
            }

            gi_MenuPosition = 0
            ShowPlayerMenu(id)
            return PLUGIN_HANDLED_MAIN
        }
        else
        {
            colored_print(id,"^x04***^x01 Only VIP-players can use ^x04/ban")
            return PLUGIN_HANDLED_MAIN
        }
    }

    return PLUGIN_CONTINUE
}

public ShowPlayerMenu(id)
{
    if(gi_MenuPosition < 0)  
        return

    new start = gi_MenuPosition * 8
    if(start >= gi_TotalPlayers)
            start = gi_MenuPosition

    new end = start + 8
    if(end > gi_TotalPlayers)
            end = gi_TotalPlayers

    static menubody[512]	
    new len = format(menubody, 511, "Players to BAN: ^n^n")

    static name[32]

    new b = 0, i
    new keys = MENU_KEY_0

    for(new a = start; a < end; ++a)
    {
        i = ga_PlayerID[a]
        get_user_name(i, name, 31)

        if( i == id || get_user_flags(i) & ADMIN_LEVEL_H)
        {
            ++b
            len += format(menubody[len], 511 - len, "\d#  %s\w^n", name)
        }
        else
        {
            keys |= (1<<b)
            len += format(menubody[len], 511 - len, "%d. %s\w^n", ++b, name)
        }
    }

    if(end != gi_TotalPlayers) 
    {
            format(menubody[len], 511 - len, "^n9. %s...^n0. %s", "Next", gi_MenuPosition ? "Back" : "Exit")
            keys |= MENU_KEY_9
    }
    else
        format(menubody[len], 511-len, "^n0. %s", gi_MenuPosition ? "Back" : "Exit")

    show_menu(id, keys, menubody, 20, "ChoosePlayer")
}

public ChooseMenu(id, key)
{
  switch(key)
  {
    case 8:
    {
      gi_MenuPosition=gi_MenuPosition+8
      ShowPlayerMenu(id)
    }
    case 9:
    {
      if(gi_MenuPosition>=8)
      {
        gi_MenuPosition=gi_MenuPosition-8
        ShowPlayerMenu(id)
      }
      else
        return 0
    }
    default:
    {
        gi_Sellection=gi_MenuPosition+key
        log_amx("[VB] preparing to Messagemode...")
        client_cmd(ga_PlayerID[gi_VoteStarter], "messagemode VIP_REASON")
    }
  }
  return PLUGIN_HANDLED
}

public setCustomBanReason(id,level,cid)
{
    new szReason[128]
    read_argv(1, szReason, 127)
    copy(ban_reason, 127, szReason)
    if(strlen(ban_reason) == 0) {
        log_amx("[VB] unknown ban reason")
        ban_reason = "unknown"
    }
    
    log_amx("[VB] Victim name: %s, Victim ip: %s", ga_PlayerName[gi_Sellection], ga_PlayerIP[gi_Sellection])
    log_amx("[VB] VIP reason: %s, VIP name: %s", ban_reason, ga_PlayerName[gi_VoteStarter])
    log_amx("[VB] gi_VoteStarter: %d, func_id: %d", gi_VoteStarter, id)
    ActualBan(gi_Sellection, gi_VoteStarter)
    set_task(5.0, "additionalBan", id)

    return PLUGIN_HANDLED
}

public additionalBan() {
    server_cmd("addip %d %s", get_pcvar_num(gi_BanTime), ga_PlayerIP[gi_Sellection])
    log_amx("[VB] addIp: %s", ga_PlayerIP[gi_Sellection])
}

public ActualBan(Selected,VBStarter)
{
    new Type = get_pcvar_num(gi_BanType) 
    switch(Type)
    {
        case 1:
            server_cmd("addip %d %s", get_pcvar_num(gi_BanTime), ga_PlayerIP[Selected])
        case 2:
        {
            log_amx("[VB] client_command: amx_ban %d %s %s", ga_PlayerIP[Selected], ga_PlayerName[Selected], ban_reason)
            client_cmd(ga_PlayerID[VBStarter], "amx_ban %d %s %s", get_pcvar_num(gi_BanTime), ga_PlayerIP[Selected], ban_reason)
        }
        default:
            server_cmd("banid %d %s kick", get_pcvar_num(gi_BanTime), ga_PlayerAuthID[Selected])
    }
    colored_print(0,"^x03%s ^x01is BANNED by %s! Reason: %s.", ga_PlayerName[gi_Sellection], ga_PlayerName[gi_VoteStarter], ban_reason)
    return 0
}