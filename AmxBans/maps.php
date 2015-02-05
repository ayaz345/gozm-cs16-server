<html>
    <head>
        <title> GoZm Maps </title>
    </head>
    <body>
        <?php
            require("include/config.inc.php");

            $mysql_host = $config->db_host;
            $mysql_user = $config->db_user;
            $mysql_password = $config->db_pass;
            $mysql_db = $config->db_name;

            if (!@mysql_connect($mysql_host, $mysql_user, $mysql_password))
                die (mysql_error());
            if (!mysql_select_db($mysql_db))
                die (mysql_error());

			$resource = mysql_query($config->stats_select_maps);
			echo '<table border=1 style="float:center;margin-left:50px;">
                    <tr><th>№</th>
                        <th>Карта</th>
                        <th>Игр сыграно</th>
                    </tr>';
			$iter = 1;
            while ($row = mysql_fetch_object($resource))
            {
                $map = $row->map;
                $games = $row->games;
                echo "  <tr><td>" . $iter . "." . "
                        </td><td>" . $map . "
                        </td><td>" . $games . "
                        </td></tr>";
				$iter = $iter + 1;
            }
            echo '</table>';
        ?>
    </body>
</html>