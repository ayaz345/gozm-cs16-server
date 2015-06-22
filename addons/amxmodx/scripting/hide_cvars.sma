#include <amxmodx>

#define MAX_CVARS 150

new g_Cvars[MAX_CVARS][64], g_CvarsCount

public plugin_init()
{
    register_plugin("Hide Server Cvars", "1.0", "DJ_WEST")

    new s_File[128]
    get_configsdir(s_File, charsmax(s_File))
    format(s_File, charsmax(s_File), "%s/hide_cvars.ini", s_File)

    set_task(0.1, "Read_HideCvars", 0, s_File, sizeof(s_File))
}

public Read_HideCvars(const s_FilePath[])
{
    if (file_exists(s_FilePath))
    {
        new line[64], index

        new file = fopen(s_FilePath, "rt")
        while (file && !feof(file))
        {
            fgets(file, line, charsmax(line))
            trim(line)

            // skip commented lines
            if (line[0] == ';' || strlen(line) < 1 || (line[0] == '/' && line[1] == '/'))
                continue

            copy(g_Cvars[index], charsmax(g_Cvars[]), line)
            index++
        }
        if (file) fclose(file)

        g_CvarsCount = index
        set_task(0.1, "Hide_Cvars")
    }
}

public Hide_Cvars()
{
    new i_Flags, s_Cvar[64]

    for (new i = 0; i < g_CvarsCount; i++)
    {
        s_Cvar = g_Cvars[i]

        if (cvar_exists(s_Cvar))
        {
            i_Flags = get_cvar_flags(s_Cvar)
            remove_cvar_flags(s_Cvar)

            if (i_Flags >= 32)
                set_cvar_flags(s_Cvar, i_Flags  &~ FCVAR_SERVER | FCVAR_PROTECTED)
            else
                set_cvar_flags(s_Cvar, i_Flags  &~ FCVAR_SERVER)
        }
    }
}

get_configsdir(s_Name[], i_Len)
{
    return get_localinfo("amxx_configsdir", s_Name, i_Len)
}
