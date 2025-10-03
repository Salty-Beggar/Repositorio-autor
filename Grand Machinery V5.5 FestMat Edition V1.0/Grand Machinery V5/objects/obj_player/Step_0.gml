/// @description Insert description here
// You can write your code in this editor

//show_debug_message(global.saveInterfaceMap[? id].x);
//show_debug_message(global.saveInterfaceMap[? id].y);
//ifPhysics.applyGravity();

#region Horizontal movement

var movementDirection = 0;
if (isBeingRepulsed) {
	canMoveSwitch = false;
}
if (canMoveSwitch && canMoveStack == 0) {
	movementDirection = InputManager.isInputActivated(input_ID.right) - InputManager.isInputActivated(input_ID.left);
}
canMoveSwitch = true;

if (canChangeDirection) {
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
if (!PlayerManager.isDead && healing.canStartSwitch && healing.canStartStack == 0 && InputManager.isInputActivated(input_ID.hlthPacket)) {
	healing.start();
}
healing.canStartSwitch = true;

#endregion

slash.tick();
shot.tick();

PlayerManager.mainInventory.tick();

if (ifPhysics.isCollidingDown) {
	isStrongKnockbacked = false;
}

//ifPhysics.applySpeed();

image_alpha = 1.0;
damageFlashing.tick();

selfDrawer.tick();
