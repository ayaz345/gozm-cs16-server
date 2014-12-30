#include <amxmodx>
#include <fakemeta>
#include <regex>
#include <colored_print>

public plugin_init()
{
    register_plugin("Anti-Spam", "1.2", "Dumka")
    register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged_Pre", false)
    register_clcmd("say", "check_player_msg")
    register_clcmd("say_team", "check_player_msg")
}

public ClientUserInfoChanged_Pre(const iClient, const pszInfoBuffer)
{
    new szNetName[32];
    pev(iClient, pev_netname, szNetName, charsmax(szNetName));

    new szBufferName[32];
    engfunc(EngFunc_InfoKeyValue, pszInfoBuffer, "name", szBufferName, charsmax(szBufferName));

    if (szNetName[0] != '^0' && equal(szNetName, szBufferName)) {
        return FMRES_IGNORED;
    }

    new bool:fChanged;

    for (new i = 0; szBufferName[i] != '^0'; i++)
        if (szBufferName[i] == '#' || (szBufferName[i] == '+' && !('0' <= szBufferName[i + 1] <= '9'))) {
            szBufferName[i] = ' ';
            fChanged = true;
        }

    if (fChanged)
        engfunc(EngFunc_SetClientKeyValue, iClient, pszInfoBuffer, "name", szBufferName);

    new Regex:regex;
    new error[50], num;
    regex = regex_match(szBufferName, "[a-zA-Z0-9-]{3,}\.[a-zA-Z]{2,3}$", num, error, 49, "i");
    if(regex >= REGEX_OK)
    {
        regex_free(regex);
        engfunc(EngFunc_SetClientKeyValue, iClient, pszInfoBuffer, "name", "[spam] Domen Name");
    }
    regex = regex_match(szBufferName, "([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}", num, error, 49);
    if(regex >= REGEX_OK)
    {
        regex_free(regex);
        engfunc(EngFunc_SetClientKeyValue, iClient, pszInfoBuffer, "name", "[spam] IP Name");
    }

    return FMRES_IGNORED;
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
    {
        colored_print(id, "^x04***^x01 СООБЩЕНИЕ УДАЛЕНО!", text)
        return PLUGIN_HANDLED
    }

    if(is_invalid(text))
    {
        colored_print(id, "^x04***^x01 [%s] -^x04 СПАМ, СООБЩЕНИЕ УДАЛЕНО!", text)
        return PLUGIN_HANDLED
    }	
        
    return PLUGIN_CONTINUE
}

