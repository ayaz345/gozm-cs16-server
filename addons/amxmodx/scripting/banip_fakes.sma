#include <amxmodx>

#define PLUGIN "BanIP Fakes"
#define VERSION "0.2"
#define AUTHOR "Safety1st"

/*---------------EDIT ME------------------*/
#define MAX_SAME_IP        3	// how many players allowed with the same IP address
#define BAN_DURATION       33
new gszKickMsg[] =         "bye"

#define DEBUG	// uncomment to enable some messages

new gszPlayerIP[MAX_PLAYERS][16]
new Trie:gtPlayerIPs

#define FIRST_PLAYER   1
#define SINGLE_PLAYER  1

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR )
	register_cvar( "banipfakes_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED )

	gtPlayerIPs = TrieCreate()
}

public client_putinserver(id) {
	new szPlayerIP[16]
	get_user_ip( id, szPlayerIP, charsmax(szPlayerIP), 1 /* without port */ )

	new iQuantity = FIRST_PLAYER
	if( TrieGetCell( gtPlayerIPs, szPlayerIP, iQuantity ) ) {
		if( ++iQuantity > MAX_SAME_IP ) {
			server_cmd( "kick #%d  %s; wait; addip %d %s", get_user_userid(id), gszKickMsg, BAN_DURATION, szPlayerIP )
			static szBanMsg[] = "IP %s has been banned for %d minutes"
			log_amx( szBanMsg, szPlayerIP, BAN_DURATION )
		}
	}

	TrieSetCell( gtPlayerIPs, szPlayerIP, iQuantity )
	copy( gszPlayerIP[id], charsmax( gszPlayerIP[] ), szPlayerIP )
}

public client_disconnect(id) {
	if( !gszPlayerIP[id][0] )
		// whitelisted player or not fully initialized one (it could happen nearly a map change)
		return

	new iQuantity
	TrieGetCell( gtPlayerIPs, gszPlayerIP[id], iQuantity )
	if( iQuantity == SINGLE_PLAYER )
		TrieDeleteKey( gtPlayerIPs, gszPlayerIP[id] )
	else
		TrieSetCell( gtPlayerIPs, gszPlayerIP[id], --iQuantity )

	gszPlayerIP[id][0] = EOS
}

/*-- Modified and simplified 'IP converter stocks' by Zetex --*/

// Gets net and mask as LONG from subnet.
stock net_to_long( net_string[], &net, &mask ) {
	new i, ip[16]

	i = copyc( ip, charsmax(ip), net_string, '/' )
	mask = i ? cidr_to_long( net_string[i + 1] ) : 0xFFFFFFFF /* mask /32, IP itself */

	net = ip_to_long(ip) & mask
}

// Converts mask to LONG. Returns unsigned long.
stock cidr_to_long( mask_string[] ) {
	new mask = str_to_num(mask_string)
	new result = (1 << 31) >> (mask - 1)

	return result
}

// Converts IP to LONG. Returns unsigned long.
stock ip_to_long( ip_string[] ) {
	new right[16], part[4], octet, ip = 0
	strtok( ip_string, part, 3, right, 15, '.' )

	for( new i = 0; i < 4; i++ ) {
		octet = str_to_num(part)

		ip += octet

		if( i == 3 )
			break

		strtok( right, part, 3, right, 15, '.' )
		ip = ip << 8
	}

	return ip
}