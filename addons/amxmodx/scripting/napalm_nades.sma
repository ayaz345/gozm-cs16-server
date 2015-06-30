#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <biohazard>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// Explosion sounds
new const grenade_fire[][] = { "weapons/hegrenade-1.wav" }

// Grenade sprites
new const sprite_grenade_fire[] = "sprites/flame.spr"
new const sprite_grenade_smoke[] = "sprites/black_smoke3.spr"
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"
new const sprite_grenade_ring[] = "sprites/shockwave.spr"

// Glow and trail colors (red, green, blue)
const NAPALM_R = 200
const NAPALM_G = 0
const NAPALM_B = 0

/*===============================================================================*/

// Burning task
const TASK_BURN = 1000
#define ID_BURN (taskid - TASK_BURN)
#define BURN_DURATION args[0]
#define BURN_ATTACKER args[1]

// CS Player PData Offsets (win32)
const OFFSET_CSTEAMS = 114
const OFFSET_LINUX = 5 // offsets +5 in Linux builds

// CS Player CBase Offsets (win32)
const OFFSET_ACTIVE_ITEM = 373

// pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_NAPALM = 681856

// pev_ field used to store napalm's custom ammo
const PEV_NAPALM_AMMO = pev_flSwimTime

// Precached sprites indices
new g_flameSpr, g_smokeSpr, g_trailSpr, g_exploSpr

// Messages
new g_msgDamage

// CVAR pointers
new cvar_radius, cvar_duration, cvar_slowdown, cvar_damage

// Cached stuff
new g_maxplayers
new g_duration, g_damage, Float:g_slowdown, Float:g_radius

// Precache all custom stuff
public plugin_precache()
{
    for (new i=0; i < sizeof(grenade_fire); i++)
        engfunc(EngFunc_PrecacheSound, grenade_fire[i])

    g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
    g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
    g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
    g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
}

public plugin_init()
{
    // Register plugin call
    register_plugin("Napalm Nades", "1.3a", "MeRcyLeZZ")

    // Events
    register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

    // Forwards
    register_forward(FM_SetModel, "fw_SetModel")
    RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")

    // CVARS
    cvar_radius = register_cvar("napalm_radius", "240")
    cvar_duration = register_cvar("napalm_duration", "5")
    cvar_damage = register_cvar("napalm_damage", "8")
    cvar_slowdown = register_cvar("napalm_slowdown", "0.77")

    g_maxplayers = get_maxplayers()

    // Message ids
    g_msgDamage = get_user_msgid("Damage")
}

public plugin_cfg()
{
    // Cache CVARs after configs are loaded
    set_task(0.5, "event_round_start")
}

// Round Start Event
public event_round_start()
{
    // Cache CVARs
    g_duration = get_pcvar_num(cvar_duration)
    g_slowdown = get_pcvar_float(cvar_slowdown)
    g_damage = floatround(get_pcvar_float(cvar_damage), floatround_ceil)
    g_radius = get_pcvar_float(cvar_radius)

    // Stop any burning tasks on players
    static id
    for (id=1; id<=g_maxplayers; id++)
        remove_task(id+TASK_BURN)
}

// Set Model Forward
public fw_SetModel(entity, const model[])
{
    // Get damage time of grenade
    static Float:dmgtime
    pev(entity, pev_dmgtime, dmgtime)

    // Grenade not yet thrown
    if (dmgtime == 0.0)
        return FMRES_IGNORED

    // Not an affected grenade (only HE)
    if (!equal(model[7], "w_he", 4))
        return FMRES_IGNORED

    // Get owner of grenade and napalm weapon entity
    static owner, napalm_weaponent
    owner = pev(entity, pev_owner)
    napalm_weaponent = fm_get_user_current_weapon_ent(owner)

    // Get owner's team
    static owner_team
    owner_team = fm_get_user_team(owner)

    // Give it a glow
    fm_set_rendering(entity, kRenderFxGlowShell, NAPALM_R, NAPALM_G, NAPALM_B, kRenderNormal, 16)

    // And a colored trail
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_BEAMFOLLOW) // TE id
    write_short(entity) // entity
    write_short(g_trailSpr) // sprite
    write_byte(10) // life
    write_byte(10) // width
    write_byte(NAPALM_R) // r
    write_byte(NAPALM_G) // g
    write_byte(NAPALM_B) // b
    write_byte(200) // brightness
    message_end()

    // Reduce napalm ammo
    static napalm_ammo
    napalm_ammo = pev(napalm_weaponent, PEV_NAPALM_AMMO)
    set_pev(napalm_weaponent, PEV_NAPALM_AMMO, --napalm_ammo)

    // Run out of napalms?
    if (napalm_ammo < 1)
    {
        // Remove napalm flag from the owner's weapon entity
        set_pev(napalm_weaponent, PEV_NADE_TYPE, 0)
    }

    // Set grenade type on the thrown grenade entity
    set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)

    // Set owner's team on the thrown grenade entity
    set_pev(entity, pev_team, owner_team)

    return FMRES_IGNORED;
}

