
<table cellspacing='1' class='listtable' width='100%'>
  <tr>
    <td height='16' colspan='2' class='listtable_top'>

	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
	<tr>
		<td width='95%'><b>{"_BANDETAILS"|lang}</b></td>
		{if $ban_info.id_type == "bid"}

			{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="delete" method="post" action="{$dir}/admin/edit_ban.php">
				<input type='hidden' name='action' value='edit'>
				<input type='hidden' name='bid' value='{$ban_info.bid}'><td align='right' width='2%'>
				<input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'><img src='{$dir}/images/spacer.gif' width='1px' height='1'></td></form>
			{/if}
			{if (($smarty.session.bans_unban == "yes") || (($smarty.session.bans_unban == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
				<input type='hidden' name='action' value='unban'>
				<input type='hidden' name='bid' value='{$ban_info.bid}'><td align='right' width='2%'>
				<input type='image' SRC='{$dir}/images/locked.gif' name='action' ALT='{"_UNBAN"|lang}'><img src='{$dir}/images/spacer.gif' width='1px' height='1'></td></form>
			{/if}
		{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
				<input type='hidden' name='action' value='delete'>
				<input type='hidden' name='bid' value='{$ban_info.bid}'>
		<td align='right' valign='top' width='1%'>
				<input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_WANTTOREMOVE"|lang} ban_id {$ban_info.bid}?')"></td></form>
			{/if}
		{/if}

		{if $ban_info.id_type == "bhid"}

			{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="delete" method="post" action="{$dir}/admin/edit_ban_ex.php">
				<input type='hidden' name='action' value='edit_ex'>
				<input type='hidden' name='bhid' value='{$ban_info.bid}'>
		<td align='right' width='2%'>
				<input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'><img src='{$dir}/images/spacer.gif' width='1px' height='1'></td></form>
			{/if}

		{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban_ex.php">
				<input type='hidden' name='action' value='delete_ex'>
				<input type='hidden' name='bhid' value='{$ban_info.bid}'>
		<td align='right' valign='top' width='2%'>
				<input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_WANTTOREMOVE"|lang} ban_id {$ban_info.bid}?')"></td></form>
			{/if}
		{/if}
	</tr>
	</table>

    </td>
  </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_PLAYER"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{$ban_info.player_name}</td>
          </tr>
		  <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_MAP"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{$ban_info.map_name}</td>
          </tr>
          <!--tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_BANTYPE"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{$ban_info.ban_type}</td>
          </tr-->
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>SteamID</td>
            <td height='16' width='70%' class='listtable_1-w'>{if $ban_info.player_id == "&nbsp;"}<i><font color='#677882'>{"_NOSTEAMID"|lang}</font></i>{else}{$ban_info.player_id}{/if}</td>
          </tr>
		  <!--tr bgcolor="#D3D8DC" align='left'>
			<td height='16' width='30%' class='listtable_1-g'>{"_COMMUNITYPROFILE"|lang}</td>
			<td height='16' width='70%' class='listtable_1-g'><a href="http://steamcommunity.com/profiles/{$ban_info.player_comid}" target="_blank">http://steamcommunity.com/profiles/{$ban_info.player_comid}</a></td>
		  </tr-->
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_IP"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{if $smarty.session.ip_view == "yes" || $ban_info.player_ip == "&nbsp;"}{$ban_info.player_ip}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_INVOKED"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{$ban_info.ban_start}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_BANLENGHT"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{$ban_info.ban_duration}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_EXPIRES"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{$ban_info.ban_end}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_REASON"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{$ban_info.ban_reason}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_BANBY"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{if ($display_admin == "enabled") || ($smarty.session.bans_add == "yes")}{$ban_info.admin_name}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
          <!--tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_BANON"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{$ban_info.server_name}</td>
          </tr-->
</table>

{if $unban_info.verify == "TRUE"}
	<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>{"_UNBANDETAILS"|lang}</b></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_BANREMOVED"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{$unban_info.unban_start}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_REASON"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{if ($display_admin == "enabled") || ($smarty.session.bans_add == "yes") || ($unban_info.unban_reason == "tempban expired") || ($unban_info.unban_reason == "tempban expired")}{$unban_info.unban_reason}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_REMBY"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'>{if ($display_admin == "enabled") || ($smarty.session.bans_add == "yes") || ($unban_info.unban_reason == "tempban expired") || ($unban_info.unban_reason == "tempban expired")}{$unban_info.admin_name}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
        </table>
{/if}

{if $history == "TRUE"}
	<br>
    <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' colspan='6' class='listtable_top'><b>{"_BANHISTORY"|lang}</b></td>
          </tr>
    {foreach from=$bhans item=bhans}
          <tr bgcolor="#D3D8DC" class="listtable_1-{cycle values="w,g"}tr" style="cursor:pointer !important;" onClick="document.location = '{$dir}/ban_details.php?bhid={$bhans.bhid}';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}' class='listtable_1'>{$bhans.date}</td>
            <td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_1'>{$bhans.player}</td>
            <td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_1'>{if ($display_admin == "enabled") || ($smarty.session.bans_add == "yes")}{$bhans.admin}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
            {if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_1'>{$bhans.reason}</td>{/if}
            <td height='16' width='16%' class='listtable_1'>{$bhans.duration}</td>


            <td height='16' width='4%' class='listtable_1'>
    <table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="delete" method="post" action="{$dir}/admin/edit_ban_ex.php"><input type='hidden' name='action' value='edit_ex'><input type='hidden' name='bhid' value='{$bhans.bhid}'><td align='right' width='2%' class='listtable_1'><input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'><img src='{$dir}/images/spacer.gif' width='1px' height='1'></td></form>
				{/if}
				{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban_ex.php"><input type='hidden' name='action' value='delete_ex'><input type='hidden' name='bhid' value='{$bhans.bhid}'><td align='right' valign='top' width='2%' class='listtable_1'><input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_WANTTOREMOVE"|lang} ban_id {$bhans.bhid}?')"></td></form>
				{/if}
			</tr>
		</table>
            </td>
          </tr>
    {foreachelse}
          <tr bgcolor="#D3D8DC">
            <td height='16' colspan='6' class='listtable_1-w'>{"_NOBANNED"|lang}</td>
          </tr>
          {/foreach}
    </table>
{/if}


{if $display_demo == "enabled"}
<br>
   <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' colspan=2 class='listtable_top'><b>{"_PLAYERDEMO"|lang}</b></td>
          </tr>
{foreach from=$demos item=demos}
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_FILE"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'><a href={$dir}/getdemo.php?demo={$demos.demo_id}>{$demos.demo}</a></td>
           </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_COMMENT"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'>{if ($demos.comment != "")}{$demos.comment}{else}{"_NOCOMMENTS"|lang}{/if}</td>
           </tr>
    {foreachelse}
          <tr bgcolor="#D3D8DC">
            <td height='16' class='listtable_1-w'>{"_NODEMO"|lang}</td>
          </tr>
          {/foreach}
</table>
{/if}

{if $display_comments == "enabled"}

{if isset($edit)}
<br>
	<table cellspacing='1' class='listtable' width='100%'>
			<form name="edit" method="post" action="{$dir}/{if $ban_info.bid}ban_details.php?bid={$ban_info.bid}{else}ban_details_ex.php?bhid={$ban_info.bhid}{/if}">
			<input type='hidden' name='action' value='update'>
			<input type='hidden' name='id' value='{$edit_id}'>
			  <tr>
				<td height='16' colspan='2' class='listtable_top'><b>{"_EDITCOMMENT"|lang}</b></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-w'>{"_NAME"|lang}</td>
				<td height='16' width='70%' class='listtable_1-w'>{$edit_name}</td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-g'>{"_MAIL"|lang}</td>
				<td height='16' width='70%' class='listtable_1-g'><input type='text' name='email' value='{$edit_email}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 350px'></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-w'>{"_COMMENT"|lang}</td>
			 <td height='16' width='70%' class='listtable_1-w'><textarea cols=50 rows=6 name=comment id="ns_comment">{$edit_comment}</textarea></td>
			  </tr>
			  <tr bgcolor="#D3D8DC">
				<td height='16' width='100%' class='listtable_1-g' colspan='2' align='right'><input type='submit' name='apply' value=' {"_APPLY"|lang} ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
			  </tr>
			  </form>
	</table>
{/if}
<br>

   <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='14%' class='listtable_top'><b>{"_COMMENTS"|lang}</b></td>
          </tr>
		{foreach from=$ban_comments item=ban_comments}
			<tr>
				<td height='10' class='listtable_1-w' align='left'>
				<table border=0 cellpadding=0 cellspacing=0 width=100%>
					<tr>
						<td><td height='10'>
							<b>#{$ban_comments.order}</b> - <i>{$ban_comments.date}</i> - <a href=mailto:{$ban_comments.email}><b>{$ban_comments.name}</b></a>
						</td>
						{if ($smarty.session.bans_edit == "yes")}
							<td height='10' align='right'>
								{$ban_comments.addr}
							</td>
							<td	height='10' align='right'>
								<form name="editpost" method="post" action="{$dir}/{if $ban_info.bid}ban_details.php?bid={$ban_info.bid}{else}ban_details_ex.php?bhid={$ban_info.bhid}{/if}">
									<input type='hidden' name='action' value='edit'>
									<input type='hidden' name='id' value='{$ban_comments.cid}'>
									<input type='image' src='{$dir}/images/edit.gif' name='edit' alt='{"_EDIT"|lang}'>
							</td></form>
							<td height='10'>
								<form name="deletepost" method="post" action="{$dir}/{if $ban_info.bid}ban_details.php?bid={$ban_info.bid}{else}ban_details_ex.php?bhid={$ban_info.bhid}{/if}">
									<input type='hidden' name='action' value='delete'>
									<input type='hidden' name='id' value='{$ban_comments.cid}'>
									<input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_COMMENT_PRE_DELETE"|lang} {$ban_comments.cid}?')">
							</td></form>
						{/if}
					</tr>
				</table>
				</td>
			</tr>
			<tr bgcolor="#ececec">
				<td height='16'  style="padding:7px;" colspan={if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}4{else}3{/if}>
					{$ban_comments.comment}
					<br><br>
				</td>
			</tr>
		{foreachelse}
			<tr bgcolor="#D3D8DC">
				<td height='16' class='listtable_1-g'>{"_NOCOMMENTS"|lang}</td>
			</tr>
		{/foreach}
	</table>
<br>

<table cellspacing='1' class='listtable' width='100%'>

	<form name="addcomment" method="post" action="{$dir}/{if $ban_info.bid}ban_details.php?bid={$ban_info.bid}{else}ban_details_ex.php?bhid={$ban_info.bhid}{/if}" enctype="multipart/form-data" onsubmit="return verifchamps()">
		<input type='hidden' name='action' value='insert'>
        <tr>
			<td height='16' width='14%' colspan='6' class='listtable_top'><b>{"_ADDCOMMENT"|lang}</b></td>
        </tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_NAME"|lang}</td>
            <td height='16' width='70%' class='listtable_1-w'><input type='text' name='name' id="ns_name"></td>
		</tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_MAIL"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'><input type='text' name='email' id="ns_email"></td>
		</tr>

        <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w' valign=top>{"_COMMENT"|lang}</td>
            <td height='16' class='listtable_1-w'>
		<textarea cols=50 rows=6 name=comment id="ns_comment"></textarea>
		</td>
		</tr>
			<tr bgcolor="#D3D8DC">
				<td height='16' width='30%' class='listtable_1-g'>{"_SCODE"|lang}</td>
				<td height='16' width='70%' class='listtable_1-g'>{"_SCODEENTER"|lang}<br>
					<img src={$dir}/code.php alt="Security code" style="border: 1px #000000 solid;"><br>
					<input type='text' name='verify' id="verify_code">
				</td>
			</tr>
			<tr bgcolor="#D3D8DC">
				<td height='16' width='100%' class='listtable_1-w' colspan='2' align='right'>
					<input type='submit' name='submit' value=' {"_ADDCOMMENT"|lang} ' style='font-family: verdana, tahoma, arial; font-size: 10px;'>
				</td>
			</tr>
		</tr>
    </form>
</table>
{/if}