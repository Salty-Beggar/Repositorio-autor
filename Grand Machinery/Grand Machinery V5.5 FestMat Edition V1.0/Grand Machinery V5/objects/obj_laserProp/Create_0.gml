/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

with (energyInterface) {
	receiveEnergyExtra = function(energyI) {
		instanceID.flashCharge();
	}
	powerOnExtra = function() {
		instanceID.startShooting();
	}
}
succesful = false;

hDir = (image_angle == 0) - (image_angle == 180 || image_angle == -180);
vDir = (image_angle == -90 || image_angle == 270) - (image_angle == 90);

spriteBase = spr_laserProp;
spriteCharge = spr_laserPropCharge;
spriteBeam = spr_laserPropBeam;
chargeLifetimeFrames = 120;	
chargeLifetimeFramesCur = 0;
doesChargeDecrease = true;

lastShotLengths = [0];

flashCharge = function() {
	AlarmManager.activate(chargeLifetimeAlarm);
}
flashChargeApply = function() {
	chargeLifetimeFramesCur = chargeLifetimeFrames;
}
chargeLifetimeAlarm = AlarmManager.constructAlarm(self, flashChargeApply);

energyObjIgnoreMap = ds_map_create();
ds_map_add(energyObjIgnoreMap, obj_energyCollision, pointer_null);
ds_map_add(energyObjIgnoreMap, obj_shooterDroneProjectile, pointer_null);

startShootingApply = function() {
	if (!isShooting) {
		isShooting = true;
		shootDelayFramesCur = shootDelayFrames;
	}
}
startShooting = function() {
	AlarmManager.activate(shootDelayAlarm);
}
shootDelayAlarm = AlarmManager.constructAlarm(id, startShootingApply);

/*if (energyInterface.hasEnergy) {
	startShooting();
}*/
laserEvent = {
	_p: other,
	notifiesEnd: false,
	shotEnergy: undefined,
	notifyCollisionInst: function(instI) {
		if (
			EnergyInterface.hasInstance(instI.id) &&
			instI.id != _p.id &&
			!ds_map_exists(_p.energyObjIgnoreMap, instI.object_index)
		) {
			instI.energyInterface.receiveEnergy(shotEnergy);
			notifiesEnd = true;
		}
	},
	notifyCollisionBlock: function(colTypeI) {
		if (colTypeI == collisionType_normal) notifiesEnd = true;
	},
	notifyHoriHitscanEnd: function(finalXI) {
		var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_laserPropTrail);
		newLaserTrail.initialize(_p.x, _p.y, _p.hDir, 0, abs(finalXI-_p.x));
	},
	notifyVertHitscanEnd: function(finalYI) {
		var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_laserPropTrail);
		newLaserTrail.initialize(_p.x, _p.y, 0, _p.vDir, abs(finalYI-_p.y));
	}
}

function shootLaser(horiDirectionI, vertDirectionI, shotEnergyI, shotIndexI = 0) {
	laserEvent.shotEnergy = shotEnergyI;
	laserEvent.notifiesEnd = false;
	if (!shortcuttedShotsIsIt[shotIndexI])
		ActionObjectManagers.hitscan.start(x, y, horiDirectionI, vertDirectionI, laserEvent);
	else
		ActionObjectManagers.hitscan.startShortcutInst(x, y, horiDirectionI, vertDirectionI, laserEvent, shortcuttedShotsInstances[shotIndexI]);
	energyInterface.useEnergy(shotEnergyI);
}
function shootLaserDefault() {
	shootLaser(hDir, vDir, energyInterface.energy);
}

function receiveEnergy(energyI) {
	energyInterface.energy += energyI;
}