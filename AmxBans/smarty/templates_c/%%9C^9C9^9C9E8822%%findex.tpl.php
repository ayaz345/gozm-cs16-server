<?php /* Smarty version 2.6.14, created on 2014-02-24 09:00:59
         compiled from findex.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'findex.tpl', 26, false),array('function', 'cycle', 'findex.tpl', 28, false),)), $this); ?>
<!--DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"-->
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

<!--div id="header"><a href="http://amxbans.forteam.ru<?php echo $this->_tpl_vars['dir']; ?>
"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/logo.png" /></a></div>
<div class="line-h"></div-->

<table border='0' cellpadding='0' cellspacing='0' width='100%' id='ram'>
  <tr>
    <td width='100%' valign='top' style='padding: 20px'>			
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='6' class='listtable_top'><b><?php echo ((is_array($_tmp='_BANDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		  	<td height='16' width='10%' class='listtable_1'><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='20%' class='listtable_1'><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='20%' class='listtable_1'>SteamID</td>
			<td height='16' width='10%' class='listtable_1'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='20%' class='listtable_1'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='20%' class='listtable_1'><?php echo ((is_array($_tmp='_BANBY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>			
          </tr>
		 
		 <?php $_from = $this->_tpl_vars['bhans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['bhans']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		  	<td height='16' width='10%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['date']; ?>
</td>
            <td height='16' width='20%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['player']; ?>
</td>
			<td height='16' width='20%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['player_id']; ?>
</td>
			<td height='16' width='10%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['duration']; ?>
</td>
			<td height='16' width='20%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['reason']; ?>
</td>
			<td height='16' width='20%' class='listtable_1'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' )):  echo $this->_tpl_vars['bhans']['admin'];  else: ?>hidden<?php endif; ?></td>
          </tr>
		     
          <?php endforeach; else: ?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td height='16' width='100%' colspan='6' class='listtable_1'><?php echo ((is_array($_tmp='_NOBANNED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>
		   </table>    
			<!--table cellspacing='1' width='100%'>
				<tr>
					<td align='right'>3om6u cepBep (x_x(O_o)x_x) Go Zombie !!!</td>
				</tr>
			</table-->
		</td>
	</tr>
</table>

</body>

</html>