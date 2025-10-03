/// @description Insert description here
// You can write your code in this editor

draw_sprite(baseSprite, 0, x, y);
var chargeProgress = chargeLifetimeFramesCur/chargeLifetimeFrames;
var chargeAlpha = chargeProgress;
draw_sprite_ext(chargeSprite, 0, x, y, 1.0, 1.0, 0, c_white, chargeAlpha);
var genChargeAlpha = (energyCooldown-energyCooldownCur)/energyCooldown;
draw_sprite_ext(genChargeSprite, 0, x, y, 1.0, 1.0, 0, c_white, genChargeAlpha);