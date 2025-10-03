/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, 0);
hitEnemies = ds_map_create();

curSpd = spd;
PhysicsMonomanager.setHSpeed(physics, dcos(dir)*curSpd);
PhysicsMonomanager.setVSpeed(physics, -dsin(dir)*curSpd);