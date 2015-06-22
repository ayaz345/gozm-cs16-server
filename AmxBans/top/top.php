<html>
    <head>
        <title> GoZm Statistics </title>
        <?php
            if ($handle = opendir('.')) 
            {
                $css_list = array();

                while (false !== ($file = readdir($handle)))
                {
                    if (substr($file, -4, 4) == '.css')
                    {
                        array_push($css_list, $file);
                    }
                }
                closedir($handle);
            }

            $css_id = array_rand($css_list);
            $css = $css_list[$css_id];
            echo '<link rel="stylesheet" type="text/css" href=' . $css . '>';
        ?>
    </head>
    <body>
        <?php
            require("../include/config.inc.php");

            $mysql_host = $config->db_host;
            $mysql_user = $config->db_user;
            $mysql_password = $config->db_pass;
            $mysql_db = $config->db_name;

            $css_toggle = true;

            if (!@mysql_connect($mysql_host, $mysql_user, $mysql_password))
                die (mysql_error());
            if (!mysql_select_db($mysql_db))
                die (mysql_error());

            $resource = mysql_query($config->stats_select_players);

            echo "<table width=100%% border=0 align=center cellpadding=0 cellspacing=1>
                    <tr>
                        <th>Место</th>
                        <th>Ник</th>
                        <th>Убил зм</th>
                        <th>Заразил людей</th>
                        <th>Был заражён</th>
                        <th>Был убит</th>
                        <th>Первый зм</th>
                        <th>Убил с ножа</th>
                        <th>Лучший зм</th>
                        <th>Лучший человек</th>
                        <th>Герой эскейпа</th>
                        <th>Лучший игрок карты</th>
                        <th>Общий скилл</th>
                    </tr>";
            while ($row = mysql_fetch_object($resource))
            {
                $skill = intval($row->skill * 1000);
                $style = $css_toggle ? " id=c" : "";
                echo "  <tr" . $style . ">
                            <td>" . $row->rank . "</td>
                            <td>" . $row->nick . "</td>
                            <td>" . $row->zombiekills . "</td>
                            <td>" . $row->infect . "</td>
                            <td>" . $row->infected . "</td>
                            <td>" . $row->death . "</td>
                            <td>" . $row->first_zombie . "</td>
                            <td>" . $row->knife_kills . "</td>
                            <td>" . $row->best_zombie . "</td>
                            <td>" . $row->best_human . "</td>
                            <td>" . $row->escape_hero . "</td>
                            <td>" . $row->best_player . "</td>
                            <td>" . $skill . "</td>
                        </tr>";

                $css_toggle = $css_toggle ? false : true;
            }
            echo "</table>";
        ?>
    </body>
</html>
