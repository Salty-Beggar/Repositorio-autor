// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ds_map_map_to_array(mapI){
	var curKeys = ds_map_keys_to_array(mapI);
	var curValues = ds_map_values_to_array(mapI);
	var curArr = array_create(ds_map_size(mapI));
	for (var i = 0; i < ds_map_size(mapI); i++) {
		curArr[i] = [curKeys[i], curValues[i]];
	}
	return curArr;
}