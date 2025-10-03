/// @description Insert description here
// You can write your code in this editor

pointDisplayDraw(killPointsDisplay);
pointDisplayDraw(comboPointsDisplay);
pointDisplayDraw(damagePointsDisplay);

pointDisplayDraw(curPointsDisplay);
pointDisplayDraw(curTimeDisplay);

if (hasPrevPoints) {
	pointDisplayDraw(curSmallestTimeDisplay);
	pointDisplayDraw(curHighscoreDisplay);
}

if (isRankingVisible) {
	if (!curDisplayInfoStage.isRankless) {
		draw_set_color(RankingManager.colors[ranking]);
		draw_set_font(rankingFont);
		draw_text(rankingX, rankingY, RankingManager.strings[ranking]);
	}
	
	draw_set_color(restartColor);
	draw_set_font(restartFont);
	draw_text(restartX, restartY, "Reinícios "+string(restartAmount));
	
	if (curDisplayInfoGameplay.isMainLevel) {
		draw_set_color(mechcoinColor);
		draw_set_font(mechcoinFont);
		draw_text(mechcoinX, mechcoinY, "Mecamoedas "+string(mechcoinGain));
	}
}

if (isFlashing) {
	draw_set_color(c_white);
	var curAlpha = flashFramesCur/flashFrames;
	draw_set_alpha(curAlpha);
	draw_rectangle(0, 0, gameResolutionWidth, gameResolutionHeight, false);
	draw_set_alpha(1.0);
}