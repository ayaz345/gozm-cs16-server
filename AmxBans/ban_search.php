<?php

/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
 *
 *	web		: http://www.xs4all.nl/~yomama/amxbans/
 *	mail	: yomama@xs4all.nl
 *	ICQ		: 104115504
 *
 *	This file is part of AMXBans.
 *
 *  AMXBans is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  AMXBans is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with AMXBans; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

// Start session
@session_start();

// Require basic site files
require("include/config.inc.php");


/*include("$config->path_root/include/accesscontrol.inc.php");

if( ($_SESSION['bans_add'] != "yes") && ($config->display_search != "enabled") ) {
	echo "You do not have the required credentials to view this page.";
	exit();
}*/


if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}
require("$config->path_root/include/functions.lang.php");
require("$config->path_root/include/functions.inc.php");

// Make the array for the admin list
$query		= "SELECT DISTINCT steamid, nickname FROM $config->amxadmins WHERE is_active AND ashow ORDER BY id ASC";
$resource	= mysql_query($query) or die(mysql_error());

$admin_array	= array();

while($result = mysql_fetch_object($resource)) {
	$steamid	= $result->steamid;
	$nickname	= htmlentities($result->nickname, ENT_QUOTES);


	// Asign variables to the array used in the template
	$admin_info = array(
		"steamid"	=> $steamid,
		"nickname"	=> $nickname
		);

	$admin_array[] = $admin_info;
}

// Make the array for the server list
$query2		= "SELECT address, hostname FROM $config->servers ORDER BY hostname ASC";
$resource2	= mysql_query($query2) or die(mysql_error());

$server_array	= array();

while($result2 = mysql_fetch_object($resource2)) {
	$address	= $result2->address;
	$hostname	= htmlentities($result2->hostname, ENT_QUOTES);


	// Asign variables to the array used in the template
	$server_info = array(
		"address"	=> $address,
		"hostname"	=> $hostname
		);

	$server_array[] = $server_info;
}


