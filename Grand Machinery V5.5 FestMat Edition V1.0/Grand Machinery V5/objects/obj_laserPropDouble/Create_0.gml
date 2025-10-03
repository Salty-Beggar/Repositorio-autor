/// @description Insert description here
// You can write your code in this editor
// Inherit the parent event
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

event_inherited();

isHorizontal = image_angle == 0;
isVertical = image_angle == 90;

lastShotLengths = [0, 0];

spriteBase = spr_laserPropDouble;
spriteCharge = spr_laserPropDoubleCharge;
spriteBeam = spr_laserPropDoubleBeam;

function shootLaserDefault() {
	if (isHorizontal) {
		var energyHalf = energyInterface.energy/2;
		shootLaser(1, 0, energyHalf, 0);
		shootLaser(-1, 0, energyHalf, 1);
	}else {
		var energyHalf = energyInterface.energy/2;
		shootLaser(0, 1, energyHalf, 0);
		shootLaser(0, -1, energyHalf, 1);
	}
}