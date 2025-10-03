/// @description Insert description here
// You can write your code in this editor

global.levelRoomStartEvent();

#region Camouflage management

ds_map_clear(camouflageClusters);
var constructCluster = function() {
	return {
		objects: array_create(20),
		objAmount: 0,
		visibility: true
	};
}
for (var i = 0; i < instance_number(obj_camouflage); i++) {
	var curCamouflage = instance_find(obj_camouflage, i);
	if (!ds_map_exists(camouflageClusters, curCamouflage.clusterID)) {
		ds_map_add(camouflageClusters, curCamouflage.clusterID, constructCluster());
	}
	var curCluster = camouflageClusters[? curCamouflage.clusterID];
	curCluster.objects[curCluster.objAmount] = curCamouflage.id;
	curCluster.objAmount++;
}

#endregion

global.cameraManager.roomStartEvent();
global.collisionGrid.roomStartEvent();