new const PLUGIN_VERSION[]  = "1.1 $Revision: 290 $"; // $Date: 2009-02-26 11:20:25 -0500 (Thu, 26 Feb 2009) $;

#include <amxmodx>
#include <amxmisc>
#include <colored_print>
#include <gozm>

#pragma semicolon 1

#define TASKID_EMPTYSERVER				98176977
#define TASKID_REMINDER					52691153

#define RTV_CMD_STANDARD				1
#define RTV_CMD_SHORTHAND				2
#define RTV_CMD_DYNAMIC					4

#define SOUND_GETREADYTOCHOOSE			1
#define SOUND_COUNTDOWN					2
#define SOUND_TIMETOCHOOSE				4
#define SOUND_RUNOFFREQUIRED			8

#define SHOWSTATUS_VOTE					1

#define SHOWSTATUSTYPE_PERCENTAGE		2

#define MAX_NOMINATION_CNT				5

#define MAX_PREFIX_CNT					32
#define MAX_RECENT_MAP_CNT				16

#define MAX_PLAYER_CNT					32
#define MAX_MAPNAME_LEN					31
#define MAX_MAPS_IN_VOTE				8
#define MAX_NOM_MATCH_CNT				1000

#define VOTE_IN_PROGRESS				1
#define VOTE_FORCED						2
#define VOTE_IS_RUNOFF					4
#define VOTE_IS_OVER					8
#define VOTE_IS_EARLY					16
#define VOTE_HAS_EXPIRED				32

#define SRV_START_CURRENTMAP			1
#define SRV_START_NEXTMAP				2
#define SRV_START_RANDOMMAP				4

#define LISTMAPS_USERID					0
#define LISTMAPS_LAST					1

#define TIMELIMIT_NOT_SET				-1.0

new MENU_CHOOSEMAP[] = "gal_menuChooseMap";

new DIR_CONFIGS[64];
new DIR_DATA[64];

new CLR_RED[3];         // \r
new CLR_WHITE[3];       // \w
new CLR_YELLOW[3];      // \y
new CLR_GREY[3];        // \d

new bool:g_wasLastRound = false;
new g_mapPrefix[MAX_PREFIX_CNT][16], g_mapPrefixCnt = 1;
new g_currentMap[MAX_MAPNAME_LEN+1], Float:g_originalTimelimit = TIMELIMIT_NOT_SET;

new g_nomination[MAX_PLAYER_CNT + 1][MAX_NOMINATION_CNT + 1], g_nominationCnt, g_nominationMatchesMenu[MAX_PLAYER_CNT];

new g_voteWeightFlags[32];

new Array:g_emptyCycleMap, bool:g_isUsingEmptyCycle = false, g_emptyMapCnt = 0;

new Array:g_mapCycle;

new g_recentMap[MAX_RECENT_MAP_CNT][MAX_MAPNAME_LEN + 1], g_cntRecentMap;
new Array:g_nominationMap, g_nominationMapCnt;
new Array:g_fillerMap;
new Float:g_rtvWait;
new bool:g_rockedVote[MAX_PLAYER_CNT + 1], g_rockedVoteCnt;

new g_mapChoice[MAX_MAPS_IN_VOTE + 1][MAX_MAPNAME_LEN + 1], g_choiceCnt, g_choiceMax;
new bool:g_voted[MAX_PLAYER_CNT + 1] = {true, ...}, g_mapVote[MAX_MAPS_IN_VOTE + 1];
new g_voteStatus, g_voteDuration, g_votesCast;
new g_runoffChoice[2];
new g_vote[512];
new bool:g_handleMapChange = true;
new bool:g_skip_task_vote_manageEnd = false;
new bool:g_vote_running = false;

new g_refreshVoteStatus = true, g_voteTallyType[3], g_snuffDisplay[MAX_PLAYER_CNT + 1];

new g_sync_msgdisplay;
new g_menuChooseMap;

new g_pauseMapEndVoteTask, g_pauseMapEndManagerTask;

new cvar_extendmapMax, cvar_extendmapStep;
new cvar_endOnRound, cvar_endOfMapVote;
new cvar_rtvWait, cvar_rtvRatio, cvar_rtvCommands;
new cvar_cmdVotemap, cvar_cmdListmaps, cvar_listmapsPaginate;
new cvar_banRecent, cvar_banRecentStyle, cvar_voteDuration;
new cvar_nomMapFile, cvar_nomPrefixes;
new cvar_nomQtyUsed, cvar_nomPlayerAllowance;
new cvar_voteExpCountdown, cvar_voteWeightFlags, cvar_voteWeight;
new cvar_voteMapChoiceCnt, cvar_voteAnnounceChoice, cvar_voteUniquePrefixes;
new cvar_voteMapFile, cvar_rtvReminder;
new cvar_srvStart;
new cvar_emptyWait, cvar_emptyMapFile, cvar_emptyCycle;
new cvar_runoffEnabled, cvar_runoffDuration;
new cvar_voteStatus, cvar_voteStatusType;
new cvar_soundsMute;

new cvar_freezetime;
new cvar_bh_starttime;

public plugin_init()
{
    // build version information
    new jnk[1], version[8], rev[8];
    parse(PLUGIN_VERSION, version, charsmax(version), jnk, charsmax(jnk), rev, charsmax(rev), jnk, charsmax(jnk));
    new pluginVersion[16];
    formatex(pluginVersion, charsmax(pluginVersion), "%s.%s", version, rev);

    register_plugin("Galileo", pluginVersion, "Brad Jones");

    if (!is_server_licenced())
        return PLUGIN_CONTINUE;

    register_cvar("gal_version", pluginVersion, FCVAR_SERVER|FCVAR_SPONLY);
    set_cvar_string("gal_version", pluginVersion);

    register_cvar("gal_server_starting", "1", FCVAR_SPONLY);
    cvar_emptyCycle = register_cvar("gal_in_empty_cycle", "0", FCVAR_SPONLY);

    register_dictionary("common.txt");
    register_dictionary("nextmap.txt");
    register_dictionary("galileo.txt");

    register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
    register_logevent("logevent_round_end", 2, "1=Round_End");

    register_event("TextMsg", "event_game_commencing", "a", "2=#Game_Commencing", "2=#Game_will_restart_in");
    register_event("30", "event_intermission", "a");

    g_menuChooseMap = register_menuid(MENU_CHOOSEMAP);
    register_menucmd(g_menuChooseMap, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0, "vote_handleChoice");

    register_clcmd("say", "cmd_say", -1);
    register_clcmd("say_team", "cmd_say", -1);
    register_clcmd("say nextmap", "cmd_nextmap", 0, "- displays nextmap");
    register_clcmd("say currentmap", "cmd_currentmap", 0, "- display current map");
    register_clcmd("say ff", "cmd_ff", 0, "- display friendly fire status");    // grrface
    register_clcmd("votemap", "cmd_HL1_votemap");
    register_clcmd("listmaps", "cmd_HL1_listmaps");

    register_concmd("gal_startvote", "cmd_startVote", ADMIN_MAP);
    register_concmd("gal_createmapfile", "cmd_createMapFile", OWNER_FLAG);
    register_concmd("recentmaps", "cmd_listrecent");

    register_cvar("amx_nextmap", "", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY);
    cvar_extendmapMax               =   register_cvar("amx_extendmap_max", "35");
    cvar_extendmapStep          =   register_cvar("amx_extendmap_step", "15");

    cvar_cmdVotemap                 = register_cvar("gal_cmd_votemap", "0");
    cvar_cmdListmaps                = register_cvar("gal_cmd_listmaps", "1");

    cvar_listmapsPaginate       = register_cvar("gal_listmaps_paginate", "10");

    cvar_banRecent                  = register_cvar("gal_banrecent", "6");
    cvar_banRecentStyle         = register_cvar("gal_banrecentstyle", "1");

    cvar_endOnRound                 = register_cvar("gal_endonround", "1");
    cvar_endOfMapVote               = register_cvar("gal_endofmapvote", "1");

    cvar_emptyWait                  =   register_cvar("gal_emptyserver_wait", "2");
    cvar_emptyMapFile               = register_cvar("gal_emptyserver_mapfile", "emptycycle.txt");

    cvar_srvStart                       = register_cvar("gal_srv_start", "4");

    cvar_rtvCommands                = register_cvar("gal_rtv_commands", "2");
    cvar_rtvWait                    = register_cvar("gal_rtv_wait", "3");
    cvar_rtvRatio                       = register_cvar("gal_rtv_ratio", "0.50");
    cvar_rtvReminder                = register_cvar("gal_rtv_reminder", "0");

    cvar_nomPlayerAllowance = register_cvar("gal_nom_playerallowance", "1");
    cvar_nomMapFile                 = register_cvar("gal_nom_mapfile", "mapcycle.txt");
    cvar_nomPrefixes                = register_cvar("gal_nom_prefixes", "0");
    cvar_nomQtyUsed                 = register_cvar("gal_nom_qtyused", "0");

    cvar_voteWeight                 = register_cvar("gal_vote_weight", "2");
    cvar_voteWeightFlags        = register_cvar("gal_vote_weightflags", "t");
    cvar_voteMapFile                = register_cvar("gal_vote_mapfile", "mapcycle.txt");
    cvar_voteDuration               = register_cvar("gal_vote_duration", "10");
    cvar_voteExpCountdown       = register_cvar("gal_vote_expirationcountdown", "1");
    cvar_voteMapChoiceCnt       =   register_cvar("gal_vote_mapchoices", "3");
    cvar_voteAnnounceChoice = register_cvar("gal_vote_announcechoice", "1");
    cvar_voteStatus                 =   register_cvar("gal_vote_showstatus", "1");
    cvar_voteStatusType         = register_cvar("gal_vote_showstatustype", "1");
    cvar_voteUniquePrefixes = register_cvar("gal_vote_uniqueprefixes", "0");

    cvar_runoffEnabled          = register_cvar("gal_runoff_enabled", "0");
    cvar_runoffDuration         = register_cvar("gal_runoff_duration", "10");

    cvar_soundsMute                 = register_cvar("gal_sounds_mute", "0");

    g_sync_msgdisplay = CreateHudSyncObj();

    return PLUGIN_CONTINUE;
}

