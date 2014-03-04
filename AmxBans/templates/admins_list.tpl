	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='3' class='listtable_top'><b>AMXadmins</b></td>
		</tr>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' class='listtable_1' align='center'><b>{"_NICKNAME"|lang}</b></td>
			<td height='16' class='listtable_1' align='center'><b>{"_ACCESSFLAGS"|lang}</b></td>
			<td height='16' class='listtable_1' align='center'><b>{"_DATE"|lang}</b></td>
		</tr>
		{foreach from=$amxadmin item=amxadmin}
		<form name='admins' method='post' action='{$this}'>
		<tr class="listtable_1-{cycle values="w,g"}tr">
			<td height='16' width='10%' class='listtable_1'>{$amxadmin.nickname}</td>
			<!--td height='16' width='10%' class='listtable_1'>{$amxadmin.access}</td-->
			<td height='16' width='10%' class='listtable_1'>{if strlen($amxadmin.access)>1}ADMIN{/if} {if strlen($amxadmin.access)==1}VIP{/if}</td>
			<td height='16' width='10%' class='listtable_1'>{$amxadmin.time}</td>
		</tr>
		{/foreach}
</table>
<!--br>
	<table cellspacing='1' class='listtable' width='100%'>
		<tr>
			<td height='16' colspan='2' class='listtable_top'><b>{"_ACCESSPERMS"|lang}</b></td>
		</tr>

		<tr class="listtable_1-{cycle values="w,g"}tr">
		<td colspan=2 class='listtable_1'>
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
		</tr>
		</table-->