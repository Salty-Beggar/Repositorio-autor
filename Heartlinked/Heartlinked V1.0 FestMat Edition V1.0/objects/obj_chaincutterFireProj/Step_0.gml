/// @description Insert description here
// You can write your code in this editor

PhysicsMonomanager.targetNullSpeed(physics, 0.08);

for (var i = 0; i < instance_number(obj_enemyParent); i++) {
	var curEnemy = instance_find(obj_enemyParent, i);
	if (instance_exists(curEnemy) && !ds_map_exists(hitEnemies, curEnemy.id) && place_meeting(x, y, curEnemy)) {
		ds_map_add(hitEnemies, curEnemy.id, pointer_null);
		//PhysicsMonomanager.applyKnockback(curEnemy.physics, knockback, dir);
		EnemySubmanager.damageEnemyFire(curEnemy, dmg);
		EnemySubmanager.applyFire(curEnemy, stacks);
	}
}

PhysicsMonomanager.applySpeed(physics);

lifetime--;

if (lifetime <= 0) instance_destroy();