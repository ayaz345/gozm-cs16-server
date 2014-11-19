/**
*	Simple plugin to protect server against recently created fake flooder.
*
*	Home post:
*	  http://c-s.net.ua/forum/index.php?act=findpost&pid=638816
*
*	Last update:
*	  8/7/2014
*
*	Credits:
*	- Zetex for 'IP converter' stocks
*/

/*	Copyright © 2014  Safety1st

	BanIP Fakes is free software;
	you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <amxmodx>
#include <celltrie>

#define PLUGIN "BanIP Fakes"
#define VERSION "0.2"
#define AUTHOR "Safety1st"

/*---------------EDIT ME------------------*/
#define MAX_SAME_IP        3	// how many players allowed with the same IP address
#define BAN_DURATION       33
new gszKickMsg[] =         "bye"

//#define WHITELIST_SIZE   4	// EXACTLY as rows quantity below; uncomment to enable whitelist

#if defined WHITELIST_SIZE
new const gszWhiteList[WHITELIST_SIZE][] = {
	"127.0.0.0/8",         // loopback interface (usually assigned IP is 127.0.0.1)
	"192.168.0.0/24",      // 192.168.0.0/24 subnet, IPs range 192.168.0.0 ... 192.168.0.255
	"10.3.3.2/24",         // 10.3.3.0/24 subnet, we could use any of its IPs here
	"141.101.120.244"      // c-s.net.ua IP
}
#endif
/*----------------------------------------*/

#define DEBUG	// uncomment to enable some messages

new gszPlayerIP[MAX_PLAYERS][16]
new Trie:gtPlayerIPs

#if defined WHITELIST_SIZE
enum _:WhitelistData {
	NET_IP,
	NET_MASK
}
new Array:gaWhitelist
#endif

#define FIRST_PLAYER   1
#define SINGLE_PLAYER  1

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR )
	register_cvar( "banipfakes_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED )

	gtPlayerIPs = TrieCreate()

#if defined WHITELIST_SIZE
	new iData[WhitelistData]
	gaWhitelist = ArrayCreate(WhitelistData)

	for( new i; i < WHITELIST_SIZE; i++ ) {
		net_to_long( gszWhiteList[i], iData[NET_IP], iData[NET_MASK] )
		ArrayPushArray( gaWhitelist, iData )
	}
#endif
}

public client_putinserver(id) {
	new szPlayerIP[16]
	get_user_ip( id, szPlayerIP, charsmax(szPlayerIP), 1 /* without port */ )

#if defined WHITELIST_SIZE
	new iData[WhitelistData]
	for( new i; i < WHITELIST_SIZE; i++ ) {
		ArrayGetArray( gaWhitelist, i, iData )
		if( iData[NET_IP] == ip_to_long(szPlayerIP) & iData[NET_MASK] ) {
			#if defined DEBUG
			server_print( "White IP detected: id %d, IP %s", id, szPlayerIP )
			#endif
			return
		}
	}
#endif

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