<?php /* Smarty version 2.6.14, created on 2014-03-11 16:34:08
         compiled from main_header.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'getlanguage', 'main_header.tpl', 39, false),array('modifier', 'selectlang', 'main_header.tpl', 40, false),array('modifier', 'escape', 'main_header.tpl', 45, false),array('modifier', 'lang', 'main_header.tpl', 54, false),)), $this); ?>
<?php 
CheckFrontEndState();

if(isset($_COOKIE["amxbans"])) {
	ReadSessionFromCookie();
}
 ?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>AMXBans - <?php echo $this->_tpl_vars['title']; ?>
</title>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
<meta name="Keywords" content="" />
<meta name="Description" content="" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
<link rel="stylesheet" type="text/css" href="<?php echo $this->_tpl_vars['dir']; ?>
/include/amxbans.css" />
<script type="text/javascript" language="JavaScript" src="<?php echo $this->_tpl_vars['dir']; ?>
/layer.js"></script>

</head>

<body>

<!--div id="header"><a href="http://amxbans.forteam.ru<?php echo $this->_tpl_vars['dir']; ?>
"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/logo.png" /></a></div>
<div class="line-h"></div-->

<div id="menu">
	<!--div class="r"></div-->
	<!--div class="l"></div-->
	<div class="c">
		<table cellspacing='1' width='100%'>
		
		<tr>
	
			<td aling=left style="padding-left:20px;">
			<form name="setlang" action="<?php echo $this->_tpl_vars['dir']; ?>
/ban_list.php" method="POST" style="margin: 0px">
	<?php $this->assign('lang', ((is_array($_tmp=$this->_tpl_vars['true'])) ? $this->_run_mod_handler('getlanguage', true, $_tmp) : smarty_modifier_getlanguage($_tmp))); ?>
	<?php $this->assign('select_lang', ((is_array($_tmp=$this->_tpl_vars['true'])) ? $this->_run_mod_handler('selectlang', true, $_tmp, 'session') : smarty_modifier_selectlang($_tmp, 'session'))); ?>
	<?php $this->assign('default_lang', ((is_array($_tmp=$this->_tpl_vars['true'])) ? $this->_run_mod_handler('selectlang', true, $_tmp, 'config') : smarty_modifier_selectlang($_tmp, 'config'))); ?>

	<select name="newlang" style="background: #fff; font-family:tahoma, arial; font-size: 11px; color:#6e6e6e;" onchange="this.form.submit()">
	<?php $_from = $this->_tpl_vars['lang']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['lang']):
?>
	<option value="<?php echo ((is_array($_tmp=$this->_tpl_vars['lang'])) ? $this->_run_mod_handler('escape', true, $_tmp) : smarty_modifier_escape($_tmp)); ?>
" <?php if (empty ( $this->_tpl_vars['select_lang'] ) && $this->_tpl_vars['default_lang'] == $this->_tpl_vars['lang']): ?>selected<?php endif; ?> <?php if ($this->_tpl_vars['select_lang'] == $this->_tpl_vars['lang']): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp=$this->_tpl_vars['lang'])) ? $this->_run_mod_handler('escape', true, $_tmp) : smarty_modifier_escape($_tmp)); ?>
</option>
	<?php endforeach; endif; unset($_from); ?>
	</select>
	</form>	
	</td>
			<td align='right' style="padding-right:20px;">
			<form action="none" name="navigator">
			<?php global $config; if($config->disable_frontend == "true") { echo "<font color=\"#ff0000\">AMXBans frontend is currently disabled!</font>"; } ?>
			<select name="nav" style="background: #fff; font-family:tahoma, arial; font-size: 11px; color:#6e6e6e;"  onchange="openURI()">
			<option value='<?php echo $this->_tpl_vars['dir']; ?>
/' <?php if ($this->_tpl_vars['section'] != 'banlist'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_HOME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='<?php echo $this->_tpl_vars['dir']; ?>
/ban_list.php' <?php if ($this->_tpl_vars['section'] == 'banlist'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_BANLIST')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='<?php echo $this->_tpl_vars['dir']; ?>
/admins_list.php' <?php if ($this->_tpl_vars['section'] == 'Serveradmins'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_ADMLIST')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<?php if (( $_SESSION['bans_add'] == 'yes' )): ?>
			<option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/add_ban.php' <?php if ($this->_tpl_vars['section'] == 'addban'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_ADDBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/add_live_ban.php' <?php if ($this->_tpl_vars['section'] == 'addliveban'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_ADDLIVEBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if ($this->_tpl_vars['display_search'] == 'enabled' || ( $_SESSION['bans_add'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/ban_search.php' <?php if ($this->_tpl_vars['section'] == 'search'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['bans_import'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/import_bans.php' <?php if ($this->_tpl_vars['section'] == 'import'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_IMPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['bans_export'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/export_bans.php' <?php if ($this->_tpl_vars['section'] == 'export'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_EXPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['prune_db'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/prune_db.php' <?php if ($this->_tpl_vars['section'] == 'prune'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_PRUNEDB')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['amxadmins_edit'] == 'yes' || $_SESSION['webadmins_edit'] == 'yes' || $_SESSION['permissions_edit'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/admins_levels.php' <?php if ($this->_tpl_vars['section'] == 'admins_levels'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_ADMINSLEVELS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['amxadmins_edit'] == 'yes' && $_SESSION['permissions_edit'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/server_admins.php' <?php if ($this->_tpl_vars['section'] == 'server_admins'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_SERVERADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['servers_edit'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/servers.php' <?php if ($this->_tpl_vars['section'] == 'servers'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_SERVERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if (( $_SESSION['bans_add'] == 'yes' && $_SESSION['bans_import'] == 'yes' && $_SESSION['bans_export'] == 'yes' && $_SESSION['webadmins_edit'] == 'yes' && $_SESSION['prune_db'] == 'yes' && $_SESSION['amxadmins_edit'] == 'yes' && $_SESSION['permissions_edit'] == 'yes' )): ?><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/cfg.php' <?php if ($this->_tpl_vars['section'] == 'config'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_CONFIG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><option value='<?php echo $this->_tpl_vars['dir']; ?>
/admin/log_search.php' <?php if ($this->_tpl_vars['section'] == 'logs'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_ACCESSLOG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			</select>
			<span class="m">|</span>
			<?php if (isset ( $_SESSION['uid'] )):  echo ((is_array($_tmp='_LOGGED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
: <?php echo $_SESSION['uid']; ?>
 [<a href='<?php echo $this->_tpl_vars['dir']; ?>
/logout.php'><?php echo ((is_array($_tmp='_LOGOUT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a>]<?php else:  echo ((is_array($_tmp='_NOTLOGGED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 [<a href='<?php echo $this->_tpl_vars['dir']; ?>
/login.php'><?php echo ((is_array($_tmp='_LOGIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a>]<?php endif; ?>			
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

        