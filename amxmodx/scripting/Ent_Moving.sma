#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>
#include <fakemeta>
#include <cellarray>

#define MAXENTS 1365
#define SAVEPATH "addons/amxmodx/data/entsaves"

new Array:entvars [MAXENTS]
new weaponmode [33]

public plugin_init(){
	register_plugin("Ent Moving","1.7","Ingram")
	
	register_clcmd("+moveent","startmoving",ADMIN_LEVEL_C," - Begin moving an ent")
	register_clcmd("+moveentaim","startmoving",ADMIN_LEVEL_C," - Begin moving an ent by aiming")
	register_clcmd("+copyent","startmoving",ADMIN_LEVEL_C," - Copy an ent and begin moving")
	register_clcmd("+copyentaim","startmoving",ADMIN_LEVEL_C," - Copy an ent and begin moving by aiming")
	register_clcmd("-moveent","stopmoving")
	register_clcmd("-moveentaim","stopmoving")
	register_clcmd("-copyent","stopmoving")
	register_clcmd("-copyentaim","stopmoving")
	
	register_clcmd("amx_ent_move","startmoving",ADMIN_LEVEL_C," [classname/ent] - For moving mutliple ents or moving by number")
	register_clcmd("amx_ent_moveaim","startmoving",ADMIN_LEVEL_C," [classname/ent] - For moving mutliple ents or moving by number by aiming")
	register_clcmd("amx_ent_copy","startmoving",ADMIN_LEVEL_C," [classname/ent] - For copying mutliple ents or copying by number")
	register_clcmd("amx_ent_copyaim","startmoving",ADMIN_LEVEL_C," [classname/ent] - For copying mutliple ents or copying by number by aiming")
	register_clcmd("amx_ent_stop","stopmoving",ADMIN_LEVEL_C," - Stop moving all ents")
	
	register_concmd("amx_ent_remove","removeent",ADMIN_LEVEL_C," [classname/ent] - Deletes an ent")
	register_concmd("amx_ent_rotate","rotate",ADMIN_LEVEL_C," <x> <y> <z> [classname/ent] - Rotates an ent")
	register_concmd("amx_ent_stack","stack",ADMIN_LEVEL_C," <number> <x offset> <y offset> <z offset> [classname/ent]- Make a pile of ents")
	register_concmd("amx_ent_use","forceuse",ADMIN_LEVEL_C," [classname/ent] [player] - Forces an ent to be used with you or a player")
	register_concmd("amx_ent_droptofloor","droptofloor",ADMIN_LEVEL_C," [classname/ent] - Drops an ent to the floor (has to be near floor)")
	register_concmd("amx_ent_originallocation","originallocation",ADMIN_LEVEL_C," [classname/ent] - Returns an ent to its original location")
	register_concmd("amx_ent_render","setrendering",ADMIN_LEVEL_C," <mode> <r> <g> <b> <amt> <fx> [classname/ent] - For rendering an ent (-1 to ignore)")
	
	register_clcmd("amx_ent_weaponmode","weapon",ADMIN_LEVEL_C," - toggles weapon moving mode on yourself")
	
	register_concmd("amx_ent_createplayer","create",ADMIN_LEVEL_C," <name> <classname> - Create an ent on someone")
	register_concmd("amx_ent_createorigin","create",ADMIN_LEVEL_C," <y> <z> <x> <classname> - Create an ent at a location")
	register_concmd("amx_ent_createworld","createworld",ADMIN_LEVEL_C," <speed> <x> <y> <z> - Create a rotating world")
	register_concmd("amx_ent_removeworld","deleteworlds",ADMIN_LEVEL_C," - Removes all rotating worlds")
	
	register_concmd("amx_ent_info","info",ADMIN_LEVEL_C," [classname/ent] - Dump entity keys to your console")
	register_concmd("amx_ent_setkey","setvar",ADMIN_LEVEL_C," [classname/ent] <key> ^"<value>^" - Set entity variable (Use Quotes)")
	
	register_clcmd("amx_ent_load","loadfile",ADMIN_LEVEL_C," <savename> - Loads a saved file")
	register_clcmd("amx_ent_save","savefile",ADMIN_LEVEL_C," <savename> - Saves selected ents in file")
	register_clcmd("amx_ent_saveent","saveent",ADMIN_LEVEL_C," [classname/ent] - Selects an ent to save")
	
	register_clcmd("amx_ent_noclip","noclip",ADMIN_LEVEL_C," - toggles noclip on yourself")
	register_clcmd("amx_ent_godmode","godmode",ADMIN_LEVEL_C," - toggles godmode on yourself")
	register_clcmd("amx_ent_solid","solid",ADMIN_LEVEL_C," - toggles solid mode on yourself")
	register_clcmd("amx_ent_teleport","teleport",ADMIN_LEVEL_C," <x> <y> <z> - teleport yourself to coordinates")
	
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
}

