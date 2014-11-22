<?php /* Smarty version 2.6.14, created on 2013-04-02 06:46:20
         compiled from login.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'login.tpl', 4, false),)), $this); ?>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b><?php echo ((is_array($_tmp='_LOGIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
					<form name="login" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
					<input type='hidden' name='remember' value='on'>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_USERNAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='65%' class='listtable_1-w'><input type='text' value='' name='uid' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_PASSWORD')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><input type='password' value='' name='pwd' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
          </tr>
		  <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>&nbsp;</td>
			<td height='16' width='70%' class='listtable_1-w'><input type='checkbox' value='rememberme' name='remember'>
            <?php echo ((is_array($_tmp='_REMEMBERME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		  </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g' colspan='2' align='right'><input type='submit' name='login' value=' <?php echo ((is_array($_tmp='_LOGIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
         	</form>
        </table>