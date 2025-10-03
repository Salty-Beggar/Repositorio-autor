/// @description Insert description here
// You can write your code in this editor

CameraSubmanager.notifyPlayerMovementFinish();

if (!isControlled && canLeaveStack == 0) {
	instance_destroy();
}

if (InputSubmanager.joystick.isBeingPressed())
	lastDirection = InputSubmanager.joystick.returnDirection();

if (InputSubmanager.inputMode == INPUT_DEVICE.controller && (abs(gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrh)) >= 0.2 || abs(gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrv) >= 0.2))) {
	lastDirection2 = InputSubmanager.joystick2.returnDirection();
}