/// @description Insert description here
// You can write your code in this editor

PhysicsMonomanager.applyFriction(physics);

detection.step();
aiManager.step();

PhysicsMonomanager.applyCollision(physics);
PhysicsMonomanager.applySpeed(physics);

stun.step();