<?php /* Smarty version 2.6.14, created on 2014-03-29 18:00:15
         compiled from motd_details.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'cycle', 'motd_details.tpl', 31, false),)), $this); ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>AMXBans - <?php echo $this->_tpl_vars['title']; ?>
</title>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
<meta name="Keywords" content="" />
<meta name="Description" content="" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
<?php echo $this->_tpl_vars['meta']; ?>

<link rel="stylesheet" type="text/css" href="<?php echo $this->_tpl_vars['dir']; ?>
/include/amxbans.css" />
<script type="text/javascript" language="JavaScript" src="<?php echo $this->_tpl_vars['dir']; ?>
/layer.js"></script>
</head>

<body>
<div id="header"><a href="http://gozm.myarena.ru<?php echo $this->_tpl_vars['dir']; ?>
"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/logo.png" /></a></div>
<div class="line-h"></div>

<table border='0' cellpadding='0' cellspacing='0' width='100%'>
  <tr>
    <td width='100%' valign='top' style='padding: 20px'>
    <table border='0' cellpadding='0' cellspacing='0' width='100%'>
      <tr>
        <td>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>Bandetails</b></td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr"
            <td height='16' width='30%' class='listtable_1'>Player</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['player_name']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Bantype</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_type']; ?>
</td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>SteamID</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['player_id']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Banlength</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_duration']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Expires on</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_end']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Banned by</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_type']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Reason</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_tpl_vars['ban_info']['ban_reason']; ?>
</td>
          </tr>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Banned by</td>
            <td height='16' width='70%' class='listtable_1'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' )):  echo $this->_tpl_vars['ban_info']['admin_name'];  else: ?>hidden<?php endif; ?></td>
          </tr>
 
  	    <?php if ($this->_tpl_vars['history'] == 'TRUE'): ?>
          <?php $_from = $this->_tpl_vars['bhans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }$this->_foreach['bhans'] = array('total' => count($_from), 'iteration' => 0);
if ($this->_foreach['bhans']['total'] > 0):
    foreach ($_from as $this->_tpl_vars['bhans']):
        $this->_foreach['bhans']['iteration']++;
?>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Previous bans</td>
            <td height='16' width='70%' class='listtable_1'><?php echo $this->_foreach['bhans']['total']; ?>
 (3 bans means a permanent ban!)</td>
          </tr>
          <?php endforeach; else: ?>
          <tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='30%' class='listtable_1'>Previous bans</td>
            <td height='16' width='70%' class='listtable_1'>None found</td>
          </tr>
          <?php endif; unset($_from); ?>          
        </table>
	      <?php else: ?>
	      </table>
	      <?php endif; ?>

				<table cellspacing='1' width='100%'>
					<tr>
						<td align='right'>AMXBans 5.0 by YoMama/LuX & lantz69</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</body>

</html>