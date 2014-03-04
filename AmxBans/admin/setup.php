<?php

/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
 *
 *	web	: http://www.xs4all.nl/~yomama/amxbans/
 *	mail	: yomama@xs4all.nl
 *	ICQ	: 104115504
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
 *
 */

// Make sure the installation hasn't already occurred (check for config.inc.php)

if ( file_exists("../include/config.inc.php") )
{
	header( "Location:../ban_list.php" );
	exit();
}

$php_version="5.1b";

function get_php_setting($type) { //1 = safe_mode,2=register_globals ("on","off")
	ob_start();
	phpinfo();
	$phpinfo = array('phpinfo' => array());
	if(preg_match_all('#(?:<h2>(?:<a name=".*?">)?(.*?)(?:</a>)?</h2>)|(?:<tr(?: class=".*?")?><t[hd](?: class=".*?")?>(.*?)\s*</t[hd]>(?:<t[hd](?: class=".*?")?>(.*?)\s*</t[hd]>(?:<t[hd](?: class=".*?")?>(.*?)\s*</t[hd]>)?)?</tr>)#s', ob_get_clean(), $matches, PREG_SET_ORDER)) {	
		foreach($matches as $match) {
			if(strlen($match[1])) {
				$phpinfo[$match[1]] = array();
			} elseif(isset($match[3])) {
				$phpinfo[end(array_keys($phpinfo))][$match[2]] = isset($match[4]) ? array($match[3], $match[4]) : $match[3];
			} else {
				$phpinfo[end(array_keys($phpinfo))][] = $match[2];
			}
		}
	}
	switch($type) {
		case 1: return $phpinfo['PHP Core']['safe_mode'][0]; 
		case 2: return $phpinfo['PHP Core']['register_globals'][0]; 
	}
	ob_end_clean();
}
function display_post_get() { 
   if ($_POST) { 
      echo "Displaying POST Variables: <br> \n"; 
      echo "<table border=1> \n"; 
      echo " <tr> \n";
      echo "  <td><b>result_name </b></td> \n "; 
      echo "  <td><b>result_val  </b></td> \n "; 
      echo " </tr> \n"; 
      while (list($result_nme, $result_val) = each($_POST)) { 
         echo " <tr> \n"; 
         echo "  <td> $result_nme </td> \n"; 
         echo "  <td> $result_val </td> \n"; 
         echo " </tr> \n"; 
      } 
      echo "</table> \n"; 
   } 
   if ($_GET) { 
      echo "Displaying GET Variables: <br> \n"; 
      echo "<table border=1> \n"; 
      echo " <tr> \n"; 
      echo "  <td><b>result_name </b></td> \n "; 
      echo "  <td><b>result_val  </b></td> \n "; 
      echo " </tr> \n"; 
      while (list($result_nme, $result_val) = each($_GET)) { 
         echo " <tr> \n"; 
         echo "  <td> $result_nme </td> \n"; 
         echo "  <td> $result_val </td> \n"; 
         echo " </tr> \n"; 
      } 
      echo "</table> \n"; 
   } 
}
############### file / dir check #####################
#file_perms($file); // prints: 754
#file_perms($file); // prints 0754
function file_perms($file, $octal = false)
{
    if(!file_exists($file)) return false;

    $perms = fileperms($file);

    $cut = $octal ? 1 : 2;

    return substr(decoct($perms), $cut);
}
##############################################
if (isset($_POST['action'])) {
	$action = $_POST['action'];
}

if ((isset($action)) && ($action == " proceed to AMXBans ")) {
	//header( "Location:$config->document_root" );
	header( "Location:../" );
}

if ((isset($_POST['action'])) && ($_POST['action'] == " step 5 ")) {
	if (($_POST['admin_nick'] == "") || ($_POST['admin_email'] == "") || ($_POST['admin_pass'] == "")) {
		$empty_details = 1;
		$action = " step 4 ";
	}
}

