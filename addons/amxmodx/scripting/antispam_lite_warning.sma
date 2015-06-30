#include <amxmodx>
#include <regex>
#include <colored_print>

new const g_equal_list[][] = {
    "/xmenu",
    "/cp",
    "/knife"
}

new const g_contain_list[][] = {
    "ICQ",
    "ManoCS"
}

public plugin_init()
{
    register_plugin("Anti-Spam", "1.3", "GoZm")

    register_clcmd("say", "check_player_msg")
    register_clcmd("say_team", "check_player_msg")
}

bool:is_invalid(const text[])
{
    static Regex:regex, error[50], num, i

    regex = regex_match(text, "[a-z0-9-]{3,}\.[a-z]{1,2}(\S)", num, error, charsmax(error), "i")
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        return true
    }

    regex = regex_match(text, "([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}", num, error, 49)
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        return true
    }

    regex = regex_match(text, "27[0-9][0-9][0-9]", num, error, charsmax(error))
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        return true
    }

    for (i=0; i<sizeof(g_equal_list); i++)
        if (equal(text, g_equal_list[i]))
            return true

    for (i=0; i<sizeof(g_contain_list); i++)
        if (contain(text, g_contain_list[i]) != -1)
            return true

    return false
}

public check_player_msg(id)
{
    static text[128]
    read_args(text, charsmax(text))
    remove_quotes(text)

    if(is_invalid(text))
    {
        colored_print(id, "^x04***^x01 [%s] -^x04 СПАМ, СООБЩЕНИЕ УДАЛЕНО!", text)
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}
