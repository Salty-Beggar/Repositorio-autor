/// @description Insert description here
// You can write your code in this editor

isControlled = true;
canLeaveStack = 0;

lastDirection = 0;
lastDirection2 = 0;

function drawAim() {
	if (InputSubmanager.inputMode == INPUT_DEVICE.keyboard) return;
	draw_set_alpha(0.5);
	draw_sprite_ext(
		spr_playerAim, 0,
		x, y,
		1.0, 1.0,
		lastDirection2,
		c_white,
		0.5
	);
	draw_set_alpha(1.0);
}

physics = PhysicsMonomanager.construct(self, DEFAULT_FRICTION);

movement = {
	_p: other,
	canBeDoneStack: 0,
	maxSpd: 2,
	step: function() {
		if (_p.isControlled && canBeDoneStack == 0 && InputSubmanager.joystick.isBeingPressed())
			PhysicsMonomanager.targetMaxSpeedToDirection(_p.physics, maxSpd, 1, InputSubmanager.joystick.returnDirection());
	}
}

applyPhysics = function() {
	PhysicsMonomanager.applyCollision(physics);
	PhysicsMonomanager.stepInterface(physics);
}

memberType = undefined;
initialize = function(memberTypeI) {
	memberType = memberTypeI;
}