/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
event_inherited();

baseSprite = spr_nodePropGenerator;
chargeSprite = spr_nodePropGeneratorCharge;
genChargeSprite = spr_nodePropGeneratorGenCharge;