#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <xs>
//#include <colored_print>
#include <gozm>

/*
 *  fakemeta-version by djmd378
 */

enum ZONEMODE
{
    ZM_NOTHING,
    ZM_CAMPING,
    ZM_CAMPING_T1,  // Team 1 -> e.g. Terrorist
    ZM_CAMPING_T2,  // Team 2 -> e.g. Counter-Terroris
    ZM_BLOCK_ALL,
    ZM_KILL,
    ZM_KILL_T1, // DoD-Unterstützung
    ZM_KILL_T2
}

new zonemode[ZONEMODE][] = {
    "ZONE_MODE_NONE",
    "ZONE_MODE_CAMPER",
    "ZONE_MODE_CAMPER_T1",
    "ZONE_MODE_CAMPER_T2",
    "ZONE_MODE_BLOCKING",
    "ZONE_MODE_CHEATER",
    "ZONE_MODE_CHEATER_T1",
    "ZONE_MODE_CHEATER_T2"
}
new zonename[ZONEMODE][] = {
    "wgz_none",
    "wgz_camper",
    "wgz_camper_t1",
    "wgz_camper_t2",
    "wgz_block_all",
    "wgz_kill",
    "wgz_kill_t1",
    "wgz_kill_t2"
}
new solidtyp[ZONEMODE] = {
    SOLID_NOT,
    SOLID_TRIGGER,
    SOLID_TRIGGER,
    SOLID_TRIGGER,
    SOLID_BBOX,
    SOLID_TRIGGER,
    SOLID_TRIGGER,
    SOLID_TRIGGER
}
new zonecolor[ZONEMODE][3] = {
    { 255, 0, 255 },        // nichts
    { 0, 255, 0 },      // Camperzone
    { 0, 255, 128 },        // Camperzone T1
    { 128, 255, 0 },        // Camperzone T2
    { 255, 255, 255 },  // alle Blockieren
    { 255, 0, 0 },  // Kill
    { 255, 0, 128 },    // Kill - T1
    { 255, 128, 0 } // Kill - T2
}

#define ZONEID pev_iuser1
#define CAMPERTIME pev_iuser2

new zone_color_aktiv[3] = { 0, 0, 255 }
new zone_color_red[3] = { 255, 0, 0 }
new zone_color_green[3] = { 255, 255, 0 }

// alle Zonen
#define MAXZONES 100
new zone[MAXZONES]
new maxzones        // soviele existieren
new index       // die aktuelle Zone

// Editier-Funktionen
new setupunits = 10 // Änderungen an der Größe um diese Einheiten
new direction = 0   // 0 -> X-Koorinaten / 1 -> Y-Koords / 2 -> Z-Koords
new koordinaten[3][] = { "TRANSLATE_X_KOORD", "TRANSLATE_Y_KOORD", "TRANSLATE_Z_KOORD" }

new spr_dot     // benötigt für die Lininen

new editor = 0      // dieser Spieler ist gerade am erstellen .. Menü verkraftet nur einen Editor

new camperzone[33]      // letzte Meldung der CamperZone
new Float:campertime[33]    // der erste Zeitpunkt des eintreffens in die Zone
new Float:camping[33]       // der letzte Zeitpunkt des campens

#define TASK_BASIS_CAMPER       2000
#define TASK_BASIS_SHOWZONES    1000

new pcv_damage
new pcv_immunity
new pcv_direction
new pcv_damageicon

// less CPU
new slap_direction
new slap_damage
new admin_immunity
new icon_damage     // Damage-Icon

enum ROUNDSTATUS {
    RS_UNDEFINED,
    RS_RUNNING,
    RS_FREEZETIME,
    RS_END,
}

new ROUNDSTATUS:roundstatus = RS_UNDEFINED

new g_maxplayers
new g_isconnected[MAX_PLAYERS+1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])

public plugin_init()
{
    register_plugin("WalkGuard", "1.3.2", "mogel")

    pcv_damage = register_cvar("wg_damage", "10")
    pcv_immunity = register_cvar("wg_immunity", "0")        // Admins mit Immunität brauchen nicht
    pcv_direction = register_cvar("wg_direction", "1")  // zufällige Richtung beim Slap
    pcv_damageicon = register_cvar("wg_damageicon", "262144") // eigentlich ein Pfeil

    register_menu("MainMenu", -1, "MainMenuAction", 0)
    register_menu("EditMenu", -1, "EditMenuAction", 0)
    register_menu("KillMenu", -1, "KillMenuAction", 0)

    // Menu
    register_clcmd("walkguardmenu", "InitWalkGuard", OWNER_FLAG, " - open the WalkGuard-Menu")

    // Sprache
    register_dictionary("walkguard.txt")

    // Einstelleungen der Variablen laden
    register_event("HLTV", "Event_FreezeTime", "a", "1=0", "2=0")
    register_logevent("Event_RoundStart", 2, "1=Round_Start")
    register_logevent("Event_RoundEnd", 2, "1=Round_End")

    register_forward(FM_Touch, "fw_touch")

    // Zonen nachladen
    set_task(1.0, "LoadWGZ")

    g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
    precache_model("models/gib_skull.mdl")
    spr_dot = precache_model("sprites/dot.spr")
}