public pfn_keyvalue(ent){
	new class [1], key [32], value [32], keyvalue [64]
	copy_keyvalue(class,0,key,32,value,32)	
	if (!entvars [ent])
		entvars [ent] = ArrayCreate(64,1)
	format (keyvalue, 64, "%s*%s", key, value)
	ArrayPushString(entvars [ent], keyvalue)
	return PLUGIN_CONTINUE
}

public setKeyValue (ent, key[], value[]){
	new item, keyvalue [64]
	DispatchKeyValue(ent,key,value)
	if (!entvars [ent])
		entvars [ent] = ArrayCreate(64,1)
	format (keyvalue, 64, "%s*%s", key, value)
	if ((item = arrayfindkey (ent, key)) == -1)
		ArrayPushString(entvars [ent], keyvalue)
	else
		ArraySetString(entvars [ent], item, keyvalue)
}

public setKeyValueInt (ent, key[], arg){
	new value [32]
	num_to_str (arg, value, 32)
	setKeyValue (ent, key, value)
}

public setKeyValueFloat (ent, key[], Float:arg){
	new value [32]
	float_to_str (arg, value, 32)
	setKeyValue (ent, key, value)
}

public setKeyValueVector (ent, key[], Float:arg[3]){
	new value [32]
	format (value, 32, "%f %f %f", arg[0], arg[1], arg[2])
	setKeyValue (ent, key, value)
}

public arrayfindkey (ent, tofind []){
	if (!entvars[ent])
		return -1;
	new keyvalue [64], key [32], value [32]
	for (new i=0;i<ArraySize(entvars [ent]);i++){
		ArrayGetString(entvars[ent], i, keyvalue, 64)
		strtok(keyvalue, key, 32, value, 32, '*')
		if (equal(key, tofind))
			return i;
	}
	return -1;
}

public getactualorigin (ent, origin [3]){
	if (ent <= get_maxplayers())
		get_user_origin (ent, origin)
	else{
		new Float:orig [3], Float:mins [3], Float:maxs[3]
		entity_get_vector(ent, EV_VEC_origin, orig)
		entity_get_vector(ent, EV_VEC_mins, mins)
		entity_get_vector(ent, EV_VEC_maxs, maxs)
		for(new i = 0; i < 3; i++)
			origin [i] = floatround((mins[i] + maxs[i]) / 2 + orig [i])
	}
}

public getorigin (ent, origin [3]){
	if (ent <= get_maxplayers())
		get_user_origin (ent, origin)
	else{
		new Float:orig [3]
		entity_get_vector(ent, EV_VEC_origin, orig)
		FVecIVec(orig, origin)
	}
}

public setorigin (ent, origin [3]){
	if (ent <= get_maxplayers())
		set_user_origin (ent, origin)
	else{
		new Float:orig [3]
		IVecFVec(origin, orig)
		entity_set_origin (ent, orig)
	}
}

