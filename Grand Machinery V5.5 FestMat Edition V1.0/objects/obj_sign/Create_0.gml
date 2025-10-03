/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

dialogue = DialogueManager.constructDialogue(text, true, spr_battery, true);
isBeingRead = false;