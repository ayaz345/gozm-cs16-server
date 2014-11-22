<?php /* Smarty version 2.6.14, created on 2014-03-11 16:02:37
         compiled from cfg.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'cfg.tpl', 4, false),array('modifier', 'getlanguage', 'cfg.tpl', 25, false),array('modifier', 'escape', 'cfg.tpl', 29, false),array('function', 'cycle', 'cfg.tpl', 7, false),)), $this); ?>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_AMXBANSCONFIG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<form name="section" method="post" action="<?php echo $this->_tpl_vars['this']; ?>
">
	<tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='100%' colspan="2" class='listtable_1'><b><?php echo ((is_array($_tmp='_ADMININFO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_MAINADMINNICK')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_nick" value="<?php echo $this->_tpl_vars['cfg']->admin_nickname; ?>
" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px"></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_MAINADMINMAIL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_email" value="<?php echo $this->_tpl_vars['cfg']->admin_email; ?>
" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px"></td>
	</tr>
		<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='100%' colspan="2" class='listtable_1'><b><?php echo ((is_array($_tmp='_INFOPTIONS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DEFAULTLANG')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

	<?php $this->assign('lang', ((is_array($_tmp=$this->_tpl_vars['true'])) ? $this->_run_mod_handler('getlanguage', true, $_tmp) : smarty_modifier_getlanguage($_tmp))); ?>

		<select name="default_lang" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
<?php $_from = $this->_tpl_vars['lang']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['lang']):
?>
		<option value="<?php echo ((is_array($_tmp=$this->_tpl_vars['lang'])) ? $this->_run_mod_handler('escape', true, $_tmp) : smarty_modifier_escape($_tmp)); ?>
" <?php if ($this->_tpl_vars['cfg']->default_lang == $this->_tpl_vars['lang']): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp=$this->_tpl_vars['lang'])) ? $this->_run_mod_handler('escape', true, $_tmp) : smarty_modifier_escape($_tmp)); ?>
</option>
<?php endforeach; endif; unset($_from); ?>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_USEAMXMAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="admin_management" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->admin_management == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->admin_management == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	<tr  class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_FANCYLAYERS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="fancy_layers" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->fancy_layers == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->fancy_layers == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>

	</tr>

	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DISPLAY_DEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_demo" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->display_demo == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->display_demo == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>

	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DEMO_MAX_SIZE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>
	
		<input type="text" name="demo_maxsize" value="<?php echo $this->_tpl_vars['cfg']->demo_maxsize; ?>
" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px"> (default 2mb).

		</td>
	</tr>

	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DISPLAY_COMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_comments" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->display_comments == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->display_comments == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>

	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_VERSIONCHECK')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="version_checking" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->version_checking == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->version_checking == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_HOURSONSERVER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="timezone_fixx" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="0" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '0'): ?>selected<?php endif; ?>>0</option>
		<option value="1" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '1'): ?>selected<?php endif; ?>>1</option>
		<option value="2" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '2'): ?>selected<?php endif; ?>>2</option>
		<option value="3" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '3'): ?>selected<?php endif; ?>>3</option>
		<option value="4" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '4'): ?>selected<?php endif; ?>>4</option>
		<option value="5" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '5'): ?>selected<?php endif; ?>>5</option>
		<option value="6" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '6'): ?>selected<?php endif; ?>>6</option>
		<option value="7" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '7'): ?>selected<?php endif; ?>>7</option>
		<option value="8" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '8'): ?>selected<?php endif; ?>>8</option>
		<option value="9" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '9'): ?>selected<?php endif; ?>>9</option>
		<option value="10" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '10'): ?>selected<?php endif; ?>>10</option>
		<option value="11" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '11'): ?>selected<?php endif; ?>>11</option>
		<option value="12" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == '12'): ?>selected<?php endif; ?>>12</option>
		<option value="-1" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-1"): ?>selected<?php endif; ?>>-1</option>
		<option value="-2" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-2"): ?>selected<?php endif; ?>>-2</option>
		<option value="-3" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-3"): ?>selected<?php endif; ?>>-3</option>
		<option value="-4" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-4"): ?>selected<?php endif; ?>>-4</option>
		<option value="-5" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-5"): ?>selected<?php endif; ?>>-5</option>
		<option value="-6" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-6"): ?>selected<?php endif; ?>>-6</option>
		<option value="-7" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-7"): ?>selected<?php endif; ?>>-7</option>
		<option value="-8" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-8"): ?>selected<?php endif; ?>>-8</option>
		<option value="-9" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-9"): ?>selected<?php endif; ?>>-9</option>
		<option value="-10" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-10"): ?>selected<?php endif; ?>>-10</option>
		<option value="-11" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-11"): ?>selected<?php endif; ?>>-11</option>
		<option value="-12" <?php if ($this->_tpl_vars['cfg']->timezone_fixx == "-12"): ?>selected<?php endif; ?>>-12</option>
		</select>

		</td>
	</tr>
	
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_PUBLICSEARCH')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_search" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->display_search == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->display_search == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DISPLAYADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_admin" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->display_admin == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->display_admin == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_DISPLAYREASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_reason" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->display_reason == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->display_reason == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_GEOIP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="geoip" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" <?php if ($this->_tpl_vars['cfg']->geoip == 'enabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_YES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		<option value="disabled" <?php if ($this->_tpl_vars['cfg']->geoip == 'disabled'): ?>selected<?php endif; ?>><?php echo ((is_array($_tmp='_NO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_MAXOFFENCES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="autopermban_count" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="disabled" <?php if ($this->_tpl_vars['config']->autopermban_count == 'disabled'): ?>selected<?php endif; ?>>disabled</option>
		<option value="1" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '1'): ?>selected<?php endif; ?>>1</option>
		<option value="2" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '2'): ?>selected<?php endif; ?>>2</option>
		<option value="3" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '3'): ?>selected<?php endif; ?>>3</option>
		<option value="4" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '4'): ?>selected<?php endif; ?>>4</option>
		<option value="5" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '5'): ?>selected<?php endif; ?>>5</option>
		<option value="6" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '6'): ?>selected<?php endif; ?>>6</option>
		<option value="7" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '7'): ?>selected<?php endif; ?>>7</option>
		<option value="8" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '8'): ?>selected<?php endif; ?>>8</option>
		<option value="9" <?php if ($this->_tpl_vars['cfg']->autopermban_count == '9'): ?>selected<?php endif; ?>>9</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_BANPERPAGE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="bans_per_page" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="10" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '10'): ?>selected<?php endif; ?>>10</option>
		<option value="25" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '25'): ?>selected<?php endif; ?>>25</option>
		<option value="30" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '30'): ?>selected<?php endif; ?>>30</option>
		<option value="40" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '40'): ?>selected<?php endif; ?>>40</option>
		<option value="50" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '50'): ?>selected<?php endif; ?>>50</option>
		<option value="60" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '60'): ?>selected<?php endif; ?>>60</option>
		<option value="70" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '70'): ?>selected<?php endif; ?>>70</option>
		<option value="80" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '80'): ?>selected<?php endif; ?>>80</option>
		<option value="90" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '90'): ?>selected<?php endif; ?>>90</option>
		<option value="100" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '100'): ?>selected<?php endif; ?>>100</option>
		<option value="150" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '150'): ?>selected<?php endif; ?>>150</option>
		<option value="200" <?php if ($this->_tpl_vars['cfg']->bans_per_page == '200'): ?>selected<?php endif; ?>>200</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_RCONCLASS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="rcon_class" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px">
		<option value="two" <?php if ($this->_tpl_vars['cfg']->rcon_class == 'two'): ?>selected<?php endif; ?>>PHPrcon (http://server.counter-strike.net/phprcon/development.php)</option>
		<option value="one" <?php if ($this->_tpl_vars['cfg']->rcon_class == 'one'): ?>selected<?php endif; ?>>[Game]Server_Infos (http://gsi.probal.fr/index_en.php)</option>
		

		</select>

		</td>
	</tr>

	<tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
		<td height='16' class='listtable_1' colspan='2' align='right'><input type='submit' name='dir' value='<?php echo ((is_array($_tmp='_CHECKDIRS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='db' value='<?php echo ((is_array($_tmp='_CHECKCONNECT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='<?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_SURETOSAVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
')"></td>
	</tr>
	</form>
</table>
