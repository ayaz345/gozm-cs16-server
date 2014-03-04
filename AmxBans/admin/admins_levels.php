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
session_start();

// Require basic site files

require("../include/config.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

$action = "";

include("$config->path_root/include/accesscontrol.inc.php");
include("$config->path_root/include/functions.lang.php");

if(($_SESSION['amxadmins_edit'] != "yes") && ($_SESSION['webadmins_edit'] != "yes") && ($_SESSION['permissions_edit'] != "yes")) {
	echo lang("_NOACCESS");
	exit();
}

if (!isset($_POST['sektion'])) {
	$sektion = "xxx";
} else {
	$sektion = $_POST['sektion'];
}

if (isset($_POST['action'])) {
	$action = $_POST['action'];
}


if (($sektion == "levels") && ($_SESSION['permissions_edit'] == "yes")) {

	if ($action == lang("_ADD")) {
		$resource = mysql_query("INSERT INTO $config->levels VALUES('".$_POST['new_lvl']."', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no', 'no')") or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'lvl management', 'Added new level')") or die (mysql_error());

	} else if ($action == lang("_REMOVE")) {

		// check if there are admins using this level before removing it...
		$resource = mysql_query("SELECT COUNT(level) AS get_lvls FROM $config->webadmins WHERE level = '".$_POST['ex_lvl']."'") or die (mysql_error());
		$lvls	  = mysql_fetch_object($resource);

		if ($lvls->get_lvls == 0) {
			$resource2 = mysql_query("DELETE FROM $config->levels WHERE level = '".$_POST['ex_lvl']."'") or die (mysql_error());

			$now = date("U");
			$add_log   = mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'lvl management', 'Removed level ".$_POST['ex_lvl']."')") or die (mysql_error());

		} else {
			echo "Some admins are using this level. Make sure no admin(s) are using this level before trying to remove it.";

			$now = date("U");
			$add_log   = mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'lvl management', 'Attempted to remove level ".$_POST['ex_lvl']." (level still used)')") or die (mysql_error());
		}
	} else if ($action == lang("_APPLY")) {

		foreach($_POST as $key => $value) {
			$choppedkey = explode("-", $key);

			if (is_numeric($choppedkey[0])) {
				if(($value == "on") || ($value == "yes")) {
					$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'yes' WHERE level = '$choppedkey[0]'") or die (mysql_error());
				} else if($value == "own") {
					$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'own' WHERE level = '$choppedkey[0]'") or die (mysql_error());
				} else if($value == "no") {
					$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'no' WHERE level = '$choppedkey[0]'") or die (mysql_error());
				}
			}

/*
			if (is_numeric($choppedkey[0])) {

				//check this level/ability is set to yes...
				$resource2 = mysql_query("SELECT COUNT(level) AS get_lvls FROM $config->levels WHERE level = '$choppedkey[0]' AND `$choppedkey[1]` = 'yes'") or die (mysql_error());
				$result2 = mysql_fetch_object($resource2);

				if ($result2->get_lvls == 0) {
					if($value == "on") {
						$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'yes' WHERE level = '$choppedkey[0]'") or die (mysql_error());
					} else if($value == "own") {
						$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'own' WHERE level = '$choppedkey[0]'") or die (mysql_error());
					}
				}	else if ($result2->get_lvls == 1) {
					if($value == "no") {
						$resource3 = mysql_query("UPDATE $config->levels SET `$choppedkey[1]` = 'no' WHERE level = '$choppedkey[0]'") or die (mysql_error());
					}
				} else {
					echo "Duplicate entry found?";
				}
			} */
		}

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'lvl management', 'Updated one or more levels')") or die (mysql_error());
	}

	//get all levels
	$resource = mysql_query("SELECT level, bans_add, bans_edit, bans_delete, bans_unban, bans_import, bans_export, amxadmins_edit, webadmins_edit, permissions_edit, prune_db, servers_edit, ip_view FROM $config->levels ORDER BY level ASC") or die (mysql_error());

	$level_array = array();
	while($result = mysql_fetch_object($resource)) {

		// Asign variables to the array used in the template
		$level_info = array(
			"level"			=> $result->level,
			"bans_add"		=> $result->bans_add,
			"bans_edit"		=> $result->bans_edit,
			"bans_delete"		=> $result->bans_delete,
			"bans_unban"		=> $result->bans_unban,
			"bans_import"		=> $result->bans_import,
			"bans_export"		=> $result->bans_export,
			"amxadmins_edit"	=> $result->amxadmins_edit,
			"webadmins_edit"	=> $result->webadmins_edit,
			"permissions_edit"	=> $result->permissions_edit,
			"prune_db"		=> $result->prune_db,
			"servers_edit"		=> $result->servers_edit,
			"ip_view"		=> $result->ip_view
			);
	
		$level_array[] = $level_info;
	}

	$get_levels = mysql_query("SELECT DISTINCT level FROM $config->levels") or die (mysql_error());

	while($result2 = mysql_fetch_object($get_levels)) {
		$existing_levels[] = $result2->level;
	}

	for($i=1;$i<100;$i++) {
		if(in_array($i,$existing_levels)) {
			next($existing_levels);
		} else {
			$available_levels[] = $i;
		}
	}
} else if (($sektion == "webadmins") && ($_SESSION['webadmins_edit'] == "yes")) {

	if ($action == lang("_REMOVE")) {
		$resource2 = mysql_query("DELETE FROM $config->webadmins WHERE id = '".$_POST['id']."'") or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'webadmins management', 'Removed admin ".$_POST['username']."')") or die (mysql_error());

	} else if ($action == lang("_APPLY")) {
		if ($_POST['password'] == "") {
			$resource = mysql_query("UPDATE $config->webadmins SET username = '".$_POST['username']."', level = '".$_POST['level']."' WHERE id = '".$_POST['id']."'") or die (mysql_error());
		} else {
			$password = md5($_POST['password']);			
			$resource = mysql_query("UPDATE $config->webadmins SET username = '".$_POST['username']."', password = '$password', level = '".$_POST['level']."' WHERE id = '".$_POST['id']."'") or die (mysql_error());
		}

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'webadmins management', 'Edited admin ".$_POST['username']."')") or die (mysql_error());

	} else if ($action == lang("_INSERT")) {
		//display_post_get();
		$username	= htmlentities($_POST['username'], ENT_QUOTES); 
		$password = md5($_POST['password']);
		$resource	= mysql_query("INSERT INTO $config->webadmins (username, password, level) VALUES('$username', '$password', '".$_POST['level']."')") or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'webadmins management', 'Added admin $username')") or die (mysql_error());
	}


	//get all webadmins
	$resource = mysql_query("SELECT id, username, level FROM $config->webadmins ORDER BY username ASC") or die (mysql_error());

	$webadmins_array = array();
	while($result = mysql_fetch_object($resource)) {

		$get_lvls = mysql_query("SELECT level FROM $config->levels") or die (mysql_error());

		unset($existing_levels);
		$existing_levels = array();
		while($result2 = mysql_fetch_object($get_lvls)) {
			$existing_levels[] = $result2->level;
		}

		// Asign variables to the array used in the template
		$webadmins_info = array(
			"id"		=> $result->id,
			"username"	=> $result->username,
			"level"		=> $result->level,
			"existing_lvls"	=> $existing_levels
			);
	
		$webadmins_array[] = $webadmins_info;
	}
} else if (($sektion == "amxadmins") && ($_SESSION['amxadmins_edit'] == "yes")) {

	if ($action == lang("_REMOVE")) {
		$resource2 = mysql_query("DELETE FROM $config->amxadmins WHERE id = '".$_POST['id']."'") or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'amxadmins management', 'Removed admin ".$_POST['username']."')") or die (mysql_error());

	} else if ($action == lang("_APPLY")) {
		$username	= htmlentities($_POST['username'], ENT_QUOTES); 
		$password	= htmlentities($_POST['password'], ENT_QUOTES);
		$nickname	= htmlentities($_POST['nickname'], ENT_QUOTES);
		$resource2	= mysql_query("UPDATE $config->amxadmins SET username = '$username', password = '$password', access = '".$_POST['access']."', flags = '".$_POST['flags']."', steamid = '".$_POST['steamid']."', nickname = '$nickname',ashow = '".$_POST['ashow']."' WHERE id = '".$_POST['id']."'") or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'amxadmins management', 'Edited admin $username')") or die (mysql_error());

	} else if ($action == lang("_INSERT")) {
		$username	= htmlentities($_POST['username'], ENT_QUOTES); 
		$password	= htmlentities($_POST['password'], ENT_QUOTES);
		$nickname	= htmlentities($_POST['nickname'], ENT_QUOTES);
		$resource2	= mysql_query("INSERT INTO $config->amxadmins (username, password, access, flags, steamid, nickname, ashow ) VALUES('$username', '$password', '".$_POST['access']."', '".$_POST['flags']."', '".$_POST['steamid']."', '$nickname', '".$_POST['ashow']."')")  or die (mysql_error());

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'amxadmins management', 'Added admin $username')") or die (mysql_error());
	}

	//get all amxadmins
	$resource = mysql_query("SELECT id, username, password, access, flags, steamid, nickname, ashow FROM $config->amxadmins ORDER BY access ASC, id ASC") or die (mysql_error());

	$amxadmins_array = array();
	while($result = mysql_fetch_object($resource)) {

		// Asign variables to the array used in the template
		$amxadmins_info = array(
			"id"		=> $result->id,
			"username"	=> $result->username,
			"password"	=> $result->password,
			"access"	=> $result->access,
			"flags"		=> $result->flags,
			"steamid"	=> $result->steamid,
			"nickname"	=> $result->nickname,
			"ashow"		=> $result->ashow
			);
	
		$amxadmins_array[] = $amxadmins_info;
	}
//	$file = 'test.txt';
//	$current = file_get_contents($file);
//	$current .= $amxadmins_array;
//	file_put_contents($file, $current);
}

//echo "<pre>";
//print_r($webadmins_array);
//echo "</pre>";

/*
 *
 * Template parsing
 *
 */

$title	= lang("_SERVERADMINS");
$section = "admins_levels";
$smarty	= new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("section",$section);
$smarty->assign("dir",$config->document_root);
$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("sektion",$sektion);
$smarty->assign("action", isset($action) ? $action : "");
$smarty->assign("level", isset($level_array) ? $level_array : "");
$smarty->assign("existing_levels",isset($existing_levels) ? $existing_levels : "");
$smarty->assign("available_levels",isset($available_levels) ? $available_levels : "");
$smarty->assign("webadmin",isset($webadmins_array) ? $webadmins_array : "");
$smarty->assign("amxadmin",isset($amxadmins_array) ? $amxadmins_array : "");

$smarty->display('main_header.tpl');
$smarty->display('admins_levels.tpl');
$smarty->display('main_footer.tpl');

?>