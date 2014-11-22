<?php /* Smarty version 2.6.14, created on 2014-03-05 00:05:02
         compiled from admins_list.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'cycle', 'admins_list.tpl', 5, false),array('modifier', 'lang', 'admins_list.tpl', 6, false),)), $this); ?>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='3' class='listtable_top'><b>AMXadmins</b></td>
		</tr>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' class='listtable_1' align='center'><b><?php echo ((is_array($_tmp='_NICKNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
			<td height='16' class='listtable_1' align='center'><b><?php echo ((is_array($_tmp='_ACCESSFLAGS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
			<td height='16' class='listtable_1' align='center'><b><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		</tr>
		<?php $_from = $this->_tpl_vars['amxadmin']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['amxadmin']):
?>
		<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
			<td height='16' width='10%' class='listtable_1'><?php echo $this->_tpl_vars['amxadmin']['nickname']; ?>
</td>
			<!--td height='16' width='10%' class='listtable_1'><?php echo $this->_tpl_vars['amxadmin']['access']; ?>
</td-->
			<td height='16' width='10%' class='listtable_1'><?php if (strlen ( $this->_tpl_vars['amxadmin']['access'] ) > 1): ?>ADMIN<?php endif; ?> <?php if (strlen ( $this->_tpl_vars['amxadmin']['access'] ) == 1): ?>VIP<?php endif; ?></td>
			<td height='16' width='10%' class='listtable_1'><?php echo $this->_tpl_vars['amxadmin']['time']; ?>
</td>
		</tr>
		<?php endforeach; endif; unset($_from); ?>
</table>
<!--br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACCESSPERMS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		</tr>

		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td colspan=2 class='listtable_1'>
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
		</tr>
		</table-->