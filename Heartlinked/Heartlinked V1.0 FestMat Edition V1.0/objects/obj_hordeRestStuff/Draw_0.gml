/// @description Insert description here
// You can write your code in this editor

draw_set_color(c_white);
if (GameplayManager.DEBUG_hordeManager.hordeIsInRest) {
	draw_set_font(ft_default);
	var curString = string(ceil(GameplayManager.DEBUG_hordeManager.hordeRestCooldownCur/60))+" segundos de descanso!";
	draw_text(x-string_width(curString)/2, y-20, curString);
}