public client_putinserver(id)
{
    g_isconnected[id] = true
}

public client_disconnect(player)
{
    // aus irgend welchen Gründen ist der Spieler einfach wech........
    if (player == editor) HideAllZones()

    g_isconnected[player] = false
}

public Event_FreezeTime()
{
    roundstatus = RS_FREEZETIME
}

public Event_RoundStart()
{
    roundstatus = RS_RUNNING

    // CPU schonen und die Variablen am Anfang gleich merken
    slap_damage = get_pcvar_num(pcv_damage)
    slap_direction = get_pcvar_num(pcv_direction)
    admin_immunity = get_pcvar_num(pcv_immunity)
    icon_damage = get_pcvar_num(pcv_damageicon)
}

public Event_RoundEnd()
{
    roundstatus = RS_END
}

// -----------------------------------------------------------------------------------------
//
//  WalkGuard-Action
//
//      -> hier ist alles was passiert
//
// -----------------------------------------------------------------------------------------
public fw_touch(zone, player)
{
    if (editor) return FMRES_IGNORED

    if (!pev_valid(zone) || !is_user_valid_connected(player))
        return FMRES_IGNORED

    static classname[33]
    pev(player, pev_classname, classname, charsmax(classname))
    if (!equal(classname, "player"))
        return FMRES_IGNORED

    pev(zone, pev_classname, classname, charsmax(classname))
    if (!equal(classname, "walkguardzone"))
        return FMRES_IGNORED

    if (roundstatus == RS_RUNNING)
        ZoneTouch(player, zone)

    return FMRES_IGNORED
}

ZoneTouch(player, zone)
{
    static zm, userteam
    zm = pev(zone, ZONEID)
    userteam = get_user_team(player)

    // Admin mit Immunity brauchen nicht
    if (admin_immunity && (get_user_flags(player) & ADMIN_IMMUNITY)) return

    // Kill Bill
    if ((ZONEMODE:zm == ZM_KILL) || ((ZONEMODE:zm == ZM_KILL_T1) && (userteam == 1)) || ((ZONEMODE:zm == ZM_KILL_T2) && (userteam == 2)))
        set_task(0.1, "ZoneModeKill", player)

    // Camping
    if ((ZONEMODE:zm == ZM_CAMPING) || ((ZONEMODE:zm == ZM_CAMPING_T1) && (userteam == 1)) || ((ZONEMODE:zm == ZM_CAMPING_T2) && (userteam == 2))) {
        if (!camping[player]) {
            client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_INIT")
            // Gratulation ... Du wirst beobachtet
            camperzone[player] = zone
            campertime[player] = get_gametime()
            camping[player] = get_gametime()
            set_task(0.5, "ZoneModeCamper", TASK_BASIS_CAMPER + player, _, _, "b")
        } else {
            // immer fleissig mitzählen
            camping[player] = get_gametime()
        }
    }
}

public ZoneModeKill(player)
{
    if (!is_user_valid_connected(player) || !is_user_alive(player))
        return

    user_silentkill(player)
    client_print(player, print_chat, "[WalkGuard] %L", player, "WALKGUARD_KILL_MESSAGE")
    //colored_print(player, "^04[GoZm]:^x01 Запрещенная зона!")
    client_cmd(player,"speak ambience/thunder_clap.wav")
}

public ZoneModeCamper(player)
{
    player -= TASK_BASIS_CAMPER

    if (!is_user_valid_connected(player))
    {
        // so ein Feigling ... hat sich einfach verdrückt ^^
        remove_task(TASK_BASIS_CAMPER + player)
        return
    }

    static Float:gametime
    gametime  = get_gametime();
    if ((gametime - camping[player]) > 0.5)
    {
        // *juhu* ... wieder frei
        campertime[player] = 0.0
        camping[player] = 0.0
        remove_task(TASK_BASIS_CAMPER + player)
        return
    }

    static ct, left
    ct = pev(camperzone[player], CAMPERTIME)
    left = ct - floatround(gametime - campertime[player])
    if (left < 1)
    {
        client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_DAMG")
        if (slap_direction) RandomDirection(player)
        fm_fakedamage(player, "camping", float(slap_damage), icon_damage)
    } else
    {
        client_print(player, print_center, "%L", player, "WALKGUARD_CAMPING_TIME", left)
    }
}

RandomDirection(player)
{
    static Float:velocity[3]
    velocity[0] = random_float(-256.0, 256.0)
    velocity[1] = random_float(-256.0, 256.0)
    velocity[2] = random_float(-256.0, 256.0)
    set_pev(player, pev_velocity, velocity)
}

