
{if $display_search != "enabled" && ($smarty.session.bans_add != "yes")}
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='100' align='center'><b><font color='red' size='3'>{"_NOACCESS"|lang}</font></b></td>
         </tr>
</table> 
{else}

<table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b>{"_SEARCH"|lang}</b></td>
          </tr>
          
          <tr  class="listtable_1-{cycle values="w,g"}tr">
          	<form name="searchnick" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_NICKNAME"|lang}</td>
            <td height='16' width='65%' class='listtable_1'><input type='text' name='nick' value='{$nick}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          <tr class="listtable_1-{cycle values="w,g"}tr">
          	<form name="searchsteamid" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_STEAMID&IP"|lang}</td>
            <td height='16' width='65%' class='listtable_1'>
            	<input type='text' name='steamid' value='{$steamid}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
            	<input type='text' name='ip' value='{$ip}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'>
            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          <tr class="listtable_1-{cycle values="w,g"}tr">
          	<form name="searchreason" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_REASON"|lang}</td>
            <td height='16' width='65%' class='listtable_1'><input type='text' name='reason' value='{$reason}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
	
	<tr class="listtable_1-{cycle values="w,g"}tr">
          <form name="searchdate" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_DATE"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='date' value='{$smarty.now|date_format:"%d-%m-%Y"}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>&nbsp;<script language="JavaScript" src="calendar1.js"></script><a href="javascript:cal1.popup();"><img src="{$dir}/images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
	  </form>
<script language="JavaScript">
<!--
	var cal1 = new calendar1(document.forms['searchdate'].elements['date']);
	cal1.year_scroll = true;
	cal1.time_comp = false;
-->
</script>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
          	<form name="searchrecidivists" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_PLAYERSWITH"|lang}</td>
            <td height='16' width='65%' class='listtable_1'>

		<select name='timesbanned' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
		<option value='1'>1</option>
		<option value='2'>2</option>
		<option value='3'>3</option>
		<option value='4'>4</option>
		<option value='5'>5</option>
		<option value='6'>6</option>
		<option value='7'>7</option>
		<option value='8'>8</option>
		<option value='9'>9</option>
		<option value='10'>10</option>
		</select> {"_MOREBANSHIS"|lang}

            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
            </form>
          </tr>
          
          {if $display_admin == "enabled" || ($smarty.session.bans_add == "yes")}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <form name="searchadmin" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_ADMIN"|lang}</td>
            <td height='16' width='70%' class='listtable_1'>

		<select name='admin' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
			{section name=mysec loop=$admins}
			{html_options values=$admins[mysec].nickname output=$admins[mysec].nickname}
			{/section}
		</select>

            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          	</form>
          </tr>
          {/if}
        <tr class="listtable_1-{cycle values="w,g"}tr">
          <form name="searchserver" method="post" action="{$this}">
            <td height='16' width='30%' class='listtable_1'>{"_SERVER"|lang}</td>
            <td height='16' width='70%' class='listtable_1'>

		<select name='server' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
			{section name=mysec2 loop=$servers}
			{html_options values=$servers[mysec2].address output=$servers[mysec2].hostname}
			{/section}
			<option value=''>website</option>
		</select>

            </td>
            <td height='16' width='5%' class='listtable_1'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
      	  </form>
    	</tr>
</table>

{if isset($nick) || isset($steamid) || isset($reason) || isset($date) || isset($timesbanned) || isset($admin) || isset($server)}
<br>

<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='red' size='3'>{"_ACTIVEBANS"|lang}</font></b></td>
         </tr>
</table>

