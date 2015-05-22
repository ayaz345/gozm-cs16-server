<?php

//http://forums.alliedmods.net/showthread.php?t=60899
function GetFriendID($pszAuthID)
{
	$iServer = "0";
    $iAuthID = "0";
	
	$szAuthID = $pszAuthID;
	
	$szTmp = strtok($szAuthID, ":");
	
	while(($szTmp = strtok(":")) !== false)
    {
        $szTmp2 = strtok(":");
        if($szTmp2 !== false)
        {
            $iServer = $szTmp;
            $iAuthID = $szTmp2;
        }
    }
    if($iAuthID == "0")
        return "0";

    $i64friendID = bcmul($iAuthID, "2");

    //Friend ID's with even numbers are the 0 auth server.
    //Friend ID's with odd numbers are the 1 auth server.
    $i64friendID = bcadd($i64friendID, bcadd("76561197960265728", $iServer)); 
	
	return $i64friendID;
}
function GetAuthID($i64friendID)
{
	$tmpfriendID = $i64friendID;
	$iServer = "1";
	if(bcmod($i64friendID, "2") == "0")
	{
		$iServer = "0";
	}
	$tmpfriendID = bcsub($tmpfriendID,$iServer);
	if(bccomp("76561197960265728",$tmpfriendID) == -1)
		$tmpfriendID = bcsub($tmpfriendID,"76561197960265728");
	$tmpfriendID = bcdiv($tmpfriendID, "2");
	return ("STEAM_0:" . $iServer . ":" . $tmpfriendID);
}

function AtoF_callback($matches)
{
	return '<a href="http://steamcommunity.com/profiles/'.GetFriendID($matches[0]).'">'.$matches[0].'</a>';
}

function FtoA_callback($matches)
{
	$trimmed = trim($matches[0], ":]'\"");
	return GetAuthID($trimmed);
}

?>
