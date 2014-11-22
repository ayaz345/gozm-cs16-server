<?php /* Smarty version 2.6.14, created on 2013-04-03 00:22:46
         compiled from admins_levels.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'admins_levels.tpl', 4, false),array('function', 'cycle', 'admins_levels.tpl', 7, false),)), $this); ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADMINSLEVELS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<form name="sektion" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_SELECTACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

			<select name='sektion' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px' onChange="javascript:document.sektion.submit()">
			<option value='xxx' <?php if ($this->_tpl_vars['sektion'] == 'xxx'): ?>selected<?php endif; ?>>...</option>
			<?php if ($_SESSION['permissions_edit'] == 'yes'): ?><option value='levels' <?php if ($this->_tpl_vars['sektion'] == 'levels'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_MANAGELEVEL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if ($_SESSION['webadmins_edit'] == 'yes'): ?><option value='webadmins' <?php if ($this->_tpl_vars['sektion'] == 'webadmins'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_MANAGEWEBADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			<?php if ($_SESSION['amxadmins_edit'] == 'yes'): ?><option value='amxadmins' <?php if ($this->_tpl_vars['sektion'] == 'amxadmins'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_MANAGEAMXADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option><?php endif; ?>
			</select>

		</td>
	</tr>
	</form>
</table>

<?php if ($this->_tpl_vars['sektion'] == 'levels' && $_SESSION['permissions_edit'] == 'yes'): ?>
	<br>
<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='13' class='listtable_top'><b><?php echo ((is_array($_tmp='_MANAGELEVEL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1'>&nbsp;</td>
		<td height='16' class='listtable_1' colspan='6'>bans</td>
		<td height='16' class='listtable_1'>AMXadmins</td>
		<td height='16' class='listtable_1'>Webadmins</td>
		<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_SERVERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' class='listtable_1' colspan='3'><?php echo ((is_array($_tmp='_OTHER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_LVL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_ADD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_IMPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EXPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
		<td height='16' class='listtable_1' align='center'><i>prune DB</i></td>
		<td height='16' class='listtable_1' align='center'><i><?php echo ((is_array($_tmp='_VIEWIP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</i></td>
	</tr>
	<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
<?php $_from = $this->_tpl_vars['level']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['level']):
?>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='2%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='<?php echo $this->_tpl_vars['sektion']; ?>
'><?php echo $this->_tpl_vars['level']['level']; ?>
</td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_add' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_add' <?php if ($this->_tpl_vars['level']['bans_add'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_edit' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' <?php if ($this->_tpl_vars['level']['bans_edit'] == 'no'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='yes' <?php if ($this->_tpl_vars['level']['bans_edit'] == 'yes'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='own' <?php if ($this->_tpl_vars['level']['bans_edit'] == 'own'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_OWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</td>

		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_delete' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' <?php if ($this->_tpl_vars['level']['bans_delete'] == 'no'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='yes' <?php if ($this->_tpl_vars['level']['bans_delete'] == 'yes'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='own' <?php if ($this->_tpl_vars['level']['bans_delete'] == 'own'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_OWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</td>

		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_unban' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' <?php if ($this->_tpl_vars['level']['bans_unban'] == 'no'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='yes' <?php if ($this->_tpl_vars['level']['bans_unban'] == 'yes'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='own' <?php if ($this->_tpl_vars['level']['bans_unban'] == 'own'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_OWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</td>

		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_import' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_import' <?php if ($this->_tpl_vars['level']['bans_import'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_export' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-bans_export' <?php if ($this->_tpl_vars['level']['bans_export'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-amxadmins_edit' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-amxadmins_edit' <?php if ($this->_tpl_vars['level']['amxadmins_edit'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-webadmins_edit' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-webadmins_edit' <?php if ($this->_tpl_vars['level']['webadmins_edit'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-servers_edit' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-servers_edit' <?php if ($this->_tpl_vars['level']['servers_edit'] == 'yes'): ?>checked<?php endif; ?>>		
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-permissions_edit' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-permissions_edit' <?php if ($this->_tpl_vars['level']['permissions_edit'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-prune_db' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-prune_db' <?php if ($this->_tpl_vars['level']['prune_db'] == 'yes'): ?>checked<?php endif; ?>></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-ip_view' value='no'><input type='checkbox' name='<?php echo $this->_tpl_vars['level']['level']; ?>
-ip_view' <?php if ($this->_tpl_vars['level']['ip_view'] == 'yes'): ?>checked<?php endif; ?>>
	</tr>
<?php endforeach; endif; unset($_from); ?>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1' colspan='13' align='right'><?php echo ((is_array($_tmp='_ADDLEVEL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 

		<select name='new_lvl' style='font-family: verdana, tahoma, arial; font-size: 10px'>
		<?php $_from = $this->_tpl_vars['available_levels']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['available_levels']):
?>
		<option value='<?php echo $this->_tpl_vars['available_levels']; ?>
'><?php echo $this->_tpl_vars['available_levels']; ?>
</option>
		<?php endforeach; endif; unset($_from); ?>
		</select>

		<input type='submit' name='action' value='<?php echo ((is_array($_tmp='_ADD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1' colspan='13' align='right'><?php echo ((is_array($_tmp='_REMOVELEVEL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 

		<select name='ex_lvl' style='font-family: verdana, tahoma, arial; font-size: 10px'>
		<?php $_from = $this->_tpl_vars['existing_levels']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['existing_levels']):
?>
		<option value='<?php echo $this->_tpl_vars['existing_levels']; ?>
'><?php echo $this->_tpl_vars['existing_levels']; ?>
</option>
		<?php endforeach; endif; unset($_from); ?>
		</select>

		<input type='submit' name='action' value='<?php echo ((is_array($_tmp='_REMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1' colspan='13' align='right'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	</form>
</table>
<?php endif; ?>
				
<?php if ($this->_tpl_vars['sektion'] == 'webadmins' && $_SESSION['webadmins_edit'] == 'yes'): ?>
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='12' class='listtable_top'><b><?php echo ((is_array($_tmp='_MANAGEWEBADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		</tr>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' width='25%' class='listtable_1'><?php echo ((is_array($_tmp='_USERNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='25%' class='listtable_1'><?php echo ((is_array($_tmp='_PASSWORD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='10%' class='listtable_1'><?php echo ((is_array($_tmp='_LEVEL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='40%' class='listtable_1'><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		</tr>
		<?php $_from = $this->_tpl_vars['webadmin']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['webadmin']):
?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='hidden' name='id' value='<?php echo $this->_tpl_vars['webadmin']['id']; ?>
'><input type='text' name='username' value='<?php echo $this->_tpl_vars['webadmin']['username']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'>
	
			<?php $this->assign('temp', $this->_tpl_vars['webadmin']['existing_lvls']); ?>
			<select name='level' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 50px'>
			<?php $_from = $this->_tpl_vars['temp']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['item']):
?>
			<option value='<?php echo $this->_tpl_vars['item']; ?>
' <?php if ($this->_tpl_vars['item'] == $this->_tpl_vars['webadmin']['level']): ?>selected<?php endif; ?>><?php echo $this->_tpl_vars['item']; ?>
</option>
			<?php endforeach; endif; unset($_from); ?>
			</select>
	
			</td>
			<td height='16' class='listtable_1' align='left'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='<?php echo ((is_array($_tmp='_REMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_DELADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
')"></td>
		</tr>
		</form>
		<?php endforeach; endif; unset($_from); ?>
	
		<?php if ($this->_tpl_vars['action'] == lang ( '_ADDWEBADMINS' )): ?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='hidden' name='sektion' value='webadmins'><input type='text' name='username' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'>
	
			<?php $this->assign('temp', $this->_tpl_vars['webadmin']['existing_lvls']); ?>
			<select name='level' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 50px'>
			<?php $_from = $this->_tpl_vars['temp']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['item']):
?>
			<option value='<?php echo $this->_tpl_vars['item']; ?>
'><?php echo $this->_tpl_vars['item']; ?>
</option>
			<?php endforeach; endif; unset($_from); ?>
			</select>
	
			</td>
			<td height='16' class='listtable_1' align='left'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_INSERT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
		</tr>
		</form>
		<?php endif; ?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1' colspan='12' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_ADDWEBADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
		</tr>
		</form>
	</table>
<?php endif; ?>

<?php if ($this->_tpl_vars['sektion'] == 'amxadmins' && $_SESSION['amxadmins_edit'] == 'yes'): ?>
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='12' class='listtable_top'><b><?php echo ((is_array($_tmp='_MANAGEAMXADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		</tr>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1'>Nickname/SteamID/IP</td>
			<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_PASSWORD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_ACCESS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_FLAGS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' class='listtable_1'>SteamID</td>
			<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_NICKNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' class='listtable_1'>Admins list</td>
			<td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		</tr>
		<?php $_from = $this->_tpl_vars['amxadmin']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['amxadmin']):
?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' width='10%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='hidden' name='id' value='<?php echo $this->_tpl_vars['amxadmin']['id']; ?>
'><input type='text' name='username' value='<?php echo $this->_tpl_vars['amxadmin']['username']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='password' value='<?php echo $this->_tpl_vars['amxadmin']['password']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='access' value='<?php echo $this->_tpl_vars['amxadmin']['access']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 140px'></td>
			<td height='16' width='5%' class='listtable_1' align='center'><input type='text' name='flags' value='<?php echo $this->_tpl_vars['amxadmin']['flags']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 30px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='steamid' value='<?php echo $this->_tpl_vars['amxadmin']['steamid']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='nickname' value='<?php echo $this->_tpl_vars['amxadmin']['nickname']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><select name='ashow' style='font-family: verdana, tahoma, arial; font-size: 10px'><option value='0'>Not show</option><option value='1' <?php if ($this->_tpl_vars['amxadmin']['ashow'] == '1'): ?>selected<?php endif; ?>>Show</option></select></td>
			<td height='16' width='45%' class='listtable_1' align='left'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='<?php echo ((is_array($_tmp='_REMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_DELADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
')"></td>
		</tr>
		</form>
		<?php endforeach; endif; unset($_from); ?>
		<?php if ($this->_tpl_vars['action'] == lang ( '_ADDAMXADMINS' )): ?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' width='10%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='text' name='username' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='access' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 140px'></td>
			<td height='16' width='5%' class='listtable_1' align='center'><input type='text' name='flags' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 30px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='steamid' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='nickname' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><select name='ashow' style='font-family: verdana, tahoma, arial; font-size: 10px'><option value='0'>Not show</option><option value='1' <?php if ($this->_tpl_vars['amxadmin']['ashow'] == '1'): ?>selected<?php endif; ?>>Show</option></select></td>
			<td height='16' width='45%' class='listtable_1' align='left'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_INSERT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
		</tr>
		</form>
		<?php endif; ?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1' colspan='12' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_ADDAMXADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
		</tr>
		</form>
	</table>
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
	<tr>
	<td height='16' width='60%' colspan='1' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACCESSPERMS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	<td height='16' width='40%' colspan='1' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACCESSFLAGS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
	<td colspan=1 class='listtable_1'>
		<?php echo ((is_array($_tmp='_ACCESS_A')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_B')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_C')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_D')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_E')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_F')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_G')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_H')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_I')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_J')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_K')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_L')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_M')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_N')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_O')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_P')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_Q')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_R')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_S')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_T')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_U')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_ACCESS_Z')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
	</td>
	<td colspan=1 class='listtable_1'>
		<?php echo ((is_array($_tmp='_FLAG_A')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_FLAG_B')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_FLAG_C')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_FLAG_D')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_FLAG_E')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
		<?php echo ((is_array($_tmp='_FLAG_K')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br>
	</td>
	</tr>
	</table>
	<?php endif; ?>
	
	<!-- Comment out line 187, 198 and 211 (password field) in admins_levels.tpl then your width will be smaller -->