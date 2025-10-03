/// @description Insert description here
// You can write your code in this editor

var curTargets = [obj_player.id];
if (hasNonDefaultTargets) {
	curTargets = targetsInitial;
}
var curTargetTypes = targetTypes;
if (areAllTargetsInstances) {
	curTargetTypes = array_create(array_length(curTargets), if_targetting_targetTypes.instance);
}
StageObjectManager.type_shooterDrone.add(x, y, curTargets, curTargetTypes);
