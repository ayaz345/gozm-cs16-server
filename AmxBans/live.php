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

//fast security fix
if (isset($_GET["sid"]) && $_GET["sid"] != "") $_GET["sid"]=(int)$_GET["sid"];
$where=array();
$servers_list=array();
$servers_array=array();
$player=array();

// Require basic site files
require("include/config.inc.php");
require("$config->path_root/include/functions.inc.php");
if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

if ($config->geoip == "enabled") {
	include("$config->path_root/include/geoip.inc");
}

if (strstr($_SERVER['HTTP_USER_AGENT'], 'MSIE')) {
	$browser = "IE";
} else {
	$browser = "MO";
}

	include("$config->path_root/include/rcon_hl_net.inc");

//make an array for the servers...
	// black server list
	$where[] = "address != 'localhost:27000'";


$resource = mysql_query("SELECT * FROM $config->servers WHERE ".implode(" AND ",$where)." ORDER BY hostname ASC") or die (mysql_error());
while($result = mysql_fetch_object($resource)) {

$servers_list[] = $result->id;
$key = array_keys($servers_list);
$count = count($key);

	for ($i=0; $i<$count; $i++) {
		$servers_info = array(
			"id"		=> $key[$i],
			"hostname"		=> $result->hostname
		);
	}
		$servers_array[] = $servers_info;
}

if ($_GET['sid'] != "" && is_numeric($_GET['sid'])){
$sid = $_GET['sid'];
}else{
$sid = "0";
}
$server_id = $servers_list[$sid];

	//fetch server_information
	$resource2	= mysql_query("SELECT * FROM $config->servers WHERE id = '".$server_id."'") or die (mysql_error());
	$result2		= mysql_fetch_object($resource2);
	if(mysql_num_rows($resource2)) {
		$split_address = explode (":", $result2->address);
		$eye_pee	= $split_address['0'];
		$poort		= $split_address['1'];

		$server = new Rcon();
		$server->Connect($eye_pee, $poort, $result2->rcon);

		$infos = $server->Info(); 
		$info = $server->ServerInfo(); 

		//Action
		$response = $server->RconCommand("amx_timeleft");
		$response1 = $server->RconCommand("mp_timelimit");
		$response2 = $server->RconCommand("sv_visiblemaxplayers");
		
		//get addons version
		$response_amxmodx = $server->RconCommand("amxmodx_version");
		$response_amxbans = $server->RconCommand("amxbans_version");
		$response_ptb = $server->RconCommand("amx_ptb_version");
		$response_atac = $server->RconCommand("atac_version");
		$response_hlr = $server->RconCommand("hltv_report");
		$response_sank = $server->RconCommand("sanksounds_version");
		$response_steambans = $server->RconCommand("sbsrv_version");
		$response_metamod = $server->RconCommand("metamod_version");
		
		$add_amxx = explode ("\"", $response_amxmodx);
		$add_amxbans = explode ("\"", $response_amxbans);
		$add_ptb = explode ("\"", $response_ptb);
		$add_atac = explode ("\"", $response_atac);
		$add_hlr = explode ("\"", $response_hlr);
		$add_sank = explode ("\"", $response_sank);
		$add_steambans = explode ("\"", $response_steambans);
		$add_metamod = explode ("\"", $response_metamod);
		
		//close connection
		$server->Disconnect();

		$game = explode (" ", $info[mod]);
		
		//create addons array
		$addons_array = array(
				"amxx"		=> $add_amxx[3],
				"amxbans"	=> $add_amxbans[3],
				"ptb"		=> $add_ptb[3],
				"atac"		=> $add_atac[3],
				"hlr"		=> $add_hlr[3],
				"sank"		=> $add_sank[3],
				"steambans"	=> $add_steambans[3],
				"vac"		=> $game[3]=="secure" ? "VAC2":"",
				"metamod"	=> $add_metamod[3]
				);
				
		
		$timeleft = explode ("\"", $response);
		$timelimit = explode ("\"", $response1);
		$maxplayers = explode ("\"", $response2);
		
		//check if mappic exists
		if(file_exists("stats/images/maps/".$info[map].".jpg")) {
			$mappic = $info[map];
		} else {
			$mappic = "noimage";
		}
		
		$server_info = array( 
         		"hostname"      => $info[name], 
         		"address"      => $info[ip], 
         		"map"         => $info[map],
				"mappic"         => $mappic,
         		"game"         => $game[0], 
         		"cur_players"      => $info[activeplayers], 
         		"max_players"      => $maxplayers[3], 
         		"timeleft"      => $timeleft[3], 
         		"timelimit"      => $timelimit[3]
         		);
	
		$server_array[] = $server_info;

$player_array	= array();
$int = $info[activeplayers]+1;

for ($i=1; $i<$int; $i++) {
$player = $info[$i];
$player[name] = htmlspecialchars($player[name]);

		$split_adress = explode (":", $player[adress]);

		if ($config->geoip == "enabled") {
			$gi = geoip_open("$config->path_root/include/GeoIP.dat",GEOIP_STANDARD);
			$cc = geoip_country_code_by_addr($gi, $split_adress['0']);
			$cn = geoip_country_name_by_addr($gi, $split_adress['0']);
			geoip_close($gi);
		} else {
			$cc = "";
			$cn = "";
		}

		$player_info = array(
			"name"		=> $player[name],
			"frag"		=> $player[frag],
			"time"		=> $player[time],
			"ping"		=> $player[ping],
			"cc"		=> $cc,
			"cn"		=> $cn
			);
	
		$player_array[] = $player_info;
	}
}

/*
 *
 * 		Template parsing
 *
 */

// Header
$title = "Live Server Status";

// Section
$section = "live";

// Parsing
$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("section",$section);
$smarty->assign("dir",$config->document_root);
$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("browser",$browser);


$smarty->assign("live_player_ban", get_post('live_player_ban'));
$smarty->assign("geoip", $config->geoip);

$smarty->assign("s",$sid);

$smarty->assign("servers",$servers_array);
$smarty->assign("server",$server_array);
$smarty->assign("addons",$addons_array);
$smarty->assign("players", isset($player_array) ? $player_array : NULL);
$smarty->assign("empty_result",isset($empty_result) ? $empty_result : NULL);
$smarty->assign("post",$_POST);

$smarty->display('main_header.tpl');
      echo "<script type=\"text/javascript\">
	<!--
		function jumpMenu(selection, target)
		{
			var url = selection.options[selection.selectedIndex].value;
			
			if (url == \"\")
			{
				return false;
			}
			else
			{
				window.location = url;
			}
		}
	// -->
	</script>";
$smarty->display('live.tpl');
$smarty->display('main_footer.tpl');

?>