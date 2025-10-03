/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

laserColor = c_aqua;
laserAlphaUncharged = 0.3;
laserAlphaCharged = 0.7;
areConnectionsVisible = true;
connectionsVisibility = array_create(array_length(destinations), true);

baseSprite = spr_nodeProp;
chargeSprite = spr_nodePropCharge;
chargeLifetimeFrames = 120;
chargeLifetimeFramesCur = 0;

with (hlthInterface) {
	dieExtra = function() {
		StageObjectManager.destroyObjectByInstance(instanceID);
	}
}

with (energyInterface) {
	powerOnExtra = function() {
		for (var i = 0; i < array_length(instanceID.destinations); i++) {
			var curDest = instanceID.destinations[i];
			if (instance_exists(curDest)) {
				curDest.energyInterface.receiveEnergy(energy);
			}
		}
		instanceID.flashCharge();
		useEnergy(energy);
	}
}

flashCharge = function() {
	chargeLifetimeFramesCur = chargeLifetimeFrames;
}

array_copy(connectionsVisibility, 0, connectionsVisibilityInput, 0, array_length(connectionsVisibilityInput));
