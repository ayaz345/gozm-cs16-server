#include <amxmodx>
#include <fakemeta>
#include <colored_print>
#include <gozm>

#define PDATA_SAFE                      2
#define OFFSET_LINUX                    5
#define OFFSET_CSMENUCODE               205

new g_targets[MAX_PLAYERS+1]            // player's voteban targets
new g_votes_for[MAX_PLAYERS+1]          // count of votes for ban that player
new g_votes_by[MAX_PLAYERS+1]           // count of votes for ban by that player
new g_immunity[MAX_PLAYERS+1]           // admin can set immunity flag
new g_being_banned[MAX_PLAYERS+1]       // against duplicate bans

#define CHECK_FLAG(%1,%2)               (%1 &   ( 1 << (%2 - 1) ))
#define ADD_FLAG(%1,%2)                 (%1 |=  ( 1 << (%2 - 1) ))
#define REMOVE_FLAG(%1,%2)              (%1 &= ~( 1 << (%2 - 1) ))

new pcvar_percent, g_percent
new pcvar_bantime, g_bantime
new pcvar_player_limit, g_player_limit
new pcvar_min_players_to_vote, g_min_players_to_vote
new pcvar_min_voters_needed, g_min_voters_needed

new const g_prefix[] = "[VOTEBAN]:"
new const g_reason[] = "Voteban"

public plugin_init()
{
    register_plugin("Rock to Ban", "2.5", "GoZm")

    if(!is_server_licenced())
        return PLUGIN_CONTINUE

    register_clcmd("say voteban", "voteban_menu")
    register_clcmd("say_team voteban", "voteban_menu")
    register_clcmd("say /voteban", "voteban_menu")
    register_clcmd("say_team /voteban", "voteban_menu")

    pcvar_percent               = register_cvar("voteban_percent", "30")
    pcvar_bantime               = register_cvar("voteban_time", "10")
    pcvar_player_limit          = register_cvar("voteban_player_limit", "2")
    pcvar_min_players_to_vote   = register_cvar("voteban_min_players_to_vote", "5")
    pcvar_min_voters_needed     = register_cvar("voteban_min_voters_needed ", "4")

    set_task(0.1, "cache_cvars")

    return PLUGIN_CONTINUE
}

public cache_cvars()
{
    g_percent = get_pcvar_num(pcvar_percent)
    g_bantime = get_pcvar_num(pcvar_bantime)
    g_player_limit = get_pcvar_num(pcvar_player_limit)
    g_min_players_to_vote = get_pcvar_num(pcvar_min_players_to_vote)
    g_min_voters_needed = get_pcvar_num(pcvar_min_voters_needed)
}

public client_connect(id)
{
    reset_variables(id)
}

public client_disconnect(id)
{
    static players[32], players_num, player, i

    get_players(players, players_num)
    for (i = 0; i < players_num; i++)
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
            if (check_votes(player))
            {
                ban(player, true)
            }
        }
    }

    reset_variables(id)
}

