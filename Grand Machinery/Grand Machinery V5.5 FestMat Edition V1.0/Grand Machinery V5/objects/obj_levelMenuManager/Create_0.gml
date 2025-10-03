/// @description Insert description here
// You can write your code in this editor

exitButton = {
	button: ButtonManager.createButton(
		20, 20, 20+32, 20+32, 0
	),
	spr: spr_exitButton
}

rankingDisplay = {
	rankingArr: [rankings.P, rankings.S, rankings.A],
	xStart: 720, xSpacing: -70,
	y: 540,
	font: ft_levelInfoRank,
	draw: function() {
		var visualIndex = 0;
		var curRankingAmount = 3;
		draw_set_font(font);
		for (var i = 0; i < curRankingAmount; i++) {
			var curRanking = rankingArr[i];
			if (UserManager.userRankingAmount[curRanking] != 0) {
				var curStr = RankingManager.strings[curRanking]+" "+string(UserManager.userRankingAmount[curRanking]);
				draw_set_color(RankingManager.colors[curRanking]);
				draw_text(xStart+visualIndex*xSpacing, y, curStr);
				visualIndex++;
			}
		}
	}
}

mechcoinAmount = {
	x: 770, y: 20, font: ft_levelInfoTitle, color: c_white,
	draw: function() {
		draw_set_font(font);
		draw_set_color(color);
		var curStr = string(UserManager.mechcoinAmount)+" mecamoedas";
		draw_text(x-string_width(curStr), y, curStr);
	}
}

