/// @description Insert description here
// You can write your code in this editor

// General
defaultLifetimeFrames = 260;
defaultDisappearFrame = 90;

hlthCurLifetime = defaultLifetimeFrames;
energyCurLifetime = defaultLifetimeFrames;
fuelCurLifetime = defaultLifetimeFrames;

flashAll = function() {
	healthBar.flash(true);
	hlthPacket.flash(true);
	mainInventory.flash(true);
	point.flash(true);
}

notifyPointARank = function() {
	point.pointColor = RankingManager.colors[rankings.A];
}

notifyPointSRank = function() {
	point.pointColor = RankingManager.colors[rankings.S];
}

notifyPointNoRank = function() {
	point.pointColor = RankingManager.colors[rankings.D];
}

notifyTimeARank = function() {
	point.timeColor = RankingManager.colors[rankings.A];
}

notifyTimeSRank = function() {
	point.timeColor = RankingManager.colors[rankings.S];
}

notifyTimeNoRank = function() {
	point.timeColor = RankingManager.colors[rankings.D];
}

// Health
hlth = 100;
hlthMax = 100;

updateHlth = function(hlthI) {
	hlth = hlthI;
	healthBar.flash(false);
}
healthBar = {
	_p: other,
	lifetimeFrames: other.defaultLifetimeFrames,
	lifetimeFramesCur: other.defaultLifetimeFrames,
	disappearFrame: other.defaultDisappearFrame,
	fillWidth: 119,
	fillHeight: 19,
	fillColor: c_red,
	x: 10, y: 10,
	draw: function() {
		var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
		draw_set_alpha(curMainAlpha);
		draw_set_color(fillColor);
		var curRatio = _p.hlth/_p.hlthMax;
		draw_rectangle(x, y, x+curRatio*fillWidth, y+fillHeight, false);
		draw_sprite_ext(spr_healthBarBase, 0, x, y, 1.0, 1.0, 0, c_white, curMainAlpha);
		draw_set_alpha(1.0);
	},
	flash: function(isQuickI) {
		if (isQuickI) lifetimeFramesCur = disappearFrame;
		else lifetimeFramesCur = lifetimeFrames;
	}
}

// Point
pointCurAmount = PointsManager.curPoints;
pointTargAmount =  PointsManager.curPoints;
pointInitAmount = 0;
pointIsUpdatingAmount = false;
pointAmountUpdateFrames = 60;
pointAmountUpdateFramesCur = 60;

timeValueFrames = 0;
setTime = function(timeFramesI) {
	timeValueFrames = timeFramesI;
}

