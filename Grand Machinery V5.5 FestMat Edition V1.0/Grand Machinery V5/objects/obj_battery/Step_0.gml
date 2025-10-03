/// @description Insert description here
// You can write your code in this editor

var totalGivenEnergy = 0;

for (var i = 0; i < array_length(destinations); i++) {
	var curDest = destinations[i];
	if (instance_exists(curDest)) {
		if (energyInterface.hasEnergy && totalGivenEnergy != energyInterface.energy) {
			if (curDest.energyInterface.energy != curDest.energyInterface.energyMax) {
				var curGivenEnergy = min(energyInterface.energy, curDest.energyInterface.energyMax - curDest.energyInterface.energy);
				totalGivenEnergy += curGivenEnergy;
				curDest.energyInterface.receiveEnergy(curGivenEnergy);
			}
		}
	}
}
if (totalGivenEnergy != 0) {
	energyInterface.useEnergy(totalGivenEnergy);
}