#include <amxmodx>
#include <fakemeta>
#include <colored_print>
#include <gozm>

#define PDATA_SAFE                  2
#define OFFSET_LINUX                5
#define OFFSET_CSMENUCODE           205

new g_targets[MAX_PLAYERS+1]        // player's voteban targets
new g_votes_for[MAX_PLAYERS+1]      // count of votes for ban that player
new g_votes_by[MAX_PLAYERS+1]       // count of votes for ban by that player
new g_immunity[MAX_PLAYERS+1]       // admin can set immunity flag

#define MIN_PLAYERS                 4
#define MIN_VOTERS                  3

#define CHECK_FLAG(%1,%2)           (%1 &   ( 1 << (%2-1) ))
#define ADD_FLAG(%1,%2)             (%1 |=  ( 1 << (%2-1) ))
#define REMOVE_FLAG(%1,%2)          (%1 &= ~( 1 << (%2-1) ))

new pcvar_percent
new pcvar_bantime
new pcvar_limit

new const g_prefix[] = "[VOTEBAN]:"

public plugin_init()
{
    register_plugin("Rock to Ban", "2.2", "GoZm")

    if(!is_server_licenced())
        return PLUGIN_CONTINUE

    register_clcmd("say voteban", "voteban_menu")
    register_clcmd("say_team voteban", "voteban_menu")
    register_clcmd("say /voteban", "voteban_menu")
    register_clcmd("say_team /voteban", "voteban_menu")

    pcvar_percent = register_cvar("voteban_percent", "35")
    pcvar_bantime = register_cvar("voteban_time", "10")
    pcvar_limit = register_cvar("voteban_limit", "2")

    return PLUGIN_CONTINUE
}

public client_connect(id)
{
    g_targets[id] = 0
    g_votes_by[id] = 0
    g_votes_for[id] = 0
    g_immunity[id] = 0
}

public client_disconnect(id)
{
    new players[32], players_num, player

    get_players(players, players_num, "ch")     // skip bots and HLTV
    for (new i = 0; i < players_num; i++)
    {
        player = players[i]

        // check whether there were votes for ban by that player
        if (g_targets[id])
        {
            if (CHECK_FLAG(g_targets[id], player))
            {
                REMOVE_FLAG(g_targets[id], player)
                g_votes_for[player]--
                g_votes_by[id]--
            }
        }
        // check whether there were votes for ban that player
        if (g_votes_for[id])
        {
            if (CHECK_FLAG(g_targets[player], id))
            {
                REMOVE_FLAG(g_targets[player], id)
                g_votes_for[id]--
                g_votes_by[player]--
            }
        }
        // re-calculate others' votes
        if (g_votes_for[player] && !g_immunity[player])
        {
            check_votes(player)
        }
    }

    g_targets[id] = 0
    g_votes_by[id] = 0
    g_votes_for[id] = 0
    g_immunity[id] = 0
}

