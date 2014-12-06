<?php /* Smarty version 2.6.14, created on 2013-04-02 06:35:37
         compiled from main_footer.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'lang', 'main_footer.tpl', 13, false),)), $this); ?>
<?php $total = CountBans(); ?>

	
		</td>
	</tr>
</table>
		</td>
	</tr>
</table>


<div id="footer">
<a href="http://www.amxbans.de" target="_blank">AMXBans 5.1b</a> | <a href="http://www.myarena.ru" target="_blank">MyArena.ru</a> | <?php echo ((is_array($_tmp='_TOTALBANS')) ? $this->_run_mod_handler('lang', true, $_tmp) : smarty_modifier_lang($_tmp)); ?>
: <?php echo $total ?>
	 
</div>


</body>

</html>