public plugin_cfg()
{
    formatex(DIR_CONFIGS[get_configsdir(DIR_CONFIGS, charsmax(DIR_CONFIGS))], charsmax(DIR_CONFIGS), "/galileo");
    formatex(DIR_DATA[get_datadir(DIR_DATA, charsmax(DIR_DATA))], charsmax(DIR_DATA), "/galileo");

    server_cmd("exec %s/galileo.cfg", DIR_CONFIGS);
    server_exec();

    if (colored_menus())
    {
        copy(CLR_RED, 2, "\r");
        copy(CLR_WHITE, 2, "\w");
        copy(CLR_YELLOW, 2, "\y");
    }

    g_rtvWait = get_pcvar_float(cvar_rtvWait);
    get_pcvar_string(cvar_voteWeightFlags, g_voteWeightFlags, charsmax(g_voteWeightFlags));
    get_mapname(g_currentMap, charsmax(g_currentMap));
    g_choiceMax = max(min(MAX_MAPS_IN_VOTE, get_pcvar_num(cvar_voteMapChoiceCnt)), 2);
    g_fillerMap = ArrayCreate(32);
    g_nominationMap = ArrayCreate(32);

    // initialize nominations table
    nomination_clearAll();

    if (get_pcvar_num(cvar_banRecent))
    {
        register_clcmd("say recentmaps", "cmd_listrecent", 0);

        map_loadRecentList();

        if (!(get_cvar_num("gal_server_starting") && get_pcvar_num(cvar_srvStart)))
        {
            map_writeRecentList();
        }
    }

    if (get_pcvar_num(cvar_rtvCommands) & RTV_CMD_STANDARD)
    {
        register_clcmd("say rockthevote", "cmd_rockthevote", 0);
    }

    if (get_pcvar_num(cvar_nomPlayerAllowance))
    {
        register_concmd("gal_listmaps", "cmd_listmaps");
        register_clcmd("say nominations", "cmd_nominations", 0, "- displays current nominations for next map");

        if (get_pcvar_num(cvar_nomPrefixes))
        {
            map_loadPrefixList();
        }
        map_loadNominationList();
    }

    if (get_cvar_num("gal_server_starting"))
    {
        srv_handleStart();
    }

    set_task(10.0, "vote_setupEnd");

    if (get_pcvar_num(cvar_emptyWait))
    {
        g_emptyCycleMap = ArrayCreate(32);
        map_loadEmptyCycleList();
        set_task(60.0, "srv_initEmptyCheck");
    }

    cvar_freezetime = get_cvar_num("mp_freezetime");
    cvar_bh_starttime = get_cvar_num("bh_starttime");
}

public plugin_end()
{
    map_restoreOriginalTimeLimit();
}

public vote_setupEnd()
{
    g_originalTimelimit = get_cvar_float("mp_timelimit");

    new nextMap[32];
    if (get_pcvar_num(cvar_endOfMapVote))
    {
        formatex(nextMap, charsmax(nextMap), "%L", LANG_SERVER, "GAL_NEXTMAP_UNKNOWN");
    }
    else
    {
        g_mapCycle = ArrayCreate(32);
        map_populateList(g_mapCycle, "mapcycle.txt");
        map_getNext(g_mapCycle, g_currentMap, nextMap);
    }
    map_setNext(nextMap);

    // as long as the time limit isn't set to 0, we can manage the end of the map automatically
    if (g_originalTimelimit)
    {
        set_task(10.0, "vote_manageEnd", _, _, _, "b");
    }
}

map_getNext(Array:mapArray, currentMap[], nextMap[32])
{
    new thisMap[32], mapCnt = ArraySize(mapArray), nextmapIdx = 0, returnVal = -1;
    for (new mapIdx = 0; mapIdx < mapCnt; mapIdx++)
    {
        ArrayGetString(mapArray, mapIdx, thisMap, charsmax(thisMap));
        if (equal(currentMap, thisMap))
        {
            nextmapIdx = (mapIdx == mapCnt - 1) ? 0 : mapIdx + 1;
            returnVal = nextmapIdx;
            break;
        }
    }
    ArrayGetString(mapArray, nextmapIdx, nextMap, charsmax(nextMap));

    return returnVal;
}

srv_handleStart()
{
    // this is the key that tells us if this server has been restarted or not
    set_cvar_num("gal_server_starting", 0);

    // take the defined "server start" action
    new startAction = get_pcvar_num(cvar_srvStart);
    if (startAction)
    {
        new nextMap[32];

        if (startAction == SRV_START_CURRENTMAP || startAction == SRV_START_NEXTMAP)
        {
            new filename[256];
            formatex(filename, charsmax(filename), "%s/info.dat", DIR_DATA);

            new file = fopen(filename, "rt");
            if (file) // !feof(file)
            {
                fgets(file, nextMap, charsmax(nextMap));

                if (startAction == SRV_START_NEXTMAP)
                {
                    nextMap[0] = 0;
                    fgets(file, nextMap, charsmax(nextMap));
                }
            }
            fclose(file);
        }
        else if (startAction == SRV_START_RANDOMMAP)
        {
            // pick a random map from allowable nominations

            // if noms aren't allowed, the nomination list hasn't already been loaded
            if (get_pcvar_num(cvar_nomPlayerAllowance) == 0)
            {
                map_loadNominationList();
            }

            if (g_nominationMapCnt)
            {
                ArrayGetString(g_nominationMap, random_num(0, g_nominationMapCnt - 1), nextMap, charsmax(nextMap));
            }
        }

        trim(nextMap);

        if (nextMap[0] && is_map_valid(nextMap))
        {
            //server_cmd("changelevel %s", nextMap);
            engine_changelevel(nextMap);
        }
        else
        {
            vote_manageEarlyStart();
        }
    }
}

vote_manageEarlyStart()
{
    g_voteStatus |= VOTE_IS_EARLY;

    set_task(120.0, "vote_startDirector");
}

map_setNext(nextMap[])
{
    // set the queryable cvar
    set_cvar_string("amx_nextmap", nextMap);

    // update our data file
    new filename[256];
    formatex(filename, charsmax(filename), "%s/info.dat", DIR_DATA);

    new file = fopen(filename, "wt");
    if (file)
    {
        fprintf(file, "%s", g_currentMap);
        fprintf(file, "^n%s", nextMap);
        fclose(file);
    }
    else
    {
        //error
    }
}

public vote_manageEnd()
{
    if (g_skip_task_vote_manageEnd)
    {
        return;
    }

    new secondsLeft = get_timeleft();
    // are we managing the end of the map?
    if (secondsLeft < 22 && !g_pauseMapEndManagerTask)
    {
        map_manageEnd();
    }
}

map_loadRecentList()
{
    new filename[256];
    formatex(filename, charsmax(filename), "%s/recentmaps.dat", DIR_DATA);

    new file = fopen(filename, "rt");
    if (file)
    {
        new buffer[32];

        while (!feof(file))
        {
            fgets(file, buffer, charsmax(buffer));
            trim(buffer);

            if (buffer[0])
            {
                if (g_cntRecentMap == get_pcvar_num(cvar_banRecent))
                {
                    break;
                }
                copy(g_recentMap[g_cntRecentMap++], charsmax(buffer), buffer);
            }
        }
        fclose(file);
    }
}

map_writeRecentList()
{
    new filename[256];
    formatex(filename, charsmax(filename), "%s/recentmaps.dat", DIR_DATA);

    new file = fopen(filename, "wt");
    if (file)
    {
        fprintf(file, "%s", g_currentMap);

        for (new idxMap = 0; idxMap < get_pcvar_num(cvar_banRecent) - 1; ++idxMap)
        {
            fprintf(file, "^n%s", g_recentMap[idxMap]);
        }

        fclose(file);
    }
}

map_loadFillerList(filename[])
{
    return map_populateList(g_fillerMap, filename);
}

public cmd_rockthevote(id)
{
    client_print(id, print_chat, "%L", id, "GAL_CMD_RTV");
    vote_rock(id);
    return PLUGIN_CONTINUE;
}

public cmd_nominations(id)
{
    client_print(id, print_chat, "%L", id, "GAL_CMD_NOMS");
    nomination_list(id);
    return PLUGIN_CONTINUE;
}

public cmd_nextmap(id)
{
    new map[32];
    get_cvar_string("amx_nextmap", map, charsmax(map));
    colored_print(0,"^x01Следующая карта ^x04%s^x01.", map);
    return PLUGIN_CONTINUE;
}

public cmd_currentmap(id)
{
    client_print(0, print_chat, "%L: %s", LANG_PLAYER, "PLAYED_MAP", g_currentMap);
    return PLUGIN_CONTINUE;
}

public cmd_listrecent(id)
{
    switch (get_pcvar_num(cvar_banRecentStyle))
    {
        case 1:
        {
            new msg[101], msgIdx;

            console_print(id, "==== Недавние карты ====");
            for (new idx = 0; idx < g_cntRecentMap; ++idx)
            {
                msgIdx += format(msg[msgIdx], charsmax(msg) - msgIdx, ", %s", g_recentMap[idx]);
                console_print(id, "%s", g_recentMap[idx]);
            }
            colored_print(id, "^x04***^x1 Недавние карты отображены в консоле (~)");
        }
        case 2:
        {
            for (new idx = 0; idx < g_cntRecentMap; ++idx)
            {
                client_print(id, print_chat, "%L (%i): %s", LANG_PLAYER, "GAL_MAP_RECENTMAP", idx+1, g_recentMap[idx]);
            }
        }
    }

    return PLUGIN_HANDLED;
}

public cmd_startVote(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED;

    if (g_voteStatus & VOTE_IN_PROGRESS)
    {
        colored_print(id, "^x04***^x01 Голосование уже началось!");
    }
    else if (g_voteStatus & VOTE_IS_OVER)
    {
        colored_print(id, "^x04***^x01 Голосование истекло");
    }
    else
    {
        // we may not want to actually change the map after outcome of vote is determined
        if (read_argc() == 2)
        {
            new arg[32];
            read_args(arg, charsmax(arg));

            if (equali(arg, "-nochange"))
            {
                g_handleMapChange = false;
            }
        }

        vote_startDirector(true);
    }

    return PLUGIN_HANDLED;
}

