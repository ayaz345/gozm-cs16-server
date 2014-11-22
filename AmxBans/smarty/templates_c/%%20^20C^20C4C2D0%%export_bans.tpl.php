<?php /* Smarty version 2.6.14, created on 2013-04-03 16:14:57
         compiled from export_bans.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'export_bans.tpl', 4, false),array('function', 'cycle', 'export_bans.tpl', 8, false),array('function', 'html_options', 'export_bans.tpl', 15, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_EXPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <form name='export' enctype='multipart/form-data' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='submitted' value='true'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_GAMETYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'>

							<select name='gtype' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
							<option value='all'><?php echo ((is_array($_tmp='_ALLGAMETYPES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
							<?php unset($this->_sections['mysec']);
$this->_sections['mysec']['name'] = 'mysec';
$this->_sections['mysec']['loop'] = is_array($_loop=$this->_tpl_vars['gametypes']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['mysec']['show'] = true;
$this->_sections['mysec']['max'] = $this->_sections['mysec']['loop'];
$this->_sections['mysec']['step'] = 1;
$this->_sections['mysec']['start'] = $this->_sections['mysec']['step'] > 0 ? 0 : $this->_sections['mysec']['loop']-1;
if ($this->_sections['mysec']['show']) {
    $this->_sections['mysec']['total'] = $this->_sections['mysec']['loop'];
    if ($this->_sections['mysec']['total'] == 0)
        $this->_sections['mysec']['show'] = false;
} else
    $this->_sections['mysec']['total'] = 0;
if ($this->_sections['mysec']['show']):

            for ($this->_sections['mysec']['index'] = $this->_sections['mysec']['start'], $this->_sections['mysec']['iteration'] = 1;
                 $this->_sections['mysec']['iteration'] <= $this->_sections['mysec']['total'];
                 $this->_sections['mysec']['index'] += $this->_sections['mysec']['step'], $this->_sections['mysec']['iteration']++):
$this->_sections['mysec']['rownum'] = $this->_sections['mysec']['iteration'];
$this->_sections['mysec']['index_prev'] = $this->_sections['mysec']['index'] - $this->_sections['mysec']['step'];
$this->_sections['mysec']['index_next'] = $this->_sections['mysec']['index'] + $this->_sections['mysec']['step'];
$this->_sections['mysec']['first']      = ($this->_sections['mysec']['iteration'] == 1);
$this->_sections['mysec']['last']       = ($this->_sections['mysec']['iteration'] == $this->_sections['mysec']['total']);
?>
								<?php echo smarty_function_html_options(array('values' => $this->_tpl_vars['gametypes'][$this->_sections['mysec']['index']]['gametype'],'output' => $this->_tpl_vars['gametypes'][$this->_sections['mysec']['index']]['gametype']), $this);?>

							<?php endfor; endif; ?>
							</select>

            </td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

							<select name='bantype' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
							<option value='both'><?php echo ((is_array($_tmp='_ALLBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
							<option value='perm'><?php echo ((is_array($_tmp='_PERMBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
							<option value='temp'><?php echo ((is_array($_tmp='_TEMPBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
							</select>

            </td>
					</tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_INCREASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='checkbox' name='include_reason'></td>
					</tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='10%' class='listtable_1' colspan='2' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_EXPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
        </table>

				<?php if (( $this->_tpl_vars['submitted'] == 'true' )): ?>
				<br>
        <table cellspacing='1' class='listtable' width='100%'>
					<tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_EXPORTRESULT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <form name='dl' method='post' action='<?php echo $this->_tpl_vars['dir']; ?>
/send_export.php'>
          <input type='hidden' name='download' value='true'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td width='2%' class='listtable_1' align='center'><br>

<textarea name='blob' rows='5' cols='50' selected>
<?php if ($this->_tpl_vars['include_reason'] == 'on'): ?>
<?php $_from = $this->_tpl_vars['exported_bans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['exported_bans']):
?>
banid 0.0 <?php echo $this->_tpl_vars['exported_bans']['steamid']; ?>
 // <?php echo $this->_tpl_vars['exported_bans']['reason']; ?>

<?php endforeach; else: ?>
<?php echo ((is_array($_tmp='_SOMETHINGWRONG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>

<?php endif; unset($_from); ?>
<?php else: ?>
<?php $_from = $this->_tpl_vars['exported_bans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['exported_bans']):
?>
banid 0.0 <?php echo $this->_tpl_vars['exported_bans']['steamid']; ?>

<?php endforeach; else: ?>
<?php echo ((is_array($_tmp='_SOMETHINGWRONG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>

<?php endif; unset($_from); ?>
<?php endif; ?>
</textarea><br><br>

          	</td>
          </tr>

          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='10%' class='listtable_1' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_DOWNLOAD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
				</table>
				<?php endif; ?>