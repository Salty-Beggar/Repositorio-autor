/// @description Insert description here
// You can write your code in this editor

event_inherited();
StageObjectManager.getObject(curStageManager.blockingEnergyCollision).instanceID.energyInterface.setEnergy(0.1);
if (obj_player.x > curStageManager.detectionX && obj_player.y > curStageManager.arenaY1) {
	isDetecting = true;
}

var newDirection = sign(obj_player.x - x);
if (canChangeDirectionStack == 0 && newDirection != 0) {
	lastDirection = newDirection;
}

var curTargetSpd = 0;
if (!death.isDying && isDetecting && canMoveStack == 0) {
	curTargetSpd = lastDirection*spd;
}
if (hasTargetSpdStack == 0) {
	if_physics.targetMaxHSpeed(ifPhysics, curTargetSpd, acc);
}

death.tick();
if (!death.isDying) energyDeath.tick();

if (!StageObjectManager.objectExists(stageObjectID)) {
	return;
}

slash.tick();
lunge.tick();
backstep.tick();

if (!death.isDying && !energyDeath.isDying && isDetecting) {
	enrage.tick();
	threeSlashCombo.tick();
	triShot.tick();
	lungeAttack.tick();
	ultraHeal.tick();

	outOfRangeBehaviour.tick();
}

var curIgnoresPlatforms = false;
var vTolerance = -40;
if (ignoresPlatforms && bbox_bottom+ifPhysics.vSpd < obj_player.bbox_bottom+vTolerance) {
	curIgnoresPlatforms = true;
}
ifPhysics.collision.perms.any = !ignoresCollisions;
ifPhysics.collision.perms.vPlatform = !curIgnoresPlatforms;

trailManager.tick();