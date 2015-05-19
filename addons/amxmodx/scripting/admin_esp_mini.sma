#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <colored_print>
#include <gozm>

#define OFFSET_TEAM    114
   
enum {
    ESP_ON = 0,
    ESP_LINE,
    ESP_BOX
}

new g_maxplayers
new g_isconnected[MAX_PLAYERS + 1]
new g_isalive[MAX_PLAYERS + 1]
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

new bool:admin[33], bool:first_person[33], bool:ducking[33], bool:admin_options[33][10], bool:is_in_menu[33]
new team_colors[4][3]={{0,0,0},{150,0,0},{0,0,150},{0,150,0}} 
new esp_colors[5][3]={{0,255,0},{100,60,60},{60,60,100},{255,0,255},{128,128,128}}
new view_target[33], damage_done_to[33], spec[33], laser
   
public plugin_init()
{
    register_plugin("Admin Spectator ESP", "1.6", "KoST")

    register_clcmd("esp_menu", "cmd_esp_menu", ADMIN_KICK, "Shows ESP Menu")
    register_clcmd("esp_toggle", "cmd_esp_toggle", ADMIN_KICK, "Toggle ESP on/off")
    register_clcmd("esp_setting", "cmd_esp_settings", ADMIN_KICK, "ESP adasdsassdasd")

    register_event("StatusValue", "spec_target", "bd", "1=2")
    register_event("SpecHealth2", "spec_target", "bd")
    register_event("TextMsg", "spec_mode", "b", "2&#Spec_Mode")
    register_event("Damage", "event_Damage", "b", "2!0", "3=0", "4!0")
    register_event("ResetHUD", "reset_hud_alive", "be")

    register_forward(FM_PlayerPreThink, "fwdPlayerPreThink")    

    RegisterHam(Ham_Killed, "player", "bacon_killed_player")
    RegisterHam(Ham_Spawn, "player", "bacon_spawn_player_post", 1)

    new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2
    register_menucmd(register_menuid("Admin Specator ESP"), keys, "menu_esp")

    g_maxplayers = get_maxplayers()

    set_task(1.0, "esp_timer")
}
   
public plugin_precache()
    laser=precache_model("sprites/laserbeam.spr")
   
public client_putinserver(id)
{
    first_person[id] = false
    g_isconnected[id] = true

    if (is_priveleged_user(id))
    {
        admin[id]=true
        init_admin_options(id)
    }
    else
        admin[id]=false
}
   
public client_disconnect(id)
{
    g_isconnected[id] = false
    g_isalive[id] = false

    save2vault(id)
    admin[id] = false
    spec[id] = 0
}
   
public reset_hud_alive(id)
    spec[id] = 0
   
public cmd_esp_settings(id)
{
    if (admin[id])
    {
        new out[11], len = strlen(out)
        read_argv(1, out, 4)
        for (new i=0;i<len;i++)
        {
            if (out[i]=='1')
                admin_options[id][i]=true
            else
                admin_options[id][i]=false
        }
    }
}
   
public cmd_esp_menu(id)
{
    if (admin[id])
    {
        show_esp_menu(id)
    }
}
   
public cmd_esp_toggle(id)
{
    if (admin[id])
    {
        change_esp_status(id, !admin_options[id][0])
    }
}
   
show_esp_menu(id)
{
    is_in_menu[id] = true
    new menu[501]
    new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2
    new onoff[2][] = {{"\roff\w"},{"\yon\w"}}
    new text[2][] = {{"(use move forward/backward to switch on/off)"},{"(use esp_toggle command to toggle)"}}
    formatex(menu, 500, "Admin Specator ESP^n %s %s^n^n1. Линии %s^n2. Квадраты %s^n^n0. Выход", onoff[admin_options[id][ESP_ON]], text[0],
    onoff[admin_options[id][ESP_LINE]],
    onoff[admin_options[id][ESP_BOX]])
    show_menu(id, keys,menu)
       
    return PLUGIN_HANDLED
}
   
public menu_esp(id, key)
{
    if (key==9)
    {
        is_in_menu[id]=false
        return PLUGIN_HANDLED
    }
    if (admin_options[id][key+1])
        admin_options[id][key+1]=false
    else
        admin_options[id][key+1]=true
   
    show_esp_menu(id)
    return PLUGIN_HANDLED
}
   
public event_Damage(id)
{
    if (id>0) 
    {
        new attacker=get_user_attacker(id)
        if (attacker>0 && attacker<=g_maxplayers)
        { 
            if (view_target[attacker]==id)
                damage_done_to[attacker]=id
        }
    }
    return PLUGIN_CONTINUE
}
   
public spec_mode(id)
{
    new specMode[12]
    read_data(2, specMode, 11)
       
    if(equal(specMode,"#Spec_Mode4"))
        first_person[id]=true
    else
        first_person[id]=false
   
    return PLUGIN_CONTINUE
}
   
