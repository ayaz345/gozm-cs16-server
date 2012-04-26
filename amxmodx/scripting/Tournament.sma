#include <amxmodx>
#include <colored_print>

public plugin_init()
{
	register_plugin("ShowINFO", "1.00", "Dumka")
}

public client_putinserver(id)
{
	if ( !is_user_bot(id)) 
	{
		new param[1]
		param[0] = id 
		set_task( 15.0 , "showWarn" , id , param , 1 )
	}
}

public showWarn(param[])
{
	colored_print( param[0],"^x04>>> ^x01Выиграй ^x03БАБЛО ^x01или ^x03АДМИНКУ^x01 на турнире 2х2!")
	colored_print( param[0],"^x04>>> ^x01Принять участие может каждый! ЗАПИСЫВАЙСЯ!!!")
	colored_print( param[0],"^x04>>> ^x01Подробнее ^x04vkontakte.ru/bbs.unet")
}