// -----------------------------------------------------------------------------------------
//
//  Zonenerstellung
//
// -----------------------------------------------------------------------------------------
CreateZone(Float:position[3], Float:mins[3], Float:maxs[3], zm, campertime)
{
    static entity
    entity = cs_create_entity("info_target")
    set_pev(entity, pev_classname, "walkguardzone")
    fm_entity_set_model(entity, "models/gib_skull.mdl")
    fm_entity_set_origin(entity, position)

    set_pev(entity, pev_movetype, MOVETYPE_FLY)

    static id
    id = pev(entity, ZONEID)
    if (editor)
    {
        set_pev(entity, pev_solid, SOLID_NOT)
    }
    else
    {
        set_pev(entity, pev_solid, solidtyp[ZONEMODE:id])
    }

    fm_entity_set_size(entity, mins, maxs)

    fm_set_entity_visibility(entity, 0)

    set_pev(entity, ZONEID, zm)
    set_pev(entity, CAMPERTIME, campertime)

    //log_amx("create zone '%s' with campertime %i seconds", zonename[ZONEMODE:zm], campertime)

    return entity
}

CreateNewZone(Float:position[3])
{
    static Float:mins[3] = { -32.0, -32.0, -32.0 }
    static Float:maxs[3] = { 32.0, 32.0, 32.0 }
    return CreateZone(position, mins, maxs, 0, 10); // ZM_NONE
}

CreateZoneOnPlayer(player)
{
    // Position und erzeugen
    static Float:position[3]
    pev(player, pev_origin, position)

    static entity
    entity = CreateNewZone(position)
    FindAllZones()

    static i
    for (i = 0; i < maxzones; i++)
        if (zone[i] == entity)
            index = i;
}

// -----------------------------------------------------------------------------------------
//
//  Load & Save der WGZ
//
// -----------------------------------------------------------------------------------------
SaveWGZ(player)
{
    static zonefile[200]
    static mapname[50]

    // Verzeichnis holen
    get_configsdir(zonefile, charsmax(zonefile))
    format(zonefile, charsmax(zonefile), "%s/walkguard", zonefile)
    if (!dir_exists(zonefile))
        mkdir(zonefile)

    // Namen über Map erstellen
    get_mapname(mapname, charsmax(mapname))
    format(zonefile, charsmax(zonefile), "%s/%s.wgz", zonefile, mapname)

    FindAllZones()  // zur Sicherheit

    static file
    file = fopen(zonefile, "w")
    // Header
    fputs(file, "; V1 - WalkGuard Zone-File")
    fputs(file, "; <zonename> <position (x/y/z)> <mins (x/y/z)> <maxs (x/y/z)> [<parameter>] ")
    fputs(file, ";")
    fputs(file, ";")
    fputs(file, "; parameter")
    fputs(file, ";")
    fputs(file, ";   - wgz_camper    <time>")
    fputs(file, ";   - wgz_camper_t1 <time>")
    fputs(file, ";   - wgz_camper_t2 <time>")
    fputs(file, ";   - wgz_camper_t3 <time>")
    fputs(file, ";   - wgz_camper_t4 <time>")
    fputs(file, ";")
    fputs(file, "")

    // alle Zonen speichern
    static i
    for (i = 0; i < maxzones; i++)
    {
        static z, zm
        z = zone[i] // das Entity

        // diverse Daten der Zone
        zm = pev(z, ZONEID)

        // Koordinaten holen
        static Float:pos[3]
        pev(z, pev_origin, pos)

        // Dimensionen holen
        static Float:mins[3], Float:maxs[3]
        pev(z, pev_mins, mins)
        pev(z, pev_maxs, maxs)

        // Ausgabe formatieren
        //  -> Type und CamperTime
        static output[1000]
        formatex(output, charsmax(output), "%s", zonename[ZONEMODE:zm])
        //  -> Position
        format(output, charsmax(output), "%s %.1f %.1f %.1f", output, pos[0], pos[1], pos[2])
        //  -> Dimensionen
        format(output, charsmax(output), "%s %.0f %.0f %.0f", output, mins[0], mins[1], mins[2])
        format(output, charsmax(output), "%s %.0f %.0f %.0f", output, maxs[0], maxs[1], maxs[2])

        // diverse Parameter
        if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
        {
            static ct
            ct = pev(z, CAMPERTIME)
            format(output, charsmax(output), "%s %i", output, ct)
        }

        // und schreiben
        fputs(file, output)
    }
    if (file) fclose(file)

    client_print(player, print_chat, "%L", player, "ZONE_FILE_SAVED", zonefile)
}