point = {
	_p: other,
	lifetimeFrames: other.defaultLifetimeFrames,
	lifetimeFramesCur: other.defaultLifetimeFrames,
	disappearFrame: other.defaultDisappearFrame,
	x: 670, y: 8,
	width: 120,
	// Points
		pointColor: c_white,
		pointY1: 0,
		pointY2: 32,
		pointFont: ft_HUDPoints,
		pointTextX: 4,
		pointTextY: 0,
	// Time
		timeColor: c_white,
		timeY1: 34,
		timeY2: 58,
		timeSpr: spr_clockSymbol,
		timeSprX: 19, timeSprY: 12,
		timeTextX: 23,
		timeTextY: 9,
		timeFont: ft_HUDTime,
	// Combo
		comboY1: 60,
		comboY2: 70,
		comboColor: c_white,
		comboBarX: 2,
		comboBarWidth: 0,
		comboBarY1: 4,
		comboBarY2: 9,
	backColor: c_black,
	backCornerSprSet: spr_blackBackCorner,
		cornerTopLeft: 0,
		cornerTopRight: 1,
		cornerBottomLeft: 2,
		cornerBottomRight: 3,
	backBorderThickness: 3,
	backBorderAlpha: 0.6,
	draw: function() {
		var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
		drawBack(curMainAlpha, x, y+pointY1, x+width, y+pointY2, true, false);
		drawBack(curMainAlpha, x, y+timeY1, x+width, y+timeY2, false, false);
		drawBack(curMainAlpha, x, y+comboY1, x+width, y+comboY2, false, true);
		
		// Points
		draw_set_font(pointFont);
		draw_set_color(pointColor);
		var curPointString = string(_p.pointCurAmount)+"P";
		draw_text(x+width-pointTextX-string_width(curPointString), y+pointTextY, curPointString);
		
		// Time
		draw_sprite_ext(timeSpr, 0, x+width-timeSprX, timeY1+timeSprY, 1.0, 1.0, 0, timeColor, curMainAlpha);
		var curTimeString = convertFrameToTime();
		draw_set_font(timeFont);
		draw_set_color(timeColor);
		draw_text(x+width-string_width(curTimeString)-timeTextX, timeY1+timeTextY, curTimeString);
		
		// Combo bar
		var curBarRatio = PointsManager.comboLifetimeCur/PointsManager.comboLifetime;
		draw_set_color(comboColor);
		draw_set_alpha(1.0);
		draw_rectangle(x+comboBarX, y+comboY1+comboBarY1, x+comboBarX+curBarRatio*comboBarWidth-1, y+comboY1+comboBarY2-1, false);
	},
	drawBack: function(alphaI, x1I, y1I, x2I, y2I, hasTopI, hasBottomI) {
		var oldAlpha = alphaI;
		alphaI *= backBorderAlpha;
		draw_set_alpha(alphaI);
		draw_set_color(backColor);
		if (hasTopI) {
			draw_sprite_ext(spr_blackBackCorner, cornerTopLeft, x1I, y1I, 1.0, 1.0, 0, c_white, alphaI);
			draw_sprite_ext(spr_blackBackCorner, cornerTopRight, x2I, y1I, 1.0, 1.0, 0, c_white, alphaI);
			draw_rectangle(x1I, y1I-backBorderThickness, x2I-1, y1I-1, false);
			draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
		}else if (hasBottomI) {
			draw_sprite_ext(spr_blackBackCorner, cornerBottomLeft, x1I, y2I, 1.0, 1.0, 0, c_white, alphaI);
			draw_sprite_ext(spr_blackBackCorner, cornerBottomRight, x2I, y2I, 1.0, 1.0, 0, c_white, alphaI);
			draw_rectangle(x1I, y2I, x2I-1, y2I+backBorderThickness-1, false);
			draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
		}else {
			draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
		}
		draw_set_alpha(oldAlpha);
	},
	convertFrameToTime: function() {
		return timeframes_to_string(_p.timeValueFrames);
	},
	flash: function(isQuickI) {
		if (isQuickI) lifetimeFramesCur = disappearFrame;
		else lifetimeFramesCur = lifetimeFrames;
	}
}
with (point) {
	comboBarWidth = width-comboBarX*2;	
}

notifyTimeSRank();
notifyPointNoRank();

pointUpdateAmount = function(pointsI) {
	pointIsUpdatingAmount = true;
	pointAmountUpdateFramesCur = pointAmountUpdateFrames;
	pointTargAmount = pointsI;
	pointInitAmount = pointCurAmount;
}