public spec_target(id)
{
    if (id>0)
    {
        new target=read_data(2)
        if (target!=0)
            spec[id]=target
    }
    return PLUGIN_CONTINUE
}
   
init_admin_options(id)
{
    for (new i=0;i<4;i++)
    {
        admin_options[id][i] = true
    }
    admin_options[id][1] = false  // - disable lines by default
    load_vault_data(id)
}
   
save2vault(id)
{
    if (admin[id])
    {
        new authid[35], tmp[11], key[41]
        get_user_authid(id, authid, charsmax(authid)) 
       
        for (new s=0;s<4;s++)
        {
            if (admin_options[id][s])
                tmp[s]='1'
            else
                tmp[s]='0'
        }
        tmp[4]=0
   
        formatex(key, charsmax(key), "ESP_%s", authid)
        set_vaultdata(key, tmp)
    }
}
   
load_vault_data(id)
{
    if (admin[id])
    {
        new data[11], authid[35], key[41]
        get_user_authid (id, authid, charsmax(authid))
        formatex(key, 40, "ESP_%s", authid) 
        get_vaultdata(key, data, 4)
        if (strlen(data) > 0)
        {
            for (new s=0;s<4;s++)
            {
                if (data[s]=='1')
                    admin_options[id][s]=true
                else
                    admin_options[id][s]=false
            }
        }
    }
}
   
change_esp_status(id, bool:on)
{
    if (on)
    {
        admin_options[id][0] = true
        if (!is_in_menu[id]) colored_print(id, "^x04[ADMIN SPEC]^x01 Активировано")
        if (is_in_menu[id]) show_esp_menu(id)
    }
    else
    {
        admin_options[id][0] = false
        if (!is_in_menu[id]) colored_print(id, "^x04[ADMIN SPEC]^x01 Выключено")
        if (is_in_menu[id]) show_esp_menu(id)
    }
}
   
public fwdPlayerPreThink(id)
{
    if (!is_user_valid_connected(id)) return FMRES_IGNORED
       
    static button, oldbutton
    button=pev(id, pev_button)
    if (button==0) return FMRES_IGNORED

    oldbutton=pev(id, pev_oldbuttons)
       
    if (button & IN_DUCK)
        ducking[id]=true
    else
        ducking[id]=false
       
    if (admin[id])
    {
        if (first_person[id] && !is_user_valid_alive(id))
        {
            if ((button & IN_FORWARD) && !(oldbutton & IN_FORWARD) && !admin_options[id][0])
            {
                change_esp_status(id, true)
            }
            if ((button & IN_BACK) && !(oldbutton & IN_BACK) && admin_options[id][0])
            {
                change_esp_status(id, false)
            }
        }
    }

    return FMRES_HANDLED
}

public bacon_killed_player(victim, killer, shouldgib)
{
    g_isalive[victim] = false

    return HAM_IGNORED
}

public bacon_spawn_player_post(id)
{
    if(!is_user_valid_alive(id))
        return HAM_IGNORED

    g_isalive[id] = true

    return HAM_IGNORED
}

