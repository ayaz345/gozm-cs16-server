<?php
/*
 *
 *  AMXBans, managing bans for Half-Life modifications
 *  Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
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
 */

@session_start();

require("$config->path_root/include/functions.inc.php");

if( $_SERVER['REQUEST_METHOD'] == 'POST')
    if(!preg_match('!^http(s)?://' . preg_quote($_SERVER['HTTP_HOST']) . '!i', $_SERVER['HTTP_REFERER']))
        exit;

$uid = mysql_real_escape_string($_POST['uid']);
$pwd = mysql_real_escape_string($_POST['pwd']);
$uip = $_SERVER['REMOTE_ADDR'];

if (empty($uid)) $uid = $_SESSION['uid'];
if (empty($pwd)) $pwd = $_SESSION['pwd'];

if(isset($_COOKIE["amxbans"])) {
	$cook			= explode(":", $_COOKIE["amxbans"]);
	$uid			= $cook[0];
	$pwd			= $cook[1];
	$lvl			= $cook[2];
	$uip			= $cook[3];
	$logcode		= $cook[4];
	$bans_add		= $cook[5];
	$bans_edit		= $cook[6];
	$bans_delete		= $cook[7];
	$bans_unban		= $cook[8];
	$bans_import		= $cook[9];
	$bans_export		= $cook[10];
	$amxadmins_view		= $cook[11];
	$amxadmins_edit		= $cook[12];
	$webadmins_view		= $cook[13];
	$webadmins_edit		= $cook[14];
	$permissions_edit	= $cook[15];
	$prune_db		= $cook[16];
	$servers_edit		= $cook[17];
	$ip_view		= $cook[18];
}
if(empty($uid)) {
	$_SESSION['uid'] = "";
	$_SESSION['pwd'] = "";
	$_SESSION['logcode'] = "";
	
	$title	= "Login";

	$smarty = new dynamicPage;

	$smarty->assign("meta","");
	$smarty->assign("title",$title);
	$smarty->assign("dir",$config->document_root);
	$smarty->assign("this",$_SERVER['PHP_SELF']);
	$smarty->display('main_header.tpl');
	$smarty->display('login.tpl');
	$smarty->display('main_footer.tpl');
	
	exit;
}

if(isset($_COOKIE["amxbans"])) {
	$sql = "SELECT * FROM $config->webadmins AS wa LEFT JOIN $config->levels AS le ON wa.level=le.level WHERE username = '$uid' AND password = '$pwd' AND logcode = '$logcode'";
} else {
	$sql = "SELECT * FROM $config->webadmins AS wa LEFT JOIN $config->levels AS le ON wa.level=le.level WHERE username = '$uid' AND password = md5('$pwd')";
}
$result = mysql_query($sql);
if (!$result)
{
	echo "A database error occurred while checking your login details.<br>Please contact an adminstrator.";
	exit;
}

if (mysql_num_rows($result) == 0)
{	
	$_SESSION['uid'] = "";
	$_SESSION['pwd'] = "";
	$_SESSION['logcode'] = "";
	
	$title	= "Login";

	$smarty = new dynamicPage;

	$smarty->assign("meta","");
	$smarty->assign("title",$title);
	$smarty->assign("dir",$config->document_root);
	$smarty->assign("this",$_SERVER['PHP_SELF']);
	$smarty->display('main_header.tpl');
	echo "<br><font color='#ff0000'><b>Your username or password is incorrect, or you are not an admin.</b></font><br><br>";
	$smarty->display('login.tpl');
	$smarty->display('main_footer.tpl');
	
	$now = date("U");
	$add_log	= mysql_query("INSERT INTO $config->logs (timestamp,ip,username,action,remarks) VALUES ('$now', '$uip', 'unknown', 'admin logins', '$uid failed to login')") or die (mysql_error());
	
	exit;
	}

while ($my_admin = mysql_fetch_array($result))
{
	$lvl			= isset($my_admin['level']) ? $my_admin['level'] : "";
	$bans_add		= $my_admin['bans_add'];
	$bans_edit		= $my_admin['bans_edit'];
	$bans_delete	= $my_admin['bans_delete'];
	$bans_unban		= $my_admin['bans_unban'];
	$bans_import		= $my_admin['bans_import'];
	$bans_export		= $my_admin['bans_export'];
	$amxadmins_view		= $my_admin['amxadmins_view'];
	$amxadmins_edit	= $my_admin['amxadmins_edit'];
	$webadmins_view	= $my_admin['webadmins_view'];
	$webadmins_edit		= $my_admin['webadmins_edit'];
	$permissions_edit	= $my_admin['permissions_edit'];
	$prune_db	= $my_admin['prune_db'];
	$servers_edit		= $my_admin['servers_edit'];
	$ip_view		= $my_admin["ip_view"];

	
	
	if(isset($_POST['remember']) && ($_POST['remember']=="rememberme")) {
	
		$logcode	= md5(GenerateString(8));
		$res		= mysql_query("UPDATE $config->webadmins SET logcode = '$logcode' WHERE username = '$uid'");
		$pwdhash	= md5($pwd);
		$cookiestring	= $uid.":".$pwdhash.":".$lvl.":".$uip.":".$logcode.":".$bans_add.":".$bans_edit.":".$bans_delete.":".$bans_unban.":".$bans_import.":".$bans_export.":".$amxadmins_view.":".$amxadmins_edit.":".$webadmins_view.":".$webadmins_edit.":".$permissions_edit.":".$prune_db.":".$servers_edit.":".$ip_view;
		
		$savecookie=setcookie("amxbans", $cookiestring, time()+60*60*24*7,$config->document_root,$_SERVER['SERVER_NAME']);
		
	}
	
	$_SESSION['uid'] = $uid;
	$_SESSION['pwd'] = $pwd;
	$_SESSION['uip'] = $uip;	
	$_SESSION['lvl'] = $lvl;
	$_SESSION['userid'] = $userid;
	$_SESSION['bans_add'] = $bans_add;
	$_SESSION['bans_edit'] = $bans_edit;
	$_SESSION['bans_delete'] = $bans_delete;
	$_SESSION['bans_unban'] = $bans_unban;
	$_SESSION['bans_import'] = $bans_import;
	$_SESSION['bans_export'] = $bans_export;
	$_SESSION['amxadmins_view'] = $amxadmins_view;
	$_SESSION['amxadmins_edit'] = $amxadmins_edit;
	$_SESSION['webadmins_view'] = $webadmins_view;
	$_SESSION['webadmins_edit'] = $webadmins_edit;
	$_SESSION['permissions_edit'] = $permissions_edit;
	$_SESSION['prune_db'] = $prune_db;
	$_SESSION['servers_edit'] = $servers_edit;
	$_SESSION['ip_view'] = $ip_view;
}
?>
