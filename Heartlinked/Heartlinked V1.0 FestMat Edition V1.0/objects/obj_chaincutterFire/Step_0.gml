/// @description Insert description here
// You can write your code in this editor

lifetimeCur--;

var curSize = min(1, lifetimeCur/disappearFrames);
image_xscale = curSize;
image_yscale = curSize;

if (lifetimeCur == 0) instance_destroy();

/*for (var i = 0; i < instance_number(obj_enemyParent); i++) {
	var curEnemy = instance_find(obj_enemyParent, i);
	if (place_meeting(x, y, curEnemy)) {
		EnemySubmanager.damageEnemy(curEnemy, 1);
		instance_destroy();
	}
}*/