if ((isset($_POST['check'])) && ($_POST['check'] == " check connection ")) {
	unset($dblogin);
	if (($_POST['db_host'] == "") || ($_POST['db_name'] == "") || ($_POST['db_user'] == "")) {
		$dblogin = 0; //some fields are left blank
	} else {
		$link = @mysql_connect($_POST['db_host'], $_POST['db_user'], $_POST['db_pass']);

		if (!$link) { // can't connect to database
			$dblogin = 1;
		} else {
			$db_selected = mysql_select_db($_POST['db_name'], $link);

			if (!$db_selected) { //can't switch to mentioned database
				$dblogin = 2;
			} else { // connection successfull and database exists
				$dblogin = 3;
			}
		}
	}
} else if ((isset($_POST['check'])) && ($_POST['check'] == " create ")) {

	$link = mysql_connect($_POST['db_host'], $_POST['db_user'], $_POST['db_pass']);

	function TableExists($tablename, $db) {
   
		$result = mysql_list_tables($db);
		$rcount = mysql_num_rows($result);

		for ($i=0;$i<$rcount;$i++) {
			if (mysql_tablename($result, $i)==$tablename) {
				return true;
			}
		}
		return false;
	}

	$tbl_bans_exists = TableExists($_POST['tbl_bans'], $_POST['db_name']);
	if ($tbl_bans_exists == "true") {
		$tbl_bans_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_bans']."` (`bid` int(11) NOT NULL auto_increment, `player_ip` varchar(100) default NULL, `player_id` varchar(50) NOT NULL default '0', `player_nick` varchar(100) NOT NULL default 'Unknown', `admin_ip` varchar(100) default NULL, `admin_id` varchar(50) NOT NULL default '0', `admin_nick` varchar(100) NOT NULL default 'Unknown', `ban_type` varchar(10) NOT NULL default 'S', `ban_reason` varchar(255) NOT NULL default '', `ban_created` int(11) NOT NULL default '0', `ban_length` varchar(100) NOT NULL default '', `server_ip` varchar(100) NOT NULL default '', `server_name` varchar(100) NOT NULL default 'Unknown', PRIMARY KEY (`bid`))") or die (mysql_error());
		$tbl_bans_created = 1;
	}

	$tbl_banhistory_exists = TableExists($_POST['tbl_banhistory'], $_POST['db_name']);
	if ($tbl_banhistory_exists == "true") {
		$tbl_banhistory_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_banhistory']."` (`bhid` int(11) NOT NULL auto_increment, `player_ip` varchar(100) default NULL, `player_id` varchar(50) NOT NULL default '0', `player_nick` varchar(100) NOT NULL default 'Unknown', `admin_ip` varchar(100) default NULL, `admin_id` varchar(50) NOT NULL default '0', `admin_nick` varchar(100) NOT NULL default 'Unknown', `ban_type` varchar(10) NOT NULL default 'S', `ban_reason` varchar(255) NOT NULL default '', `ban_created` int(11) NOT NULL default '0', `ban_length` varchar(100) NOT NULL default '', `server_ip` varchar(100) NOT NULL default '', `server_name` varchar(100) NOT NULL default 'Unknown', `unban_created` int(11) NOT NULL default '0', `unban_reason` varchar(255) NOT NULL default 'tempban expired', `unban_admin_nick` varchar(100) NOT NULL default 'Unknown', PRIMARY KEY (`bhid`))") or die (mysql_error());
		$tbl_banhistory_created = 1;
	}

	$tbl_webadmins_exists = TableExists($_POST['tbl_webadmins'], $_POST['db_name']);
	if ($tbl_webadmins_exists == "true") {
		$tbl_webadmins_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_webadmins']."` (`id` int(12) NOT NULL auto_increment, `username` varchar(32) default NULL, `password` varchar(32) default NULL, `level` varchar(32) NOT NULL default '6', `logcode` varchar(32) NOT NULL default '', PRIMARY KEY  (`id`), UNIQUE KEY (`username`))") or die (mysql_error());
		$tbl_webadmins_created = 1;
	}

	$tbl_amxadmins_exists = TableExists($_POST['tbl_amxadmins'], $_POST['db_name']);
	if ($tbl_amxadmins_exists == "true") {
		$check_amxadmins_ashow = @mysql_query("SELECT ashow FROM `".$_POST['tbl_amxadmins']."` WHERE 1");
		if (!$check_amxadmins_ashow) {
			$add_amxadmins_ashow = mysql_query("ALTER TABLE `".$_POST['tbl_amxadmins']."` ADD `ashow` INT( 11 ) NOT NULL") or die (mysql_error());
			$update_amxadmins = 1;
		} else {
			$update_amxadmins = 0;
		}
		$tbl_amxadmins_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_amxadmins']."` (`id` int(12) NOT NULL auto_increment, `username` varchar(32) default NULL, `password` varchar(32) default NULL, `access` varchar(32) default NULL, `flags` varchar(32) default NULL, `steamid` varchar(32) default NULL, `nickname` varchar(32) NOT NULL default '',`ashow` INT( 11 ) NOT NULL, PRIMARY KEY  (`id`))") or die (mysql_error());
		$tbl_amxadmins_created = 1;
	}

	$tbl_levels_exists = TableExists($_POST['tbl_levels'], $_POST['db_name']);
	if ($tbl_levels_exists == "true") {

		$check_ip_view = @mysql_query("SELECT ip_view FROM `".$_POST['tbl_levels']."` WHERE 1");
	
		if (!$check_ip_view) {
			$add_ip_view = mysql_query("ALTER TABLE `".$_POST['tbl_levels']."` ADD `ip_view` ENUM( 'yes', 'no' ) DEFAULT 'no' NOT NULL") or die (mysql_error());
			$update_amxlevels = 1;
		} else {
			$update_amxlevels = 0;
		}

		$check_servers_view = @mysql_query("SELECT servers_view FROM `".$_POST['tbl_levels']."` WHERE 1");

		if (!$check_servers_view) {
			$update_amxlevels = 0;
		} else {
			$edit_servers_view = mysql_query("ALTER TABLE `".$_POST['tbl_levels']."` CHANGE `servers_view` `servers_edit` ENUM( 'yes', 'no' ) DEFAULT 'no' NOT NULL ") or die (mysql_error());
			$update_amxlevels = 1;
		}

		$check_servers_delete = @mysql_query("SELECT servers_delete FROM `".$_POST['tbl_levels']."` WHERE 1");

		if (!$check_servers_delete) {
			$update_amxlevels = 0;
		} else {
			$delete_servers_delete = mysql_query("ALTER TABLE `".$_POST['tbl_levels']."` DROP `servers_delete") or die (mysql_error());
			$update_amxlevels = 1;
		}

		$edit_own = @mysql_query("ALTER TABLE `".$_POST['tbl_levels']."` CHANGE `bans_edit` `bans_edit` ENUM( 'yes', 'no', 'own' ) DEFAULT 'no' NOT NULL, CHANGE `bans_delete` `bans_delete` ENUM( 'yes', 'no', 'own' ) DEFAULT 'no' NOT NULL , CHANGE `bans_unban` `bans_unban` ENUM( 'yes', 'no', 'own' ) DEFAULT 'no' NOT NULL") or die (mysql_error());

		$tbl_levels_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_levels']."` (`level` int(12) NOT NULL default '0', `bans_add` enum('yes','no') NOT NULL default 'no', `bans_edit` enum('yes','no', 'own') NOT NULL default 'no', `bans_delete` enum('yes','no', 'own') NOT NULL default 'no', `bans_unban` enum('yes','no', 'own') NOT NULL default 'no', `bans_import` enum('yes','no') NOT NULL default 'no', `bans_export` enum('yes','no') NOT NULL default 'no', `amxadmins_view` enum('yes','no') NOT NULL default 'no', `amxadmins_edit` enum('yes','no') NOT NULL default 'no', `webadmins_view` enum('yes','no') NOT NULL default 'no', `webadmins_edit` enum('yes','no') NOT NULL default 'no', `permissions_edit` enum('yes','no') NOT NULL default 'no', `prune_db` enum('yes','no') NOT NULL default 'no', `servers_edit` enum('yes','no') NOT NULL default 'no', `ip_view` enum('yes','no') NOT NULL default 'no', PRIMARY KEY  (`level`))") or die (mysql_error());
		$tbl_levels_created = 1;
	}

	$tbl_admins_servers_exists = TableExists($_POST['tbl_admins_servers'], $_POST['db_name']);
	if ($tbl_admins_servers_exists == "true") {
		$tbl_admins_servers_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_admins_servers']."` (`admin_id` int(12) NOT NULL default '0', `server_id` int(12) NOT NULL default '0')") or die (mysql_error());
		$tbl_admins_servers_created = 1;
	}

	$tbl_servers_exists = TableExists($_POST['tbl_servers'], $_POST['db_name']);
	if ($tbl_servers_exists == "true") {

		$check_amxban_menu = @mysql_query("SELECT amxban_menu FROM `".$_POST['tbl_servers']."` WHERE 1");
	
		if (!$check_amxban_menu) {
			$add_amxbans_menu = mysql_query("ALTER TABLE `".$_POST['tbl_servers']."` ADD `amxban_menu` int(10) DEFAULT '0' NOT NULL") or die (mysql_error());
			$update_amxservers = 1;
		} else {
			$update_amxservers = 0;
		}

		$tbl_servers_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_servers']."` (`id` int(11) NOT NULL auto_increment, `timestamp` varchar(50) NOT NULL default '0', `hostname` varchar(100) NOT NULL default 'Unknown', `address` varchar(32) NOT NULL default '', `gametype` varchar(32) NOT NULL default '', `rcon` varchar(32) default NULL, `amxban_version` varchar(32) NOT NULL default '', `amxban_motd` varchar(250) NOT NULL default '', `motd_delay` int(10) NOT NULL default '10', `amxban_menu` int(10) NOT NULL default '0', PRIMARY KEY  (`id`))") or die (mysql_error());
		$tbl_servers_created = 1;
	}

	$tbl_logs_exists = TableExists($_POST['tbl_logs'], $_POST['db_name']);
	if ($tbl_logs_exists == "true") {
		$tbl_logs_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_logs']."` (`id` int(11) NOT NULL auto_increment, `timestamp` int(1) NOT NULL, `ip` varchar(100) NOT NULL, `username` varchar(100) NOT NULL, `action` varchar(100) NOT NULL, `remarks` varchar(100) NOT NULL, PRIMARY KEY (`id`))") or die (mysql_error());
		$tbl_logs_created = 1;
	}

	$tbl_reasons_exists = TableExists($_POST['tbl_reasons'], $_POST['db_name']);
	if ($tbl_reasons_exists == "true") {
		$tbl_reasons_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_reasons']."` (`id` int(12) NOT NULL auto_increment, `address` varchar(32) NOT NULL, `reason` varchar(250) NOT NULL, PRIMARY KEY (`id`))") or die (mysql_error());
		$tbl_reasons_created = 1;
	}
########################## demo and comment mod added
	$tbl_comments_exists = TableExists($_POST['tbl_comments'], $_POST['db_name']);
	if ($tbl_comments_exists == "true") {
		$check_comments_bhid = @mysql_query("SELECT bhid FROM `".$_POST['tbl_comments']."` WHERE 1");
		if (!$check_comments_bhid) {
			$add_amxbans_menu = mysql_query("ALTER TABLE `".$_POST['tbl_comments']."` ADD `bhid` int(11) NOT NULL") or die (mysql_error());
			$update_amxcomments = 1;
		} else {
			$update_amxcomments = 0;
		}
		$tbl_comments_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_comments']."` (`id` int(11) NOT NULL auto_increment, `name` varchar(35) NOT NULL default '', `comment` text NOT NULL, `email` varchar(100) NOT NULL default '', `addr` varchar(100) NOT NULL default '', `date` varchar(35) NOT NULL default '', `bid` int(11) NOT NULL default '0', `bhid` int(11) NOT NULL default '0', PRIMARY KEY  (`id`)) TYPE=MyISAM AUTO_INCREMENT=1") or die (mysql_error());
		$tbl_comments_created = 1;
	}
	$tbl_demos_exists = TableExists($_POST['tbl_demos'], $_POST['db_name']);
	if ($tbl_demos_exists == "true") {
		$check_demos_bhid = @mysql_query("SELECT bhid FROM `".$_POST['tbl_demos']."` WHERE 1");
		if (!$check_demos_bhid) {
			$add_amxbans_menu = mysql_query("ALTER TABLE `".$_POST['tbl_demos']."` ADD `bhid` int(11) NOT NULL") or die (mysql_error());
			$update_amxdemos = 1;
		} else {
			$update_amxdemos = 0;
		}
		$tbl_demos_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_demos']."` (`id` int(11) NOT NULL auto_increment,`bid` varchar(100) NOT NULL default '',`demo` varchar(100) NOT NULL default '',`comment` text NOT NULL,`bhid` varchar(100) NOT NULL default '',PRIMARY KEY  (`id`)) TYPE=MyISAM AUTO_INCREMENT=1") or die (mysql_error());
		$tbl_demos_created = 1;
	}
	$tbl_smilies_exists = TableExists($_POST['tbl_smilies'], $_POST['db_name']);
	if ($tbl_smilies_exists == "true") {
		$tbl_smilies_created = 0;
	} else {
		$create_tbl = mysql_query("CREATE TABLE `".$_POST['tbl_smilies']."` (`id` int(5) NOT NULL auto_increment,`code` varchar(50) NOT NULL default '',`url` varchar(100) NOT NULL default '',`name` varchar(100) NOT NULL default '',PRIMARY KEY  (`id`)) TYPE=MyISAM AUTO_INCREMENT=12") or die (mysql_error());
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (1, ':D', 'biggrin.gif', 'Very Happy')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (2, ':)', 'smile.gif', 'Smile')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (3, ':(', 'frown.gif', 'Sad')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (4, ':o', 'eek.gif', 'Surprised')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (5, ':?', 'confused.gif', 'Confused')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (6, '8)', 'cool.gif', 'Cool')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (7, ':P', 'tongue.gif', 'Razz')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (8, ':x', 'mad.gif', 'Mad')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (9, ';)', 'wink.gif', 'Wink')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (10, ':red:', 'redface.gif', 'Embarassed')");
		$create_tbl = mysql_query("INSERT INTO `".$_POST['tbl_smilies']."` VALUES (11, ':roll:', 'rolleyes.gif', 'Rolling Eyes')");
		$tbl_smilies_created = 1;
	}

#####################################################

} else if ((isset($_POST['check'])) && ($_POST['check'] == " check dirs ")) {
	unset($checked_dirs);
	//if (($_POST['doc_root'] == "") || ($_POST['path_root'] == "") || ($_POST['dir_import'] == "") || ($_POST['dir_template'] == "")) {
	// Removed the check for doc_rot if emty because sometimes it has to be empty // lantz69
	if (($_POST['path_root'] == "") || ($_POST['dir_import'] == "") || ($_POST['dir_template'] == "")) {
		$checked_dirs = 1; //some fields are left blank
	} else {
		
		if (is_dir($_POST['path_root'])) {
			$path_root_is_dir = 1;
		} else {
			$path_root_is_dir = 0;
		}

		if (is_dir($_POST['dir_import'])) {
			$dir_import_is_dir = 1;
		} else {
			$dir_import_is_dir = 0;
		}

		if (is_dir($_POST['dir_template'])) {
			$dir_template_is_dir = 1;
		} else {
			$dir_template_is_dir = 0;
		}
		if (is_dir('../demos')) {
			$dir_demos_is_dir = 1;
		} else {
			$dir_demos_is_dir = 0;
		}
		if (is_dir('../include')) {
			$dir_include_is_dir = 1;
		} else {
			$dir_include_is_dir = 0;
		}
		if (is_dir('../smarty/templates_c')) {
			$dir_smarty_is_dir = 1;
		} else {
			$dir_smarty_is_dir = 0;
		}
	}


	if ($checked_dirs != 1) {
		if (($path_root_is_dir == 0) || ($dir_import_is_dir == 0) || ($dir_template_is_dir == 0) || ($dir_demos_is_dir == 0)) {
			$checked_dirs = 2;
		} else {
			$checked_dirs = 3;
		}
	}
	if(file_perms($_POST['dir_import']) == 777) { $dir_import_chmod = 1; } else { $dir_import_chmod = 0; $checked_dirs = 4;}
	#if(file_perms($_POST['dir_template']) == 777) { $dir_template_chmod = 1; } else { $dir_template_chmod = 0; $checked_dirs = 4;}
	if(file_perms('../demos') == 777) { $dir_demos_chmod = 1; } else { $dir_demos_chmod = 0; $checked_dirs = 4;}
	if(file_perms('../include') == 777) { $dir_include_chmod = 1; } else { $dir_include_chmod = 0; $checked_dirs = 4;}
	if(file_perms('../smarty/templates_c') == 777) { $dir_smarty_chmod = 1; } else { $dir_smarty_chmod = 0; $checked_dirs = 4;}
}

