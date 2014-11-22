<?php /* Smarty version 2.6.14, created on 2014-04-09 01:18:20
         compiled from ban_list.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'ban_list.tpl', 18, false),array('modifier', 'lower', 'ban_list.tpl', 40, false),array('function', 'cycle', 'ban_list.tpl', 37, false),)), $this); ?>

<?php if ($this->_tpl_vars['new_version'] == 1): ?>
<table cellspacing='1' class='listtable' width='100%'>
  <tr>
  	<td height='16' class='listtable_top'><b>New AMX Frontend available!</b></td>
  </tr>
  <tr bgcolor="#D3D8DC">
	<td height='32' width='100%' class='listtable_1' colspan='5' align='center'><br><br>A new version of the AMXBans frontend is available. You can download it at:<br><font color='#ff0000'><a href='<?php echo $this->_tpl_vars['update_url']; ?>
' class='alert'  target="_blank"><?php echo $this->_tpl_vars['update_url']; ?>
</a></font><br><br></td>
  </tr>
</table>
<br>
<?php endif; ?>
 

<table cellspacing='1' class='listtable' width='100%'>
  <tr>
	<td height='16' width='2%' class='listtable_top'>&nbsp;</td>
	<td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_DATE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	<td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	<td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADMIN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_top'><b><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><?php endif; ?>
	<td height='16' width='20%' class='listtable_top'><b><?php echo ((is_array($_tmp='_LENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	<?php if ($this->_tpl_vars['display_comments'] == 'enabled'): ?><td height='16' width='25%' class='listtable_top'><b><?php echo ((is_array($_tmp='_COMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><?php endif; ?>
	<?php if ($this->_tpl_vars['display_demo'] == 'enabled'): ?><td height='16' width='25%' class='listtable_top'><b><?php echo ((is_array($_tmp='_DEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td><?php endif; ?>
    
  </tr>
	<tr bgcolor="#D3D8DC">
   		<td height='16' width='100%' class='listtable_1' colspan='<?php if ($this->_tpl_vars['display_demo'] == 'enabled'): ?>8<?php else: ?>7<?php endif; ?>' align='right'>
		<?php if ($this->_tpl_vars['pages_results']['prev_page'] <> ""): ?><b><a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_list.php?view=<?php echo $this->_tpl_vars['pages_results']['view']; ?>
&amp;page=<?php echo $this->_tpl_vars['pages_results']['prev_page']; ?>
" class='hover_black'><img src='images/left.gif' border='0' alt="<?php echo ((is_array($_tmp='_PREVIOUS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
"></a></b> <?php endif; ?>
			<?php echo ((is_array($_tmp='_DISPLAYING')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_tpl_vars['pages_results']['page_start']; ?>
 - <?php echo $this->_tpl_vars['pages_results']['page_end']; ?>
 <?php echo ((is_array($_tmp='_OF')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_tpl_vars['pages_results']['all_bans']; ?>
 <?php echo ((is_array($_tmp='_RESULTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>

		<?php if ($this->_tpl_vars['pages_results']['next_page'] <> ""): ?> <b><a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_list.php?view=<?php echo $this->_tpl_vars['pages_results']['view']; ?>
&amp;page=<?php echo $this->_tpl_vars['pages_results']['next_page']; ?>
" class='hover_black'><img src='images/right.gif' border='0' alt="<?php echo ((is_array($_tmp='_NEXT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
"></a></b><?php endif; ?>
		</td>
	</tr>
          
          
          <?php $_from = $this->_tpl_vars['bans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['bans']):
?>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr" style="CURSOR:pointer;" <?php if (( $this->_tpl_vars['fancy_layers'] == 'enabled' )): ?>onClick="ToggleLayer('layer_<?php echo $this->_tpl_vars['bans']['bid']; ?>
');"<?php else: ?>onClick="document.location = '<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['bid']; ?>
';"<?php endif; ?> onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' class='listtable_1' align='center'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/<?php echo $this->_tpl_vars['bans']['gametype']; ?>
.gif'></td>
            <td height='16' class='listtable_1'><?php echo $this->_tpl_vars['bans']['date']; ?>
</td>
            <td height='16' class='listtable_1'><?php if ($this->_tpl_vars['geoip'] == 'enabled'):  if ($this->_tpl_vars['bans']['cc'] != ""): ?><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/flags/<?php echo ((is_array($_tmp=$this->_tpl_vars['bans']['cc'])) ? $this->_run_mod_handler('lower', true, $_tmp) : smarty_modifier_lower($_tmp)); ?>
.gif' alt='<?php echo $this->_tpl_vars['bans']['cn']; ?>
'> <?php else: ?><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='18' height='12'> <?php endif;  endif;  echo $this->_tpl_vars['bans']['player']; ?>
</td>
            <td height='16' class='listtable_1'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' ) || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['bans']['admin'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
            <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' class='listtable_1'><?php echo $this->_tpl_vars['bans']['ban_reason']; ?>
&nbsp;</td><?php endif; ?>
            <td height='16' class='listtable_1'>
<?php if (( $this->_tpl_vars['fancy_layers'] != 'enabled' )): ?>

<table width='100%' border='0' cellpadding='0' cellspacing='0'>
	<tr>
		<td width='50%'><?php echo $this->_tpl_vars['bans']['duration']; ?>
</td>
		<?php if ($this->_tpl_vars['display_demo'] == 'enabled'): ?>
		<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>

			<form name="adddemo" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/demo.php">
			<input type='hidden' name='action' value='add'>
			<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
			<td align='right' width='2%'>
			<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/demo.gif' name='action' ALT='<?php echo ((is_array($_tmp='_DEMOCP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>
			</td></form>
		<?php endif; ?>
		<?php endif; ?>
		<?php if (( ( $_SESSION['bans_unban'] == 'yes' ) || ( ( $_SESSION['bans_unban'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
			<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
			<input type='hidden' name='action' value='edit'>
			<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
		<td align='right' width='2%'>
			<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='3px' height='1'></td></form>
		<?php endif; ?>
		
		<?php if (( ( $_SESSION['bans_unban'] == 'yes' ) || ( ( $_SESSION['bans_unban'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
				<input type='hidden' name='action' value='unban'>
				<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
			<td align='right' width='2%'>
					<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/locked.gif' name='action' ALT='<?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='3px' height='1'></td></form>
		<?php endif; ?>
		<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
				<input type='hidden' name='action' value='delete'>
				<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
			<td align='right' valign='top' width='2%'>
					<input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_WANTTOREMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ban_id <?php echo $this->_tpl_vars['bans']['bid']; ?>
?')"></td></form>
		<?php endif; ?>
	</tr>
</table>

<?php else:  echo $this->_tpl_vars['bans']['duration'];  endif; ?>
	</td>
<?php if ($this->_tpl_vars['display_comments'] == 'enabled'): ?><td height='16' class='listtable_1' align=center><?php echo $this->_tpl_vars['bans']['commentscount']; ?>
</td><?php endif;  if ($this->_tpl_vars['display_demo'] == 'enabled'): ?><td height='16' class='listtable_1' align=center>
	<?php if ($this->_tpl_vars['bans']['demo'] <> NULL): ?>
		<a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['demo']; ?>
"><?php echo ((is_array($_tmp='_DEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a>
	<?php else: ?>
		<nobr><?php echo ((is_array($_tmp='_NODEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</nobr>
	<?php endif; ?></td>
<?php endif; ?>

     </tr>


<?php if (( $this->_tpl_vars['fancy_layers'] == 'enabled' )): ?>


          <tr id="layer_<?php echo $this->_tpl_vars['bans']['bid']; ?>
" style="display: none" bgcolor="#C7CCD2">
          	<td colspan="<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>8<?php else: ?>7<?php endif; ?>" class='listtable_1'><br><center>

	<table cellspacing='1' class='listtable' width='80%'>
          <tr>
            <td height='16' colspan='2' class='d-top align='left'>

		<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<td width='92%' '><b><?php echo ((is_array($_tmp='_BANDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
				<td align='right' width='2%'><a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['bid']; ?>
"><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/details.gif' name='action' ALT='<?php echo ((is_array($_tmp='_DETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' border='0'></a><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='2px' height='1'></td>
				<?php if ($this->_tpl_vars['display_demo'] == 'enabled'): ?>
				<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>

					<form name="adddemo" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/demo.php">
					<input type='hidden' name='action' value='add'>
					<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
					<td align='right' width='2%'>
					<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/demo.gif' name='action' ALT='<?php echo ((is_array($_tmp='_DEMOCP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>
					</td></form>
				<?php endif; ?>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
					<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
					<input type='hidden' name='action' value='edit'>
					<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
				<td align='right' width='2%'><input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='2px' height='1'></td></form>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_unban'] == 'yes' ) || ( ( $_SESSION['bans_unban'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
						<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
						<input type='hidden' name='action' value='unban'>
						<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
				<td align='right' width='2%'>
					<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/locked.gif' name='action' ALT='<?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='2px' height='1'></td></form>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
						<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
						<input type='hidden' name='action' value='delete'>
						<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['bans']['bid']; ?>
'>
				<td align='right' valign='top' width='2%'><input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_WANTTOREMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ban_id <?php echo $this->_tpl_vars['bans']['bid']; ?>
?')"></td></form>
				<?php endif; ?>
			</tr>
		</table>

            </td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c'  width='20%'><b><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c'  width='80%'><?php echo $this->_tpl_vars['bans']['player']; ?>
</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c'  width='20%'><b><?php echo ((is_array($_tmp='_MAP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c'  width='80%'><?php echo $this->_tpl_vars['bans']['map']; ?>
</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%''><b><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c'  width='80%'><?php echo $this->_tpl_vars['bans']['ban_type']; ?>
</td>
          </tr>
          <tr  align='left'>
            <td height='16' class='d-c'  width='20%'><b>SteamID</b></td>
            <td height='16' class='d-c' width='80%'><?php if ($this->_tpl_vars['bans']['player_id'] == "&nbsp;"): ?><i><font color='#677882'><?php echo ((is_array($_tmp='_NOSTEAMID')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php else:  echo $this->_tpl_vars['bans']['player_id'];  endif; ?></td>
          </tr>
		  
		  <tr  align='left'>
			<td height='16' class='d-c'  width='20%'><b><?php echo ((is_array($_tmp='_COMMUNITYPROFILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
			<td height='16' class='d-c'  width='80%'>
			<?php if ($this->_tpl_vars['bans']['player_id'] <> NULL): ?>
				<a href="http://steamcommunity.com/profiles/<?php echo $this->_tpl_vars['bans']['player_comid']; ?>
" target="_blank">http://steamcommunity.com/profiles/<?php echo $this->_tpl_vars['bans']['player_comid']; ?>
</a>
			<?php else: ?>
				&nbsp;
			<?php endif; ?>
			</td>
		  </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
	     <td height='16' class='d-c' width='80%' ><?php if ($_SESSION['ip_view'] == 'yes' || $this->_tpl_vars['bans']['player_id'] == "&nbsp;"):  echo $this->_tpl_vars['bans']['player_ip'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td> 
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%' ><b><?php echo ((is_array($_tmp='_INVOKED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%'><?php echo $this->_tpl_vars['bans']['ban_start']; ?>
</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%' ><?php echo $this->_tpl_vars['bans']['ban_duration']; ?>
</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_EXPIRES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%' ><?php echo $this->_tpl_vars['bans']['ban_end']; ?>
</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%' ><?php echo $this->_tpl_vars['bans']['ban_reason']; ?>
&nbsp;</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_BANBY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%' ><?php if ($this->_tpl_vars['display_admin'] == 'enabled' || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['bans']['admin']; ?>
 (<?php echo $this->_tpl_vars['bans']['webadmin']; ?>
)<?php else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_BANON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%' ><?php echo $this->_tpl_vars['bans']['server_name']; ?>
</td>
          </tr>
          <tralign='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_PREVOFF')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%'><?php echo $this->_tpl_vars['bans']['bancount']; ?>
</td>
          </tr>
          	<?php if ($this->_tpl_vars['display_comments'] == 'enabled'): ?>
          <tr bgcolor="#D3D8DC" align='left'>
            <td height='16' class='d-c' width='20%'><b><?php echo ((is_array($_tmp='_COMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
            <td height='16' class='d-c' width='80%'>
				<?php if ($this->_tpl_vars['bans']['comments'] <> NULL): ?>
					<a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['bid']; ?>
"><?php echo ((is_array($_tmp='_READ')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a> <?php echo $this->_tpl_vars['bans']['commentscount']; ?>

				<?php else: ?>
					<?php echo ((is_array($_tmp='_NOCOMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <a href="<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bid=<?php echo $this->_tpl_vars['bans']['bid']; ?>
"><?php echo ((is_array($_tmp='_ADDCOMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</a>
				<?php endif; ?>
			</td>
          </tr>
		<?php endif; ?>
        </table><br>

          	</td>
          </tr>
<?php endif;  endforeach; else: ?>
          <tr >
            <td height='16' class='d-c'  colspan='<?php if ($this->_tpl_vars['fancy_layers'] != 'enabled'): ?>7<?php else: ?>8<?php endif; ?>'><?php echo ((is_array($_tmp='_NOBANSFOUND')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
<?php endif; unset($_from);  if ($this->_tpl_vars['display_comments'] == 'enabled' || $this->_tpl_vars['display_demo'] == 'enabled'): ?>
          <tr>
            <td height='16' class='d-c'  colspan='<?php if ($this->_tpl_vars['fancy_layers'] != 'enabled'): ?>7<?php else: ?>8<?php endif; ?>''>
		<?php if ($this->_tpl_vars['display_comments'] == 'enabled'):  echo ((is_array($_tmp='_TOTALCOMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 : <?php echo $this->_tpl_vars['count_comm']; ?>
<br><?php endif; ?>
		<?php if ($this->_tpl_vars['display_demo'] == 'enabled'):  echo ((is_array($_tmp='_TOTALDEMOS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 : <?php echo $this->_tpl_vars['count_demo'];  endif; ?>&nbsp;</td>
          </tr> 
<?php endif; ?>
	</table>

