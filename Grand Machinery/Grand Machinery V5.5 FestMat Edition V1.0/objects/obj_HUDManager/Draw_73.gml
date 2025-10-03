/// @description Insert description here
// You can write your code in this editor

#region Enemy HUD drawing

var curEnemyHUDObjs = ds_map_keys_to_array(enemyHUDMap);
for (var i = 0; i < array_length(curEnemyHUDObjs); i++) {
	var curEnemy = curEnemyHUDObjs[i];
	var curHUDDefinitions = enemyHUDMap[?curEnemyHUDObjs[i]];
	if (!instance_exists(curEnemy)) {
		curHUDDefinitions.cleanup();
		delete curHUDDefinitions;
		ds_map_delete(enemyHUDMap, curEnemy);
		break;
	}
	if (curHUDDefinitions.isVisible) {
		var curYAdd = 0;
		for (var j = curHUDDefinitions.barAmount-1; j >= 0; j--) {
			var curY1 = 0;
			var curY2 = curYAdd;
			var pipAmount = 0;
			var pipWidth = 0;
			var pipHeight = 0;
			var barWidth = 0;
			var pipColor = 0;
			var pipSpacing = 0;
			var barAlpha = 0;
			var remainingValue = 0;
			var pipHighlightArr = [];
			var pipCapacity = 0;
			switch (curHUDDefinitions.barIndexes[j]) {
				case enemyHUD.hlthBarIndex:
					var curYAddSubtract = enemyHUD.borderThickness+curHUDDefinitions.hlthHeight;
					curYAdd -= curYAddSubtract;
				
					curY1 = curY2-curYAddSubtract-enemyHUD.borderThickness;
					pipAmount = curHUDDefinitions.hlthPipAmount;
					pipCapacity = curHUDDefinitions.hlthPipCap;
					pipWidth = curHUDDefinitions.hlthWidth;
					pipHeight = curHUDDefinitions.hlthHeight;
					barWidth = curHUDDefinitions.hlthBarWidth;
					pipColor = enemyHUD.hlthColor;
					pipSpacing = curHUDDefinitions.hlthPipSpacing;
					remainingValue = curEnemy.hlthInterface.hlth/curHUDDefinitions.hlthPipCap;
					barAlpha = min(1.0, curHUDDefinitions.hlthLifetimeCur/curHUDDefinitions.barDisappearFrame);
					pipHighlightArr = curHUDDefinitions.hlthPipHighlight.array;
					break;
				case enemyHUD.energyBarIndex:
					var curYAddSubtract = enemyHUD.borderThickness+curHUDDefinitions.energyHeight;
					curYAdd -= curYAddSubtract;
				
					curY1 = curY2-curYAddSubtract-enemyHUD.borderThickness;
					pipAmount = curHUDDefinitions.energyPipAmount;
					pipCapacity = curHUDDefinitions.energyPipCap;
					pipWidth = curHUDDefinitions.energyWidth;
					pipHeight = curHUDDefinitions.energyHeight;
					barWidth = curHUDDefinitions.energyBarWidth;
					pipColor = enemyHUD.energyColor;
					pipSpacing = curHUDDefinitions.energyPipSpacing;
					remainingValue = curEnemy.energyInterface.energy/curHUDDefinitions.energyPipCap;
					barAlpha = min(1.0, curHUDDefinitions.energyLifetimeCur/curHUDDefinitions.barDisappearFrame);
					pipHighlightArr = curHUDDefinitions.energyPipHighlight.array;
					break;
				default:
					var curYAddSubtract = enemyHUD.borderThickness+curHUDDefinitions.fuelHeight;
					curYAdd -= curYAddSubtract;
				
					curY1 = curY2-curYAddSubtract-enemyHUD.borderThickness;
					pipAmount = curHUDDefinitions.fuelPipAmount;
					pipCapacity = curHUDDefinitions.fuelPipCap;
					pipWidth = curHUDDefinitions.fuelWidth;
					pipHeight = curHUDDefinitions.fuelHeight;
					barWidth = curHUDDefinitions.fuelBarWidth;
					pipColor = enemyHUD.fuelColor;
					pipSpacing = curHUDDefinitions.fuelPipSpacing;
					remainingValue = curEnemy.fuel/curHUDDefinitions.fuelPipCap;
					barAlpha = min(1.0, curHUDDefinitions.fuelLifetimeCur/curHUDDefinitions.barDisappearFrame);
					break;
			}
			
			if (barAlpha != 0) {
				var curMainX = curEnemy.x+curHUDDefinitions.barsXOffset;
				var curMainY = curEnemy.y-curHUDDefinitions.barsYOffset+curYAdd;
				var barHeight = curY2-curY1;
				
				draw_set_alpha(barAlpha);
				draw_set_color(enemyHUD.borderColor);
				draw_rectangle(
					curMainX, curMainY,
					curMainX+barWidth-1, curMainY+barHeight-1,
					false
				);
		
				var curPipX = enemyHUD.borderThickness;
				var pipY = enemyHUD.borderThickness;
				for (var pip = 0; pip < pipAmount; pip++) {
					
					draw_set_alpha(barAlpha);
					
					// Back of pip
					draw_set_color(enemyHUD.emptyColor);
					draw_rectangle(
						curMainX+curPipX, curMainY+pipY, curMainX+curPipX+pipWidth-1, curMainY+pipY+pipHeight-1, false
					);
					
					// Pip itself
					var curPipRatio = max(0, min(1, remainingValue));
					var isHorizontal = pipWidth > pipHeight;
					var curPipProgress = pip+curPipRatio;
					
					draw_set_color(pipColor);
					if (isHorizontal) {
						draw_rectangle(
							curMainX+curPipX, curMainY+pipY, curMainX+curPipX+curPipRatio*pipWidth-1, curMainY+pipY+pipHeight-1, false
						);
					}else {
						draw_rectangle(
							curMainX+curPipX, curMainY+pipY, curMainX+curPipX+pipWidth-1, curMainY+pipY+curPipRatio*pipHeight-1, false
						);
					}
					
					draw_set_color(enemyHUD.pipHighlightColor);
					for (var c = 0; c < enemyHUD.pipHighlightArrCapacity; c++) {
						var curHighlight = pipHighlightArr[c];
						var valueStart = curHighlight[1]/pipCapacity;
						var valueEnd = curHighlight[2]/pipCapacity;
						if (pip >= valueStart && pip < valueEnd) {
							var curHighlightAlpha = curHighlight[0]/enemyHUD.pipHighlightLifetime;
							var curPipStartRatio = max(0.0, valueStart-pip);
							var curPipEndRatio = min(1.0, valueEnd-pip);
							draw_set_alpha(curHighlightAlpha*barAlpha);
							if (isHorizontal) {
								draw_rectangle(
									curMainX+curPipX+curPipStartRatio*pipWidth, curMainY+pipY, curMainX+curPipX+curPipEndRatio*pipWidth-1, curMainY+pipY+pipHeight-1, false
								);
							}else {
								draw_rectangle(
									curMainX+curPipX, curMainY+pipY+curPipStartRatio*pipHeight, curMainX+curPipX+pipWidth-1, curMainY+pipY+curPipEndRatio*pipHeight-1, false
								);
							}
						}
					}
					draw_set_alpha(1.0);
					
					remainingValue--;
					curPipX += pipSpacing;
				}
			}
		}
	}
}
draw_set_alpha(1.0);

#endregion

pointPopups.draw();