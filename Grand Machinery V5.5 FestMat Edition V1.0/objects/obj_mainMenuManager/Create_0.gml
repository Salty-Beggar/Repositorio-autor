/// @description Insert description here
// You can write your code in this editor

buttonAmount = 5;
buttonStrings = [lng_continue, lng_levels, lng_shop, lng_leaderboard, lng_exit];
buttonSprites = array_create(buttonAmount);
buttonFont = ft_calibriBold12;
isButtonMarked = true;
lastIsButtonMarked = false;
markedButton = 0;
curVisualMarkedButton = 0;
isVisualMarking = true;
buttons = array_create(buttonAmount);

buttonXFromBorder = 320;
buttonWidth = gameResolutionWidth-buttonXFromBorder*2;
buttonYStart = 250;
buttonYSpacing = 60;
buttonHeight = 36;
buttonUnarkedColor = c_grey;
buttonMarkedColor = c_white;

isSelecting = false;
selectBlinkState = 1.0;
selectBlinkFrames = 2;
selectBlinkFramesCur = 0;

markRectangle = {
	_p: other,
	xAdd: 40, y1Add: 4, y2Add: 10,
	isAppearing: false,
	inFrames: 8, inFramesCur: 0,
	inXAdd: 10, inYAdd: 10,
	isSelecting: false,
	curSelectXAdd: 0, selectXAddAdd: 17, selectXAddAcc: 1,
	selectColor: c_white,
	appear: function() {
		inFramesCur = inFrames;
		isAppearing = true;
	},
	select: function() {
		isSelecting = true;
		_p.isVisualMarking = false;
	},
	tick: function() {
		if (isAppearing) {
			inFramesCur--;
			if (inFramesCur == 0) isAppearing = false;
		}
		if (isSelecting) {
			curSelectXAdd += selectXAddAdd;
			selectXAddAdd -= selectXAddAcc;
			if (selectXAddAdd <= 0) selectXAddAdd = 0;
		}
	},
	draw: function(yI) {
		draw_set_color(c_white);
		var curInXAdd = (1.0-dsin((inFrames-inFramesCur)/inFrames*90))*inXAdd;
		var curInYAdd = (1.0-dsin((inFrames-inFramesCur)/inFrames*90))*inYAdd;
		var isOutline = !isSelecting;
		
		if (isOutline) {
			draw_set_alpha((inFrames-inFramesCur)/inFrames);
			draw_rectangle(
				_p.buttonXFromBorder-xAdd-curInXAdd,
				yI-y1Add-curInYAdd,
				gameResolutionWidth-_p.buttonXFromBorder+xAdd+curInXAdd,
				yI+_p.buttonHeight+y2Add+curInYAdd,
				true
			);
			draw_rectangle(
				_p.buttonXFromBorder-xAdd+1-curInXAdd,
				yI-y1Add+1-curInYAdd,
				gameResolutionWidth-_p.buttonXFromBorder+xAdd-1+curInXAdd,
				yI+_p.buttonHeight+y2Add-1+curInYAdd,
				true
			);
			draw_set_alpha(1.0);
		}else {
			draw_set_alpha((inFrames-inFramesCur)/inFrames);
			draw_rectangle(
				_p.buttonXFromBorder-xAdd-curInXAdd-curSelectXAdd,
				yI-y1Add-curInYAdd,
				gameResolutionWidth-_p.buttonXFromBorder+xAdd+curInXAdd+curSelectXAdd,
				yI+_p.buttonHeight+y2Add+curInYAdd,
				false
			);
			draw_set_alpha(1.0);
		}
	}
}

draw_set_font(buttonFont);
for (var i = 0; i < buttonAmount; i++) {
	var surfWidth = string_width(buttonStrings[i])*2+2;
	var surfHeight = string_height(buttonStrings[i])*2+2;
	var textSurface = surface_create(string_width(buttonStrings[i])+1, string_height(buttonStrings[i])+1);
	var finalSurface = surface_create(surfWidth, surfHeight);
	var backColor = c_grey;
	
	surface_set_target(textSurface);
	draw_set_color(backColor);
	draw_text(1, 1, buttonStrings[i]);
	draw_set_color(c_white);
	draw_text(0, 0, buttonStrings[i]);
	surface_reset_target();
	
	surface_set_target(finalSurface);
	draw_surface_ext(textSurface, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
	surface_reset_target();
	
	buttonSprites[i] = sprite_create_from_surface(finalSurface, 0, 0, surfWidth, surfHeight, true, false, 0, 0);
	surface_free(textSurface);
	surface_free(finalSurface);
	
	var curButtonY = buttonYStart+buttonYSpacing*i;
	buttons[i] = ButtonManager.createButton(
		buttonXFromBorder, curButtonY,
		buttonXFromBorder+surfWidth, curButtonY+surfHeight,
		0
	);
}