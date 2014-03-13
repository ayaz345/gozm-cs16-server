{php}
CheckFrontEndState();

if(isset($_COOKIE["amxbans"])) {
	ReadSessionFromCookie();
}
{/php}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>AMXBans - {$title}</title>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
<meta name="Keywords" content="" />
<meta name="Description" content="" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
<link rel="stylesheet" type="text/css" href="{$dir}/include/amxbans.css" />
<script type="text/javascript" language="JavaScript" src="{$dir}/layer.js"></script>

</head>

<body>

<!--div id="header"><a href="http://amxbans.forteam.ru{$dir}"><img src="{$dir}/images/logo.png" /></a></div>
<div class="line-h"></div-->

<div id="menu">
	<!--div class="r"></div-->
	<!--div class="l"></div-->
	<div class="c">
		<table cellspacing='1' width='100%'>
		
		<tr>
	
			<td aling=left style="padding-left:20px;">
			<form name="setlang" action="{$dir}/ban_list.php" method="POST" style="margin: 0px">
	{assign var="lang" value=$true|getlanguage}
	{assign var="select_lang" value=$true|selectlang:"session"}
	{assign var="default_lang" value=$true|selectlang:"config"}

	<select name="newlang" style="background: #fff; font-family:tahoma, arial; font-size: 11px; color:#6e6e6e;" onchange="this.form.submit()">
	{foreach from=$lang item="lang"}
	<option value="{$lang|escape}" {if empty($select_lang) && $default_lang == $lang}selected{/if} {if $select_lang == $lang}selected{/if}>{$lang|escape}</option>
	{/foreach}
	</select>
	</form>	
	</td>
			<td align='right' style="padding-right:20px;">
			<form action="none" name="navigator">
			{php}global $config; if($config->disable_frontend == "true") { echo "<font color=\"#ff0000\">AMXBans frontend is currently disabled!</font>"; }{/php}
			<select name="nav" style="background: #fff; font-family:tahoma, arial; font-size: 11px; color:#6e6e6e;"  onchange="openURI()">
			<option value='{$dir}/' {if $section != "banlist"}selected{/if}>{"_HOME"|lang}</option>
			<option value='{$dir}/ban_list.php' {if $section == "banlist"}selected{/if}>{"_BANLIST"|lang}</option>
			<option value='{$dir}/admins_list.php' {if $section == "Serveradmins"}selected{/if}>{"_ADMLIST"|lang}</option>
			{if ($smarty.session.bans_add == "yes")}
			<option value='{$dir}/admin/add_ban.php' {if $section == "addban"}selected{/if}>{"_ADDBAN"|lang}</option>
			<option value='{$dir}/admin/add_live_ban.php' {if $section == "addliveban"}selected{/if}>{"_ADDLIVEBAN"|lang}</option>{/if}
			{if $display_search == "enabled" || ($smarty.session.bans_add == "yes")}<option value='{$dir}/ban_search.php' {if $section == "search"}selected{/if}>{"_SEARCH"|lang}</option>{/if}
			{if ($smarty.session.bans_import == "yes")}<option value='{$dir}/admin/import_bans.php' {if $section == "import"}selected{/if}>{"_IMPORT"|lang}</option>{/if}
			{if ($smarty.session.bans_export == "yes")}<option value='{$dir}/export_bans.php' {if $section == "export"}selected{/if}>{"_EXPORT"|lang}</option>{/if}
			{if ($smarty.session.prune_db == "yes")}<option value='{$dir}/admin/prune_db.php' {if $section == "prune"}selected{/if}>{"_PRUNEDB"|lang}</option>{/if}
			{if ($smarty.session.amxadmins_edit == "yes" || $smarty.session.webadmins_edit == "yes" || $smarty.session.permissions_edit == "yes")}<option value='{$dir}/admin/admins_levels.php' {if $section == "admins_levels"}selected{/if}>{"_ADMINSLEVELS"|lang}</option>{/if}
			{if ($smarty.session.amxadmins_edit == "yes" && $smarty.session.permissions_edit == "yes")}<option value='{$dir}/admin/server_admins.php' {if $section == "server_admins"}selected{/if}>{"_SERVERADMINS"|lang}</option>{/if}
			{if ($smarty.session.servers_edit == "yes")}<option value='{$dir}/admin/servers.php' {if $section == "servers"}selected{/if}>{"_SERVERS"|lang}</option>{/if}
			{if ($smarty.session.bans_add == "yes" && $smarty.session.bans_import == "yes" && $smarty.session.bans_export == "yes" && $smarty.session.webadmins_edit == "yes" && $smarty.session.prune_db == "yes" && $smarty.session.amxadmins_edit == "yes" && $smarty.session.permissions_edit == "yes")}<option value='{$dir}/admin/cfg.php' {if $section == "config"}selected{/if}>{"_CONFIG"|lang}</option><option value='{$dir}/admin/log_search.php' {if $section == "logs"}selected{/if}>{"_ACCESSLOG"|lang}</option>{/if}
			</select>
			<span class="m">|</span>
			{if isset($smarty.session.uid)}{"_LOGGED"|lang}: {$smarty.session.uid} [<a href='{$dir}/logout.php'>{"_LOGOUT"|lang}</a>]{else}{"_NOTLOGGED"|lang} [<a href='{$dir}/login.php'>{"_LOGIN"|lang}</a>]{/if}			
			</form>
			
			
			</td>
			
			
		</tr>
		
	</table>
	
	</div>
	
</div>

<table border='0' cellpadding='0' cellspacing='0' width='100%'>
  <tr>
    <td width='100%' valign='top' style='padding: 0px 20px 20px 20px'>
    <table border='0' cellpadding='0' cellspacing='0' width='100%'>
      
	<tr>
		<td>&nbsp;</td>
	</tr>
	  
      <tr>
        <td>

        