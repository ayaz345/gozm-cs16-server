
<table cellspacing='1' class='listtable' width='100%'>
	<tr>
		<td height='16' colspan='2' class='listtable_top'><b>{"_AMXBANSCONFIG"|lang}</b></td>
	</tr>
	<form name="section" method="post" action="{$this}">
	<tr  class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='100%' colspan="2" class='listtable_1'><b>{"_ADMININFO"|lang}</b></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_MAINADMINNICK"|lang}</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_nick" value="{$cfg->admin_nickname}" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px"></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_MAINADMINMAIL"|lang}</td>
		<td height='16' width='70%' class='listtable_1'><input type="text" name="admin_email" value="{$cfg->admin_email}" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px"></td>
	</tr>
		<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='100%' colspan="2" class='listtable_1'><b>{"_INFOPTIONS"|lang}</b></td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DEFAULTLANG"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

	{assign var="lang" value=$true|getlanguage}

		<select name="default_lang" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
{foreach from=$lang item="lang"}
		<option value="{$lang|escape}" {if $cfg->default_lang == $lang}selected{/if}>{$lang|escape}</option>
{/foreach}
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_USEAMXMAN"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="admin_management" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->admin_management == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->admin_management == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	<tr  class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_FANCYLAYERS"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="fancy_layers" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->fancy_layers == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->fancy_layers == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>

	</tr>

	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DISPLAY_DEMO"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_demo" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->display_demo == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->display_demo == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>

	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DEMO_MAX_SIZE"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>
	
		<input type="text" name="demo_maxsize" value="{$cfg->demo_maxsize}" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px"> (default 2mb).

		</td>
	</tr>

	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DISPLAY_COMMENTS"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_comments" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->display_comments == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->display_comments == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>

	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_VERSIONCHECK"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="version_checking" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->version_checking == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->version_checking == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_HOURSONSERVER"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="timezone_fixx" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="0" {if $cfg->timezone_fixx == "0"}selected{/if}>0</option>
		<option value="1" {if $cfg->timezone_fixx == "1"}selected{/if}>1</option>
		<option value="2" {if $cfg->timezone_fixx == "2"}selected{/if}>2</option>
		<option value="3" {if $cfg->timezone_fixx == "3"}selected{/if}>3</option>
		<option value="4" {if $cfg->timezone_fixx == "4"}selected{/if}>4</option>
		<option value="5" {if $cfg->timezone_fixx == "5"}selected{/if}>5</option>
		<option value="6" {if $cfg->timezone_fixx == "6"}selected{/if}>6</option>
		<option value="7" {if $cfg->timezone_fixx == "7"}selected{/if}>7</option>
		<option value="8" {if $cfg->timezone_fixx == "8"}selected{/if}>8</option>
		<option value="9" {if $cfg->timezone_fixx == "9"}selected{/if}>9</option>
		<option value="10" {if $cfg->timezone_fixx == "10"}selected{/if}>10</option>
		<option value="11" {if $cfg->timezone_fixx == "11"}selected{/if}>11</option>
		<option value="12" {if $cfg->timezone_fixx == "12"}selected{/if}>12</option>
		<option value="-1" {if $cfg->timezone_fixx == "-1"}selected{/if}>-1</option>
		<option value="-2" {if $cfg->timezone_fixx == "-2"}selected{/if}>-2</option>
		<option value="-3" {if $cfg->timezone_fixx == "-3"}selected{/if}>-3</option>
		<option value="-4" {if $cfg->timezone_fixx == "-4"}selected{/if}>-4</option>
		<option value="-5" {if $cfg->timezone_fixx == "-5"}selected{/if}>-5</option>
		<option value="-6" {if $cfg->timezone_fixx == "-6"}selected{/if}>-6</option>
		<option value="-7" {if $cfg->timezone_fixx == "-7"}selected{/if}>-7</option>
		<option value="-8" {if $cfg->timezone_fixx == "-8"}selected{/if}>-8</option>
		<option value="-9" {if $cfg->timezone_fixx == "-9"}selected{/if}>-9</option>
		<option value="-10" {if $cfg->timezone_fixx == "-10"}selected{/if}>-10</option>
		<option value="-11" {if $cfg->timezone_fixx == "-11"}selected{/if}>-11</option>
		<option value="-12" {if $cfg->timezone_fixx == "-12"}selected{/if}>-12</option>
		</select>

		</td>
	</tr>
	
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_PUBLICSEARCH"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_search" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->display_search == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->display_search == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DISPLAYADMIN"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_admin" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->display_admin == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->display_admin == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_DISPLAYREASON"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="display_reason" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->display_reason == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->display_reason == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_GEOIP"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="geoip" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="enabled" {if $cfg->geoip == "enabled"}selected{/if}>{"_YES"|lang}</option>
		<option value="disabled" {if $cfg->geoip == "disabled"}selected{/if}>{"_NO"|lang}</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_MAXOFFENCES"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="autopermban_count" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="disabled" {if $config->autopermban_count == "disabled" }selected{/if}>disabled</option>
		<option value="1" {if $cfg->autopermban_count == "1"}selected{/if}>1</option>
		<option value="2" {if $cfg->autopermban_count == "2"}selected{/if}>2</option>
		<option value="3" {if $cfg->autopermban_count == "3"}selected{/if}>3</option>
		<option value="4" {if $cfg->autopermban_count == "4"}selected{/if}>4</option>
		<option value="5" {if $cfg->autopermban_count == "5"}selected{/if}>5</option>
		<option value="6" {if $cfg->autopermban_count == "6"}selected{/if}>6</option>
		<option value="7" {if $cfg->autopermban_count == "7"}selected{/if}>7</option>
		<option value="8" {if $cfg->autopermban_count == "8"}selected{/if}>8</option>
		<option value="9" {if $cfg->autopermban_count == "9"}selected{/if}>9</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_BANPERPAGE"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="bans_per_page" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 100px">
		<option value="10" {if $cfg->bans_per_page == "10"}selected{/if}>10</option>
		<option value="20" {if $cfg->bans_per_page == "20"}selected{/if}>20</option>
		<option value="30" {if $cfg->bans_per_page == "30"}selected{/if}>30</option>
		<option value="40" {if $cfg->bans_per_page == "40"}selected{/if}>40</option>
		<option value="50" {if $cfg->bans_per_page == "50"}selected{/if}>50</option>
		<option value="60" {if $cfg->bans_per_page == "60"}selected{/if}>60</option>
		<option value="70" {if $cfg->bans_per_page == "70"}selected{/if}>70</option>
		<option value="80" {if $cfg->bans_per_page == "80"}selected{/if}>80</option>
		<option value="90" {if $cfg->bans_per_page == "90"}selected{/if}>90</option>
		<option value="100" {if $cfg->bans_per_page == "100"}selected{/if}>100</option>
		<option value="150" {if $cfg->bans_per_page == "150"}selected{/if}>150</option>
		<option value="200" {if $cfg->bans_per_page == "200"}selected{/if}>200</option>
		</select>

		</td>
	</tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' width='30%' class='listtable_1'>{"_RCONCLASS"|lang}</td>
		<td height='16' width='70%' class='listtable_1'>

		<select name="rcon_class" style="font-family: verdana, tahoma, arial; font-size: 10px; width: 250px">
		<option value="two" {if $cfg->rcon_class == "two"}selected{/if}>PHPrcon (http://server.counter-strike.net/phprcon/development.php)</option>
		<option value="one" {if $cfg->rcon_class == "one"}selected{/if}>[Game]Server_Infos (http://gsi.probal.fr/index_en.php)</option>
		

		</select>

		</td>
	</tr>

	<tr class="listtable_1-{cycle values="w,g"}tr">
		<td height='16' class='listtable_1' colspan='2' align='right'><input type='submit' name='dir' value='{"_CHECKDIRS"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='db' value='{"_CHECKCONNECT"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px'> <input type='submit' name='action' value='{"_APPLY"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px' onclick="javascript:return confirm('{"_SURETOSAVE"|lang}')"></td>
	</tr>
	</form>
</table>

