#include <amxmod>

public plugin_init()
{
	register_plugin("CL_DLMAX","1.0","Anonymous")
	register_cvar("sv_cl_corpsestay","10")
}

public client_connect(id)
{
	client_cmd(id,"cl_corpsestay %d", get_cvar_num("sv_cl_corpsestay"))
}

public client_authorized(id)
{
	client_cmd(id,"cl_corpsestay %d", get_cvar_num("sv_cl_corpsestay"))
}
