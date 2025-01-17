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
require("include/config.inc.php");

if ($config->error_handler == "enabled") {
	include("$config->error_handler_path");
}
require("$config->path_root/include/functions.lang.php");
require("$config->path_root/include/functions.inc.php");

if ($_GET['msg'] == "frontend_disabled") {
	$message = lang("_ERRORAMXBANSDISABLED");
} else if ($_GET['msg'] == "setupfile_exists") {
	$message = lang("_ERRORSETUPPHP");
} else if ($_GET['msg'] == "magicquotes_off") {
	$message = lang("_ERRORMAGICQUOTES");
} else {
	$message = "unknown";
}

/*
 * Template parsing
 */


$title			= lang("_UNAVAILABLE");

$smarty = new dynamicPage;

$smarty->assign("meta","");
$smarty->assign("title",$title);
$smarty->assign("dir",$config->document_root);
$smarty->assign("message",$message);

$smarty->display('unavailable.tpl');

?>