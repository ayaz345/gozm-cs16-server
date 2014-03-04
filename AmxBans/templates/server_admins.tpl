
				<table cellspacing='1' class='listtable' width='100%'>
					<tr>
						<td height='16' colspan='3' class='listtable_top'><b>{"_SERVERS"|lang}</b></td>
					</tr>
					<form name="server" method="post" action="{$this}">
					<tr  class="listtable_1-{cycle values="w,g"}tr">
						<td height='16' width='30%' class='listtable_1'>{"_SELECTSERVER"|lang}</td>
						<td height='16' width='70%' class='listtable_1'><input type='hidden' name'submitted' value='true'>

							<select name='server_id' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px' onChange="javascript:document.server.submit()">
							<option value='xxx'>{"_SELECTSERVER"|lang}</option>
							{foreach from=$servers item=servers}
							<option value='{$servers.id}'{if $servers.id == $thisserver} selected{/if}>{$servers.hostname}</option>
							{/foreach}
							</select>

						</td>
					</tr>
					</form>
					<form name='admins' method='post' action='{$this}'>
					<input type='hidden' name='server_id' value='{$thisserver}'>
					<input type='hidden' name='action' value='apply'>
					<tr  class="listtable_1-{cycle values="w,g"}tr">
						<td height='16' width='30%' class='listtable_1' valign='top'>{"_SERVERADMINS"|lang}</td>
						<td height='16' width='70%' class='listtable_1'>
						{if isset($thisserver)}
						{foreach from=$all_admins item=all_admins}
						<input type='hidden' name='{$all_admins.id}' class='filecheck' value='off'>
						<input type ='checkbox' name='{$all_admins.id}' {if $all_admins.checked == 1}checked{/if}>{$all_admins.nickname} ({$all_admins.username})<br>
						{/foreach}
						{/if}
            &nbsp;</td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
						<td height='16' width='100%' class='listtable_1' colspan='2' align='right'><input type='submit' name='submit' value='{"_CONFIRM"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
					</tr>
					</form>
        </table>
