<?PHP

function BBcode($comment)
{
    if ($comment != "")
    {
	//$comment = nl2br($comment);

        $comment = " " . $comment;
        $comment = preg_replace("#([\t\r\n ])([a-z0-9]+?){1}://([\w\-]+\.([\w\-]+\.)*[\w]+(:[0-9]+)?(/[^ \"\n\r\t<]*)?)#i", '\1<a href="\2://\3"  onclick="window.open(this.href); return false;">\2://\3</a>', $comment);
        $comment = preg_replace("#([\t\r\n ])(www|ftp)\.(([\w\-]+\.)*[\w]+(:[0-9]+)?(/[^ \"\n\r\t<]*)?)#i", '\1<a href="http://\2.\3"  onclick="window.open(this.href); return false;">\2.\3</a>', $comment);
        $comment = preg_replace("#([\n ])([a-z0-9\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)#i", "\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>", $comment);

	$comment = str_replace("\r", "", $comment);
	$comment = str_replace("\n", "<br />", $comment);

        $comment = preg_replace("/\[color=(.*?)\](.*?)\[\/color\]/i", "<span style=\"color: \\1;\">\\2</span>", $comment);
        $comment = preg_replace("/\[size=(.*?)\](.*?)\[\/size\]/i", "<span style=\"font-size: \\1px;\">\\2</span>", $comment);
        $comment = preg_replace("/\[font=(.*?)\](.*?)\[\/font\]/i", "<span style=\"font-family: \\1;\">\\2</span>", $comment);
        $comment = preg_replace("/\[align=(.*?)\](.*?)\[\/align\]/i", "<div style=\"text-align: \\1;\">\\2</div>", $comment);
        $comment = str_replace("[b]", "<b>", $comment);
        $comment = str_replace("[/b]", "</b>", $comment);
        $comment = str_replace("[i]", "<i>", $comment);
        $comment = str_replace("[/i]", "</i>", $comment);
        $comment = str_replace("[li]", "<ul><li>", $comment);
        $comment = str_replace("[/li]", "</li></ul>", $comment);
        $comment = str_replace("[u]", "<span style=\"text-decoration: underline;\">", $comment);
        $comment = str_replace("[/u]", "</span>", $comment);
        $comment = str_replace("[center]", "<div style=\"text-align: center;\">", $comment);
        $comment = str_replace("[/center]", "</div>", $comment);
        $comment = str_replace("[strike]", "<span style=\"text-decoration: line-through;\">", $comment);
        $comment = str_replace("[/strike]", "</span>", $comment);
        $comment = str_replace("[blink]", "<span style=\"text-decoration: blink;\">", $comment);
        $comment = str_replace("[/blink]", "</span>", $comment);
        $comment = preg_replace("/\[flip\](.*?)\[\/flip\]/i", "<div style=\"width: 100%;filter: FlipV;\">\\1</div>", $comment);
        $comment = preg_replace("/\[blur\](.*?)\[\/blur\]/i", "<div style=\"width: 100%;filter: blur();\">\\1</div>", $comment);
        $comment = preg_replace("/\[glow\](.*?)\[\/glow\]/i", "<div style=\"width: 100%;filter: glow(color=red);\">\\1</div>", $comment);
        $comment = preg_replace("/\[glow=(.*?)\](.*?)\[\/glow\]/i", "<div style=\"width: 100%;filter: glow(color=\\1);\">\\2</div>", $comment);
        $comment = preg_replace("/\[shadow\](.*?)\[\/shadow\]/i", "<div style=\"width: 100%;filter: shadow(color=red);\">\\1</div>", $comment);
        $comment = preg_replace("/\[shadow=(.*?)\](.*?)\[\/shadow\]/i", "<div style=\"width: 100%;filter: shadow(color=\\1);\">\\2</div>", $comment);
        $comment = preg_replace("/\[email\](.*?)\[\/email\]/i", "<a href=\"mailto:\\1\">\\1</a>", $comment);
        $comment = preg_replace("/\[email=(.*?)\](.*?)\[\/email\]/i", "<a href=\"mailto:\\1\">\\2</a>", $comment);
        $comment = str_replace("[quote]", "<br /><table style=\"background: " . $bgcolor3 . ";\" cellpadding=\"3\" cellspacing=\"1\" width=\"100%\" border=\"0\"><tr><td style=\"background: #FFFFFF;color: #000000\"><b>" . _QUOTE . " :</b><br />", $comment);
        $comment = preg_replace("/\[quote=(.*?)\]/i", "<br /><table style=\"background: " . $bgcolor3 . ";\" cellpadding=\"3\" cellspacing=\"1\" width=\"100%\" border=\"0\"><tr><td style=\"background: #FFFFFF;color: #000000\"><b>\\1 " . _HASWROTE . " :</b><br />", $comment);
        $comment = str_replace("[/quote]", "</td></tr></table><br />", $comment);
        $comment = str_replace("[code]", "<br /><table style=\"background: " . $bgcolor3 . ";\" cellpadding=\"3\" cellspacing=\"1\" width=\"100%\" border=\"0\"><tr><td style=\"background: #FFFFFF;color: #000000\"><b>" . _CODE . " :</b><pre>", $comment);
        $comment = str_replace("[/code]", "</pre></td></tr></table>", $comment);
        $comment = preg_replace_callback('/\[img\](.*?)\[\/img\]/i', create_function('$var', '$img = "<img style=\"border: 0;\" src=\"" . checkimg($var[1]) . "\" alt=\"\" />";return $img;'), $comment);
        $comment = preg_replace_callback('/\[img=(.*?)x(.*?)\](.*?)\[\/img\]/i', create_function('$var', '$img = "<img style=\"border: 0;\" width=\"" . $var[1] . "\" height=\"" . $var[2] . "\" src=\"" . checkimg($var[3]) . "\" alt=\"\" />";return $img;'), $comment);
	$comment = preg_replace("/\[flash\](.*?)\[\/flash\]/i", "<object type=\"application/x-shockwave-flash\" data=\"\\1\"><param name=\"movie\" value=\"\\1\" /><param name=\"pluginurl\" value=\"http://www.macromedia.com/go/getflashplayer\" /></object>", $comment);
        $comment = preg_replace("/\[flash=(.*?)x(.*?)\](.*?)\[\/flash\]/i", "<object type=\"application/x-shockwave-flash\" data=\"\\3\" width=\"\\1\" height=\"\\2\"><param name=\"movie\" value=\"\\3\" /><param name=\"pluginurl\" value=\"http://www.macromedia.com/go/getflashplayer\" /></object>", $comment);
	$comment = preg_replace("/\[url\]www.(.*?)\[\/url\]/i", "<a href=\"http://www.\\1\" onclick=\"window.open(this.href); return false;\">\\1</a>", $comment);
        $comment = preg_replace("/\[url\](.*?)\[\/url\]/i", "<a href=\"\\1\" onclick=\"window.open(this.href); return false;\">\\1</a>", $comment);
        $comment = preg_replace("/\[url=(.*?)\](.*?)\[\/url\]/i", "<a href=\"\\1\" onclick=\"window.open(this.href); return false;\">\\2</a>", $comment);
        $comment = preg_replace("#\[s\](http://)?(.*?)\[/s\]#si", "<img style=\"border: 0;\" src=\"images/icones/\\2\" alt=\"\" />", $comment);
	
	$comment = ltrim($comment);
    } 
    return($comment);
} 


