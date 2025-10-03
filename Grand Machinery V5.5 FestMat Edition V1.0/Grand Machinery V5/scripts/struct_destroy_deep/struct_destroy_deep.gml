// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function struct_destroy_deep(structI){
	var varArr = variable_struct_get_names(structI);
	for (var i = 0; i < array_length(varArr); i++) {
		var curVar = struct_get(structI, varArr[i]);
		if (ds_exists(curVar, ds_type_map)) {
			ds_map_destroy(curVar);
		}else if (ds_exists(curVar, ds_type_queue)) {
			ds_queue_destroy(curVar);
		}else if (ds_exists(curVar, ds_type_stack)) {
			ds_stack_destroy(curVar);
		}else if (is_struct(curVar)) {
			struct_destroy_deep(curVar);
		}
	}
	delete structI;
}