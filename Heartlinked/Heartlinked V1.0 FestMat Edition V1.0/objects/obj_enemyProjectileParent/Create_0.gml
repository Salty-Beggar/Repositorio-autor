/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, DEFAULT_FRICTION);

curSpd = undefined;
accSpd = undefined;
image_angle = dir;

function initialize(initSpdI, accSpdI) {
	curSpd = initSpdI;
	accSpd = accSpdI;
}