function smiley($textarea)
{
    $sql = mysql_query("SELECT code, url, name FROM amx_smilies ORDER BY id LIMIT 0, 15");
    while (list($code, $url, $name) = mysql_fetch_array($sql))
    {
        $name = stripslashes($name);
        $name = htmlentities($name);

        echo "&nbsp;<a href=\"javascript:insertAtCaret('" . $textarea ."', '$code')\"><img style=\"border: 0;\" src=\"images/icones/" . $url . "\" alt=\"\" title=\"" . $name . "\" /></a>";
    }
} 

function icon($comment)
{


    $comment = str_replace("mailto:", "mailto!", $comment);
    $comment = str_replace("http://", "_http_", $comment);
    $comment = str_replace("&quot;", "_QUOT_", $comment);
    $comment = str_replace("&#039;", "_SQUOT_", $comment);

    $sql = mysql_query("SELECT code, url, name FROM amx_smilies ORDER BY id");
    while (list($code, $url, $name) = mysql_fetch_array($sql))
    {
        $name = stripslashes($name);
        $comment = str_replace($code, "<img src=\"images/icones/" . $url . "\" alt=\"\" title=\"$name\" />", $comment);
    } 

    $comment = str_replace("mailto!", "mailto:", $comment);
    $comment = str_replace("_http_", "http://", $comment);
    $comment = str_replace("_QUOT_", "&quot;", $comment);
    $comment = str_replace("_SQUOT_", "&#039;", $comment);

    return($comment);
}
?>