/// @description Insert description here
// You can write your code in this editor

//show_debug_message(global.saveInterfaceMap[? id].x);
//show_debug_message(global.saveInterfaceMap[? id].y);
//ifPhysics.applyGravity();

show_debug_message(canBeRepulsedStack);
canBeRepulsedSwitch = ifPhysics.isCollidingDown;

if (iFramesCur > 0) {
	iFramesCur--;
}

#region Horizontal movement

var movementDirection = 0;
if (isBeingRepulsed) {
	canMoveSwitch = false;
}
if (canMoveSwitch && canMoveStack == 0) {
	movementDirection = InputManager.isInputActivated(input_ID.right) - InputManager.isInputActivated(input_ID.left);
}
canMoveSwitch = true;

if (true) {
	curDirection = movementDirection;

	if (movementDirection != 0) {
		lastDirection = movementDirection;
	}
}

if (ifPhysics.isStrongKnockbackedStack == 0) {
	if (movementDirection != 0) {
		if_physics.targetMaxHSpeed(ifPhysics, movementDirection*maxSpd, accSpd);
	}
}

#endregion

#region Jumping

if (ifPhysics.isCollidingDown) {
	coyoteFramesCur = coyoteFrames;
}else if (coyoteFramesCur != 0) {
	coyoteFramesCur--;
}

if (isHoldingJump) {
	if (!InputManager.isInputActivated(input_ID.jump)) {
		if (ifPhysics.vSpd < 0) ifPhysics.vSpd *= 0.5;
		isHoldingJump = false;
	}
}

if (canJumpStack == 0 && canJumpSwitch && InputManager.isInputActivated(input_ID.jump)) {
	if (coyoteFramesCur != 0) {
		jump();
	}
}
canJumpSwitch = true;
isBeingRepulsed = false;

#endregion

#region Sliding

slide.tick();
if (!PlayerManager.isDead && slide.canSlideSwitch && slide.canSlideStack == 0 && !slide.isSliding && InputManager.isInputActivated(input_ID.dashStart)) {
	slide.start();
}else if (slide.isSliding) {
	if (
		InputManager.isInputActivated(input_ID.dashEnd) ||
		place_meeting(x, y, obj_enemyParent) ||
		ifPhysics.isCollidingLeft || ifPhysics.isCollidingRight || !ifPhysics.isCollidingDown ||
		ifPhysics.vSpd > 0
	) {
		slide.stop();
	}
}
slide.canSlideSwitch = true;

#endregion

#region Healing

healing.tick();
if (!PlayerManager.isDead && !healing.hasCharged && healing.canStartSwitch && healing.canStartStack == 0 && InputManager.isInputActivated(input_ID.hlthPacket)) {
	healing.start();
}
healing.canStartSwitch = true;

#endregion

roll.tick();
rollSlash.tick();

downwardsShot.tick();
slideShot.tick();
diveSlash.tick();
greatSlash.tick();
slideSlash.tick();
slash.tick();
shot.tick();

if (queuedBlink) {
	queuedBlink = false;
	PlayerManager.charge += 2;
	if (PlayerManager.charge >= PlayerManager.chargeMax) PlayerManager.charge = PlayerManager.chargeMax;
	shot.isEnemyBlinkWindow = false;
	shot.isBlinkingEnemy = false;
	shot.blinkedEnemy = undefined;
	audio_play_sound(snd_blinkSuper, 0, false);
	shot.blinkShotEvent.notifiesEnd = false;
	shot.blinkShotEvent.curDir = queuedBlinkDir;
	shot.blinkShotEvent.dmg = queuedBlinkDmg;
	shot.blinkShotEvent.curY = queuedBlinkY;
	if (queuedBlinkDir == 1) {
		ActionObjectManagers.hitscan.start(queuedBlinkX, queuedBlinkY, 1, 0, shot.blinkShotEvent);
	}
	else {
		ActionObjectManagers.hitscan.start(queuedBlinkX, queuedBlinkY, -1, 0, shot.blinkShotEvent);
	}
	audio_play_sound(snd_playerShot, 0, false);
}

if (slideSlash.peakFramesCur > 0) {
	slideSlash.peakFramesCur--;
}
if (slideSlash.peakFramesCur == 0 || sign(ifPhysics.hSpd) != sign(slideSlash.peakSpd)) {
	slideSlash.peakSpd = ifPhysics.hSpd;
	slideSlash.peakFramesCur = slideSlash.peakFrames;
}

if (abs(ifPhysics.hSpd) > abs(slideSlash.peakSpd)) {
	slideSlash.peakSpd = ifPhysics.hSpd;
	slideSlash.peakFramesCur = slideSlash.peakFrames;
}

if (execuitionFramesCur > 0) {
	execuitionFramesCur--;
	if (execuitionFramesCur <= 0) {
		executionPip = 0;
	}
}
if (hasExecuted) {
	executionPip = 0;
	hasExecuted = false;
}

if (willOverkill) {
	willOverkill = false;
	executionPip = executionPipNew;
	execuitionFramesCur = executionFrames;
}

PlayerManager.mainInventory.tick();

if (ifPhysics.isCollidingDown) {
	isStrongKnockbacked = false;
}

if (!instance_exists(shot.blinkedEnemy)) {
	shot.isEnemyBlinkWindow = false;
	shot.isBlinkingEnemy = false;
	shot.blinkedEnemy = undefined;
}

//ifPhysics.applySpeed();

image_alpha = 1.0;
damageFlashing.tick();

selfDrawer.tick();
