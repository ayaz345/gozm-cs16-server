
/* AMX Mod X script. 
*
* tracer_fire by jon
*
* based on war weapon tracers.
*
* latest fixes:
*  - found get_user_origin mode 4, for cs only.
*    this allows us to draw the tracer to where the bullet actually
*    went instead of where the player was aiming.
*
* features solid, random, weapon class, and team color(s)
* and a new option to prevent player from seeing their own tracer.
*
*  *******************************************************************************
*   
*	Ported By KingPin( kingpin@onexfx.com ). I take no responsibility 
*	for this file in any way. Use at your own risk. No warranties of any kind. 
*
*  *******************************************************************************
*
*
* TODO:
*  - read default colors from a cfg or ini or something
*  - save colors/mode between map changes instead of loading defaults
*/


#include <amxconst>
#include <amxmodx>
#include <amxmisc>
#include <string>

/* current version */
static const CURR_VERSION[] = "1.6"

/* mode nomenclature */
static const modenames[5][] = { "disabled", "uniform", "random", "weapon-class", "player-team" }


/***************** some shiz *****************/


/* color tables. */
static weap_colors[31][3]
static rand_colors[23][3]

/* table[playerid] stores ammo count and last weapon id. */
new lastammo[33]
new lastweap[33]

/* cached beam sprite */
new spriteidx


/***************** more shiz *****************/


/*	gamemode:
*	0 - disabled
*	1 - use nCOLOR vars for color (defaults to pink 255,0,204)
*	2 - random color from fixed table for every shot
*	3 - use weapon table for colors
*	4 - team based. CT=blue, T=red
*/
new gamemode

/*	option_all
*	0 - send individual messages. player does not 'see' his/her own tracer. bots do not 'see' tracers.
*	1 - MSG_ALL every tracer.
*/
new option_all = 1


/* nCOLOR: [0-255] - store rgb values for solid tracer. */
new nred
new ngreen
new nblue


/***************** still more shiz *****************/


public tracer_setmode(id, level, cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new bool:nochange = false
	new args[1]

	read_argv(1, args, 1)

	if (equal(args,"0")) gamemode = 0
	else if (equal(args,"1")) gamemode = 1
	else if (equal(args,"2")) gamemode = 2
	else if (equal(args,"3")) gamemode = 3
	else if (equal(args,"4")) gamemode = 4
	else nochange = true

	console_print(id, "tracer mode is: %s", modenames[gamemode])

	// didn't change gamemode, don't display anything.
	if (nochange) {
		console_print(id, "usage: 'amx_tracers <0-4>' where: 0=off, 1=uniform, 2=random, 3=weapons, 4=teams")
		return PLUGIN_HANDLED
	}

	set_hudmessage(255, 255, 255, 0.05, 0.65, 0, 0.00, 6.0, 0.01, 4.0, 3)
	show_hudmessage(0, "tracer mode is: %s", modenames[gamemode])

	return PLUGIN_HANDLED
}


public tracer_setall(id, level, cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	new bool:nochange = false
	new args[1]

	read_argv(1, args, 1)

	if (equal(args,"0")) option_all = 0
	else if (equal(args,"1")) option_all = 1
	else nochange = true

	console_print(id, "tracer option_all is: %s", ((option_all==1) ? "on" : "off"))

	// didn't change option_all, don't display anything.
	if (nochange) {
		console_print(id, "usage: 'amx_tracers_all <0-1>' where 0=dont draw own tracer, 1=draw all tracers")
		return PLUGIN_HANDLED
	}

	set_hudmessage(255, 255, 255, 0.05, 0.65, 0, 0.00, 6.0, 0.01, 4.0, 3)
	show_hudmessage(0, "tracer option_all is: %s", ((option_all==1) ? "on" : "off"))

	return PLUGIN_HANDLED
}



