<?php

@session_start();
$user_ip = $_SESSION['code'];

$im = ImageCreate(120,50);
$foreground_color = array(mt_rand(0,100), mt_rand(0,100), mt_rand(0,100));
$background_color = array(mt_rand(200,255), mt_rand(200,255), mt_rand(200,255));

$red = ImageColorAllocate($im, $foreground_color[0], $foreground_color[1], $foreground_color[2]);
$white = ImageColorAllocate($im, $background_color[0], $background_color[1], $background_color[1]);
ImageString($im, mt_rand(3,20), mt_rand(0,60), mt_rand(1,35), "$user_ip", $white);
header('Content-Type: image/png');
header('Cache-control: no-cache, no-store');

ImagePng($im);
ImageDestroy($im);

?>