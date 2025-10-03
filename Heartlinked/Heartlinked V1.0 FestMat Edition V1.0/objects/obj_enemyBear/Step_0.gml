/// @description Insert description here
// You can write your code in this editor

stun.step();
dodge.step();

PhysicsMonomanager.applyFriction(physics);

detection.step();
aiManager.step();

if (slash.isBeingDone) ActionObjectSubmanager.slash.step(slash);
attack.step();

PhysicsMonomanager.applyCollision(physics);
PhysicsMonomanager.applySpeed(physics);