public LoadWGZ()
{
    static zonefile[200]
    static mapname[50]

    // Verzeichnis holen
    get_configsdir(zonefile, charsmax(zonefile))
    format(zonefile, charsmax(zonefile), "%s/walkguard", zonefile)

    // Namen über Map erstellen
    get_mapname(mapname, charsmax(mapname))
    format(zonefile, charsmax(zonefile), "%s/%s.wgz", zonefile, mapname)

    if (!file_exists(zonefile))
    {
        log_amx("No zone-file found")
        return
    }

    // einlesen der Daten
    static input[1000]

    static file
    file = fopen(zonefile, "rt")
    while (file && !feof(file))
    {
        fgets(file, input, charsmax(input))
        trim(input)

        // skip commented lines
        if (input[0] == ';' || strlen(input) < 1 || (input[0] == '/' && input[1] == '/'))
            continue

        static data[20]
        static Float:mins[3], Float:maxs[3], Float:pos[3]  // Größe & Position
        static zm, ct, i        // "abgebrochenen" Daten - ZoneMode - CamperTime

        ct = 0

        // Zone abrufen
        argbreak(input, data, charsmax(data), input, charsmax(input))
        zm = -1
        for (i = 0; ZONEMODE:i < ZONEMODE; ZONEMODE:i++)
        {
            // Änderungen von CS:CZ zu allen Mods
            if (equal(data, "wgz_camper_te"))
                formatex(data, charsmax(data), "wgz_camper_t1")
            if (equal(data, "wgz_camper_ct"))
                formatex(data, charsmax(data), "wgz_camper_t2")
            if (equal(data, zonename[ZONEMODE:i]))
                zm = i;
        }

        if (zm == -1)
        {
            log_amx("undefined zone -> '%s' ... dropped", data)
            continue;
        }

        // Position holen
        argbreak(input, data, charsmax(data), input, charsmax(input));  pos[0] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  pos[1] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  pos[2] = str_to_float(data);

        // Dimensionen
        argbreak(input, data, charsmax(data), input, charsmax(input));  mins[0] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  mins[1] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  mins[2] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  maxs[0] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  maxs[1] = str_to_float(data);
        argbreak(input, data, charsmax(data), input, charsmax(input));  maxs[2] = str_to_float(data);

        if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
        {
            // Campertime wird immer mitgeliefert
            argbreak(input, data, charsmax(data), input, charsmax(input))
            ct = str_to_num(data)
        }

        // und nun noch erstellen
        CreateZone(pos, mins, maxs, zm, ct);
    }
    if (file) fclose(file)

    FindAllZones()
    HideAllZones()
}

FX_Line(start[3], stop[3], color[3], brightness)
{
    if (!is_user_valid_connected(editor))
        return

    message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, editor)

    write_byte(TE_BEAMPOINTS)

    write_coord(start[0])
    write_coord(start[1])
    write_coord(start[2])

    write_coord(stop[0])
    write_coord(stop[1])
    write_coord(stop[2])

    write_short(spr_dot)

    write_byte(1) // framestart
    write_byte(1) // framerate
    write_byte(4) // life in 0.1's
    write_byte(5) // width
    write_byte(0)     // noise

    write_byte(color[0])   // r, g, b
    write_byte(color[1])   // r, g, b
    write_byte(color[2])   // r, g, b

    write_byte(brightness)    // brightness
    write_byte(0)     // speed

    message_end()
}

DrawLine(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, color[3])
{
    static start[3]
    static stop[3]

    start[0] = floatround(x1)
    start[1] = floatround(y1)
    start[2] = floatround(z1)

    stop[0] = floatround(x2)
    stop[1] = floatround(y2)
    stop[2] = floatround(z2)

    FX_Line(start, stop, color, 200)
}

ShowAllZones()
{
    FindAllZones()  // zur Sicherheit alle suchen

    static i, z
    for (i = 0; i < maxzones; i++)
    {
        z = zone[i]
        remove_task(TASK_BASIS_SHOWZONES + z)
        set_pev(z, pev_solid, SOLID_NOT)
        set_task(0.2, "ShowZoneBox", TASK_BASIS_SHOWZONES + z, _, _, "b")
    }
}

