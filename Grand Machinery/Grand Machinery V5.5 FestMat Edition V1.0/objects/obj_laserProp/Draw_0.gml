/// @description Insert description here
// You can write your code in this editor

draw_sprite_ext(spriteBase, 0, x, y, 1.0, 1.0, image_angle, c_white, 1.0);
var chargeAlpha = chargeLifetimeFramesCur/chargeLifetimeFrames;
if (doesChargeDecrease) {
	draw_sprite_ext(spriteCharge, 0, x, y, 1.0, 1.0, image_angle, c_white, chargeAlpha);
}else {
	draw_sprite_ext(spriteCharge, 0, x, y, 1.0, 1.0, image_angle, c_white, 1.0);
}
if (energyInterface.hasEnergy) {
	var beamProgress = dcos(((shootDelayFramesCur)/shootDelayFrames)*90);
	draw_sprite_ext(spriteBeam, floor(beamProgress*sprite_get_number(spriteBeam)), x, y, 1.0, 1.0, image_angle, c_white, 1.0);
}else {
	draw_sprite_ext(spriteBeam, sprite_get_number(spriteBeam)-1, x, y, 1.0, 1.0, image_angle, c_white, chargeAlpha);
}