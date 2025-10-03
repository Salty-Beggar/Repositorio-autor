/// @description Insert description here
// You can write your code in this editor

lifetimeCur--;
if (lifetimeCur == 0) {
	instance_destroy(self);
}