<table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}' class='listtable_top'><b>{"_DATE"|lang}</b></td>
            <td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_top'><b>{"_PLAYER"|lang}</b></td>
            <td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_top'><b>{"_ADMIN"|lang}</b></td>
            {if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_top'><b>{"_REASON"|lang}</b></td>{/if}
            <td height='16' width='16%' class='listtable_top'><b>{"_LENGHT"|lang}</b></td>
            
            <td height='16' width='2%' class='listtable_top'>&nbsp;</td>
            
          </tr>
          {foreach from=$bans item=bans}
          <tr class="listtable_1-{cycle values="w,g"}tr" style="CURSOR:pointer;" onClick="document.location = '{$dir}/ban_details.php?bid={$bans.bid}';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='2%'  class='listtable_1' align='center'><img src='{$dir}/images/{$bans.gametype}.gif'></td>
            <td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}' class='listtable_1'>{$bans.date}</td>
            <td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_1'>{$bans.player}</td>
            <td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_1'>{if $display_admin == "enabled" || ($smarty.session.bans_add == "yes")}{$bans.admin}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
           {if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_1'>{$bans.reason}</td>{/if}
            <td height='16' width='16%' class='listtable_1'>{$bans.duration}</td>
          
          <td height='16' width='2%' class='listtable_1'>
            	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="delete" method="post" action="{$dir}/admin/edit_ban.php"><input type='hidden' name='action' value='edit'><input type='hidden' name='bid' value='{$bans.bid}'><td align='right' width='1%'><input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'>&nbsp;&nbsp;</td></form>
				{/if}
				{if (($smarty.session.bans_unban == "yes") || (($smarty.session.bans_unban == "own") && ($smarty.session.uid == $bans.webadmin)))}
		<form name="unban" method="post" action="{$dir}/admin/edit_ban.php"><input type='hidden' name='action' value='unban'><input type='hidden' name='bid' value='{$bans.bid}'><td align='right' width='1%'><input type='image' SRC='{$dir}/images/locked.gif' name='action' ALT='{"_UNBAN"|lang}'>&nbsp;</td></form>
		{/if}
				{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban.php"><input type='hidden' name='action' value='delete'><input type='hidden' name='bid' value='{$bans.bid}'><td align='right' width='1%'><input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('Are you sure you want to remove ban_id {$bans.bid}?')"></td></form>
				{/if}
			</tr>
		</table>
            </td>
          
          </tr>






{foreachelse}
          <tr bgcolor="#D3D8DC">
            <td height='16' colspan='7' class='listtable_1'>No active ban(s) found for that {if isset($nick)}(part of) nickname{elseif isset($steamid)}steamID{elseif isset($date)}date{elseif isset($admin)}admin{elseif isset($server)}server{/if}.</td>
          </tr>
{/foreach}
</table>
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='red' size='2'>{"_TOTALACTBANS"|lang} ({$bans.bancount})</font></b></td>
        </tr>
</table>


<br><br>



<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='green' size='3'>{"_EXPIREDBANS"|lang}</font></b></td>
        </tr>
</table>

<table cellspacing='1' class='listtable' width='100%'>
	<tr>
       	    <td height='16' width='2%'  class='listtable_top'>&nbsp;</td>
            <td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}' class='listtable_top'><b>{"_DATE"|lang}</b></td>
            <td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_top'><b>{"_PLAYER"|lang}</b></td>
            <td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_top'><b>{"_ADMIN"|lang}</b></td>
            {if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_top'><b>{"_REASON"|lang}</b></td>{/if}
            <td height='16' width='16%' class='listtable_top'><b>{"_LENGHT"|lang}</b></td>
            <td height='16' width='2%' class='listtable_top'>&nbsp;</td>
         </tr>
          
    
   {foreach from=$exbans item=exbans}
          
          
         <tr class="listtable_1-{cycle values="w,g"}tr" style="CURSOR:pointer;" onClick="document.location = '{$dir}/ban_details_ex.php?bhid={$exbans.bhid}';" onMouseOver="this.style.backgroundColor='#C7CCD2'" onMouseOut="this.style.backgroundColor='#D3D8DC'">
            <td height='16' width='2%'  class='listtable_1' align='center'><img src='{$dir}/images/{$exbans.ex_gametype}.gif'></td>
            <td height='16' width='{if $display_reason == "enabled"}10%{else}15%{/if}%' class='listtable_1'>{$exbans.ex_date}</td>
            <td height='16' width='{if $display_reason == "enabled"}23%{else}33%{/if}' class='listtable_1'>{$exbans.ex_player}</td>
            <td height='16' width='{if $display_reason == "enabled"}20%{else}30%{/if}' class='listtable_1'>{if $display_admin == "enabled" || ($smarty.session.bans_add == "yes")}{$exbans.ex_admin}{else}<i><font color='#677882'>{"_HIDDEN"|lang}</font></i>{/if}</td>
            {if $display_reason == "enabled"}<td height='16' width='25%' class='listtable_1'>{$exbans.ex_reason}</td>{/if}
            <td height='16' width='16%' class='listtable_1'>{$exbans.ex_duration}</td>
            
            <td height='16' width='2%' class='listtable_1'>
            	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
			<tr>
				<!--{if (($smarty.session.bans_edit == "yes") || (($smarty.session.bans_edit == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="delete" method="post" action="{$dir}/admin/edit_ban_ex.php"><input type='hidden' name='action' value='edit_ex'><input type='hidden' name='bhid' value='{$exbans.bhid}'><td align='right' width='1%'><input type='image' SRC='{$dir}/images/edit.gif' name='action' ALT='{"_EDIT"|lang}'>&nbsp;&nbsp;</td></form>
				{/if}
				{if (($smarty.session.bans_delete == "yes") || (($smarty.session.bans_delete == "own") && ($smarty.session.uid == $bans.webadmin)))}
				<form name="unban" method="post" action="{$dir}/admin/edit_ban_ex.php"><input type='hidden' name='action' value='delete_ex'><input type='hidden' name='bhid' value='{$exbans.bhid}'><td align='right' width='1%'><input type='image' src='{$dir}/images/delete.gif' name='delete' alt='{"_DELETE"|lang}' onclick="javascript:return confirm('Are you sure you want to remove ban_id {$exbans.bhid}?')"></td></form>
				{/if}-->
				&nbsp;
			</tr>
		</table>
            </td>
          </tr>

{foreachelse}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' colspan='7' class='listtable_1'>No expired ban(s) found for that {if isset($steamid)}steamID{elseif isset($date)}date{elseif isset($admin)}admin{elseif isset($server)}server{/if}.</td>
          </tr>
{/foreach}

</table>
<table cellspacing='0' border='0' width='100%'>
	<tr>
		<td height='16' align='left'><b><font color='green' size='2'>{"_TOTALEXPBANS"|lang} ({$exbans.ex_bancount})</font></b></td>
        </tr>
</table>
{/if}

{/if}