?>

<html>
<head>
<title>AMXBans - Installation</title>


<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />

<link rel="stylesheet" type="text/css" href="../include/amxbans.css" />

</head>

<body>

<table border='0' cellpadding='0' cellspacing='0' width='100%'>
  <tr>
    <td width='100%' valign='top' style='padding: 20px'>
    <table border='0' cellpadding='0' cellspacing='0' width='100%'>
      <tr>
        <td>

<?php if ((isset($action)) && ($action == " step 2 " || $action == " check tables ")) { ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 2: Create tables</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		Here you can define names for your tables. Please note that if you choose a different name for the Bans table and/or AMXAdmins table, you need to specify the same names in the amxbans and admin_mysql plugins.<br><br>
		Existing tables will <b>*not*</b> be overwritten. So this script is safe when upgrading from previous versions of AMXBans.

		<br><br></td>
	</tr>

	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<input type="hidden" name="action" value="<?=$_POST['action'] ?>">
	<input type="hidden" name="db_host" value="<?=$_POST['db_host'] ?>">
	<input type="hidden" name="db_name" value="<?=$_POST['db_name'] ?>">
	<input type="hidden" name="db_user" value="<?=$_POST['db_user'] ?>">
	<input type="hidden" name="db_pass" value="<?=$_POST['db_pass'] ?>">
	<input type="hidden" name="tbl_bans" value="<?=isset($_POST['tbl_bans']) ? $_POST['tbl_bans'] : "" ?>">
	<input type="hidden" name="tbl_banhistory" value="<?=isset($_POST['tbl_banhistory']) ? $_POST['tbl_banhistory'] : "" ?>">
	<input type="hidden" name="tbl_webadmins" value="<?=isset($_POST['tbl_webadmins']) ? $_POST['tbl_webadmins'] : "" ?>">
	<input type="hidden" name="tbl_amxadmins" value="<?=isset($_POST['tbl_amxadmins']) ? $_POST['tbl_amxadmins'] : "" ?>">
	<input type="hidden" name="tbl_levels" value="<?=isset($_POST['tbl_levels']) ? $_POST['tbl_levels'] : "" ?>">
	<input type="hidden" name="tbl_admins_servers" value="<?=isset($_POST['tbl_admins_servers']) ? $_POST['tbl_admins_servers'] : "" ?>">
	<input type="hidden" name="tbl_servers" value="<?=isset($_POST['tbl_servers']) ? $_POST['tbl_servers'] : "" ?>">
	<input type="hidden" name="tbl_logs" value="<?=isset($_POST['tbl_logs']) ? $_POST['tbl_logs'] : "" ?>">
	<input type="hidden" name="tbl_reasons" value="<?=isset($_POST['tbl_reasons']) ? $_POST['tbl_reasons'] : "" ?>">
	

<!--########################## demo and comment mod added-->

	<input type="hidden" name="tbl_comments" value="<?=isset($_POST['tbl_comments']) ? $_POST['tbl_comments'] : "" ?>">
	<input type="hidden" name="tbl_demos" value="<?=isset($_POST['tbl_demos']) ? $_POST['tbl_demos'] : "" ?>">
	<input type="hidden" name="tbl_smilies" value="<?=isset($_POST['tbl_smilies']) ? $_POST['tbl_smilies'] : "" ?>">
	
<!--#####################################################-->	

	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Bans table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_bans'])) && (!isset($tbl_bans_created))) { ?><input type="text" name="tbl_bans" value="<? if (!isset($POST['tbl_bans'])) { echo "amx_bans"; } else { print $_POST['tbl_bans']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_bans_created == 0) { echo "table '".$_POST['tbl_bans']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_bans']."' successfully created</font>"; } }?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Banhistory table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_banhistory'])) && (!isset($tbl_banhistory_created))) { ?><input type="text" name="tbl_banhistory" value="<? if (!isset($POST['tbl_banhistory'])) { echo "amx_banhistory"; } else { print $_POST['tbl_banhistory']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_banhistory_created == 0) { echo "table '".$_POST['tbl_banhistory']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_banhistory']."' successfully created</font>"; } }?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Webadmins table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_webadmins'])) && (!isset($tbl_webadmins_created))) { ?><input type="text" name="tbl_webadmins" value="<? if (!isset($POST['tbl_webadmins'])) { echo "amx_webadmins"; } else { print $_POST['tbl_webadmins']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_webadmins_created == 0) { echo "table '".$_POST['tbl_webadmins']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_webadmins']."' successfully created</font>"; } }?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>AMXadmins table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_amxadmins'])) && (!isset($tbl_amxadmins_created))) { ?><input type="text" name="tbl_amxadmins" value="<? if (!isset($POST['tbl_amxadmins'])) { echo "amx_amxadmins"; } else { print $_POST['tbl_amxadmins']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { 
			if ($tbl_amxadmins_created == 0) {
				if ($update_amxadmins == 1) {
					echo "table '".$_POST['tbl_amxadmins']."' exists, patched to version ".$php_version."...";
				} else {
					echo "table '".$_POST['tbl_amxadmins']."' exists, skipped..."; 
				}	
			} else { 
				echo "<font color='#00b266'>table '".$_POST['tbl_amxadmins']."' successfully created</font>"; 
			} 
		}?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Levels table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_levels'])) && (!isset($tbl_levels_created))) { ?><input type="text" name="tbl_levels" value="<? if (!isset($POST['tbl_levels'])) { echo "amx_levels"; } else { print $_POST['tbl_levels']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { 
			if ($tbl_levels_created == 0) {
				if ($update_amxlevels == 1) {
					echo "table '".$_POST['tbl_levels']."' exists, patched to version ".$php_version."...";
				} else {
					echo "table '".$_POST['tbl_levels']."' exists, skipped...";									
				}
			} else {
				echo "<font color='#00b266'>table '".$_POST['tbl_levels']."' successfully created</font>";
			}
		}?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Admins/Servers crosstable</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_admins_servers'])) && (!isset($tbl_admins_servers_created))) { ?><input type="text" name="tbl_admins_servers" value="<? if (!isset($POST['tbl_admins_servers'])) { echo "amx_admins_servers"; } else { print $_POST['tbl_admins_servers']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_admins_servers_created == 0) { echo "table '".$_POST['tbl_admins_servers']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_admins_servers']."' successfully created</font>"; } }?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Serverinfo table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_servers'])) && (!isset($tbl_servers_created))) { ?><input type="text" name="tbl_servers" value="<? if (!isset($POST['tbl_servers'])) { echo "amx_serverinfo"; } else { print $_POST['tbl_servers']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else {

			if ($tbl_servers_created == 0) {
				if ($update_amxservers == 1) {
					echo "table '".$_POST['tbl_servers']."' exists, patched to version ".$php_version."...";
				} else {
					echo "table '".$_POST['tbl_servers']."' exists, skipped...";									
				}
			} else {
				echo "<font color='#00b266'>table '".$_POST['tbl_servers']."' successfully created</font>";
			}
		}?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Log table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_logs'])) && (!isset($tbl_logs_created))) { ?><input type="text" name="tbl_logs" value="<? if (!isset($POST['tbl_logs'])) { echo "amx_logs"; } else { print $_POST['tbl_logs']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_logs_created == 0) { echo "table '".$_POST['tbl_logs']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_logs']."' successfully created</font>"; } }?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Banreasons table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_reasons'])) && (!isset($tbl_reasons_created))) { ?><input type="text" name="tbl_reasons" value="<? if (!isset($POST['tbl_reasons'])) { echo "amx_banreasons"; } else { print $_POST['tbl_reasons']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_reasons_created == 0) { echo "table '".$_POST['tbl_reasons']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_reasons']."' successfully created</font>"; } }?></td>
	</tr>

