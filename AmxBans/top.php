<html>
    <head>
        <title> GoZm Statistics </title>
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

            $resource = mysql_query($config->stats_select_players);

            echo '<table border=1 style="float:center;margin-right:50px;">
                    <tr><th>Место</th>
                        <th>Ник</th>
                        <th>Убил зм</th>
                        <th>Заразил</th>
                        <th>Был заражён</th>
                        <th>Умирал</th>
                        <th>Был первым зм</th>
                        <th>Убил с ножа</th>
                        <th>Лучший зм</th>
                        <th>Лучший человек</th>
                        <th>Лучший игрок карты</th>
                        <th>Общий скилл</th>
                    </tr>';
            while ($row = mysql_fetch_object($resource))
            {
                $skill = intval($row->skill * 1000);
                echo "  <tr><td>" . $row->rank . ". 
                        </td><td>" . $row->nick . "
                        </td><td>" . $row->zombiekills . "
                        </td><td>" . $row->infect . "
                        </td><td>" . $row->infected . "
                        </td><td>" . $row->death . "
                        </td><td>" . $row->first_zombie . "
                        </td><td>" . $row->knife_kills . "
                        </td><td>" . $row->best_zombie . "
                        </td><td>" . $row->best_human . "
                        </td><td>" . $row->best_player . "
                        </td><td> " . $skill . "
                        </td></tr>";
            }
            echo '</table>';
        ?>
    </body>
</html>