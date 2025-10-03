/// @description Insert description here
// You can write your code in this editor

levelDisplay.tick();
levelSelection.tick();

if (ButtonManager.isButtonSelected(exitButton.button)) {
	TransitionManager.exitMenu();
	TransitionManager.goToMenu(MenuManager.getMenu(menu.main));
}