/// @description Insert description here
// You can write your code in this editor

var destroyInstance = false;
if (ifPhysics.isCollidingLeft || ifPhysics.isCollidingRight || ifPhysics.isCollidingDown || ifPhysics.isCollidingUp) {
	destroyInstance = true;
}
if (place_meeting(x, y, obj_player)) {
	destroyInstance = true;
	PlayerManager.receiveDamage(playerDmg);
}else {
	var collidedObjects = InstanceCollisionGrid.instanceGetCollidedInstances(self, 0, 0);
	for (var i = 0; i < array_length(collidedObjects); i++) {
		var curObj = collidedObjects[i];
		if (instance_exists(curObj)) {
			if (ds_map_exists(EnergyInterface.map, curObj) && (!instance_exists(shooterInst) || curObj != shooterInst.id) && !ds_map_exists(energyObjIgnoreMap, curObj.object_index) && place_meeting(x, y, curObj)) {
				curObj.energyInterface.receiveEnergy(energyInterface.energy);
				destroyInstance = true;
				break;
			}
		}
	}
}

if (destroyInstance) {
	StageObjectManager.destroyObjectByInstance(self);
}

CollisionGridManager.outOfBoundsDestroy(self);