public ShowZoneBox(entity)
{
    entity -= TASK_BASIS_SHOWZONES
    if ((!fm_is_valid_ent(entity)) || !editor)
        return

    // Koordinaten holen
    static Float:pos[3]
    pev(entity, pev_origin, pos)
    if (!fm_is_in_viewcone(editor, pos) && (entity != zone[index]))
        return      // sieht der Editor eh nicht

    // jetzt vom Editor zur Zone testen... Zonen hinter der Wand aber im ViewCone
    // müssen nicht gezeichnet werden
    static Float:editorpos[3]
    pev(editor, pev_origin, editorpos)
    static Float:hitpoint[3]   // da ist der Treffer
    fm_trace_line(-1, editorpos, pos, hitpoint)

    // Linie zur Zone zeichnen ... dann wird sie schneller gefunden
    if (entity == zone[index])
        DrawLine(editorpos[0], editorpos[1], editorpos[2] - 16.0, pos[0], pos[1], pos[2], { 255, 0, 0})

    // Distanz zum Treffer ... ist Wert größer dann war da etwas
    static Float:dh
    dh = vector_distance(editorpos, pos) - vector_distance(editorpos, hitpoint)
    if ((floatabs(dh) > 128.0) && (entity != zone[index]))
        return          // hinter einer Wand

    // -+*+-   die Zone muss gezeichnet werden   -+*+-

    // Dimensionen holen
    static Float:mins[3], Float:maxs[3]
    pev(entity, pev_mins, mins)
    pev(entity, pev_maxs, maxs)

    // Größe in Absolut umrechnen
    mins[0] += pos[0]
    mins[1] += pos[1]
    mins[2] += pos[2]
    maxs[0] += pos[0]
    maxs[1] += pos[1]
    maxs[2] += pos[2]

    static id
    id = pev(entity, ZONEID)

    static color[3]
    color[0] = (zone[index] == entity) ? zone_color_aktiv[0] : zonecolor[ZONEMODE:id][0]
    color[1] = (zone[index] == entity) ? zone_color_aktiv[1] : zonecolor[ZONEMODE:id][1]
    color[2] = (zone[index] == entity) ? zone_color_aktiv[2] : zonecolor[ZONEMODE:id][2]

    // einzelnen Linien der Box zeichnen
    //  -> alle Linien beginnen bei maxs
    DrawLine(maxs[0], maxs[1], maxs[2], mins[0], maxs[1], maxs[2], color)
    DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], maxs[2], color)
    DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], maxs[1], mins[2], color)
    //  -> alle Linien beginnen bei mins
    DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], mins[2], color)
    DrawLine(mins[0], mins[1], mins[2], mins[0], maxs[1], mins[2], color)
    DrawLine(mins[0], mins[1], mins[2], mins[0], mins[1], maxs[2], color)
    //  -> die restlichen 6 Lininen
    DrawLine(mins[0], maxs[1], maxs[2], mins[0], maxs[1], mins[2], color)
    DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], mins[2], color)
    DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], mins[2], color)
    DrawLine(maxs[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], color)
    DrawLine(maxs[0], mins[1], maxs[2], mins[0], mins[1], maxs[2], color)
    DrawLine(mins[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], color)

    // der Rest wird nur gezeichnet wenn es sich um ide aktuelle Box handelt
    if (entity != zone[index])
        return

    // jetzt noch die Koordinaten-Linien
    if (direction == 0) // X-Koordinaten
    {
        DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], mins[2], zone_color_green)
        DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_green)

        DrawLine(mins[0], maxs[1], maxs[2], mins[0], mins[1], mins[2], zone_color_red)
        DrawLine(mins[0], maxs[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)
    }
    if (direction == 1) // Y-Koordinaten
    {
        DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], zone_color_red)
        DrawLine(maxs[0], mins[1], mins[2], mins[0], mins[1], maxs[2], zone_color_red)

        DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], maxs[2], zone_color_green)
        DrawLine(maxs[0], maxs[1], mins[2], mins[0], maxs[1], maxs[2], zone_color_green)
    }
    if (direction == 2) // Z-Koordinaten
    {
        DrawLine(maxs[0], maxs[1], maxs[2], mins[0], mins[1], maxs[2], zone_color_green)
        DrawLine(maxs[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], zone_color_green)

        DrawLine(maxs[0], maxs[1], mins[2], mins[0], mins[1], mins[2], zone_color_red)
        DrawLine(maxs[0], mins[1], mins[2], mins[0], maxs[1], mins[2], zone_color_red)
    }
}

HideAllZones()
{
    static i, id
    editor = 0  // Menü für den nächsten wieder frei geben ... ufnktionalität aktivieren
    for (i = 0; i < maxzones; i++)
    {
        id = pev(zone[i], ZONEID)
        set_pev(zone[i], pev_solid, solidtyp[ZONEMODE:id])
        remove_task(TASK_BASIS_SHOWZONES + zone[i])
    }
}

FindAllZones()
{
    static entity
    entity = -1
    maxzones = 0

    while((entity = fm_find_ent_by_class(entity, "walkguardzone")))
    {
        zone[maxzones] = entity
        maxzones++
    }
}

public InitWalkGuard(player)
{
    static name[33], steam[33]
    get_user_name(player, name, charsmax(name))
    get_user_authid(player, steam, charsmax(steam))

    if (!has_rcon(player))
    {
        log_amx("no access-rights for '%s' <%s>", name, steam)
        return PLUGIN_HANDLED
    }

    editor = player
    FindAllZones();
    ShowAllZones();

    set_task(0.1, "OpenWalkGuardMenu", player)

    return PLUGIN_HANDLED
}

