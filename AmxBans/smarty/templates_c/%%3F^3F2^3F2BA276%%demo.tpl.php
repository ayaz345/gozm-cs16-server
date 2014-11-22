<?php /* Smarty version 2.6.14, created on 2013-04-22 21:23:08
         compiled from demo.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'demo.tpl', 3, false),array('function', 'cycle', 'demo.tpl', 9, false),)), $this); ?>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_FILESLIST')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
<?php $_from = $this->_tpl_vars['demos']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['demos']):
?>
	<form name="editdemo" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
?bid=<?php echo $this->_tpl_vars['demos']['bid']; ?>
" enctype="multipart/form-data">
	<input type='hidden' name='action' value='edit'>
	<input type='hidden' name='did' value='<?php echo $this->_tpl_vars['demos']['did']; ?>
'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_FILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='demo' value="<?php echo $this->_tpl_vars['demos']['demo']; ?>
" size="52"></td>
           </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_COMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><textarea name="comment" rows="3" cols="40" size="40" class="post"><?php echo $this->_tpl_vars['demos']['comment']; ?>
</textarea></td>
           </tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
	<td colspan=2>
	<input type="checkbox" name="delete" value="1"/><?php echo ((is_array($_tmp='_DELETE_FILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>

	</td></tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value=' <?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><?php echo ((is_array($_tmp='_NOFILES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>
        </table>
<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADDDEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
					<form name="adddemo" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
" enctype="multipart/form-data">
					<input type='hidden' name='action' value='insert'>
					<input type='hidden' name='bid' value=<?php echo $this->_tpl_vars['bid']; ?>
>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr"">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_FILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type="file" name="userfile" size="40" maxlength="80"></td>
           </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_COMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><textarea name="comment" rows="3" cols="40" size="40" class="post"></textarea></td>
           </tr>
					<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr"
						<td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value=' <?php echo ((is_array($_tmp='_ADDDEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
        </table>