public getent (id, arg){
	new ent
	if (arg && read_argc() > arg){
		new entarg [64]
		read_argv(arg,entarg,63)
		if (isdigit(entarg [0])){
			ent=str_to_num (entarg)
		}else{
			new ents[1]
			find_sphere_class(id, entarg, 300.0, ents, 1)
			if (!ents[0]){
				console_print (id, "[AMXx] Ent Not Found")
				return 0
      		}
			ent=ents[0]
		}
	}
	if (!is_valid_ent(ent)){
		if (!id)
			return 0
		new bodypart
		get_user_aiming (id,ent,bodypart)
		if (!is_valid_ent(ent)) 
			return 0
	}
	return ent
}

public client_PreThink(id) {
	if (weaponmode [id]){
		new buttons = entity_get_int(id, EV_INT_button)
		if (buttons & IN_ATTACK){
			if (weaponmode [id] == 1)
				client_cmd (id, "amx_ent_moveaim")
			weaponmode [id] = 2
			buttons -= IN_ATTACK
		}else if (weaponmode [id] == 2){
			client_cmd (id, "amx_ent_stop")
			weaponmode [id] = 1
		}
		if (buttons & IN_RELOAD){
			if (weaponmode [id] == 1)
				client_cmd (id, "amx_ent_copyaim")
			weaponmode [id] = 3
			buttons -= IN_RELOAD
		}else if (weaponmode [id] == 3){
			client_cmd (id, "amx_ent_stop")
			weaponmode [id] = 1
		}
		if (buttons & IN_ATTACK2){
			if (weaponmode [id] == 1)
				client_cmd (id, "amx_ent_remove")
			buttons -= IN_ATTACK2
			weaponmode [id] = 4
		}else if (weaponmode [id] == 4){
			weaponmode [id] = 1
		}
		entity_set_int(id, EV_INT_button, buttons)
	}
}

public UpdateClientData(id, weapons, cd_handle){
    if (weaponmode [id])
		set_cd(cd_handle, CD_ID, 0)
    return FMRES_HANDLED
}

public weapon (id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	if (weaponmode [id])
		weaponmode [id] = 0
	else
		weaponmode [id] = 1
		
	console_print (id, "[AMXx] Weapon Mode Toggled")
		
	return PLUGIN_HANDLED
}

public create (id,level,cid){
	new cmd [32]
	read_argv(0,cmd,31)
	if (!cmd_access(id,level,cid,(containi (cmd,"origin")==-1)? 3:5)) 
      		return PLUGIN_HANDLED 
      		
	new arg [32], classname [32], origin[3], ent, player

	if (containi (cmd,"origin")==-1){
		read_argv(1,arg, 32)
		player=cmd_target(id,arg,7)
		if (!player)
			return PLUGIN_HANDLED
		getorigin (player,origin)
		read_argv(2,classname,32)
	}else{
		for (new i=0;i<3;i++){
			read_argv(i+1,arg,32)
			origin[i]=str_to_num (arg)
		}
		read_argv(4,classname,32)
	}
	if (entity_count()>=MAXENTS-15*get_maxplayers()-100){
		client_print (id, print_chat, "[AMXx] Maximum number of ents reached!")
		return PLUGIN_HANDLED
	}

	ent = create_entity(classname)
	setKeyValue (ent, "classname", classname)
	setKeyValueInt (ent, "spawnflags", 1 << 30)
	setorigin(ent, origin)
	DispatchSpawn(ent)
	
	if (containi(cmd,"origin")==-1)
		fake_touch(player, ent)
	
	console_print (id,"[AMXx] Created Ent Number: %i",ent)
	return PLUGIN_HANDLED 
}

