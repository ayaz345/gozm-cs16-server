#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#define PLUGIN "floodban" //Plugin will ban fake flooder Zeal method (new)
#define VERSION "0.1"
#define AUTHOR "mazdan"

new Trie:g_u_ip_warn
new Trie:g_u_time

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    g_u_ip_warn=TrieCreate();
    g_u_time=TrieCreate();
    set_task(120.0,"arrclear",_,_,_,"b")
}

public arrclear()
{
    TrieClear(g_u_ip_warn)
    TrieClear(g_u_time)
}
public client_connect(id) 
{ 
    if(is_user_bot(id)) return;
    new ip[32]
    new ltime
    get_user_ip(id,ip,31,1)
    new name[32]
    get_user_name(id, name, 31)

    new week_number[3], logfile[19]
    get_time("%W", week_number, 2)
    format(logfile, 18, "connections_%s.log", week_number)
    log_to_file(logfile, "floodban => %s, %s", name, ip)

    if(!ip[0]) return;
    if (!TrieKeyExists(g_u_ip_warn, ip))
    {
        TrieSetCell(g_u_ip_warn,ip,1);
    }
    else
    {
        TrieGetCell(g_u_time,ip,ltime);
        if(!(get_systime()-ltime))
        {
            new warn
            TrieGetCell(g_u_ip_warn,ip,warn)
            if(++warn>4)
            {
                //server_cmd("addip 0.0 %s; writeip;",ip)
                server_cmd("addip 120.0 %s;",ip)
                log_to_file("NO_FLOOD.log", "ZEAL: %s", ip)
                TrieDeleteKey(g_u_ip_warn, ip);
            }
            else
                TrieSetCell(g_u_ip_warn,ip,warn)
        }
    }
    TrieSetCell(g_u_time,ip,get_systime());
}

public plugin_end()
{
    new week_number[3], next_logfile[19]
    get_time("%W", week_number, 2)
    
    new temp_cell
    temp_cell = str_to_num(week_number[1])
    temp_cell++
    num_to_str(temp_cell, week_number[1], 1)
    
    format(next_logfile, 18, "connections_%s.log", week_number)
    log_amx("[CLEANER]: %s", next_logfile)
    
    new directory[32], file[32]
    get_basedir(directory, 31)
    format(directory, 31, "%s/logs", directory)
    format(file, 31, "%s/%s", directory, next_logfile)
    log_amx("[CLEANER]:file %s", file)
    
    if(file_exists(next_logfile))
    {
        new successed
        successed = delete_file(next_logfile)
        log_amx("[CLEANER]: %s to delete file %s", successed ? "Successed" : "Failed", next_logfile)
    }
}