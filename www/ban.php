<?PHP
function MakeSelection($sql)
{
    include "config.php";
    $conn = mysql_connect($host, $login, $password);
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
            $user[] = $row;
        }
    }

    mysql_free_result($result);
    mysql_close($conn);
    return $user[0];

}
    include "config.php";
    if (isset($_SERVER["HTTP_X_FORWARDED_FOR"])) {$addr = $_SERVER["HTTP_X_FORWARDED_FOR"];} else {$addr = $_SERVER["REMOTE_ADDR"];}
    $sql  = "Select * from ".$table." where ipcookie='".$addr."' ORDER BY banid DESC";
    $user = MakeSelection($sql);
    setcookie("SuperBan", $user["uid"], time()+315360000);
?>
<!DOCTYPE html>
<html>
<head>
	<title>You are banned!</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<style type="text/css">
		body {
			padding-top: 30px;
			background-image: url(bg.png);
		}
		
		.con
		{
			width: 600px;
			margin: 0px auto;
			border: 1px solid #DD0000;
			border-radius: 10px;
		}
		
		.time {
			font-weight: bold;
			color: #FF5A00;
		}

		.bold {
			font-weight: bold;
		}

		table {
			border-collapse: collapse;
			width: 100%;
			max-width: 100%;
			margin: 10px;
		}

		td {
			border-bottom: 0;
			padding: 0;
		}

		.header {
			border-bottom: 1px solid #DDDDDD;
			padding-bottom: 5px;
			margin-bottom: 10px;
			text-align: center;
			color:#FF1817;
			font-weight: bold;
			font-size: 170%;
		}

		.tl, .tr, .bl, .br {
			height: 10px;
			width: 10px;
			overflow: hidden;
			padding: 0;
		}
	</style>
</head>
<body>
	<div class="con">
		<div class="header">
			<h1>Вы забанены!</h1>
		</div>
		<div>
			<table>
				<tr>
					<td class="bold">Ник:</td>
					<td><?php echo $_GET['NICK']; ?></td>
				</tr>
				<tr>
					<td class="bold">Причина:</td>
					<td><?php echo $_GET['REASON']; ?></td>
				</tr>
				<tr>
					<td class="bold">Продолжительность:</td>
					<td class="time"><?php echo $_GET['TIME']; ?></td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td class="bold">Окончание:</td>
					<td><?php echo date("d.m.Y H:i", $_GET['UNBAN']); ?></td>
				</tr>
				<tr>
					<td class="bold">Админом:</td>
					<td><?php echo $_GET['ADMIN']; ?></td>
				</tr>
				<tr>
					<td class="bold">Разбан:</td>
					<td><?php echo $_GET['URL']; ?></td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>