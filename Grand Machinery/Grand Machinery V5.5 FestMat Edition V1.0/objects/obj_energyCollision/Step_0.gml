/// @description Insert description here
// You can write your code in this editor

if (energyInterface.hasEnergy && array_length(InstanceCollisionGrid.rectangleGetCollidedInstances(bbox_left, bbox_top, bbox_right, bbox_bottom)) == 1) {
	if (!isActive) {
		activate();
	}
	energyInterface.useEnergy(energyUseFrame);
}else {
	if (isActive) {
		deactivate();
	}
}
event_inherited();