public startmoving (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
      		return PLUGIN_HANDLED 
			
	new ent=getent (id,1)
	if (!ent)
		return PLUGIN_HANDLED
	
	new cmd[32], dontcolour
	read_argv(0,cmd,31)
	if (containi(cmd,"copy")!=-1 && ent > get_maxplayers()){
		if (arrayfindkey (ent, "entmoving_mover") != -1 || arrayfindkey (ent, "entmoving_saver") != -1)
			dontcolour=1
		ent=copyent (ent,id)
	}
		
	if (ent <= get_maxplayers() && get_user_flags(ent)&ADMIN_IMMUNITY){
		client_print (id, print_chat, "[AMXx] You cannot move a user with immunity.")
		return PLUGIN_HANDLED
	}
	
	if (arrayfindkey (ent, "entmoving_mover") != -1 || arrayfindkey (ent, "entmoving_saving") != -1){
		client_print (id, print_chat, "[AMXx] You cannot move an ent that is already being moved or saved.")
		return PLUGIN_HANDLED
	}

	new keyvalue [64]
	format (keyvalue, 64, "%s*%d", "entmoving_mover", id)
	if (!entvars[ent])
		entvars [ent] = ArrayCreate(64,1)
	ArrayPushString(entvars [ent], keyvalue)
	if (!dontcolour)
		colourent (ent, Float:{255.0, 0.0, 0.0})
    
	new information [5], userorigin [3], entorigin [3]
	information[0]=id
	information[1]=ent
	getorigin (id,userorigin)
	
	if (contain (cmd,"aim")==-1){
		getorigin (ent,entorigin)
		for (new i=0;i<3;i++)
			information [i+2]=entorigin[i]-userorigin [i]
		set_task(0.1,"moveoriginal",435+id,information,5,"b")
	}else{
		getactualorigin (ent,entorigin)
		information[2]=get_distance(userorigin, entorigin)
		set_task (0.1,"moveaim",435+id,information,3,"b")
	}
	return PLUGIN_HANDLED
}

public copyent (ent,id){
	if (entity_count()>=MAXENTS-15*get_maxplayers()-100){
		client_print (id, print_chat, "[AMXx] Maximum number of ents reached!")
		return PLUGIN_HANDLED
	}
	new newent, keyvalue [64], key [32], value [32]
	
	entity_get_string(ent, EV_SZ_classname, value, 32)
	newent = create_entity(value)
	if (!newent)
		return PLUGIN_HANDLED
	
	for (new i=0;i<ArraySize(entvars [ent]);i++){
		ArrayGetString(entvars[ent], i, keyvalue, 64)
		strtok(keyvalue, key, 32, value, 32, '*')
		if (!equal (key, "entmoving_mover") && !equal (key, "entmoving_saver")) 
			setKeyValue(newent,key,value)
	}
	DispatchSpawn(newent)
	
	new origin [3]
	getorigin(ent, origin)
	setorigin(newent, origin)

	return newent
}

public moveoriginal (information[5]){
	new origin[3]
	
	if (!is_user_connected(information[0]) || ((information[1] <= get_maxplayers())? !is_user_connected(information[1]):!is_valid_ent(information[1]))){
		stopmoving (information[0])
		return PLUGIN_HANDLED
	}
	
	getorigin(information[0], origin)
	for (new i=0;i<3;i++)
		origin[i]+=information[i+2]
	setorigin(information[1], origin)
	
	return PLUGIN_CONTINUE
}

public moveaim (information [3]){
	new Float:aiming [3], origin[3]
	
	if (!is_user_connected(information[0]) || ((information[1] <= get_maxplayers())? !is_user_connected(information[1]):!is_valid_ent(information[1]))){
		stopmoving (information[0])
		return PLUGIN_HANDLED
	}
	
	get_user_origin(information[0], origin, 3)
	IVecFVec(origin, aiming)
	getorigin (information[0], origin)
	
	for (new i=0;i<3;i++)
		aiming [i] -= float(origin [i])
	for (new i=0;i<3;i++)
		origin [i] += floatround (aiming [i] * (float(information [2])/vector_length(aiming)))
	
	if (information[1]>get_maxplayers()){
		new Float:mins [3], Float:maxs[3]
		entity_get_vector(information[1], EV_VEC_mins, mins)
		entity_get_vector(information[1], EV_VEC_maxs, maxs)
		for(new i = 0; i < 3; i++)
			origin [i] -= floatround ((mins[i] + maxs[i]) / 2)
	}
	setorigin (information[1],origin)
	
	return PLUGIN_CONTINUE
}

