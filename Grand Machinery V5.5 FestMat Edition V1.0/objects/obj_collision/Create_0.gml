
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

collisionType = collisionType_normal;

activate = function() {
	isActive = true;
	BlockCollisionGrid.setRegionByInstance(self, collisionType);
}

deactivate = function() {
	isActive = false;
	BlockCollisionGrid.setRegionByInstance(self, collisionType_nothing);
}

activate();