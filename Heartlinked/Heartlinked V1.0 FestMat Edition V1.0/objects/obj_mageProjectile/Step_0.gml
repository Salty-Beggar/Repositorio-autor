/// @description Insert description here
// You can write your code in this editor


event_inherited();

curScale += scaleAddSpd;
image_xscale = curScale;

trailFramesCur++;
if (trailFramesCur == trailFrames) {
	trailFramesCur = 0;
	instance_create_layer(x, y, "Instances", obj_archerArrowTrail, {
		dir: image_angle,
		image_xscale: image_xscale,
		baseAlpha: 1.2,
		sprite_index: sprite_index
	});
}