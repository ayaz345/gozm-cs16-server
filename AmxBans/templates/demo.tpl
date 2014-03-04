        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>{"_FILESLIST"|lang}</b></td>
          </tr>
{foreach from=$demos item=demos}
	<form name="editdemo" method="post" action="{$this}?bid={$demos.bid}" enctype="multipart/form-data">
	<input type='hidden' name='action' value='edit'>
	<input type='hidden' name='did' value='{$demos.did}'>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_FILE"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><input type='text' name='demo' value="{$demos.demo}" size="52"></td>
           </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_COMMENT"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><textarea name="comment" rows="3" cols="40" size="40" class="post">{$demos.comment}</textarea></td>
           </tr>
	<tr class="listtable_1-{cycle values="w,g"}tr">
	<td colspan=2>
	<input type="checkbox" name="delete" value="1"/>{"_DELETE_FILE"|lang}
	</td></tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
          <td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value=' {"_APPLY"|lang} ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
          {foreachelse}
          <tr class="listtable_1-{cycle values="w,g"}tr">
          <td height='16' width='100%' colspan='2' class='listtable_1' align='right'>{"_NOFILES"|lang}</td>
          </tr>
          {/foreach}
        </table>
<br>
        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='2' class='listtable_top'><b>{"_ADDDEMO"|lang}</b></td>
          </tr>
					<form name="adddemo" method="post" action="{$this}" enctype="multipart/form-data">
					<input type='hidden' name='action' value='insert'>
					<input type='hidden' name='bid' value={$bid}>
          <tr class="listtable_1-{cycle values="w,g"}tr"">
            <td height='16' width='30%' class='listtable_1'>{"_FILE"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><input type="file" name="userfile" size="40" maxlength="80"></td>
           </tr>
          <tr class="listtable_1-{cycle values="w,g"}tr">
            <td height='16' width='30%' class='listtable_1'>{"_COMMENT"|lang}</td>
            <td height='16' width='70%' class='listtable_1'><textarea name="comment" rows="3" cols="40" size="40" class="post"></textarea></td>
           </tr>
					<tr class="listtable_1-{cycle values="w,g"}tr"
						<td height='16' width='100%' colspan='2' class='listtable_1' align='right'><input type='submit' name='submit' value=' {"_ADDDEMO"|lang} ' style='font-family: verdana, tahoma, arial; font-size: 10px;'></td>
          </tr>
          </form>
        </table>