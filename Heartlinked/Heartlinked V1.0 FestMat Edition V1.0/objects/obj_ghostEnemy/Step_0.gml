/// @description Insert description here
// You can write your code in this editor

stun.step();

detection.step();
aiManager.step();

PhysicsMonomanager.applyFriction(physics);
PhysicsMonomanager.applySpeed(physics);