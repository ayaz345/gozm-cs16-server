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

//fast security fix
if (isset($_GET["bid"]) && $_GET["bid"] != "") $_GET["bid"]=(int)$_GET["bid"];
if (isset($_GET["bhid"]) && $_GET["bhid"] != "") $_GET["bhid"]=(int)$_GET["bhid"];

///Captcha-System
$rand = mt_rand(1000000,9999999);
$rand = base64_encode($rand);
$rand = substr($rand, 0, 7)."";
$rand = str_replace("J", "Z", $rand);
$rand = str_replace("I", "Y", $rand);
$rand = str_replace("j", "z", $rand);
$rand = str_replace("i", "y", $rand);

if(!isset($_POST[action]) && $_POST[action] != "insert"){
	unset($_SESSION['code']);
	$_SESSION['code'] = "$rand";
}

// Require basic site files
require("include/config.inc.php");
require("include/bbcode.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}
require("$config->path_root/include/functions.lang.php");
require("$config->path_root/include/functions.inc.php");


// Get ban details
if(isset($_GET["bhid"]) AND is_numeric($_GET["bhid"])) {

	$query = "SELECT * FROM $config->ban_history WHERE bhid = '".mysql_escape_string($_GET["bhid"])."'";


	$resource = mysql_query($query) or die(mysql_error());
	$numrows = mysql_num_rows($resource);

	if(mysql_num_rows($resource) == 0) {
		trigger_error("Can't find ban with given ID.", E_USER_NOTICE);
	} else {
		$result = mysql_fetch_object($resource);

		// Get the AMX username of the admin if the ban was invoked from inside the server
		if($result->server_name <> "website") {
			//$query2 = "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
			$query2 = "SELECT nickname FROM $config->amxadmins WHERE username = '".$result->admin_id."' OR username = '".$result->admin_ip."' OR username = '".$result->admin_nick."'";
			$resource2 = mysql_query($query2) or die(mysql_error());
			$result2 = mysql_fetch_object($resource2);

			$admin_amxname = cp1251_to_utf8(($result2) ? $result2->nickname : "");
		}

		// Prepare all the variables
		//$player_name = htmlentities($result->player_nick, ENT_QUOTES);
		$player_name = cp1251_to_utf8($result->player_nick);
		$map_name = $result->map_name;

		if(!empty($result->player_ip)) {
			$player_ip = htmlentities($result->player_ip, ENT_QUOTES);
		} else {
			$player_ip = "<i><font color='#677882'>" . lang("_NOIP") . "</font></i>";
		}

		if(!empty($result->player_id)) {
			$player_id = htmlentities($result->player_id, ENT_QUOTES);
		} else {
			//$player_id = "<i><font color='#677882'>" . lang("_NOSTEAMID") . "</font></i>";
			$player_id = "&nbsp;";
		}

		$timezone = $config->timezone_fixx * 3600;
		$ban_start = dateShorttime($result->ban_created + $timezone);

		if(empty($result->ban_length) OR $result->ban_length == 0) {
			$ban_duration = lang("_PERMANENT");
			$ban_end = "<i><font color='#677882'>" . lang("_NOTAPPLICABLE") . "</font></i>";
		} else {

			//echo $timezone;
			$ban_duration = $result->ban_length . "&nbsp;" . lang("_MINS");
			$date_and_ban = $result->ban_created + $timezone + ($result->ban_length * 60);

			$now = date("U");
			if($now >= $date_and_ban) {
				$ban_end = dateShorttime($date_and_ban) . "&nbsp;(" .
                    lang("_ALREADYEXP") . ")";
			} else {
				$ban_end = dateShorttime($date_and_ban) . "&nbsp;(" .
                    timeleft($now + $timezone,$date_and_ban)."&nbsp;".lang("_REMAINING").")";
			}
		}

		if($result->ban_type == "SI") {
			$ban_type = lang("_STEAMID&IP");
		} else {
			$ban_type = "SteamID";
		}

        $ban_reason = cp1251_to_utf8($result->ban_reason);

		if($result->server_name <> "website") {
			//$query2 = "SELECT nickname FROM $config->amxadmins WHERE steamid = '".$result->admin_id."'";
			$query2 = "SELECT nickname FROM $config->amxadmins WHERE username = '".$result->admin_id."' OR username = '".$result->admin_ip."' OR username = '".$result->admin_nick."'";
			$resource2 = mysql_query($query2) or die(mysql_error());
			$result2 = mysql_fetch_object($resource2);

			$admin_name = cp1251_to_utf8($result->admin_nick)." (".cp1251_to_utf8(($result2) ? $result2->nickname : "").")";
			//$server_name = $result->server_name;
            $server_name = cp1251_to_utf8($result->server_name);
		} else {
			$admin_name = cp1251_to_utf8($result->admin_nick);
			$server_name = lang("_WEBSITE");
		}


		$id_type = "bhid";
		$id = $_GET["bhid"];

		$ban_info = array(
			"id_type"	=> $id_type,
			"bhid"		=> $id,
			"player_name"	=> $player_name,
			"map_name"	=> $map_name,
			"player_id"	=> $player_id,
			"player_ip"	=> $player_ip,
			"ban_start"	=> $ban_start,
			"ban_duration"	=> $ban_duration,
			"ban_end"	=> $ban_end,
			"ban_type"	=> $ban_type,
			"ban_reason"	=> $ban_reason,
			"admin_name"	=> $admin_name,
			"amx_name"	=> isset($admin_amxname) ? $admin_amxname : "",
			"server_name"	=> $server_name
			);


		$unban_info = array(
			"verify"	=> TRUE,
			"unban_start"	=> dateShorttime($result->unban_created),
			"unban_reason"	=> cp1251_to_utf8($result->unban_reason),
			"admin_name"	=> $result->unban_admin_nick
		);

	}

	if(isset($_GET["bhid"])) {
		// Make the array for the history ban list
		if($result->player_id <> "")
		{
			$query = "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE player_id = '".$result->player_id."' ORDER BY ban_created DESC";
		}
		else // Search for IP bans
		{
			$query = "SELECT bhid, player_nick, admin_nick, ban_length, ban_reason, ban_created, server_ip FROM $config->ban_history WHERE player_ip = '".$result->player_ip."' ORDER BY ban_created DESC";
		}
		$resource = mysql_query($query) or die(mysql_error());

		$unban_array = array();

		while($result = mysql_fetch_object($resource)) {
			$bhid = $result->bhid;
			$date = dateMonth($result->ban_created);
			$player = cp1251_to_utf8($result->player_nick);
			$admin = cp1251_to_utf8($result->admin_nick);
			$reason = cp1251_to_utf8($result->ban_reason);
			$duration = $result->ban_length;

			if(empty($duration)) {
				$duration = lang("_PERMANENT");
			}

			else {
				$duration = "$duration" . lang("_MINS");
			}

			// Asign variables to the array used in the template
			$unban_info = array(
				"bhid" => $bhid,
				"date" => $date,
				"player" => $player,
				"admin" => $admin,
				"reason" => $reason,
				"duration" => $duration
				);

			$unban_array[] = $unban_info;
		}

		$history = TRUE;
	}
}

if($config->display_demo == "enabled"){

	$bhid = $_GET["bhid"];
	$resourcecc	= mysql_query("SELECT id, bid, demo, comment FROM $config->amxdemos WHERE bhid = '".mysql_escape_string($bhid)."'") or die(mysql_error());

	$demos	= array();

	while($resultss = mysql_fetch_object($resourcecc)) {
		$demo_id	= $resultss->id;
		$demo		= $resultss->demo;
		$comment	= $resultss->comment;

		$demos_info = array(
			"demo_id" => $demo_id,
			"demo" => $demo,
			"comment" => $comment
		);
		$demos	[]= $demos_info;
		}
	}

	$page = $_GET['page'];

	$bhid = $_GET['bhid'];
	$resourcec	= mysql_query("SELECT id, name, comment, email, addr, date FROM $config->amxcomments WHERE bhid =".mysql_escape_string($bhid)." ORDER BY date ASC") or die(mysql_error());

	$ban_comments	= array();
	$i=0;
	while($results = mysql_fetch_object($resourcec)) {
		$i++;
		$id		= $results->id;
		$name		= $results->name;
		$comment	= $results->comment;
		$email		= $results->email;
		$addr		= $results->addr;
		$date		= $results->date;
		$date = strftime("%d/%m/%Y %H:%M", $date);
		$comment = BBcode($comment);
		$comment = icon($comment);

		$comments_info = array(
			"order"=> $i,
			"cid"	=> $id,
			"name" => $name,
			"comment" => $comment,
			"email" => $email,
			"addr" => $addr,
			"date" => $date
			);
		$ban_comments[]= $comments_info;
}

if ((isset($_POST['action'])) && ($_POST['action'] == "insert")) {

if ($_SERVER['HTTP_CLIENT_IP'])
{
    $user_ip = $_SERVER['HTTP_CLIENT_IP'];
}
else if ($_SERVER['HTTP_X_FORWARDED_FOR'])
{
    $user_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
}
else if ($_SERVER['REMOTE_ADDR'])
{
    $user_ip = $_SERVER['REMOTE_ADDR'];
}
else
{
    $user_ip = "";
}

if($_POST['verify'] != $_SESSION['code']){
         $url      = "$config->document_root";
         $delay   = "5";
         echo "Incorrect security code, please try again!";
		 if(isset($_GET["bhid"])) {
			$bhid = $_GET['bhid'];
		    echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url=\"ban_details_ex.php?bhid=$bhid\">";
		}
         exit();
}


$name = $_POST['name'];
$comment = $_POST['comment'];
$email = $_POST['email'];
$bhid=$_GET["bhid"];

	$time = time();
    	$contact_flood=5*60;

	if(isset($_GET['bhid'])) {
 		$bhid = $_GET["bhid"];
		$sql = mysql_query("SELECT date FROM $config->amxcomments WHERE addr = '".$user_ip."' AND bhid = '".$bhid."' ORDER BY date DESC LIMIT 0, 1");
	}
    	$count = mysql_num_rows($sql);
    	list($flood_date) = mysql_fetch_array($sql);
    	$anti_flood = $flood_date + $contact_flood;

    	if ($count > 0 && $time < $anti_flood)
    	{
			$url	= "$config->document_root";
			$delay	= "5";
			echo lang("_COMMENT_ALREADY_ADDED") . "&nbsp;" . lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url=\"ban_details_ex.php?bhid=$bhid\">";
			exit();
    	} else {
		$name = trim($name);
		$email = trim($email);
		$comment = trim($comment);

		$comment = stripslashes($comment);

		$email = htmlentities($email, ENT_QUOTES);

		if(isset($_GET["bhid"]) ){

			$bid=$_GET["bhid"];
			$add = mysql_query("INSERT INTO $config->amxcomments ( `id` , `name` , `comment` , `email` , `addr` , `date` , `bhid`) VALUES ( '' , '" . $name . "' , '" . $comment . "' , '" . $email . "' , '" . $user_ip . "' , '" . $time . "' , '" . $bid . "')");
		}
		$url		= "$config->document_root";
		$delay	= "2";
		echo lang("_COMMENT_ADDED") . "&nbsp;" . lang("_REDIRECT");
		if(isset($_GET["bhid"])) {
			$bhid=$GET["bhid"];
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url=\"ban_details_ex.php?bhid=$bhid\">";
		}
		exit();
    	}
    }

if ((isset($_POST['action'])) && ($_POST['action'] == "delete") && ($_SESSION['bans_edit'] == "yes" )) {
$id = $_POST['id'];
$del = mysql_query("DELETE FROM $config->amxcomments WHERE id = '" . $id . "' LIMIT 1");

			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_COMMENT_DELETED") . "&nbsp;" . lang("_REDIRECT");
			if(isset($_GET["bhid"])) {

				$bhid=$GET["bhid"];
				echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url=\"ban_details_ex.php?bhid=$bhid\">";
			}
			exit();
}

if ((isset($_POST['action'])) && ($_POST['action'] == "edit") && ($_SESSION['bans_edit'] == "yes" )) {
$id = $_POST['id'];
$edit = $_POST['action'];
$resourceccc	= mysql_query("SELECT id, name, email, comment FROM $config->amxcomments WHERE id = '" . $id . "'") or die(mysql_error());
	$resultsss = mysql_fetch_object($resourceccc);
	$edit_id		= $resultsss->id;
	$edit_name		= $resultsss->name;
	$edit_email		= $resultsss->email;
	$edit_comment	= $resultsss->comment;
}


if ((isset($_POST['action'])) && ($_POST['action'] == "update") && ($_SESSION['bans_edit'] == "yes" )) {
		$update = mysql_query("UPDATE $config->amxcomments SET email = '".$_POST['email']."', comment = '".$_POST['comment']."' WHERE id = '".$_POST['id']."'") or die (mysql_error());

			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_COMMENT_UPDATED") . "&nbsp;" . lang("_REDIRECT");
			if(isset($_GET["bhid"])) {

				echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url=\"ban_details.php?bhid=$bhid\">";
			}
			exit();
}

/****************************************************************
* Template parsing						*
****************************************************************/


$title = lang("_BANDETAILS");

$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("working_title","home");
$smarty->assign("dir",$config->document_root);

//$smarty->assign("this","ban_details.php");

$smarty->assign("edit",$edit);
$smarty->assign("edit_id",$edit_id);
$smarty->assign("edit_name",$edit_name);
$smarty->assign("edit_email",$edit_email);
$smarty->assign("edit_comment",$edit_comment);

$smarty->assign("display_search", $config->display_search);
$smarty->assign("display_admin", $config->display_admin);
$smarty->assign("display_reason", $config->display_reason);
$smarty->assign("display_demo", $config->display_demo);
$smarty->assign("display_comments", $config->display_comments);

$smarty->assign("ban_info", isset($ban_info) ? $ban_info : "");
$smarty->assign("unban_info", isset($unban_info) ? $unban_info : "");
$smarty->assign("history", isset($history) ? $history : "" );
$smarty->assign("bhans", isset($unban_array) ? $unban_array : "");
$smarty->assign("parsetime", isset($parsetime) ? $parsetime : "");
$smarty->assign("ban_comments", isset($ban_comments) ? $ban_comments : "");
$smarty->assign("demos", isset($demos) ? $demos : "");

$smarty->display('main_header.tpl');

	echo "<script type=\"text/javascript\">\n"
	."<!--\n"
	."\n"
	. "function verifchamps()\n"
	. "{\n"
	. "if (document.getElementById('ns_name').value.length == 0)\n"
	. "{\n"
	. "alert('" . lang("_NONAME") . "');\n"
	. "return false;\n"
	. "}\n"
	. "if (document.getElementById('ns_email').value.indexOf('@') == -1)\n"
	. "{\n"
	. "alert('" . lang("_NOMAIL") . "');\n"
	. "return false;\n"
	. "}\n"
	. "if (document.getElementById('ns_comment').value.length == 0)\n"
	. "{\n"
	. "alert('" . lang("_NOTEXT") . "');\n"
	. "return false;\n"
	. "}\n"
	. "return true;\n"
	. "}\n"
	. "\n"
	. "// -->\n"
	."</script>\n";

$smarty->display('ban_details.tpl');
$smarty->display('main_footer.tpl');
?>