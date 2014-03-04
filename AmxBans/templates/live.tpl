        <table cellspacing='0' width='100%'>
          <tr>
            <td height='16' colspan=4 align='left'><b>{"_SELECTSERVER"|lang} </b>
		<select name="server" size="1" style="background: #D3D8DC; font-family: verdana, tahoma, arial; font-size: 10px;" onChange="jumpMenu(this, '_top');">
           {foreach from=$servers item=servers}
      <option value="{$dir}/live.php?sid={$servers.id}" {if $servers.id == $s} selected{/if}>{$servers.hostname}</option>
          {/foreach}
	</select>
	</td>
	</tr>
           <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width=30% valign=top>

        <table cellspacing='1' width='100%' class='listtable'>
	{foreach from=$server item=server}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td  width=30% height='16' class='listtable_top' colspan=2><b>{$server.hostname}</b></td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1' colspan=2 align=center valign=middle><img style="border:1px #000000 solid;" src=../stats/images/maps/{$server.mappic}.jpg alt="{$server.map}"></td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'><b>{"_ADDRESS"|lang}</b></td><td height='16' class='listtable_1'>{$server.address}</td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'><b>{"_MAP"|lang}</b></td><td height='16' class='listtable_1'>{$server.map}</td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'><b>{"_GAMETYPE"|lang}</b></td><td height='16' class='listtable_1'>{$server.game}</td>
          </tr>
            {if $server.timelimit == "0"}
				<tr class="listtable_1-{cycle values="w,g"}tr">
					<td height='16' class='listtable_1'><b>{"_TIMELIMIT"|lang}</b></td><td height='16' class='listtable_1'>{"_NOTIMELIMIT"|lang}</td>
				</tr>
			{else}
				<tr class="listtable_1-{cycle values="w,g"}tr">
					<td height='16' class='listtable_1'><b>{"_TIMELEFT"|lang}</b></td><td height='16' class='listtable_1'>{$server.timeleft} min</td>
				</tr>
				<tr  class="listtable_1-{cycle values="w,g"}tr">
					<td height='16' class='listtable_1'><b>{"_TIMELIMIT"|lang}</b></td><td height='16' class='listtable_1'>{$server.timelimit}:00 min</td>
				</tr>
			{/if}
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'><b>{"_PLAYER"|lang}</b></td><td height='16' class='listtable_1'>{$server.cur_players}/{$server.max_players}</td>
          </tr>
		  <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1' valign='top'><b>AntiCheat</b></td>
				<td height='16' class='listtable_1'>
					{if $addons.vac}{$addons.vac}{/if}
					{if $addons.vac && $addons.steambans}, {/if}
					{if $addons.steambans}<a href="http://www.steambans.com">SB</a> {$addons.steambans}{/if}
				</td>
          </tr>
		  <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1' valign='top'><b>Addons</b></td>
				<td height='16' class='listtable_1'>
					<table cellspacing='1' width=70%>
						{if $addons.metamod}<tr bgcolor='#D3D8DC'><td><a href="http://www.metamod.org">Metamod</a></td><td>v{$addons.metamod}</td></tr>{/if}
						{if $addons.amxx}<tr bgcolor='#D3D8DC'><td><a href="http://www.amxmodx.org">AMXModX</a></td><td>v{$addons.amxx}</td></tr>{/if}
						{if $addons.amxbans}<tr bgcolor='#D3D8DC'><td><a href="http://www.amxbans.de">AMXBans</a></td><td>v{$addons.amxbans}</td></tr>{/if}
					</table>
				
				
				</td>
          </tr>
	{/foreach}
	</table>
		</td>
<td valign=top>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_top'><b>{"_PLAYER"|lang}</b></td>
		<td height='16' width=50 class='listtable_top'><b>{"_FRAGS"|lang}</b></td>
		<td height='16' width=50  class='listtable_top'><b>{"_PING"|lang}</b></td>
		<td height='16' width=50  class='listtable_top'><b>{"_ONLINE"|lang}</b></td>
          </tr>
          {foreach from=$players item=players}
		<tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' class='listtable_1'>{if $geoip == "enabled"}{if $players.cc != ""}<img src='{$dir}/images/flags/{$players.cc|lower}.gif' alt='{$players.cn}'> {else}<img src='{$dir}/images/spacer.gif' width='18' height='12'> {/if}{/if}{if $players.name != ""}{$players.name}{else}Player Connecting...{/if}</td>
            <td height='16' width=50  class='listtable_1'>{$players.frag}&nbsp;</td>
            <td height='16' width=50  class='listtable_1'>{$players.ping}&nbsp;</td>
            <td height='16' width=50  class='listtable_1'>{$players.time}&nbsp;</td>
					</tr>
          {foreachelse}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' colspan=4 class='listtable_1' align='center'><br>{"_NOPLAYER"|lang}<br><br></td>
          </tr>
          {/foreach}    
		</table>
</td></tr>
        </table>