<?php /* Smarty version 2.6.14, created on 2013-04-05 10:25:33
         compiled from edit_ban.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'edit_ban.tpl', 5, false),array('function', 'cycle', 'edit_ban.tpl', 7, false),)), $this); ?>

				<?php if ($this->_tpl_vars['action'] == 'unban'): ?>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_BANDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['player_name']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>SteamID</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['player_id']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr"
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['player_ip']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_INVOKED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_start']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_duration']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_EXPIRES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_end']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_type']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_reason']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANBY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['admin_name']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['server_name']; ?>
</td>
          </tr>
          <form name='unban' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bid']; ?>
'>
          <input type='hidden' name='action' value='unban_perm'>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASONUNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='unban_reason' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value='<?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
					</form>
        </table>
				<?php elseif ($this->_tpl_vars['action'] == 'edit'): ?>
				<table cellspacing='1' class='listtable' width='100%'>
          <form name='edit' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bid']; ?>
'>
          <input type='hidden' name='action' value='apply'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_nick' value='<?php echo $this->_tpl_vars['ban_info']['player_name']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'>

						<select name='ban_type' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
						<option value='S' <?php if ($this->_tpl_vars['ban_info']['ban_type'] == 'S'): ?>selected<?php endif; ?>>SteamID</a>
						<option value='SI' <?php if ($this->_tpl_vars['ban_info']['ban_type'] == 'SI'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp="_STEAMID&IP")) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a>
						</select

						</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>SteamID</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_id' value='<?php echo $this->_tpl_vars['ban_info']['player_id']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_ip' value='<?php echo $this->_tpl_vars['ban_info']['player_ip']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_length' value='<?php echo $this->_tpl_vars['ban_info']['ban_duration']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_reason' value='<?php echo $this->_tpl_vars['ban_info']['ban_reason']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='apply' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
					</form>
        </table>
				<?php endif; ?>