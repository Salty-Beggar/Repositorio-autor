/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, undefined);
physics.appliesFrictionStack++;

physics.hSpd = spd*dcos(dir);
physics.vSpd = spd*-dsin(dir);

image_angle = dir;

PhysicsMonomanager.applySpeed(physics);

hitEnemies = ds_map_create();
piercesCur = 0;

lifetimeCur = 40;

trailCooldownFrames = 3;
trailCooldownFramesHeavy = 1;
trailCooldownFramesCur = 0;

if (isHeavy) {
	physics.hSpd += playerHSpd;
	physics.vSpd += playerVSpd;
	var curPlayerSpd = point_distance(0, 0, physics.hSpd, physics.vSpd);
	var spdRatio = curPlayerSpd/25;
	dmg += spdRatio*4;
	knockback += spdRatio*8;
}

function deflect(newDirI) {
	dir = newDirI;
	
	physics.hSpd = spd*dcos(dir);
	physics.vSpd = spd*-dsin(dir);
	
	ds_map_clear(hitEnemies);

	image_angle = dir;
	piercesCur = 0;
	lifetimeCur = 40;
}

