/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
	
draw_sprite(sprite, curSpriteIndex, x, y+dsin(vMoveValue)*yDiff);