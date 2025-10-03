/// @description Insert description here
// You can write your code in this editor

if (energyCooldownCur != 0) {
	energyCooldownCur--;
	if (energyCooldownCur == 0){ 
		energyCooldownCur = energyCooldown;
		energyInterface.receiveEnergy(energyGeneration);
	}
}

event_inherited();