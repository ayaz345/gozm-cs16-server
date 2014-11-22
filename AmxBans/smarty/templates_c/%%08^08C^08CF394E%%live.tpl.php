<?php /* Smarty version 2.6.14, created on 2014-05-19 03:46:41
         compiled from live.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'live.tpl', 3, false),array('modifier', 'lower', 'live.tpl', 80, false),array('function', 'cycle', 'live.tpl', 11, false),)), $this); ?>
        <table cellspacing='0' width='100%'>
          <tr>
            <td height='16' colspan=4 align='left'><b><?php echo ((is_array($_tmp='_SELECTSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 </b>
		<select name="server" size="1" style="background: #D3D8DC; font-family: verdana, tahoma, arial; font-size: 10px;" onChange="jumpMenu(this, '_top');">
           <?php $_from = $this->_tpl_vars['servers']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['servers']):
?>
      <option value="<?php echo $this->_tpl_vars['dir']; ?>
/live.php?sid=<?php echo $this->_tpl_vars['servers']['id']; ?>
" <?php if ($this->_tpl_vars['servers']['id'] == $this->_tpl_vars['s']): ?> selected<?php endif; ?>><?php echo $this->_tpl_vars['servers']['hostname']; ?>
</option>
          <?php endforeach; endif; unset($_from); ?>
	</select>
	</td>
	</tr>
           <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width=30% valign=top>

        <table cellspacing='1' width='100%' class='listtable'>
	<?php $_from = $this->_tpl_vars['server']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['server']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td  width=30% height='16' class='listtable_top' colspan=2><b><?php echo $this->_tpl_vars['server']['hostname']; ?>
</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1' colspan=2 align=center valign=middle><img style="border:1px #000000 solid;" src=../stats/images/maps/<?php echo $this->_tpl_vars['server']['mappic']; ?>
.jpg alt="<?php echo $this->_tpl_vars['server']['map']; ?>
"></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_ADDRESS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['address']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_MAP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['map']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_GAMETYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['game']; ?>
</td>
          </tr>
            <?php if ($this->_tpl_vars['server']['timelimit'] == '0'): ?>
				<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
					<td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_TIMELIMIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo ((is_array($_tmp='_NOTIMELIMIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
				</tr>
			<?php else: ?>
				<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
					<td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_TIMELEFT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['timeleft']; ?>
 min</td>
				</tr>
				<tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
					<td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_TIMELIMIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['timelimit']; ?>
:00 min</td>
				</tr>
			<?php endif; ?>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['server']['cur_players']; ?>
/<?php echo $this->_tpl_vars['server']['max_players']; ?>
</td>
          </tr>
		  <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1' valign='top'><b>AntiCheat</b></td>
				<td height='16' class='listtable_1'>
					<?php if ($this->_tpl_vars['addons']['vac']):  echo $this->_tpl_vars['addons']['vac'];  endif; ?>
					<?php if ($this->_tpl_vars['addons']['vac'] && $this->_tpl_vars['addons']['steambans']): ?>, <?php endif; ?>
					<?php if ($this->_tpl_vars['addons']['steambans']): ?><a href="http://www.steambans.com">SB</a> <?php echo $this->_tpl_vars['addons']['steambans'];  endif; ?>
				</td>
          </tr>
		  <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1' valign='top'><b>Addons</b></td>
				<td height='16' class='listtable_1'>
					<table cellspacing='1' width=70%>
						<?php if ($this->_tpl_vars['addons']['metamod']): ?><tr bgcolor='#D3D8DC'><td><a href="http://www.metamod.org">Metamod</a></td><td>v<?php echo $this->_tpl_vars['addons']['metamod']; ?>
</td></tr><?php endif; ?>
						<?php if ($this->_tpl_vars['addons']['amxx']): ?><tr bgcolor='#D3D8DC'><td><a href="http://www.amxmodx.org">AMXModX</a></td><td>v<?php echo $this->_tpl_vars['addons']['amxx']; ?>
</td></tr><?php endif; ?>
						<?php if ($this->_tpl_vars['addons']['amxbans']): ?><tr bgcolor='#D3D8DC'><td><a href="http://www.amxbans.de">AMXBans</a></td><td>v<?php echo $this->_tpl_vars['addons']['amxbans']; ?>
</td></tr><?php endif; ?>
					</table>
				
				
				</td>
          </tr>
	<?php endforeach; endif; unset($_from); ?>
	</table>
		</td>
<td valign=top>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_top'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		<td height='16' width=50 class='listtable_top'><b><?php echo ((is_array($_tmp='_FRAGS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		<td height='16' width=50  class='listtable_top'><b><?php echo ((is_array($_tmp='_PING')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		<td height='16' width=50  class='listtable_top'><b><?php echo ((is_array($_tmp='_ONLINE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <?php $_from = $this->_tpl_vars['players']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['players']):
?>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1'><?php if ($this->_tpl_vars['geoip'] == 'enabled'):  if ($this->_tpl_vars['players']['cc'] != ""): ?><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/flags/<?php echo ((is_array($_tmp=$this->_tpl_vars['players']['cc'])) ? $this->_run_mod_handler('lower', true, $_tmp) : smarty_modifier_lower($_tmp)); ?>
.gif' alt='<?php echo $this->_tpl_vars['players']['cn']; ?>
'> <?php else: ?><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='18' height='12'> <?php endif;  endif;  if ($this->_tpl_vars['players']['name'] != ""):  echo $this->_tpl_vars['players']['name'];  else: ?>Player Connecting...<?php endif; ?></td>
            <td height='16' width=50  class='listtable_1'><?php echo $this->_tpl_vars['players']['frag']; ?>
&nbsp;</td>
            <td height='16' width=50  class='listtable_1'><?php echo $this->_tpl_vars['players']['ping']; ?>
&nbsp;</td>
            <td height='16' width=50  class='listtable_1'><?php echo $this->_tpl_vars['players']['time']; ?>
&nbsp;</td>
					</tr>
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan=4 class='listtable_1' align='center'><br><?php echo ((is_array($_tmp='_NOPLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br><br></td>
          </tr>
          <?php endif; unset($_from); ?>    
		</table>
</td></tr>
        </table>