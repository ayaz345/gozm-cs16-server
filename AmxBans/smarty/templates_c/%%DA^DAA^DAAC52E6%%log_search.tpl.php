<?php /* Smarty version 2.6.14, created on 2013-04-03 00:22:17
         compiled from log_search.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'log_search.tpl', 4, false),array('modifier', 'date_format', 'log_search.tpl', 9, false),array('function', 'cycle', 'log_search.tpl', 7, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACCESSLOG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <form name="searchdate" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='date' value='<?php if (! isset ( $this->_tpl_vars['date'] )):  echo ((is_array($_tmp=time())) ? $this->_run_mod_handler('date_format', true, $_tmp, "%d-%m-%Y") : smarty_modifier_date_format($_tmp, "%d-%m-%Y"));  else:  if ($this->_tpl_vars['date'] != "%"):  echo $this->_tpl_vars['date'];  endif;  endif; ?>' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>&nbsp;<script language="JavaScript" src="calendar1.js"></script><a href="javascript:cal1.popup();"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
					</tr>
					<script language="JavaScript">
						<!--
							var cal1 = new calendar1(document.forms['searchdate'].elements['date']);
							cal1.year_scroll = true;
							cal1.time_comp = false;
						-->
					</script>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

							<select name='admin' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
								<option value='all'><?php echo ((is_array($_tmp='_ALL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
								<?php $_from = $this->_tpl_vars['admins']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['admins']):
?>
								<option value='<?php echo $this->_tpl_vars['admins']; ?>
' <?php if ($this->_tpl_vars['admins'] == $this->_tpl_vars['admin']): ?>selected<?php endif; ?>><?php echo $this->_tpl_vars['admins']; ?>
</option>
								<?php endforeach; endif; unset($_from); ?>
							</select>

            </td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

							<select name='action' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
								<option value='all'><?php echo ((is_array($_tmp='_ALL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
								<?php $_from = $this->_tpl_vars['actions']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['actions']):
?>
								<option value='<?php echo $this->_tpl_vars['actions']; ?>
' <?php if ($this->_tpl_vars['actions'] == $this->_tpl_vars['action']): ?>selected<?php endif; ?>><?php echo $this->_tpl_vars['actions']; ?>
</option>
								<?php endforeach; endif; unset($_from); ?>
							</select>

            </td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
						<td height='16' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
					</tr>
					</form>
        </table>

				<br>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='15%' class='listtable_top'><b><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='10%' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='15%' class='listtable_top'><b><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='20%' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='40%' class='listtable_top'><b><?php echo ((is_array($_tmp='_REMARKS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <?php $_from = $this->_tpl_vars['logs']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['logs']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['logs']['date']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['logs']['username']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['logs']['ip']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['logs']['action']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['logs']['remarks']; ?>
</td>
          </tr>
          <?php endforeach; else: ?>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan='6' class='listtable_1' align='center'><br><?php echo ((is_array($_tmp='_NOLOGFOUND')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br><br></td>
          </tr>
          <?php endif; unset($_from); ?>
 				</table>
 				