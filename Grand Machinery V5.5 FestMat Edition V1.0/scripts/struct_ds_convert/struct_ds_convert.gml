// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function struct_ds_convert(structI) {
	var convertedStruct = {};
	var variables = struct_get_names(structI);
	var variableAmount = array_length(variables);
	for (var i = 0; i < variableAmount; i++) {
		var curVariable = struct_get(structI, variables[i]);
		var convertedVariable = curVariable;
		if (curVariable != undefined && ds_exists(curVariable, ds_type_map)) {
			convertedVariable = ds_map_map_to_array(curVariable);
		}else if (curVariable != undefined && ds_exists(curVariable, ds_type_queue)) {
			convertedVariable = [];
			var curQueue = ds_queue_create();
			ds_queue_copy(curQueue, curVariable);
			while (!ds_queue_empty(curQueue)) {
				array_push(convertedVariable, ds_queue_dequeue(curQueue));
			}
		}else if (curVariable != undefined && ds_exists(curVariable, ds_type_stack)) {
			convertedVariable = [];
			var curStack = ds_stack_create();
			ds_stack_copy(curQueue, curVariable);
			while (!ds_stack_empty(curStack)) {
				array_push(convertedVariable, ds_stack_pop(curStack));
			}
		}else if (is_struct(curVariable)) {
			convertedVariable = struct_ds_convert(curVariable);
		}
		struct_set(convertedStruct, variables[i], convertedVariable);
	}
	return convertedStruct;
}