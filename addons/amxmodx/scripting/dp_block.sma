#include <amxmodx>
#include <orpheu>
#include <orpheu_advanced>
#include <orpheu_stocks>
#define PLUGIN "IP block"
#define VERSION "0.1"
#define AUTHOR "kanagava"


new OrpheuHook:handlePrintf


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    set_task(2.01, "regfunctions")  
} 
public regfunctions()
{
    OrpheuRegisterHook(OrpheuGetFunction("dp_traffic_block"),"dp_traffic_block_OrpheuHookPost", OrpheuHookPost)
    OrpheuRegisterHook(OrpheuGetFunction("dp_traffic_block"),"dp_traffic_block_OrpheuHookPre", OrpheuHookPre)
}

public OrpheuHookReturn:dp_traffic_block_OrpheuHookPost(const a[], const b[] , const c[] )
{
	OrpheuUnregisterHook(handlePrintf)

	return OrpheuIgnored;
}

public OrpheuHookReturn:dp_traffic_block_OrpheuHookPre(const a[], const b[] , const c[] )
{
	
	handlePrintf = OrpheuRegisterHook( OrpheuGetFunction( "Con_Printf" ), "Con_Printf" , OrpheuHookPre);
	return OrpheuIgnored;
}

public OrpheuHookReturn:Con_Printf(const a[], const b[])
{
	if (containi(b,"traffic temporary blocked")>-1)
	{
		new msg[256]
		copy(msg,255,b)
		del_log(msg)
		return OrpheuSupercede;
	}
		
	return OrpheuIgnored;
}

public del_log(mess[])
{
	static szLeft[300], szRight[300]
	split ( mess, szLeft, 299, szRight, 299, "traffic temporary blocked from ")
	copy(mess, 299, szRight)
	split ( mess, szLeft, 299, szRight, 299, " for flooding") 
	containi(mess,"traffic temporary blocked")
	server_cmd("addip 360.0 %s",szLeft)
	//log_to_file("trafic_blocked","[BLOCKED FROM] %s",szLeft) //снимите комментарий есле желаете видеть IP в логах
	//для того чтобы писать напрямую в файл (делать лист IP без излишеств) нужно писать в файл, а не делать лог
}