public voteban_menu(id)
{
    if (get_playersnum() < MIN_PLAYERS)
    {
        colored_print(id, "^x04%s^x01 Недостаточно игроков для проведения голосования!", g_prefix)
        return PLUGIN_HANDLED
    }

    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)  // prevent from showing CS std menu

    new players[32], players_num, player
    new temp_string[64], name[32], info[3]

    new menu = menu_create("\yМеню \rVOTEBAN\y:", "menu_handle")

    if (has_vip(id))
        menu_setprop(menu, MPROP_TITLE, "\yМеню \rVOTEBAN\y:^n\dУправление только иммунитетом игрока!\y")
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\y")
    menu_setprop(menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(menu, MPROP_BACKNAME, "Назад")
    menu_setprop(menu, MPROP_EXITNAME, "Выход")

    new callback = menu_makecallback("menu_callback")

    new max_votes = get_max_votes()

    get_players(players, players_num, "ch")     // skip bots and HLTV
    for (new i = 0; i < players_num; i++)
    {
        player = players[i]
        get_user_name(player, name, charsmax(name))

        if (player == id)
        {
            continue    // don't show player itself
        }
        else if (g_immunity[player])
        {
            formatex(temp_string, charsmax(temp_string), "%s \yзащита", name)
            if (has_vip(id))
                menu_additem(menu, temp_string, info, .callback=callback)
            else
                menu_additem(menu, name, "", .callback=callback)
        }
        else if (has_vip(player))
        {
            // don't set info[] if player has immunity
            menu_additem(menu, name, "", .callback=callback)
        }
        else
        {
            if (!g_votes_for[player])
                formatex(temp_string, charsmax(temp_string), "%s", name)
            else if (CHECK_FLAG(g_targets[id], player))
                formatex(temp_string, charsmax(temp_string), "\r%s \d(\y%d/%d\d)", name, g_votes_for[player], max_votes)
            else
                formatex(temp_string, charsmax(temp_string), "%s \d(\y%d/%d\d)", name, g_votes_for[player], max_votes)
            num_to_str(player, info, charsmax(info))
            menu_additem(menu, temp_string, info, .callback=callback)
        }
    }

    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public menu_callback(id, menu, item)
{
    new access, info[3], callback, temp_string[64]
    menu_item_getinfo(menu, item, access, info, charsmax(info), temp_string, charsmax(temp_string), callback)

    if (!info[0])
        // player has immunity
        return ITEM_DISABLED

    if (str_to_num(info) == id)
        return ITEM_DISABLED

    return ITEM_ENABLED
}

public menu_handle(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new access, info[3], callback

    menu_item_getinfo(menu, item, access, info, charsmax(info), .callback=callback)
    menu_destroy(menu)

    new target = str_to_num(info)

    if (!is_user_connected(target))
    {
        colored_print(id, "^x04%s^x01 Выбранный игрок вышел с сервера", g_prefix)
        return PLUGIN_HANDLED
    }

    new voter_name[32], target_name[32]
    get_user_name(id, voter_name, charsmax(voter_name))
    get_user_name(target, target_name, charsmax(target_name))

    // set/unset immunity by admin
    if (has_vip(id))
    {
        if (g_immunity[target])
        {
            g_immunity[target] = 0
            log_amx("%s %s removed immunity from %s", g_prefix, voter_name, target_name)
            colored_print(id, "^x04%s^x01 Ты убрал защиту у^x03 %s", g_prefix, target_name)
            return PLUGIN_HANDLED
        }
        else
        {
            g_immunity[target] = 1
            log_amx("%s %s set immunity to %s", g_prefix, voter_name, target_name)
            colored_print(id, "^x04%s^x01 Ты поставил защиту для^x03 %s", g_prefix, target_name)
            return PLUGIN_HANDLED
        }
    }
    // set/unset vote by player
    else
    {
        new max_votes = get_max_votes()
        new players_num = get_playersnum()

        if (CHECK_FLAG(g_targets[id], target))
        {
            REMOVE_FLAG(g_targets[id], target)
            g_votes_by[id]--
            g_votes_for[target]--

            log_amx("%s %s removed vote from %s (%d/%d of %d)",
                    g_prefix, voter_name, target_name, g_votes_for[target], max_votes, get_playersnum())
            colored_print(id, "^x04%s^x01 Ты убрал голос против^x03 %s", g_prefix, target_name)
            return PLUGIN_HANDLED
        }

        new limit = get_pcvar_num(pcvar_limit)
        if (g_votes_by[id] >= limit)
        {
            // don't let vote too much ;)
            log_amx("%s %s votes too much (%d)", g_prefix, voter_name, g_votes_by[id])
            colored_print(id, "^x04%s^x01 Превышен твой лимит голосов:^x04 %s", g_prefix, limit)
            return PLUGIN_HANDLED
        }

        g_votes_by[id]++
        g_votes_for[target]++
        ADD_FLAG(g_targets[id], target)

        log_amx("%s %s set vote for %s (%d/%d of %d)",
                g_prefix, voter_name, target_name, g_votes_for[target], max_votes, players_num)

        new info_msg[128]
        formatex(info_msg, charsmax(info_msg), "^x04%s^x01 Ты проголосовал против^x03 %s", g_prefix, target_name)
        if (g_votes_for[target] < max_votes)
        {
            new delta = max_votes - g_votes_for[target]
            format(info_msg, charsmax(info_msg), "%s^x01. %s еще^x04 %d^x01 голос%s",
                   info_msg, delta == 1 ? "Нужен" : "Нужно", delta, set_completion(delta))
            colored_print(id, info_msg)
        }
        else
        {
            colored_print(id, info_msg)

            ban_player(target, 1)
        }
    }

    return PLUGIN_HANDLED
}

public check_votes(target)
{
    new max_votes = get_max_votes()
    if (g_votes_for[target] >= max_votes)
    {
        ban_player(target, 1)
    }
}

public get_max_votes()
{
    new percent = get_pcvar_num(pcvar_percent)
    new players_num = max(MIN_VOTERS, get_playersnum() - 1)     // one is for client being banning
    return floatround(float(players_num*percent) / 100.0, floatround_ceil)
}

public ban_player(id, announce)
{
    new user_name[32], user_id
    new ban_time

    get_user_name(id, user_name, charsmax(user_name))
    user_id = get_user_userid(id)
    ban_time = get_pcvar_num(pcvar_bantime)

    server_cmd("amx_ban %d #%d ^"GoZm Voteban^"", ban_time, user_id)
    log_amx("%s %s is banned by %d votes", g_prefix, user_name, g_votes_for[id])

    if (announce)
    {
        colored_print(0, "^x04%s^x01 Игрок^x04 %s^x01 забанен общим голосованием", g_prefix, user_name)
    }
}

public set_completion(number)
{
    new completion[5]   // 1 cyrillic symbol take 2 bytes
    new remaining = number % 10

    if (remaining == 1 && number != 11)
    {
        formatex(completion, charsmax(completion), "")
    }
    else if (2 <= remaining <= 4)
    {
        formatex(completion, charsmax(completion), "а")
    }
    else
    {
        formatex(completion, charsmax(completion), "ов")
    }

    return completion
}
