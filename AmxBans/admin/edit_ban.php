<?php

/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2009, www.amxbans.de
 *
 *	web		: http://www.amxbans.de
 *	mail		: setoy@my-horizon.de
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

// Start session
@session_start();

// Require basic site files
require("../include/config.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

require("$config->path_root/include/functions.lang.php");
//require("$config->path_root/include/functions.inc.php");
include("$config->path_root/include/accesscontrol.inc.php");

if(($_SESSION['bans_delete'] != "yes" ) && ($_SESSION['bans_delete'] != "own" ) && ($_SESSION['bans_edit'] != "yes" ) && ($_SESSION['bans_delete'] != "own" ) && ($_SESSION['bans_unban'] != "yes" ) && ($_SESSION['bans_unban'] != "own" )){
	echo "You do not have the required credentials to view this page.";
	exit();
}

$ban_end = "";

if (isset($_POST['action'])) {

    $superban_name = "";
    $resource = mysql_query("SELECT `player_nick` FROM $config->bans WHERE bid = '".$_POST['bid']."'") or die(mysql_error());
    $result = mysql_fetch_object($resource);
    $superban_name = $result->player_nick;

	if ($_POST['action'] == "delete") {
		$now 	  = date("U");
        $resource = mysql_query("DELETE FROM `superban` WHERE banname = '$superban_name'") or die(mysql_error());
		$resource = mysql_query("DELETE FROM $config->bans WHERE bid = '".$_POST['bid']."'") or die(mysql_error());
		$add_log  = mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'delete ban', 'Ban with BanID ".$_POST['bid']." deleted')") or die (mysql_error());
		$url	  = "$config->document_root";
		$delay	  = "0";
		//echo "Deleted bid ".$_POST['bid'].". Redirecting...";
		echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url'\">";
		exit();
	} else if ($_POST['action'] == "unban") {

		// Get ban details
		if(isset($_POST['bid']) && is_numeric($_POST['bid'])) {
			$resource = mysql_query("SELECT * FROM $config->bans WHERE bid = '".mysql_escape_string($_POST["bid"])."'") or die(mysql_error());

			if(mysql_num_rows($resource) == 0) {
				trigger_error("Can't find ban with given ID.", E_USER_NOTICE);
			} else {
				$result = mysql_fetch_object($resource);

				// Get the AMX username of the admin if the ban was invoked from inside the server
				if($result->server_name <> "website") {
					$query2		= "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
					$resource2	= mysql_query($query2) or die(mysql_error());
					$result2	= mysql_fetch_object($resource2);
					$admin_amxname	= cp1251_to_utf8($result2 ? $result2->nickname : "");
				}

				// Prepare all the variables
				$player_name = cp1251_to_utf8($result->player_nick);
				$player_id = htmlentities($result->player_id, ENT_QUOTES);
                $player_ip = htmlentities($result->player_ip, ENT_QUOTES);

				/*if(!empty($result->player_ip)) {
					if(isset($_SESSION["user_authenticated"]) && $_SESSION["user_authenticated"] == "TRUE" && $_SESSION["user_level"] == "OWNER" || $_SESSION["user_level"] == "ADMIN") {
						$player_ip = htmlentities($result->player_ip, ENT_QUOTES);
					} else {
						$player_ip = "<i><font color='#677882'>".lang("_HIDDEN")."</font></i>";
					}
				} else {
					$player_ip = "<i><font color='#677882'>".lang("_NOTAPPLICABLE")."</font></i>";
				}*/

				$ban_start = dateShorttime($result->ban_created);

				if(empty($result->ban_length) OR $result->ban_length == 0) {
					$ban_duration = lang("_PERMANENT");
					$ban_end = "<i><font color='#677882'>".lang("_NOTAPPLICABLE")."</font></i>";
				} else {
					$ban_duration = $result->ban_length . "&nbsp;" . lang("_MINS");
					$date_and_ban = $result->ban_created + ($result->ban_length * 60);

					$now = date("U");
				if($now >= $date_and_ban) {
				$ban_end = dateShorttime($date_and_ban) .
                    "&nbsp;(".lang("_ALREADYEXP") . ")";
				} else {
				$ban_end = dateShorttime($date_and_ban) .
                    "&nbsp;(".timeleft($now,$date_and_ban) . lang("_REMAINING") .")";
				}
				}

				if($result->ban_type == "SI") {
					$ban_type = lang("_STEAMID&IP");
				} else {
					$ban_type = "SteamID";
				}

                $ban_reason = cp1251_to_utf8($result->ban_reason);
                //$ban_reason = cp1252_to_utf8($result->ban_reason);
                //$ban_reason = mb_convert_encoding($result->ban_reason, 'cp1252', 'cp1251');
                //$ban_reason = iconv('CP1251', 'UTF-8', $result->ban_reason);
                //$ban_reason = mb_convert_encoding($result->ban_reason, 'cp1252');
                //$ban_reason = mb_convert_encoding($ban_reason, 'cp1251', 'cp1252');
                //$ban_reason = iconv('CP1252', 'UTF-8', $ban_reason);

				if($result->server_name <> "website") {
					$query2 = "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
					$resource2 = mysql_query($query2) or die(mysql_error());
					$result2 = mysql_fetch_object($resource2);
					$admin_name = cp1251_to_utf8($result->admin_nick) . cp1251_to_utf8($result2 ? $result2->nickname : "");
					//$server_name = $result->server_name;
                    $server_name = cp1251_to_utf8($result->server_name);
				} else {
					$admin_name = cp1251_to_utf8($result->admin_nick);
					$server_name = "Website";
				}

				$ban_info = array(
					"player_name"	=> $player_name,
					"player_id"	=> $player_id,
					"player_ip"	=> $player_ip,
					"ban_start"	=> $ban_start,
					"ban_duration"	=> $ban_duration,
					"ban_end"	=> $ban_end,
					"ban_type"	=> $ban_type,
					"ban_reason"	=> $ban_reason,
					"admin_name"	=> $admin_name,
					"server_name"	=> $server_name
					);

				if(isset($_GET["bhid"])) {
					$unban_info = array(
						"verify"	=> TRUE,
						"unban_start"	=> dateShorttime($result->unban_created),
						"unban_reason"	=> cp1251_to_utf8($result->unban_reason),
						"admin_name"	=> cp1251_to_utf8($result->unban_admin_nick)
						);
				}
			}
		}
	} else if ($_POST['action'] == "edit") {

		// Get ban details
		if(isset($_POST['bid']) && is_numeric($_POST['bid'])) {
			$resource = mysql_query("SELECT * FROM $config->bans WHERE bid = '".mysql_escape_string($_POST["bid"])."'") or die(mysql_error());

			if(mysql_num_rows($resource) == 0) {
				trigger_error("Can't find ban with given ID.", E_USER_NOTICE);
			} else {
				$result = mysql_fetch_object($resource);

				// Get the AMX username of the admin if the ban was invoked from inside the server
				if($result->server_name <> "website") {
					$query2					= "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
					$resource2			= mysql_query($query2) or die(mysql_error());
					$result2				= mysql_fetch_object($resource2);
					$admin_amxname = ($result2) ? cp1251_to_utf8($result->nickname) : "";
				}

				// Prepare all the variables
				$player_name	= cp1251_to_utf8($result->player_nick);
				$player_id	= htmlentities($result->player_id, ENT_QUOTES);
				$playa_ip	= $result->player_ip;
				$ban_type	= $result->ban_type;

				$ban_start = dateShorttime($result->ban_created);

				if(empty($result->ban_length) OR $result->ban_length == 0) {
					$ban_duration = 0;
				} else {
					$ban_duration = $result->ban_length;
				}

                $ban_reason = cp1251_to_utf8($result->ban_reason);
				//$ban_reason = cp1252_to_utf8($result->ban_reason);
                //$ban_reason = iconv('CP1251', 'UTF-8', $result->ban_reason);
                //$ban_reason = mb_convert_encoding($result->ban_reason, 'cp1252');
                //$ban_reason = mb_convert_encoding($ban_reason, 'cp1251', 'cp1252');
                //$ban_reason = iconv('CP1252', 'UTF-8', $ban_reason);

				if($result->server_name <> "website") {
					$query2 = "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
					$resource2 = mysql_query($query2) or die(mysql_error());
					$result2 = mysql_fetch_object($resource2);
					$admin_name = htmlentities($result->admin_nick, ENT_QUOTES)." (".htmlentities(($result2) ? $result2->nickname : "", ENT_QUOTES).")";
					//$server_name = $result->server_name;
                    $server_name = cp1251_to_utf8($result->server_name);
				} else {
					$admin_name = cp1251_to_utf8($result->admin_nick);
					$server_name = "Website";
				}

				$ban_info = array(
					"player_name"	=> $player_name,
					"player_id"	=> $player_id,
					"player_ip"	=> $playa_ip,
					"ban_start"	=> $ban_start,
					"ban_duration"	=> $ban_duration,
					"ban_end"	=> $ban_end,
					"ban_type"	=> $ban_type,
					"ban_reason"	=> $ban_reason,
					"admin_name"	=> $admin_name,
					"server_name"	=> $server_name
					);
			}
		}
	} else if ($_POST['action'] == "apply") {
		$player_nick = $_POST['player_nick'];
		$ban_reason = $_POST['ban_reason'];
        $player_nick = utf8_to_cp1251($player_nick);
        $ban_reason = utf8_to_cp1251($ban_reason);

		if($_POST['player_ip'] == "") {
            $resource = mysql_query("UPDATE `$config->bans` SET `player_ip` = NULL, `player_id` = '".$_POST['player_id']."', `player_nick` = '$player_nick', `ban_type` = '".$_POST['ban_type']."', `ban_reason` = '$ban_reason', `ban_length` = '".min($_POST['ban_length'], 43800*3)."' WHERE `bid` = '".$_POST['bid']."'") or die (mysql_error());
            $superban = mysql_query("UPDATE `superban` SET `sid` = '".$_POST['player_id']."', `banname` = '$player_nick', `reason` = '$ban_reason', `unbantime` = `bantime` + 60*'".min($_POST['ban_length'], 43800*3)."' WHERE `banname` = '$superban_name'") or die (mysql_error());
		} else {
			$resource = mysql_query("UPDATE `$config->bans` SET `player_ip` = '".$_POST['player_ip']."', `player_id` = '".$_POST['player_id']."', `player_nick` = '$player_nick', `ban_type` = '".$_POST['ban_type']."', `ban_reason` = '$ban_reason', `ban_length` = '".min($_POST['ban_length'], 43800*3)."' WHERE `bid` = '".$_POST['bid']."'") or die (mysql_error());
            $superban = mysql_query("UPDATE `superban` SET `ip` = '".$_POST['player_ip']."', `ipcookie` = '".$_POST['player_ip']."', `sid` = '".$_POST['player_id']."', `banname` = '$player_nick', `reason` = '$ban_reason', `unbantime` = `bantime` + 60*'".min($_POST['ban_length'], 43800*3)."' WHERE `banname` = '$superban_name'") or die (mysql_error());
		}

		$now = date("U");
		$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'edit ban', 'Ban with BanID ".$_POST['bid']." (".$_POST['player_id'].")(".$_POST['player_ip'].") edited')") or die (mysql_error());

		$url			= "$config->document_root";
		$delay		= "0";
		//echo "Edited bid ".$_POST['bid'].". Redirecting...";
		echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url'\">";
		exit();
	} else if ($_POST['action'] == "unban_perm") {

		$list_ban	= mysql_query("SELECT * FROM $config->bans WHERE bid = '".$_POST['bid']."'") or die (mysql_error());

		while ($myban = mysql_fetch_array($list_ban)) {
			$unban_created = date("U");
			$player_nick = cp1251_to_utf8($myban['player_nick']);
			$ban_reason = cp1251_to_utf8($myban['ban_reason']);

			$insert_ban = mysql_query("INSERT INTO $config->ban_history (player_ip, player_id, player_nick, map_name, admin_ip, admin_id, admin_nick, ban_type, ban_reason, ban_created, ban_length, server_ip, server_name, unban_created, unban_reason, unban_admin_nick) VALUES ('$myban[player_ip]', '$myban[player_id]', '$player_nick', '$myban[map_name]', '$myban[admin_ip]', '$myban[admin_id]', '$myban[admin_nick]', '$myban[ban_type]', '$ban_reason', '$myban[ban_created]', '$myban[ban_length]', '$myban[server_ip]', '$myban[server_name]', '$unban_created', '".$_POST['unban_reason']."', '".$_SESSION['uid']."')") or die (mysql_error());
			$remove_ban = mysql_query("DELETE FROM $config->bans WHERE bid = '".$_POST['bid']."'") or die (mysql_error());
            $remove_superban = mysql_query("DELETE FROM `superban` WHERE banname = '$player_nick'") or die (mysql_error());

			$now = date("U");
			$add_log	= mysql_query("INSERT INTO $config->logs (timestamp, ip, username, action, remarks) VALUES ('$now', '".$_SERVER['REMOTE_ADDR']."', '".$_SESSION['uid']."', 'unban ban', 'Ban with BanID ".$_POST['bid']." unbanned (SteamID $myban[player_id])')") or die (mysql_error());
		}

		$url	= "$config->document_root";
		$delay	= "0";
		//echo "unbanned bid ".$_POST['bid'].". Redirecting...";
		echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url'\">";
		exit();
	}
}


/*
 *
 *		Template parsing
 *
 */

$title = "Edit bandetails";

// Section
$section = "config";

$smarty = new dynamicPage;
$smarty->assign("section",$section);
$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("dir",$config->document_root);
$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("action", $_POST['action']);
$smarty->assign("bid",$_POST['bid']);
$smarty->assign("ban_info",$ban_info);

$smarty->display('main_header.tpl');
$smarty->display('edit_ban.tpl');
$smarty->display('main_footer.tpl');
?>
