/// @description Insert description here
// You can write your code in this editor

energyCooldownCur--;
if (energyCooldownCur == 0) {
	energyInterface.setEnergy(2);
	chargeLifetimeFramesCur = chargeLifetimeFrames;
	energyCooldownCur = energyCooldown;
	shootLaserDefault();
}
if (chargeLifetimeFramesCur != 0) {
	chargeLifetimeFramesCur--;
}