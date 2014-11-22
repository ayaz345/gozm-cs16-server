<?php /* Smarty version 2.6.14, created on 2014-03-13 04:26:46
         compiled from prune_db.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'prune_db.tpl', 5, false),array('function', 'cycle', 'prune_db.tpl', 8, false),)), $this); ?>


        <table cellspacing='1' class='listtable' width='100%'>
          <tr>
            <td height='16' colspan='4' class='listtable_top'><b><?php echo ((is_array($_tmp='_PRUNEDB')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b></td>
          </tr>
          <form name='prunebans' method='post' action='<?php echo $this->_tpl_vars['this']; ?>
'>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='30%' class='listtable_1'><?php echo ((is_array($_tmp='_NBEXPBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</td>
            <td height='16' width='60%' class='listtable_1'><?php if (( $this->_tpl_vars['bans2prune'] == 0 && bans2prune2 == 0 )):  echo ((is_array($_tmp='_NONE')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp));  else:  echo $this->_tpl_vars['bans2prune']; ?>
 / <?php echo $this->_tpl_vars['bans2prune2'];  endif; ?></td>
						<td height='16' width='10%' class='listtable_1' align='right' colspan='2'><input type='hidden' name='submitted' value='true'><input type='submit' name='prune' value='<?php echo ((is_array($_tmp='_PRUNEDB')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
' style='font-family: verdana, tahoma, arial; font-size: 10px;' <?php if (( $this->_tpl_vars['bans2prune'] == 0 )): ?>disabled<?php endif; ?>></td>
          </tr>
          </form>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
          	<td height='16' width='100%' class='listtable_1' colspan='4'><br>

							<b><?php echo ((is_array($_tmp='_WHATISPRUNING')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
</b><br>
							<?php echo ((is_array($_tmp='_PRUNINGINFO')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>

							<br><br>
          	</td>
          </tr>
        </table>