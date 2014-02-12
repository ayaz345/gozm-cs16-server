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
    new hpk_file_size
    hpk_file_size = file_size("custom.hpk")

    if (hpk_file_size/SIZE_KB > get_pcvar_float(cv_size))
    {
        delete_file("custom.hpk")
        log_amx("custom.hpk delete due so much size (%d kb)", hpk_file_size/SIZE_KB)
    }
}