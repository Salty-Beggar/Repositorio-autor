/// @description Insert description here
// You can write your code in this editor

targettingInterface.updateCurrentTarget();
isTargetting = targettingInterface.isTargetting;
if (isTargetting) {
	lastTarget = targettingInterface.curTarget;
}

statHUDInterface.isVisible = ObjectManager_Camouflage.instanceIsCamouflaged(self);

if (repulsesPlayer && place_meeting(x, y, obj_player) && obj_player.canBeRepulsedStack == 0  && obj_player.canBeRepulsedSwitch) {
	var curPushDirection = sign(obj_player.x-x);
	if_physics.targetMaxHSpeed(obj_player.ifPhysics, curPushDirection*playerRepulsionForce, maxRepulsionForce+abs(ifPhysics.hSpd));
	obj_player.isBeingRepulsed = true;
}