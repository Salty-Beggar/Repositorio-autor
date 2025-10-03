/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

if (place_meeting(x, y, obj_player)) {
	PlayerManager.mainInventory.receiveItem(toolIndex);
	HUDManager.mainInventory.flash();
	StageObjectManager.destroyObjectByInstance(self);
}

vMoveValue++;