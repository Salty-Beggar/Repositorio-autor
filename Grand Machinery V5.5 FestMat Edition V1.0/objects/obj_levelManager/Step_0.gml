/// @description Insert description here
// You can write your code in this editor

if (global.pauseManager.isActive) return;

if (InputManager.isInputActivated(input_ID.restart)) {
	global.restartLevel();
	return;
}

global.cameraManager.stepEvent();

#region Camouflage management

var clustersArr = ds_map_keys_to_array(camouflageClusters);
for (var i = 0; i < array_length(clustersArr); i++) {
	if (ds_map_exists(camouflageClusters, i)) {
		var curCluster = camouflageClusters[? i];
		curCluster.visibility = !global.camouflageCol.visibleClusters[i];
	}
}

#endregion

global.collisionGrid.stepEvent();
PointsManager.stepEvent();
