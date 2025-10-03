/// @description Insert description here
// You can write your code in this editor

// OBSERVATION098 - Organize the code referring to button drawing.
draw_sprite(spr_menuBackground, 0, 0, 0); // OBSERVATION097 - Make a more "patternized" way of showing the background.

for (var i = 0; i < buttonAmount; i++) {
	var curButton = buttons[i];
	var curButtonY = buttonYStart+buttonYSpacing*i;
	var curColor = buttonUnarkedColor;
	if (i == curVisualMarkedButton) {
		curColor = buttonMarkedColor;
		markRectangle.draw(curButtonY);
	}
	
	var curAlpha = (isSelecting && i == curVisualMarkedButton) ? selectBlinkState : 1.0;
	draw_sprite_ext(buttonSprites[i], 0, curButton.x1, curButton.y1, 1.0, 1.0, 0, curColor, curAlpha);
}