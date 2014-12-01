<html>
    <head>
        <title> Go Zombie !!! STATS </title>
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

			echo '<table><tr><td>';

            echo '<table border=1 style="float:left;margin-right:50px;"><tr><th>Rank</th><th>Nick</th><th>ZM killed</th><th>Infects</th><th>Infected</th><th>Deaths</th><th>Bonuses</th><th>Total Skill</th></tr>';
            while ($row = mysql_fetch_object($resource))
            {
                $skill_float = ($row->zombiekills*2 + $row->infect + $row->extra) / ($row->death + $row->infected + 300);
                $skill = intval($skill_float * 1000);
                echo "<tr><td>" . $row->rank . ". </td><td>" . $row->nick . "</td><td>" . $row->zombiekills . "</td><td>" . $row->infect . "</td><td>" . $row->infected . "</td><td>" . $row->death . "</td><td>" . $row->extra . "</td><td> " . $skill . " </td></tr>";
            }
            echo '</table>';

			echo '</td><td>';

			$resource = mysql_query($config->stats_select_maps);
			echo '<table border=1 style="float:right;margin-left:50px;"><tr><th>No.</th><th>Map</th><th>Games</th></tr>';
			$iter = 1;
            while ($row = mysql_fetch_object($resource))
            {
                $map = $row->map;
                $games = $row->games;
                echo "<tr><td>" . $iter . " </td><td>" . $map . " </td><td>" . $games . "</td></tr>";
				$iter = $iter + 1;
            }
            echo '</table>';

			echo '</td></tr></table>';
        ?>
    </body>
</html>