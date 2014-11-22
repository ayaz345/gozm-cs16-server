<?php /* Smarty version 2.6.14, created on 2013-04-03 00:34:13
         compiled from server_admins.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'server_admins.tpl', 4, false),array('function', 'cycle', 'server_admins.tpl', 7, false),)), $this); ?>

				<table cellspacing='1' class='listtable' width='100%'>
					<tr>
						<td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_SERVERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
					</tr>
					<form name="server" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
					<tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
						<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_SELECTSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
						<td height='16' width='70%' class='listtable_1'><input type='hidden' name'submitted' value='true'>

							<select name='server_id' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px' onChange="javascript:document.server.submit()">
							<option value='xxx'><?php echo ((is_array($_tmp='_SELECTSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
							<?php $_from = $this->_tpl_vars['servers']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['servers']):
?>
							<option value='<?php echo $this->_tpl_vars['servers']['id']; ?>
'<?php if ($this->_tpl_vars['servers']['id'] == $this->_tpl_vars['thisserver']): ?> selected<?php endif; ?>><?php echo $this->_tpl_vars['servers']['hostname']; ?>
</option>
							<?php endforeach; endif; unset($_from); ?>
							</select>

						</td>
					</tr>
					</form>
					<form name='admins' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
					<input type='hidden' name='server_id' value='<?php echo $this->_tpl_vars['thisserver']; ?>
'>
					<input type='hidden' name='action' value='apply'>
					<tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
						<td height='16' width='30%' class='listtable_1' valign='top'><?php echo ((is_array($_tmp='_SERVERADMINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
						<td height='16' width='70%' class='listtable_1'>
						<?php if (isset ( $this->_tpl_vars['thisserver'] )): ?>
						<?php $_from = $this->_tpl_vars['all_admins']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['all_admins']):
?>
						<input type='hidden' name='<?php echo $this->_tpl_vars['all_admins']['id']; ?>
' class='filecheck' value='off'>
						<input type ='checkbox' name='<?php echo $this->_tpl_vars['all_admins']['id']; ?>
' <?php if ($this->_tpl_vars['all_admins']['checked'] == 1): ?>checked<?php endif; ?>><?php echo $this->_tpl_vars['all_admins']['nickname']; ?>
 (<?php echo $this->_tpl_vars['all_admins']['username']; ?>
)<br>
						<?php endforeach; endif; unset($_from); ?>
						<?php endif; ?>
            &nbsp;</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
						<td height='16' width='100%' class='listtable_1' colspan='2' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_CONFIRM')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
					</tr>
					</form>
        </table>