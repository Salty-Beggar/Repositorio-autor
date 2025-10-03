/// @description Insert description here
// You can write your code in this editor

markRectangle.tick();
if (lastIsButtonMarked != ButtonManager.isAnyButtonMarked) {
	lastIsButtonMarked = ButtonManager.isAnyButtonMarked;
	if (lastIsButtonMarked == true) {
		markRectangle.appear();
	}
}

if (isVisualMarking) {
	for (var i = 0; i < buttonAmount; i++) {
		var curButton = buttons[i];
		if (ButtonManager.isButtonMarked(curButton)) {
			curVisualMarkedButton = i;
		}
	}
}

if (ButtonManager.isButtonSelected(buttons[0])) {
	TransitionManager.exitMenu();
	TransitionManager.continueMainLevel();
	isSelecting = true;
	markRectangle.select();
}else if (ButtonManager.isButtonSelected(buttons[1])) {
	TransitionManager.exitMenu();
	TransitionManager.goToMenu(MenuManager.getMenu(menu.levels));
	isSelecting = true;
	markRectangle.select();
}else if (ButtonManager.isButtonSelected(buttons[2])) {
	TransitionManager.exitMenu();
	isSelecting = true;
	markRectangle.select();
	TransitionManager.goToMenu(MenuManager.getMenu(menu.shop));
}else if (ButtonManager.isButtonSelected(buttons[3])) {
	markRectangle.select();
	isSelecting = true;
}

if (isSelecting) {
	selectBlinkFramesCur++;
	if (selectBlinkFramesCur == selectBlinkFrames) {
		selectBlinkFramesCur = 0;
		selectBlinkState = (selectBlinkState == 1.0) ? 0.0 : 1.0;
	}
}