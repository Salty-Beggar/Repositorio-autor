/// @description Insert description here
// You can write your code in this editor

exitButton = {
	button: ButtonManager.createButton(
		20, 20, 20+32, 20+32, 0
	),
	spr: spr_exitButton
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

skinSelection = {
	x: 300, y: 20+16, buttonX: 30, buttonWidth: 16, buttonHeight: 32,
	buttonBack: {
		sprite: spr_leftSymbol,
		button: undefined,
		action: function() {
			do {
				GameplayManager.selectedSkinID--;
				if (GameplayManager.selectedSkinID == -1) GameplayManager.selectedSkinID = skinAmount-1;
			}until (UserManager.unlockedSkins[GameplayManager.selectedSkinID])
		}
	},
	buttonNext: {
		sprite: spr_rightSymbol,
		button: undefined,
		action: function() {
			do {
				GameplayManager.selectedSkinID++;
				if (GameplayManager.selectedSkinID == skinAmount) GameplayManager.selectedSkinID = 0;
			}until (UserManager.unlockedSkins[GameplayManager.selectedSkinID])
		}
	},
	tick: function() {
		show_debug_message(buttonBack.button);
		if (ButtonManager.isButtonSelected(buttonBack.button)) {show_debug_message("cock"); buttonBack.action()};
		else if (ButtonManager.isButtonSelected(buttonNext.button)) buttonNext.action();
	},
	draw: function() {
		draw_sprite(spr_skinSimple, GameplayManager.selectedSkinID, x, y);
		global.drawButtonDefault(buttonBack.button, buttonBack.sprite);
		global.drawButtonDefault(buttonNext.button, buttonNext.sprite);
	},
	initialize: function() {
		var buttonHeightHalf = buttonHeight/2;
		buttonBack.button = ButtonManager.createButton(
			x-buttonX-buttonWidth, y-buttonHeightHalf,
			x-buttonX, y+buttonHeightHalf,
			-10
		);
		buttonNext.button = ButtonManager.createButton(
			x+buttonX, y-buttonHeightHalf,
			x+buttonX+buttonWidth, y+buttonHeightHalf,
			-10
		);
	}
}
skinSelection.initialize();

shopItems = {
	itemXStart: undefined, itemXSpacing: undefined,
	itemYStart: 430, itemYSpacing: 100,
	itemPerRow: 5, itemPerColumn: 2,
	itemFont: ft_levelInfo,
	itemUnlockY: 20,
	itemBoughtStr: "Comprado!",
	itemBuy: {
		_p: undefined,
		array: [],
		buttonX1: -28, buttonX2: 28,
		buttonY1: 44, buttonY2: 60,
		buttonSpr: undefined,
		initialize: function() {
			_p = obj_shopMenuManager.shopItems;
			buttonSpr = global.generateRectangleSpriteFromText(
				buttonX1, buttonY1, buttonX2, buttonY2,
				"Comprar", ft_levelInfoChallenge
			);
			var itemAmount = array_length(ShopManager.itemArr);
			var curRow = 0;
			var curCol = 0; // column
			for (var i = 0; i < itemAmount; i++) {
				var curItem = ShopManager.itemArr[i];
				if (curItem.lock.type == LockManager.mechcoinBuy && curItem.lock.isLocking) {
					var curItemX = _p.itemXStart+curRow*_p.itemXSpacing;
					var curItemY = _p.itemYStart+curCol*_p.itemYSpacing;
					var newButton = ButtonManager.createButton(
						curItemX+buttonX1, curItemY+buttonY1,
						curItemX+buttonX2, curItemY+buttonY2,
						-10
					);
					array_push(array, [i, newButton]);
				}
				curRow++;
				if (curRow == _p.itemPerRow) {
					curRow = 0;
					curCol++;
				}
			}
		},
		cleanup: function() {
			sprite_delete(buttonSpr);
		},
		tick: function() {
			var curLength = array_length(array);
			for (var i = 0; i < curLength; i++) {
				var curItem = array[i];
				var curShopItem = ShopManager.itemArr[curItem[0]];
				if (ButtonManager.isButtonSelected(curItem[1])) {
					var hasBought = LockManager.mechcoinBuy.tryUnlockLock(curShopItem.lock);
					if (hasBought) {
						curShopItem.type.buy(curShopItem);
						ButtonManager.destroyButton(curItem[1]);
						array_delete(array, i, 1);
						curLength--;
					}
				}
			}
		},
		draw: function() {
			var curLength = array_length(array);
			for (var i = 0; i < curLength; i++) {
				global.drawButtonDefault(array[i][1], buttonSpr);
			}
		}
	},
	tick: function() {
		itemBuy.tick();
	},
	draw: function() {
		var itemAmount = array_length(ShopManager.itemArr);
		var curRow = 0;
		var curCol = 0; // column
		for (var i = 0; i < itemAmount; i++) {
			var curItem = ShopManager.itemArr[i];
			var curItemX = itemXStart+curRow*itemXSpacing;
			var curItemY = itemYStart+curCol*itemYSpacing;
			curItem.type.menuDraw(curItem, curItemX, curItemY);
			draw_set_font(itemFont);
			draw_set_color(c_white);
			var curItemUnlockStr = (curItem.lock.isLocking) 
				? curItem.lock.type.buildMenuString(curItem.lock)
				: itemBoughtStr;
			draw_text(curItemX-string_width(curItemUnlockStr)/2, curItemY+itemUnlockY, curItemUnlockStr);
			curRow++;
			if (curRow == itemPerRow) {
				curRow = 0;
				curCol++;
			}
		}
		itemBuy.draw();
	},
	initialize: function() {
		var itemXBorder = 100;
		var itemXExtension = gameResolutionWidth-itemXBorder*2;
		itemXStart = itemXBorder;
		itemXSpacing = itemXExtension/(itemPerRow-1);
		itemBuy.initialize();
	}
}
shopItems.initialize();