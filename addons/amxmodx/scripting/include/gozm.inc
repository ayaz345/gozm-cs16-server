#if defined _gozm_included
    #endinput
#endif
#define _gozm_included

#define OWNER_FLAG		ADMIN_RCON
#define ADMIN_FLAG		ADMIN_BAN
#define VIP_FLAG 		ADMIN_LEVEL_H


stock bool:is_server_licenced()
{
    new server_ips[][20] = {
        "46.174.52.13:27259",  // MyArena
        "172.23.65.13:27016"  // Home
    }
    new current_ip[20]
    get_user_ip(0, current_ip, 19, 0);
    
    for(new c; c<sizeof server_ips; c++)
    {
        if(equal(current_ip, server_ips[c]))
            return true
    }
    return false
}

stock has_vip(id)
    return get_user_flags(id) & VIP_FLAG

stock has_admin(id)
    return get_user_flags(id) & ADMIN_FLAG
    
stock has_rcon(id)
    return get_user_flags(id) & OWNER_FLAG

stock is_priveleged_user(id)
    return get_user_flags(id) & (VIP_FLAG | ADMIN_FLAG | OWNER_FLAG)