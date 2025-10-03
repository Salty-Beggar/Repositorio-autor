/// @description Insert description here
// You can write your code in this editor

if (global.pauseManager.isActive) return;

// Background
draw_clear(c_black);

#region Camouflage management

var clustersArr = ds_map_keys_to_array(camouflageClusters);
for (var i = 0; i < array_length(clustersArr); i++) {
	var curCluster = camouflageClusters[? clustersArr[i]];
	if (curCluster.visibility == false) {
		for (var j = 0; j < curCluster.objAmount; j++) {
			var curCamouflage = curCluster.objects[j];
			with (curCamouflage) {
				image_blend = other.invisibleCamouflageBlend;
				draw_self();
			}
		}
	}
}

#endregion