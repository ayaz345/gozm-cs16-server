<?php
$c=file_get_contents('lang.russian.php');
$r=iconv('CP866','CP1251//IGNORE',$c);

//$r=iconv('UTF-8','ASCII//TRANSLIT',$c);

echo $c;