levelDisplay = {
	_p: other,
	array: array_create(mainLevelAmount),
	index: 0,
	displayPerRow: 4,
	xFromBorder: 40,
	xGapSpacing: 40,
	xStart: -1,
	xSpacing: -1,
	width: -1,
	yStart: 100,
	ySpacing: 30,
	height: 150,
	font: ft_bigNumber,
	lockedSymbolSpr: -1,
	infoFont: ft_levelInfo,
	pointX: 7, pointY: 5,
	timeX: 7, timeY: 22,
	challengeX: 7, challengeY: 120,
	rankingX: 34, rankingY: 5, infoRankFont: ft_levelInfoRank,
	add: function(positionIndexI, mainLevelID, spriteI) {
		var curMainLevelStruct = MainLevelManager.getLevel(mainLevelID);
		//var curLevelStruct = LevelManager.getLevel(curMainLevelStruct.levelID);
		
		var xIndex = positionIndexI % displayPerRow;
		var yIndex = floor(positionIndexI/displayPerRow);
		var curX = xStart+xIndex*xSpacing;
		var curY = yStart+yIndex*ySpacing;
		
		array[index] = {
			button: ButtonManager.createButton(
				curX, curY, curX+width, curY+height, 0
			),
			x: curX,
			y: curY,
			mainLevelStruct: curMainLevelStruct,
			symbolSpr: spriteI
		}
		index++;
	},
	generateLevelDisplaySprite: function(textI) {
		var curSpr = -1;
		var tempSurface = surface_create(width, height);
		
		surface_set_target(tempSurface);
		
		var curText = textI;
		draw_set_font(font);
		draw_text((width-string_width(curText))/2, (height-string_height(curText))/2, curText);
		
		surface_reset_target();
		
		curSpr = sprite_create_from_surface(tempSurface, 0, 0, width, height, true, false, 0, 0);
		surface_free(tempSurface);
		
		return curSpr;
	},
	activateButtons: function(stateI) {
		var displayAmount = array_length(array);
		for (var i = 0; i < displayAmount; i++) {
			var curDisplay = array[i];
			if (stateI == true) {
				ButtonManager.activateButton(curDisplay.button);
			}else {
				ButtonManager.deactivateButton(curDisplay.button);
			}
		}
	},
	tick: function() {
		var displayAmount = array_length(array);
		for (var i = 0; i < displayAmount; i++) {
			tickDisplay(i);
		}
	},
	tickDisplay: function(indexI) {
		var curStruct = array[indexI];
		if (ButtonManager.isButtonSelected(curStruct.button)) {
			_p.levelSelection.select(curStruct.mainLevelStruct.id);
		}
	},
	cleanup: function() {
		var displayAmount = array_length(array);
		for (var i = 0; i < displayAmount; i++) {
			cleanupDisplay(i);
		}
		sprite_delete(lockedSymbolSpr);
	},
	cleanupDisplay: function(indexI) {
		var curStruct = array[indexI];
		sprite_delete(curStruct.symbolSpr);
	},
	draw: function() {
		var displayAmount = array_length(array);
		for (var i = 0; i < displayAmount; i++) {
			drawDisplay(i);
		}
	},
	drawDisplay: function(indexI) {
		var curStruct = array[indexI];
		
		var curMainLevel = curStruct.mainLevelStruct;
		var curStage = StageManager.getStage(curMainLevel.stageID);
		
		var curMainLevelUserInfo = UserManager.getMainLevelInfoFromStruct(curMainLevel);
		var curStageUserInfo = UserManager.getStageInfoFromStruct(curStage);
		
		var curRankingIsVisible = !curStage.isRankless;
		var curUserPointInfo = curStageUserInfo.pointInformation;
		
		var curMainColor = c_white;
		if (curRankingIsVisible) {
			if (curUserPointInfo.ranking == rankings.A)
				curMainColor = RankingManager.colors[rankings.A];
			else if (curUserPointInfo.ranking == rankings.S)
				curMainColor = RankingManager.colors[rankings.S];
			else if (curUserPointInfo.ranking == rankings.P)
				curMainColor = RankingManager.colors[rankings.P];
		}
		
		var outlineThickness = 3;
		draw_set_color(curMainColor);
		draw_rectangle(curStruct.x, curStruct.y, curStruct.x+width-1, curStruct.y+height-1, false);
		draw_set_color(c_black);
		draw_rectangle(
			curStruct.x+outlineThickness, curStruct.y+outlineThickness,
			curStruct.x-outlineThickness+width-1, curStruct.y-outlineThickness+height-1,
			false
		);
		
		var curSymbol = lockedSymbolSpr;
		if (curMainLevelUserInfo.isUnlocked) {
			curSymbol = curStruct.symbolSpr;
		}
		draw_sprite_ext(curSymbol, 0, curStruct.x, curStruct.y, 1.0, 1.0, 0, curMainColor, 1.0);
		
		if (curStageUserInfo.hasBeenFinished) {
			draw_set_color(curMainColor);
			draw_set_font(infoFont);
			draw_text(curStruct.x+pointX, curStruct.y+pointY, string(curUserPointInfo.points)+"P");
			draw_text(curStruct.x+timeX, curStruct.y+timeY, timeframes_to_string(curUserPointInfo.time));
			draw_text(curStruct.x+challengeX, curStruct.y+challengeY, string(curMainLevelUserInfo.completedChallengeAmount)+"/"+string(curMainLevel.challengeAmount));
			if (curRankingIsVisible) {
				draw_set_font(infoRankFont);
				draw_text(curStruct.x+width-rankingX, curStruct.y+rankingY, RankingManager.strings[curUserPointInfo.ranking]);
			}
		}
	},
	initialize: function() {
		width = (gameResolutionWidth-xFromBorder*2-xGapSpacing*(displayPerRow-1))/displayPerRow;
		xSpacing = width+xGapSpacing;
		xStart = xFromBorder;
		var curLevelIndex = 1;
		for (var i = 0; i < mainLevelAmount; i++) {
			var curLevelSpr;
			if (i == mainLevel_ID.tutorial) {
				curLevelSpr = generateLevelDisplaySprite("T");
			}else {
				curLevelSpr = generateLevelDisplaySprite(string(curLevelIndex));
				curLevelIndex++;
			}
			add(i, i, curLevelSpr);
		}
		
		var tempSurface = surface_create(width, height);
		
		surface_set_target(tempSurface);
		
		draw_sprite(spr_levelLocked, 0, width/2, height/2);
		
		surface_reset_target();
		
		lockedSymbolSpr = sprite_create_from_surface(tempSurface, 0, 0, width, height, true, false, 0, 0);
		surface_free(tempSurface);
	}
}