// Grenade Think Forward
public fw_ThinkGrenade(entity)
{
    // Invalid entity
    if (!pev_valid(entity))
        return HAM_IGNORED

    // Get damage time of grenade
    static Float:dmgtime
    pev(entity, pev_dmgtime, dmgtime)

    // Check if it's time to go off
    if (dmgtime > get_gametime())
        return HAM_IGNORED

    // Not a napalm grenade
    if (pev(entity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
        return HAM_IGNORED

    // Explode event
    napalm_explode(entity)

    // Keep the original explosion
    set_pev(entity, PEV_NADE_TYPE, 0)
    return HAM_IGNORED
}

// Napalm Grenade Explosion
napalm_explode(ent)
{
    // Get attacker and its team
    static attacker, attacker_team
    attacker = pev(ent, pev_owner)
    attacker_team = pev(ent, pev_team)

    // Get origin
    static Float:originF[3]
    pev(ent, pev_origin, originF)

    // Custom explosion effect
    create_blast2(originF)

    // Napalm explosion sound
    engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, grenade_fire[random_num(0, sizeof grenade_fire - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

    // Collisions
    static victim
    victim = -1

    if (is_user_zombie(attacker))
        return

    while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, g_radius)) != 0)
    {
        // Only effect alive players
        if (!is_user_alive(victim))
            continue

        //MINE
        if (!is_user_zombie(victim))
            continue

        // myself is not allowed
        if (victim == attacker)
            continue

        // Check if friendly fire is allowed
        if (attacker_team == fm_get_user_team(victim))
            continue

        // Heat icon
        message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
        write_byte(0) // damage save
        write_byte(0) // damage take
        write_long(DMG_BURN) // damage type
        write_coord(0) // x
        write_coord(0) // y
        write_coord(0) // z
        message_end()

        // Our task params
        static params[2]
        params[0] = g_duration * 5 // duration
        params[1] = attacker // attacker

        // Set burning task on victim
        set_task(0.1, "burning_flame", victim+TASK_BURN, params, sizeof(params))
    }
}

// Burning Task
public burning_flame(args[2], taskid)
{
    // Player died/disconnected
    if (!is_user_alive(ID_BURN))
        return

    // Get player origin and flags
    static Float:originF[3], flags
    pev(ID_BURN, pev_origin, originF)
    flags = pev(ID_BURN, pev_flags)

    // In water or burning stopped
    if ((flags & FL_INWATER) || BURN_DURATION < 1)
    {
        // Smoke sprite
        engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
        write_byte(TE_SMOKE) // TE id
        engfunc(EngFunc_WriteCoord, originF[0]) // x
        engfunc(EngFunc_WriteCoord, originF[1]) // y
        engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
        write_short(g_smokeSpr) // sprite
        write_byte(random_num(15, 20)) // scale
        write_byte(random_num(10, 20)) // framerate
        message_end()

        return
    }

    // Fire slow down
    if (g_slowdown > 0.0 && (flags & FL_ONGROUND))
    {
        static Float:velocity[3]
        pev(ID_BURN, pev_velocity, velocity)
        xs_vec_mul_scalar(velocity, g_slowdown, velocity)
        set_pev(ID_BURN, pev_velocity, velocity)
    }

    // Get victim's health
    static health
    health = pev(ID_BURN, pev_health)

    // Take damage from the fire
    if (health - g_damage > 0)
        set_pev(ID_BURN, pev_health, float(health - g_damage))

    // Flame sprite
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_SPRITE) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
    engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
    engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
    write_short(g_flameSpr) // sprite
    write_byte(random_num(5, 10)) // scale
    write_byte(200) // brightness
    message_end()

    // Decrease task cycle count
    BURN_DURATION -= 1

    // Keep sending flame messages
    set_task(0.4, "burning_flame", taskid, args, sizeof args)
}

// Napalm Grenade: Fire Blast (originally made by Avalanche in Frostnades)
create_blast2(const Float:originF[3])
{
    // Smallest ring
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_BEAMCYLINDER) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
    write_short(g_exploSpr) // sprite
    write_byte(0) // startframe
    write_byte(0) // framerate
    write_byte(4) // life
    write_byte(60) // width
    write_byte(0) // noise
    write_byte(200) // red
    write_byte(100) // green
    write_byte(0) // blue
    write_byte(200) // brightness
    write_byte(0) // speed
    message_end()

    // Medium ring
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_BEAMCYLINDER) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
    write_short(g_exploSpr) // sprite
    write_byte(0) // startframe
    write_byte(0) // framerate
    write_byte(4) // life
    write_byte(60) // width
    write_byte(0) // noise
    write_byte(200) // red
    write_byte(50) // green
    write_byte(0) // blue
    write_byte(200) // brightness
    write_byte(0) // speed
    message_end()

    // Largest ring
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_BEAMCYLINDER) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
    write_short(g_exploSpr) // sprite
    write_byte(0) // startframe
    write_byte(0) // framerate
    write_byte(4) // life
    write_byte(60) // width
    write_byte(0) // noise
    write_byte(200) // red
    write_byte(0) // green
    write_byte(0) // blue
    write_byte(200) // brightness
    write_byte(0) // speed
    message_end()
}

// Set entity's rendering type (from fakemeta_util)
fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
    static Float:color[3]
    color[0] = float(r)
    color[1] = float(g)
    color[2] = float(b)

    set_pev(entity, pev_renderfx, fx)
    set_pev(entity, pev_rendercolor, color)
    set_pev(entity, pev_rendermode, render)
    set_pev(entity, pev_renderamt, float(amount))
}

// Get User Current Weapon Entity
fm_get_user_current_weapon_ent(id)
{
    return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

// Get User Team
fm_get_user_team(id)
{
    return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}