<!--########################## demo and comment mod added-->
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Comments table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_comments'])) && (!isset($tbl_comments_created))) { ?><input type="text" name="tbl_comments" value="<? if (!isset($POST['tbl_comments'])) { echo "amx_comments"; } else { print $_POST['tbl_comments']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { 
		
			if ($tbl_comments_created == 0) { 
				if ($update_amxcomments == 1) {
					echo "table '".$_POST['tbl_comments']."' exists, patched to version ".$php_version."...";
				} else {	
					echo "table '".$_POST['tbl_comments']."' exists, skipped...";
				}
			} else {
				echo "<font color='#00b266'>table '".$_POST['tbl_comments']."' successfully created</font>";
			} 
		}?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Demos table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_demos'])) && (!isset($tbl_demos_created))) { ?><input type="text" name="tbl_demos" value="<? if (!isset($POST['tbl_demos'])) { echo "amx_demos"; } else { print $_POST['tbl_demos']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else {
			
			if ($tbl_demos_created == 0) {
				if ($update_amxdemos == 1) {
					echo "table '".$_POST['tbl_demos']."' exists, patched to version ".$php_version."...";
				} else {
					echo "table '".$_POST['tbl_demos']."' exists, skipped...";
				}
			} else { 
				echo "<font color='#00b266'>table '".$_POST['tbl_demos']."' successfully created</font>"; 
			} 
		}?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Smilies table</td>
		<td height='16' width='70%' class='listtable_1'><? if ((!isset($_POST['tbl_smilies'])) && (!isset($tbl_smilies_created))) { ?><input type="text" name="tbl_smilies" value="<? if (!isset($POST['tbl_smilies'])) { echo "amx_smilies"; } else { print $_POST['tbl_smilies']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"> <?php } else { if ($tbl_smilies_created == 0) { echo "table '".$_POST['tbl_smilies']."' exists, skipped..."; } else { echo "<font color='#00b266'>table '".$_POST['tbl_smilies']."' successfully created</font>"; } }?></td>
	</tr>

