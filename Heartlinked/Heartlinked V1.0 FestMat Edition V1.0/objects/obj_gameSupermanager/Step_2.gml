/// @description Insert description here
// You can write your code in this editor

if ((MEMBER_TYPE.chaincutter.isDown && MEMBER_TYPE.archer.isDown) || keyboard_check_pressed(ord("R"))) {
	for (var i = 0; i < array_length(instance_id); i++) {
		instance_destroy(instance_id[i]);
	}
	instance_destroy();
	room_goto(rm_setup);
}