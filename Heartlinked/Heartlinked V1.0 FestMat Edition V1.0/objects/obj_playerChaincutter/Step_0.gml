/// @description Insert description here
// You can write your code in this editor

PhysicsMonomanager.applyFriction(physics);

movement.step();
fireSlice.step();
dash.step();
flameThrow.step();

if (isMovingFastStack == 0) movement.maxSpd = 2;
else movement.maxSpd = 1.3;

PhysicsMonomanager.applyCollision(physics);
PhysicsMonomanager.applySpeed(physics);

if (slash.isBeingDone) {
	ActionObjectSubmanager.slash.step(slash);
}

slashCombo.step();
chainsawSlash.step();


heat.step();
