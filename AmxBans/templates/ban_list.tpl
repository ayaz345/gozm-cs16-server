
{if $new_version == 1}
<table cellspacing='1' class='listtable' width='100%'>
  <tr>
  	<td height='16' class='listtable_top'><b>New AMX Frontend available!</b></td>
  </tr>
  <tr bgcolor="#D3D8DC">
	<td height='32' width='100%' class='listtable_1' colspan='5' align='center'><br><br>A new version of the AMXBans frontend is available. You can download it at:<br><font color='#ff0000'><a href='{$update_url}' class='alert'  target="_blank">{$update_url}</a></font><br><br></td>
  </tr>
</table>
<br>
{/if}


<table cellspacing='1' class='listtable' width='100%'>
  <tr>
	<td height='16' width='2%' class='listtable_top'>&nbsp;</td>
	<td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}' class='listtable_top'><b>{"_DATE"|lang}</b></td>
	<td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_top'><b>{"_PLAYER"|lang}</b></td>
	<td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_top'><b>{"_ADMIN"|lang}</b></td>
	{if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_top'><b>{"_REASON"|lang}</b></td>{/if}
	<td height='16' width='20%' class='listtable_top'><b>{"_LENGHT"|lang}</b></td>
	{if $display_comments == "enabled"}<td height='16' width='25%' class='listtable_top'><b>{"_COMMENTS"|lang}</b></td>{/if}
	{if $display_demo == "enabled"}<td height='16' width='25%' class='listtable_top'><b>{"_DEMO"|lang}</b></td>{/if}

  </tr>
	<tr bgcolor="#D3D8DC">
   		<td height='16' width='100%' class='listtable_1' colspan='{if $display_demo == "enabled"}8{else}7{/if}' align='right'>
        {"_YOUR"|lang} {"_IP"|lang}: <b>{$pages_results.ip}</b> &nbsp;|&nbsp;
		{if $pages_results.prev_page <> ""}<b><a href="{$dir}/ban_list.php?view={$pages_results.view}&amp;page={$pages_results.prev_page}" class='hover_black'><img src='images/left.gif' border='0' alt='{"_PREVIOUS"|lang}'></a></b> {/if}
			{"_DISPLAYING"|lang} {$pages_results.page_start} - {$pages_results.page_end} {"_OF"|lang} {$pages_results.all_bans} {"_RESULTS"|lang}
		{if $pages_results.next_page <> ""} <b><a href="{$dir}/ban_list.php?view={$pages_results.view}&amp;page={$pages_results.next_page}" class='hover_black'><img src='images/right.gif' border='0' alt="{"_NEXT"|lang}"></a></b>{/if}
		</td>
	</tr>


          {foreach from=$bans item=bans}
          <tr class="listtable_1-{cycle values="w,g"}tr" style="CURSOR:pointer;" {if ($fancy_layers == "enabled")}onClick="ToggleLayer('layer_{$bans.bid}');"{else}onClick="document.location = '{$dir}/ban_details.php?bid={$bans.bid}';"{/if} onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' class='listtable_1' align='center'><img src='{$dir}/images/{$bans.gametype}.gif'></td>
            <td height='16' class='listtable_1'>{$bans.date}</td>
            <td height='16' class='listtable_1'>{if $geoip == "enabled"}{if $bans.cc != ""}<img src='{$dir}/images/flags/{$bans.cc|lower}.gif' alt='{$bans.cn}'> {else}<img src='{$dir}/images/spacer.gif' width='18' height='12'> {/if}{/if}{$bans.player}</td>
            <td height='16' class='listtable_1'>{if ($display_admin == "enabled") || ($smarty.session.bans_add == "yes")}{$bans.admin}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
            {if $display_reason == "enabled"}<td height='16' class='listtable_1'>{$bans.ban_reason}&nbsp;</td>{/if}
            <td height='16' class='listtable_1'>
{if ($fancy_layers != "enabled")}

<table width='100%' border='0' cellpadding='0' cellspacing='0'>
	<tr>
		<td width='50%'>{$bans.duration}</td>
		{if $display_demo == "enabled"}
		{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}

			<form name="adddemo" method="post" action="{$dir}/admin/demo.php">
			<input type='hidden' name='action' value='add'>
			<input type='hidden' name='bid' value='{$bans.bid}'>
			<td align='right' width='2%'>
			<input type='image' SRC='{$dir}/images/demo.gif' name='action' ALT='{"_DEMOCP"|lang}'>
			</td></form>
		{/if}
		{/if}
		{if (($smarty.session.bans_unban == "yes") || (($smarty.session.bans_unban == "own") && ($smarty.session.uid == $bans.webadmin)))}
			<form name="delete" method="post" action="{$dir}/admin/edit_ban.php">
			<input type='hidden' name='action' value='edit'>
			<input type='hidden' name='bid' value='{$bans.bid}'>
		<td align='right' width='2%'>
			<input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'><img src='{$dir}/images/spacer.gif' width='3px' height='1'></td></form>
		{/if}

		{if (($smarty.session.bans_unban == "yes") || (($smarty.session.bans_unban == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
				<input type='hidden' name='action' value='unban'>
				<input type='hidden' name='bid' value='{$bans.bid}'>
			<td align='right' width='2%'>
					<input type='image' SRC='{$dir}/images/locked.gif' name='action' ALT='{"_UNBAN"|lang}'><img src='{$dir}/images/spacer.gif' width='3px' height='1'></td></form>
		{/if}
		{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
				<input type='hidden' name='action' value='delete'>
				<input type='hidden' name='bid' value='{$bans.bid}'>
			<td align='right' valign='top' width='2%'>
					<input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_WANTTOREMOVE"|lang} ban_id {$bans.bid}?')"></td></form>
		{/if}
	</tr>
</table>

{else}{$bans.duration}{/if}
	</td>
{if $display_comments == "enabled"}<td height='16' class='listtable_1' align=center>{$bans.commentscount}</td>{/if}
{if $display_demo == "enabled"}<td height='16' class='listtable_1' align=center>
	{if $bans.demo <> NULL}
		<a href="{$dir}/ban_details.php?bid={$bans.demo}">{"_DEMO"|lang}</a>
	{else}
		<nobr>{"_NODEMO"|lang}</nobr>
	{/if}</td>
{/if}

     </tr>


{if ($fancy_layers == "enabled")}


          <tr id="layer_{$bans.bid}" style="display: none" bgcolor="#C7CCD2">
          	<td colspan="{if $display_reason == "enabled"}8{else}7{/if}" class='listtable_1'><br><center>

	<table cellspacing='1' class='listtable' width='80%'>
          <tr>
            <td height='16' colspan='2' class='d-top align='left'>

		<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<td width='92%' '><b>{"_BANDETAILS"|lang}</b></td>
				<td align='right' width='2%'><a href="{$dir}/ban_details.php?bid={$bans.bid}"><img src='{$dir}/images/details.gif' name='action' ALT='{"_DETAILS"|lang}' border='0'></a><img src='{$dir}/images/spacer.gif' width='2px' height='1'></td>
				{if $display_demo == "enabled"}
				{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}

					<form name="adddemo" method="post" action="{$dir}/admin/demo.php">
					<input type='hidden' name='action' value='add'>
					<input type='hidden' name='bid' value='{$bans.bid}'>
					<td align='right' width='2%'>
					<input type='image' SRC='{$dir}/images/demo.gif' name='action' ALT='{"_DEMOCP"|lang}'>
					</td></form>
				{/if}
				{/if}
				{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
					<form name="delete" method="post" action="{$dir}/admin/edit_ban.php">
					<input type='hidden' name='action' value='edit'>
					<input type='hidden' name='bid' value='{$bans.bid}'>
				<td align='right' width='2%'><input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'><img src='{$dir}/images/spacer.gif' width='2px' height='1'></td></form>
				{/if}
				{if (($smarty.session.bans_unban == "yes") || (($smarty.session.bans_unban == "own") && ($smarty.session.uid == $bans.webadmin)))}
						<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
						<input type='hidden' name='action' value='unban'>
						<input type='hidden' name='bid' value='{$bans.bid}'>
				<td align='right' width='2%'>
					<input type='image' SRC='{$dir}/images/locked.gif' name='action' ALT='{"_UNBAN"|lang}'><img src='{$dir}/images/spacer.gif' width='2px' height='1'></td></form>
				{/if}
				{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
						<form name="unban" method="post" action="{$dir}/admin/edit_ban.php">
						<input type='hidden' name='action' value='delete'>
						<input type='hidden' name='bid' value='{$bans.bid}'>
				<td align='right' valign='top' width='2%'><input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('{"_WANTTOREMOVE"|lang} ban_id {$bans.bid}?')"></td></form>
				{/if}
			</tr>
		</table>

            </td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c'  width='20%'><b>{"_PLAYER"|lang}</b></td>
            <td height='16' class='d-c'  width='80%'>{$bans.player}</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c'  width='20%'><b>{"_MAP"|lang}</b></td>
            <td height='16' class='d-c'  width='80%'>{$bans.map}</td>
          </tr>
          <!--tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_BANTYPE"|lang}</b></td>
            <td height='16' class='d-c'  width='80%'>{$bans.ban_type}</td>
          </tr-->
          <tr  align='left'>
            <td height='16' class='d-c'  width='20%'><b>SteamID</b></td>
            <td height='16' class='d-c' width='80%'>{if $bans.player_id == "&nbsp;"}<i><font color='#677882'>{"_NOSTEAMID"|lang}</font></i>{else}{$bans.player_id}{/if}</td>
          </tr>
		  <!--tr  align='left'>
			<td height='16' class='d-c'  width='20%'><b>{"_COMMUNITYPROFILE"|lang}</b></td>
			<td height='16' class='d-c'  width='80%'>
			{if $bans.player_id <> NULL}
				<a href="http://steamcommunity.com/profiles/{$bans.player_comid}" target="_blank">http://steamcommunity.com/profiles/{$bans.player_comid}</a>
			{else}
				&nbsp;
			{/if}
			</td>
		  </tr-->
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_IP"|lang}</b></td>
	     <td height='16' class='d-c' width='80%' >{if $smarty.session.ip_view == "yes" || $bans.player_id == "&nbsp;"}{$bans.player_ip}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%' ><b>{"_INVOKED"|lang}</b></td>
            <td height='16' class='d-c' width='80%'>{$bans.ban_start}</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_BANLENGHT"|lang}</b></td>
            <td height='16' class='d-c' width='80%' >{$bans.ban_duration}</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_EXPIRES"|lang}</b></td>
            <td height='16' class='d-c' width='80%' >{$bans.ban_end}</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_REASON"|lang}</b></td>
            <td height='16' class='d-c' width='80%' >{$bans.ban_reason}&nbsp;</td>
          </tr>
          <tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_BANBY"|lang}</b></td>
            <td height='16' class='d-c' width='80%' >{if $display_admin == "enabled" || ($smarty.session.bans_add == "yes")}{$bans.admin} ({$bans.webadmin}){else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
          </tr>
          <!--tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_BANON"|lang}</b></td>
            <td height='16' class='d-c' width='80%' >{$bans.server_name}</td>
          </tr-->
          <!--tr align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_PREVOFF"|lang}</b></td>
            <td height='16' class='d-c' width='80%'>{$bans.bancount}</td>
          </tr-->
          	{if $display_comments == "enabled"}
          <tr bgcolor="#D3D8DC" align='left'>
            <td height='16' class='d-c' width='20%'><b>{"_COMMENTS"|lang}</b></td>
            <td height='16' class='d-c' width='80%'>
				{if $bans.comments <> NULL}
					<a href="{$dir}/ban_details.php?bid={$bans.bid}">{"_READ"|lang}</a> {$bans.commentscount}
				{else}
					{"_NOCOMMENTS"|lang} <a href="{$dir}/ban_details.php?bid={$bans.bid}">{"_ADDCOMMENT"|lang}</a>
				{/if}
			</td>
          </tr>
		{/if}
        </table><br>

          	</td>
          </tr>
{/if}
{foreachelse}
          <tr >
            <td height='16' class='d-c'  colspan='{if $fancy_layers != "enabled"}7{else}8{/if}'>{"_NOBANSFOUND"|lang}</td>
          </tr>
{/foreach}
{if $display_comments=="enabled" || $display_demo=="enabled"}
          <tr>
            <td height='16' class='d-c'  colspan='{if $fancy_layers != "enabled"}7{else}8{/if}'>
                {if $display_comments == "enabled"}{"_TOTALCOMMENTS"|lang} : {$count_comm}<br>{/if}
                {if $display_demo == "enabled"}{"_TOTALDEMOS"|lang} : {$count_demo}{/if}&nbsp;
            </td>
          </tr>
{/if}
	</table>


