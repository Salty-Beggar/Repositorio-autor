/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, undefined);
physics.appliesFrictionStack++;

physics.hSpd = spd*dcos(dir);
physics.vSpd = spd*-dsin(dir);

image_angle = dir;

PhysicsMonomanager.applySpeed(physics);

obj_playerArcher.canLeaveStack++;