<!--#####################################################-->

	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'><? if (isset($_POST['check']) && $_POST['check'] == " create ") { ?><input type='submit' name='action' value=' step 3 ' style='font-family: verdana, tahoma, arial; font-size: 10px'> <?php }else { ?><input type='submit' name='check' value=' create ' style='font-family: verdana, tahoma, arial; font-size: 10px'><? } ?></td>
	</tr>
	</form>
</table>

<?php } else if ((isset($action)) && ($action == " step 3 ")) { ?>
<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 3: Directories</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		Enter the path-information for AMXBans here. This script tries to calculate the correct values. If you are not sure what to enter here, <b>*please accept the default values*</b>

		<br><br></td>
	</tr>

	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<input type="hidden" name="action" value="<?=$_POST['action'] ?>">
	<input type="hidden" name="db_host" value="<?=$_POST['db_host'] ?>">
	<input type="hidden" name="db_name" value="<?=$_POST['db_name'] ?>">
	<input type="hidden" name="db_user" value="<?=$_POST['db_user'] ?>">
	<input type="hidden" name="db_pass" value="<?=$_POST['db_pass'] ?>">
	<input type="hidden" name="tbl_bans" value="<?=$_POST['tbl_bans'] ?>">
	<input type="hidden" name="tbl_banhistory" value="<?=$_POST['tbl_banhistory'] ?>">
	<input type="hidden" name="tbl_webadmins" value="<?=$_POST['tbl_webadmins'] ?>">
	<input type="hidden" name="tbl_amxadmins" value="<?=$_POST['tbl_amxadmins'] ?>">
	<input type="hidden" name="tbl_levels" value="<?=$_POST['tbl_levels'] ?>">
	<input type="hidden" name="tbl_admins_servers" value="<?=$_POST['tbl_admins_servers'] ?>">
	<input type="hidden" name="tbl_servers" value="<?=$_POST['tbl_servers'] ?>">
	<input type="hidden" name="tbl_logs" value="<?=$_POST['tbl_logs'] ?>">
	<input type="hidden" name="tbl_reasons" value="<?=$_POST['tbl_reasons'] ?>">
	<input type="hidden" name="tbl_comments" value="<?=$_POST['tbl_comments'] ?>">
	<input type="hidden" name="tbl_demos" value="<?=$_POST['tbl_demos'] ?>">
	<input type="hidden" name="tbl_smilies" value="<?=$_POST['tbl_smilies'] ?>">

	</tr>


	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Document root</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="doc_root" value="<? if (!isset($_POST['doc_root'])) { $docroot = str_replace ("/admin/setup.php", "", $_SERVER["PHP_SELF"]); echo "$docroot"; } else { print $_POST['doc_root']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 400px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Path root</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="path_root" value="<? if (!isset($_POST['path_root'])) { $scriptrealpath = ereg_replace("\\\\",'/', realpath("."));$scriptrealpath = ereg_replace("/admin",'', $scriptrealpath); echo $scriptrealpath; } else { print $_POST['path_root']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 400px">
			<?php if ((isset($_POST['check']) && $_POST['check'] == " check dirs ") && ($path_root_is_dir != 1)) { 
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
			} 
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Import dir</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="dir_import" value="<? if (!isset($_POST['dir_import'])) {$scriptrealpath = ereg_replace("\\\\",'/', realpath("."));$scriptrealpath = ereg_replace("/admin",'', $scriptrealpath); echo $scriptrealpath."/tmp"; } else { print $_POST['dir_import']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 400px">
			<?php if (( isset($_POST['check']) && ($_POST['check'] == " check dirs "))) {
				if ($dir_import_is_dir != 1) { 
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
				} else if ($dir_import_chmod == 0) {
					echo "&nbsp;<font color=\"#ff0000\">chmod check failed, need 777.</font>";
				} else {
					echo "&nbsp;<font color=\"#00b266\">OK.</font>";
				}
			}
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Template dir</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="dir_template" value="<? if (!isset($_POST['dir_template'])) { $scriptrealpath = ereg_replace("\\\\",'/', realpath("."));$scriptrealpath = ereg_replace("/admin",'', $scriptrealpath); echo $scriptrealpath."/templates"; } else { print $_POST['dir_template']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 400px">
			<?php if ((isset($_POST['check']) && ($_POST['check'] == " check dirs "))) {
				if($dir_template_is_dir != 1) {
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
				#} else if ($dir_template_chmod == 0) {
				#	echo "&nbsp;<font color=\"#ff0000\">chmod check failed, need 777.</font>";
				} else {
					echo "&nbsp;<font color=\"#00b266\">OK.</font>";
				}
			} 
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Demos dir</td>
		<td height='16' width='70%' class='listtable_1'>./demos
			<?php if ((isset($_POST['check']) && ($_POST['check'] == " check dirs "))) {
				if ($dir_demos_is_dir != 1) {
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
				} else if($dir_demos_chmod == 0) {
					echo "&nbsp;<font color=\"#ff0000\">chmod check failed, need 777.</font>"; 
				} else {
					echo "&nbsp;<font color=\"#00b266\">OK.</font>";
				}

			} 
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Include dir</td>
		<td height='16' width='70%' class='listtable_1'>./include 
			<?php if ((isset($_POST['check']) && ($_POST['check'] == " check dirs "))) {
				if ($dir_include_is_dir != 1) {
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
				} else if($dir_include_chmod == 0) {
					echo "&nbsp;<font color=\"#ff0000\">chmod check failed, need 777.</font>";if ($dir_include_is_dir != 1);
				} else {
					echo "&nbsp;<font color=\"#00b266\">OK.</font>";
				}
			} else { echo "&nbsp"; }
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Smarty templates dir</td>
		<td height='16' width='70%' class='listtable_1'>./smarty/templates_c
			<?php if ((isset($_POST['check']) && ($_POST['check'] == " check dirs "))) {
				if ($dir_smarty_is_dir != 1) {
					echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>";
				} else if($dir_smarty_chmod == 0) {
					echo "&nbsp;<font color=\"#ff0000\">chmod check failed, need 777.</font>"; 
				} else {
					echo "&nbsp;<font color=\"#00b266\">OK.</font>";
				}
			} else { echo "&nbsp"; } 
		?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'>

<?php

	if ((( isset($_POST['check']) && $_POST['check'] == " check dirs ") && ($checked_dirs == 1) || ($checked_dirs == 4))){
		echo "<font color=\"#ff0000\">Please fill in all required fields and check your chmod.</font>";
	} else {
		if (isset($_POST['check']) && $checked_dirs == 3) {
			echo "<font color=\"#00b266\">Directory information OK. Proceed.</font>";
		}
	}

?>

	<?php if ($checked_dirs != 3) { 
		echo "<input type='submit' name='check' value=' check dirs ' style='font-family: verdana, tahoma, arial; font-size: 10px'>"; 
	} else { 
		echo "<input type='submit' name='action' value=' step 4 ' style='font-family: verdana, tahoma, arial; font-size: 10px'>"; 
	} 
?></td>
</tr></form></table>

<?php } else if ((isset($action)) && ($action == " step 4 ")) { ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 4: Main admin information</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		Create your admin-account here. This admin will be granted all privileges (level 1). You will be able to add more admins and levels at a later stage.<br><br>
		The E-mailaddress you enter here will *not* be visible on any webpage by default. It's only used for displaying and handling error messages.

		<br><br></td>
	</tr>
	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<input type="hidden" name="action" value="<?=$_POST['action'] ?>">
	<input type="hidden" name="db_host" value="<?=$_POST['db_host'] ?>">
	<input type="hidden" name="db_name" value="<?=$_POST['db_name'] ?>">
	<input type="hidden" name="db_user" value="<?=$_POST['db_user'] ?>">
	<input type="hidden" name="db_pass" value="<?=$_POST['db_pass'] ?>">
	<input type="hidden" name="tbl_bans" value="<?=$_POST['tbl_bans'] ?>">
	<input type="hidden" name="tbl_banhistory" value="<?=$_POST['tbl_banhistory'] ?>">
	<input type="hidden" name="tbl_webadmins" value="<?=$_POST['tbl_webadmins'] ?>">
	<input type="hidden" name="tbl_amxadmins" value="<?=$_POST['tbl_amxadmins'] ?>">
	<input type="hidden" name="tbl_levels" value="<?=$_POST['tbl_levels'] ?>">
	<input type="hidden" name="tbl_admins_servers" value="<?=$_POST['tbl_admins_servers'] ?>">
	<input type="hidden" name="tbl_servers" value="<?=$_POST['tbl_servers'] ?>">
	<input type="hidden" name="tbl_logs" value="<?=$_POST['tbl_logs'] ?>">
	<input type="hidden" name="tbl_reasons" value="<?=$_POST['tbl_reasons'] ?>">
	<input type="hidden" name="tbl_comments" value="<?=$_POST['tbl_comments'] ?>">
	<input type="hidden" name="tbl_demos" value="<?=$_POST['tbl_demos'] ?>">
	<input type="hidden" name="tbl_smilies" value="<?=$_POST['tbl_smilies'] ?>">
	<input type="hidden" name="doc_root" value="<?=$_POST['doc_root'] ?>">
	<input type="hidden" name="path_root" value="<?=$_POST['path_root'] ?>">
	<input type="hidden" name="dir_import" value="<?=$_POST['dir_import'] ?>">
	<input type="hidden" name="dir_template" value="<?=$_POST['dir_template'] ?>">

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Nickname</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_nick" value="<? if (!isset($_POST['admin_nick'])) { echo "admin"; } else { print $_POST['admin_nick']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>E-mail address</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_email" value="<? if (!isset($_POST['admin_email'])) { echo "your@email.here"; } else { print $_POST['admin_email']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Password</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_pass" value="<?=isset($_POST['admin_pass']) ? $_POST['admin_pass'] : "" ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>

	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'>

<?php

	if (isset($empty_details) && $empty_details == 1){
		echo "<font color=\"#ff0000\">Please fill in all required fields.</font>";
	}

?>


		<input type='submit' name='action' value=' step 5 ' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
	</tr>
	</form>
</table>

<?php } else if ((isset($action)) && ($action == " step 5 ")) { ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 5: AMXBans config items</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		<b>Use included AMX admin manager</b><br>
		With this option you can decide to use the AMX admin manager that comes with AMXBans. Should you choose to a different method of defining admins (such as via the users.ini file per server) you should set this option to 'disabled'. We obviously recommend you check out our included AMXadmin manager (leave 'enabled'). You can easily disable it at a later stage.<br><br>
		<b>Use fancy layers</b><br>
		Setting this to 'enabled' enables visitors to 'unfold' ban_details (instead of being directed to a separate 'ban_details'-page).Please note that this functionality was only tested with Internet Explorer. You can easily disable it at a later stage should you or your users experience difficulties viewing the ban list.<br><br>
<!--		<b>Enable version-checking</b><br>
		AMXBans is frequently updated to include added functionalities and/or bugfixes. Enabling this option allows admins to see when a new version is released. If a new version becomes available, logged-in admins can see a notice on the ban_list page.<br><br>
-->		<b>Display reason on front-page</b><br>
		By default only the date, player nickname, admin and ban-length are displayed on the front-page. If you enable this option, the ban-reason will also be displayed.<br><br>
		<b>Use custom error-handler</b><br>
		You can use your own error-handler if you want. Leave this option disabled if unsure.<br><br>
		<b>Bans per page</b><br>
		Here you can set how many bans are displayed per page.

		<br><br></td>
	</tr>

	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<input type="hidden" name="action" value="<?=$_POST['action'] ?>">
	<input type="hidden" name="db_host" value="<?=$_POST['db_host'] ?>">
	<input type="hidden" name="db_name" value="<?=$_POST['db_name'] ?>">
	<input type="hidden" name="db_user" value="<?=$_POST['db_user'] ?>">
	<input type="hidden" name="db_pass" value="<?=$_POST['db_pass'] ?>">
	<input type="hidden" name="tbl_bans" value="<?=$_POST['tbl_bans'] ?>">
	<input type="hidden" name="tbl_banhistory" value="<?=$_POST['tbl_banhistory'] ?>">
	<input type="hidden" name="tbl_webadmins" value="<?=$_POST['tbl_webadmins'] ?>">
	<input type="hidden" name="tbl_amxadmins" value="<?=$_POST['tbl_amxadmins'] ?>">
	<input type="hidden" name="tbl_levels" value="<?=$_POST['tbl_levels'] ?>">
	<input type="hidden" name="tbl_admins_servers" value="<?=$_POST['tbl_admins_servers'] ?>">
	<input type="hidden" name="tbl_servers" value="<?=$_POST['tbl_servers'] ?>">
	<input type="hidden" name="tbl_logs" value="<?=$_POST['tbl_logs'] ?>">
	<input type="hidden" name="tbl_reasons" value="<?=$_POST['tbl_reasons'] ?>">
	<input type="hidden" name="tbl_comments" value="<?=$_POST['tbl_comments'] ?>">
	<input type="hidden" name="tbl_demos" value="<?=$_POST['tbl_demos'] ?>">
	<input type="hidden" name="tbl_smilies" value="<?=$_POST['tbl_smilies'] ?>">
	<input type="hidden" name="doc_root" value="<?=$_POST['doc_root'] ?>">
	<input type="hidden" name="path_root" value="<?=$_POST['path_root'] ?>">
	<input type="hidden" name="dir_import" value="<?=$_POST['dir_import'] ?>">
	<input type="hidden" name="dir_template" value="<?=$_POST['dir_template'] ?>">
	<input type="hidden" name="admin_nick" value="<?=$_POST['admin_nick'] ?>">
	<input type="hidden" name="admin_email" value="<?=$_POST['admin_email'] ?>">
	<input type="hidden" name="admin_pass" value="<?=$_POST['admin_pass'] ?>">

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Use included AMX admin manager?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='admin_management' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['admin_management'])) && ($_POST['admin_management'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if ((isset($_POST['admin_management'])) && ($_POST['admin_management'] == "disabled")) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Use fancy layers?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='fancy_layers' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['fancy_layers'])) && ($_POST['fancy_layers'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if ((isset($_POST['fancy_layers'])) && ($_POST['fancy_layers'] == "disabled")) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Enable version-checking?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='version_checking' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled'  <?php if ((isset($_POST['version_checking'])) && ($_POST['version_checking'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if ((isset($_POST['version_checking'])) && ($_POST['version_checking'] == "disabled") || (!isset($_POST['version_checking']))) { echo "selected"; } ?>>disabled</option>
		</select> leave this set to 'disabled'. is is currently not supported, maybe later.

		</td>
	</tr>
	
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Hours between webserver and game server.</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='timezone_fixx' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='0'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "0"))  { echo "selected"; } ?>>0</option>
		<option value='1'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "1"))  { echo "selected"; } ?>>+1</option>
		<option value='2'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "2"))  { echo "selected"; } ?>>+2</option>
		<option value='3'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "3"))  { echo "selected"; } ?>>+3</option>
		<option value='4'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "4"))  { echo "selected"; } ?>>+4</option>
		<option value='5'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "5"))  { echo "selected"; } ?>>+5</option>
		<option value='6'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "6"))  { echo "selected"; } ?>>+6</option>
		<option value='7'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "7"))  { echo "selected"; } ?>>+7</option>
		<option value='8'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "8"))  { echo "selected"; } ?>>+8</option>
		<option value='9'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "9"))  { echo "selected"; } ?>>+9</option>
		<option value='10' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "10")) { echo "selected"; } ?>>+10</option>
		<option value='11' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "11")) { echo "selected"; } ?>>+11</option>
		<option value='12' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "12")) { echo "selected"; } ?>>+12</option>
		<option value='-1'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-1"))  { echo "selected"; } ?>>-1</option>
		<option value='-2'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-2"))  { echo "selected"; } ?>>-2</option>
		<option value='-3'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-3"))  { echo "selected"; } ?>>-3</option>
		<option value='-4'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-4"))  { echo "selected"; } ?>>-4</option>
		<option value='-5'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-5"))  { echo "selected"; } ?>>-5</option>
		<option value='-6'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-6"))  { echo "selected"; } ?>>-6</option>
		<option value='-7'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-7"))  { echo "selected"; } ?>>-7</option>
		<option value='-8'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-8"))  { echo "selected"; } ?>>-8</option>
		<option value='-9'  <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-9"))  { echo "selected"; } ?>>-9</option>
		<option value='-10' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-10")) { echo "selected"; } ?>>-10</option>
		<option value='-11' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-11")) { echo "selected"; } ?>>-11</option>
		<option value='-12' <?php if ((isset($_POST['timezone_fixx'])) && ($_POST['timezone_fixx'] == "-12")) { echo "selected"; } ?>>-12</option>
		</select>

		</td>
	</tr>
	
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Should public users be able to use search?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='display_search' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['display_search'])) && ($_POST['display_search'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['display_search'])) && ($_POST['display_search'] == "disabled"))) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>
	
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Display admin nick for public users on front-page?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='display_admin' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['display_admin'])) && ($_POST['display_admin'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['display_admin'])) && ($_POST['display_admin'] == "disabled"))) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Display reason on front-page?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='display_reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['display_reason'])) && ($_POST['display_reason'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['display_reason'])) && ($_POST['display_reason'] == "disabled"))) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Use custom error handler?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='error_handler' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['error_handler'])) && ($_POST['error_handler'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['error_handler'])) && ($_POST['error_handler'] == "disabled")) || (!isset($_POST['error_handler']))) { echo "selected"; } ?>>disabled</option>
		</select> leave this set to 'disabled' unless you know what you are doing.

		</td>
	</tr>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Error Handler</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="error_handler_path" value="<? if (!isset($_POST['error_handler_path'])) { print (isset($_SERVER['DOCUMENT_ROOT']) ? $_SERVER['DOCUMENT_ROOT'] : "").(isset($docroot) ? $docroot : "")."/include/error_handler.inc.php"; } else { print $_POST['error_handler_path']; } ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 300px"><? if ((isset($_POST['check']) && $_POST['check'] == " check dirs ") && ($path_root_is_dir != 1)) { echo "&nbsp;<font color=\"#ff0000\">Directory does not exist or is invalid.</font>"; } ?></td>
	</tr>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Bans per page</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='bans_amount' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='10' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "10")) { echo "selected"; } ?>>10</option>
		<option value='20' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "20")) { echo "selected"; } ?>>20</option>
		<option value='30' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "30")) { echo "selected"; } ?>>30</option>
		<option value='40' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "40")) { echo "selected"; } ?>>40</option>
		<option value='50' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "50")) { echo "selected"; } ?>>50</option>
		<option value='60' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "60")) { echo "selected"; } ?>>60</option>
		<option value='70' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "70")) { echo "selected"; } ?>>70</option>
		<option value='80' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "80")) { echo "selected"; } ?>>80</option>
		<option value='90' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "90")) { echo "selected"; } ?>>90</option>
		<option value='100' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "100")) { echo "selected"; } ?>>100</option>
		<option value='150' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "150")) { echo "selected"; } ?>>150</option>
		<option value='200' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "200")) { echo "selected"; } ?>>200</option>
		<option value='250' <?php if ((isset($_POST['bans_amount'])) && ($_POST['bans_amount'] == "250")) { echo "selected"; } ?>>250</option>
		</select>

		</td>
	</tr>
