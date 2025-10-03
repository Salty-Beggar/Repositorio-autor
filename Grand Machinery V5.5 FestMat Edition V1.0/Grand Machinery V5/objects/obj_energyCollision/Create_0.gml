/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
// Inherit the parent event
event_inherited();

inactiveAlpha = 0.3;
isCollisionUpdated = false;