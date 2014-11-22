<?php /* Smarty version 2.6.14, created on 2013-07-03 13:53:44
         compiled from ban_details.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'ban_details.tpl', 8, false),array('function', 'cycle', 'ban_details.tpl', 135, false),)), $this); ?>

<table cellspacing='1' class='listtable' width='100%'>
  <tr>
    <td height='16' colspan='2' class='listtable_top'>

	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
	<tr>
		<td width='95%'><b><?php echo ((is_array($_tmp='_BANDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
		<?php if ($this->_tpl_vars['ban_info']['id_type'] == 'bid'): ?>
		
			<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
				<input type='hidden' name='action' value='edit'>
				<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['ban_info']['bid']; ?>
'><td align='right' width='2%'>
				<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='1px' height='1'></td></form>
			<?php endif; ?>
			<?php if (( ( $_SESSION['bans_unban'] == 'yes' ) || ( ( $_SESSION['bans_unban'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
				<input type='hidden' name='action' value='unban'>
				<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['ban_info']['bid']; ?>
'><td align='right' width='2%'>
				<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/locked.gif' name='action' ALT='<?php echo ((is_array($_tmp='_UNBAN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='1px' height='1'></td></form>
			<?php endif; ?>
		<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban.php">
				<input type='hidden' name='action' value='delete'>
				<input type='hidden' name='bid' value='<?php echo $this->_tpl_vars['ban_info']['bid']; ?>
'>
		<td align='right' valign='top' width='1%'>
				<input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_WANTTOREMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ban_id <?php echo $this->_tpl_vars['ban_info']['bid']; ?>
?')"></td></form>
			<?php endif; ?>
		<?php endif; ?>
		
		<?php if ($this->_tpl_vars['ban_info']['id_type'] == 'bhid'): ?>
		
			<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php">
				<input type='hidden' name='action' value='edit_ex'>
				<input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['ban_info']['bid']; ?>
'>
		<td align='right' width='2%'>
				<input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='1px' height='1'></td></form>
			<?php endif; ?>
			
		<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php">
				<input type='hidden' name='action' value='delete_ex'>
				<input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['ban_info']['bid']; ?>
'>
		<td align='right' valign='top' width='2%'>
				<input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_WANTTOREMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ban_id <?php echo $this->_tpl_vars['ban_info']['bid']; ?>
?')"></td></form>
			<?php endif; ?>
		<?php endif; ?>
	</tr>
	</table>

    </td>
  </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_PLAYER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['ban_info']['player_name']; ?>
</td>
          </tr>
		  <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_MAP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['ban_info']['map_name']; ?>
</td>
          </tr>	
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_BANTYPE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php echo $this->_tpl_vars['ban_info']['ban_type']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>SteamID</td>
            <td height='16' width='70%' class='listtable_1-w'><?php if ($this->_tpl_vars['ban_info']['player_id'] == "&nbsp;"): ?><i><font color='#677882'><?php echo ((is_array($_tmp='_NOSTEAMID')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php else:  echo $this->_tpl_vars['ban_info']['player_id'];  endif; ?></td>
          </tr>
		  <?php if ($this->_tpl_vars['ban_info']['player_id'] <> "&nbsp;"): ?>
		  <tr bgcolor="#D3D8DC" align='left'>
			<td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_COMMUNITYPROFILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			<td height='16' width='70%' class='listtable_1-g'><a href="http://steamcommunity.com/profiles/<?php echo $this->_tpl_vars['ban_info']['player_comid']; ?>
" target="_blank">http://steamcommunity.com/profiles/<?php echo $this->_tpl_vars['ban_info']['player_comid']; ?>
</a></td>
		  </tr>
		  <?php endif; ?>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_IP')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php if ($_SESSION['ip_view'] == 'yes' || $this->_tpl_vars['ban_info']['player_ip'] == "&nbsp;"):  echo $this->_tpl_vars['ban_info']['player_ip'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_INVOKED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php echo $this->_tpl_vars['ban_info']['ban_start']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_BANLENGHT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['ban_info']['ban_duration']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_EXPIRES')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php echo $this->_tpl_vars['ban_info']['ban_end']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['ban_info']['ban_reason']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_BANBY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' ) || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['ban_info']['admin_name'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_BANON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['ban_info']['server_name']; ?>
</td>
          </tr>
</table>
				
<?php if ($this->_tpl_vars['unban_info']['verify'] == 'TRUE'): ?>
	<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_UNBANDETAILS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_BANREMOVED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['unban_info']['unban_start']; ?>
</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_REASON')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' ) || ( $_SESSION['bans_add'] == 'yes' ) || ( $this->_tpl_vars['unban_info']['unban_reason'] == 'tempban expired' ) || ( $this->_tpl_vars['unban_info']['unban_reason'] == 'tempban expired' )):  echo $this->_tpl_vars['unban_info']['unban_reason'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_REMBY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' ) || ( $_SESSION['bans_add'] == 'yes' ) || ( $this->_tpl_vars['unban_info']['unban_reason'] == 'tempban expired' ) || ( $this->_tpl_vars['unban_info']['unban_reason'] == 'tempban expired' )):  echo $this->_tpl_vars['unban_info']['admin_name'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
          </tr>
        </table>
<?php endif; ?>
  
<?php if ($this->_tpl_vars['history'] == 'TRUE'): ?>
	<br>
    <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' colspan='6' class='listtable_top'><b><?php echo ((is_array($_tmp='_BANHISTORY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
    <?php $_from = $this->_tpl_vars['bhans']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['bhans']):
?>
          <tr bgcolor="#D3D8DC" class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr" style="cursor:pointer !important;" onClick="document.location = '<?php echo $this->_tpl_vars['dir']; ?>
/ban_details.php?bhid=<?php echo $this->_tpl_vars['bhans']['bhid']; ?>
';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>10%<?php else: ?>15%<?php endif; ?>' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['date']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>23%<?php else: ?>33%<?php endif; ?>' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['player']; ?>
</td>
            <td height='16' width='<?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?>20%<?php else: ?>30%<?php endif; ?>' class='listtable_1'><?php if (( $this->_tpl_vars['display_admin'] == 'enabled' ) || ( $_SESSION['bans_add'] == 'yes' )):  echo $this->_tpl_vars['bhans']['admin'];  else: ?><i><font color='#677882'><?php echo ((is_array($_tmp='_HIDDEN')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</font></i><?php endif; ?></td>
            <?php if ($this->_tpl_vars['display_reason'] == 'enabled'): ?><td height='16' width='25%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['reason']; ?>
</td><?php endif; ?>
            <td height='16' width='16%' class='listtable_1'><?php echo $this->_tpl_vars['bhans']['duration']; ?>
</td>
            
            
            <td height='16' width='4%' class='listtable_1'>
    <table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="delete" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php"><input type='hidden' name='action' value='edit_ex'><input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['bhans']['bhid']; ?>
'><td align='right' width='2%' class='listtable_1'><input type='image' SRC='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='action' ALT='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'><img src='<?php echo $this->_tpl_vars['dir']; ?>
/images/spacer.gif' width='1px' height='1'></td></form>
				<?php endif; ?>
				<?php if (( ( $_SESSION['bans_delete'] == 'yes' ) || ( ( $_SESSION['bans_delete'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>
				<form name="unban" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/admin/edit_ban_ex.php"><input type='hidden' name='action' value='delete_ex'><input type='hidden' name='bhid' value='<?php echo $this->_tpl_vars['bhans']['bhid']; ?>
'><td align='right' valign='top' width='2%' class='listtable_1'><input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_WANTTOREMOVE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ban_id <?php echo $this->_tpl_vars['bhans']['bhid']; ?>
?')"></td></form>
				<?php endif; ?>
			</tr>
		</table>
            </td>
          </tr>
    <?php endforeach; else: ?>
          <tr bgcolor="#D3D8DC">
            <td height='16' colspan='6' class='listtable_1-w'><?php echo ((is_array($_tmp='_NOBANNED')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>          
    </table>
<?php endif; ?>


<?php if ($this->_tpl_vars['display_demo'] == 'enabled'): ?>
<br>
   <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' colspan=2 class='listtable_top'><b><?php echo ((is_array($_tmp='_PLAYERDEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
<?php $_from = $this->_tpl_vars['demos']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['demos']):
?>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_FILE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><a href=<?php echo $this->_tpl_vars['dir']; ?>
/getdemo.php?demo=<?php echo $this->_tpl_vars['demos']['demo_id']; ?>
><?php echo $this->_tpl_vars['demos']['demo']; ?>
</a></td>
           </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_COMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><?php if (( $this->_tpl_vars['demos']['comment'] != "" )):  echo $this->_tpl_vars['demos']['comment'];  else:  echo ((is_array($_tmp='_NOCOMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  endif; ?></td>
           </tr>
    <?php endforeach; else: ?>
          <tr bgcolor="#D3D8DC">
            <td height='16' class='listtable_1-w'><?php echo ((is_array($_tmp='_NODEMO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
          </tr>
          <?php endif; unset($_from); ?>
</table>
<?php endif; ?>

<?php if ($this->_tpl_vars['display_comments'] == 'enabled'): ?>

<?php if (isset ( $this->_tpl_vars['edit'] )): ?>
<br>
	<table cellspacing='1' class='listtable' width='100%'>
			<form name="edit" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/<?php if ($this->_tpl_vars['ban_info']['bid']): ?>ban_details.php?bid=<?php echo $this->_tpl_vars['ban_info']['bid'];  else: ?>ban_details_ex.php?bhid=<?php echo $this->_tpl_vars['ban_info']['bhid'];  endif; ?>">
			<input type='hidden' name='action' value='update'>
			<input type='hidden' name='id' value='<?php echo $this->_tpl_vars['edit_id']; ?>
'>
			  <tr>
				<td height='16' colspan='2' class='listtable_top'><b><?php echo ((is_array($_tmp='_EDITCOMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_NAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
				<td height='16' width='70%' class='listtable_1-w'><?php echo $this->_tpl_vars['edit_name']; ?>
</td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_MAIL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
				<td height='16' width='70%' class='listtable_1-g'><input type='text' name='email' value='<?php echo $this->_tpl_vars['edit_email']; ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_COMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			 <td height='16' width='70%' class='listtable_1-w'><textarea cols=50 rows=6 name=comment id="ns_comment"><?php echo $this->_tpl_vars['edit_comment']; ?>
</textarea></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='100%' class='listtable_1-g' colspan='2' align='right'><input type='submit' name='apply' value=' <?php echo ((is_array($_tmp='_APPLY')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
			  </tr>
			  </form>
	</table>
<?php endif; ?>
<br>

   <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' class='listtable_top'><b><?php echo ((is_array($_tmp='_COMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
		<?php $_from = $this->_tpl_vars['ban_comments']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['ban_comments']):
?>
			<tr>
				<td height='10' class='listtable_1-w' align='left'>
				<table border=0 cellpadding=0 cellspacing=0 width=100%>
					<tr>
						<td><td height='10'>
							<b>#<?php echo $this->_tpl_vars['ban_comments']['order']; ?>
</b> - <i><?php echo $this->_tpl_vars['ban_comments']['date']; ?>
</i> - <a href=mailto:<?php echo $this->_tpl_vars['ban_comments']['email']; ?>
><b><?php echo $this->_tpl_vars['ban_comments']['name']; ?>
</b></a>
						</td>
						<?php if (( $_SESSION['bans_edit'] == 'yes' )): ?>
							<td height='10' align='right'>
								<?php echo $this->_tpl_vars['ban_comments']['addr']; ?>

							</td>
							<td	height='10' align='right'>
								<form name="editpost" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/<?php if ($this->_tpl_vars['ban_info']['bid']): ?>ban_details.php?bid=<?php echo $this->_tpl_vars['ban_info']['bid'];  else: ?>ban_details_ex.php?bhid=<?php echo $this->_tpl_vars['ban_info']['bhid'];  endif; ?>">
									<input type='hidden' name='action' value='edit'>
									<input type='hidden' name='id' value='<?php echo $this->_tpl_vars['ban_comments']['cid']; ?>
'>
									<input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/edit.gif' name='edit' alt='<?php echo ((is_array($_tmp='_EDIT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
'>
							</td></form>
							<td height='10'>
								<form name="deletepost" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/<?php if ($this->_tpl_vars['ban_info']['bid']): ?>ban_details.php?bid=<?php echo $this->_tpl_vars['ban_info']['bid'];  else: ?>ban_details_ex.php?bhid=<?php echo $this->_tpl_vars['ban_info']['bhid'];  endif; ?>">
									<input type='hidden' name='action' value='delete'>
									<input type='hidden' name='id' value='<?php echo $this->_tpl_vars['ban_comments']['cid']; ?>
'>
									<input type='image' src='<?php echo $this->_tpl_vars['dir']; ?>
/images/delete.gif' name='delete' alt='<?php echo ((is_array($_tmp='_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' onclick="javascript:return confirm('<?php echo ((is_array($_tmp='_COMMENT_PRE_DELETE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 <?php echo $this->_tpl_vars['ban_comments']['cid']; ?>
?')">
							</td></form>
						<?php endif; ?>
					</tr>
				</table>
				</td>
			</tr>
			<tr bgcolor="#ececec">
				<td height='16'  style="padding:7px;" colspan=<?php if (( ( $_SESSION['bans_edit'] == 'yes' ) || ( ( $_SESSION['bans_edit'] == 'own' ) && ( $_SESSION['uid'] == $this->_tpl_vars['bans']['webadmin'] ) ) )): ?>4<?php else: ?>3<?php endif; ?>>
					<?php echo $this->_tpl_vars['ban_comments']['comment']; ?>

					<br><br>
				</td>
			</tr>
		<?php endforeach; else: ?>
			<tr bgcolor="#D3D8DC">
				<td height='16' class='listtable_1-g'><?php echo ((is_array($_tmp='_NOCOMMENTS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
			</tr>
		<?php endif; unset($_from); ?>
	</table>
<br>

<table cellspacing='1' class='listtable' width='100%'>

	<form name="addcomment" method="post" action="<?php echo $this->_tpl_vars['dir']; ?>
/<?php if ($this->_tpl_vars['ban_info']['bid']): ?>ban_details.php?bid=<?php echo $this->_tpl_vars['ban_info']['bid'];  else: ?>ban_details_ex.php?bhid=<?php echo $this->_tpl_vars['ban_info']['bhid'];  endif; ?>" enctype="multipart/form-data" onsubmit="return verifchamps()">
		<input type='hidden' name='action' value='insert'>
        <tr>
			<td height='16' width='14%' colspan='6' class='listtable_top'><b><?php echo ((is_array($_tmp='_ADDCOMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
        </tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'><?php echo ((is_array($_tmp='_NAME')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-w'><input type='text' name='name' id="ns_name"></td>
		</tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_MAIL')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='70%' class='listtable_1-g'><input type='text' name='email' id="ns_email"></td>
		</tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w' valign=top><?php echo ((is_array($_tmp='_COMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' class='listtable_1-w'>
		<textarea cols=50 rows=6 name=comment id="ns_comment"></textarea>
		</td>
		</tr>
			<tr bgcolor="#D3D8DC"> 
				<td height='16' width='30%' class='listtable_1-g'><?php echo ((is_array($_tmp='_SCODE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td> 
				<td height='16' width='70%' class='listtable_1-g'><?php echo ((is_array($_tmp='_SCODEENTER')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
<br> 
					<img src=<?php echo $this->_tpl_vars['dir']; ?>
/code.php alt="Security code" style="border: 1px #000000 solid;"><br> 
					<input type='text' name='verify' id="verify_code"> 
				</td> 
			</tr>
			<tr bgcolor="#D3D8DC">
				<td height='16' width='100%' class='listtable_1-w' colspan='2' align='right'>
					<input type='submit' name='submit' value=' <?php echo ((is_array($_tmp='_ADDCOMMENT')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
 ' style='font-family: verdana, tahoma, arial; font-size: 10px;'>
				</td>
			</tr>
		</tr>
    </form>
</table>
<?php endif; ?>