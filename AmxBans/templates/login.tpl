
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='3' class='listtable_top'><b>{"_LOGIN"|lang}</b></td>
          </tr>
					<form name="login" method="post" action="{$this}">
					<input type='hidden' name='remember' value='on'>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>{"_USERNAME"|lang}</td>
            <td height='16' width='65%' class='listtable_1-w'><input type='text' value='' name='uid' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
          </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g'>{"_PASSWORD"|lang}</td>
            <td height='16' width='70%' class='listtable_1-g'><input type='password' value='' name='pwd' style='font-family: verdana, tahoma, arial; font-size: 10px; width: 150px'></td>
          </tr>
		  <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-w'>&nbsp;</td>
			<td height='16' width='70%' class='listtable_1-w'><input type='checkbox' value='rememberme' name='remember'>
            {"_REMEMBERME"|lang}</td>
		  </tr>
          <tr bgcolor="#D3D8DC">
            <td height='16' width='30%' class='listtable_1-g' colspan='2' align='right'><input type='submit' name='login' value=' {"_LOGIN"|lang} ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
         	</form>
        </table>