public tracer_setcolor(id, level, cid)
{
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	new ared[4], agreen[4], ablue[4]
	new tnred, tngreen, tnblue

	// get args
	read_argv(1, ared, 3)
	read_argv(2, agreen, 3)
	read_argv(3, ablue, 3)

	// convert to int
	tnred = str_to_num(ared)
	tngreen = str_to_num(agreen)
	tnblue = str_to_num(ablue)

	// check bounds
	if (tnred < 0) tnred = 0
	if (tngreen < 0) tngreen = 0
	if (tnblue < 0) tnblue = 0
	if (tnred > 255) tnred = 255
	if (tngreen > 255) tngreen = 255
	if (tnblue > 255) tnblue = 255

	// values ok, update application
	nred = tnred
	ngreen = tngreen
	nblue = tnblue

	return PLUGIN_HANDLED
}


public draw_tracer_for(pl, pteam[], vec1[3], vec2[3], weap)
{
	new rval

	message_begin(((pl==0) ? MSG_ALL : MSG_ONE), SVC_TEMPENTITY, vec1, pl)
	write_byte(0)		// TE_BEAMPOINTS
	write_coord(vec1[0])	// start point
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])	// end point
	write_coord(vec2[1])
	write_coord(vec2[2])
	write_short(spriteidx)	// sprite to draw (precached below)
	write_byte(0)			// starting frame
	write_byte(0)			// frame rate
	write_byte(4)			// life in 0.1s
	write_byte(1)			// line width in 0.1u
	write_byte(0)			// noise in 0.1u

	switch (gamemode) {
		case 4: {
			if (equali(pteam,"CT")) write_byte(0); else write_byte(255)
			write_byte(0)
			if (equali(pteam,"CT")) write_byte(255); else write_byte(0)
		}
		case 3: {
			write_byte(weap_colors[weap][0])
			write_byte(weap_colors[weap][1])
			write_byte(weap_colors[weap][2])
		}
		case 2: {
			rval = random_num(0, 22)
			write_byte(rand_colors[rval][0])
			write_byte(rand_colors[rval][1])
			write_byte(rand_colors[rval][2])
		}
		default: {
			write_byte(nred)
			write_byte(ngreen)
			write_byte(nblue)
		}
	}

	write_byte(120)				// brightness
	write_byte(50)				// scroll speed
	message_end()

	return PLUGIN_CONTINUE
}


public make_tracer(id)
{

	if (gamemode == 0) return PLUGIN_CONTINUE

	new weap = read_data(2)		// id of the weapon
	new ammo = read_data(3)		// ammo left in clip
	new pteam[16]
	new players[32]
	new i, n

	get_user_team(id, pteam, 15)

	/* if no lastweap is set, you'll miss the first tracer!
	   weap is never zero.
	*/
	if (lastweap[id] == 0) { lastweap[id] = weap; }

	/* fire this event only if the ammo has changed but the weapon has not.
	   this prevents a tracer from being drawn when you switch from a weapon
	   with a larger clip to one with a smaller clip.

	   also, new ammo setting must be less.. otherwise a tracer is fired on reload.
	*/
	if ((lastammo[id] > ammo) && (lastweap[id] == weap)) {

		new vec1[3], vec2[3]
		get_user_origin(id, vec1, 1) // origin; your camera point.
		get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)

		vec1[2] -= 6

		if (option_all==1)
		{
			// MSG_ALL
			draw_tracer_for(0, pteam, vec1, vec2, weap)
		}
		else
		{
			// MSG_ONE
			get_players(players, n, "c")
			for(i = 0; i < n; i++)
				if ((id != players[i]) && (is_user_connected(players[i])))
					draw_tracer_for(players[i], pteam, vec1, vec2, weap)
		}
	}

	lastammo[id] = ammo
	lastweap[id] = weap

	return PLUGIN_CONTINUE
}


