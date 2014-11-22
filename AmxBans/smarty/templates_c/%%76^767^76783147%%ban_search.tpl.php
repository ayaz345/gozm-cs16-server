<?php /* Smarty version 2.6.14, created on 2013-06-22 14:03:59
         compiled from ban_search.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'ban_search.tpl', 5, false),array('modifier', 'date_format', 'ban_search.tpl', 45, false),array('function', 'cycle', 'ban_search.tpl', 15, false),array('function', 'html_options', 'ban_search.tpl', 87, false),)), $this); ?>

<?php if ($this->_tpl_vars['display_search'] != 'enabled' && ( $_SESSION['bans_add'] != 'yes' )): ?>
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='100' align='center'><b><font color='red' size='3'><?php echo ((is_array($_tmp='_NOACCESS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></b></td>
         </tr>
</table> 
<?php else: ?>

<table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<form name="searchnick" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_NICKNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'><input type='text' name='nick' value='<?php echo $this->_tpl_vars['nick']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<form name="searchsteamid" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp="_STEAMID&IP")) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'>
            	<input type='text' name='steamid' value='<?php echo $this->_tpl_vars['steamid']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
            	<input type='text' name='ip' value='<?php echo $this->_tpl_vars['ip']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<form name="searchreason" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'><input type='text' name='reason' value='<?php echo $this->_tpl_vars['reason']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
	
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          <form name="searchdate" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='date' value='<?php echo ((is_array($_tmp=time())) ? $this->_run_mod_handler('date_format', true, $_tmp, "%d-%m-%Y") : smarty_modifier_date_format($_tmp, "%d-%m-%Y")); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>&nbsp;<script language="JavaScript" src="calendar1.js"></script><a href="javascript:cal1.popup();"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
	  </form>
<script language="JavaScript">
<!--
	var cal1 = new calendar1(document.forms['searchdate'].elements['date']);
	cal1.year_scroll = true;
	cal1.time_comp = false;
-->
</script>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<form name="searchrecidivists" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_PLAYERSWITH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1'>

		<select name='timesbanned' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
		<option value='1'>1</option>
		<option value='2'>2</option>
		<option value='3'>3</option>
		<option value='4'>4</option>
		<option value='5'>5</option>
		<option value='6'>6</option>
		<option value='7'>7</option>
		<option value='8'>8</option>
		<option value='9'>9</option>
		<option value='10'>10</option>
		</select> <?php echo ((is_array($_tmp='_MOREBANSHIS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>


            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          <?php if ($this->_tpl_vars['display_admin'] == 'enabled' || ( $_SESSION['bans_add'] == 'yes' )): ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <form name="searchadmin" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

		<select name='admin' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
			<?php unset($this->_sections['mysec']);
$this->_sections['mysec']['name'] = 'mysec';
$this->_sections['mysec']['loop'] = is_array($_loop=$this->_tpl_vars['admins']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
			<?php echo smarty_function_html_options(array('values' => $this->_tpl_vars['admins'][$this->_sections['mysec']['index']]['nickname'],'output' => $this->_tpl_vars['admins'][$this->_sections['mysec']['index']]['nickname']), $this);?>

			<?php endfor; endif; ?>
		</select>

            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          	</form>
          </tr>
          <?php endif; ?>
        <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          <form name="searchserver" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_SERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

		<select name='server' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
			<?php unset($this->_sections['mysec2']);
$this->_sections['mysec2']['name'] = 'mysec2';
$this->_sections['mysec2']['loop'] = is_array($_loop=$this->_tpl_vars['servers']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['mysec2']['show'] = true;
$this->_sections['mysec2']['max'] = $this->_sections['mysec2']['loop'];
$this->_sections['mysec2']['step'] = 1;
$this->_sections['mysec2']['start'] = $this->_sections['mysec2']['step'] > 0 ? 0 : $this->_sections['mysec2']['loop']-1;
if ($this->_sections['mysec2']['show']) {
    $this->_sections['mysec2']['total'] = $this->_sections['mysec2']['loop'];
    if ($this->_sections['mysec2']['total'] == 0)
        $this->_sections['mysec2']['show'] = false;
} else
    $this->_sections['mysec2']['total'] = 0;
if ($this->_sections['mysec2']['show']):

            for ($this->_sections['mysec2']['index'] = $this->_sections['mysec2']['start'], $this->_sections['mysec2']['iteration'] = 1;
                 $this->_sections['mysec2']['iteration'] <= $this->_sections['mysec2']['total'];
                 $this->_sections['mysec2']['index'] += $this->_sections['mysec2']['step'], $this->_sections['mysec2']['iteration']++):
$this->_sections['mysec2']['rownum'] = $this->_sections['mysec2']['iteration'];
$this->_sections['mysec2']['index_prev'] = $this->_sections['mysec2']['index'] - $this->_sections['mysec2']['step'];
$this->_sections['mysec2']['index_next'] = $this->_sections['mysec2']['index'] + $this->_sections['mysec2']['step'];
$this->_sections['mysec2']['first']      = ($this->_sections['mysec2']['iteration'] == 1);
$this->_sections['mysec2']['last']       = ($this->_sections['mysec2']['iteration'] == $this->_sections['mysec2']['total']);
?>
			<?php echo smarty_function_html_options(array('values' => $this->_tpl_vars['servers'][$this->_sections['mysec2']['index']]['address'],'output' => $this->_tpl_vars['servers'][$this->_sections['mysec2']['index']]['hostname']), $this);?>

			<?php endfor; endif; ?>
			<option value=''>website</option>
		</select>

            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_SEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
      	  </form>
    	</tr>
</table>

<?php if (isset ( $this->_tpl_vars['nick'] ) || isset ( $this->_tpl_vars['steamid'] ) || isset ( $this->_tpl_vars['reason'] ) || isset ( $this->_tpl_vars['date'] ) || isset ( $this->_tpl_vars['timesbanned'] ) || isset ( $this->_tpl_vars['admin'] ) || isset ( $this->_tpl_vars['server'] )): ?>
<br>

<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='red' size='3'><?php echo ((is_array($_tmp='_ACTIVEBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></b></td>
         </tr>
</table>

<table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_top'><b><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><?php endif; ?>
            <td height='16' width='16%' class='listtable_top'><b><?php echo ((is_array($_tmp='_LENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            
            <td height='16' width='2%' class='listtable_top'>&nbsp;</td>
            
          </tr>
          <?php $_from = $this->_tpl_vars['bans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['bans']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr" style="CURSOR:pointer;" onClick="document.location = '<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['bid']; ?>
';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='2%'  class='listtable_1' align='center'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/<?php echo $this->_tpl_vars['bans']['gametype']; ?>
.gif'></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>' class='listtable_1'><?php echo $this->_tpl_vars['bans']['date']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_1'><?php echo $this->_tpl_vars['bans']['player']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_1'><?php if ($this->_tpl_vars['display_admin'] == 'enabled' || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['bans']['admin'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
           <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_1'><?php echo $this->_tpl_vars['bans']['reason']; ?>
</td><?php endif; ?>
            <td height='16' width='16%' class='listtable_1'><?php echo $this->_tpl_vars['bans']['duration']; ?>
</td>
          
          <td height='16' width='2%' class='listtable_1'>
            	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php"><input type='hidden' name='action' value='edit'><input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'><td align='right' width='1%'><input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>&nbsp;&nbsp;</td></form>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_unban'] == 'yes' ) || ( ( $_SESSION['bans_unban'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
		<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php"><input type='hidden' name='action' value='unban'><input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'><td align='right' width='1%'><input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/locked.gif' name='action' ALT='<?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>&nbsp;</td></form>
		<?php endif; ?>
				<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php"><input type='hidden' name='action' value='delete'><input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'><td align='right' width='1%'><input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('Are you sure you want to remove ban_id <?php echo $this->_tpl_vars['bans']['bid']; ?>
?')"></td></form>
				<?php endif; ?>
			</tr>
		</table>
            </td>
          
          </tr>






<?php endforeach; else: ?>
          <tr bgcolor="#D3D8DC">
            <td height='16' colspan='7' class='listtable_1'>No active ban(s) found for that <?php if (isset ( $this->_tpl_vars['nick'] )): ?>(part of) nickname<?php elseif (isset ( $this->_tpl_vars['steamid'] )): ?>steamID<?php elseif (isset ( $this->_tpl_vars['date'] )): ?>date<?php elseif (isset ( $this->_tpl_vars['admin'] )): ?>admin<?php elseif (isset ( $this->_tpl_vars['server'] )): ?>server<?php endif; ?>.</td>
          </tr>
<?php endif; unset($_from); ?>
</table>
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='red' size='2'><?php echo ((is_array($_tmp='_TOTALACTBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 (<?php echo $this->_tpl_vars['bans']['bancount']; ?>
)</font></b></td>
        </tr>
</table>


<br><br>



<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='green' size='3'><?php echo ((is_array($_tmp='_EXPIREDBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></b></td>
        </tr>
</table>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
       	    <td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_top'><b><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><?php endif; ?>
            <td height='16' width='16%' class='listtable_top'><b><?php echo ((is_array($_tmp='_LENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='2%' class='listtable_top'>&nbsp;</td>
         </tr>
          
    
   <?php $_from = $this->_tpl_vars['exbans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['exbans']):
?>
          
          
         <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr" style="CURSOR:pointer;" onClick="document.location = '<?php echo $this->_tpl_vars['dir']; ?>
/ban_details_ex.php?bhid=<?php echo $this->_tpl_vars['exbans']['bhid']; ?>
';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='2%'  class='listtable_1' align='center'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/<?php echo $this->_tpl_vars['exbans']['ex_gametype']; ?>
.gif'></td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>%' class='listtable_1'><?php echo $this->_tpl_vars['exbans']['ex_date']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_1'><?php echo $this->_tpl_vars['exbans']['ex_player']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_1'><?php if ($this->_tpl_vars['display_admin'] == 'enabled' || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['exbans']['ex_admin'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
            <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_1'><?php echo $this->_tpl_vars['exbans']['ex_reason']; ?>
</td><?php endif; ?>
            <td height='16' width='16%' class='listtable_1'><?php echo $this->_tpl_vars['exbans']['ex_duration']; ?>
</td>
            
            <td height='16' width='2%' class='listtable_1'>
            	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<!--<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php"><input type='hidden' name='action' value='edit_ex'><input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['exbans']['bhid']; ?>
'><td align='right' width='1%'><input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>&nbsp;&nbsp;</td></form>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php"><input type='hidden' name='action' value='delete_ex'><input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['exbans']['bhid']; ?>
'><td align='right' width='1%'><input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('Are you sure you want to remove ban_id <?php echo $this->_tpl_vars['exbans']['bhid']; ?>
?')"></td></form>
				<?php endif; ?>-->
				&nbsp;
			</tr>
		</table>
            </td>
          </tr>

<?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan='7' class='listtable_1'>No expired ban(s) found for that <?php if (isset ( $this->_tpl_vars['steamid'] )): ?>steamID<?php elseif (isset ( $this->_tpl_vars['date'] )): ?>date<?php elseif (isset ( $this->_tpl_vars['admin'] )): ?>admin<?php elseif (isset ( $this->_tpl_vars['server'] )): ?>server<?php endif; ?>.</td>
          </tr>
<?php endif; unset($_from); ?>

</table>
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='green' size='2'><?php echo ((is_array($_tmp='_TOTALEXPBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 (<?php echo $this->_tpl_vars['exbans']['ex_bancount']; ?>
)</font></b></td>
        </tr>
</table>
<?php endif; ?>

<?php endif; ?>