<!--############ demo and comment ###########-->
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Show comments?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='display_comments' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['display_comments'])) && ($_POST['display_comments'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['display_comments'])) && ($_POST['display_comments'] == "disabled"))) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Show demos?</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name='display_demos' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'>
		<option value='enabled' <?php if ((isset($_POST['display_demos'])) && ($_POST['display_demos'] == "enabled")) { echo "selected"; } ?>>enabled</option>
		<option value='disabled' <?php if (((isset($_POST['display_demos'])) && ($_POST['display_demos'] == "disabled"))) { echo "selected"; } ?>>disabled</option>
		</select>

		</td>
	</tr>
<!--######################################-->
	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'>

<?php

	if ( isset($empty_details) && $empty_details == 1){
		echo "<font color=\"#ff0000\">Please fill in all required fields.</font>";
	}

?>

		<input type='submit' name='action' value=' finalize ' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
	</tr>
	</form>
</table>

<?php } else if ((isset($action)) && ($action == " finalize ")) { ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 6: Create objects/tables</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		Level 1 will be created and the admin you entered earlier will be assigned this level. The file config.inc.php will be created. If you are upgrading from a previous version, and you are getting 'failed' on creating the level and webadmin; this is caused by the fact that level 1 an the specified webadmin allready exists in the database. 

		<br><br></td>
	</tr>


<?php

	$config->document_root		= $_POST['doc_root'];
	$config->path_root		= $_POST['path_root'];
	$config->importdir		= $_POST['dir_import'];
	$config->templatedir		= $_POST['dir_template'];

	$config->db_host			= $_POST['db_host'];
	$config->db_name			= $_POST['db_name'];
	$config->db_user			= $_POST['db_user'];
	$config->db_pass			= $_POST['db_pass'];

	$config->bans			= $_POST['tbl_bans'];
	$config->ban_history		= $_POST['tbl_banhistory'];
	$config->webadmins		= $_POST['tbl_webadmins'];
	$config->amxadmins		= $_POST['tbl_amxadmins'];
	$config->amxcomments		= $_POST['tbl_comments']; 
	$config->amxdemos			= $_POST['tbl_demos'];
	$config->amxsmilies			= $_POST['tbl_smilies'];
	$config->levels			= $_POST['tbl_levels'];
	$config->admins_servers		= $_POST['tbl_admins_servers'];
	$config->servers			= $_POST['tbl_servers'];
	$config->logs			= $_POST['tbl_logs'];
	$config->reasons			= $_POST['tbl_reasons'];

	$config->admin_nickname		= $_POST['admin_nick'];
	$config->admin_email		= $_POST['admin_email'];

	$config->error_handler		= $_POST['error_handler'];
	$config->error_handler_path	= $_POST['error_handler_path'];

	$config->admin_management	= $_POST['admin_management'];

	$config->fancy_layers		= $_POST['fancy_layers'];

	$config->version_checking	= $_POST['version_checking'];

	$config->bans_per_page		= $_POST['bans_amount'];

	$config->display_search 	= $_POST['display_search'];
	
	$config->timezone_fixx 		= $_POST['timezone_fixx'];
	
	$config->display_admin 		= $_POST['display_admin'];
	
	$config->display_reason		= $_POST['display_reason'];
	$config->display_comments	= $_POST['display_comments']; 
	$config->display_demo		= $_POST['display_demos']; 
	$config->demo_maxsize		= "2";

	$config->disable_frontend	= "false";
	$config->rcon_class = "two";
	$config->geoip = "enabled";
	$config->autopermban_count = "disabled";

	$link		= @mysql_connect($config->db_host, $config->db_user, $config->db_pass);
	$db_selected	= @mysql_select_db($config->db_name, $link);
	$insert_level 	= @mysql_query("INSERT INTO $config->levels VALUES ('1', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes')");
	$pass		= md5($_POST['admin_pass']);
	$insert_admin 	= @mysql_query("INSERT INTO $config->webadmins (username, password, level) VALUES ('$config->admin_nickname', '$pass', '1')");

	if (!$insert_level) {
		$insert_level_error = 1;
	} else {
		$insert_level_error = 0;
	}

	if (!$insert_admin) {
		$insert_admin_error = 1;
	} else {
		$insert_admin_error = 0;
	}

?>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Creating default level (1)</td>
		<td height='16' width='70%' class='listtable_1'><? if ($insert_level_error == 0) { echo "<font color=\"#00b266\">Succeeded</font>"; } else { echo "<font color=\"#ff0000\">Failed (Can be because an account already exist and you are upgrading)</font>"; } ?></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Inserting Webadmin <?=$_POST['admin_nick'] ?></td>
		<td height='16' width='70%' class='listtable_1'><? if ($insert_level_error == 0) { echo "<font color=\"#00b266\">Succeeded</font>"; } else { echo "<font color=\"#ff0000\">Failed (Can be because an account already exist and you are upgrading)</font>"; } ?></td>
	</tr>

<?php

	$disclaimer = "
/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
 *
 *	web		: http://www.xs4all.nl/~yomama/amxbans/
 *	mail	: yomama@xs4all.nl
 *	ICQ		: 104115504
 *   
 *  AMXBans 5.1 developed by the new AMXBans dev team:
 *
 *  web          : http://www.amxbans.de
 *
 *  Main Developer
 *
 *  Setoy        : http://www.yari-serve.de          web/php
 *  |PJ|ShOrTy   : http://www.prostjumsen.de         web/php/amxmodx
 *                 shorty@prostjumsen.de
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
";

	$security_fix = "
if (!get_magic_quotes_gpc()) { 
   \$_POST = addslashes(\$_POST); 
   \$_GET = addslashes(\$_GET); 
} 
// fix text to display 
\$_POST = str_replace(\"\'\", \"\", \$_POST); 
\$_POST = str_replace(\"\\\"\", \"\", \$_POST); 
\$_POST = str_replace(\"\\\\\", \"\", \$_POST); 

\$_GET = str_replace(\"\'\", \"\", \$_GET); 
\$_GET = str_replace(\"\\\"\", \"\", \$_GET); 
\$_GET = str_replace(\"\\\\\", \"\", \$_GET);
";


	$smarty_meuk = "

/* Don't edit below this line */
\$config->update_url = \"http://www.amxbans.de\";
\$config->php_version = \"$php_version\";
\$config->default_lang = \"english\";

/* Smarty settings */
define(\"SMARTY_DIR\", \$config->path_root.\"/smarty/\");

require(SMARTY_DIR.\"Smarty.class.php\");

class dynamicPage extends Smarty {
	function dynamicPage() {

		global \$config;

		\$this->Smarty();

		\$this->template_dir = \$config->templatedir;
		\$this->compile_dir	= SMARTY_DIR.\"templates_c/\";
		\$this->config_dir	= SMARTY_DIR.\"configs/\";
		\$this->cache_dir	= SMARTY_DIR.\"cache/\";
		\$this->caching		= FALSE;

		\$this->assign(\"app_name\",\"dynamicPage\");
	}
}

?>";

	$arr	= get_object_vars($config);
	$fp	= fopen("$config->path_root/include/config.inc.php", "w");

	if (!fopen("$config->path_root/include/config.inc.php", "w")) {
		$config_fail = 1;
	} else {
		$config_fail = 0;
	}

	fwrite($fp, "<?php\n");
	fwrite($fp, $disclaimer);
	fwrite($fp, $security_fix);
	
	fwrite($fp, "\n\n");

	while (list($prop, $val) = each($arr)) {
		fwrite($fp, "\$config->$prop = \"$val\";\n");
	}

	fwrite($fp, $smarty_meuk);
	fclose($fp);

?>

	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Writing config file</td>
		<td height='16' width='70%' class='listtable_1'><? if ($config_fail == 0) { echo "<font color=\"#00b266\">Succeeded</font>"; } else { echo "<font color=\"#ff0000\">Failed (Enable write permission on the include folder and smarty/templates_c)</font>"; } ?></td>
	</tr>
	
	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<input type="hidden" name="action" value="<?=$_POST['action'] ?>">
	<input type="hidden" name="doc_root" value="<?=$_POST['doc_root'] ?>">
	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'>

<?php

	if (isset($empty_details) && $empty_details == 1){
		echo "<font color=\"#ff0000\">Please fill in all required fields.</font>";
	}

?>


      <input type='submit' name='action' value=' proceed to AMXBans ' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
    </tr>
  </form>
</table>

<?php } else { ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>AMXBans Setup - Step 1: Database information</b></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td colspan='2' class='listtable_1'><br>

		This is where you enter Database information. The Database server can be entered either as hostname or IP-address. Make sure that the user has create database privileges. Also make sure that this user has the required privileges to connect from this host. For more infomation on how to add users, please check out:<br><br> <a href="http://dev.mysql.com/doc/mysql/en/Adding_users.html" target="_new">http://dev.mysql.com/doc/mysql/en/Adding_users.html</a>.

		<br><br></td>
	</tr>

	<form name="section" method="post" action="<?=$_SERVER['PHP_SELF'] ?>">
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>Database server</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="db_host" value="<?= isset($_POST['db_host']) ? $_POST['db_host'] : "" ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>DB Name</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="db_name" value="<?=isset($_POST['db_name']) ? $_POST['db_name'] : "" ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>DB Username</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="db_user" value="<?=isset($_POST['db_host']) ? $_POST['db_user'] : "" ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' width='30%' class='listtable_1'>DB Password</td>
		<td height='16' width='70%' class='listtable_1'><input type="password" name="db_pass" value="<?=isset($_POST['db_host']) ? $_POST['db_pass'] : "" ?>" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 150px"></td>
	</tr>
	<tr bgcolor="#D3D8DC">
		<td height='16' class='listtable_1' colspan='2' align='right'>

<?php

	if ((isset($_POST['check'])) && ($_POST['check'] == " check connection ")) {
		if ($dblogin == 0) {
			echo "<font color=\"#ff0000\">Please fill in all required fields.</font>";
		} else if ($dblogin == 1) {
			echo "<font color=\"#ff0000\">Can't connect to server. Please check your connection details and try again.</font>";
		} else if($dblogin == 2) {
			echo "<font color=\"#ff0000\">Database '".$_POST['db_name']."' is not accessible. Please create database '".$_POST['db_name']."' first, and try again.</font>";
		} else {
			echo "<font color=\"#00b266\">DB details OK. Proceed.</font>";
		}
	}

?>

<?php if ((!isset($dblogin)) || ($dblogin != 3)) { echo "<input type='submit' name='check' value=' check connection ' style='font-family: verdana, tahoma, arial; font-size: 10px'>"; } if ((isset($_POST['check']) && ($_POST['check'] == " check connection ")) && (isset($dblogin) && ($dblogin == 3))) { echo "<input type='submit' name='action' value=' step 2 ' style='font-family: verdana, tahoma, arial; font-size: 10px'>"; } ?></td>
	</tr>
	</form>
</table>

<?php } ?>

				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</body>

</html>