public plugin_init()
{
	gamemode = 1
	nred = 255
	ngreen = 0
	nblue = 204

	rand_colors[0]  = {0, 255, 255}    // cyan
	rand_colors[1]  = {255, 0, 255}    // magenta

	rand_colors[2]  = {255, 255, 204}  // lt yellow
	rand_colors[3]  = {255, 255, 0}    // yellow
	rand_colors[4]  = {153, 153, 0}    // dark yellow/gold

	rand_colors[5]  = {204, 204, 255}  // lt blue
	rand_colors[6]  = {0, 0, 255}      // blue
	rand_colors[7]  = {0, 0, 102}      // dark blue

	rand_colors[8]  = {255, 204, 255}  // lt purple
	rand_colors[9]  = {204, 0, 204}    // purple
	rand_colors[10] = {102, 0, 102}    // dark purple

	rand_colors[11] = {255, 102, 102}  // lt red
	rand_colors[12] = {255, 0, 0}      // red
	rand_colors[13] = {102, 0, 0}      // dark red

	rand_colors[14] = {0, 255, 0}      // lt green
	rand_colors[15] = {0, 153, 0}      // green
	rand_colors[16] = {0, 102, 0}      // dark green

	rand_colors[17] = {255, 204, 153}  // lt orange
	rand_colors[18] = {255, 153, 0}    // orange
	rand_colors[19] = {153, 102, 0}    // brown
	rand_colors[20] = {102, 102, 102}  // gray
	rand_colors[21] = {204, 204, 204}  // lt gray
	rand_colors[22] = {255, 255, 255}  // white


	weap_colors[CSW_USP]		= { 0, 0, 255 } // blue
	weap_colors[CSW_GLOCK18]	= { 0, 0, 255 }
	weap_colors[CSW_P228]		= { 0, 0, 255 }
	weap_colors[CSW_ELITE]		= { 0, 0, 255 }
	weap_colors[CSW_FIVESEVEN]	= { 0, 0, 255 }
	weap_colors[CSW_DEAGLE]		= { 0, 0, 255 }

	weap_colors[CSW_XM1014]		= { 255, 255, 0 } // yellow
	weap_colors[CSW_M3]		= { 255, 255, 0 }

	weap_colors[CSW_MP5NAVY]	= { 255, 153, 0 } // orange
	weap_colors[CSW_TMP]		= { 255, 153, 0 }
	weap_colors[CSW_MAC10]		= { 255, 153, 0 }
	weap_colors[CSW_UMP45]		= { 255, 153, 0 }
	weap_colors[CSW_P90]		= { 255, 153, 0 }

	weap_colors[CSW_M4A1]	= { 102, 0, 0 } // dark red
	weap_colors[CSW_AUG]	= { 102, 0, 0 }
	weap_colors[CSW_SG552]	= { 102, 0, 0 }
	weap_colors[CSW_AK47]	= { 102, 0, 0 }
	weap_colors[CSW_G3SG1]	= { 102, 0, 0 }
	weap_colors[CSW_SG550]	= { 102, 0, 0 }

	weap_colors[CSW_SCOUT]	= { 102, 102, 102 } // lt gray
	weap_colors[CSW_AWP]	= { 204, 204, 204 } // gray

	weap_colors[CSW_M249]	= { 0, 255, 0 } // lt green


	register_concmd("amx_tracers", "tracer_setmode", ADMIN_LEVEL_B, "<0-4> - 0:off,1:uniform,2:random,3:weapons,4:teams")
	register_concmd("amx_tracers_all", "tracer_setall", ADMIN_LEVEL_B, "<0-1> - 0:dont draw own tracer,1:draw all tracers")
	register_concmd("amx_tracers_colors", "tracer_setcolor", ADMIN_LEVEL_B, "<0-255> <0-255> <0-255> - RGB color values")
	register_plugin("tracer_fire", CURR_VERSION, "jon")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	spriteidx = precache_model("sprites/laserbeam.spr");
	return PLUGIN_CONTINUE
}
