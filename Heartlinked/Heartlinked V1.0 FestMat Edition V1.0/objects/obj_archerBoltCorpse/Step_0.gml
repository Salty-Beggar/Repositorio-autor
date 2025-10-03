/// @description Insert description here
// You can write your code in this editor

for (var i = 0; i < instance_number(obj_enemyParent); i++) {
	var curEnemy = instance_find(obj_enemyParent, i);
	
	if (instance_exists(curEnemy) && !ds_map_exists(hitEnemies, curEnemy.id) && place_meeting(x, y, curEnemy)) {
		ds_map_add(hitEnemies, curEnemy.id, pointer_null);
		EnemySubmanager.stunEnemyTemporary(curEnemy, 40);
		PhysicsMonomanager.setHSpeed(curEnemy.physics, physics.hSpd);
		PhysicsMonomanager.setVSpeed(curEnemy.physics, physics.vSpd);
		EnemySubmanager.damageEnemy(curEnemy, 4);
		audio_play_sound(snd_archerBallistaHit, 0, false, 0.75, 0, 1.5+random(0.2));
	}
}

PhysicsMonomanager.applyFriction(physics);
PhysicsMonomanager.applySpeed(physics);
if (abs(physics.hSpd) < 1 && abs(physics.vSpd) < 1) {
	instance_destroy();
}