public stopmoving (id){
	if (task_exists (435+id))
		remove_task (435+id)
		
	new item, keyvalue [64], key [32], value [32]
	for (new i=0;i<MAXENTS;i++){
		if ((item = arrayfindkey (i, "entmoving_mover")) != -1){
			ArrayGetString(entvars[i], item, keyvalue, 64)
			strtok(keyvalue, key, 32, value, 32, '*')
			if (equal(key, "entmoving_mover") && id == str_to_num(value)) {
				colourent (i, Float:{0.0, 0.0, 0.0})
				ArrayDeleteItem(entvars [i], item)
			}
		}
	}
	return PLUGIN_HANDLED 
}

public colourentcopykey (ent, tocopy [32]){
	new item, keyvalue [64], key [32], value [32]
	if ((item = arrayfindkey (ent, tocopy)) != -1){
		ArrayGetString(entvars[ent], item, keyvalue, 64)
		strtok(keyvalue, key, 32, value, 32, '*')
		format (keyvalue, 64, "entmoving_%s*%s", tocopy, value)
		ArrayPushString(entvars [ent], keyvalue)
	}else{
		if (equal (tocopy, "renderamt"))
			format (keyvalue, 64, "entmoving_%s*255", tocopy)
		else if (equal (tocopy, "rendercolor"))
			format (keyvalue, 64, "entmoving_%s*0 0 0", tocopy)
		else
			format (keyvalue, 64, "entmoving_%s*0", tocopy)
		ArrayPushString(entvars [ent], keyvalue)
	}
}

public colourentreverse (ent, reverse [32]){
	new item, keyvalue [64], key [32], value [32]
	format (key, 32, "entmoving_%s", reverse)
	if ((item = arrayfindkey (ent, key)) != -1){
		ArrayGetString(entvars[ent], item, keyvalue, 64)
		strtok(keyvalue, key, 32, value, 32, '*')
		setKeyValue(ent, reverse, value)
		ArrayDeleteItem(entvars [ent], item)
	}
}

public colourent (ent, Float:colours [3]){
	if (colours [0] == 0.0 && colours [1] == 0.0 && colours [2] == 0.0){
		colourentreverse (ent, "rendermode")
		colourentreverse (ent, "renderamt")
		colourentreverse (ent, "rendercolor")
	}else{
		colourentcopykey (ent, "rendermode")
		colourentcopykey (ent, "renderamt")
		colourentcopykey (ent, "rendercolor")
		setKeyValue(ent, "rendermode", "1")
		setKeyValue(ent, "renderamt", "100")
		setKeyValueVector(ent, "rendercolor", colours)
	}
}

public stack(id,level,cid){ 
	if (!cmd_access(id,level,cid,5)) 
		return PLUGIN_HANDLED 

	new arg[64], ent=getent (id,5)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED 

	read_argv(1,arg,63) 
	new amount = str_to_num(arg)

	new entorigin [3]
	getorigin(ent, entorigin)
	for(new i=0;i<amount;i++){ 
		ent=copyent (ent,id)
		for (new j=0;j<3;j++){
			read_argv(j+2,arg,63) 
			entorigin[j] += str_to_num(arg) 
		}
		setorigin(ent, entorigin)
	}
	return PLUGIN_HANDLED
} 


public rotate (id,level,cid){
	if (!cmd_access(id,level,cid,4)) 
		return PLUGIN_HANDLED 

	new arg [32], Float:angles [3], entorigin [3], ent = getent (id, 4)
	if (!ent)
		return PLUGIN_HANDLED
	
	entity_get_vector(ent, EV_VEC_angles, angles)
	for (new i=0;i<3;i++){
		read_argv(i+1,arg,31)
		angles [i] += floatstr (arg)
	}
	
	getorigin(ent, entorigin)
	entity_set_vector(ent, EV_VEC_v_angle, angles)
	entity_set_vector(ent, EV_VEC_angles, angles)
	setorigin(ent, entorigin)
	
	return PLUGIN_HANDLED 
}

