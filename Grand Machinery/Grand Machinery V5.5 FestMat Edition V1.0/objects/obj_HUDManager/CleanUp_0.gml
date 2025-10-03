/// @description Insert description here
// You can write your code in this editor
var curEnemyHUDObjs = ds_map_keys_to_array(enemyHUDMap);
for (var i = 0; i < array_length(curEnemyHUDObjs); i++) {
	var curEnemyHUD = enemyHUDMap[?curEnemyHUDObjs[i]];
	curEnemyHUD.cleanup();
}
	ds_map_destroy(enemyHUDMap);
	pointPopups.cleanup();