<?PHP
include "config.php";
if (isset($_COOKIE["SuperBan"]))
{
    $conn = mysql_connect($host, $login, $password);
    if ($conn)
    {
        if (mysql_select_db($db))
        {
            if (isset($_SERVER["HTTP_X_FORWARDED_FOR"])) {$addr = $_SERVER["HTTP_X_FORWARDED_FOR"];} else {$addr = $_SERVER["REMOTE_ADDR"];}
            mysql_query("UPDATE ".$table." SET ipcookie='".mysql_real_escape_string($addr)."', bantime=UNIX_TIMESTAMP(NOW()) WHERE uid='".mysql_real_escape_string($_COOKIE["SuperBan"])."'");
        }
    }
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">
<!--html>
< comment <meta http-equiv="Refresh" content="0; URL=motd.html"> comment >
<head>
<title>Cstrike MOTD</title>
<style type="text/css">
pre 	{
		font-family:Verdana,Tahoma;
		color:#FFB000;
    	}
body	{
		background:#000000;
		margin-left:8px;
		margin-top:0px;
		}
a	{
    	text-decoration:    underline;
	}
a:link  {
    color:  #FFFFFF;
    }
a:visited   {
    color:  #FFFFFF;
    }
a:active    {
    color:  #FFFFFF;
    }
a:hover {
    color:  #FFFFFF;
    text-decoration:    underline;
    }
</style>
</head>
<body scroll="no">
<pre>
This server is using plugin <b>amx_superban</b> by Lukmanov Ildar!
</pre>
</body>
</html-->
<!--html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=cp1251">
<meta http-equiv="refresh" content="0;URL=http://multreactor.ru/motd/motd.html">
</head>
<body
</body>
</html-->
<html>
<head>
<title>3om6u cepBep (x_x(O_o)x_x) Go Zombie !!!</title>
<style type="text/css">
<!--body {
margin-left: 0px;
margin-top: 0px;
margin-right: 0px;
margin-bottom: 0px;
background-color: #000000;
}-->
</style>
</head>
<body>

<img src="http://gozm.myarena.ru/fast/welcome.jpg" width="100%" height="100%"
border="0" align="center">

</body>
</html>