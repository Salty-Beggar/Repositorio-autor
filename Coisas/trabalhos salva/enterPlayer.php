<?php
session_start();
if (!isset($_SESSION["playerID"])) {
    $playerFile = json_decode(file_get_contents("locations.txt"));
    var_dump($playerFile);
    $_SESSION["playerID"] = sizeof($playerFile);
    $playerFile[] = [10, 10];
}
echo $_SESSION["playerID"];
session_destroy();