/// @description Insert description here
// You can write your code in this editor

selfDrawer.draw();
slash.draw();
healing.draw();
shot.draw();

if (shot.isBlinkWindow) {
	draw_sprite(spr_blink, 0, x+lastDirection*24, y-5);
}

if (execuitionFramesCur > blinkingExecFrames) draw_set_color(c_orange);
else draw_set_color(c_red);
if (executionPip >= 1) {
	draw_circle(x-8, y-35, 5, false);
}
if (executionPip >= 2) {
	draw_circle(x+8, y-35, 5, false);
}