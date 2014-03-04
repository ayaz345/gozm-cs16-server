
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>{"_ACCESSLOG"|lang}</b></td>
          </tr>
          <form name="searchdate" method="post" action="{$this}">
          <tr  class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_DATE"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='date' value='{if !isset($date)}{$smarty.now|date_format:"%d-%m-%Y"}{else}{if $date != "%"}{$date}{/if}{/if}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>&nbsp;<script language="JavaScript" src="calendar1.js"></script><a href="javascript:cal1.popup();"><img src="{$dir}/images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
					</tr>
					<script language="JavaScript">
						<!--
							var cal1 = new calendar1(document.forms['searchdate'].elements['date']);
							cal1.year_scroll = true;
							cal1.time_comp = false;
						-->
					</script>
          </tr>
          <tr  class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_ADMIN"|lang}</td>
            <td height='16' width='70%' class='listtable_1'>

							<select name='admin' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
								<option value='all'>{"_ALL"|lang}</option>
								{foreach from=$admins item=admins}
								<option value='{$admins}' {if $admins == $admin}selected{/if}>{$admins}</option>
								{/foreach}
							</select>

            </td>
          </tr>
          <tr  class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_ACTION"|lang}</td>
            <td height='16' width='70%' class='listtable_1'>

							<select name='action' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px'>
								<option value='all'>{"_ALL"|lang}</option>
								{foreach from=$actions item=actions}
								<option value='{$actions}' {if $actions == $action}selected{/if}>{$actions}</option>
								{/foreach}
							</select>

            </td>
          </tr>
          <tr  class="listtable_1-{cycle values="w,g"}tr">
						<td height='16' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value='{"_SEARCH"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
					</tr>
					</form>
        </table>

				<br>

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' width='15%' class='listtable_top'><b>{"_DATE"|lang}</b></td>
            <td height='16' width='10%' class='listtable_top'><b>{"_ADMIN"|lang}</b></td>
            <td height='16' width='15%' class='listtable_top'><b>{"_IP"|lang}</b></td>
            <td height='16' width='20%' class='listtable_top'><b>{"_ACTION"|lang}</b></td>
            <td height='16' width='40%' class='listtable_top'><b>{"_REMARKS"|lang}</b></td>
          </tr>
          {foreach from=$logs item=logs}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'>{$logs.date}</td>
            <td height='16' class='listtable_1'>{$logs.username}</td>
            <td height='16' class='listtable_1'>{$logs.ip}</td>
            <td height='16' class='listtable_1'>{$logs.action}</td>
            <td height='16' class='listtable_1'>{$logs.remarks}</td>
          </tr>
          {foreachelse}
          <tr  class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' colspan='6' class='listtable_1' align='center'><br>{"_NOLOGFOUND"|lang}<br><br></td>
          </tr>
          {/foreach}
 				</table>
 				