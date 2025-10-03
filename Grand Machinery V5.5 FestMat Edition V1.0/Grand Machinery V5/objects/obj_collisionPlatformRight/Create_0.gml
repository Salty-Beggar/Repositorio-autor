/// @description Insert description here
// You can write your code in this editor
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
	
event_inherited();

collisionType = collisionType_onewayRight;
activate();