public OpenWalkGuardMenu(player)
{
    static trans[70]
    static menu[1024]
    static zm, ct, menukeys

    zm = -1
    ct = 0
    menukeys = MENU_KEY_0 + MENU_KEY_4 + MENU_KEY_9

    if (fm_is_valid_ent(zone[index]))
    {
        zm = pev(zone[index], ZONEID)
        ct = pev(zone[index], CAMPERTIME)
    }

    formatex(menu, charsmax(menu), "\dWalkGuard-Menu\w")
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%L", player, "WGM_ZONE_FOUND", menu, maxzones)

    if (zm != -1)
    {
        formatex(trans, charsmax(trans), "%L", player, zonemode[ZONEMODE:zm])
        if (ZONEMODE:zm == ZM_CAMPING)
        {
            format(menu, charsmax(menu), "%L", player, "WGM_ZONE_CURRENT_CAMP", menu, index + 1, trans, ct)
        } else
        {
            format(menu, charsmax(menu), "%L", player, "WGM_ZONE_CURRENT_NONE", menu, index + 1, trans)
        }

        menukeys += MENU_KEY_2 + MENU_KEY_3 + MENU_KEY_1
        format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
        format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
        format(menu, charsmax(menu), "%L", player, "WGM_ZONE_EDIT", menu)
        format(menu, charsmax(menu), "%L", player, "WGM_ZONE_CHANGE", menu)
    }

    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%L" ,player, "WGM_ZONE_CREATE", menu)

    if (zm != -1)
    {
        menukeys += MENU_KEY_6
        format(menu, charsmax(menu), "%L", player, "WGM_ZONE_DELETE", menu)
    }
    format(menu, charsmax(menu), "%L", player, "WGM_ZONE_SAVE", menu)

    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%L" ,player, "WGM_ZONE_EXIT", menu)

    show_menu(player, menukeys, menu, -1, "MainMenu")
    client_cmd(player, "spk sound/buttons/blip1.wav")
}

public MainMenuAction(player, key)
{
    key = (key == 10) ? 0 : key + 1
    switch(key)
    {
        case 1:
        {
            // Zone editieren
            if (fm_is_valid_ent(zone[index]))
                OpenEditMenu(player);
            else
                OpenWalkGuardMenu(player);
        }
        case 2:
        {
            // vorherige Zone
            index = (index > 0) ? index - 1 : index;
            OpenWalkGuardMenu(player)
        }
        case 3:
        {
            // nächste Zone
            index = (index < maxzones - 1) ? index + 1 : index;
            OpenWalkGuardMenu(player)
        }
        case 4:
        {
            // neue Zone über dem Spieler
            if (maxzones < MAXZONES - 1)
            {
                CreateZoneOnPlayer(player);
                ShowAllZones();
                MainMenuAction(player, 0);  // selber aufrufen
            }
            else
            {
                client_print(player, print_chat, "%L", player, "ZONE_FULL")
                client_cmd(player, "spk sound/buttons/button10.wav")
                set_task(0.5, "OpenWalkGuardMenu", player)
            }
        }
        case 6:
        {
            // aktuelle Zone löschen
            OpenKillMenu(player);
        }
        case 9:
        {
            // Zonen speichern
            SaveWGZ(player)
            OpenWalkGuardMenu(player)
        }
        case 10:
        {
            editor = 0
            HideAllZones()
        }
    }
}

OpenEditMenu(player)
{
    static trans[70]
    static menu[1024]
    static menukeys, zm, ct

    menukeys = MENU_KEY_0 + MENU_KEY_1 + MENU_KEY_4 + MENU_KEY_5 + MENU_KEY_6 + MENU_KEY_7 + MENU_KEY_8 + MENU_KEY_9

    formatex(menu, charsmax(menu), "\dEdit WalkGuard-Zone\w")
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile

    zm = -1
    ct = 0

    if (fm_is_valid_ent(zone[index]))
    {
        zm = pev(zone[index], ZONEID)
        ct = pev(zone[index], CAMPERTIME)
    }

    if (zm != -1)
    {
        formatex(trans, charsmax(trans), "%L", player, zonemode[ZONEMODE:zm])
        if ((ZONEMODE:zm == ZM_CAMPING) || (ZONEMODE:zm == ZM_CAMPING_T1) || (ZONEMODE:zm == ZM_CAMPING_T2))
        {
            format(menu, charsmax(menu), "%L", player, "WGE_ZONE_CURRENT_CAMP", menu, trans, ct)
            format(menu, charsmax(menu), "%L", player, "WGE_ZONE_CURRENT_CHANGE", menu)
            menukeys += MENU_KEY_2 + MENU_KEY_3
        } else
        {
            format(menu, charsmax(menu), "%L", player, "WGE_ZONE_CURRENT_NONE", menu, trans)
            format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
        }
    }

    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile

    formatex(trans, charsmax(trans), "%L", player, koordinaten[direction])
    format(menu, charsmax(menu), "%L", player, "WGE_ZONE_SIZE_INIT", menu, trans)
    format(menu, charsmax(menu), "%L", player, "WGE_ZONE_SIZE_MINS", menu)
    format(menu, charsmax(menu), "%L", player, "WGE_ZONE_SIZE_MAXS", menu)
    format(menu, charsmax(menu), "%L", player, "WGE_ZONE_SIZE_STEP", menu, setupunits)
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%s^n", menu)        // Leerzeile
    format(menu, charsmax(menu), "%L", player, "WGE_ZONE_SIZE_QUIT", menu)

    show_menu(player, menukeys, menu, -1, "EditMenu")
    client_cmd(player, "spk sound/buttons/blip1.wav")
}

