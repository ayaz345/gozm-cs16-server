<?php /* Smarty version 2.6.14, created on 2013-04-03 00:33:43
         compiled from servers.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'cycle', 'servers.tpl', 7, false),array('modifier', 'lang', 'servers.tpl', 17, false),array('modifier', 'date_format', 'servers.tpl', 30, false),)), $this); ?>

<?php if ($this->_tpl_vars['any_outdated'] == true): ?>
<table cellspacing='1' class='listtable' width='100%'>
  <tr>
  	<td height='16' class='listtable_top'><b>New AMX Plugin available!</b></td>
  </tr>
  <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
	<td height='32' width='100%' class='listtable_1' colspan='5' align='center'><br><br>A new version of the AMXBans Plugin is available for one (or more) of your servers listed below. You can download it at:<br><font color='#ff0000'><a href='<?php echo $this->_tpl_vars['update_url']; ?>
' class='alert'  target="_blank"><?php echo $this->_tpl_vars['update_url']; ?>
</a></font><br><br></td>
  </tr>
</table>
<br>
<?php endif; ?>

<table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='32%' class='listtable_top'><b><?php echo ((is_array($_tmp='_HOSTNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='16%' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADDRESS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='16%' class='listtable_top'><b><?php echo ((is_array($_tmp='_LASTSEEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='11%' class='listtable_top'><b><?php echo ((is_array($_tmp='_VERSION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='6%' class='listtable_top'><b><?php echo ((is_array($_tmp='_BANMENU')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='17%' class='listtable_top'><b><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>

          <?php $_from = $this->_tpl_vars['servers']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['servers']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1' align='center'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/<?php if ($this->_tpl_vars['servers']['gametype'] == ""): ?>huh<?php else:  echo $this->_tpl_vars['servers']['gametype'];  endif; ?>.gif' alt='modification: <?php if ($this->_tpl_vars['servers']['gametype'] == ""):  echo ((is_array($_tmp='_UNKNOWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  else:  echo $this->_tpl_vars['servers']['gametype'];  endif; ?>'></td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['servers']['hostname']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['servers']['address']; ?>
</td>
	    <td height='16' class='listtable_1'><?php echo ((is_array($_tmp=$this->_tpl_vars['servers']['timestamp'])) ? $this->_run_mod_handler('date_format', true, $_tmp, "%d-%m-%y %H:%M") : smarty_modifier_date_format($_tmp, "%d-%m-%y %H:%M")); ?>
</td>
            <td height='16' class='listtable_1' <?php if ($this->_tpl_vars['version_checking'] == 'enabled'):  if ($this->_tpl_vars['servers']['outdated'] != 0): ?>bgcolor='#FFEAEA' style="CURSOR:hand;" onClick="document.location = 'http://www.amxbans.net';" onMouseOver="this.style.backgroundColor='#FFA6A6'" onMouseOut="this.style.backgroundColor='any_outdated'"<?php endif;  endif; ?>><?php echo $this->_tpl_vars['servers']['version']; ?>
 (<?php echo $this->_tpl_vars['servers']['plugin']; ?>
)</td>
            <form name='editserver' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
            <td height='16' class='listtable_1' align='center'><?php if ($this->_tpl_vars['servers']['amxban_menu'] != 0): ?><input type='submit' name='list_reasons' value='<?php echo ((is_array($_tmp='_SHOWREASONS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'><?php else: ?>&nbsp;<?php endif; ?></td>
            <td height='16' class='listtable_1' align='right'><?php if (( $_SESSION['servers_edit'] == 'yes' )): ?><input type='hidden' name='id' value='<?php echo $this->_tpl_vars['servers']['id']; ?>
'><input type='hidden' name='hostname' value='<?php echo $this->_tpl_vars['servers']['hostname']; ?>
'><input type='hidden' name='address' value='<?php echo $this->_tpl_vars['servers']['address']; ?>
'><input type='hidden' name='rcon' value='<?php echo $this->_tpl_vars['servers']['rcon']; ?>
'><input type='hidden' name='gametype' value='<?php echo $this->_tpl_vars['servers']['gametype']; ?>
'><input type='hidden' name='amxban_motd' value='<?php echo $this->_tpl_vars['servers']['amxban_motd']; ?>
'><input type='hidden' name='motd_delay' value='<?php echo $this->_tpl_vars['servers']['motd_delay']; ?>
'> <input type='submit' name='edit' value='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'> <input type='submit' name='remove' value='<?php echo ((is_array($_tmp='_REMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;' <?php if (( $_SESSION['servers_edit'] != 'yes' )): ?>disabled<?php endif; ?>onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_DELSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
')"><?php else: ?>&nbsp;<?php endif; ?></td>
	    </form>
          </tr>
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan='8' class='listtable_1'><?php echo ((is_array($_tmp='_NOSERVERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>          
</table>


<?php if (isset ( $this->_tpl_vars['edit'] )): ?>
<br>
<table cellspacing='1' class='listtable' width='100%'>
          <form name='applyserver' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='id' value='<?php echo $this->_tpl_vars['id']; ?>
'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_SERVERDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_tpl_vars['hostname']; ?>
 (<?php echo $this->_tpl_vars['address']; ?>
)</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_MODIFICATION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>
		<select name='mod' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'>
			<option value='huh' <?php if ($this->_tpl_vars['gametype'] == 'huh'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_SELMODIFICATION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
			<option value='cstrike' <?php if ($this->_tpl_vars['gametype'] == 'cstrike'): ?>selected<?php endif; ?>>Counter-Strike</option>
			<option value='czero' <?php if ($this->_tpl_vars['gametype'] == 'czero'): ?>selected<?php endif; ?>>Condition Zero</option>
			<option value='dod' <?php if ($this->_tpl_vars['gametype'] == 'dod'): ?>selected<?php endif; ?>>Day of Defeat</option>
			<option value='ns' <?php if ($this->_tpl_vars['gametype'] == 'ns'): ?>selected<?php endif; ?>>Natural Selection</option>
			<option value='tfc' <?php if ($this->_tpl_vars['gametype'] == 'tfc'): ?>selected<?php endif; ?>>Team Fortress Classic</option>
			<option value='ts' <?php if ($this->_tpl_vars['gametype'] == 'ts'): ?>selected<?php endif; ?>>The Specialists</option>
			
		</select>
	    </td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>RCON</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='rcon' value='<?php echo $this->_tpl_vars['rcon']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_AMXBANSMOTDURL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='amxban_motd' value='<?php echo $this->_tpl_vars['amxban_motd']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_AMXBANSMOTDURLDELAY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>
		<select name='motd_delay' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'>
			<option value='0' <?php if ($this->_tpl_vars['motd_delay'] == 0): ?>selected<?php endif; ?>>0</option>
			<option value='1' <?php if ($this->_tpl_vars['motd_delay'] == 1): ?>selected<?php endif; ?>>1</option>
			<option value='5' <?php if ($this->_tpl_vars['motd_delay'] == 5): ?>selected<?php endif; ?>>5</option>
			<option value='10' <?php if ($this->_tpl_vars['motd_delay'] == 10): ?>selected<?php endif; ?>>10</option>
			<option value='30' <?php if ($this->_tpl_vars['motd_delay'] == 30): ?>selected<?php endif; ?>>30</option>
			<option value='60' <?php if ($this->_tpl_vars['motd_delay'] == 60): ?>selected<?php endif; ?>>60</option>
		</select>
	    </td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' class='listtable_1' colspan='2' align='right'><input type='submit' name='apply' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
</table>
<?php endif; ?>


<br>
<?php if (isset ( $this->_tpl_vars['list_reasons'] )): ?>
        
<table cellspacing='1' class='listtable' width='100%'>

          <input type='hidden' name='id' value='<?php echo $this->_tpl_vars['id']; ?>
'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_BANREASONSFOR')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_tpl_vars['hostname']; ?>
 (<?php echo $this->_tpl_vars['address']; ?>
)</b></td>
          </tr>
	<?php $_from = $this->_tpl_vars['reasons']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }$this->_foreach['reasons'] = array('total' => count($_from), 'iteration' => 0);
if ($this->_foreach['reasons']['total'] > 0):
    foreach ($_from as $this->_tpl_vars['reasons']):
        $this->_foreach['reasons']['iteration']++;
?>
          <form name='applyreasons' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'><input type='hidden' name='address' value='<?php echo $this->_tpl_vars['address']; ?>
'>
          <input type='hidden' name='list_reasons' value='whatever'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><input type='hidden' name='id' value='<?php echo $this->_tpl_vars['reasons']['id']; ?>
'><?php echo ((is_array($_tmp='_BANREASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_foreach['reasons']['iteration']; ?>
</td>
            <td height='16' width='50%' class='listtable_1'><input type='text' name='reason' value='<?php echo $this->_tpl_vars['reasons']['reason']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
	    <td heigth='16' width='20%' class='listtable_1' align='right'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'> <input type='submit' name='action' value='<?php echo ((is_array($_tmp='_REMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_DELBANREASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
')"></td>
          </tr>
          </form>
          <?php endforeach; endif; unset($_from); ?>
	<?php if ($this->_tpl_vars['action'] == lang ( '_ADD' )): ?>
          <form name='applyreasons' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='address' value='<?php echo $this->_tpl_vars['address']; ?>
'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANREASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='50%' class='listtable_1'><input type='hidden' name='list_reasons' value='whatever'><input type='text' name='reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
	    <td heigth='16' width='20%' class='listtable_1' align='right'><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
	<?php endif; ?>
		<form name='applyreasons' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
		<input type='hidden' name='list_reasons' value='whatever'><input type='hidden' name='address' value='<?php echo $this->_tpl_vars['address']; ?>
'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' class='listtable_1' colspan='3' align='right'><?php if ($this->_foreach['reasons']['total'] < 7): ?><input type='submit' name='action' value='<?php echo ((is_array($_tmp='_ADD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'><?php else: ?>&nbsp;<?php endif; ?></td>
          </tr>
          </form>
</table>
<?php endif; ?>