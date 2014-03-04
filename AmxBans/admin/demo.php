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
session_start();

// Require basic site files
require("../include/config.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

include("$config->path_root/include/functions.lang.php");
include("$config->path_root/include/accesscontrol.inc.php");

if($_SESSION['bans_add'] != "yes") {
	echo "You do not have the required credentials to view this page.";
	exit();
}

if(isset($_POST['bid'])){$did = $_POST['bid'];}else{$did = $_GET['bid'];}

		$resourcec	= mysql_query("SELECT id, bid, demo, comment FROM $config->amxdemos WHERE bid = '" . $did . "'") or die(mysql_error());
		$demos	= array();

	while($results = mysql_fetch_object($resourcec)) {
	$id		= $results->id;
	$bid		= $results->bid;
	$demo		= $results->demo;
	$comment	= $results->comment;

			$demos_info = array(
				"did"	=> $id,
				"bid"  => $bid,
				"demo" => $demo,
				"comment" => $comment
				);
			$demos	[]= $demos_info;
}
if(isset($_POST['bid'])){$did = $_POST['bid'];}else{$did = $_GET['bid'];}

if ((isset($_POST['action'])) && ($_POST['action'] == "insert")) {

ini_set("post_max_size",$config->demo_maxsize."M");

$filename = $_FILES['userfile']['name'];
$file = $_FILES['userfile']['tmp_name'];
$attach_filename = strtolower($filename);
$_FILES['userfile']['name'] = strtolower($_FILES['userfile']['name']);

$_FILES['userfile']['name'] = str_replace(" ", "_", $_FILES['userfile']['name']);
$attach_filename = str_replace(" ", "_", $attach_filename);

$upload_dir = "$config->path_root/demos/";

if (is_file("$upload_dir$attach_filename") ){
			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_ERROR_FILE_EXIST") . "<br>";
			echo lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url/admin/demo.php?bid=$bid'\">";
			exit();
}
if (move_uploaded_file($_FILES[userfile]['tmp_name'], $upload_dir . $_FILES['userfile']['name'])) {
chmod($upload_dir . $_FILES['userfile']['name'], 0644);

if(isset($_POST['bid'])){$did = $_POST['bid'];}else{$did = $_GET['bid'];}

			$insert = mysql_query("INSERT INTO $config->amxdemos VALUES ('', '".$did."', '".$attach_filename."', '".$_POST['comment']."','')") or die (mysql_error());
			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_FILE") . " $attach_filename " . lang("_UPLOADED") . "<br>";
			echo lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url/admin/demo.php?bid=$did'\">";
			exit();
} else {
			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_ERROR_UPLOAD") . "<br>";
			echo lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url/admin/demo.php?bid=$did'\">";
			exit();
}
}

if(isset($_POST['delete'])) {

	$filename = $_POST['demo'];
	$filename = basename($filename);

	$upload_dir = "$config->path_root/demos/";
	$del_file = "$upload_dir$filename";
	$deleted = @unlink($del_file);

$delete = mysql_query("DELETE FROM $config->amxdemos WHERE id = '".$_POST['did']."'") or die (mysql_error());
			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_FILE") . " $filename " . lang("_FILE_DELETED") . "<br>";
			echo lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url/admin/demo.php?bid=$bid'\">";
			exit();
}

if ((isset($_POST['action'])) && ($_POST['action'] == "edit")) {
		$update = mysql_query("UPDATE $config->amxdemos SET demo = '".$_POST['demo']."', comment = '".$_POST['comment']."' WHERE id = '".$_POST['did']."'") or die (mysql_error());

			$url		= "$config->document_root";
			$delay	= "2";
			echo lang("_DEMO_UPDATED") . "<br>";
			echo lang("_REDIRECT");
			echo "<meta http-equiv=\"refresh\" content=\"".$delay.";url='http://".$_SERVER["HTTP_HOST"]."$url/admin/demo.php?bid=$did'\">";
			exit();
}

/*
 *
 * 		Template parsing
 *
 */

// Header
$title = lang("_DEMOCP");

// Section
$section = "demos";

// Parsing
$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("section",$section);
$smarty->assign("dir",$config->document_root);
$smarty->assign("this",$_SERVER['PHP_SELF']);
$smarty->assign("bid",$did);
$smarty->assign("demos",$demos);
$smarty->display('main_header.tpl');
$smarty->display('demo.tpl');
$smarty->display('main_footer.tpl');

?>