#include <amxmodx>
//#include <amxmisc>
//#include <engine>

// Counter for the SayText event.
new count[32][32]

public catch_say(id)
{
	new reciever = read_data(0) //Reads the ID of the message recipient
	new sender = read_data(1)   //Reads the ID of the sender of the message
	new message[151]            //Variable for the message
	new channel[151]
	new sender_name[32]

	read_data(2,channel,150)
	read_data(4,message,150)
   	get_user_name(sender, sender_name, 31)
	
	// DEBUG. 
	// console_print(0, "DEBUG MESSAGE: %s", message)
	// console_print(0, "DEBUG channel: %s", channel)
	// console_print(0, "DEBUG sender: %s, %i", sender_name, sender)
	// console_print(0, "DEBUG receiver: %i", reciever)
   
   	//With the SayText event, the message is sent to the person who sent it last.
   	//It's sent to everyone else before the sender recieves it.

	// Keeps count of who recieved the message
   	count[sender][reciever] = 1          
	// If current SayText message is the last then...
   	if (sender == reciever)
	{      
      	new player_count = get_playersnum()  //Gets the number of players on the server
      	new players[32] //Player IDs
      	get_players(players, player_count, "c")

      	for (new i = 0; i < player_count; i++) 
		{  
			// If the player did not recieve the message then...
            if (count[sender][players[i]] != 1)
			{              
               	message_begin(MSG_ONE, get_user_msgid("SayText"),{0,0,0},players[i])
               	// Appends the ID of the sender to the message, so the engine knows what color to make the name.
               	write_byte(sender)
               	// Appends the message to the message (depending on the mod).
                write_string(channel)
                write_string(sender_name)
                write_string(message)
                message_end()
            }
            count[sender][players[i]] = 0  //Set everyone's counter to 0 so it's ready for the next SayText
      	}
   	}
	
	// LOGGING MESSAGE
//	log_to_file("CHAT.log", "%s: %s", sender_name, message)
	
   	return PLUGIN_CONTINUE
}

public plugin_init(){
   register_plugin("AdminListen","2.3x","/dev/ urandom")
   register_event("SayText","catch_say","b")
   return PLUGIN_CONTINUE
}