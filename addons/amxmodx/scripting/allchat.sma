#include <amxmodx>

#define VERSION "1.1"

new COLCHAR[3][2] = { "^x03"/*team col*/, "^x04"/*green*/, "^x01"/*white*/ }

//vars to check if message has already been duplicated
new alv_sndr, alv_str2[26], alv_str4[101]
new msg[200]

public plugin_init( )
{
	register_plugin("All Chat",VERSION,"Ian Cammarata")
	register_message( get_user_msgid("SayText"), "col_changer" )
	return PLUGIN_CONTINUE
}

public col_changer( msg_id, msg_dest, rcvr )
{
	new str2[26]
	get_msg_arg_string( 2, str2, 25 )
	if( equal( str2, "#Cstrike_Chat", 13 ) )
	{
		new str3[22]
		get_msg_arg_string( 3, str3, 21 )
		
		if( !strlen( str3 ) )
		{
			new str4[101]
			get_msg_arg_string( 4, str4, 100 )
			new sndr = get_msg_arg_int( 1 )
			
			new bool:is_team_msg = !bool:equal( str2, "#Cstrike_Chat_All", 17 )
			
			new sndr_team = get_user_team( sndr )
			new bool:is_sndr_spec = !bool:( 0 < sndr_team < 3 )
			
			new bool:same_as_last = bool:( alv_sndr == sndr && equal( alv_str2, str2 ) && equal( alv_str4, str4) )
			
			if( !same_as_last )
			{//Duplicate message once
				//Don't duplicate if it's a spectator team message
				new flags[5], team[10]
				if( is_user_alive( sndr ) ) flags = "bch"
				else flags = "ach"
				
				if( is_team_msg )
				{
					add( flags[strlen( flags )], 4, "e" )
					if( sndr_team == 1 ) team = "TERRORIST"
					else team = "CT"
				}
				
				new players[32], num
				get_players( players, num, flags, team )
				buildmsg( sndr, is_sndr_spec, is_team_msg, sndr_team, 0, 2, str4 ) //normal colors
				
				for( new i=0; i < num; i++ )
				{
                    if(is_user_connected(players[i]))
                    {
                        message_begin( MSG_ONE, get_user_msgid( "SayText" ), _, players[i] )
                        write_byte( sndr )
                        write_string( msg )
                        message_end()
                    }
				}
					
				alv_sndr = sndr
				alv_str2 = str2
				alv_str4 = str4
				if( task_exists( 411 ) ) remove_task( 411 )
				set_task( 0.1, "task_clear_antiloop_vars", 411 )		
			}
		}
	}
	return PLUGIN_CONTINUE
}

public buildmsg( sndr, is_sndr_spec, is_team_msg, sndr_team, namecol, msgcol, str4[ ] )
{
	new sndr_name[33]
	get_user_name( sndr, sndr_name, 32 )
	
	new prefix[30] = "^x01"
	if( is_sndr_spec ) prefix = "^x01*SPEC* "
	else if( !is_user_alive( sndr ) ) prefix = "^x01*DEAD* "
		
	if( is_team_msg )
	{
		if( is_sndr_spec ) prefix = "^x01(Spectator) "
		else if( sndr_team == 1 ) add( prefix[strlen(prefix)-1], 29, "(Terrorist) " )
		else if( sndr_team == 2 ) add( prefix[strlen(prefix)-1], 29, "(Counter-Terrorist) " )
	}
	
	format( msg, 199, "%s%s%s :  %s%s",	strlen( prefix ) > 1 ? prefix : "", COLCHAR[namecol], sndr_name, COLCHAR[msgcol], str4 )
	
	// FOR LOGGING
	new cur_date[3], logfile[13]
	get_time("%d", cur_date, 2)
	format(logfile, 12, "chat_%s.log", cur_date)
	log_to_file(logfile, "%s: %s", sndr_name, str4)
	
	return PLUGIN_HANDLED
}

public task_clear_antiloop_vars( )
{
	alv_sndr = 0
	alv_str2 = ""
	alv_str4 = ""
	return PLUGIN_HANDLED
}