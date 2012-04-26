#include <amxmodx>

public handle_say(id) {

    new is_alive = is_user_alive(id);
    new team = get_user_team(id);

    new command[17];
    read_argv(0, command, 16);

    new is_team_msg = ! equal(command, "say");

    new player_count = get_playersnum();
    new players[32];

    get_players(players, player_count, "c");

    new message[129];
    read_argv(1, message, 128);

    new name[33];
    get_user_name(id, name, 32);

    for (new i = 0; i < player_count; i++) {
        if (!is_user_alive(players[i]) && is_alive &&
            (! is_team_msg || team == get_user_team(players[i]))) 
			{
            // The current player is dead and the talking player is alive
            client_print(players[i], print_chat, "%s :    %s", name, message);
			} 
											}
    return PLUGIN_CONTINUE;
}

public plugin_init() {
    register_plugin("PsychoListen", "0.8.6b", "PsychoGuard");

    register_clcmd("say", "handle_say");
    register_clcmd("say_team", "handle_say");

    return PLUGIN_CONTINUE;
}