// Point popups
pointPopups = {
	queue: ds_queue_create(),
	lifetimeFrames: 50,
	comboLifetimeFrames: 80,
	disappearFrame: 20,
	yAdd: -20,
	font: ft_pointPopup,
	color: c_white,
	add: function(pointsI, xI, yI) {
		var curStr = "";
		if (pointsI > 0) {
			curStr += "+";
		}
		curStr += string(pointsI);
		draw_set_font(font);
		ds_queue_enqueue(queue, [lifetimeFrames, curStr, xI-string_width(curStr)/2, yI-string_height(curStr)/2]);
	},
	addCombo: function(pointsI, comboI, xI, yI) {
		var curStr = string(comboI)+"x combo\n+"+string(pointsI);
		draw_set_font(font);
		ds_queue_enqueue(queue, [comboLifetimeFrames, curStr, xI-string_width(curStr)/2, yI-string_height(curStr)/2]);
	},
	tick: function() {
		var tempQueue = ds_queue_create();
		while (!ds_queue_empty(queue)) {
			var curPopup = ds_queue_dequeue(queue);
			curPopup[0]--;
			if (curPopup[0] != 0) {
				ds_queue_enqueue(tempQueue, curPopup);
			}
		}
		ds_queue_destroy(queue);
		queue = tempQueue;
	},
	draw: function() {
		draw_set_color(color);
		draw_set_font(font);
		
		var tempQueue = ds_queue_create();
		while (!ds_queue_empty(queue)) {
			var curPopup = ds_queue_dequeue(queue);
			var curAlpha = min(1.0, curPopup[0]/disappearFrame);
			var curYAdd = (lifetimeFrames-curPopup[0])/lifetimeFrames*yAdd;
			draw_set_alpha(curAlpha);
			draw_text(curPopup[2], curPopup[3]+curYAdd, curPopup[1]);
			
			ds_queue_enqueue(tempQueue, curPopup);
		}
		ds_queue_destroy(queue);
		queue = tempQueue;
		
		draw_set_alpha(1.0);
	},
	cleanup: function() {
		ds_queue_destroy(queue);
	}
}

pointSetAmount = function(pointsI) {
	pointTargAmount = pointsI;
	pointCurAmount = pointsI;
}

// Combo
combo = {
	_p: other,
	x: 624, y: 40,
	font: ft_HUDCombo,
	draw: function() {
		if (PointsManager.isComboActive) {
			var curCombo = PointsManager.curCombo;
			var curString = string(curCombo)+"x";
			draw_set_font(font);
			draw_text(x, y, curString);
		}
	}
}