levelSelection = {
	_p: other,
	isActive: false,
	selectedLevelID: 0,
	blackBackgroundAlpha: 0.5,
	x1: 0, y1: 0, x2: 0, y2: 0,
	width: 0, height: 0,
	outlineThickness: 3,
	outlineColor: c_white,
	fillColor: c_black,
	levelTitleX: 10,
	levelTitleY: 10,
	levelTitleFont: ft_levelInfoTitle,
	levelTitleColor: c_white,
	levelTitleSeparatorX1: 0,
	levelTitleSeparatorX2: 0,
	levelTitleSeparatorY1: 50,
	levelTitleSeparatorY2: 0,
	
	// Tabs
	currentTab: undefined,
	selectTab: function(tabI) {
		if (currentTab != undefined) currentTab.quit();
		currentTab = tabI;
		currentTab.enter();
	},
	lockedLevelTab: {
		_lS: undefined,
		requirementsX: 10,
		requirementsYStart: 60,
		requirementsYSpacing: 50,
		requirementsFont: ft_levelInfoSelected,
		requirementsColor: c_white,
		enter: function() {
			
		},
		quit: function() {
			
		},
		tick: function() {
			
		},
		draw: function() {
			var curMainLevelInfo = UserManager.getMainLevelInfo(_lS.selectedLevelID);
			var curStageInfo = UserManager.getStageInfo(MainLevelManager.getLevel(_lS.selectedLevelID).stageID);
			draw_set_font(requirementsFont);
			var curMainLevel = MainLevelManager.getLevel(_lS.selectedLevelID);
			var length = array_length(curMainLevel.lockArray);
			var posIndex = 0;
			for (var i = 0; i < length; i++) {
				if (curMainLevelInfo.lockStatusArray[i] == false) {
					var curLock = curMainLevel.lockArray[i];
					draw_text(_lS.x1+requirementsX, _lS.y1+requirementsYStart+requirementsYSpacing*posIndex, curLock.type.buildDescriptionString(curLock));
					posIndex++;
				}
			}
		}
	},
	levelInfoTab: {
		_lS: undefined,
		infoX: 20,
		infoPointsY: 80,
		infoPointsStr: lng_levelMenu_points,
		infoTimeY: 120,
		infoTimeStr: lng_levelMenu_time,
		infoChallengeY: 160,
		infoChallengeStr: lng_levelMenu_challenges,
		infoFont: ft_levelInfoSelected,
		infoRankX: 330,
		infoRankY: 70,
		infoRankFont: ft_levelInfoSelectedRank,
		challengeButton: {
			_p: obj_levelMenuManager,
			_lS: undefined,
			_tab: undefined,
			x: undefined, y1: undefined, width: 24, y2: undefined,
			button: undefined, buttonSpr: spr_threeDots, sprWidth: 24,
			draw: function() {
				if (UserManager.getMainLevelInfo(_lS.selectedLevelID).isUnlocked) {
					global.drawButtonDefault(
						button, buttonSpr
					);
				}
			},
			create: function(challengeStrI) {
				var spacingFromText = 34;
				draw_set_font(_tab.infoFont);
				x = _lS.x1+string_width(challengeStrI)+spacingFromText;
				button = ButtonManager.createButton(x, y1, x+width, y2);
			},
			destroy: function() {
				ButtonManager.destroyButton(button);
			},
			initialize: function() {
				_lS = obj_levelMenuManager.levelSelection;
				_tab = obj_levelMenuManager.levelSelection.levelInfoTab;
				var yAdd = 4;
				y1 = _lS.y1+_tab.infoChallengeY+yAdd;
				y2 = y1+sprWidth;
			}
		},
		enter: function() {
			ButtonManager.activateButton(_lS.playButton.button);
			var curMainLevelInfo = UserManager.getMainLevelInfo(_lS.selectedLevelID);
			var curMainLevel = MainLevelManager.getLevel(_lS.selectedLevelID);
			var curStageInfo = UserManager.getStageInfo(curMainLevel.stageID);
			if (curStageInfo.hasBeenFinished) {
				infoPointsStr = lng_levelMenu_points+" "+string(curStageInfo.pointInformation.points);
				infoTimeStr = lng_levelMenu_time+" "+timeframes_to_string_complete(curStageInfo.pointInformation.time);
				infoChallengeStr = lng_levelMenu_challenges+" "+string(curMainLevelInfo.completedChallengeAmount)+"/"+string(curMainLevel.challengeAmount);
				challengeButton.create(infoChallengeStr);
			}
		},
		quit: function() {
			ButtonManager.deactivateButton(_lS.playButton.button);
			var curMainLevel = MainLevelManager.getLevel(_lS.selectedLevelID);
			var curStageInfo = UserManager.getStageInfo(curMainLevel.stageID);
			if (curStageInfo.hasBeenFinished) {
				challengeButton.destroy();
			}
		},
		tick: function() {
			if (ButtonManager.isButtonSelected(challengeButton.button)) {
				_lS.selectTab(_lS.challengeTab);
			}
		},
		draw: function() {
			var curMainLevelInfo = UserManager.getMainLevelInfo(_lS.selectedLevelID);
			var curStageInfo = UserManager.getStageInfo(MainLevelManager.getLevel(_lS.selectedLevelID).stageID);
			if (curStageInfo.hasBeenFinished) {
				draw_set_font(infoFont);
				draw_text(_lS.x1+infoX, _lS.y1+infoPointsY, infoPointsStr);
				draw_text(_lS.x1+infoX, _lS.y1+infoTimeY, infoTimeStr);
				draw_text(_lS.x1+infoX, _lS.y1+infoChallengeY, infoChallengeStr);
				draw_set_font(infoRankFont);
				draw_text(_lS.x1+infoRankX, _lS.y1+infoRankY, RankingManager.strings[curStageInfo.pointInformation.ranking]);
				challengeButton.draw();
			}
		},
		initialize: function() {
			challengeButton.initialize();
		}
	},
	challengeTab: {
		_lS: undefined,
		titleX: undefined, titleY: 60,
		titleFont: ft_levelInfoSelected,
		titleStr: "Desafios",
		challengeScrollArea: {
			scrollArea: undefined,
			x1: undefined, y1: undefined,
			x2: undefined, y2: undefined,
			width: undefined,
			create: function(curHeightI) {
				scrollArea = ScrollAreaManager.createScrollArea(
					x1, y1, x2, y2,
					width, curHeightI,
					0,
					surface_rgba4unorm
				);
			},
			destroy: function() {
				ScrollAreaManager.destroyScrollArea(scrollArea);
			}
		},
		challengeCompletedColor: RankingManager.colors[rankings.A],
		challengeIncompletedColor: c_grey,
		challengeX1: undefined, challengeX2: undefined,
		challengeYStart: 100, challengeYSpacing: 82,
		challengeWidth: undefined, challengeHeight: 76,
		challengeOutlineThickness: 2,
		challengeSprWidth: 64, challengeSprX: undefined, challengeSprY: undefined,
		challengeTitleFont: ft_levelInfoChallengeTitle, challengeTitleX: 96, challengeTitleY: 5,
		challengeTextFont: ft_levelInfoChallenge, challengeTextX: 96, challengeTextY: 24,
		challengeTextYSpacing: 10, challengeTextWidth: undefined,
		challengeRightBorderWidth: 20,
		challengeMechcoinX: undefined, challengeMechcoinY: 0, challengeMechcoinFont: ft_levelInfoChallengeTitle,
		challengeMechcoinYSpacing: 12,
		challengeHiddenName: "Desafio escondido",
		challengeHiddenDescription: "???",
		challengeHiddenSpr: spr_challengeSprHidden,
		backButton: {
			_p: obj_levelMenuManager,
			_lS: undefined,
			_tab: undefined,
			x1: 130, y1: 65, x2: 130+24, y2: 65+24,
			button: undefined, buttonSpr: spr_backSymbol, sprWidth: 24,
			draw: function() {
				global.drawButtonDefault(
					button, buttonSpr
				);
			},
			create: function() {
				button = ButtonManager.createButton(_lS.x1+x1, _lS.y1+y1, _lS.x1+x2, _lS.y1+y2);
			},
			destroy: function() {
				ButtonManager.destroyButton(button);
			},
			initialize: function() {
				_lS = obj_levelMenuManager.levelSelection;
				_tab = obj_levelMenuManager.levelSelection.challengeTab;
			}
		},
		enter: function() {
			ButtonManager.activateButton(_lS.playButton.button);
			backButton.create();
			var curLevel = MainLevelManager.getLevel(_lS.selectedLevelID);
			challengeScrollArea.create((curLevel.challengeAmount-1)*challengeYSpacing+challengeHeight);
		},
		quit: function() {
			ButtonManager.deactivateButton(_lS.playButton.button);
			backButton.destroy();
			challengeScrollArea.destroy();
		},
		tick: function() {
			if (ButtonManager.isButtonSelected(backButton.button)) {
				_lS.selectTab(_lS.levelInfoTab);
			}
		},
		draw: function() {
			draw_set_font(titleFont);
			draw_text(_lS.x1+titleX, _lS.y1+titleY, titleStr);
			var curLevel = MainLevelManager.getLevel(_lS.selectedLevelID);
			var challengeAmount = curLevel.challengeAmount;
			var challengeArr = curLevel.challengeArr;
			ScrollAreaManager.setScrollAreaSurfaceTarget(challengeScrollArea.scrollArea);
			draw_clear(c_black);
			for (var i = 0; i < challengeAmount; i++) {
				var curChallenge = LevelChallengeManager.challengeArr[challengeArr[i]];
				var curColor = challengeIncompletedColor;
				var isCurChallengeComplete = UserManager.userLevelChallengeInfo.completedChallengeArr[challengeArr[i]];
				if (isCurChallengeComplete)
					curColor = challengeCompletedColor;
				
				var curChallengeY = challengeYSpacing*i;
				draw_set_color(curColor);
				draw_rectangle(0, curChallengeY, challengeWidth-1, curChallengeY+challengeHeight-1, false);
				draw_set_color(c_black);
				draw_rectangle(challengeOutlineThickness, curChallengeY+challengeOutlineThickness, challengeWidth-1-challengeRightBorderWidth, curChallengeY+challengeHeight-1-challengeOutlineThickness, false);
				
				show_debug_message(curChallenge);
				var curChallengeSpr = (!isCurChallengeComplete && curChallenge.isHidden) ? challengeHiddenSpr : curChallenge.sprite;
				draw_sprite_ext(curChallengeSpr, 0, challengeSprX, curChallengeY+challengeSprY, 1.0, 1.0, 0, curColor, 1.0);
				
				draw_set_color(curColor);
				draw_set_font(challengeTitleFont);
				var curChallengeName = (!isCurChallengeComplete && curChallenge.isHidden) ? challengeHiddenName : curChallenge.name;
				draw_text(challengeTitleX, curChallengeY+challengeTitleY, curChallengeName);
				
				draw_set_font(challengeTextFont);
				var curChallengeDesc = (!isCurChallengeComplete && curChallenge.isHidden) ? challengeHiddenDescription : curChallenge.description;
				draw_text_ext(challengeTextX, curChallengeY+challengeTextY, curChallengeDesc, challengeTextYSpacing, challengeTextWidth);
				
				draw_set_font(challengeMechcoinFont);
				draw_set_color(c_black);
				var curMechcoinStr = string(curChallenge.mechcoinReward)+"M";
				var curMechcoinStrLength = string_length(curMechcoinStr);
				for (var j = 0; j < curMechcoinStrLength; j++) {
					var curChar = string_char_at(curMechcoinStr, j+1);
					var curCharY = challengeMechcoinY+j*challengeMechcoinYSpacing;
					draw_text(challengeMechcoinX-string_width(curChar)/2, curChallengeY+curCharY, curChar);
				}
			}
			surface_reset_target();
			ScrollAreaManager.drawScrollArea(challengeScrollArea.scrollArea);
			backButton.draw();
		},
		initialize: function() {
			draw_set_font(titleFont);
			titleX = (_lS.x2-_lS.x1-string_width(titleStr))/2;
			var challengeXBorder = 20;
			challengeX1 = challengeXBorder;
			challengeX2 = _lS.x2-_lS.x1-challengeXBorder;
			challengeWidth = challengeX2-challengeX1;
			challengeScrollArea.x1 = _lS.x1+challengeX1;
			challengeScrollArea.x2 = _lS.x1+challengeX2;
			challengeScrollArea.y1 = _lS.y1+challengeYStart;
			challengeScrollArea.y2 = _lS.y1+challengeYStart+186;
			challengeScrollArea.width = challengeWidth;
			
			challengeSprX = challengeX1+challengeHeight/2;
			challengeSprY = challengeHeight/2;
			
			var challengeTextBorder = 30;
			challengeTextWidth = challengeWidth-challengeTextBorder-challengeTextX;
			
			var challengeMechcoinXborder = 10;
			challengeMechcoinX = challengeWidth-challengeMechcoinXborder;
			
			backButton.initialize();
		}
	},
	
	// Present in more than one tab
	playButton: {
		_p: other,
		_lS: 0,
		x1: 0, y1: 300, x2: 0, y2: 350,
		button: 0, buttonSpr: 0,
		strText: lng_levelMenu_playButton,
		font: ft_levelInfoSelected,
		draw: function() {
			if (UserManager.getMainLevelInfo(_lS.selectedLevelID).isUnlocked) {
				global.drawButtonDefault(
					button, buttonSpr
				);
			}
		},
		cleanup: function() {
			sprite_delete(buttonSpr);
		}
	},
	
	select: function(levelIDI) {
		selectedLevelID = levelIDI;
		isActive = true;
		
		ButtonManager.deactivateButton(_p.exitButton.button);
		_p.levelDisplay.activateButtons(false);
		
		var curLevelInfo = UserManager.getMainLevelInfo(selectedLevelID);
		if (curLevelInfo.isUnlocked) {
			selectTab(levelInfoTab);
		}else {
			selectTab(lockedLevelTab);
		}
	},
	close: function() {
		isActive = false;
		ButtonManager.activateButton(_p.exitButton.button);
		_p.levelDisplay.activateButtons(true);
		if (currentTab != undefined) currentTab.quit();
		currentTab = undefined;
	},
	tick: function() {
		if (isActive) {
			currentTab.tick()
			
			if (UserManager.getMainLevelInfo(selectedLevelID).isUnlocked) {
				if (ButtonManager.isButtonSelected(playButton.button)) {
					TransitionManager.exitMenu();
					TransitionManager.goToMainLevel(MainLevelManager.getLevel(selectedLevelID));
				}
			}
			
			if (InputManager.isInputActivated(input_ID.escape)) {
				close();
			}
		}
	},
	cleanup: function() {
		playButton.cleanup();
	},
	draw: function() {
		if (isActive) {
			draw_set_color(c_black);
			draw_set_alpha(blackBackgroundAlpha);
			draw_rectangle(0, 0, gameResolutionWidth, gameResolutionHeight, false);
			draw_set_alpha(1.0);
			
			draw_set_color(outlineColor);
			draw_rectangle(x1, y1, x2-1, y2-1, false);
			draw_set_color(fillColor);
			draw_rectangle(x1+outlineThickness, y1+outlineThickness, x2-outlineThickness-1, y2-outlineThickness-1, false);
			
			draw_set_font(levelTitleFont);
			draw_set_color(levelTitleColor);
			draw_text(x1+levelTitleX, y1+levelTitleY, MainLevelManager.getLevel(selectedLevelID).name);
			var separatorColor = levelTitleColor;
			draw_rectangle(
				x1+levelTitleSeparatorX1, y1+levelTitleSeparatorY1,
				x1+levelTitleSeparatorX2-1, y1+levelTitleSeparatorY2-1,
				false
			);
			
			currentTab.draw();
			
			var curMainLevelInfo = UserManager.getMainLevelInfo(selectedLevelID);
			if (curMainLevelInfo.isUnlocked) {
				playButton.draw();
			}
		}
	},
	initialize: function() {
		var xBorder = 200;
		x1 = xBorder;
		x2 = gameResolutionWidth-xBorder;
		var yBorder = 100;
		y1 = yBorder;
		y2 = gameResolutionHeight-yBorder;
	
		width = x2-x1;
		height = y2-y1;
	
		var separatorXBorder = 18;
		levelTitleSeparatorX1 = separatorXBorder;
		levelTitleSeparatorX2 = width-separatorXBorder;
		var separatorThickness = 2;
		levelTitleSeparatorY2 = levelTitleSeparatorY1+separatorThickness;
	
		with (playButton) {
			_lS = other;
			var xBorder = 50;
			x1 = xBorder;
			x2 = _lS.width-xBorder;
			button = ButtonManager.createButton(
				_lS.x1+x1, _lS.y1+y1, _lS.x1+x2, _lS.y1+y2, -10
			);
			ButtonManager.deactivateButton(button);
			buttonSpr = global.generateButtonSpriteFromText(button, strText, font);
		}
		
		lockedLevelTab._lS = obj_levelMenuManager.levelSelection;
		levelInfoTab._lS = obj_levelMenuManager.levelSelection;
		challengeTab._lS = obj_levelMenuManager.levelSelection;
		levelInfoTab.initialize();
		challengeTab.initialize();
	}
}
levelSelection.initialize();

with (levelSelection) {
}

levelDisplay.initialize();