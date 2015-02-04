<?php

/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2009, www.amxbans.de
 *
 *	web		: http://www.amxbans.de
 *	mail	: setoy@my-horizon.de
 *	ICQ		: 226696015
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

if ( !file_exists("include/config.inc.php") )
{
	header("Location: http://" . $_SERVER['HTTP_HOST']
                     . rtrim(dirname($_SERVER['PHP_SELF']), '/\\')
                     . "/" . "admin/setup.php");
}

// Start session
@session_start();

$previous_button = NULL;
$next_button = NULL;

// Require basic site files
require("include/config.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

if ($config->geoip == "enabled") {
	include("$config->path_root/include/geoip.inc");
}

require("$config->path_root/include/functions.lang.php");
require("$config->path_root/include/functions.inc.php");
require("$config->path_root/include/steam.inc.php");

// First we get the total number of bans in the date base.
$resource	= mysql_query("SELECT COUNT(bid) AS all_bans FROM $config->bans") or die(mysql_error());
$result		= mysql_fetch_object($resource);

// Get the page number, if no number is defined make default 1
if(isset($_GET["page"]) AND is_numeric($_GET["page"])) {
	$page = mysql_real_escape_string($_GET["page"]);
	
	if($page < 1) {
		trigger_error("Pagenumbers need to be >= 1.", E_USER_NOTICE);
		exit;
	}
} else {
	$page = 1;
}

// Get the view number, if no number is defined set to default
if(isset($_GET["view"]) AND is_numeric($_GET["view"])) {
	$view = mysql_real_escape_string($_GET["view"]);
} else {
	$view = $config->bans_per_page;
}

// create pages
if($result->all_bans <= $view) {
	$query_start = 0;
	$query_end = $view;
	
	$page_start = $result->all_bans ? 1:0;
	$page_end = $result->all_bans;
	
	$pages_results = array(
		"page_start" => $page_start,
		"page_end" => $page_end,
		"all_bans" => $result->all_bans,
		"prev_button" => "",
		"next_button" => "");
} else {
	if($page == 1) {
		$query_start = 0;
		$query_end = $view;
	
		$page_start = 1;
		$page_end = $view;
		
		$previous_page = NULL;
		$next_page = $page + 1;
	} else {
		$remaining = $result->all_bans % $view;
		$pages = ($result->all_bans - $remaining) / $view;
		
		$query_start = $view * ($page - 1);
		$query_end = $view;
		
		if($page > $pages + 1) {
			trigger_error("Page number doesn't exists.", E_USER_NOTICE);
			exit;
		} elseif($page == $pages + 1) {
			$page_start = ($view * ($page - 1)) + 1;
			$page_end = $page_start + $remaining - 1;
		
			$previous_page = $page - 1;
		} else {
			$page_start = ($view * ($page - 1)) + 1;
			$page_end = $page_start + ($view - 1);
			
			$previous_page = $page - 1;
			$next_page = $page + 1;
		}
	}
	$pages_results = array(
		"page_start" => $page_start,
		"page_end" => $page_end,
		"all_bans" => $result->all_bans,
		"view" => $view,
		"prev_page" => ($previous_page <> NULL) ? $previous_page : "",
		"next_page" => ($next_page <> NULL) ? $next_page : "");
}

//get the bans for the page list
$resource	= mysql_query("SELECT bid, player_id, player_ip, player_nick, admin_nick, ban_reason, ban_created, ban_length, server_ip, server_name, map_name, se.gametype, aa.nickname FROM $config->bans AS ba LEFT JOIN $config->servers AS se ON ba.server_ip=se.address LEFT JOIN $config->amxadmins AS aa ON aa.username=ba.admin_nick or aa.username=ba.admin_ip or aa.username=ba.admin_id ORDER BY ban_created DESC LIMIT ".$query_start.",".$query_end) or die(mysql_error());

$ban_array	= array();
$timezone_correction = $config->timezone_fixx * 3600;

while($result = mysql_fetch_object($resource)) {
	$bid		= $result->bid;
	//$date		= dateShort($result->ban_created + $timezone_correction);
    $date		= dateShorttime($result->ban_created + $timezone_correction);
	$player 	= htmlentities($result->player_nick, ENT_QUOTES);
    $map        = htmlentities($result->map_name, ENT_QUOTES);

	$admin = htmlentities($result->admin_nick, ENT_QUOTES);
	$duration 	= $result->ban_length;
	$serverip	= $result->server_ip;
	$player_ip 	= $result->player_ip;

	if($config->display_demo == "enabled") {
		$sql_demo = mysql_query("SELECT * FROM $config->amxdemos WHERE  bid = '" . $bid . "'");
		$count_demo = mysql_num_rows($sql_demo);
		$show_demo = $count_demo > 0 ? $bid : NULL;
	}
	
	//$server_name = $result->server_name;
	$server_name = htmlentities($result->server_name, ENT_QUOTES, 'utf-8');
    $server_name = mb_convert_encoding($server_name, 'cp1251', 'utf-8');
	
	if ($config->fancy_layers == "enabled") {
		if($config->display_comments == "enabled") {
			$sql_comm = mysql_query("SELECT * FROM $config->amxcomments WHERE  bid = '" . $bid . "'");
			$count_cmts = mysql_num_rows($sql_comm);
			$show_comm = $count_cmts > 0 ? $bid : NULL;
		}
		#if($count_cmts > '0'){
		#	$show_comm="<a href=".$config->document_root."/ban_details.php?bid=$bid>" . lang("_READ") . "</a> ($count_cmts)";
		#}else if($count_cmts == '0'){
		#	$show_comm="" . lang("_NOCOMMENTS") . " (<a href=".$config->document_root."/ban_details.php?bid=$bid>" . lang("_ADDCOMMENT") . "</a>)";
		#}
		if(!empty($result->player_ip)) {
			$player_ip = htmlentities($result->player_ip, ENT_QUOTES);
		} else {
			$player_ip = "<i><font color='#677882'>" . lang("_NOIP") . "</font></i>";
		}
		
		if(!empty($result->player_id)) {
			$steamid = htmlentities($result->player_id, ENT_QUOTES);
			$steamcomid = GetFriendId($steamid);
		} else {
			$steamid = NULL;
			$steamcomid = NULL;
		}

		$ldate		= dateShorttime($result->ban_created + $timezone_correction);
		$banlength	= $result->ban_length;
	
		if(empty($result->ban_length) OR $result->ban_length == 0) {
			$ban_duration = lang("_PERMANENT");
			$ban_end = "<i><font color='#677882'>" . lang("_NOTAPPLICABLE") . "</font></i>";
		} else {
			$ban_duration = $result->ban_length . "&nbsp; ". lang("_MINS") . "&nbsp;";
			$date_and_ban = $result->ban_created + $timezone_correction + ($result->ban_length * 60);

			$now = date("U");
			if($now >= $date_and_ban) {
				$ban_end = dateShorttime($date_and_ban)."&nbsp; (".lang("_ALREADYEXP").")";
			} else {
				$ban_end = dateShorttime($date_and_ban)."&nbsp; (".timeleft($now,$date_and_ban) ."&nbsp;". lang("_REMAINING") .")";
			}
		}
		
		if(@$result->ban_type == "SI") {
			$ban_type = lang("_STEAMID&IP");
		} else {
			$ban_type = "SteamID";
		}
		
		// // if($result->server_name <> "website") {
			// // //$query2 = "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";	
			// // $query2 = "SELECT nickname FROM $config->amxadmins WHERE username = '".$result->admin_id."' OR username = '".$result->admin_ip."' OR username = '".$result->admin_nick."'";	
			// // $resource2 = mysql_query($query2) or die(mysql_error());	
			// // $result2 = mysql_fetch_object($resource2);

			
			// // $admin_name = htmlentities($result->admin_nick, ENT_QUOTES);
			// // if ( $result2 )
		if($result->server_name != "website") {
			if (empty($result->nickname))
			{
				// // $web_admin_name = htmlentities($result2->nickname, ENT_QUOTES);
				$admin_name = htmlentities($result->admin_nick, ENT_QUOTES);
				$web_admin_name = "";
			}
			else
			{
				// // $web_admin_name = "";
				$web_admin_name = htmlentities($result->nickname, ENT_QUOTES);
				$admin_name = htmlentities($result->nickname, ENT_QUOTES);
			}
			// // $server_name = $result->server_name;
		} else {
			$admin_name = htmlentities($result->admin_nick, ENT_QUOTES);
			$web_admin_name = $admin_name;
			$server_name = lang("_WEBSITE");
		}
	}

	$ban_reason = htmlentities($result->ban_reason, ENT_QUOTES, 'utf-8');
    $ban_reason = mb_convert_encoding($ban_reason, 'cp1251', 'utf-8');

	if ($serverip != "") {
		$gametype = $result->gametype;
	} else {
		$gametype = "html";
	}

	// We dont need to count the bans if fancy layers arent enabled (Lantz69 060906)
	if ($config->fancy_layers == "enabled") {	
		// get previous offences if any
		//$resource4   = mysql_query("SELECT count(player_id) FROM $config->ban_history WHERE player_id = '$steamid'") or die(mysql_error());
		//$bancount = mysql_result($resource4, 0);
		
		// get previous offences if any 
		if (empty($steamid)) {
			$bancount = 'unknown';
		}
		else {
			$resource4   = mysql_query("SELECT count(player_id) AS repeatOffence FROM $config->ban_history WHERE player_id = '$steamid'") or die(mysql_error()); 
			while($result4 = mysql_fetch_object($resource4)) { 
				$bancount = $result4->repeatOffence; 
			}
		}
	}

	if(empty($duration)) {
		$duration = lang("_PERMANENT");
	}	else {
		if ($duration >= 1440) {
			$duration = round($duration / 1440);
			if ($duration == 1)
				$duration = "$duration " . lang("_DAY");
			else
				$duration = "$duration " . lang("_DAYS");
		} else {
			$duration = "$duration " . lang("_MINS");
		}
	}

	if ($config->geoip == "enabled") {
		$gi = geoip_open("$config->path_root/include/GeoIP.dat",GEOIP_STANDARD);
		$cc = geoip_country_code_by_addr($gi, $player_ip);
		$cn = geoip_country_name_by_addr($gi, $player_ip);
		geoip_close($gi);
	} else {
		$cc = "";
		$cn = "";
	}

	// Asign variables to the array used in the template
	if ($config->fancy_layers == "enabled") {
		$ban_info = array(
		"gametype"	=> $gametype,
		"bid"		=> $bid,
        "map"       => $map,
		"date"		=> $date,
		"player"	=> $player,
		"cc"		=> $cc,
		"cn"		=> $cn,
		"admin"		=> $admin_name,
		"webadmin"	=> $web_admin_name,
		"duration"	=> $duration,
		"player_id"	=> $steamid,
		"player_comid" => $steamcomid,
		"player_ip"	=> $player_ip,
		"ban_start"	=> $ldate,
		"ban_duration"	=> $ban_duration,
		"ban_end"	=> $ban_end,
		"ban_type"	=> $ban_type,
		"ban_reason"	=> $ban_reason,
		"server_name"	=> $server_name,
		"bancount"	=> $bancount,
		"demo"		=> ($config->display_demo == "enabled") ?$show_demo:NULL,
		"comments"	=> ($config->display_comments == "enabled") ? $show_comm:NULL,
		"commentscount"=> ($config->display_comments == "enabled") ?$count_cmts:NULL
		);
	} else {
		if ($config->display_reason == "enabled") {
			$ban_info = array(
				"gametype"	=> $gametype,
				"bid"		=> $bid,
				"date"		=> $date,
				"player"	=> $player,
				"cc"		=> $cc,
				"cn"		=> $cn,
				"admin"		=> $admin,
				"duration"	=> $duration,
				"ban_reason"	=> $ban_reason,
				"demo"		=> ($config->display_demo == "enabled") ? $show_demo:NULL,
				"comments"	=> ($config->display_comments == "enabled") ? $show_comm:NULL,
				"commentscount"=> ($config->display_comments == "enabled") ? $count_cmts:NULL
			);
		} else {
			$ban_info = array(
				"gametype"	=> $gametype,
				"bid"		=> $bid,
				"date"		=> $date,
				"player"	=> $player,
				"cc"		=> $cc,
				"cn"		=> $cn,
				"admin"	=> $admin,
				"duration"	=> $duration,
				"demo"		=> ($config->display_demo == "enabled") ? $show_demo:NULL,
				"comments"	=> ($config->display_comments == "enabled") ? $show_comm:NULL,
				"commentscount"=> ($config->display_comments == "enabled") ? $count_cmts:NULL
			);
		}
	}
	
	$ban_array[] = $ban_info;
}

if ($config->version_checking == "enabled") {
	$new_version_exists = CheckAMXWebVersion();
} else {
	$new_version_exists = 0;
}

//Get Count from all comments
$sql_comm = mysql_query("SELECT * FROM $config->amxcomments");
$count_comm = mysql_num_rows($sql_comm);

//Get Count from all demos
$sql_demo = mysql_query("SELECT * FROM $config->amxdemos");
$count_demo = mysql_num_rows($sql_demo);

/*
 * Template parsing
 */


$title			= lang("_BANLIST");

// Section
$section = "banlist";

$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("section",$section);
$smarty->assign("dir",$config->document_root);
$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("fancy_layers", $config->fancy_layers);
$smarty->assign("display_search", $config->display_search);
$smarty->assign("display_admin", $config->display_admin);
$smarty->assign("display_reason", $config->display_reason);
$smarty->assign("display_demo", $config->display_demo);
$smarty->assign("display_comments", $config->display_comments);
$smarty->assign("geoip", $config->geoip);
$smarty->assign("bans",$ban_array);
$smarty->assign("count_comm",$count_comm);
$smarty->assign("count_demo",$count_demo);
$smarty->assign("pages_results",$pages_results);
#$smarty->assign("previous_button",$previous_button);
#$smarty->assign("next_button",$next_button);
$smarty->assign("new_version",$new_version_exists);
$smarty->assign("update_url",$config->update_url);

$smarty->display('main_header.tpl');
$smarty->display('ban_list.tpl');
$smarty->display('main_footer.tpl');

?>