public originallocation (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
      		return PLUGIN_HANDLED 
      	
	new ent = getent (id, 1)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED

	new dimensions [3] = {0, 0, 0}
	setorigin(ent, dimensions)
	
	return PLUGIN_HANDLED
}

public forceuse (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
      		return PLUGIN_HANDLED 

	new ent = getent (id, 1)
	if (!ent)
		return PLUGIN_HANDLED
	
	if (read_argc()>2){
		new arg [32], player
		read_argv(2,arg,31)
		player=cmd_target(id,arg,3)
		if (player)
			force_use(player,ent)
	}else{
		force_use(id,ent)
	}
	
	return PLUGIN_HANDLED
}

public removeent (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
		return PLUGIN_HANDLED 
      	
	new ent = getent (id, 1)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED
	
	if (entvars [ent])
		ArrayDestroy (entvars [ent])
	remove_entity(ent)
		
	return PLUGIN_HANDLED
}

public droptofloor (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
      		return PLUGIN_HANDLED 
      	
	new ent = getent (id, 1)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED
	
	drop_to_floor(ent)
	
	return PLUGIN_HANDLED
}

public setrendering (id,level,cid){
	if (!cmd_access(id,level,cid,7)) 
		return PLUGIN_HANDLED 
		
	new ent = getent (id,7)
	if(!ent) 
		return PLUGIN_HANDLED
      		
	new arg[32], mode, Float:colours [3], Float:amt, fx
	read_argv(1,arg,32)
	mode = str_to_num(arg)

	for (new i=0;i<3;i++){
		read_argv(i+2,arg,32)
		colours[i] = floatstr(arg)
	}

	read_argv(5,arg,32)
	amt = floatstr(arg)

	read_argv(6,arg,31)
	fx = str_to_num(arg)
	
	if (mode != -1)	
		setKeyValueInt(ent, "rendermode", mode)
	if (colours [0] != -1 && colours [1] != -1 && colours [2] != -1)
		setKeyValueVector(ent, "rendercolor", colours)
	if (amt != -1) 
		setKeyValueFloat(ent, "renderamt", amt)
	if (fx != -1) 
		setKeyValueInt(ent, "renderfx", fx)

	return PLUGIN_HANDLED
}

public createworld (id,level,cid){
	if (!cmd_access(id,level,cid,4)) 
      		return PLUGIN_HANDLED 
      	
	new rotatingworld = create_entity("func_rotating")
      	
	new arg [64]
	get_mapname(arg,64)
	format (arg, 64, "maps/%s.bsp",arg)
	setKeyValue (rotatingworld, "model", arg)
	read_argv(1,arg,64)
	setKeyValue (rotatingworld, "speed", arg)
	read_args(arg,64)
	copy(arg,64,arg [contain (arg, " ")])
	setKeyValue (rotatingworld, "angles", arg)
      	
	setKeyValue (rotatingworld, "spawnflags", "65")
      	
	DispatchSpawn(rotatingworld)
      	
	return PLUGIN_HANDLED 
}

public deleteworlds (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
      		return PLUGIN_HANDLED 

	new ent = -1, model [64]
	get_mapname(model,64)
	format (model, 64, "maps/%s.bsp",model)
	while ((ent = find_ent_by_model(-1, "func_rotating", model)))
		remove_entity(ent)
      	
      	return PLUGIN_HANDLED 
}

