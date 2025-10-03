/// @description Insert description here
// You can write your code in this editor

for (var i = 0; i < instance_number(obj_enemyParent); i++) {
	var curEnemy = instance_find(obj_enemyParent, i);
	if (instance_exists(curEnemy) && !ds_map_exists(hitEnemies, curEnemy.id) && place_meeting(x, y, curEnemy)) {
		piercesCur++;
		ds_map_add(hitEnemies, curEnemy.id, pointer_null);
		PhysicsMonomanager.applyKnockback(curEnemy.physics, knockback, dir);
		EnemySubmanager.damageEnemy(curEnemy, dmg);
		if (isCharged) EnemySubmanager.applyElectricity(curEnemy, debuffStacks);
		
		if (piercesCur == pierces) {
			instance_destroy();
			break;
		}
	}
}

PhysicsMonomanager.applyCollision(physics);

if (physics.isColliding) {
	instance_destroy();
}

PhysicsMonomanager.applySpeed(physics);

lifetimeCur--;
if (lifetimeCur == 0) instance_destroy();

trailCooldownFramesCur--;
if (trailCooldownFramesCur <= 0) {
	instance_create_layer(x, y, "Instances", obj_archerArrowTrail, {
		image_blend: self.image_blend,
		dir: self.dir
	});
	trailCooldownFramesCur = (isHeavy) ? trailCooldownFramesHeavy : trailCooldownFrames;
}