map_populateList(Array:mapArray, mapFilename[])
{
    // clear the map array in case we're reusing it
    ArrayClear(mapArray);

    // load the array with maps
    new mapCnt;

    if (!equal(mapFilename, "*"))
    {
        new file = fopen(mapFilename, "rt");
        if (file)
        {
            new buffer[32];

            while (!feof(file))
            {
                fgets(file, buffer, charsmax(buffer));
                trim(buffer);

                if (buffer[0] && !equal(buffer, "//", 2) && !equal(buffer, ";", 1) && is_map_valid(buffer))
                {
                    ArrayPushString(mapArray, buffer);
                    ++mapCnt;
                }
            }
            fclose(file);
        }
        else
        {
            log_error(AMX_ERR_NOTFOUND, "%L", LANG_SERVER, "GAL_MAPS_FILEMISSING", mapFilename);
        }
    }
    else
    {
        // no file provided, assuming contents of "maps" folder
        new dir, mapName[32];
        dir = open_dir("maps", mapName, charsmax(mapName));

        if (dir)
        {
            new lenMapName;

            while (next_file(dir, mapName, charsmax(mapName)))
            {
                lenMapName = strlen(mapName);
                if (lenMapName > 4 && equali(mapName[lenMapName - 4], ".bsp", 4))
                {
                    mapName[lenMapName-4] = '^0';
                    if (is_map_valid(mapName))
                    {
                        ArrayPushString(mapArray, mapName);
                        ++mapCnt;
                    }
                }
            }
            close_dir(dir);
        }
        else
        {
            // directory not found, wtf?
            log_error(AMX_ERR_NOTFOUND, "%L", LANG_SERVER, "GAL_MAPS_FOLDERMISSING");
        }
    }
    return mapCnt;
}

map_loadNominationList()
{
    new filename[256];
    get_pcvar_string(cvar_nomMapFile, filename, charsmax(filename));

    g_nominationMapCnt = map_populateList(g_nominationMap, filename);
}

// grrface, this has no place in a map choosing plugin. just replicating it because it's in AMXX's
public cmd_ff()
{
    client_print(0, print_chat, "%L: %L", LANG_PLAYER, "FRIEND_FIRE", LANG_PLAYER, get_cvar_num("mp_friendlyfire") ? "ON" : "OFF");
    return PLUGIN_CONTINUE;
}

public cmd_createMapFile(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED;

    new cntArg = read_argc() - 1;

    switch (cntArg)
    {
        case 1:
        {
            new arg1[256];
            read_argv(1, arg1, charsmax(arg1));
            remove_quotes(arg1);

            new mapName[MAX_MAPNAME_LEN+5]; // map name is 31 (i.e. MAX_MAPNAME_LEN), ".bsp" is 4, string terminator is 1.
            new dir, file, mapCnt, lenMapName;

            dir = open_dir("maps", mapName, charsmax(mapName));
            if (dir)
            {
                new filename[256];
                formatex(filename, charsmax(filename), "%s/%s", DIR_CONFIGS, arg1);

                file = fopen(filename, "wt");
                if (file)
                {
                    mapCnt = 0;
                    while (next_file(dir, mapName, charsmax(mapName)))
                    {
                        lenMapName = strlen(mapName);

                        if (lenMapName > 4 && equali(mapName[lenMapName - 4], ".bsp", 4))
                        {
                            mapName[lenMapName- 4] = '^0';
                            if (is_map_valid(mapName))
                            {
                                mapCnt++;
                                fprintf(file, "%s^n", mapName);
                            }
                        }
                    }
                    fclose(file);
                    con_print(id, "%L", LANG_SERVER, "GAL_CREATIONSUCCESS", filename, mapCnt);
                }
                else
                {
                    con_print(id, "%L", LANG_SERVER, "GAL_CREATIONFAILED", filename);
                }
                close_dir(dir);
            }
            else
            {
                // directory not found, wtf?
                con_print(id, "%L", LANG_SERVER, "GAL_MAPSFOLDERMISSING");
            }
        }
        default:
        {
            // inform of correct usage
            con_print(id, "%L", id, "GAL_CMD_CREATEFILE_USAGE1");
            con_print(id, "%L", id, "GAL_CMD_CREATEFILE_USAGE2");
        }
    }
    return PLUGIN_HANDLED;
}

map_loadPrefixList()
{
    new filename[256];
    formatex(filename, charsmax(filename), "%s/prefixes.ini", DIR_CONFIGS);

    new file = fopen(filename, "rt");
    if (file)
    {
        new buffer[16];
        while (!feof(file))
        {
            fgets(file, buffer, charsmax(buffer));
            if (buffer[0] && !equal(buffer, "//", 2))
            {
                if (g_mapPrefixCnt <= MAX_PREFIX_CNT)
                {
                    trim(buffer);
                    copy(g_mapPrefix[g_mapPrefixCnt++], charsmax(buffer), buffer);
                }
                else
                {
                    log_error(AMX_ERR_BOUNDS, "%L", LANG_SERVER, "GAL_PREFIXES_TOOMANY", MAX_PREFIX_CNT, filename);
                    break;
                }
            }
        }
        fclose(file);
    }
    else
    {
        log_error(AMX_ERR_NOTFOUND, "%L", LANG_SERVER, "GAL_PREFIXES_NOTFOUND", filename);
    }
    return PLUGIN_HANDLED;
}

map_loadEmptyCycleList()
{
    new filename[256];
    get_pcvar_string(cvar_emptyMapFile, filename, charsmax(filename));

    g_emptyMapCnt = map_populateList(g_emptyCycleMap, filename);
}

public map_manageEnd()
{
    g_pauseMapEndManagerTask = true;

    if (get_realplayersnum() <= 0)  // was 1
    {
        // at most there is only one player on the server, so no need to stay around
        map_change();
    }
    else
    {
        if (get_pcvar_num(cvar_endOnRound) && g_wasLastRound == false)
        {
            // let the server know it's the last round
            g_wasLastRound = true;

            // let the players know it's the last round
            if (g_voteStatus & VOTE_FORCED)
            {
                colored_print(0, "^x04***^x01 После завершения этого раунда карта сменится");
            }
            else
            {
                set_hudmessage(_, _, _, 0.07, -1.0, 2, _, 4.5, 0.2, _, -1);
                ShowSyncHudMsg(0, g_sync_msgdisplay, "Последний раунд");
            }

            // prevent the map from ending automatically
            server_cmd("mp_timelimit 0");
        }
        else
        {
            message_begin(MSG_BROADCAST, SVC_INTERMISSION);
            message_end();
            set_task(floatmax(get_cvar_float("mp_chattime"), 2.0), "map_change");
        }
    }
}

public event_round_start()
{
    g_skip_task_vote_manageEnd = false;

    if (g_wasLastRound)
    {
        server_cmd("mp_freezetime %d", cvar_freezetime);
        server_cmd("bh_starttime %d", cvar_bh_starttime);

        if (g_voteStatus & VOTE_FORCED)
            map_manageEnd();
        else if (!g_vote_running)
            vote_startDirector(false);
    }
}

public logevent_round_end()
{
    g_skip_task_vote_manageEnd = true;

    if (g_wasLastRound)
    {
        ClearSyncHud(0, g_sync_msgdisplay);

        new vote_duration = get_pcvar_num(cvar_voteDuration);
        server_cmd("mp_freezetime %d", vote_duration + 8 + 1);
        server_cmd("bh_starttime %d", vote_duration + 8 + 10);
    }
}

public event_game_commencing()
{
    // make sure the reset time is the original time limit
    // (can be skewed if map was previously extended)
    map_restoreOriginalTimeLimit();
}

public event_intermission()
{
    // don't let the normal end interfere
    g_pauseMapEndManagerTask = true;

    // change the map after "chattime" is over
    set_task(floatmax(get_cvar_float("mp_chattime"), 2.0), "map_change");

    return PLUGIN_CONTINUE;
}

map_getIdx(text[])
{
    new map[MAX_MAPNAME_LEN + 1];
    new mapIdx;
    new nominationMap[32];

    for (new prefixIdx = 0; prefixIdx < g_mapPrefixCnt; ++prefixIdx)
    {
        formatex(map, charsmax(map), "%s%s", g_mapPrefix[prefixIdx], text);

        for (mapIdx = 0; mapIdx < g_nominationMapCnt; ++mapIdx)
        {
            ArrayGetString(g_nominationMap, mapIdx, nominationMap, charsmax(nominationMap));

            if (equal(map, nominationMap))
            {
                return mapIdx;
            }
        }
    }
    return -1;
}

public cmd_say(id)
{
    //-----
    // generic say handler to determine if we need to act on what was said
    //-----

    static text[70], arg1[32], arg2[32], arg3[2];
    read_args(text, charsmax(text));
    remove_quotes(text);
    arg1[0] = '^0';
    arg2[0] = '^0';
    arg3[0] = '^0';
    parse(text, arg1, charsmax(arg1), arg2, charsmax(arg2), arg3, charsmax(arg3));

    // if the chat line has more than 2 words, we're not interested at all
    if (arg3[0] == 0)
    {
        new idxMap;

        // if the chat line contains 1 word, it could be a map or a one-word command
        if (arg2[0] == 0) // "say [rtv|rockthe<anything>vote] or [NEW] nominate for all list of maps"
        {
            if ((get_pcvar_num(cvar_rtvCommands) & RTV_CMD_SHORTHAND && (equali(arg1, "rtv") || equali(arg1, "/rtv"))) || ((get_pcvar_num(cvar_rtvCommands) & RTV_CMD_DYNAMIC && equali(arg1, "rockthe", 7) && equali(arg1[strlen(arg1)-4], "vote"))))
            {
                vote_rock(id);
                return PLUGIN_HANDLED;
            }
            else if (equali(arg1, "nominate"))
            {
                nomination_attempt(id, "_");  // every map name contains 'underscore'
                return PLUGIN_HANDLED;
            }
            else if (get_pcvar_num(cvar_nomPlayerAllowance))
            {
                new first_symbols[5];
                read_args(first_symbols, charsmax(first_symbols));
                if(equali(first_symbols[1], "zm_") || equali(first_symbols[1], "ze_"))
                {
                    new short_piece_of_mapname[7];
                    read_args(short_piece_of_mapname, charsmax(short_piece_of_mapname));
                    nomination_attempt(id, short_piece_of_mapname[1]);
                    return PLUGIN_HANDLED;
                }
                else if (equali(arg1, "noms"))
                {
                    nomination_list(id);
                    return PLUGIN_HANDLED;
                }
                else
                {
                    idxMap = map_getIdx(arg1);
                    if (idxMap >= 0)
                    {
                        nomination_toggle(id, idxMap);
                        return PLUGIN_HANDLED;
                    }
                }
            }
        }
        else if (get_pcvar_num(cvar_nomPlayerAllowance)) // "say <nominate|nom|cancel> <map>"
        {
            if (equali(arg1, "nominate") || equali(arg1, "nom"))
            {
                nomination_attempt(id, arg2);
                return PLUGIN_HANDLED;
            }
            else if (equali(arg1, "cancel"))
            {
                // bpj -- allow ambiguous cancel in which case a menu of their nominations is shown
                idxMap = map_getIdx(arg2);
                if (idxMap >= 0)
                {
                    nomination_cancel(id, idxMap);
                    return PLUGIN_HANDLED;
                }
            }
        }
    }
    return PLUGIN_CONTINUE;
}