if ((isset($_POST['nick'])) || (isset($_POST['steamid'])) || (isset($_POST['ip'])) || (isset($_POST['reason'])) || (isset($_POST['date'])) || (isset($_POST['timesbanned'])) || (isset($_POST['admin'])) || (isset($_POST['server']))) {

	$query = "SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip, se.gametype FROM $config->bans AS ba LEFT JOIN $config->servers AS se ON ba.server_ip=se.address WHERE ";
	// Make the array for the active bans list
	if (isset($_POST['nick'])) {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE player_nick LIKE '%".$_POST['nick']."%' ORDER BY ban_created DESC") or die(mysql_error());
		$nick = mysql_escape_string($_POST['nick']);
		$query .= " player_nick LIKE '%$nick%'";
	} else if (isset($_POST['steamid']) && $_POST['steamid'] != '') {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE (player_id = '".$_POST['steamid']."' AND ban_type='S' ) OR ( player_ip='".$_POST['ip']."' AND ban_type='SI')  ORDER BY ban_created DESC") or die(mysql_error());
		$steamid = mysql_escape_string($_POST['steamid']);
        // $query .= " (player_id = '$nick' AND ban_type='S' ) OR ( player_ip='$ip' AND ban_type='SI') ";
		$query .= " player_id = '$steamid' ";
	} else if (isset($_POST['ip']) && $_POST['ip'] != '') {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE (player_id = '".$_POST['steamid']."' AND ban_type='S' ) OR ( player_ip='".$_POST['ip']."' AND ban_type='SI')  ORDER BY ban_created DESC") or die(mysql_error());
		$ip = mysql_escape_string($_POST['ip']);
        // $query .= " (player_id = '$nick' AND ban_type='S' ) OR ( player_ip='$ip' AND ban_type='SI') ";
		$query .= " player_ip='$ip' ";
    } else if (isset($_POST['reason'])) {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE ban_reason LIKE '%".$_POST['reason']."%' ORDER BY ban_created DESC") or die(mysql_error());
		$reason = mysql_escape_string($_POST['reason']);
		$query .= " ban_reason LIKE '%$reason%' ";//ORDER BY ban_created DESC ";
	} else if (isset($_POST['date'])) {
		$date		= substr_replace($_POST['date'], '', 2, 1);
		$date		= substr_replace($date, '', 4, 1);
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE FROM_UNIXTIME(ban_created,'%d%m%Y') LIKE '$date' ORDER BY ban_created DESC") or die(mysql_error());
		$date = mysql_escape_string($date);
		$query .= " FROM_UNIXTIME(ban_created,'%d%m%Y') LIKE '$date' ";
	} else if (isset($_POST['timesbanned'])) {
		$bcount = mysql_escape_string($_POST['timesbanned']);
		//Note: Not .=
		$query = "SELECT id, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip, COUNT(*) FROM $config->ban_history where player_id > '' GROUP BY player_id HAVING COUNT(*) >= '$bcount' ";
	} else if (isset($_POST['admin'])) {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE admin_id = '".$_POST['admin']."' ORDER BY ban_created DESC") or die(mysql_error());
		$admin = mysql_escape_string($_POST['admin']);
		$query .= " admin_nick = '$admin' ";
	} else if (isset($_POST['server'])) {
		// // $resource3	= mysql_query("SELECT bid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->bans WHERE server_ip = '".$_POST['server']."' ORDER BY ban_created DESC") or die(mysql_error());
		$server = mysql_escape_string($_POST['server']);
		$query .= " server_ip = '$server' ";
	} else  {
		echo "KOE";
	}
	$query .= " ORDER BY ban_created DESC LIMIT 100";
	//echo "$query";
	$resource3 = mysql_query($query) or die("<b>Mysql Error:</b> ".mysql_error());
	$ban_array	= array();
	$timezone = $config->timezone_fixx * 3600;
	$bancount = 0;

	while($result3 = mysql_fetch_object($resource3)) {
		$bid	  = $result3->bid;
		$date	  = dateShorttime($result3->ban_created + $timezone);
		$player	  = htmlentities($result3->player_nick, ENT_QUOTES);
		$admin	  = htmlentities($result3->admin_nick, ENT_QUOTES);
		//$reason   = htmlentities($result3->ban_reason, ENT_QUOTES);
        $reason = convert_cp1251_to_utf8($result3->ban_reason);
		$duration = $result3->ban_length;
		$serverip = $result3->server_ip;
		$bancount = $bancount+1;

		if ($serverip != "") {

			// // // Get the gametype for each ban
			// // $query4		= "SELECT gametype FROM $config->servers WHERE address = '$serverip'";
			// // $resource4	= mysql_query($query4) or die(mysql_error());
			// // while($result4 	= mysql_fetch_object($resource4)) {
				// // $gametype = $result4->gametype;
				$gametype = $result3->gametype;
		// // } else {
		}
		else {
			$gametype = "html";
		}

		if(empty($duration)) {
			$duration = lang("_PERMANENT");
		}
		else {
			$duration = "$duration " . lang("_MINS");
		}

		// Asign variables to the array used in the template
		$ban_info = array(
			"gametype"	=> $gametype,
			"bid"		=> $bid,
			"date"		=> $date,
			"player"	=> $player,
			"admin"		=> $admin,
			"reason"	=> $reason,
			"duration"	=> $duration,
			"bancount"	=> $bancount
			);

		$ban_array[] = $ban_info;
	}

	// Make the array for the expired bans list

	$query5 = "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip, se.gametype FROM $config->ban_history AS bh LEFT JOIN $config->servers AS se ON bh.server_ip=se.address WHERE ";
	if (isset($_POST['nick'])) {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE player_nick like '%".$_POST['nick']."%' ORDER BY ban_created DESC";
		$nick = mysql_escape_string($_POST['nick']);
		$query5	.= "player_nick like '%$nick%' ";
	} else if (isset($_POST['steamid']) && $_POST['steamid'] != '') {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE (player_id = '".$_POST['steamid']."' AND ban_type='S' ) OR ( player_ip='".$_POST['ip']."' AND ban_type='SI')  ORDER BY ban_created DESC";
		$steamid = mysql_escape_string($_POST['steamid']);
		$query5	.= " player_id = '$steamid' ";
    } else if (isset($_POST['ip']) && $_POST['ip'] != '') {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE (player_id = '".$_POST['steamid']."' AND ban_type='S' ) OR ( player_ip='".$_POST['ip']."' AND ban_type='SI')  ORDER BY ban_created DESC";
		$ip = mysql_escape_string($_POST['ip']);
		$query5	.= " player_ip='$ip' ";
	} else if (isset($_POST['reason'])) {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE ban_reason LIKE '%".$_POST['reason']."%' ORDER BY ban_created DESC";
		$reason = mysql_escape_string($_POST['reason']);
		$query5	.= " ban_reason LIKE '%$reason%' ";
	} else if (isset($_POST['date'])) {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE FROM_UNIXTIME(ban_created,'%d%m%Y') LIKE '$date' ORDER BY ban_created DESC";
		//We don't really need to redo the date.. but why not?
		$date		= substr_replace($_POST['date'], '', 2, 1);
		$date		= substr_replace($date, '', 4, 1);
		$date = mysql_escape_string($date);
		$query5	.= " FROM_UNIXTIME(ban_created,'%d%m%Y') LIKE '$date' ";
	} else if (isset($_POST['timesbanned'])) {
		$bancount = mysql_escape_string($_POST['timesbanned']);
		$query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip, COUNT(*) FROM $config->ban_history where player_id > '' GROUP BY player_id HAVING COUNT(*) >= '$bancount' ";
	} else if (isset($_POST['admin'])) {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE admin_id = '".$_POST['admin']."' ORDER BY ban_created DESC";
		$admin = mysql_escape_string($_POST['admin']);
		$query5	.= " admin_nick = '$admin' ";
	} else if (isset($_POST['server'])) {
		// // $query5	= "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE server_ip = '".$_POST['server']."' ORDER BY ban_created DESC";
		$server = mysql_escape_string($_POST['server']);
		$query5	.= " server_ip = '$server' ";
}
	$query5 .= " ORDER BY ban_created DESC LIMIT 100";

	$resource5	= mysql_query($query5) or die(mysql_error());
	$exban_array	= array();
	$ex_bancount = 0;

	while($result5 = mysql_fetch_object($resource5)) {
		$bhid		= $result5->bhid;
		$ex_date	= dateShorttime($result5->ban_created + $timezone);
		$ex_player	= $result5->player_nick;
		$ex_admin	= htmlentities($result5->admin_nick, ENT_QUOTES);
		//$ex_reason      = $result5->ban_reason;
        $ex_reason = convert_cp1251_to_utf8($result5->ban_reason);
		$ex_duration	= $result5->ban_length;
		$ex_serverip	= $result5->server_ip;

		$ex_bancount = $ex_bancount+1;

		if ($ex_serverip != "") {

			// // // Get the gametype for each ban
			// // $query6		= "SELECT gametype FROM $config->servers WHERE address = '$ex_serverip'";
			// // $resource6	= mysql_query($query6) or die(mysql_error());

			// // $ex_gametype = NULL;
			// // while($result6 = mysql_fetch_object($resource6)) {
			$ex_gametype = $result5->gametype;
			// // }

			// // // If a ban that have a serverip that's NOT in the table amx_serverinfo use the steam icon
			// // if ($ex_gametype == "")
				// // $ex_gametype = "steam";

		} else {
			$ex_gametype = "html";
		}

		if(empty($ex_duration)) {
			$ex_duration = lang("_PERMANENT");
		}	else {
			$ex_duration = $ex_duration." ".lang("_MINS");
		}

		// Asign variables to the array used in the template
		$exban_info = array(
			"ex_gametype"	=> $ex_gametype,
			"bhid"		=> $bhid,
			"ex_date"	=> $ex_date,
			"ex_player"	=> $ex_player,
			"ex_admin"	=> $ex_admin,
			"ex_reason"	=> $ex_reason,
			"ex_duration"	=> $ex_duration,
			"ex_bancount"	=> $ex_bancount
			);

		$exban_array[] = $exban_info;
	}
}