public EditMenuAction(player, key)
{
    key = (key == 10) ? 0 : key + 1
    switch(key)
    {
        case 1:
        {
            // nächster ZoneMode
            static zm
            zm = pev(zone[index], ZONEID)
            if (ZONEMODE:zm == ZM_KILL_T2)
                zm = 0;
            else
                zm++;
            set_pev(zone[index], ZONEID, zm)
            OpenEditMenu(player)
        }
        case 2:
        {
            // Campertime runter
            static ct
            ct = pev(zone[index], CAMPERTIME)
            ct = (ct > 5) ? ct - 1 : 5
            set_pev(zone[index], CAMPERTIME, ct)
            OpenEditMenu(player)
        }
        case 3:
        {
            // Campertime hoch
            static ct
            ct = pev(zone[index], CAMPERTIME)
            ct = (ct < 30) ? ct + 1 : 30
            set_pev(zone[index], CAMPERTIME, ct)
            OpenEditMenu(player)
        }
        case 4:
        {
            // Editier-Richtung ändern
            direction = (direction < 2) ? direction + 1 : 0
            OpenEditMenu(player)
        }
        case 5:
        {
            // von "mins" / rot etwas abziehen -> schmaler
            ZuRotAddieren()
            OpenEditMenu(player)
        }
        case 6:
        {
            // zu "mins" / rot etwas addieren -> breiter
            VonRotAbziehen()
            OpenEditMenu(player)
        }
        case 7:
        {
            // von "maxs" / gelb etwas abziehen -> schmaler
            VonGelbAbziehen()
            OpenEditMenu(player)
        }
        case 8:
        {
            // zu "maxs" / gelb etwas addierne -> breiter
            ZuGelbAddieren()
            OpenEditMenu(player)
        }
        case 9:
        {
            // Schreitweite ändern
            setupunits = (setupunits < 100) ? setupunits * 10 : 1
            OpenEditMenu(player)
        }
        case 10:
        {
            OpenWalkGuardMenu(player)
        }
    }
}

VonRotAbziehen()
{
    static entity
    entity = zone[index]

    // Koordinaten holen
    static Float:pos[3]
    pev(entity, pev_origin, pos)

    // Dimensionen holen
    static Float:mins[3], Float:maxs[3]
    pev(entity, pev_mins, mins)
    pev(entity, pev_maxs, maxs)

    // könnte Probleme geben -> zu klein
    //if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1) return

    mins[direction] -= float(setupunits) / 2.0
    maxs[direction] += float(setupunits) / 2.0
    pos[direction] -= float(setupunits) / 2.0

    set_pev(entity, pev_origin, pos)
    fm_entity_set_size(entity, mins, maxs)
}

ZuRotAddieren()
{
    static entity
    entity = zone[index]

    // Koordinaten holen
    static Float:pos[3]
    pev(entity, pev_origin, pos)

    // Dimensionen holen
    static Float:mins[3], Float:maxs[3]
    pev(entity, pev_mins, mins)
    pev(entity, pev_maxs, maxs)

    // könnte Probleme geben -> zu klein
    if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1)
        return

    mins[direction] += float(setupunits) / 2.0
    maxs[direction] -= float(setupunits) / 2.0
    pos[direction] += float(setupunits) / 2.0

    set_pev(entity, pev_origin, pos)
    fm_entity_set_size(entity, mins, maxs)
}

VonGelbAbziehen()
{
    static entity
    entity = zone[index]

    // Koordinaten holen
    static Float:pos[3]
    pev(entity, pev_origin, pos)

    // Dimensionen holen
    static Float:mins[3], Float:maxs[3]
    pev(entity, pev_mins, mins)
    pev(entity, pev_maxs, maxs)

    // könnte Probleme geben -> zu klein
    if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1)
        return

    mins[direction] += float(setupunits) / 2.0
    maxs[direction] -= float(setupunits) / 2.0
    pos[direction] -= float(setupunits) / 2.0

    set_pev(entity, pev_origin, pos)
    fm_entity_set_size(entity, mins, maxs)
}

