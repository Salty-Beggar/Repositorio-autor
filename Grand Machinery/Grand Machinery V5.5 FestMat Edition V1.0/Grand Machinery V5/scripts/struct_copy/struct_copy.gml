// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function struct_copy(source, dest) {
	var varArr = variable_struct_get_names(source);
	for (var i = 0; i < array_length(varArr); i++) {	
		variable_struct_set(dest, varArr[i], variable_struct_get(source, varArr[i]));
	}
}