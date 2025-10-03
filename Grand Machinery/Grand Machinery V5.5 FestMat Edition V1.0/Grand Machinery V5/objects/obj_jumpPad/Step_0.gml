/// @description Insert description here
// You can write your code in this editor

var gridCollidedInstances = InstanceCollisionGrid.instanceGetCollidedInstances(self, 0, 0);
for (var i = 0; i < array_length(gridCollidedInstances); i++) {
	if (if_physics.hasInstance(gridCollidedInstances[i])) {
		if_physics.setVSpeed(gridCollidedInstances[i].ifPhysics, vForce);
	}
}