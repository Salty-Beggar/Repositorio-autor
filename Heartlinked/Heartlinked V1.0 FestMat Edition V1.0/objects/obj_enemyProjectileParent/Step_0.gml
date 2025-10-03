/// @description Insert description here
// You can write your code in this editor

physics.hSpd = dcos(dir)*curSpd;
physics.vSpd = -dsin(dir)*curSpd;
curSpd += accSpd;

PhysicsMonomanager.applySpeed(physics);

if (place_meeting(x, y, CURRENT_MEMBER_INST)) {
	instance_destroy();
	PartySubmanager.damageCurrentMember(dmg);
}

if (place_meeting(x, y, obj_collision)) {
	instance_destroy();
}