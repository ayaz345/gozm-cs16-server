<!--DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"-->
<html>
<head>
<title>AMXBans - {$title}</title>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
<meta name="Keywords" content="" />
<meta name="Description" content="" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
{$meta}
<link rel="stylesheet" type="text/css" href="{$dir}/include/amxbans.css" />
<script type="text/javascript" language="JavaScript" src="{$dir}/layer.js"></script>
</head>

<body>

<!--div id="header"><a href="http://amxbans.forteam.ru{$dir}"><img src="{$dir}/images/logo.png" /></a></div>
<div class="line-h"></div-->

<table border='0' cellpadding='0' cellspacing='0' width='100%' id='ram'>
  <tr>
    <td width='100%' valign='top' style='padding: 20px'>			
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='6' class='listtable_top'><b>{"_BANDETAILS"|lang}</b></td>
          </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
		  	<td height='16' width='10%' class='listtable_1'>{"_DATE"|lang}</td>
            <td height='16' width='20%' class='listtable_1'>{"_PLAYER"|lang}</td>
			<td height='16' width='20%' class='listtable_1'>SteamID</td>
			<td height='16' width='10%' class='listtable_1'>{"_BANLENGHT"|lang}</td>
			<td height='16' width='20%' class='listtable_1'>{"_REASON"|lang}</td>
			<td height='16' width='20%' class='listtable_1'>{"_BANBY"|lang}</td>			
          </tr>
		 
		 {foreach from=$bhans item=bhans}
          <tr class="listtable_1-{cycle values="w,g"}tr">
		  	<td height='16' width='10%' class='listtable_1'>{$bhans.date}</td>
            <td height='16' width='20%' class='listtable_1'>{$bhans.player}</td>
			<td height='16' width='20%' class='listtable_1'>{$bhans.player_id}</td>
			<td height='16' width='10%' class='listtable_1'>{$bhans.duration}</td>
			<td height='16' width='20%' class='listtable_1'>{$bhans.reason}</td>
			<td height='16' width='20%' class='listtable_1'>{if ($display_admin == "enabled")}{$bhans.admin}{else}hidden{/if}</td>
          </tr>
		     
          {foreachelse}
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='100%' colspan='6' class='listtable_1'>{"_NOBANNED"|lang}</td>
          </tr>
          {/foreach}
		   </table>    
			<!--table cellspacing='1' width='100%'>
				<tr>
					<td align='right'>3om6u cepBep (x_x(O_o)x_x) Go Zombie !!!</td>
				</tr>
			</table-->
		</td>
	</tr>
</table>

</body>

</html>