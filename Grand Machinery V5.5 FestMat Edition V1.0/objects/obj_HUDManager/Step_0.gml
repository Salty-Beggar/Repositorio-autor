/// @description Insert description here
// You can write your code in this editor

if (healthBar.lifetimeFramesCur != 0) {
	healthBar.lifetimeFramesCur--;
}

if (mainInventory.lifetimeFramesCur != 0) {
	mainInventory.lifetimeFramesCur--;
}

if (point.lifetimeFramesCur != 0) {
	point.lifetimeFramesCur--;
}

if (pointIsUpdatingAmount) {
	pointAmountUpdateFramesCur--;
	if (pointAmountUpdateFramesCur == 0) {
		pointIsUpdatingAmount = false;
		pointCurAmount = pointTargAmount;
	}else {
		var curRatio = (pointAmountUpdateFrames-pointAmountUpdateFramesCur)/pointAmountUpdateFrames;
		pointCurAmount = round(pointInitAmount+curRatio*(pointTargAmount-pointInitAmount));
	}
}

hlthPacket.tick();
var curEnemyHUDObjs = ds_map_keys_to_array(enemyHUDMap);
for (var i = 0; i < array_length(curEnemyHUDObjs); i++) {
	if (object_exists(curEnemyHUDObjs[i]))
		show_debug_message(object_get_name(curEnemyHUDObjs[i]));
}
for (var i = 0; i < array_length(curEnemyHUDObjs); i++) {
	var curEnemy = curEnemyHUDObjs[i];
	var curEnemyHUD = enemyHUDMap[?curEnemy];
	if (!instance_exists(curEnemy)) {
		curEnemyHUD.cleanup();
		delete curEnemyHUD;
		ds_map_delete(enemyHUDMap, curEnemy);
	}else {
		with (curEnemyHUD) {
			if (hlthLifetimeCur != 0) {
				hlthLifetimeCur--;
			}
			with (hlthPipHighlight) {
				for (var j = 0; j < arrCap; j++) {
					if (array[j][0] != 0) {
						array[j][0]--;
					}
				}
			}
			
			if (hasEnergy) {
				if (energyLifetimeCur != 0) {
					energyLifetimeCur--;
				}
				with (energyPipHighlight) {
					for (var j = 0; j < arrCap; j++) {
						if (array[j][0] != 0) {
							array[j][0]--;
						}
					}
				}
			}
			if (hasFuel && fuelLifetimeCur != 0) {
				fuelLifetimeCur--;
			}
		}
	}
}

if (InputManager.isInputActivated(input_ID.seeHUD)) {
	flashAll();
}

pointPopups.tick();