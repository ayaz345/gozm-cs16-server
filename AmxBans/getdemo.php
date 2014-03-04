<?php

// Require basic site files
require("include/config.inc.php");
require("$config->path_root/include/functions.inc.php");

// ANTI INJECTION SQL 
$_GET["demo"]=(int)$_GET["demo"];
if (isset($_GET['demo']) && !is_numeric($_GET['demo'])) die("<br /><br /><br /><div style=\"text-align: center;\"><big>Error : ID must be a number !</big></div>");

$resource	= mysql_query("SELECT demo FROM `".$config->amxdemos."` WHERE id = " .mysql_real_escape_string($_GET['demo']). "") or die(mysql_error());
$results = mysql_fetch_object($resource);

if (is_file("demos/$results->demo") ){

$file = "demos/$results->demo"; 

header('Content-Description: File Transfer'); 
header('Content-Type: application/force-download'); 
header('Content-Length: ' . filesize($file)); 
header('Content-Disposition: attachment; filename=' . basename($file)); 

readfile($file); 

exit(); 

}else{

echo"<html><head>
<title>:: AmxBans ::</title>
<meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1251\"></HEAD>
<body bgcolor=#ffffff>
<center><br><br><font color=red size=2><b>Download failed! </FONT><br><br><font size=1>Error - File not found.</a><br></center></body></html>";
}
?>