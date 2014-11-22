<?php /* Smarty version 2.6.14, created on 2013-04-03 00:22:28
         compiled from add_live_ban.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'add_live_ban.tpl', 4, false),array('modifier', 'lower', 'add_live_ban.tpl', 70, false),array('function', 'cycle', 'add_live_ban.tpl', 6, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='4' class='listtable_top'><b><?php echo ((is_array($_tmp='_SELECTSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='2%' class='listtable_1'>&nbsp;</td>
            <td height='16' width='50%' class='listtable_1'><b><?php echo ((is_array($_tmp='_HOSTNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='8%' class='listtable_1'><b><?php echo ((is_array($_tmp='_PLAYERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='40%' class='listtable_1'><b><?php echo ((is_array($_tmp='_ADDRESS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>

          <?php $_from = $this->_tpl_vars['servers']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['servers']):
?>
          <form name='serverinfo' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <tr <?php if ($this->_tpl_vars['servers']['maxplayers'] == ""): ?>bgcolor="#FFEAEA"<?php elseif ($this->_tpl_vars['servers']['maxplayers'] == 0 || $this->_tpl_vars['servers']['maxplayers'] == "-" || $this->_tpl_vars['servers']['curplayers'] == "-"): ?>bgcolor="#D3D8DC"<?php else: ?>bgcolor="#D3D8DC" style="CURSOR:pointer;" onClick="javascript:submit()" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'"<?php endif; ?>>
            <td height='16' class='listtable_1' align='center'><input type="hidden" name="live_player_ban" value="true"><input type="hidden" name="server_id" value="<?php echo $this->_tpl_vars['servers']['server_id']; ?>
"><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/<?php if ($this->_tpl_vars['servers']['gametype'] == ""): ?>huh<?php else:  echo $this->_tpl_vars['servers']['gametype'];  endif; ?>.gif' alt='modification: <?php if ($this->_tpl_vars['servers']['gametype'] == ""):  echo ((is_array($_tmp='_UNKNOWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  else:  echo $this->_tpl_vars['servers']['gametype'];  endif; ?>'></td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['servers']['hostname']; ?>
</td>
            <td height='16' class='listtable_1' align='center'><?php if ($this->_tpl_vars['servers']['maxplayers'] == ""):  echo ((is_array($_tmp='_DOWN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  elseif ($this->_tpl_vars['servers']['maxplayers'] == 0):  echo ((is_array($_tmp='_NONE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  else:  echo $this->_tpl_vars['servers']['curplayers']; ?>
/<?php echo $this->_tpl_vars['servers']['maxplayers'];  endif; ?></td>
            <td height='16' class='listtable_1'>

						<table border='0' width='100%' cellspacing='0' cellpadding='0'>
							<tr>
								<td><?php echo $this->_tpl_vars['servers']['address']; ?>
</td>
								<td align='right'><?php if ($this->_tpl_vars['browser'] != 'IE'): ?><input type='submit' name='submit' value='go' style='font-family: verdana, tahoma, arial; font-size: 10px;'<?php if ($this->_tpl_vars['servers']['maxplayers'] == "" || $this->_tpl_vars['servers']['maxplayers'] == 0): ?>disabled<?php endif; ?>><?php else: ?>&nbsp;<?php endif; ?></td>
							</tr>
						</table>
            
            </td>
					</tr>
					</form>
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' colspan='4' class='listtable_1'><?php echo ((is_array($_tmp='_NOSERVFOUND')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>          
        </table>

				<?php if ($this->_tpl_vars['live_player_ban'] == 'true'): ?>
				<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='7' class='listtable_top'><b><?php echo ((is_array($_tmp='_SELECTPLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>

          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><b><?php echo ((is_array($_tmp='_NICKNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='10%' class='listtable_1'><b>SteamID</b></td>
            <td height='16' width='10%' class='listtable_1'><b><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='10%' class='listtable_1'><b><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='10%' class='listtable_1'><b><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='10%' class='listtable_1'><b><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' width='20%' class='listtable_1'><b><?php echo ((is_array($_tmp='_ACTION')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>

					<?php if (isset ( $this->_tpl_vars['empty_result'] )): ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' class='listtable_1' colspan='7'><?php echo ((is_array($_tmp='_COMMNORESPONSE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
					</tr>
				</table>
					<?php else: ?>
          <?php $_from = $this->_tpl_vars['players']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['players']):
?>
          <form name='playerinfo' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <tr <?php if ($this->_tpl_vars['players']['is_admin'] == 1 || $this->_tpl_vars['players']['steamid'] == 'BOT'): ?>bgcolor="#C7CCD2"<?php else: ?>bgcolor="#D3D8DC"<?php endif; ?>>
            
            <td height='16' class='listtable_1'>
            	<input type="hidden" name="server_id" value="<?php echo $this->_tpl_vars['post']['server_id']; ?>
">
            	<input type="hidden" name="player_nick" value="<?php echo $this->_tpl_vars['players']['nick']; ?>
">
            	<input type="hidden" name="player_id" value="<?php echo $this->_tpl_vars['players']['steamid']; ?>
">
            	<input type="hidden" name="player_ip" value="<?php echo $this->_tpl_vars['players']['ip']; ?>
">
            <?php if ($this->_tpl_vars['geoip'] == 'enabled' && ( $this->_tpl_vars['players']['steamid'] != 'BOT' ) && ( ((is_array($_tmp=$this->_tpl_vars['players']['cc'])) ? $this->_run_mod_handler('lower', true, $_tmp) : smarty_modifier_lower($_tmp)) != "" )): ?>
            	<img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/flags/<?php echo ((is_array($_tmp=$this->_tpl_vars['players']['cc'])) ? $this->_run_mod_handler('lower', true, $_tmp) : smarty_modifier_lower($_tmp)); ?>
.gif' alt='<?php echo $this->_tpl_vars['players']['cn']; ?>
'>
            <?php else: ?>
            	<img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='18' height='12'>
            <?php endif;  echo $this->_tpl_vars['players']['nick']; ?>
</td>
            
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['players']['steamid']; ?>
</td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['players']['ip']; ?>
</td>
            <td height='16' class='listtable_1'>
            
            <select name='ban_type' style='font-family: verdana, tahoma, arial; font-size: 10px;' <?php if ($this->_tpl_vars['players']['is_admin'] == 1 || $this->_tpl_vars['players']['steamid'] == 'BOT'): ?>disabled<?php endif; ?>>
						<option value='S'>SteamID</option>
						<option value='SI'><?php echo ((is_array($_tmp="_STEAMID&IP")) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						</select>
            
            </td>
						<td height='16' class='listtable_1'>

						<select name='ban_length' style='font-family: verdana, tahoma, arial; font-size: 10px;' <?php if ($this->_tpl_vars['players']['is_admin'] == 1 || $this->_tpl_vars['players']['steamid'] == 'BOT'): ?>disabled<?php endif; ?>>
						<option value='0'>Permanent</option>
						<optgroup label="minutes">
						<option value='1'>1 min</option>
						<option value='5'>5 mins</option>
						<option value='10'>10 mins</option>
						<option value='15'>15 mins</option>
						<option value='30'>30 mins</option>
						<option value='45'>45 mins</option>
						<optgroup label="hours">
						<option value='60'>1 hour</option>
						<option value='120'>2 hours</option>
						<option value='180'>3 hours</option>
						<option value='240'>4 hours</option>
						<option value='480'>8 hours</option>
						<option value='720'>12 hours</option>

						<optgroup label="days">
						<option value='1440'>1 day</option>
						<option value='2880'>2 days</option>
						<option value='4320'>3 days</option>
						<option value='5760'>4 days</option>
						<option value='7200'>5 days</option>
						<option value='8640'>6 days</option>
						<optgroup label="Weeks">
						<option value='10080'>1 week</option>
						<option value='20160'>2 weeks</option>
						<option value='30240'>3 weeks</option>
						<optgroup label="Months">
						<option value='40320'>1 month</option>
						<option value='80640'>2 months</option>
						<option value='120960'>3 months</option>
						<option value='241920'>6 months</option>
						<option value='483840'>12 months</option>
						</select>
						</td>

            <td height='16' class='listtable_1'><input type='text' name='ban_reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px' <?php if ($this->_tpl_vars['players']['is_admin'] == 1 || $this->_tpl_vars['players']['steamid'] == 'BOT'): ?>disabled<?php endif; ?>></td>
						<td height='16' class='listtable_1' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_KICKBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;' <?php if ($this->_tpl_vars['players']['is_admin'] == 1 || $this->_tpl_vars['players']['steamid'] == 'BOT'): ?>disabled<?php endif; ?>></td>
					</tr>
					</form>
          <?php endforeach; else: ?>
          <tr bgcolor='#D3D8DC'>
            <td height='16' colspan='7' class='listtable_1' align='center'><br><?php echo ((is_array($_tmp='_NOPLAYERORWRONGRCON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br><br></td>
          </tr>
          <?php endif; unset($_from); ?>          
        </table>
				<?php endif; ?>
				<?php endif; ?>