public esp_timer()
{
    static spec_id, Float:my_origin[3], my_team, target_team, Float:target_origin[3], Float:distance, width, Float:v_middle[3], 
    Float:v_hitpoint[3], Float:distance_to_hitpoint, Float:scaled_bone_len, Float:scaled_bone_width, Float:v_bone_start[3],
    Float:v_bone_end[3], Float:offset_vector[3], Float:eye_level[3], Float:distance_target_hitpoint, actual_bright, color
   
    for (new i=1;i<=g_maxplayers;i++)
    {
        if (admin_options[i][ESP_ON] && first_person[i] && is_user_valid_connected(i) && admin[i] && (!is_user_valid_alive(i)) && (spec[i]>0) && is_user_valid_alive(spec[i]))
        {
            spec_id=spec[i]
            pev(i, pev_origin, my_origin)
            my_team = get_pdata_int(spec_id, OFFSET_TEAM)
               
            for (new s=1;s<=g_maxplayers;s++)
            {
                if (is_user_valid_alive(s))
                {
                    target_team = get_pdata_int(s, OFFSET_TEAM)
                    if (!(target_team ==3))
                    {
                        if (spec_id !=s)
                        {
                            if (((my_team != target_team && (target_team ==1 || target_team ==2))))
                            {
                                pev(s, pev_origin, target_origin)
                                distance=vector_distance(my_origin, target_origin)
                                   
                                if (admin_options[i][ESP_LINE])
                                {
                                    if (distance<2040.0)
                                        width=(255-floatround(distance/8.0))/3
                                    else
                                        width=1
   
                                    make_TE_BEAMENTPOINT(i, target_origin, width,target_team)
                                }
   
                                subVec(target_origin,my_origin,v_middle)
   
                                engfunc(EngFunc_TraceLine, my_origin, target_origin, 1, -1, 0)
                                get_tr2(0, TR_vecEndPos, v_hitpoint)
   
                                distance_to_hitpoint = vector_distance(my_origin, v_hitpoint)
   
                                if (ducking[spec_id])
                                    scaled_bone_len=distance_to_hitpoint/distance*(50.0-18.0)
                                else
                                    scaled_bone_len=distance_to_hitpoint/distance*50.0
   
                                scaled_bone_len=distance_to_hitpoint/distance*50.0
                                scaled_bone_width=distance_to_hitpoint/distance*150.0
                                normalize(v_middle,offset_vector,distance_to_hitpoint-10.0)
   
                                copyVec(my_origin,eye_level)
                                   
                                if (ducking[spec_id])
                                    eye_level[2]+=12.3
                                else
                                    eye_level[2]+=17.5
   
                                addVec(offset_vector,eye_level)
   
                                copyVec(offset_vector,v_bone_start)
                                copyVec(offset_vector,v_bone_end)
                                v_bone_end[2]-=scaled_bone_len
                                   
                                distance_target_hitpoint=distance-distance_to_hitpoint
                                actual_bright=255
                                   
                                if (admin_options[i][ESP_BOX])
                                {
                                    if (distance_target_hitpoint<2040.0)
                                        actual_bright=(255-floatround(distance_target_hitpoint/12.0))
                                    else
                                        actual_bright=85
   
                                    if (distance_to_hitpoint!=distance)
                                        color=0
                                    else
                                        color=target_team
   
                                    if (damage_done_to[spec_id]==s)
                                    {
                                        color=3
                                        damage_done_to[spec_id]=0
                                    }
                                    make_TE_BEAMPOINTS(i,color,v_bone_start,v_bone_end,floatround(scaled_bone_width)
,actual_bright)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    set_task(0.4, "esp_timer")
    return PLUGIN_CONTINUE    
}
   
Float:getVecLen(Float:Vec[3])
{
    new Float:VecNull[3]={0.0,0.0,0.0}
    new Float:len=vector_distance(Vec,VecNull)
    return len
}
   
normalize(Float:Vec[3],Float:Ret[3],Float:multiplier)
{
    new Float:len=getVecLen(Vec)
    copyVec(Vec,Ret)
    Ret[0]/=len
    Ret[1]/=len
    Ret[2]/=len
    Ret[0]*=multiplier
    Ret[1]*=multiplier
    Ret[2]*=multiplier
}
   
copyVec(Float:Vec[3],Float:Ret[3])
{
    Ret[0]=Vec[0]
    Ret[1]=Vec[1]
    Ret[2]=Vec[2]
}
   
subVec(Float:Vec1[3],Float:Vec2[3],Float:Ret[3])
{
    Ret[0]=Vec1[0]-Vec2[0]
    Ret[1]=Vec1[1]-Vec2[1]
    Ret[2]=Vec1[2]-Vec2[2]
}
   
addVec(Float:Vec1[3],Float:Vec2[3])
{
    Vec1[0]+=Vec2[0]
    Vec1[1]+=Vec2[1]
    Vec1[2]+=Vec2[2]
}
   
make_TE_BEAMPOINTS(id,color,Float:Vec1[3],Float:Vec2[3],width,brightness)
{
    message_begin(MSG_ONE_UNRELIABLE ,SVC_TEMPENTITY,{0,0,0},id)
    write_byte(0)
    write_coord(floatround(Vec1[0]))
    write_coord(floatround(Vec1[1]))
    write_coord(floatround(Vec1[2]))
    write_coord(floatround(Vec2[0]))
    write_coord(floatround(Vec2[1]))
    write_coord(floatround(Vec2[2]))
    write_short(laser)
    write_byte(3)
    write_byte(0)
    write_byte(3)
    write_byte(width)
    write_byte(0)
    write_byte(esp_colors[color][0])
    write_byte(esp_colors[color][1])
    write_byte(esp_colors[color][2])
    write_byte(brightness)
    write_byte(0)
    message_end()
}
   
make_TE_BEAMENTPOINT(id,Float:target_origin[3],width,target_team)
{
    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},id)
    write_byte(1)
    write_short(id)
    write_coord(floatround(target_origin[0]))
    write_coord(floatround(target_origin[1]))
    write_coord(floatround(target_origin[2]))
    write_short(laser)
    write_byte(1)        
    write_byte(1)
    write_byte(3)
    write_byte(width)
    write_byte(0)
    write_byte(team_colors[target_team][0])
    write_byte(team_colors[target_team][1])
    write_byte(team_colors[target_team][2])
    write_byte(255)
    write_byte(0)
    message_end()
}
