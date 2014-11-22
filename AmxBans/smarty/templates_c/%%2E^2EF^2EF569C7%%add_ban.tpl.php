<?php /* Smarty version 2.6.14, created on 2013-04-03 16:14:47
         compiled from add_ban.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'add_ban.tpl', 4, false),array('function', 'cycle', 'add_ban.tpl', 8, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
					<form name="addban" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
					<input type='hidden' name='action' value='insert'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_NICKNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_nick' value='<?php if (isset ( $this->_tpl_vars['post']['player_nick'] )):  echo $this->_tpl_vars['post']['player_nick'];  endif; ?>' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>
						<select name='ban_type' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
						<option value='S'>SteamID</option>
						<option value='SI'><?php echo ((is_array($_tmp="_STEAMID&IP")) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						</select>
            </td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>SteamID</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_id' value='<?php if (isset ( $this->_tpl_vars['post']['player_id'] )):  echo $this->_tpl_vars['post']['player_id'];  endif; ?>'style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'> &nbsp; (e.g. STEAM_0:1:4548)</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_ip' value='<?php if (isset ( $this->_tpl_vars['post']['player_ip'] )):  echo $this->_tpl_vars['post']['player_ip'];  endif; ?>'style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

						<select name='ban_length' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'' <?php if ($this->_tpl_vars['players']['is_admin'] == 1): ?>disabled<?php endif; ?>>
						<option value='0'><?php echo ((is_array($_tmp='_PERMANENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<optgroup label="<?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
">
						<option value='1'>1 <?php echo ((is_array($_tmp='_MIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='5'>5 <?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='10'>10 <?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='15'>15 <?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='30'>30 <?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='45'>45 <?php echo ((is_array($_tmp='_MINS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<optgroup label="<?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
">
						<option value='60'>1 <?php echo ((is_array($_tmp='_HOUR')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='120'>2 <?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='180'>3 <?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='240'>4 <?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='480'>8 <?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='720'>12 <?php echo ((is_array($_tmp='_HOURS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>

						<optgroup label="<?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
">
						<option value='1440'>1 <?php echo ((is_array($_tmp='_DAY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='2880'>2 <?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='4320'>3 <?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='5760'>4 <?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='7200'>5 <?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='8640'>6 <?php echo ((is_array($_tmp='_DAYS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<optgroup label="<?php echo ((is_array($_tmp='_WEEKS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
">
						<option value='10080'>1 <?php echo ((is_array($_tmp='_WEEK')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='20160'>2 <?php echo ((is_array($_tmp='_WEEKS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='30240'>3 <?php echo ((is_array($_tmp='_WEEKS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<optgroup label="<?php echo ((is_array($_tmp='_MONTHS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
">
						<option value='40320'>1 <?php echo ((is_array($_tmp='_MONTH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='80640'>2 <?php echo ((is_array($_tmp='_MONTHS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='120960'>3 <?php echo ((is_array($_tmp='_MONTHS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='241920'>6 <?php echo ((is_array($_tmp='_MONTHS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						<option value='483840'>12 <?php echo ((is_array($_tmp='_MONTHS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
						</select>

            </td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
					<tr bgcolor="#D3D8DC">
						<td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value=' <?php echo ((is_array($_tmp='_ADD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
        </table>