/****************************************************************
* Template parsing
****************************************************************/

// Header
$title = lang("_SEARCH");

// Section
$section = "search";

// Parsing
$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("dir",$config->document_root);

$smarty->assign("fancy_layers", $config->fancy_layers);
$smarty->assign("display_reason", $config->display_reason);
$smarty->assign("display_search", $config->display_search);
$smarty->assign("display_admin", $config->display_admin);

$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("section",$section);
$smarty->assign("admins",$admin_array);
$smarty->assign("servers",$server_array);
$smarty->assign("bans", isset($ban_array) ? $ban_array : NULL);
$smarty->assign("exbans", isset($exban_array) ? $exban_array : NULL);

if ( isset($_POST['nick']) )
{
	$smarty->assign("nick", $_POST['nick']);
}
else
{
	$smarty->assign("nick","");
}
if ( isset($_POST['steamid']) )
{
	$smarty->assign("steamid", $_POST['steamid']);
}
else
{
	$smarty->assign("steamid","");
}
if ( isset($_POST['ip']) )
{
	$smarty->assign("ip", $_POST['ip']);
}
else
{
	$smarty->assign("ip","");
}

if ( isset($_POST['reason']) )
{
	$smarty->assign("reason", $_POST['reason']);
}
else
{
	$smarty->assign("reason","");
}

if ( isset($_POST['date']) )
{
	$smarty->assign("date", $_POST['date']);
}
else
{
	$smarty->assign("date","");
}

if ( isset($_POST['timesbanned']) )
{
	$smarty->assign("timesbanned", $_POST['timesbanned']);
}
else
{
	$smarty->assign("date","");
}

if ( isset($_POST['admin']) )
{
	$smarty->assign("admin", $_POST['admin']);
}
else
{
	$smarty->assign("admin","");
}

if ( isset($_POST['server']) )
{
	$smarty->assign("server", $_POST['server']);
}
else
{
	$smarty->assign("server","");
}
$smarty->display('main_header.tpl');
$smarty->display('ban_search.tpl');
$smarty->display('main_footer.tpl');

?>