nomination_attempt(id, nomination[])
{
    new idxNomination, idxMap;
    new mapCnt;
    new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

    for (new idPlayer = 1; idPlayer <= MAX_PLAYER_CNT; ++idPlayer)
    {
        for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
        {
            idxMap = g_nomination[idPlayer][idxNomination];
            if (idxMap >= 0)
                if (++mapCnt >= get_pcvar_num(cvar_voteMapChoiceCnt))
                {
                    colored_print(id, "^x04***^x01 Все номинации заняты!");
                    nomination_list(id);
                    return PLUGIN_CONTINUE;
                }
        }
    }

    // all map names are stored as lowercase, so normalize the nomination
    strtolower(nomination);

    // assume there'll be more than one match (because we're lazy) and starting building the match menu
    //menu_destroy(g_nominationMatchesMenu[id]);
    g_nominationMatchesMenu[id] = menu_create("\yНоминации", "nomination_handleMatchChoice");

    // gather all maps that match the nomination
    new mapIdx, nominationMap[32], matchCnt = 0, matchIdx = -1, info[1], choice[64], disabledReason[32];
    for (mapIdx = 0; mapIdx < g_nominationMapCnt && matchCnt <= MAX_NOM_MATCH_CNT; ++mapIdx)
    {
        ArrayGetString(g_nominationMap, mapIdx, nominationMap, charsmax(nominationMap));

        if (contain(nominationMap, nomination) > -1)
        {
            matchCnt++;
            matchIdx = mapIdx;  // store in case this is the only match

            // there may be a much better way of doing this, but I didn't feel like
            // storing the matches and mapIdx's only to loop through them again
            info[0] = mapIdx;

            // in most cases, the map will be available for selection, so assume that's the case here
            disabledReason[0] = 0;

            // disable if the map has already been nominated
            if (nomination_getPlayer(mapIdx))
            {
                formatex(disabledReason, charsmax(disabledReason), "(уже выбрана)");
            }
            // disable if the map is too recent
            else if (map_isTooRecent(nominationMap))
            {
                formatex(disabledReason, charsmax(disabledReason), "(была недавно)");
            }
            else if (equal(g_currentMap, nominationMap))
            {
                formatex(disabledReason, charsmax(disabledReason), "(текущая карта)");
            }

            formatex(choice, charsmax(disabledReason), "%s %s", nominationMap, disabledReason);
            menu_additem(g_nominationMatchesMenu[id], choice, info, (disabledReason[0] == 0) ? 0 : (1<<26));
        }
    }

    menu_setprop(g_nominationMatchesMenu[id], 2, "Назад");
    menu_setprop(g_nominationMatchesMenu[id], 3, "Вперед");
    menu_setprop(g_nominationMatchesMenu[id], 4, "Закрыть");

    // handle the number of matches
    switch (matchCnt)
    {
        case 0:
        {
            // no matches; pity the poor fool
            client_print(id, print_chat, "%L", id, "GAL_NOM_FAIL_NOMATCHES", nomination);
        }
        case 1:
        {
            // one match?! omg, this is just like awesome
            map_nominate(id, matchIdx);

        }
        default:
        {
            menu_display(id, g_nominationMatchesMenu[id]);
        }
    }

    return PLUGIN_CONTINUE;
}

public nomination_handleMatchChoice(id, menu, item)
{
    if( item < 0 )
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }

    // Get item info
    new mapIdx, info[1];
    new access, callback;

    menu_item_getinfo(g_nominationMatchesMenu[id], item, access, info, 1, _, _, callback);

    mapIdx = info[0];
    map_nominate(id, mapIdx);

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

nomination_getPlayer(idxMap)
{
    // check if the map has already been nominated
    new idxNomination;
    new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

    for (new idPlayer = 1; idPlayer <= MAX_PLAYER_CNT; ++idPlayer)
    {
        for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
        {
            if (idxMap == g_nomination[idPlayer][idxNomination])
            {
                return idPlayer;
            }
        }
    }
    return 0;
}

nomination_toggle(id, idxMap)
{
    new idNominator = nomination_getPlayer(idxMap);
    if (idNominator == id)
    {
        nomination_cancel(id, idxMap);
    }
    else
    {
        map_nominate(id, idxMap, idNominator);
    }
}

nomination_cancel(id, idxMap)
{
    // cancellations can only be made if a vote isn't already in progress
    if (g_voteStatus & VOTE_IN_PROGRESS)
    {
        colored_print(id, "^x04***^x01 Голосование уже началось!");
        return;
    }
    // and if the outcome of the vote hasn't already been determined
    else if (g_voteStatus & VOTE_IS_OVER)
    {
        colored_print(id, "^x04***^x01 Голосование уже завершилось!");
        return;
    }

    new bool:nominationFound, idxNomination;
    new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

    for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
    {
        if (g_nomination[id][idxNomination] == idxMap)
        {
            nominationFound = true;
            break;
        }
    }

    new mapName[32];
    ArrayGetString(g_nominationMap, idxMap, mapName, charsmax(mapName));

    if (nominationFound)
    {
        g_nomination[id][idxNomination] = -1;
        g_nominationCnt--;

        nomination_announceCancellation(mapName);
    }
    else
    {
        new idNominator = nomination_getPlayer(idxMap);
        if (idNominator)
        {
            new name[32];
            get_user_name(idNominator, name, charsmax(name));

            colored_print(id, "^x04***^x01 Карта^x04 %s^x01 уже выбрана игроком^x03 %s^x01!", mapName, name);
        }
        else
        {
            colored_print(id, "^x04***^x01 Ты еще не выбирал^x04 %s^x01!", mapName);
        }
    }
}

map_nominate(id, idxMap, idNominator = -1)
{
    // nominations can only be made if a vote isn't already in progress
    if (g_voteStatus & VOTE_IN_PROGRESS)
    {
        colored_print(id, "^x04***^x01 Голосование уже началось!");
        return;
    }
    // and if the outcome of the vote hasn't already been determined
    else if (g_voteStatus & VOTE_IS_OVER)
    {
        colored_print(id, "^x04***^x01 Голосование уже завершилось!");
        return;
    }

    if (get_count_of_nominations() >= get_pcvar_num(cvar_voteMapChoiceCnt))
    {
        colored_print(id, "^x04***^x01 Все номинации уже заняты!");
        nomination_list(id);
        return;
    }

    new mapName[32];
    ArrayGetString(g_nominationMap, idxMap, mapName, charsmax(mapName));

    // players can not nominate the current map
    if (equal(g_currentMap, mapName))
    {
        colored_print(id, "^x04***^x01 Ты сейчас на карте^x04 %s^x01!", g_currentMap);
        return;
    }

    // players may not be able to nominate recently played maps
    if (map_isTooRecent(mapName))
    {
        colored_print(id, "^x04***^x01 На карте^x04 %s^x01 играли недавно!", mapName);
        return;
    }

    // check if the map has already been nominated
    if (idNominator == -1)
    {
        idNominator = nomination_getPlayer(idxMap);
    }

    if (idNominator == 0)
    {
        // determine the number of nominations the player already made
        // and grab an open slot with the presumption that the player can make the nomination
        new nominationCnt = 0, idxNominationOpen, idxNomination;
        new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

        for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
        {
            if (g_nomination[id][idxNomination] >= 0)
            {
                nominationCnt++;
            }
            else
            {
                idxNominationOpen = idxNomination;
            }
        }

        if (nominationCnt == playerNominationMax)
        {
            new nominatedMaps[256], buffer[32];
            for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
            {
                idxMap = g_nomination[id][idxNomination];
                ArrayGetString(g_nominationMap, idxMap, buffer, charsmax(buffer));
                format(nominatedMaps, charsmax(nominatedMaps), "%s%s%s", nominatedMaps, (idxNomination == 1) ? "" : ", ", buffer);
            }

            colored_print(id, "^x04***^x01 Ты уже номинировал карту^x04 %s", nominatedMaps);
        }
        else
        {
            // otherwise, allow the nomination
            g_nomination[id][idxNominationOpen] = idxMap;
            g_nominationCnt++;
            map_announceNomination(id, mapName);
        }
    }
    else if (idNominator == id)
    {
        colored_print(id, "^x04***^x01 Ты уже выбрал эту карту^x04 %s^x01 !", mapName);
    }
    else
    {
        new name[32];
        get_user_name(idNominator, name, charsmax(name));

        colored_print(id, "^x04***^x03 %s^x01 уже выбрал эту карту^x04 %s^x01 !", name, mapName);
    }
}

get_count_of_nominations()
{
    new mapCnt = 0;
    new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

    for (new idPlayer = 1; idPlayer <= MAX_PLAYER_CNT; ++idPlayer)
    {
        for (new idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
        {
            if (g_nomination[idPlayer][idxNomination] >= 0)
            {
                mapCnt++;
            }
        }
    }

    return mapCnt;
}

nomination_list(id)
{
    new idxNomination, idxMap;
    new msg[101];
    new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);
    new mapName[32];

    for (new idPlayer = 1; idPlayer <= MAX_PLAYER_CNT; ++idPlayer)
    {
        for (idxNomination = 1; idxNomination <= playerNominationMax; ++idxNomination)
        {
            idxMap = g_nomination[idPlayer][idxNomination];
            if (idxMap >= 0)
            {
                ArrayGetString(g_nominationMap, idxMap, mapName, charsmax(mapName));
                format(msg, charsmax(msg), "%s,^x04 %s^x01", msg, mapName);
            }
        }
    }
    if (msg[0])
    {
        colored_print(id, "^x04***^x01 Выбор игроков: %s", msg[1]);
    }
    else
    {
        colored_print(id, "^x04***^x01 Выбранных карт нет");
    }
}

