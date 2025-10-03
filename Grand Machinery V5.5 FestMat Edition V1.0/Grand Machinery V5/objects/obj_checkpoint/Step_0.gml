/// @description Insert description here
// You can write your code in this editor

if (!isUsed && place_meeting(x, y, obj_player)) {
	PlayerManager.setHlth(PlayerManager.hlthMax);
	isUsed = true;
	GameplayManager.saveGameplayBlueprint();
	image_blend = c_white;
}