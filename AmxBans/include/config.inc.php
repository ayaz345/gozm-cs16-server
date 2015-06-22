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

if (!get_magic_quotes_gpc()) {
  if (isset($_POST)) {
    foreach ($_POST as $key => $value) {
      $_POST[$key] = $value;
    }
  }

  if (isset($_GET)) {
    foreach ($_GET as $key => $value) {
      $_GET[$key] = $value;
    }
  }
}

/*
if (!get_magic_quotes_gpc()) {
   $_POST = addslashes($_POST);
   $_GET = addslashes($_GET);
}
// fix text to display
$_POST = str_replace("\'", "", $_POST);
$_POST = str_replace("\"", "", $_POST);
$_POST = str_replace("\\", "", $_POST);

$_GET = str_replace("\'", "", $_GET);
$_GET = str_replace("\"", "", $_GET);
$_GET = str_replace("\\", "", $_GET);
*/

$config->document_root = "";
$config->path_root = "/var/www/gozm/data/www/gozm.myarena.ru";
$config->importdir = "/var/www/gozm/data/www/gozm.myarena.ru/tmp";
$config->templatedir = "/var/www/gozm/data/www/gozm.myarena.ru/templates";
$config->db_host = "db1.myarena.ru";
$config->db_name = "gozm_gozm";
$config->db_user = "gozm_admin";
$config->db_pass = "petyx";
$config->stats_table_players = "bio_players";
$config->stats_select_players = "SELECT * FROM (SELECT *, (@_c := @_c + 1) AS `rank`, ((`infect` + `zombiekills`*2 + `humankills` + `knife_kills`*5 + `best_zombie` + `best_human` + `escape_hero`*3 + `best_player`*10) / (`infected` + `death` + 300)) AS `skill` FROM (SELECT @_c := 0) r, `".$config->stats_table_players."` ORDER BY `skill` DESC) AS `newtable` WHERE `rank` <= 100 ORDER BY `rank` LIMIT 100;";
$config->stats_table_maps = "bio_maps";
$config->stats_select_maps = "SELECT `map`, `games` from `".$config->stats_table_maps."` ORDER BY `games` DESC;";
$config->bans = "amx_bans";
$config->ban_history = "amx_banhistory";
$config->webadmins = "amx_webadmins";
$config->amxadmins = "amx_amxadmins";
$config->amxcomments = "amx_comments";
$config->amxdemos = "amx_demos";
$config->amxsmilies = "amx_smilies";
$config->levels = "amx_levels";
$config->admins_servers = "amx_admins_servers";
$config->servers = "amx_serverinfo";
$config->logs = "amx_logs";
$config->reasons = "amx_banreasons";
$config->admin_nickname = "Dimka";
$config->admin_email = "vk.com/go_zombie";
$config->error_handler = "disabled";
$config->error_handler_path = "/var/www/gozm/data/www/gozm.myarena.ru/include/error_handler.inc.php";
$config->admin_management = "enabled";
$config->fancy_layers = "enabled";
$config->version_checking = "disabled";
$config->bans_per_page = "25";
$config->display_search = "enabled";
$config->timezone_fixx = "0";
$config->display_admin = "enabled";
$config->display_reason = "enabled";
$config->display_comments = "disabled";
$config->display_demo = "disabled";
$config->demo_maxsize = "100";
$config->disable_frontend = "false";
$config->rcon_class = "two";
$config->geoip = "enabled";
$config->autopermban_count = "disabled";
$config->update_url = "http://www.amxbans.de";
$config->php_version = "5.1b";
$config->default_lang = "russian";


/* Smarty settings */
define("SMARTY_DIR", $config->path_root."/smarty/");

require(SMARTY_DIR."Smarty.class.php");

class dynamicPage extends Smarty {
	function dynamicPage() {

		global $config;

		$this->Smarty();

		$this->template_dir	= $config->templatedir;
		$this->compile_dir	= SMARTY_DIR."templates_c/";
		$this->config_dir	= SMARTY_DIR."configs/";
		$this->cache_dir	= SMARTY_DIR."cache/";
		$this->caching		= FALSE;

		$this->assign("app_name","dynamicPage");
	}
}

?>