public vote_startDirector(bool:forced)
{
    g_vote_running = true;

    new choicesLoaded, voteDuration;

    if (g_voteStatus & VOTE_IS_RUNOFF)
    {
        choicesLoaded = vote_loadRunoffChoices();
        voteDuration = get_pcvar_num(cvar_runoffDuration);
    }
    else
    {
        // make it known that a vote is in progress
        g_voteStatus |= VOTE_IN_PROGRESS;

        // stop RTV reminders
        remove_task(TASKID_REMINDER);

        // set nextmap to "voting"
        if (forced || get_pcvar_num(cvar_endOfMapVote))
        {
            new nextMap[32];
            formatex(nextMap, charsmax(nextMap), "%L", LANG_SERVER, "GAL_NEXTMAP_VOTING");
            map_setNext(nextMap);
        }

        // pause the "end of map" tasks so they don't interfere
        g_pauseMapEndVoteTask = true;
        g_pauseMapEndManagerTask = true;

        if (forced)
        {
            g_voteStatus |= VOTE_FORCED;
        }

        choicesLoaded = vote_loadChoices();
        voteDuration = get_pcvar_num(cvar_voteDuration);

        if (choicesLoaded)
        {
            // clear all nominations
            nomination_clearAll();
        }
    }

    if (choicesLoaded)
    {
        // alphabetize the maps
        // SortCustom2D(g_mapChoice, choicesLoaded, "sort_stringsi");

        // mark the players who are in this vote for use later
        new player[32], playerCnt;
        get_players(player, playerCnt);
        for (new idxPlayer = 0; idxPlayer < playerCnt; ++idxPlayer)
        {
            g_voted[player[idxPlayer]] = false;
        }

        // make perfunctory announcement: "get ready to choose a map"
        if (!(get_pcvar_num(cvar_soundsMute) & SOUND_GETREADYTOCHOOSE) && forced)
        {
            client_cmd(0, "spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"");
        }

        // announce the pending vote countdown from 3 to 1
        set_task(1.0, "vote_countdownPendingVote", _, _, _, "a", 3);

        // display the map choices
        set_task(4.5, "vote_handleDisplay");

        // display the vote outcome
        if (get_pcvar_num(cvar_voteStatus))
        {
            new arg[3] = {-1, -1, false}; // indicates it's the end of vote display
            set_task(4.5 + float(voteDuration) + 1.0, "vote_display", _, arg, 3);
            set_task(4.5 + float(voteDuration) + 2.0, "vote_expire");
        }
        else
        {
            set_task(4.5 + float(voteDuration) + 1.0, "vote_expire");
        }
    }
    else
    {
        client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_VOTE_NOMAPS");
    }
}

public vote_countdownPendingVote()
{
    static countdown = 3;

    // visual countdown
    set_hudmessage(0, 222, 50, -1.0, 0.13, 0, 1.0, 0.94, 0.0, 0.0, -1);
    show_hudmessage(0, "Голосование через %d...", countdown);

    // audio countdown
    if (!(get_pcvar_num(cvar_soundsMute) & SOUND_COUNTDOWN))
    {
        new word[6];
        num_to_word(countdown, word, 5);

        client_cmd(0, "spk ^"fvox/%s^"", word);
    }

    // decrement the countdown
    countdown--;

    if (countdown == 0)
    {
        countdown = 7;
    }
}

vote_addNominations()
{
    if (g_nominationCnt)
    {
        // set how many total nominations we can use in this vote
        new maxNominations = get_pcvar_num(cvar_nomQtyUsed);
        new slotsAvailable = g_choiceMax - g_choiceCnt;
        new voteNominationMax = (maxNominations) ? min(maxNominations, slotsAvailable) : slotsAvailable;

        // set how many total nominations each player is allowed
        new playerNominationMax = min(get_pcvar_num(cvar_nomPlayerAllowance), MAX_NOMINATION_CNT);

        // add as many nominations as we can
        // [TODO: develop a better method of determining which nominations make the cut; either FIFO or random]
        new idxMap, id, mapName[32];

        for (new idxNomination = playerNominationMax; idxNomination >= 1; --idxNomination)
        {
            for (id = 1; id <= MAX_PLAYER_CNT; ++id)
            {
                idxMap = g_nomination[id][idxNomination];
                if (idxMap >= 0)
                {
                    ArrayGetString(g_nominationMap, idxMap, mapName, charsmax(mapName));
                    copy(g_mapChoice[g_choiceCnt++], charsmax(g_mapChoice[]), mapName);

                    if (g_choiceCnt == voteNominationMax)
                    {
                        break;
                    }
                }
            }
            if (g_choiceCnt == voteNominationMax)
            {
                break;
            }
        }
    }
}

vote_addFiller()
{
    if (g_choiceCnt == g_choiceMax)
    {
        return;
    }

    // grab the name of the filler file
    new filename[256];
    get_pcvar_string(cvar_voteMapFile, filename, charsmax(filename));

    // create an array of files that will be pulled from
    new fillerFile[8][256];
    new mapsPerGroup[8], groupCnt;

    if (!equal(filename, "*"))
    {
        // determine what kind of file it's being used as
        new file = fopen(filename, "rt");
        if (file)
        {
            new buffer[16];
            fgets(file, buffer, charsmax(buffer));
            trim(buffer);
            fclose(file);

            if (equali(buffer, "[groups]"))
            {
                // read the filler file to determine how many groups there are (max of 8)
                new groupIdx;

                file = fopen(filename, "rt");

                while (!feof(file))
                {
                    fgets(file, buffer, charsmax(buffer));
                    trim(buffer);

                    if (isdigit(buffer[0]))
                    {
                        if (groupCnt < 8)
                        {
                            groupIdx = groupCnt++;
                            mapsPerGroup[groupIdx] = str_to_num(buffer);
                            formatex(fillerFile[groupIdx], charsmax(fillerFile[]), "%s/%i.ini", DIR_CONFIGS, groupCnt);
                        }
                        else
                        {
                            log_error(AMX_ERR_BOUNDS, "%L", LANG_SERVER, "GAL_GRP_FAIL_TOOMANY", filename);
                            break;
                        }
                    }
                }

                fclose(file);

                if (groupCnt == 0)
                {
                    log_error(AMX_ERR_GENERAL, "%L", LANG_SERVER, "GAL_GRP_FAIL_NOCOUNTS", filename);
                    return;
                }
            }
            else
            {
                // we presume it's a listing of maps, ala mapcycle.txt
                copy(fillerFile[0], charsmax(filename), filename);
                mapsPerGroup[0] = 8;
                groupCnt = 1;
            }
        }
        else
        {
            log_error(AMX_ERR_NOTFOUND, "%L", LANG_SERVER, "GAL_FILLER_NOTFOUND", fillerFile);
        }
    }
    else
    {
        // we'll be loading all maps in the /maps folder
        copy(fillerFile[0], charsmax(filename), filename);
        mapsPerGroup[0] = 8;
        groupCnt = 1;
    }

    // fill remaining slots with random maps from each filler file, as much as possible
    new mapCnt, mapKey, allowedCnt, unsuccessfulCnt, choiceIdx, mapName[32];

    for (new groupIdx = 0; groupIdx < groupCnt; ++groupIdx)
    {
        mapCnt = map_loadFillerList(fillerFile[groupIdx]);

        if (g_choiceCnt < g_choiceMax && mapCnt)
        {
            unsuccessfulCnt = 0;
            allowedCnt = min(min(mapsPerGroup[groupIdx], g_choiceMax - g_choiceCnt), mapCnt);

            for (choiceIdx = 0; choiceIdx < allowedCnt; ++choiceIdx)
            {
                mapKey = random_num(0, mapCnt - 1);
                ArrayGetString(g_fillerMap, mapKey, mapName, charsmax(mapName));
                unsuccessfulCnt = 0;

                while ((map_isInMenu(mapName) || equal(g_currentMap, mapName) || map_isTooRecent(mapName) || prefix_isInMenu(mapName)) && unsuccessfulCnt < mapCnt)
                {
                    unsuccessfulCnt++;
                    if (++mapKey == mapCnt)
                    {
                        mapKey = 0;
                    }
                    ArrayGetString(g_fillerMap, mapKey, mapName, charsmax(mapName));
                }

                if (unsuccessfulCnt == mapCnt)
                {
                    // there aren't enough maps in this filler file to continue adding anymore
                    break;
                }

                copy(g_mapChoice[g_choiceCnt++], charsmax(g_mapChoice[]), mapName);
            }
        }
    }
}

vote_loadChoices()
{
    vote_addNominations();
    vote_addFiller();

    return g_choiceCnt;
}

vote_loadRunoffChoices()
{
    new choiceCnt;

    new runoffChoice[2][MAX_MAPNAME_LEN+1];
    copy(runoffChoice[0], charsmax(runoffChoice[]), g_mapChoice[g_runoffChoice[0]]);
    copy(runoffChoice[1], charsmax(runoffChoice[]), g_mapChoice[g_runoffChoice[1]]);

    new mapIdx;
    if (g_runoffChoice[0] != g_choiceCnt)
    {
        copy(g_mapChoice[mapIdx++], charsmax(g_mapChoice[]), runoffChoice[0]);
        choiceCnt++;
    }
    if (g_runoffChoice[1] != g_choiceCnt)
    {
        choiceCnt++;
    }
    copy(g_mapChoice[mapIdx], charsmax(g_mapChoice[]), runoffChoice[1]);

    g_choiceCnt = choiceCnt;

    return choiceCnt;
}

public vote_handleDisplay()
{
    // announce: "time to choose"
    if (!(get_pcvar_num(cvar_soundsMute) & SOUND_TIMETOCHOOSE))
    {
        client_cmd(0, "spk Gman/Gman_Choose%i", random_num(1, 2));
    }

    if (g_voteStatus & VOTE_IS_RUNOFF)
    {
        g_voteDuration = get_pcvar_num(cvar_runoffDuration);
    }
    else
    {
        g_voteDuration = get_pcvar_num(cvar_voteDuration);
    }

    if (get_pcvar_num(cvar_voteStatus) && get_pcvar_num(cvar_voteStatusType) == SHOWSTATUSTYPE_PERCENTAGE)
    {
        copy(g_voteTallyType, charsmax(g_voteTallyType), "%");
    }

    // make sure the display is contructed from scratch
    g_refreshVoteStatus = true;

    // ensure the vote status doesn't indicate expired
    g_voteStatus &= ~VOTE_HAS_EXPIRED;

    new arg[3];
    arg[0] = true;
    arg[1] = 0;
    arg[2] = false;

    if (get_pcvar_num(cvar_voteStatus) == SHOWSTATUS_VOTE)
    {
        set_task(1.0, "vote_display", _, arg, sizeof(arg), "a", g_voteDuration);
    }
    else
    {
        set_task(1.0, "vote_display", _, arg, sizeof(arg));
    }
}

public vote_display(arg[3])
{
    static allKeys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;
    static keys, voteStatus[512], voteTally[16];

    new updateTimeRemaining = arg[0];
    new id = arg[1];

    if (id > 0 && g_snuffDisplay[id])
    {
        new unsnuffDisplay = arg[2];
        if (unsnuffDisplay)
        {
            g_snuffDisplay[id] = false;
        }
        else
        {
            return;
        }
    }

    new isVoteOver = (updateTimeRemaining == -1 && id == -1);
    new charCnt;

    if (g_refreshVoteStatus || isVoteOver)
    {
        // wipe the previous vote status clean
        voteStatus[0] = 0;
        keys = MENU_KEY_0;

        new voteCnt;

        new allowStay = (g_voteStatus & VOTE_IS_EARLY);

        new isRunoff = (g_voteStatus & VOTE_IS_RUNOFF);
        new bool:allowExtend = !allowStay && ((isRunoff && g_choiceCnt == 1) || (!(g_voteStatus & VOTE_FORCED) && !isRunoff && get_cvar_float("mp_timelimit") < get_pcvar_float(cvar_extendmapMax)));

        // add the header
        if (isVoteOver)
        {
            charCnt = formatex(voteStatus, charsmax(voteStatus), "%sРезультат голосования:^n", CLR_YELLOW);
        }
        else
        {
            charCnt = formatex(voteStatus, charsmax(voteStatus), "%sВыбери следующую карту:^n", CLR_YELLOW);
        }

        // add maps to the menu
        for (new choiceIdx = 0; choiceIdx < g_choiceCnt; ++choiceIdx)
        {
            voteCnt = g_mapVote[choiceIdx];
            vote_getTallyStr(voteTally, charsmax(voteTally), voteCnt);

            charCnt += formatex(voteStatus[charCnt], charsmax(voteStatus)-charCnt, "^n%s%i. %s%s%s", CLR_RED, choiceIdx+1, CLR_WHITE, g_mapChoice[choiceIdx], voteTally);
            keys |= (1<<choiceIdx);
        }

        // add optional menu item
        if (allowExtend || allowStay)
        {
            // if it's not a runoff vote, add a space between the maps and the additional option
            if (g_voteStatus & VOTE_IS_RUNOFF == 0)
            {
                charCnt += formatex(voteStatus[charCnt], charsmax(voteStatus)-charCnt, "^n");
            }

            vote_getTallyStr(voteTally, charsmax(voteTally), g_mapVote[g_choiceCnt]);

            if (allowExtend)
            {
                // add the "Extend Map" menu item.
                charCnt += formatex(voteStatus[charCnt], charsmax(voteStatus)-charCnt, "^n%s%i. %s%L%s", CLR_RED, g_choiceCnt+1, CLR_WHITE, LANG_SERVER, "GAL_OPTION_EXTEND", g_currentMap, floatround(get_pcvar_float(cvar_extendmapStep)), voteTally);
            }
            else
            {
                // add the "Stay Here" menu item
                charCnt += formatex(voteStatus[charCnt], charsmax(voteStatus)-charCnt, "^n%s%i. %s%L%s", CLR_RED, g_choiceCnt+1, CLR_WHITE, LANG_SERVER, "GAL_OPTION_STAY", voteTally);
            }

            keys |= (1<<g_choiceCnt);
        }

        // make a copy of the virgin menu
        if (g_vote[0] == 0)
        {
            new cleanCharCnt = copy(g_vote, charsmax(g_vote), voteStatus);

            // append a "None" option on for people to choose if they don't like any other choice
            formatex(g_vote[cleanCharCnt], charsmax(g_vote)-cleanCharCnt, "^n^n%s0. %sНичего", CLR_RED, CLR_WHITE);
        }

        charCnt += formatex(voteStatus[charCnt], charsmax(voteStatus)-charCnt, "^n^n");

        g_refreshVoteStatus = false;
    }

    static voteFooter[32];
    if (updateTimeRemaining && get_pcvar_num(cvar_voteExpCountdown))
    {
        charCnt = copy(voteFooter, charsmax(voteFooter), "^n^n");

        if (--g_voteDuration <= 10)
        {
            formatex(voteFooter[charCnt], charsmax(voteFooter)-charCnt, "%sОсталось %s%i%sс", CLR_WHITE, CLR_RED, g_voteDuration, CLR_WHITE);
        }
    }

    // create the different displays
    static menuClean[512], menuDirty[512];
    menuClean[0] = 0;
    menuDirty[0] = 0;

    formatex(menuClean, charsmax(menuClean), "%s%s", g_vote, voteFooter);
    if (!isVoteOver)
    {
        formatex(menuDirty, charsmax(menuDirty), "%s%s", voteStatus, voteFooter);
    }
    else
    {
        formatex(menuDirty, charsmax(menuDirty), "%s^n^n%sГолосование окончено.", voteStatus, CLR_YELLOW);
    }

    new menuid, menukeys;

    // display the vote
    new showStatus = get_pcvar_num(cvar_voteStatus);
    if (id > 0)
    {
        // optionally display to single player that just voted
        if (showStatus == SHOWSTATUS_VOTE)
        {
            get_user_menu(id, menuid, menukeys);
            if (menuid == 0 || menuid == g_menuChooseMap)
            {
                show_menu(id, allKeys, menuDirty, max(1, g_voteDuration), MENU_CHOOSEMAP);
            }
        }
    }
    else
    {
        // display to everyone
        new players[32], playerCnt;
        get_players(players, playerCnt);

        for (new playerIdx = 0; playerIdx < playerCnt; ++playerIdx)
        {
            id = players[playerIdx];

            if (g_voted[id] == false && !isVoteOver)
            {
                get_user_menu(id, menuid, menukeys);
                if (menuid == 0 || menuid == g_menuChooseMap)
                {
                    show_menu(id, keys, menuClean, g_voteDuration, MENU_CHOOSEMAP);
                }
            }
            else
            {
                if ((isVoteOver && showStatus) || (showStatus == SHOWSTATUS_VOTE && g_voted[id]))
                {
                    get_user_menu(id, menuid, menukeys);
                    if (menuid == 0 || menuid == g_menuChooseMap)
                    {
                        show_menu(id, allKeys, menuDirty, (isVoteOver) ? 5 : max(1, g_voteDuration), MENU_CHOOSEMAP);
                    }
                }
            }
        }
    }
}

vote_getTallyStr(voteTally[], voteTallyLen, voteCnt)
{
    if (voteCnt && get_pcvar_num(cvar_voteStatusType) == SHOWSTATUSTYPE_PERCENTAGE)
    {
        voteCnt = percent(voteCnt, g_votesCast);
    }

    if (get_pcvar_num(cvar_voteStatus) && voteCnt)
    {
        formatex(voteTally, voteTallyLen, " %s(%i%s)", CLR_GREY, voteCnt, g_voteTallyType);
    }
    else
    {
        voteTally[0] = 0;
    }
}

public vote_expire()
{
    g_voteStatus |= VOTE_HAS_EXPIRED;

    g_vote[0] = 0;

    // determine the number of votes for 1st and 2nd place
    new firstPlaceVoteCnt, secondPlaceVoteCnt, totalVotes;
    for (new idxChoice = 0; idxChoice <= g_choiceCnt; ++idxChoice)
    {
        totalVotes += g_mapVote[idxChoice];

        if (firstPlaceVoteCnt < g_mapVote[idxChoice])
        {
            secondPlaceVoteCnt = firstPlaceVoteCnt;
            firstPlaceVoteCnt = g_mapVote[idxChoice];
        }
        else if (secondPlaceVoteCnt < g_mapVote[idxChoice])
        {
            secondPlaceVoteCnt = g_mapVote[idxChoice];
        }
    }

    // determine which maps are in 1st and 2nd place
    new firstPlace[MAX_MAPS_IN_VOTE + 1], firstPlaceCnt;
    new secondPlace[MAX_MAPS_IN_VOTE + 1], secondPlaceCnt;

    for (new idxChoice = 0; idxChoice <= g_choiceCnt; ++idxChoice)
    {
        if (g_mapVote[idxChoice] == firstPlaceVoteCnt)
        {
            firstPlace[firstPlaceCnt++] = idxChoice;
        }
        else if (g_mapVote[idxChoice] == secondPlaceVoteCnt)
        {
            secondPlace[secondPlaceCnt++] = idxChoice;
        }
    }

    // announce the outcome
    new idxWinner;
    if (firstPlaceVoteCnt)
    {
        // start a runoff vote, if needed
        if (get_pcvar_num(cvar_runoffEnabled) && !(g_voteStatus & VOTE_IS_RUNOFF))
        {
            // if the top vote getting map didn't receive over 50% of the votes cast, start runoff vote
            if (firstPlaceVoteCnt <= totalVotes / 2)
            {
                // announce runoff voting requirement
                client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_RUNOFF_REQUIRED");
                if (!(get_pcvar_num(cvar_soundsMute) & SOUND_RUNOFFREQUIRED))
                {
                    client_cmd(0, "spk ^"run officer(e40) voltage(e30) accelerating(s70) is required^"");
                }

                // let the server know the next vote will be a runoff
                g_voteStatus |= VOTE_IS_RUNOFF;

                // determine the two choices that will be facing off
                new choice1Idx, choice2Idx;
                if (firstPlaceCnt > 2)
                {
                    choice1Idx = random_num(0, firstPlaceCnt - 1);
                    choice2Idx = random_num(0, firstPlaceCnt - 1);

                    if (choice2Idx == choice1Idx)
                    {
                        choice2Idx = (choice2Idx == firstPlaceCnt - 1) ? 0 : ++choice2Idx;
                    }

                    g_runoffChoice[0] = firstPlace[choice1Idx];
                    g_runoffChoice[1] = firstPlace[choice2Idx];

                    client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_RESULT_TIED1", firstPlaceCnt);
                }
                else if (firstPlaceCnt == 2)
                {
                    g_runoffChoice[0] = firstPlace[0];
                    g_runoffChoice[1] = firstPlace[1];
                }
                else if (secondPlaceCnt == 1)
                {
                    g_runoffChoice[0] = firstPlace[0];
                    g_runoffChoice[1] = secondPlace[0];
                }
                else
                {
                    g_runoffChoice[0] = firstPlace[0];
                    g_runoffChoice[1] = secondPlace[random_num(0, secondPlaceCnt - 1)];

                    client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_RESULT_TIED2", secondPlaceCnt);
                }

                // clear all the votes
                vote_resetStats();

                // start the runoff vote
                set_task(5.0, "vote_startDirector");

                return;
            }
        }

        // if there is a tie for 1st, randomly select one as the winner
        if (firstPlaceCnt > 1)
        {
            idxWinner = firstPlace[random_num(0, firstPlaceCnt - 1)];
            colored_print(0, "Следующая карта произвольно выбрана из %d с равными голосами", firstPlaceCnt);
        }
        else
        {
            idxWinner = firstPlace[0];
        }

        if (idxWinner == g_choiceCnt)
        {
            if (get_pcvar_num(cvar_endOfMapVote))
            {
                new nextMap[32];
                formatex(nextMap, charsmax(nextMap), "%L", LANG_SERVER, "GAL_NEXTMAP_UNKNOWN");
                map_setNext(nextMap);
            }

            // restart map end vote task
            g_pauseMapEndVoteTask = false;

            if (g_voteStatus & VOTE_IS_EARLY)
            {
                // "stay here" won
                client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_WINNER_STAY");

                // clear all the votes
                vote_resetStats();

                // no longer is an early vote
                g_voteStatus &= ~VOTE_IS_EARLY;
            }
            else
            {
                // "extend map" won
                client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_WINNER_EXTEND", floatround(get_pcvar_float(cvar_extendmapStep)));
                map_extend();
            }
        }
        else
        {
            map_setNext(g_mapChoice[idxWinner]);
            server_exec();

            colored_print(0,"^x01Следующая карта ^x04%s^x01.", g_mapChoice[idxWinner]);
            log_amx("[ Galileo ] Nextmap is %s", g_mapChoice[idxWinner]);

            g_voteStatus |= VOTE_IS_OVER;
        }
    }
    else
    {
        // nobody voted. pick a random map from the choices provided.
        idxWinner = random_num(0, g_choiceCnt - 1);
        map_setNext(g_mapChoice[idxWinner]);

        client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_WINNER_RANDOM", g_mapChoice[idxWinner]);

        g_voteStatus |= VOTE_IS_OVER;
    }

    g_refreshVoteStatus = true;

    new playerCnt = get_realplayersnum();

    // vote is no longer in progress
    g_voteStatus &= ~VOTE_IN_PROGRESS;

    if (g_handleMapChange)
    {
        if ((g_voteStatus & VOTE_FORCED || (playerCnt == 1 && idxWinner < g_choiceCnt) || playerCnt == 0))
        {
            // tell the map we need to finish up
            set_task(2.0, "map_manageEnd");
        }
        else
        {
            // restart map end task
            g_pauseMapEndManagerTask = false;
            map_manageEnd();
        }
    }
}

map_extend()
{
    // reset the "rtv wait" time, taking into consideration the map extension
    if (g_rtvWait)
    {
        g_rtvWait = get_cvar_float("mp_timelimit") + g_rtvWait;
    }

    // do that actual map extension
    set_cvar_float("mp_timelimit", get_cvar_float("mp_timelimit") + get_pcvar_float(cvar_extendmapStep));
    server_exec();

    // clear vote stats
    vote_resetStats();

    // if we were in a runoff mode, get out of it
    g_voteStatus &= ~VOTE_IS_RUNOFF;
}

vote_resetStats()
{
    g_votesCast = 0;
    arrayset(g_mapVote, 0, MAX_MAPS_IN_VOTE + 1);
    // reset everyones' rocks
    arrayset(g_rockedVote, false, sizeof(g_rockedVote));
    g_rockedVoteCnt = 0;
}

map_isInMenu(map[])
{
    for (new idxChoice = 0; idxChoice < g_choiceCnt; ++idxChoice)
    {
        if (equal(map, g_mapChoice[idxChoice]))
        {
            return true;
        }
    }
    return false;
}

prefix_isInMenu(map[])
{
    if (get_pcvar_num(cvar_voteUniquePrefixes))
    {
        new tentativePrefix[8], existingPrefix[8], junk[8];

        strtok(map, tentativePrefix, charsmax(tentativePrefix), junk, charsmax(junk), '_', 1);

        for (new idxChoice = 0; idxChoice < g_choiceCnt; ++idxChoice)
        {
            strtok(g_mapChoice[idxChoice], existingPrefix, charsmax(existingPrefix), junk, charsmax(junk), '_', 1);

            if (equal(tentativePrefix, existingPrefix))
            {
                return true;
            }
        }
    }
    return false;
}

map_isTooRecent(map[])
{
    if (get_pcvar_num(cvar_banRecent))
    {
        for (new idxBannedMap = 0; idxBannedMap < g_cntRecentMap; ++idxBannedMap)
        {
            if (equal(map, g_recentMap[idxBannedMap]))
            {
                return true;
            }
        }
    }
    return false;
}

public vote_handleChoice(id, key)
{
    if (g_voteStatus & VOTE_HAS_EXPIRED)
    {
        client_cmd(id, "^"slot%i^"", key + 1);
        return;
    }

    g_snuffDisplay[id] = true;

    if (g_voted[id] == false)
    {
        new name[32];
        if (get_pcvar_num(cvar_voteAnnounceChoice))
        {
            get_user_name(id, name, charsmax(name));
        }

        // confirm the player's choice
        if (key == 9)
        {
            if (get_pcvar_num(cvar_voteAnnounceChoice))
            {
                client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_CHOICE_NONE_ALL", name);
            }
            else
            {
                colored_print(id, "^x04***^x01 Ты решил не принимать участия в голосовании");
            }
        }
        else
        {
            // increment votes cast count
            g_votesCast++;

            if (key == g_choiceCnt)
            {
                // only display the "none" vote if we haven't already voted (we can make it here from the vote status menu too)
                if (g_voted[id] == false)
                {
                    if (get_pcvar_num(cvar_voteAnnounceChoice))
                    {
                        client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_CHOICE_EXTEND_ALL", name);
                    }
                    else
                    {
                        client_print(id, print_chat, "%L", id, "GAL_CHOICE_EXTEND");
                    }
                }
            }
            else
            {
                if (get_pcvar_num(cvar_voteAnnounceChoice))
                {
                    client_print(0, print_chat, "%L", LANG_PLAYER, "GAL_CHOICE_MAP_ALL", name, g_mapChoice[key]);
                }
                else
                {
                    colored_print(id, "^x04***^x01 Ты выбрал карту^x04 %s", g_mapChoice[key]);
                }
            }

            // register the player's choice giving extra weight to admin votes
            new voteWeight = get_pcvar_num(cvar_voteWeight);
            if (voteWeight > 1 && has_flag(id, g_voteWeightFlags))
            {
                g_mapVote[key] += voteWeight;
                g_votesCast += (voteWeight - 1);
            }
            else
            {
                g_mapVote[key]++;
            }
        }

        g_voted[id] = true;
        g_refreshVoteStatus = true;
    }
    else
    {
        client_cmd(id, "^"slot%i^"", key + 1);
    }

    // display the vote again, with status
    if (get_pcvar_num(cvar_voteStatus) == SHOWSTATUS_VOTE)
    {
        new arg[3];
        arg[0] = false;
        arg[1] = id;
        arg[2] = true;

        set_task(0.1, "vote_display", _, arg, sizeof(arg));
    }
}

public map_change()
{
    // restore the map's timelimit, just in case we had changed it
    map_restoreOriginalTimeLimit();

    // grab the name of the map we're changing to
    new map[MAX_MAPNAME_LEN + 1];
    get_cvar_string("amx_nextmap", map, charsmax(map));

    // verify we're changing to a valid map
    if (!is_map_valid(map))
    {
        // probably admin did something dumb like changed the map time limit below
        // the time remaining in the map, thus making the map over immediately.
        // since the next map is unknown, just restart the current map.
        copy(map, charsmax(map), g_currentMap);

        // uselesss but keep compiling out of errors
        if (g_pauseMapEndVoteTask)
            copy(map, charsmax(map), g_currentMap);
    }

    // change to the map
    engine_changelevel(map);
}

Float:map_getMinutesElapsed()
{
    return get_cvar_float("mp_timelimit") - (float(get_timeleft()) / 60.0);
}

vote_rock(id)
{
    // if an early vote is pending, don't allow any rocks
    if (g_voteStatus & VOTE_IS_EARLY)
    {
        colored_print(id, "^x04***^x01 Голосование начнется через пару минут");
        return;
    }

    new Float:minutesElapsed = map_getMinutesElapsed();

    // rocks can only be made if a vote isn't already in progress
    if (g_voteStatus & VOTE_IN_PROGRESS)
    {
        colored_print(id, "^x04***^x01 Голосование уже началось!");
        return;
    }
    // and if the outcome of the vote hasn't already been determined
    else if (g_voteStatus & VOTE_IS_OVER)
    {
        colored_print(id, "^x04***^x01 Голосование окончено.");
        return;
    }

    // if the player is the only one on the server, bring up the vote immediately
    if (get_realplayersnum() == 1 && minutesElapsed > floatmin(2.0, g_rtvWait))
    {
        vote_startDirector(true);
        return;
    }

    // make sure enough time has gone by on the current map
    if (g_rtvWait)
    {
        if (minutesElapsed < g_rtvWait)
        {
            colored_print(id, "^x04***^x01 Голосование будет разрешено через^x04 %d^x01 мин.", floatround(g_rtvWait - minutesElapsed, floatround_ceil));
            return;
        }
    }

    // determine how many total rocks are needed
    new rocksNeeded = vote_getRocksNeeded();

    // make sure player hasn't already rocked the vote
    if (g_rockedVote[id])
    {
        colored_print(id, "^x04***^x01 Твой rtv-голос уже засчитан!");
        rtv_remind(TASKID_REMINDER + id);
        return;
    }

    // allow the player to rock the vote
    g_rockedVote[id] = true;
    colored_print(id, "^x04***^x01 Ты проголосовал за смену карты.");

    // make sure the rtv reminder timer has stopped
    if (task_exists(TASKID_REMINDER))
    {
        remove_task(TASKID_REMINDER);
    }

    // determine if there have been enough rocks for a vote yet
    if (++g_rockedVoteCnt >= rocksNeeded)
    {
        // announce that the vote has been rocked
        colored_print(0, "^x04***^x01 Достаточное количество игроков написало^x04 rtv^x01!");

        // start up the vote director
        vote_startDirector(true);
    }
    else
    {
        // let the players know how many more rocks are needed
        rtv_remind(TASKID_REMINDER + id);

        if (get_pcvar_num(cvar_rtvReminder))
        {
            // initialize the rtv reminder timer to repeat how many rocks are still needed, at regular intervals
            set_task(get_pcvar_float(cvar_rtvReminder) * 60.0, "rtv_remind", TASKID_REMINDER, _, _, "b");
        }
    }
}

vote_unrock(id)
{
    if (g_rockedVote[id])
    {
        g_rockedVote[id] = false;
        g_rockedVoteCnt--;
    }
}

vote_getRocksNeeded()
{
    return floatround(get_pcvar_float(cvar_rtvRatio) * float(get_realplayersnum()), floatround_ceil);
}

public rtv_remind(param)
{
    new who = param - TASKID_REMINDER;

    // let the players know how many more rocks are needed
    colored_print(who, "^x04***^x01 Для голосования нужно еще^x04 %i^x01 rtv", vote_getRocksNeeded() - g_rockedVoteCnt);
}

public cmd_listmaps(id)
{
    map_listAll(id);

    return PLUGIN_HANDLED;
}

public cmd_HL1_votemap(id)
{
    if (get_pcvar_num(cvar_cmdVotemap) == 0)
    {
        con_print(id, "%L", id, "GAL_DISABLED");
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}

public cmd_HL1_listmaps(id)
{
    switch (get_pcvar_num(cvar_cmdListmaps))
    {
        case 0:
        {
            con_print(id, "%L", id, "GAL_DISABLED");
        }
        case 2:
        {
            map_listAll(id);
        }
        default:
        {
            return PLUGIN_CONTINUE;
        }
    }
    return PLUGIN_HANDLED;
}

map_listAll(id)
{
    static lastMapDisplayed[MAX_PLAYER_CNT + 1][2];

    // determine if the player has requested a listing before
    new userid = get_user_userid(id);
    if (userid != lastMapDisplayed[id][LISTMAPS_USERID])
    {
        lastMapDisplayed[id][LISTMAPS_USERID] = 0;
    }

    new command[32];
    read_argv(0, command, charsmax(command));

    new arg1[8], start;
    new mapCount = get_pcvar_num(cvar_listmapsPaginate);

    if (mapCount)
    {
        if (read_argv(1, arg1, charsmax(arg1)))
        {
            if (arg1[0] == '*')
            {
                // if the last map previously displayed belongs to the current user,
                // start them off there, otherwise, start them at 1
                if (lastMapDisplayed[id][LISTMAPS_USERID])
                {
                    start = lastMapDisplayed[id][LISTMAPS_LAST] + 1;
                }
                else
                {
                    start = 1;
                }
            }
            else
            {
                start = str_to_num(arg1);
            }
        }
        else
        {
            start = 1;
        }

        if (id == 0 && read_argc() == 3 && read_argv(2, arg1, charsmax(arg1)))
        {
            mapCount = str_to_num(arg1);
        }
    }

    if (start < 1)
    {
        start = 1;
    }

    if (start >= g_nominationMapCnt)
    {
        start = g_nominationMapCnt - 1;
    }

    new end = mapCount ? start + mapCount - 1 : g_nominationMapCnt;

    if (end > g_nominationMapCnt)
    {
        end = g_nominationMapCnt;
    }

    // this enables us to use 'command *' to get the next group of maps, when paginated
    lastMapDisplayed[id][LISTMAPS_USERID] = userid;
    lastMapDisplayed[id][LISTMAPS_LAST] = end - 1;

    con_print(id, "^n----- %L -----", id, "GAL_LISTMAPS_TITLE", g_nominationMapCnt);

    new nominated[64], nominator_id, name[32], mapName[32], idx;
    for (idx = start - 1; idx < end; idx++)
    {
        nominator_id = nomination_getPlayer(idx);
        if (nominator_id)
        {
            get_user_name(nominator_id, name, charsmax(name));
            formatex(nominated, charsmax(nominated), "%L", id, "GAL_NOMINATEDBY", name);
        }
        else
        {
            nominated[0] = 0;
        }
        ArrayGetString(g_nominationMap, idx, mapName, charsmax(mapName));
        con_print(id, "%3i: %s  %s", idx + 1, mapName, nominated);
    }

    if (mapCount && mapCount < g_nominationMapCnt)
    {
        con_print(id, "----- %L -----", id, "GAL_LISTMAPS_SHOWING", start, idx, g_nominationMapCnt);

        if (end < g_nominationMapCnt)
        {
            con_print(id, "----- %L -----", id, "GAL_LISTMAPS_MORE", command, end + 1, command);
        }
    }
}

con_print(id, message[], {Float,Sql,Result,_}:...)
{
    new consoleMessage[256];
    vformat(consoleMessage, charsmax(consoleMessage), message, 3);

    if (id)
    {
        new authid[32];
        get_user_authid(id, authid, charsmax(authid));

        if (!equal(authid, "STEAM_ID_LAN"))
        {
            console_print(id, consoleMessage);
            return;
        }
    }

    server_print(consoleMessage);
}

public client_disconnect(id)
{
    g_voted[id] = false;

    // un-rock the vote
    vote_unrock(id);

    new dbg_playerCnt = get_realplayersnum()-1;

    if (dbg_playerCnt == 0)
    {
        srv_handleEmpty();
    }
}

public client_connect(id)
{
    set_pcvar_num(cvar_emptyCycle, 0);

    vote_unrock(id);
}

public client_putinserver(id)
{
    if (g_voteStatus & VOTE_IS_EARLY)
    {
        set_task(20.0, "srv_announceEarlyVote", id);
    }
}

srv_handleEmpty()
{
    if (g_originalTimelimit != get_cvar_float("mp_timelimit"))
    {
        // it's possible that the map has been extended at least once. that
        // means that if someone comes into the server, the time limit will
        // be the extended time limit rather than the normal time limit. bad.
        // reset the original time limit
        map_restoreOriginalTimeLimit();
    }

    // might be utilizing "empty server" feature
    if (g_isUsingEmptyCycle && g_emptyMapCnt)
    {
        srv_startEmptyCountdown();
    }
}

public srv_announceEarlyVote(id)
{
    if (is_user_connected(id))
    {
        new text[101];
        formatex(text, charsmax(text), "^x04%L", id, "GAL_VOTE_EARLY");
        print_color(id, text);
    }
}

public srv_initEmptyCheck()
{
    if (get_pcvar_num(cvar_emptyWait))
    {
        if ((get_realplayersnum()) == 0 && !get_pcvar_num(cvar_emptyCycle))
        {
            srv_startEmptyCountdown();
        }
        g_isUsingEmptyCycle = true;
    }
}

srv_startEmptyCountdown()
{
    new waitMinutes = get_pcvar_num(cvar_emptyWait);
    if (waitMinutes)
    {
        set_task(float(waitMinutes * 60), "srv_startEmptyCycle", TASKID_EMPTYSERVER);
    }
}

public srv_startEmptyCycle()
{
    set_pcvar_num(cvar_emptyCycle, 1);

    // set the next map from the empty cycle list,
    // or the first one, if the current map isn't part of the cycle
    new nextMap[32], mapIdx;
    mapIdx = map_getNext(g_emptyCycleMap, g_currentMap, nextMap);
    map_setNext(nextMap);

    // if the current map isn't part of the empty cycle,
    // immediately change to next map that is
    if (mapIdx == -1)
    {
        map_change();
    }
}

nomination_announceCancellation(nominations[])
{
    colored_print(0, "^x04***^x01 Эти карты больше не номинированы:^x04 %s", nominations);
}

nomination_clearAll()
{
    for (new idxPlayer = 1; idxPlayer <= MAX_PLAYER_CNT; idxPlayer++)
    {
        for (new idxNomination = 1; idxNomination <= MAX_NOMINATION_CNT; idxNomination++)
        {
            g_nomination[idxPlayer][idxNomination] = -1;
        }
    }
    g_nominationCnt = 0;
}

map_announceNomination(id, map[])
{
    new name[32];
    get_user_name(id, name, charsmax(name));

    colored_print(0, "^x03%s ^x01выбрал карту ^x04%s", name, map);
}

stock sort_stringsi(const elem1[], const elem2[], const array[], data[], data_size)
{
    return strcmp(elem1, elem2, 1);
}

get_realplayersnum()
{
    new players[32], playerCnt;
    get_players(players, playerCnt);

    return playerCnt;
}

percent(is, of)
{
    return (of != 0) ? floatround(floatmul(float(is)/float(of), 100.0)) : 0;
}

print_color(id, text[])
{
    if(is_user_connected(id))
    {
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), {0, 0, 0}, id);
        write_byte(id);
        write_string(text);
        message_end();
    }
}

map_restoreOriginalTimeLimit()
{
    if (g_originalTimelimit != TIMELIMIT_NOT_SET)
    {
        server_cmd("mp_timelimit %f", g_originalTimelimit);
        server_exec();
    }
}