ZuGelbAddieren()
{
    static entity
    entity = zone[index]

    // Koordinaten holen
    static Float:pos[3]
    pev(entity, pev_origin, pos)

    // Dimensionen holen
    static Float:mins[3], Float:maxs[3]
    pev(entity, pev_mins, mins)
    pev(entity, pev_maxs, maxs)

    // könnte Probleme geben -> zu klein
    //if ((floatabs(mins[direction]) + maxs[direction]) < setupunits + 1) return

    mins[direction] -= float(setupunits) / 2.0
    maxs[direction] += float(setupunits) / 2.0
    pos[direction] += float(setupunits) / 2.0

    set_pev(entity, pev_origin, pos)
    fm_entity_set_size(entity, mins, maxs)
}

OpenKillMenu(player)
{
    static menu[1024]

    formatex(menu, charsmax(menu), "%L", player, "ZONE_KILL_INIT")
    format(menu, charsmax(menu), "%L", player, "ZONE_KILL_ASK", menu) // ja - nein - vieleicht

    show_menu(player, MENU_KEY_1 + MENU_KEY_0, menu, -1, "KillMenu")

    client_cmd(player, "spk sound/buttons/button10.wav")
}

public KillMenuAction(player, key)
{
    key = (key == 10) ? 0 : key + 1
    switch(key)
    {
        case 1:
        {
            client_print(player, print_chat, "[WalkGuard] %L", player, "ZONE_KILL_NO")
        }
        case 10:
        {
            fm_remove_entity(zone[index])
            index--;
            if (index < 0)
                index = 0;
            client_print(player, print_chat, "[WalkGuard] %L", player, "ZONE_KILL_YES")
            FindAllZones()
        }
    }
    OpenWalkGuardMenu(player)
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "")
{
    if (classname[0])
        set_kvd(0, KV_ClassName, classname)
    else {
        static class[32]
        pev(entity, pev_classname, class, sizeof class - 1)
        set_kvd(0, KV_ClassName, class)
    }

    set_kvd(0, KV_KeyName, key)
    set_kvd(0, KV_Value, value)
    set_kvd(0, KV_fHandled, 0)

    return dllfunc(DLLFunc_KeyValue, entity, 0)
}

stock fm_fake_touch(toucher, touched)
    return dllfunc(DLLFunc_Touch, toucher, touched)

stock fm_DispatchSpawn(entity)
    return dllfunc(DLLFunc_Spawn, entity)

stock fm_remove_entity(index)
    return engfunc(EngFunc_RemoveEntity, index)

stock fm_find_ent_by_class(index, const classname[])
    return engfunc(EngFunc_FindEntityByString, index, "classname", classname)

stock fm_is_valid_ent(index)
    return pev_valid(index)

stock fm_entity_set_size(index, const Float:mins[3], const Float:maxs[3])
    return engfunc(EngFunc_SetSize, index, mins, maxs)

stock fm_entity_set_model(index, const model[])
    return engfunc(EngFunc_SetModel, index, model)

stock fm_create_entity(const classname[])
    return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname))

stock fm_fakedamage(victim, const classname[], Float:takedmgdamage, damagetype)
{
    static class[] = "trigger_hurt"
    static entity
    entity = cs_create_entity(class)
    if (!entity)
        return 0

    static value[16]
    float_to_str(takedmgdamage * 2, value, sizeof value - 1)
    fm_set_kvd(entity, "dmg", value, class)

    num_to_str(damagetype, value, sizeof value - 1)
    fm_set_kvd(entity, "damagetype", value, class)

    fm_set_kvd(entity, "origin", "8192 8192 8192", class)
    fm_DispatchSpawn(entity)

    set_pev(entity, pev_classname, classname)
    fm_fake_touch(entity, victim)
    fm_remove_entity(entity)

    return 1
}

stock fm_entity_set_origin(index, const Float:origin[3])
{
    static Float:mins[3], Float:maxs[3]
    pev(index, pev_mins, mins)
    pev(index, pev_maxs, maxs)
    engfunc(EngFunc_SetSize, index, mins, maxs)

    return engfunc(EngFunc_SetOrigin, index, origin)
}

stock fm_set_entity_visibility(index, visible = 1)
{
    set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

    return 1
}

stock bool:fm_is_in_viewcone(index, const Float:point[3])
{
    static Float:angles[3]
    pev(index, pev_angles, angles)
    engfunc(EngFunc_MakeVectors, angles)
    global_get(glb_v_forward, angles)
    angles[2] = 0.0

    static Float:origin[3], Float:diff[3], Float:norm[3]
    pev(index, pev_origin, origin)
    xs_vec_sub(point, origin, diff)
    diff[2] = 0.0
    xs_vec_normalize(diff, norm)

    static Float:dot, Float:fov
    dot = xs_vec_dot(norm, angles)
    pev(index, pev_fov, fov)
    if (dot >= floatcos(fov * M_PI / 360))
        return true

    return false
}

stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3])
{
    engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0)

    static ent
    ent = get_tr2(0, TR_pHit)
    get_tr2(0, TR_vecEndPos, ret)

    return pev_valid(ent) ? ent : 0
}
