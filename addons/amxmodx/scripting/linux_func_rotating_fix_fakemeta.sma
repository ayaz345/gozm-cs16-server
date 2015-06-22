#include <amxmodx>
#include <cstrike>
#include <fakemeta>

public plugin_init()
{
    register_plugin("rotate_fix_FM", "1.2", "NL)Ramon(NL")

    if (!is_linux_server())
    {
        set_fail_state("LINUX ONLY")
        server_print("The func_rotating fix plugin is for linux servers ONLY. Operations aborted.")

        return PLUGIN_CONTINUE
    }

    if (cs_find_ent_by_class(-1, "func_rotating"))
        set_task(10.0, "fix_bug", 0, "", 0, "b")

    return PLUGIN_CONTINUE
}

public fix_bug()
{
    static f_rota 
    f_rota = -1

    while((f_rota = cs_find_ent_by_class(f_rota, "func_rotating")))
    {
        static Float:angles[3]
        pev(f_rota, pev_angles, angles)
        angles[0] -= floatround(angles[0] / 360.0, floatround_floor) * 360.0
        angles[1] -= floatround(angles[1] / 360.0, floatround_floor) * 360.0
        angles[2] -= floatround(angles[2] / 360.0, floatround_floor) * 360.0
        set_pev(f_rota, pev_angles, angles)
    }
}
