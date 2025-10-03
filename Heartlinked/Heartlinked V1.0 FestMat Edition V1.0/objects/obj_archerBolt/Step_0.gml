/// @description Insert description here
// You can write your code in this editor

for (var i = 0; i < instance_number(obj_enemyParent); i++) {
	var curEnemy = instance_find(obj_enemyParent, i);
	if (instance_exists(curEnemy) && !ds_map_exists(hitEnemies, curEnemy.id) && place_meeting(x, y, curEnemy)) {
		piercesCur++;
		
		var curEnemyX = curEnemy.x;
		var curEnemyY = curEnemy.y;
		var curEnemyPhysics = curEnemy.physics;
		var curEnemySprIndex = curEnemy.sprite_index;
		
		ds_map_add(hitEnemies, curEnemy.id, pointer_null);
		PhysicsMonomanager.applyKnockback(curEnemy.physics, knockback, dir);
		EnemySubmanager.stunEnemyTemporary(curEnemy, 30+ratio*60, true);
		curEnemy.thrownDebuff.start(20);
		EnemySubmanager.damageEnemy(curEnemy, dmg);
		if (isCharged) EnemySubmanager.applyElectricity(curEnemy, debuffStacks);
		
		if (!instance_exists(curEnemy)) {
			instance_create_layer(curEnemyX, curEnemyY, "Instances", obj_archerBoltCorpse, {
				physics: curEnemyPhysics,
				sprite_index: curEnemySprIndex
			})
		}
		
		if (piercesCur == pierces) {
			instance_destroy();
			audio_play_sound(snd_archerBallistaHit, 0, false, 0.75, 0, 0.9+random(0.2));
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
	trailCooldownFramesCur = trailCooldownFrames;
}