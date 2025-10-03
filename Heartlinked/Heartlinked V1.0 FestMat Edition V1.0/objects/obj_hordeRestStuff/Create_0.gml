/// @description Insert description here
// You can write your code in this editor

spawnPackets = function() {
	instance_create_layer(x-40, y+40, "Instances", obj_healPacket);
	instance_create_layer(x+40, y+40, "Instances", obj_healPacket);
}