// Health packet
hlthPacketAmount = 3;
updateHlthPacket = function(hlthPacketI) {
	hlthPacketAmount = hlthPacketI;
}
hlthPacket = {
	_p: other,
	lifetimeFrames: other.defaultLifetimeFrames,
	lifetimeFramesCur: other.defaultLifetimeFrames,
	disappearFrame: other.defaultDisappearFrame,
	x: 140, y: 10,
	symbolXStart: 170,
	symbolXSpacing: 32,
	symbolAmount: 3,
	baseSpr: spr_healthPacketBase,
	fillSpr: spr_healthPacketFill,
	occupiedSymbolColor: c_red,
	unoccupiedSymbolColor: c_black,
	tick: function() {
		if (lifetimeFramesCur != 0) {
			lifetimeFramesCur--;
		}
	},
	draw: function() {
		var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
		
		for (var i = 0; i < symbolAmount; i++) {
			var curX = symbolXStart+i*symbolXSpacing;
			draw_sprite_ext(baseSpr, 0, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
			
			var curColor = occupiedSymbolColor;
			if (i >= _p.hlthPacketAmount) {
				curColor = unoccupiedSymbolColor;
			}
			draw_sprite_ext(fillSpr, 0, curX, y, 1.0, 1.0, 0, curColor, curMainAlpha);
		}
	},
	flash: function(isQuickI) {
		if (isQuickI) lifetimeFramesCur = disappearFrame;
		else lifetimeFramesCur = lifetimeFrames;
	}
}
with (hlthPacket) {
	symbolXStart = x;
}

// Main inventory
mainInventoryArr = [];
mainInventorySize = 0;
updateMainInventory = function(inventoryI, occupationArrayI, inventorySizeI) {
	mainInventoryArr = inventoryI;
	for (var i = 0; i < inventorySizeI; i++) {
		if (!occupationArrayI[i]) {
			mainInventoryArr[i] = -1;
		}
	}
	mainInventorySize = inventorySizeI;
}
mainInventory = {
	_p: other,
	lifetimeFrames: other.defaultLifetimeFrames,
	lifetimeFramesCur: other.defaultLifetimeFrames,
	disappearFrame: other.defaultDisappearFrame,
	x: 10, y: 560,
	slotSprSet: spr_inventorySlotBorder,
	slotSeparatorSpr: spr_inventorySlotBorderSep,
	slotAmount: 4,
	slotXSpacing: -1,
	slotBackColor: c_black,
	slotBackColorAlpha: 0.25,
	slotWidth: 32,
	slotHeight: 32,
	draw: function() {
		var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
		for (var i = 0; i < slotAmount; i++) {
			var curX = x+slotXSpacing*i;
			
			draw_set_alpha(curMainAlpha*slotBackColorAlpha);
			draw_set_color(slotBackColor);
			
			draw_rectangle(curX, y, curX+slotWidth, y+slotHeight, false);
			
			draw_set_alpha(1.0);
			
			var curTool = _p.mainInventoryArr[i];
			if (curTool != -1)
				draw_sprite_ext(spr_slotSprites, GameplayManager.toolArray[curTool].slotSpriteIndex, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
			
			var isFirstSlot = i == 0;
			var isLastSlot = i == slotAmount-1;
			var curSlotSpriteIndex = 1;
			var drawSeparator = true;
			if (isFirstSlot) {
				curSlotSpriteIndex = 0;
			}else if (isLastSlot) {
				curSlotSpriteIndex = 2;
				drawSeparator = false;
			}
			draw_sprite_ext(slotSprSet, curSlotSpriteIndex, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
			if (drawSeparator)
				draw_sprite_ext(slotSeparatorSpr, 0, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
		}
	},
	flash: function(isQuickI) {
		if (isQuickI) lifetimeFramesCur = disappearFrame;
		else lifetimeFramesCur = lifetimeFrames;
	}
}
with (mainInventory) {
	var itemSprSize = 32;
	slotXSpacing = itemSprSize+sprite_get_width(slotSeparatorSpr);
}

// Enemy HUD
enemyHUD = {
	borderThickness: 2,
	borderColor: c_gray,
	emptyColor: c_black,
	hlthBarIndex: 0,
	hlthColor: c_red,
	energyBarIndex: 1,
	energyColor: c_yellow,
	fuelBarIndex: 2,
	fuelColor: c_orange,
	pipHighlightArrCapacity: 8,
	pipHighlightLifetime: 100,
	pipHighlightColor: c_white
}

enemyHUDMap = ds_map_create();

function assignEnemyHUD(objectI, hlthWidthI, hlthHeightI, hlthPipCapI, hasEnergyI, energyWidthI, energyHeightI, energyPipCapI, hasFuelI, fuelWidthI, fuelHeightI, fuelPipCapI) {
	var newEnemyHUD = {};
	with (newEnemyHUD) {
		barLifetime = 180;
		barDisappearFrame = 50;
	
		hlthWidth = hlthWidthI;
		hlthHeight = hlthHeightI;
		hlthPipCap = hlthPipCapI;
		hlthPipSpacing = HUDManager.enemyHUD.borderThickness+hlthWidth;
		hlthPipAmount = objectI.hlthInterface.hlthMax/hlthPipCap;
		hlthBarWidth = hlthPipAmount*hlthPipSpacing+HUDManager.enemyHUD.borderThickness;
		hlthLifetimeCur = 0;
		isVisible = true;
		
		hlthPipHighlight = {
				color: c_white,
				arrCap: 8,
				array: array_create(8, [0, 0, 0]),
				index: 0,
				lifetime: HUDManager.enemyHUD.pipHighlightLifetime
			}
		function flashHlth() {
			hlthLifetimeCur = barLifetime;
		}
		function highlightHlthPips(oldHlthI, newHlthI) {
			with (hlthPipHighlight) {
				array[index] = [lifetime, oldHlthI, newHlthI];
				index++;
				if (index == arrCap) {
					index = 0;
				}
			}
		}
	
		hasEnergy = hasEnergyI;
		if (hasEnergy) {
			energyWidth = energyWidthI;
			energyHeight = energyHeightI;
			energyPipCap = energyPipCapI;
			energyPipSpacing = HUDManager.enemyHUD.borderThickness+energyWidth;
			energyPipAmount = objectI.energyInterface.energyMax/energyPipCap;
			energyBarWidth = energyPipAmount*energyPipSpacing+HUDManager.enemyHUD.borderThickness;
			energyPipHighlight = {
				color: c_white,
				arrCap: 8,
				array: array_create(8, [0, 0, 0]),
				index: 0,
				lifetime: HUDManager.enemyHUD.pipHighlightLifetime
			}
			energyLifetimeCur = 0;
			function flashEnergy() {
				energyLifetimeCur = barLifetime;
			}
			function highlightEnergyPips(oldEnergyI, newEnergyI) {
				with (energyPipHighlight) {
					array[index] = [lifetime, oldEnergyI, newEnergyI];
					index++;
					if (index == arrCap) {
						index = 0;
					}
				}
			}
		}
		hasFuel = hasFuelI;
		if (hasFuel) {
			fuelWidth = fuelWidthI;
			fuelHeight = fuelHeightI;
			fuelPipCap = fuelPipCapI;
			fuelPipSpacing = HUDManager.enemyHUD.borderThickness+fuelWidth;
			fuelPipAmount = objectI.fuelMax/fuelPipCap;
			fuelBarWidth = fuelPipAmount*fuelPipSpacing+HUDManager.enemyHUD.borderThickness;
			fuelLifetimeCur = 0;
			function flashFuel() {
				fuelLifetimeCur = barLifetime;
			}
		}
	
		barsXOffset = hlthBarWidth;
		if (hasEnergy && energyBarWidth > barsXOffset) {
			barsXOffset = energyBarWidth;
		}if (hasFuel && fuelBarWidth > barsXOffset) {
			barsXOffset = fuelBarWidth;
		}
		barsXOffset /= 2;
		barsXOffset *= -1;
	
		barsYOffset = sprite_get_yoffset(objectI.sprite_index)+8;
	
		if (hasEnergy && hasFuel) {
			barIndexes = [HUDManager.enemyHUD.hlthBarIndex, HUDManager.enemyHUD.energyBarIndex, HUDManager.enemyHUD.fuelBarIndex];
		}else if (hasEnergy) {
			barIndexes = [HUDManager.enemyHUD.hlthBarIndex, HUDManager.enemyHUD.energyBarIndex];
		}else {
			barIndexes = [HUDManager.enemyHUD.hlthBarIndex, HUDManager.enemyHUD.fuelBarIndex];
		}
		barAmount = array_length(barIndexes);
		barsHeight = barAmount*HUDManager.enemyHUD.borderThickness;
		for (var i = 0; i < barAmount; i++) {
			switch (barIndexes[i]) {
				case HUDManager.enemyHUD.hlthBarIndex: barsHeight += hlthHeight; break;
				case HUDManager.enemyHUD.energyBarIndex: barsHeight += energyHeight; break;
				default: barsHeight += fuelHeight; break;
			}
		}
	
		function cleanup() {
			/*if (hasEnergy) {
				ds_queue_destroy(energyPipHighlightQueue);
			}*/
		}
	}
	
	if (ds_exists(enemyHUDMap, objectI.id)) {
		enemyHUDMap[?objectI.id].cleanup();
	}
	ds_map_set(enemyHUDMap, objectI.id, newEnemyHUD);
	/*show_debug_message("Enemy HUD assignemnt");
	show_debug_message(objectI.id);
	show_debug_message("");*/
}