#include <amxmodx>
#include <fakemeta>

#define VERSION "5.3en"
#pragma semicolon 1

new bhopg[33],bhopf[33],in_check[33],checked[33],detected[33],b_sc[33],b_c[33],icvar[33];

public plugin_init() {
    register_plugin("Anty KzH by Niscree", VERSION, "Niscree");
    register_cvar("nsc_kz_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
    register_clcmd("NSC666x", "scripts");
    register_forward(FM_PlayerPreThink, "Forward");
    set_task(60.0, "reset", 0, "", 0, "b");
}

public set(id) {
    new a_scripts[1048], b_scripts[1048];
    formatex(a_scripts,1047,"echo |#SerwerChronionyPrzez;alias hang NSC666x;alias zzaplecow666 NSC666x;alias +spowolnienie666 NSC666x;alias +ramp NSC666x;alias +superstrefy2 NSC666x;alias +fa$.dsj@1 NSC666x;alias +fastrun NSC666x;alias +fastgs4 NSC666x;alias gvd NSC666x;alias +ramp NSC666x;alias rightstrafe8 NSC666x;alias rightstrafe10 NSC666x;alias +T_wolnomo NSC666x;");	
    add(a_scripts,1047, "alias +T_szybkomo NSC666x;alias kamera_tog NSC666x;alias T_pre_cj NSC666x;alias T_autolj_100aa NSC666x;alias +T_szybkie_strefy2 NSC666x;alias +T_strefy_10aa2 NSC666x;alias +T_strefy_cj NSC666x;alias +T_strefy_lj NSC666x;alias +superstrefy NSC666x;alias +duckowanie666 NSC666x;alias +T_jumpbug3 NSC666x;alias +1 NSC666x;alias +2 NSC666x;alias +3 NSC666x;alias +4 NSC666x;alias +5 NSC666x;alias +6 NSC666x");
    formatex(b_scripts,1047,"echo |#AntyKZHackbyNiscree;alias +bhop NSC666x;alias +bh NSC666x;alias +cj NSC666x;alias +jb NSC666x;alias +lj NSC666x;alias +strefy NSC666x;alias w1 NSC666x;alias w2 NSC666x;alias w3 NSC666x;alias w4 NSC666x;alias w5 NSC666x;alias w6 NSC666x;alias w10 NSC666x;alias w20 NSC666x;alias wait1 NSC666x;alias wait2 NSC666x;alias wait3 NSC666x;alias wait4 NSC666x;alias wait5 NSC666x;alias wait6 NSC666x;alias wait10 NSC666x;alias wait20 NSC666x;");
    add(b_scripts,1047, "alias +1csg46wolno NSC666x;alias +1csg46fastrun NSC666x;alias 1csg46hang NSC666x;alias 1csg46hon NSC666x;alias 1csg46autoduck NSC666x;alias 1csg46adon NSC666x;alias 1csg46morefps NSC666x;alias 1csg46normalfps NSC666x;alias +1csg46gs NSC666x;alias autoduck NSC666x;alias slowmo_toggle NSC666x;"); 
    client_cmd(id, a_scripts); 
    client_cmd(id, b_scripts); 
}

public scripts(id) {
    if(!b_sc[id]) {
        ban(id, "scripts");
        b_sc[id] = 1;
    }
    return PLUGIN_HANDLED;
}

public reset() {
    new p[32],num;
    get_players(p,num);	
    for(new i=0;i<num;i++) {	
        if (!is_user_connected(p[i]) && !is_user_alive(p[i]) && !in_check[p[i]])
            continue;
        checked[p[i]] = false;
        bhopg[p[i]] = 0;
        bhopf[p[i]] = 0;
        
        set(p[i]);
    }
}

public Forward(id) {
    if(!is_user_alive(id)) 
        return PLUGIN_HANDLED;
    if(is_user_alive(id) && pev(id,pev_button) & IN_JUMP) {
        if(pev(id,pev_flags) & FL_ONGROUND) { 
            bhopg[id]++;
            if(bhopg[id] > 8 && bhopf[id] == 0 && !in_check[id]){
                in_check[id] = true;
        }}
        else bhopf[id]++;
    }
    if(!(pev(id,pev_flags) & FL_ONGROUND) && in_check[id] && !checked[id]) {
        client_cmd(id, "+jump;wait;+jump;wait;wait;+jump");
        set_task( 0.6, "check", id);
        checked[id] = true;
    }
    return PLUGIN_HANDLED;
}

public check(id) {
    client_cmd(id, "-jump");
    if(bhopf[id] == 0){
        detected[id]++;
        if(detected[id] == 1) { 
            ban(id, "Auto Bhop"); 
        }
        else {
            bhopf[id] = 0;
            bhopg[id] = 0;
        }
    }
    else { 
        in_check[id] = false; 
    }
    return PLUGIN_HANDLED;
}

public client_putinserver( id ) {
    reseting(id);
    set_task(10.0, "cvars", id);
    set(id);
}

public client_disconnect(id) { 
    reseting(id); 
}

reseting(id) {
    bhopf[id] = 0;
    bhopg[id] = 0;
    detected[id] = 0;
    in_check[id] = false;
    checked[id] = false;
    b_sc[id] = 0;
    b_c[id] = 0;
    icvar[id] = 0;
    if(task_exists( id ))
        remove_task( id );
}

public cvars( id ) {
    if (is_user_connected(id) && !is_user_hltv(id)) {
        query_client_cvar( id, "kzh_bhop", "checking" );
        query_client_cvar( id, "kyk_bhop", "checking" );
        query_client_cvar( id, "001_bhop", "checking" );
        query_client_cvar( id, "002_bhop", "checking" );
        query_client_cvar( id, "Trk_bhop", "checking" );
        query_client_cvar( id, "m3c_bhop", "checking" );
        query_client_cvar( id, "m4c_bhop", "checking" );
        query_client_cvar( id, "zhy_bhop", "checking" );
        query_client_cvar( id, "zhe_bhop", "checking" );
        query_client_cvar( id, "n1k<bhop", "checking" );  
        query_client_cvar( id, "nkz_bhop", "checking" );
        query_client_cvar( id, "nik_bhop", "checking" ); 
        query_client_cvar( id, "xhack_bhop", "checking" );
        query_client_cvar( id, "xhz_bhop", "checking" );
        query_client_cvar( id, "xkz_bhop", "checking" ); 
    }
}

public checking( id, const typ[ ], const value[ ] ) {
    if(!is_user_connected(id)) 
        return PLUGIN_HANDLED;
    icvar[id]++;
    if( value[0] != 'B' ) {
        new reason[16];
        if(icvar[id]==1) reason = "KZ Hack";
        else if(icvar[id]==2) reason = "Kyk Hack";
        else if(icvar[id]>=3&&icvar[id]<=7) reason = "Trawka Hack";
        else if(icvar[id]==8||icvar[id]==9) reason = "Zhyk Hack";
        else if(icvar[id]>=10&&icvar[id]<=12) reason = "N1KzHack";
        else if(icvar[id]>12) reason = "xHack";
        ban( id, reason );
    }
    return PLUGIN_HANDLED;
}

public ban(id, reason[]) {
    if(is_user_connected(id)) {
        log_amx("[ANTI_BHOP]: amx_ban %d #%d %s", 10080, get_user_userid(id), reason);
        server_cmd("amx_ban %d #%d %s", 10080, get_user_userid(id), reason);
    }
}
