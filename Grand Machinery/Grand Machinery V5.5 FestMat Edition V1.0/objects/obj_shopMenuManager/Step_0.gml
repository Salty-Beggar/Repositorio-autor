/// @description Insert description here
// You can write your code in this editor

if (ButtonManager.isButtonSelected(exitButton.button)) {
	TransitionManager.exitMenu();
	TransitionManager.goToMenu(MenuManager.getMenu(menu.main));
}

shopItems.tick();
skinSelection.tick();