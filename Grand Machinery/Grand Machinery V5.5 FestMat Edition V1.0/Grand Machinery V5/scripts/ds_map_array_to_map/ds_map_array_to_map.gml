// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ds_map_array_to_map(array) {
	var newMap = ds_map_create();
	var length = array_length(array);
	for (var i = 0; i < length; i++) {
		ds_map_add(newMap, array[i][0], array[i][1]);
	}
	return newMap;
}