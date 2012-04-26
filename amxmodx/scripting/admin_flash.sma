#include <amxmodx>
#include <amxmisc>

new gMsgScreenFade 

public admin_flash(id,level,cid) { 
   if (!cmd_access(id,level,cid,2)) { 
      return PLUGIN_HANDLED 
   } 

   new victim[32] 
   read_argv(1,victim,31) 
//   new arg2[32]
//   read_argv(2,arg2,31)
//   new number=strtonum(arg2)
//   if (number==0) number=1

   if (victim[0]=='@') { 
      new team[32], inum 
      get_players(team,inum,"e",victim[1]) 
      if (inum==0) { 
         console_print(id,"[AMX] Нету клиента для использывания команды.") 
         return PLUGIN_HANDLED 
      } 
      for (new i=0;i<inum;++i) { 
         Flash(team[i]) 
         client_print(id,print_chat,"[AMX] Вы ослепили всех =D %s's.",victim[1]) 
         //client_print(id,print_chat,"[AMX] Ты ослепил всех %s's за %i секунду.",victim[1],number) 
      } 
   } 
   else if (victim[0]=='*') { 
      new all[32], inum 
      get_players(all,inum) 
      for (new i=0;i<inum;++i) { 
         Flash(all[i])
         client_print(id,print_chat,"[AMX] Вы олепили каждого")
         //client_print(id,print_chat,"[AMX] Вы ослеплены каждую  %i секунду :D.",number) 
      } 
   } 
   else { 
      new player = cmd_target(id,victim,0) 
      new playername[32] 
      get_user_name(player,playername,31) 

      if (!player) {  
         return PLUGIN_HANDLED
      } 
      Flash(player)
      client_print(id,print_chat,"[AMX] Вы ослепили %s.",playername)
      //client_print(id,print_chat,"[AMX] Вы ослеплили %s на %i секунду.",playername,number) 
   } 

   return PLUGIN_HANDLED 
} 

public Flash(id) {
	message_begin(MSG_ONE,gMsgScreenFade,{0,0,0},id) 
	write_short( 1<<15 ) 
	write_short( 1<<10 )
	write_short( 1<<12 )
	write_byte( 255 ) 
	write_byte( 255 ) 
	write_byte( 255 ) 
	write_byte( 255 ) 
	message_end()
	emit_sound(id,CHAN_BODY, "weapons/flashbang-2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
}

public plugin_init() { 
   register_plugin("Admin Flash","1.0","AssKicR") 
   register_concmd("amx_flash","admin_flash",ADMIN_LEVEL_A,"< Nick, UniqueID, #userid, @TEAM, or * > flashes selected client(s)") 
   gMsgScreenFade = get_user_msgid("ScreenFade") 
   return PLUGIN_CONTINUE 
}

public plugin_precache()
{
    // FLASHBANG SOUND
    precache_sound( "weapons/flashbang-2.wav" )
}