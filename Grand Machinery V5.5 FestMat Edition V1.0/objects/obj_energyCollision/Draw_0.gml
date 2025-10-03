/// @description Insert description here
// You can write your code in this editor

var alpha = 1.0;
if (!isActive) {
	alpha = inactiveAlpha;
}
draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, alpha);
draw_set_color(c_white);