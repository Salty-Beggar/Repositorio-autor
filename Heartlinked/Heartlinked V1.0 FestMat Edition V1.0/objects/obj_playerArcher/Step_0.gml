/// @description Insert description here
// You can write your code in this editor

PhysicsMonomanager.applyFriction(physics);

if (isMovementSlowedDownStack != 0) movement.maxSpd = 1;
else movement.maxSpd = 2;
movement.step();
shooting.step();
hook.step();

PhysicsMonomanager.applyCollision(physics);
PhysicsMonomanager.applySpeed(physics);