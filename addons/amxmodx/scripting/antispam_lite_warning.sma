#include <amxmodx>
#include <regex>
#include <colored_print>

public plugin_init()
{
	register_plugin("Anti-Spam", "1.2", "Dumka")
	register_clcmd("say","check_player_msg")
	register_clcmd("say_team","check_player_msg")
}

public client_putinserver(id)
{
    new nickname[32]
    get_user_name(id, nickname, sizeof(nickname)-1)
    
    new corrected_names[6][30] = {
        "[no_spam] Nick deleted",
        "[no_spam] My shiny new nick!",
        "[no_spam] Im a tomato",
        "[no_spam] I love GoZombie!",
        "[no_spam] Pif-Paf",
        "[no_spam] Bot"
    }
    new random_name = random_num(0, 5)
    
    strtolower(nickname)
    if( containi(nickname, ".ru") != -1 ||
        containi(nickname, ".com") != -1 ||
        containi(nickname, ".lv") != -1 ||
        containi(nickname, ".net") != -1 ||
        containi(nickname, ".ua") != -1 ||
        containi(nickname, ".su") != -1 )
        
        set_user_info(id, "name", corrected_names[random_name])
}

// Checks the message for spam
bool:is_invalid(const text[])
{
    new error[50], num
    new Regex:regex = regex_match (text, "[a-z0-9-]{3,}\.[a-z]{1,2}(\S)", num, error, 49, "i")
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
	new text[128], name[32]
	read_args(text,127)
	get_user_name(id, name, 31)
	
	if(is_invalid(text))
	{
		colored_print(id, "^x04 ***^x01 %s,^x03 STOP SPAMMING^x01 !!!", name)
		return PLUGIN_HANDLED
	}	
		
	return PLUGIN_CONTINUE
}

