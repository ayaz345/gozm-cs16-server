<?php /* Smarty version 2.6.14, created on 2013-07-08 17:05:33
         compiled from edit_ban_ex.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'cycle', 'edit_ban_ex.tpl', 9, false),)), $this); ?>

<table cellspacing='1' class='listtable' width='100%'>
          <form name='edit' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['bhid']; ?>
'>
          <input type='hidden' name='action' value='apply_ex'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>Edit bandetails</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Player</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_nick' value='<?php echo $this->_tpl_vars['ban_info']['player_name']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>bantype</td>
            <td height='16' width='70%' class='listtable_1'>

		<select name='ban_type' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
		<option value='S' <?php if ($this->_tpl_vars['ban_info']['ban_type'] == 'S'): ?>selected<?php endif; ?>>SteamID</a>
		<option value='SI' <?php if ($this->_tpl_vars['ban_info']['ban_type'] == 'SI'): ?>selected<?php endif; ?>>SteamID and/or IP address</a>
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
            <td height='16' width='30%' class='listtable_1'>IP address</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='player_ip' value='<?php echo $this->_tpl_vars['ban_info']['player_ip']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>BanStart</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_start']; ?>
</td>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Banlength</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_length' value='<?php echo $this->_tpl_vars['ban_info']['ban_duration']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Admin</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['admin_name']; ?>
</td>
          </tr>
          
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Reason</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='ban_reason' value='<?php echo $this->_tpl_vars['ban_info']['ban_reason']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='apply_ex' value=' apply ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
	</form>
</table>