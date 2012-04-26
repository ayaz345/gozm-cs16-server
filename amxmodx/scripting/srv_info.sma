/* This plugin is made by xakintosh with Amxmodx Studio 1.4.3 (final) */
// Thanks to @He3aBucuM
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

new hud_rgb, hud_x, hud_y, hud_effects,maxplayers,hudsync;
new Float:globalfps2 = 0.0;
new Float:globalfps3 = 0.0;
new Float:globalfpsmin = 10001.0;
new Float:globalfpsmax = 0.0;
new counter=0;

public plugin_init() {
     register_plugin("Server Side Info","1.6","xakintosh")
     hud_rgb = register_cvar( "srv_hud_rgb", "0 255 0" )
     hud_x = register_cvar( "srv_hud_x", "0.01" )
     hud_y = register_cvar( "srv_hud_y", "0.18" )
     hud_effects = register_cvar( "srv_hud_effects", "0" )
     hudsync = CreateHudSyncObj()
     maxplayers = get_maxplayers()
     set_task(1.0, "Fwd_StartFrame", 1, "", 0, "b")
     set_task(300.0, "Fwd_OutInfoFile", 1, "", 0, "b")
     register_forward(FM_StartFrame, "Fwd_StartFrame")
}
public Fwd_StartFrame(id) {
	new timestring[31]
	get_time("%H:%M:%S",timestring,8)
    static Float:GameTime, Float:FramesPer = 0.0
    static Float:Fps
    GameTime = get_gametime()
    if(FramesPer >= GameTime)
        Fps += 1.0;
    else {
        FramesPer = FramesPer + 1.0;
        if (globalfpsmin > Fps) { globalfpsmin = Fps; }
        if (globalfpsmax < Fps) { globalfpsmax = Fps; }
        counter = counter + 1;
        globalfps2 = (globalfps2+Fps);
        if(counter==300){
            globalfps3 = ( globalfps2/counter );
            counter = 0;
            globalfps2 = 0.0;
        }
        for( new id = 1; id <= maxplayers; id++ ) { 
            new red, green, blue
            get_hud_color(red, green, blue)
			new timeleft = get_timeleft()
			set_hudmessage(red,green,blue,get_pcvar_float(hud_x),get_pcvar_float(hud_y),get_pcvar_num(hud_effects),6.0,1.0)
            ShowSyncHudMsg(id,hudsync,"FPS: %.1f^nNext: %d:%02d^nTime: %s",Fps,timeleft / 60, timeleft % 60,timestring)
        }
        Fps = 0.0
    }
}
get_hud_color(&r, &g, &b) {
    new color[20]
    static red[5], green[5], blue[5]
    get_pcvar_string(hud_rgb, color, charsmax(color))
    parse(color, red, charsmax(red), green, charsmax(green), blue, charsmax(blue))
    r = str_to_num(red)
    g = str_to_num(green)
    b = str_to_num(blue)
}

public Fwd_OutInfoFile(id) {
    new i
    new szData[100]
    i = fopen("/stat.txt","w");
    if(i!=0){
        format(szData,sizeof(szData)-1, "%.1f %.1f %.1f",globalfps3,globalfpsmin,globalfpsmax);
        fputs(i,szData);
        fclose(i);
        globalfpsmin = 10001.0;
        globalfpsmax = 0.0;
    }
}