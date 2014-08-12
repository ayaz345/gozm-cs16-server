#include <amxmodx>
#include <fakemeta>
#include <regex>
#include <colored_print>

public plugin_init()
{
    register_plugin("Anti-Spam", "1.2", "Dumka")
    register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
    register_clcmd("say", "check_player_msg")
    register_clcmd("say_team", "check_player_msg")
}

public fw_ClientUserInfoChanged(id, infobuffer)
{
    static name[32]
    engfunc(EngFunc_InfoKeyValue, infobuffer, "name", name, charsmax(name))
    if(contain(name, "#") != -1)
        engfunc(EngFunc_SetClientKeyValue, id, infobuffer, "name", "I used bug")
    
    new Regex:regex
    new error[50], num
    regex = regex_match(name, "[a-z0-9-]{3,}\.[a-z]{1,2}(\S)", num, error, 49, "i")
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        engfunc(EngFunc_SetClientKeyValue, id, infobuffer, "name", "Change Name")
    }
    regex = regex_match(name, "([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}", num, error, 49)
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        engfunc(EngFunc_SetClientKeyValue, id, infobuffer, "name", "Change Name")
    }
}

// Checks the message for spam
bool:is_invalid(const text[])
{
    new error[50], num
    new Regex:regex = regex_match(text, "[a-z0-9-]{3,}\.[a-z]{1,2}(\S)", num, error, 49, "i")
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
    regex = regex_match(text, "27[0-9][0-9][0-9]", num, error, 49)
    if(regex >= REGEX_OK)
    {
        regex_free(regex)
        return true
    }
    if (containi(text, "ICQ") != -1)
        return true
    if (containi(text, "ManoCS") != -1)
        return true
    if (equali(text[strlen(text)-4], "107^""))
        return true
    if (equali(text[strlen(text)-4], "108^""))
        return true
    if (equali(text, "/xmenu"))
        return true
    if (equali(text, "/cp"))
        return true
    if (equali(text, "/knife"))
        return true

    return false
}

// Check say or say_team message
public check_player_msg(id)
{
    new text[128]
    read_args(text,127)
    remove_quotes(text)
    
    if(contain(text, "#") != -1)
        return PLUGIN_HANDLED

    if(is_invalid(text))
    {
        colored_print(id, "^x04***^x01 [%s] -^x04 СПАМ, СООБЩЕНИЕ УДАЛЕНО!", text)
        return PLUGIN_HANDLED
    }	
        
    return PLUGIN_CONTINUE
}

