#include <amxmodx>

#define SIZE_KB 1000
new cv_size

public plugin_init()
{
	register_plugin("custom.hpk Control", "1.0", "Northon")
	cv_size = register_cvar("amx_maxsize", "1000.0")
}

public plugin_end()
{
	if (file_size("custom.hpk")/SIZE_KB > get_pcvar_float(cv_size))
	{
		delete_file("custom.hpk")
		log_amx("custom.hpk delete due so much size (%d)", file_size("custom.hpk")/SIZE_KB)
	}
}