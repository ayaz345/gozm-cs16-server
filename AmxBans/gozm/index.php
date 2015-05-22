<?PHP
// Делает выборку из таблицы superban
ini_set('display_errors', 0);
include "config.php";
$count = 0;
function MakeSelection($sql)
{
	global $host, $login, $password, $db;
	$conn = mysql_connect($host, $login, $password);
	mysql_set_charset('utf8', $conn);	
	if (!$conn)
	{
		echo "Unable to connect to DB: " . mysql_error();
	}

	if (!mysql_select_db($db))
	{
		echo "Unable to select mydbname: " . mysql_error();
	}

	$result = mysql_query($sql);

	if (!$result)
	{
		echo "Could not successfully run query ($sql) from DB: " . mysql_error();
	}
	else
	{
		while ($row = mysql_fetch_assoc($result))
		{
			$users[] = $row;
		}
	}

	mysql_free_result($result);
	mysql_close($conn);
	return $users;
}

// Выбирает что и как запрашивать из таблицы
function BottomPanel()
{	
    global $table, $lines, $count;
	$sql = "SELECT COUNT(*) AS count FROM " . $table;
	$count_select = MakeSelection($sql);
	$count = $count_select[0]["count"];
    if (isset($_GET["banid"]))
    {
        $sql = "UPDATE " . $table . " SET unbantime = -1 WHERE banid = " . $_GET['banid'] . "";
        MakeSelection($sql);
    }
	if (isset($_GET["page"])) {$p = ($_GET["page"]-1)*$lines;} else {$p = 0;}
	if ($_GET["search"] == "")
	{
		$sql  = "SELECT * FROM ".$table." ORDER BY banid DESC LIMIT ".$p.", ".$lines;
	}
	else
	{
		$search = mysql_escape_string($_GET["search"]);
		$sql  = "SELECT * FROM " . $table
			. " WHERE ip LIKE '%" . $search
			. "%' OR banname LIKE '%" . $search
			. "%' OR name LIKE '%" . $search
			. "%' OR sid LIKE '%" . $search
			. "%' ORDER BY banid DESC LIMIT " . $p . ", " . $lines;
	}
	$users = MakeSelection($sql);

	//Печатаем резальтат
	PrintResult($users);
}

// Печатает результат запроса
function PrintResult($array)
{
	global $top_color, $line_odd_color, $line_even_color, $bottom_color, $page_color, $cursor_color, $lines, $line_add_color, $count;
	print("
    <tr align = left bgcolor = \"".$top_color."\">
      <td><b>Дата [время]</b></td>
      <td><b>Ник игрока</b></td>
      <td><b>Ник админа</b></td>
      <td><b>Причина<b></td>
      <td><b>Статус бана<b></td>
    </tr>");
	if ($count > 0)
	{
		
		for ($i = 0; $i < $lines and $i < count($array); $i++)
		{
			if (intval($array[$i]['unbantime']) > 0) {$unban = (($array[$i]['unbantime']-$array[$i]['time'])/60)." мин.";}
			if (intval($array[$i]['unbantime']) == 0) {$unban = "Навсегда";}
			if (intval($array[$i]['unbantime']) == -1) {$unban = "Разбанен";}
			if ($array[$i]['reason'] == "") {$reason = "Не указана";} else {$reason = $array[$i]['reason'];}
			if ($flag)
			{
				$flag = false;
				$color = $line_even_color;
			}
			else
			{
				$flag = true;
				$color = $line_odd_color;
			}
			print("
                <tr align = left bgcolor = \"".$color."\" onMouseOver=\"this.style.backgroundColor='".$cursor_color."'\" onMouseOut=\"this.style.backgroundColor='".$color."'\" onClick=\"Toggle(dop".$i.")\">
                  <td>".date("d.m.Y [H:i]", $array[$i]['time'])."</td>
                  <td>".htmlspecialchars($array[$i]['banname'])."</td>
                  <td>".$array[$i]['admin']."</td>
                  <td>".$reason."</td>
                  <td>".$unban."</td>
                </tr>");
    		if ($array[$i]['bantime'] == 0) $bantime = date("d.m.Y [H:i]", $array[$i]['time']);
    		else $bantime = date("d.m.Y [H:i]", $array[$i]['bantime']);
            if (intval($array[$i]['unbantime']) > 0) $unban = date("d.m.Y [H:i]", $array[$i]['unbantime']);
            else $unban = "-";
            if (isset($_GET["page"])) {$p = $_GET["page"];} else {$p = 1;}
			print("
                <tr align = left bgcolor = \"".$line_add_color."\" id = \"dop".$i."\" style = \"display: none;\">
                  <td colspan=\"5\">
                    <b>Последний визит: </b>".$bantime."<br>
                    <b>Последний IP адрес: </b>".$array[$i]['ip']."<br>
                    <b>Последний ник: </b>".$array[$i]['name']."<br>
                    <b>SteamID: </b>".$array[$i]['sid']."<br>
                    <b>Дата окончания бана: </b>".$unban."<br>
                    <input type=\"submit\" value=\"Разбанить\" 
                        onclick=\"window.location='".$_SERVER['PHP_SELF']."?banid=".$array[$i]['banid']."&page=".$p."';\" />
                  </td>
                </tr>");
        }


		print("<tr align = left bgcolor = \"".$bottom_color."\"><td colspan = 5>");
		if (ceil($count/$lines) > 1)
		{
			for ($i = 1; $i <= ceil($count/$lines); $i++)
			{
				if (isset($_GET["page"])) {$p = $_GET["page"];} else {$p = 1;}
				if ($p == $i)
				{
					Print("<font style=\"background-color: #BBBBBB;\">&nbsp;&nbsp;".$i."&nbsp;&nbsp;</font> ");
				}
				else
				{
					Print("<a href = \"?page=".$i."\" style=\"background-color: ".$page_color.";\" onMouseOver=\"this.style.backgroundColor='".$cursor_color."'\" onMouseOut=\"this.style.backgroundColor='".$page_color."'\">&nbsp;&nbsp;".$i."&nbsp;&nbsp;</a> ");
				}
			}
		}
		print("&nbsp;</td></tr>");
	}
}

// Делает запрсс из таблицы superban
function SqlQuery()
{
	global $font_size, $font_color;
	echo "<form name=\"search\" method=\"get\" style=\"font-family: Verdana; font-size: ".$font_size."; color: ".$font_color."\"> Поиск: <input type=\"text\" name=\"search\" value=\"".$_GET["search"]."\"><input type=\"submit\" value=\"Искать\"></form>";
	echo "<table align=\"center\" border = 0 cellpadding = 3 cellspacing = 3 width = 100% style=\"font-family: Verdana; font-size: ".$font_size."; color: ".$font_color."\">";
	BottomPanel();
	echo "</table>";
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>Бан-лист</title>
  <script>
  function Toggle(el)
  {
	el.style.display = (el.style.display == 'none') ? '' : 'none'
  }
  </script>
  <style type="text/css">
  a	{
    text-decoration:    none;
	}
  a:link  {
    color: <?echo $font_color?>;
    }
  a:visited   {
    color: <?echo $font_color?>;
    }
  a:active    {
    color: <?echo $font_color?>;
    }
  a:hover {
    color: <?echo $font_color?>;
    }
  </style>
  </head>
  <body bgcolor = "<?echo $bgcolor?>">
  <?SqlQuery()?>
  </body>
</html>
