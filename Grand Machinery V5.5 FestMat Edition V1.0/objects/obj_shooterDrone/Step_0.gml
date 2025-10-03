/// @description Insert description here
// You can write your code in this editor

event_inherited();

if (detectionFramesCur > 0) {
	detectionFramesCur--;
}

if (isTargetting) {
	if (lockedDir == 0) {
		var newDirection = sign(lastTarget.x - x);
		if (newDirection != 0) {
			targDir = newDirection;
		}
		if (targDir != currentDirection) {
			reactionTimeCur++;
			if (reactionTimeCur == reactionTime) {
				currentDirection = targDir;
			}
		}else {
			reactionTimeCur = 0;
		}
	}
	
	shooting.isCooldownActive = true;
	hasDetectedPlayer = true;
	
	var yDistanceDiff = y-lastTarget.y;
	if (energyInterface.energy >= blowingEnergyCost && abs(lastTarget.x - x) <= blowingDistance && yDistanceDiff >= blowingHeightMin && yDistanceDiff < blowingHeightMax) {
		if (!isChargingBlow && !isRecoveringBlow) {
			shooting.stunWeak();
			isChargingBlow = true;
			audio_play_sound(snd_blow, 0, false);
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