public voteban_menu(id)
{
    if (get_playersnum() < g_min_players_to_vote)
    {
        static name[32]
        get_user_name(id, name, charsmax(name))

        log_amx("%s not enough players by %s", g_prefix, name)
        colored_print(id, "^x04%s^x01 Недостаточно игроков для проведения голосования!", g_prefix)

        return PLUGIN_HANDLED
    }

    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)  // prevent from showing CS std menu

    static players[32], players_num, player
    static temp_string[64], name[32], info[3]

    static menu
    menu = menu_create("\yМеню \rVOTEBAN\y:", "menu_handle")

    if (has_vip(id))
        menu_setprop(menu, MPROP_TITLE, "\yМеню \rVOTEBAN\y:^n\dУправление только иммунитетом игрока!\y")
    menu_setprop(menu, MPROP_NUMBER_COLOR, "\y")
    menu_setprop(menu, MPROP_NEXTNAME, "Дальше")
    menu_setprop(menu, MPROP_BACKNAME, "Назад")
    menu_setprop(menu, MPROP_EXITNAME, "Выход")

    static callback
    callback = menu_makecallback("menu_callback")

    static max_votes, i
    max_votes = get_max_votes()

    get_players(players, players_num)
    for (i = 0; i < players_num; i++)
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
    static access, info[3], callback, temp_string[64]
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

    static access, info[3], callback

    menu_item_getinfo(menu, item, access, info, charsmax(info), .callback=callback)
    menu_destroy(menu)

    static target
    target = str_to_num(info)

    if (!is_user_connected(target))
    {
        log_amx("%s chosen player left the server", g_prefix)
        colored_print(id, "^x04%s^x01 Выбранный игрок^x04 вышел^x01 с сервера", g_prefix)

        return PLUGIN_HANDLED
    }

    static voter_name[32], target_name[32]
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
        static max_votes, players_num
        max_votes = get_max_votes()
        players_num = get_playersnum()

        // vote is unset
        if (CHECK_FLAG(g_targets[id], target))
        {
            REMOVE_FLAG(g_targets[id], target)
            g_votes_by[id]--
            g_votes_for[target]--

            log_amx("%s %s removed vote from %s (%d/%d of %d)",
                    g_prefix, voter_name, target_name, g_votes_for[target], max_votes, players_num)
            colored_print(id, "^x04%s^x01 Ты убрал голос против^x03 %s", g_prefix, target_name)

            return PLUGIN_HANDLED
        }

        // don't let vote too much ;)
        if (g_votes_by[id] >= g_player_limit)
        {
            log_amx("%s %s votes too much (%d)", g_prefix, voter_name, g_votes_by[id])
            colored_print(id, "^x04%s^x01 Превышен твой лимит голосов:^x04 %s", g_prefix, g_player_limit)

            return PLUGIN_HANDLED
        }

        // vote is set
        g_votes_by[id]++
        g_votes_for[target]++
        ADD_FLAG(g_targets[id], target)

        log_amx("%s %s set vote for %s (%d/%d of %d)",
                g_prefix, voter_name, target_name, g_votes_for[target], max_votes, players_num)

        if (g_being_banned[target])
        {
            log_amx("%s %s is being banning now", g_prefix, target_name)
            colored_print(id, "^x04%s^x01 Игрок^x03 %s^x01 уже забанен, сейчас его кикнет", g_prefix, target_name)
        }
        else
        {
            if (g_votes_for[target] < max_votes)
            {
                static delta
                delta = max_votes - g_votes_for[target]

                static info_msg[128]
                formatex(info_msg, charsmax(info_msg),
                    "^x04%s^x01 Ты проголосовал против^x03 %s^x01. %s еще^x04 %d^x01 голос%s",
                    g_prefix, target_name, delta == 1 ? "Нужен" : "Нужно", delta, set_completion(delta))

                colored_print(id, info_msg)
            }
            else
            {
                g_being_banned[target] = 1

                ban(target, true)
            }
        }
    }

    return PLUGIN_HANDLED
}

bool:check_votes(target)
{
    static max_votes
    max_votes = get_max_votes()
    if (g_votes_for[target] >= max_votes)
    {
        return true
    }
    return false
}

get_max_votes()
{
    static players_num, max_votes
    players_num = get_playersnum() - 1     // one is for client being banning
    max_votes = floatround(float(players_num*g_percent) / 100.0, floatround_ceil)

    return max(g_min_voters_needed, max_votes)
}

ban(id, bool:announce)
{
    static user_name[32]
    static user_id

    get_user_name(id, user_name, charsmax(user_name))
    user_id = get_user_userid(id)

    server_cmd("amx_ban %d #%d %s", g_bantime, user_id, g_reason)
    log_amx("%s %s is banned by %d votes", g_prefix, user_name, g_votes_for[id])

    if (announce)
    {
        colored_print(0, "^x04%s^x01 Игрок^x04 %s^x01 забанен общим голосованием", g_prefix, user_name)
    }
}

set_completion(number)
{
    static completion[5]   // 1 cyrillic symbol take 2 bytes
    static remaining
    remaining = number % 10

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

reset_variables(id)
{
    g_targets[id] = 0
    g_votes_by[id] = 0
    g_votes_for[id] = 0
    g_immunity[id] = 0
    g_being_banned[id] = 0
}
