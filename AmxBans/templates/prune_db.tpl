

        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='4' class='listtable_top'><b>{"_PRUNEDB"|lang}</b></td>
          </tr>
          <form name='prunebans' method='post' action='{$this}'>
          <tr class="listtable_1-{cycle values="w,g"}tr">
          	<td height='16' width='30%' class='listtable_1'>{"_NBEXPBANS"|lang}</td>
            <td height='16' width='60%' class='listtable_1'>{if ($bans2prune == 0 && bans2prune2 == 0)}{"_NONE"|lang}{else}{$bans2prune} / {$bans2prune2}{/if}</td>
						<td height='16' width='10%' class='listtable_1' align='right' colspan='2'><input type='hidden' name='submitted' value='true'><input type='submit' name='prune' value='{"_PRUNEDB"|lang}' style='font-family: verdana, tahoma, arial; font-size: 10px;' {if ($bans2prune == 0)}disabled{/if}></td>
          </tr>
          </form>
          <tr class="listtable_1-{cycle values="w,g"}tr">
          	<td height='16' width='100%' class='listtable_1' colspan='4'><br>

							<b>{"_WHATISPRUNING"|lang}</b><br>
							{"_PRUNINGINFO"|lang}
							<br><br>
          	</td>
          </tr>
        </table>