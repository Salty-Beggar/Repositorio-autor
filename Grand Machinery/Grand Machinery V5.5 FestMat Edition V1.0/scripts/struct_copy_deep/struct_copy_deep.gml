// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function struct_copy_deep(source, dest, isArrayOnlyI = false) {
	var varArr = variable_struct_get_names(source);
	for (var i = 0; i < array_length(varArr); i++) {
		var curVar = struct_get(source, varArr[i]);
		var newVar = curVar;
		if (!isArrayOnlyI) {
			if (is_numeric(curVar) && ds_exists(curVar, ds_type_map)) {
				newVar = ds_map_create();
				ds_map_copy(newVar, curVar);
			}else if (is_numeric(curVar) && ds_exists(curVar, ds_type_queue)) {
				newVar = ds_queue_create();
				ds_queue_copy(newVar, curVar);
			}else if (is_numeric(curVar) && ds_exists(curVar, ds_type_stack)) {
				newVar = ds_stack_create();
				ds_stack_copy(newVar, curVar);
			}else if (is_struct(curVar)) {
				newVar = {};
				struct_copy_deep(curVar, newVar, false);
			}else if (is_array(curVar)) {
				var curLength = array_length(curVar);
				newVar = array_create(curLength);
				array_copy(newVar, 0, curVar, 0, curLength);
			}
		}else {
			if (is_array(curVar)) {
				var curLength = array_length(curVar);
				newVar = array_create(curLength);
				array_copy(newVar, 0, curVar, 0, curLength);
			}else if (!is_callable(curVar) && is_struct(curVar)) {
				newVar = {};
				struct_copy_deep(curVar, newVar, true);
			}
		}
		variable_struct_set(dest, varArr[i], newVar);
	}
}