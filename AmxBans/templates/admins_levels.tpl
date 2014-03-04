
<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>{"_ADMINSLEVELS"|lang}</b></td>
	</tr>
	<form name="sektion" method="post" action="{$this}">
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_SELECTACTION"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

			<select name='sektion' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 250px' onChange="javascript:document.sektion.submit()">
			<option value='xxx' {if $sektion == "xxx"}selected{/if}>...</option>
			{if $smarty.session.permissions_edit == "yes"}<option value='levels' {if $sektion == "levels"}selected{/if}>{"_MANAGELEVEL"|lang}</option>{/if}
			{if $smarty.session.webadmins_edit == "yes"}<option value='webadmins' {if $sektion == "webadmins"}selected{/if}>{"_MANAGEWEBADMINS"|lang}</option>{/if}
			{if $smarty.session.amxadmins_edit == "yes"}<option value='amxadmins' {if $sektion == "amxadmins"}selected{/if}>{"_MANAGEAMXADMINS"|lang}</option>{/if}
			</select>

		</td>
	</tr>
	</form>
</table>

{if $sektion == "levels" && $smarty.session.permissions_edit == "yes"}
	<br>
<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='13' class='listtable_top'><b>{"_MANAGELEVEL"|lang}</b></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1'>&nbsp;</td>
		<td height='16' class='listtable_1' colspan='6'>bans</td>
		<td height='16' class='listtable_1'>AMXadmins</td>
		<td height='16' class='listtable_1'>Webadmins</td>
		<td height='16' class='listtable_1'>{"_SERVERS"|lang}</td>
		<td height='16' class='listtable_1' colspan='3'>{"_OTHER"|lang}</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1' align='center'><i>{"_LVL"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_ADD"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EDIT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_DELETE"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_UNBAN"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_IMPORT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EXPORT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EDIT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EDIT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EDIT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_EDIT"|lang}</i></td>
		<td height='16' class='listtable_1' align='center'><i>prune DB</i></td>
		<td height='16' class='listtable_1' align='center'><i>{"_VIEWIP"|lang}</i></td>
	</tr>
	<form name='admins' method='post' action='{$this}'>
{foreach from=$level item=level}
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='2%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='{$sektion}'>{$level.level}</td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-bans_add' value='no'><input type='checkbox' name='{$level.level}-bans_add' {if $level.bans_add == "yes"}checked{/if}></td>
		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='{$level.level}-bans_edit' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' {if $level.bans_edit == "no"}selected{/if}>{"_NO"|lang}</option>
			<option value='yes' {if $level.bans_edit == "yes"}selected{/if}>{"_YES"|lang}</option>
			<option value='own' {if $level.bans_edit == "own"}selected{/if}>{"_OWN"|lang}</option>
		</td>

		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='{$level.level}-bans_delete' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' {if $level.bans_delete == "no"}selected{/if}>{"_NO"|lang}</option>
			<option value='yes' {if $level.bans_delete == "yes"}selected{/if}>{"_YES"|lang}</option>
			<option value='own' {if $level.bans_delete == "own"}selected{/if}>{"_OWN"|lang}</option>
		</td>

		<td height='16' width='9%' class='listtable_1' align='center'>
			
			<select name='{$level.level}-bans_unban' style='font-family: verdana, tahoma, arial; font-size: 10px'>
			<option value='no' {if $level.bans_unban == "no"}selected{/if}>{"_NO"|lang}</option>
			<option value='yes' {if $level.bans_unban == "yes"}selected{/if}>{"_YES"|lang}</option>
			<option value='own' {if $level.bans_unban == "own"}selected{/if}>{"_OWN"|lang}</option>
		</td>

		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-bans_import' value='no'><input type='checkbox' name='{$level.level}-bans_import' {if $level.bans_import == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-bans_export' value='no'><input type='checkbox' name='{$level.level}-bans_export' {if $level.bans_export == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-amxadmins_edit' value='no'><input type='checkbox' name='{$level.level}-amxadmins_edit' {if $level.amxadmins_edit == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-webadmins_edit' value='no'><input type='checkbox' name='{$level.level}-webadmins_edit' {if $level.webadmins_edit == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-servers_edit' value='no'><input type='checkbox' name='{$level.level}-servers_edit' {if $level.servers_edit == "yes"}checked{/if}>		
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-permissions_edit' value='no'><input type='checkbox' name='{$level.level}-permissions_edit' {if $level.permissions_edit == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-prune_db' value='no'><input type='checkbox' name='{$level.level}-prune_db' {if $level.prune_db == "yes"}checked{/if}></td>
		<td height='16' width='8%' class='listtable_1' align='center'><input type='hidden' name='{$level.level}-ip_view' value='no'><input type='checkbox' name='{$level.level}-ip_view' {if $level.ip_view == "yes"}checked{/if}>
	</tr>
{/foreach}
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1' colspan='13' align='right'>{"_ADDLEVEL"|lang} 

		<select name='new_lvl' style='font-family: verdana, tahoma, arial; font-size: 10px'>
		{foreach from=$available_levels item=available_levels}
		<option value='{$available_levels}'>{$available_levels}</option>
		{/foreach}
		</select>

		<input type='submit' name='action' value='{"_ADD"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1' colspan='13' align='right'>{"_REMOVELEVEL"|lang} 

		<select name='ex_lvl' style='font-family: verdana, tahoma, arial; font-size: 10px'>
		{foreach from=$existing_levels item=existing_levels}
		<option value='{$existing_levels}'>{$existing_levels}</option>
		{/foreach}
		</select>

		<input type='submit' name='action' value='{"_REMOVE"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1' colspan='13' align='right'><input type='submit' name='action' value='{"_APPLY"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
	</tr>
	</form>
</table>
{/if}
				
{if $sektion == "webadmins" && $smarty.session.webadmins_edit == "yes"}
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='12' class='listtable_top'><b>{"_MANAGEWEBADMINS"|lang}</b></td>
		</tr>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' width='25%' class='listtable_1'>{"_USERNAME"|lang}</td>
			<td height='16' width='25%' class='listtable_1'>{"_PASSWORD"|lang}</td>
			<td height='16' width='10%' class='listtable_1'>{"_LEVEL"|lang}</td>
			<td height='16' width='40%' class='listtable_1'>{"_ACTION"|lang}</td>
		</tr>
		{foreach from=$webadmin item=webadmin}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='hidden' name='id' value='{$webadmin.id}'><input type='text' name='username' value='{$webadmin.username}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'>
	
			{assign var=temp value=$webadmin.existing_lvls}
			<select name='level' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 50px'>
			{foreach item=item from=$temp}
			<option value='{$item}' {if $item == $webadmin.level}selected{/if}>{$item}</option>
			{/foreach}
			</select>
	
			</td>
			<td height='16' class='listtable_1' align='left'><input type='submit' name='action' value='{"_APPLY"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='{"_REMOVE"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('{"_DELADMIN"|lang}')"></td>
		</tr>
		</form>
		{/foreach}
	
		{if $action == lang("_ADDWEBADMINS")}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='hidden' name='sektion' value='webadmins'><input type='text' name='username' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
			<td height='16' class='listtable_1' align='center'>
	
			{assign var=temp value=$webadmin.existing_lvls}
			<select name='level' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 50px'>
			{foreach item=item from=$temp}
			<option value='{$item}'>{$item}</option>
			{/foreach}
			</select>
	
			</td>
			<td height='16' class='listtable_1' align='left'><input type='submit' name='action' value='{"_INSERT"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
		</tr>
		</form>
		{/if}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1' colspan='12' align='center'><input type='hidden' name='sektion' value='webadmins'><input type='submit' name='action' value='{"_ADDWEBADMINS"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
		</tr>
		</form>
	</table>
{/if}

{if $sektion == "amxadmins" && $smarty.session.amxadmins_edit == "yes"}
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='12' class='listtable_top'><b>{"_MANAGEAMXADMINS"|lang}</b></td>
		</tr>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1'>Nickname/SteamID/IP</td>
			<td height='16' class='listtable_1'>{"_PASSWORD"|lang}</td>
			<td height='16' class='listtable_1'>{"_ACCESS"|lang}</td>
			<td height='16' class='listtable_1'>{"_FLAGS"|lang}</td>
			<td height='16' class='listtable_1'>SteamID</td>
			<td height='16' class='listtable_1'>{"_NICKNAME"|lang}</td>
			<td height='16' class='listtable_1'>Admins list</td>
			<td height='16' class='listtable_1'>{"_ACTION"|lang}</td>
		</tr>
		{foreach from=$amxadmin item=amxadmin}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' width='10%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='hidden' name='id' value='{$amxadmin.id}'><input type='text' name='username' value='{$amxadmin.username}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='password' value='{$amxadmin.password}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='access' value='{$amxadmin.access}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 140px'></td>
			<td height='16' width='5%' class='listtable_1' align='center'><input type='text' name='flags' value='{$amxadmin.flags}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 30px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='steamid' value='{$amxadmin.steamid}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='nickname' value='{$amxadmin.nickname}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><select name='ashow' style='font-family: verdana, tahoma, arial; font-size: 10px'><option value='0'>Not show</option><option value='1' {if $amxadmin.ashow == "1"}selected{/if}>Show</option></select></td>
			<td height='16' width='45%' class='listtable_1' align='left'><input type='submit' name='action' value='{"_APPLY"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='{"_REMOVE"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('{"_DELADMIN"|lang}')"></td>
		</tr>
		</form>
		{/foreach}
		{if $action == lang("_ADDAMXADMINS")}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' width='10%' class='listtable_1' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='text' name='username' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='password' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='access' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 140px'></td>
			<td height='16' width='5%' class='listtable_1' align='center'><input type='text' name='flags' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 30px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='steamid' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 120px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><input type='text' name='nickname' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 100px'></td>
			<td height='16' width='10%' class='listtable_1' align='center'><select name='ashow' style='font-family: verdana, tahoma, arial; font-size: 10px'><option value='0'>Not show</option><option value='1' {if $amxadmin.ashow == "1"}selected{/if}>Show</option></select></td>
			<td height='16' width='45%' class='listtable_1' align='left'><input type='submit' name='action' value='{"_INSERT"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'></td>
		</tr>
		</form>
		{/if}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1' colspan='12' align='center'><input type='hidden' name='sektion' value='amxadmins'><input type='submit' name='action' value='{"_ADDAMXADMINS"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
		</tr>
		</form>
	</table>
	<br>
	<table cellspacing='1' class='listtable' width='100%'>
	<tr>
	<td height='16' width='60%' colspan='1' class='listtable_top'><b>{"_ACCESSPERMS"|lang}</b></td>
	<td height='16' width='40%' colspan='1' class='listtable_top'><b>{"_ACCESSFLAGS"|lang}</b></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
	<td colspan=1 class='listtable_1'>
		{"_ACCESS_A"|lang}<br>
		{"_ACCESS_B"|lang}<br>
		{"_ACCESS_C"|lang}<br>
		{"_ACCESS_D"|lang}<br>
		{"_ACCESS_E"|lang}<br>
		{"_ACCESS_F"|lang}<br>
		{"_ACCESS_G"|lang}<br>
		{"_ACCESS_H"|lang}<br>
		{"_ACCESS_I"|lang}<br>
		{"_ACCESS_J"|lang}<br>
		{"_ACCESS_K"|lang}<br>
		{"_ACCESS_L"|lang}<br>
		{"_ACCESS_M"|lang}<br>
		{"_ACCESS_N"|lang}<br>
		{"_ACCESS_O"|lang}<br>
		{"_ACCESS_P"|lang}<br>
		{"_ACCESS_Q"|lang}<br>
		{"_ACCESS_R"|lang}<br>
		{"_ACCESS_S"|lang}<br>
		{"_ACCESS_T"|lang}<br>
		{"_ACCESS_U"|lang}<br>
		{"_ACCESS_Z"|lang}<br>
	</td>
	<td colspan=1 class='listtable_1'>
		{"_FLAG_A"|lang}<br>
		{"_FLAG_B"|lang}<br>
		{"_FLAG_C"|lang}<br>
		{"_FLAG_D"|lang}<br>
		{"_FLAG_E"|lang}<br>
		{"_FLAG_K"|lang}<br>
	</td>
	</tr>
	</table>
	{/if}
	
	<!-- Comment out line 187, 198 and 211 (password field) in admins_levels.tpl then your width will be smaller -->