public saveent (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
		return PLUGIN_HANDLED 
      	
	new ent=getent (id,1)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED	
	
	if (arrayfindkey (ent, "entmoving_mover") != -1 || arrayfindkey (ent, "entmoving_saver") != -1){
		client_print (id, print_chat, "[AMXx] You cannot save an ent that is already being moved or saved.")
		return PLUGIN_HANDLED
	}

	new keyvalue [64]
	format (keyvalue, 64, "%s*%d", "entmoving_saver", id)
	if (!entvars[ent])
		entvars [ent] = ArrayCreate(64,1)
	ArrayPushString(entvars [ent], keyvalue)
	colourent (ent, Float:{0.0, 255.0, 0.0})
	
	return PLUGIN_HANDLED
}

public loadfile (id,level,cid){
	if (!cmd_access(id,level,cid,2)) 
		return PLUGIN_HANDLED 
		
	new arg [32], file [128]
	read_argv(1,arg,32)
	get_mapname(file, 32)
	format(file,128,"%s/%s-%s.txt", SAVEPATH, file, arg)
	if (!file_exists(file)){
		console_print (id, "[AMXx] That savename does not exist.")
		return PLUGIN_HANDLED 
	}
	
	new txtlen, text [64], line
	while ((line=read_file(file,line,text,64,txtlen)))
		if (equal (text, "-----"))
			loadents (file, line, id)
	
	return PLUGIN_HANDLED 
}

public savefile (id,level,cid){
	if (!cmd_access(id,level,cid,2)) 
      	return PLUGIN_HANDLED 
		
	if (!dir_exists(SAVEPATH))
		mkdir(SAVEPATH)
        
	new arg [32], file [128]
	read_argv(1,arg,32)
	get_mapname(file, 32)
	format(file,128,"%s/%s-%s.txt", SAVEPATH, file, arg)
	if (file_exists(file)){
		console_print (id, "[AMXx] That savename already exists.")
		return PLUGIN_HANDLED 
	}
	
	new item, keyvalue [64], key [32], value [32]
	for (new i=0;i<MAXENTS;i++){
		if ((item = arrayfindkey (i, "entmoving_saver")) != -1){
			ArrayGetString(entvars[i], item, keyvalue, 64)
			strtok(keyvalue, key, 32, value, 32, '*')
			if (equal(key, "entmoving_saver") && id == str_to_num(value)) {
				colourent (i, Float:{0.0, 0.0, 0.0})
				ArrayDeleteItem(entvars [i], item)
				saveents (i, file)
			}
		}
	}
	
	return PLUGIN_HANDLED 
}

public saveents (ent, file [128]){
	write_file(file,"-----")
	new keyvalue [64]
	entity_get_string(ent, EV_SZ_classname, keyvalue, 64)
	format (keyvalue, 64, "classname*%s", keyvalue)
	for (new i=0;i<ArraySize(entvars [ent]);i++){
		ArrayGetString(entvars[ent], i, keyvalue, 64)
		write_file(file,keyvalue)
	}
	new origin [3]
	getorigin(ent, origin)
	format(keyvalue, 64, "origin*%d %d %d", origin [0], origin [1], origin [2])
	write_file(file,keyvalue)
}

public loadents (file [128],line, id){
	new keyvalue [64], txtlen, ent, key [32], value [32]
	while ((line=read_file(file,line,keyvalue,64,txtlen))){
		if (equal (keyvalue, "-----"))
			break
		if (entity_count()>=MAXENTS-15*get_maxplayers()-100){
			client_print (id, print_chat, "[AMXx] Maximum number of ents reached!")
			return PLUGIN_HANDLED
		} 
		strtok(keyvalue, key, 32, value, 32, '*')
		console_print (id, "key: %s, value:%s",key,value)
		if (equal (key, "classname")){
			ent = create_entity(value)
			if (!ent)
				return PLUGIN_HANDLED
			console_print (id, "classname")
		}
		setKeyValue(ent,key,value)
	}
	DispatchSpawn(ent)
	line--
	return PLUGIN_CONTINUE
}

