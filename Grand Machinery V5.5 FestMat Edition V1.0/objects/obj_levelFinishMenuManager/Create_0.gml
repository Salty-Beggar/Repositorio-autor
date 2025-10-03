/// @description Insert description here
// You can write your code in this editor

curDisplayInfo = PointsManager.stageFinishMenuInfo;
curDisplayInfoGameplay = GameplayManager.stageFinishMenuInfo;
curDisplayInfoStage = StageManager.stageFinishMenuInfo;
if (curDisplayInfoGameplay.isMainLevel) curDisplayInfoMainLevel = MainLevelManager.stageFinishMenuInfo;

currentStage = curDisplayInfo.currentStage;
hasPrevPoints = curDisplayInfo.hasPrevScore;

killPoints = curDisplayInfo.killPoints;
comboPoints = curDisplayInfo.comboPoints;
damagePenalty = curDisplayInfo.damagePenalty;

killPointsDisplayed = 0;
comboPointsDisplayed = 0;
damagePenaltyDisplayed = 0;

curPoints = curDisplayInfo.curPoints;
highscore = curDisplayInfo.highscore;

if (curDisplayInfoGameplay.isMainLevel) mechcoinGain = curDisplayInfoMainLevel.mechcoinGain;

curPointsDisplayed = 0;

timeFrames = curDisplayInfo.timeFrames;
smallestTime = curDisplayInfo.smallestTime;

timeFramesDisplayed = 0;

ranking = curDisplayInfo.ranking;

restartAmount = curDisplayInfo.restartAmount;

pointDisplayFont = ft_levelInfoFinish;
pointDisplayXBorder = 50;
var constructPointDisplay = function(yI, nameI) {
	return {
		y: yI,
		name: nameI,
		value: "",
		color: c_white
	}
}

pointDisplaySetValue = function(pointDisplayI, valueI) {
	pointDisplayI.value = valueI;
}

pointDisplaySetColor = function(pointDisplayI, colorI) {
	pointDisplayI.color = colorI;
}

pointDisplaySetName = function(pointDisplayI, nameI) {
	pointDisplayI.name = nameI;
}

pointDisplayDraw = function(pointDisplayI) {
	draw_set_color(pointDisplayI.color);
	draw_set_font(pointDisplayFont);
	draw_text(pointDisplayXBorder, pointDisplayI.y, pointDisplayI.name);
	draw_text(gameResolutionWidth-pointDisplayXBorder-string_width(pointDisplayI.value), pointDisplayI.y, pointDisplayI.value);
}

pointDisplayPointUpdateColor = function(pointDisplayI, valueI, startingIndexI) {
	var curRanking = startingIndexI;
	var nonPRankAmount = 5;
	var curPointRequirement = currentStage.pointRequirements.pointArr;
	while (curRanking != nonPRankAmount-1 && valueI > curPointRequirement[curRanking]) {
		curRanking++;
	}
	while (curRanking != 0 && valueI <= curPointRequirement[curRanking-1]) {
		curRanking--;
	}
	pointDisplaySetColor(pointDisplayI, RankingManager.colors[curRanking]);
	return curRanking;
}

pointDisplayTimeUpdateColor = function(pointDisplayI, valueI, startingIndexI) {
	var curRankingReverse = startingIndexI;
	var nonPRankAmount = 5;
	var curTimeRequirements = currentStage.pointRequirements.timeArr;
	while (curRankingReverse != nonPRankAmount-1 && valueI > curTimeRequirements[curRankingReverse]) {
		curRankingReverse++;
	}
	while (curRankingReverse != 0 && valueI <= curTimeRequirements[curRankingReverse-1]) {
		curRankingReverse--;
	}
	pointDisplaySetColor(pointDisplayI, RankingManager.colors[nonPRankAmount-1-curRankingReverse]);
	return curRankingReverse;
}

// Current state
currentGeneralState = 0; /*
0 - Point attributes
1 - Finished
*/

// Points attributes
var pointAttributeYStart = 50;
var pointAttributeYSpacing = 40;
killPointsDisplay = constructPointDisplay(pointAttributeYStart+0*pointAttributeYSpacing, "Kills");
comboPointsDisplay = constructPointDisplay(pointAttributeYStart+1*pointAttributeYSpacing, "Combo");
damagePointsDisplay = constructPointDisplay(pointAttributeYStart+2*pointAttributeYSpacing, "Dano tomado");
pointDisplaySetValue(killPointsDisplay, string(killPointsDisplayed));
pointDisplaySetValue(comboPointsDisplay, string(comboPointsDisplayed));
pointDisplaySetValue(damagePointsDisplay, string(damagePenaltyDisplayed));

isUpdatingAttribute = false;
attributeIndex = 0;

// Points and highscore
curPointsDisplay = constructPointDisplay(240, "Pontos");
curPointsDisplayedRanking = 0;
pointDisplaySetValue(curPointsDisplay, string(curPointsDisplayed));
if (hasPrevPoints) {
	curHighscoreDisplay = constructPointDisplay(280, "Pontuação máxima");
	pointDisplaySetValue(curHighscoreDisplay, string(highscore));
	pointDisplayPointUpdateColor(curHighscoreDisplay, highscore, 0);
}


// Time and smallest time
isUpdatingTime = false;
curTimeDisplay = constructPointDisplay(340, "Tempo");
pointDisplaySetValue(curTimeDisplay, timeframes_to_string(timeFramesDisplayed));
curTimeDisplayedRanking = 0;
if (hasPrevPoints) {
	curSmallestTimeDisplay = constructPointDisplay(380, "Menor tempo");
	pointDisplaySetValue(curSmallestTimeDisplay, timeframes_to_string(smallestTime));
	pointDisplayTimeUpdateColor(curSmallestTimeDisplay, smallestTime, 0);
}


// Ranking && restart && mechcoins
isRankingVisible = false;
rankingFont = ft_levelInfoRankFinish;
rankingX = 670;
rankingY = 490;
restartX = pointDisplayXBorder;
restartY = 500;
restartFont = pointDisplayFont;
restartColor = c_white;
if (curDisplayInfoGameplay.isMainLevel) {
	mechcoinX = pointDisplayXBorder;
	mechcoinY = 550;
	mechcoinFont = pointDisplayFont;
	mechcoinColor = c_white;
}
if (restartAmount == 0) {
	restartColor = RankingManager.colors[rankings.S];
}

// Default defitions
defaultIncreaseRate = 10;

// Cooldown
isInCooldown = true;
cooldownFrames = 110;
cooldownFramesCur = 110;
doCooldown = function() {
	isInCooldown = true;
	cooldownFramesCur = cooldownFrames;
}

// White flash
isFlashing = false;
flashFrames = 0;
flashFramesCur = 0;
flashFramesDefault = 120;
flashFramesQuick = 50;
doFlash = function(isQuickI) {
	isFlashing = true;
	if (isQuickI) {
		flashFrames = flashFramesQuick;
	}else {
		flashFrames = flashFramesDefault;
	}
	flashFramesCur = flashFrames;
}

