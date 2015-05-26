#include <amxmodx>

public plugin_init()
{
    register_plugin("File Cleaner", "1.0", "GoZm")

    set_task(1.0, "clean_spray_logo")
}

public clean_spray_logo()
{
    new hpk_file_size = file_size("custom.hpk")
    if (hpk_file_size/1000 > 1000.0)
    {
        delete_file("custom.hpk")
        log_amx("custom.hpk delete due so much size (%d kb)", hpk_file_size/1000)
    }
}
