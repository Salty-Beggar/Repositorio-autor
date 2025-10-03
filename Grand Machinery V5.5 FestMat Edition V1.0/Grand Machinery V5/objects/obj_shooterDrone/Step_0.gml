/// @description Insert description here
// You can write your code in this editor

event_inherited();

if (isTargetting) {
	if (lockedDir == 0) {
		var newDirection = sign(lastTarget.x - x);
		if (newDirection != 0) {
			currentDirection = newDirection;
		}
	}
	
	shooting.isCooldownActive = true;
	hasDetectedPlayer = true;
	
	var yDistanceDiff = y-lastTarget.y;
	if (energyInterface.energy >= blowingEnergyCost && abs(lastTarget.x - x) <= blowingDistance && yDistanceDiff >= blowingHeightMin && yDistanceDiff < blowingHeightMax) {
		if (!isChargingBlow && !isRecoveringBlow) {
			isChargingBlow = true;
			blowingChargeFramesCur = blowingChargeFrames;
		}
	}
}

if (shooting.canStart && hasDetectedPlayer && energyInterface.energy >= shootingEnergyCost) {
	shooting.start();
}

if (isChargingBlow) {
	blowingChargeFramesCur--;
	if (blowingChargeFramesCur == 0) {
		isChargingBlow = false;
		blowing.start();
	}
}else if (isRecoveringBlow) {
	blowingRecoveryFramesCur--;
	if (blowingRecoveryFramesCur == 0) {
		isRecoveringBlow = false;
	}
}

shooting.tick();
selfDrawer.tick();