/// @description Insert description here
// You can write your code in this editor

lifetime--;
if (lifetime <= 0 || physics.isColliding) {
	instance_destroy();
	obj_playerArcher.hook.start(x, y); // OBSERVATION_PLAYER004: The hook should also work for the chaincutter.
}

PhysicsMonomanager.applySpeed(physics);
PhysicsMonomanager.applyCollision(physics);


if (lifetime < 5) {
	for (var i = 0; i < instance_number(obj_enemyParent); i++) {
		var curEnemy = instance_find(obj_enemyParent, i);
		if (place_meeting(x, y, curEnemy)) {
			obj_playerArcher.hook.startEnemy(curEnemy);
			instance_destroy();
		}
	}
}