/// @description Insert description here
// You can write your code in this editor

PhysicsMonomanager.applyFriction(physics);

detection.step();
aiManager.step();
lunge.step();

PhysicsMonomanager.applyCollision(physics);
PhysicsMonomanager.applySpeed(physics);
z += zSpd;

stun.step();