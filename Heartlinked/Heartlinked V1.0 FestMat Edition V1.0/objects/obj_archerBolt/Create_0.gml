/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, undefined);
physics.appliesFrictionStack++;

physics.hSpd = spd*dcos(dir);
physics.vSpd = spd*-dsin(dir);
physics.hSpd += memberHSpd/2;
physics.vSpd += memberVSpd/2;

image_angle = dir;

PhysicsMonomanager.applySpeed(physics);

hitEnemies = ds_map_create();
piercesCur = 0;

lifetimeCur = 40;

trailCooldownFrames = 1;
trailCooldownFramesCur = 0;

function deflect(newDirI) {
	dir = newDirI;
	
	physics.hSpd = spd*dcos(dir);
	physics.vSpd = spd*-dsin(dir);
	
	ds_map_clear(hitEnemies);

	image_angle = dir;
	piercesCur = 0;
	lifetimeCur = 40;
}

