#include <amxmodx>
#include <amxmisc>
#include <colored_print>

#define MAX_players 32
#define MAX_menudata 1024

new ga_PlayerName[MAX_players][32]
new ga_PlayerAuthID[MAX_players][35]
new ga_PlayerID[MAX_players]
new ga_PlayerIP[MAX_players][16]
new ga_MenuData[MAX_menudata]
new ga_Choice[2]
new gi_VoteStarter
new gi_MenuPosition
new gi_Sellection
new gi_TotalPlayers
new i
//pcvars
new gi_BanTime
new gi_BanType
new invul[MAX_players][16] 

new gi_LastTime[MAX_players]
new gi_DelayTime
new LastTime

public plugin_init()
{
  register_plugin("voteban menu","1.2","hjvl")
  register_clcmd("say /voteban","SayIt" )
  register_clcmd("say_team /voteban","SayIt" )
  register_menucmd(register_menuid("ChoosePlayer"), 1023, "ChooseMenu")
  register_menucmd(register_menuid("VoteMenu"), 1023, "CountVotes")

  gi_BanTime=register_cvar("amxx_voteban_bantime","30")
  gi_BanType=register_cvar("amxx_voteban_type","1")
  gi_DelayTime=register_cvar("amxx_voteban_delaytime","300")
  LastTime = 0
  
  for (i=0; i<MAX_players; i++)
	gi_LastTime[i] = 0
}

public SayIt(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		new Elapsed = get_systime(0) - LastTime
		new Delay = 16

		if(Delay > Elapsed)
		{
			colored_print(id,"^x04 ***^x01 Voting in progress!")
			return 0
		}
	
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
		return 0
	}
	
	else
	{
		colored_print(id,"^x04***^x01 Only VIP-players can use ^x04/voteban^x01!")
		return 0
	}
	return 0
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
		LastTime = get_systime(0)
		log_amx("[VB] chosen.ip: %s", ga_PlayerIP[gi_Sellection])
		log_amx("[VB] chosen.name: %s", ga_PlayerName[gi_Sellection])
		
		if (containi( invul[gi_Sellection], ga_PlayerIP[gi_Sellection] ) != -1)  
		{
			new Elapsed=get_systime(0) - gi_LastTime[gi_Sellection]
			new Delay=get_pcvar_num(gi_DelayTime)
			
			if( Delay > Elapsed)
			{
				new seconds = Delay - Elapsed
				colored_print(id, "^x04 ***^x01 This player is^x03 SAVED^x01 for^x04 %d^x01 seconds", seconds)
				return 0
			}
		}
/*	  
		colored_print(id, "^x04 ***^x01 %s", invul[gi_Sellection])
		colored_print(id, "^x04 ***^x01 %s", ga_PlayerAuthID[gi_Sellection])
		colored_print(id, "^x04 ***^x01 Last %d", gi_LastTime[gi_Sellection])
		colored_print(id, "^x04 ***^x01 Elapsed %d", get_systime(0) - gi_LastTime[gi_Sellection])
*/			
		run_vote()
		return 0
    }
  }
  return PLUGIN_HANDLED
}

public run_vote()
{
  log_amx("[VB] Voteban starter %s against %s %s", ga_PlayerName[gi_VoteStarter], ga_PlayerName[gi_Sellection], ga_PlayerAuthID[gi_Sellection])
  format(ga_MenuData,(MAX_menudata-1),"Ban \r%s \wfor \y%d \wminutes?^n^n1. Yup!^n2. No!!!",ga_PlayerName[gi_Sellection], get_pcvar_num(gi_BanTime))
  ga_Choice[0] = 0
  ga_Choice[1] = 0
  show_menu( 0, (1<<0)|(1<<1), ga_MenuData, 15, "VoteMenu" )
  set_task(15.0,"outcom")
  return 0
}

public CountVotes(id, key)
{
//	if(key>2)
	++ga_Choice[key]
	return PLUGIN_HANDLED
}

public outcom()
{
	new Now=get_systime(0)
	gi_LastTime[gi_Sellection] = Now
		
	if( ga_Choice[0] > ga_Choice[1] )
	{
		colored_print(0,"^x03%s ^x01is BANNED for ^x04%d ^x01minutes!   >>     ^x03%d^x01 for   |   ^x03%d^x01 against   ", ga_PlayerName[gi_Sellection], get_pcvar_num(gi_BanTime), ga_Choice[0], ga_Choice[1])      
		log_amx("[VB] BANNED: %s, STARTER: %s", ga_PlayerName[gi_Sellection], ga_PlayerName[gi_VoteStarter])
		ActualBan(gi_Sellection,gi_VoteStarter)
	}
	else
	{
		colored_print(0,"^x04 Lucky guy!  ^x01 |  ^x03 %d^x04 for  ^x01|  ^x03 %d^x04 against  ^x01 |", ga_Choice[0], ga_Choice[1])
		log_amx("[VB] The voteban dit not sucseed.")
		log_amx("[VB] Invul IP: %s", invul[gi_Sellection])
		invul[gi_Sellection] = ga_PlayerIP[gi_Sellection]
	}
	return 0
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
			new param[1], flags
			param[0] = Selected
			flags = get_user_flags(Selected)
			// ADMIN_RCON flag doesn't work here
			if(flags)
			{
				server_cmd("amx_ban %d %s VIP %s", get_pcvar_num(gi_BanTime), ga_PlayerIP[Selected], ga_PlayerName[VBStarter])
				log_amx("[VB] ban.ip: %s, ban.name: %s", ga_PlayerIP[Selected], ga_PlayerName[Selected])
				log_amx("[VB] flags: %d, ADMIN_USER: %d, ADMIN_RCON: %d", flags, ADMIN_USER, ADMIN_RCON)
				set_task(10.0, "double_ban", Selected, param, 1)
			}
		}
		default:
			server_cmd("banid %d %s kick", get_pcvar_num(gi_BanTime), ga_PlayerAuthID[Selected])
	}
	return 0 
}

public double_ban(param[]) {
	new id = param[0]
	log_amx("[VB] doubled IP added: %s", ga_PlayerIP[id])
	server_cmd("addip %d %s", get_pcvar_num(gi_BanTime), ga_PlayerIP[id])
}