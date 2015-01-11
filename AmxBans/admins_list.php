<?php
// Start session
@session_start();

//security fix
$amxadmins_array=array();

// Require basic site files
require("include/config.inc.php");
require("$config->path_root/include/functions.lang.php");
require("$config->path_root/include/functions.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}

$resource	= mysql_query(
	"SELECT admins.id, admins.access, admins.nickname, players.last_seen
    FROM $config->amxadmins AS admins
	LEFT JOIN bio_players AS players ON BINARY admins.nickname = players.nick
	WHERE ashow = '1'
    ORDER BY access, id ASC"
	) or die(mysql_error());

while($result = mysql_fetch_object($resource)) {
        $time = $result->last_seen;
        if ($time) {
            $date = date("d-m-Y [H:i]", $time);
        }
        else
            $date = "(более мес€ца назад)";

		$amxadmins_info = array(
			"access"	=> $result->access,
			"nickname"	=> $result->nickname,
			"time"		=> $date
			);
	
		$amxadmins_array[] = $amxadmins_info;
}

/*
 *
 * Template parsing
 *
 */

$title	= "Serveradmins";
$section = "Serveradmins";
$smarty	= new dynamicPage;

$smarty->assign("this",$_SERVER['PHP_SELF']);

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("section",$section);
$smarty->assign("working_title","home");
$smarty->assign("dir",$config->document_root);

$smarty->assign("amxadmin",isset($amxadmins_array) ? $amxadmins_array : "");

$smarty->display('main_header.tpl');
$smarty->display('admins_list.tpl');
$smarty->display('main_footer.tpl');

?>