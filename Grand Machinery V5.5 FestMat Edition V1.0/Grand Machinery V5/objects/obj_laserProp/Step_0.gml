/// @description Insert description here
// You can write your code in this editor

if (!energyInterface.hasEnergy) {
	if (doesChargeDecrease && chargeLifetimeFramesCur != 0) {
		chargeLifetimeFramesCur--;
	}
}

if (isShooting) {
	shootDelayFramesCur--;
	if (shootDelayFramesCur == 0) {
		isShooting = false;
		shootLaserDefault();
	}
}