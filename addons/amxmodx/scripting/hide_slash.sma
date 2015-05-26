#include <amxmodx>
#include <colored_print>

public plugin_init()
{
    register_plugin("Hide Slash Commands", "1.0", "GoZm")

    register_clcmd("say", "cmd_hook_say")
    register_clcmd("say_team", "cmd_hook_say")
}

public cmd_hook_say(id)
{
    new chat_msg[64]
    read_args(chat_msg, charsmax(chat_msg))
    remove_quotes(chat_msg)

    if(chat_msg[0] == '/')
    {
        colored_print(id, "^x04***^x01 Команда^x04 %s^x01 не найдена!", chat_msg)

        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}
