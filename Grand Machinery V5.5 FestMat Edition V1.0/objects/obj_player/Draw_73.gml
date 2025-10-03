/// @description Insert description here
// You can write your code in this editor

if (instance_exists(shot.blinkedEnemy) && shot.blinkedEnemy != undefined) {
	if (!shot.isEnemyBlinkWindow) draw_sprite(spr_blinkMarker, 0, shot.blinkedEnemy.x, shot.blinkedEnemy.y);
	else draw_sprite(spr_blinkMarker2, 0, shot.blinkedEnemy.x, shot.blinkedEnemy.y);
}