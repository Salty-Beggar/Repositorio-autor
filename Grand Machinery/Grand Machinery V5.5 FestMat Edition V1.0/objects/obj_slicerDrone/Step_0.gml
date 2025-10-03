/// @description Insert description here
// You can write your code in this editor

event_inherited();

image_xscale = lastDirection;

if (isTargetting && canChangeDirection && sign(lastTarget.x - x) != 0) {
	targDir = sign(lastTarget.x - x);
}

if (targDir != lastDirection) {
	reactionTimeCur++;
	if (reactionTimeCur == reactionTime) {
		lastDirection = targDir;
	}
}else {
	reactionTimeCur = 0;
}

/* (lastTarget.y-y < detectionHeightMax && !PlayerManager.isDead) {
	var inSight = true;
	if (BlockCollisionGrid.checkCollisionRectangle(x, y, lastTarget.x, lastTarget.y, collisionType_normal)) {
		inSight = false;
	}
	if (inSight) {
		isDetecting = true;
	}else {
		isDetecting = false;
	}
}else {
	isDetecting = false;
}*/

isMoving = false;
var movementDirection = 0;
if (isTargetting && energyInterface.energy != 0) {
	var isInHSight = lastTarget.y-y >= targetMaxY1 && lastTarget.y-y <= targetMaxY2;
	var isInVSight = abs(lastTarget.x-x) < targetDistance;
		
	if (canMove && (!isInHSight || !isInVSight)) {
		var isEnemyInFront = false;
		for (var i = 0; i < instance_number(obj_slicerDrone); i++) {
			var curEnemy = instance_find(obj_slicerDrone, i);
			if (curEnemy.isMoving && collision_line(x+lastDirection*stoppingDistance, y, x+lastDirection*(1+sprite_width/2), y, curEnemy, false, true)) {
				isEnemyInFront = true;
				break;
			}
		}
		if (!isEnemyInFront) {
			movementDirection = sign(lastTarget.x-x);
		}
	}
		
	if (isInVSight && isInHSight && slash.canStart) {
		audio_play_sound(snd_tele1, 0, false);
		willSlash = true;
		slash.animationSprite = slashAnimationSprite;
		lunge.canAttempt = false;
		lunge.canStart = false;
		slashStartDelayCur = slashStartDelay;
		canMove = false;
		isPreparing = true;
		slash.canStart = false;
	}else if (isInHSight && lunge.canAttempt) {
		lunge.tryStart();
	}
}
if (movementDirection != 0) {
	isMoving = true;
}
if (hasTargetSpd) {
	if_physics.targetMaxHSpeed(ifPhysics, movementDirection*maxSpd, accSpd);
}

if (willSlash) {
	slashStartDelayCur--;
	if (slashStartDelayCur == 0) {
		willSlash = false;
		isPreparing = false;
		slash.startDefault(false);
	}
}

lunge.tick();
slash.tick();