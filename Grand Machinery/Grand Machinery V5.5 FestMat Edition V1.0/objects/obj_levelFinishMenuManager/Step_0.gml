/// @description Insert description here
// You can write your code in this editor

if (isInCooldown) {
	if (InputManager.isInputActivated(input_ID.advance)) {
		cooldownFramesCur = 0;
	}else {
		cooldownFramesCur--;
	}
	if (cooldownFramesCur == 0) {
		isInCooldown = false;
	}
}else if (currentGeneralState == 0) {
	if (!isUpdatingAttribute) {
		isUpdatingAttribute = true;
	}else {
		var hasEnded = false;
		var curIncrease = 0;
		switch (attributeIndex) {
			case 0:
				if (killPoints == 0) {
					attributeIndex++;
					break;
				}
				curIncrease = min(defaultIncreaseRate, abs(killPointsDisplayed-killPoints));
				killPointsDisplayed += curIncrease;
				if (killPointsDisplayed == killPoints) {
					hasEnded = true;
				}
				pointDisplaySetValue(killPointsDisplay, string(killPointsDisplayed));
				break;
			case 1:
				if (comboPoints == 0) {
					attributeIndex++;
					break;
				}
				curIncrease = min(defaultIncreaseRate, abs(comboPointsDisplayed-comboPoints));
				comboPointsDisplayed += curIncrease;
				if (comboPointsDisplayed == comboPoints) {
					hasEnded = true;
				}
				pointDisplaySetValue(comboPointsDisplay, string(comboPointsDisplayed));
				break;
			case 2:
				if (damagePenalty == 0) {
					hasEnded = true;
					break;
				}
				curIncrease = min(defaultIncreaseRate, abs(damagePenaltyDisplayed-damagePenalty));
				damagePenaltyDisplayed += curIncrease;
				curIncrease *= -1;
				if (damagePenaltyDisplayed == damagePenalty) {
					hasEnded = true;
				}
				pointDisplaySetValue(damagePointsDisplay, string(damagePenaltyDisplayed));
				break;
		}
		curPointsDisplayed += curIncrease;
		pointDisplaySetValue(curPointsDisplay, string(curPointsDisplayed));
		curPointsDisplayedRanking = pointDisplayPointUpdateColor(curPointsDisplay, curPointsDisplayed, curPointsDisplayedRanking);
		
		if (hasEnded) {
			isUpdatingAttribute = false;
			attributeIndex++;
			doCooldown();
			var attributeAmount = 3;
			if (attributeIndex == attributeAmount) {
				currentGeneralState++;
				if (hasPrevPoints && curPoints > highscore) {
					pointDisplaySetName(curPointsDisplay, "Nova pontuação máxima");
					pointDisplaySetName(curHighscoreDisplay, "Pontuação máxima anterior");
					doFlash(true);
				}
			}
		}
	}
}else if (currentGeneralState == 1) {
	if (!isUpdatingTime) {
		isUpdatingTime = true;
	}else {
		var hasEnded = false;
		var curIncrease = 0;
		var timeIncreaseRate = 60;
		curIncrease = min(timeIncreaseRate, abs(timeFramesDisplayed-timeFrames));
		timeFramesDisplayed += curIncrease;
		if (timeFramesDisplayed == timeFrames) {
			hasEnded = true;
		}
		pointDisplaySetValue(curTimeDisplay, timeframes_to_string(timeFramesDisplayed));
		
		if (hasEnded) {
			isUpdatingTime = false;
			doCooldown();
			currentGeneralState++;
			pointDisplayTimeUpdateColor(curTimeDisplay, timeFramesDisplayed, 0);
			if (hasPrevPoints && timeFrames < smallestTime) {
				pointDisplaySetName(curTimeDisplay, "Novo menor tempo");
				pointDisplaySetName(curSmallestTimeDisplay, "Menor tempo anterior");
				doFlash(true);
			}
		}
	}
}else if (currentGeneralState == 2) {
	doFlash(false);
	isRankingVisible = true;
	currentGeneralState++;
}else if (currentGeneralState == 3) {
	if (InputManager.isInputActivated(input_ID.advance)) {
		TransitionManager.exitMenu();
		TransitionManager.goToMainLevel(MainLevelManager.getLevel(curDisplayInfoMainLevel.FEST_nextLevelIndex)); // OBSERVATION_FEST001: Fazer ir na mesma fase de volta.
		//TransitionManager.goToMenu();
	}
}

if (isFlashing) {
	flashFramesCur--;
	if (flashFramesCur == 0) {
		isFlashing = false;
	}
}