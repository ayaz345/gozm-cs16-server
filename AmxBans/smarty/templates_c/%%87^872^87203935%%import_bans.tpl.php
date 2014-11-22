<?php /* Smarty version 2.6.14, created on 2013-04-03 16:14:51
         compiled from import_bans.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'import_bans.tpl', 4, false),array('function', 'cycle', 'import_bans.tpl', 8, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_IMPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <form name='import' enctype='multipart/form-data' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='submitted' value='true'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANFILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'><input name='<?php echo $this->_tpl_vars['filename']; ?>
' type='file' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
					</tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
						<td height='16' width='70%' class='listtable_1'><input type='text' name='ban_length' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' class='listtable_1' align='right' colspan='2'><?php echo $this->_tpl_vars['submit']; ?>
</td>
          </tr>
          </form>
        </table>

				<?php if (( $this->_tpl_vars['submitted'] == 'true' )): ?>
				<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='15%' class='listtable_top'><b>SteamID / IP</b></td>
            <td height='16' width='33%' class='listtable_top'><b><?php echo ((is_array($_tmp='_RESULT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>

					<?php $_from = $this->_tpl_vars['import']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['import']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='2%'  class='listtable_1' align='center'><?php echo $this->_tpl_vars['import']['counter']; ?>
</td>
            <td height='16' width='15%' class='listtable_1'><?php echo $this->_tpl_vars['import']['id']; ?>
</td>
            <td height='16' width='33%' class='listtable_1'><?php if ($this->_tpl_vars['import']['result'] == 0): ?><font color='#cc0000'><?php echo ((is_array($_tmp='_NOTIMPORTED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font><?php else: ?><font color='#00cc00'><?php echo ((is_array($_tmp='_IMPORTED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font><?php endif; ?></td>
          </tr>
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan='3' class='listtable_1'><?php echo ((is_array($_tmp='_NOFOUNDIMPORT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>
				</table>
				<?php endif; ?>