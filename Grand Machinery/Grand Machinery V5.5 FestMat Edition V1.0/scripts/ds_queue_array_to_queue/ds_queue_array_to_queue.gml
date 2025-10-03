// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function ds_queue_array_to_queue(arrI) {
	var outputQueue = ds_queue_create();
	for (var i = 0; i < array_length(arrI); i++) {
		ds_queue_enqueue(outputQueue, arrI[i]);
	}
	return outputQueue;
}