public client_disconnect (id){
	new item, keyvalue [64], key [32], value [32]
	for (new i=0;i<MAXENTS;i++){
		if ((item = arrayfindkey (i, "entmoving_saver")) != -1){
			ArrayGetString(entvars[i], item, keyvalue, 64)
			strtok(keyvalue, key, 32, value, 32, '*')
			if (equal(key, "entmoving_saver") && id == str_to_num(value)) {
				colourent (i, Float:{0.0, 0.0, 0.0})
				ArrayDeleteItem(entvars [i], item)
			}
		}
	}
}

public info (id,level,cid){
	if (!cmd_access(id,level,cid,1)) 
		return PLUGIN_HANDLED 

	new ent = getent (id, 1)
	if (!ent || ent <= get_maxplayers())
		return PLUGIN_HANDLED

	new key [32], value [32], keyvalue [64]

	console_print (id, "*** Entity Keys for Ent #%i ***",ent)
	
	for (new i=0;i<ArraySize(entvars [ent]);i++){
		ArrayGetString(entvars[ent], i, keyvalue, 64)
		strtok(keyvalue, key, 32, value, 32, '*')
		if (!equal (key, "entmoving_", 10)) 
			console_print (id, "%s: ^"%s^"",key,value)
	}
		
	new origin [3]
	getactualorigin (ent, origin)
	console_print (id, "origin: ^"%d %d %d^"",origin[0],origin[1],origin[2])
	
	return PLUGIN_HANDLED 
}

public setvar (id,level,cid){
	if (!cmd_access(id,level,cid,3)) 
		return PLUGIN_HANDLED 
      	
	new ent, arg [32], key [32], argsadd
	if (read_argc() == 4){
		ent = getent (id, 1)
		argsadd++
	}else
		ent = getent (id, 0)
	
	if (!ent)
		return PLUGIN_HANDLED
        
	read_argv(1+argsadd,key,31)
	read_argv(2+argsadd,arg,31)
	setKeyValue (ent,key,arg)
	
	console_print (id, "[AMXx] Key Set")
      	
	return PLUGIN_HANDLED
}

public noclip (id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	if (get_user_noclip(id))
		set_user_noclip(id)
	else
		set_user_noclip(id, 1)
	
	new name[32], authid[32]
	get_user_name(id,name,31)
	get_user_authid(id, authid, 31)
	log_amx("[Noclip] ^"%s<%s>^" has toggled noclip",name,authid)
	console_print(id,"[AMXx] Noclip Toggled")
	
	return PLUGIN_HANDLED
}

public godmode (id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	if (get_user_godmode(id))
		set_user_godmode(id)
	else
		set_user_godmode(id, 1)
	
	new name[32], authid[32]
	get_user_name(id,name,31)
	get_user_authid(id, authid, 31)
	log_amx("[Godmode] ^"%s<%s>^" has toggled godmode",name,authid)
	console_print(id,"[AMXx] Godmode Toggled")
	
	return PLUGIN_HANDLED
}

public solid (id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	if (!entity_get_int(id, EV_INT_solid))
		setKeyValue(id,"solid","3")
	else
		setKeyValue(id,"solid","0")
		
	new name[32], authid[32]
	get_user_name(id,name,31)
	get_user_authid(id, authid, 31)
	log_amx("[Solid] ^"%s<%s>^" has toggled solid",name,authid)
	console_print(id,"[AMXx] Solid Toggled")
	
	return PLUGIN_HANDLED
}

public teleport (id,level,cid){
	if (!cmd_access(id,level,cid,4))
		return PLUGIN_HANDLED
	
	new arg [32], coordinates [3]
	for (new i=0;i<3;i++){
		read_argv(i+1,arg,32)
		coordinates [i] = str_to_num (arg)
	}
	set_user_origin (id, coordinates)
	
	new name[32], authid[32]
	get_user_name(id,name,31)
	get_user_authid(id, authid, 31)
	log_amx("[Teleport] ^"%s<%s>^" has teleport to ^"%i %i %i^"",name,authid,coordinates [0], coordinates [1], coordinates [2])
	console_print(id,"[AMXx] Teleported")
	
	return PLUGIN_HANDLED
}