/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

usesEnergy = false;
fuel = 0;
fuelMax = 0;
usesFuel = false;
enemyHUDDefinitions = -1;

repulsesPlayer = true;
playerRepulsionForce = 2;
maxRepulsionForce = 4;

isTargetting = false;
curTarget = undefined;
lastTarget = undefined;

killPoints = 100;

function initialize(hlthI, usesEnergyI, energyI, usesFuelI, fuelI, killPointsI) {
	killPoints = killPointsI;
	
	targettingInterface.canTarget = true;
	curTarget = targettingInterface.targetCheckingOrder[0];
	lastTarget = curTarget;
	
	function enemyReceiveDmgExtra(hlthI) {}
	function enemyReceiveHlthExtra(hlthI) {}
	function enemySetHlthExtra(hlthI) {}
	
	with (hlthInterface) {
		receiveDamageExtra = function(hlthI) {
			instanceID.enemyReceiveDmgExtra(hlthI);
		}
		receiveHlthExtra = function(hlthI) {
			instanceID.enemyReceiveHlthExtra(hlthI);
		}
		setHlth = function(hlthI) {
			instanceID.enemySetHlthExtra(hlthI);
			hlth = hlthI;
		}
		dieExtra = function() {
			instanceID.die();
		}
	}
	
	usesEnergy = usesEnergyI;
	if (usesEnergy) {
		function enemyUseEnergyExtra(energyI) {}
		function enemyReceiveEnergyExtra(energyI) {}
		function enemySetEnergyExtra(energyI) {}
		
		with (energyInterface) {
			useEnergyExtra = function(energyI) {
				instanceID.enemyUseEnergyExtra(energyI);
			}
			receiveEnergyExtra = function(energyI) {
				instanceID.enemyReceiveEnergyExtra(energyI);
				
			}
			setEnergyExtra = function(energyI) {
				instanceID.enemySetEnergyExtra(energyI);
			}
			powerOffExtra = function() {
				instanceID.targettingInterface.canTarget = false;
			}
			powerOnExtra = function() {
				instanceID.targettingInterface.canTarget = true;
			}
		}
	}
	
	usesFuel = usesFuelI;
	if (usesFuel) {
		fuel = fuelI;
		fuelMax = fuelI;
	}
}

function die() {
	audio_play_sound(snd_holy, 0, false);
	PointsManager.notifyEnemyKill(self);
	StageObjectManager.destroyObjectByInstance(self);
}