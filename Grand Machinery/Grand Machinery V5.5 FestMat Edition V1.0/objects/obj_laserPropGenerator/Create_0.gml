/// @description Insert description here
// You can write your code in this editor
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

event_inherited();
spriteBase = spr_laserPropGenerator;
spriteCharge = spr_laserPropGeneratorCharge;
spriteBeam = spr_laserPropGeneratorBeam;
