<?php /* Smarty version 2.6.14, created on 2014-04-02 04:30:29
         compiled from unavailable.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'cycle', 'unavailable.tpl', 26, false),)), $this); ?>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
<meta name="Keywords" content="" />
<meta name="Description" content="" />
<meta http-equiv="pragma" content="no-cache" />
<meta http-equiv="cache-control" content="no-cache" />
<link rel="stylesheet" type="text/css" href="<?php echo $this->_tpl_vars['dir']; ?>
/include/amxbans.css" />
</head>

<body>

<div id="header"><a href="http://amxbans.forteam.ru<?php echo $this->_tpl_vars['dir']; ?>
"><img src="<?php echo $this->_tpl_vars['dir']; ?>
/images/logo.png" /></a></div>
<div class="line-h"></div>

<table border='0' cellpadding='0' cellspacing='0' width='100%'>
  <tr>
    <td width='100%' valign='top' style='padding: 20px' align='center'>
    <table border='0' cellpadding='0' cellspacing='0' width='60%'>
      <tr>
        <td>

        <table cellspacing='1' class='listtable' width='100%' cellspacing='20'>
          <tr>
            <td height='16' class='listtable_top'><b>AMXBans</b></td>
          </tr>
          <tr class="listtable_1-<?php echo smarty_function_cycle(array('values' => "w,g"), $this);?>
tr">
            <td class='listtable_1' align='center'><br><br>

						<?php echo $this->_tpl_vars['message']; ?>


            <br><br><br></td>
          </tr>
				</table>

 				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</body>

</html>