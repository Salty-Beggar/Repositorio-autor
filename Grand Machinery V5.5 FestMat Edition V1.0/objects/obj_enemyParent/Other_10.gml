/// @description Insert description here
// You can write your code in this editor

var hlth = 5;
var energy = 5;

var curStruct = global.levelObjectInterface.constructBase(
	self, x, y, image_xscale, image_yscale, image_angle, true
);

with (curStruct) {
	targets = other.targets;
	global.levelObjectInterface.convertInstanceIDArrayToLevelObjectIDArray(targets);
	saveExtra = function(instI) {
		targets = instI.targets;
	}
	loadExtra = function(structI) {
		structI.targets = targets;
		global.levelObjectInterface.convertLevelObjectIDArrayToInstanceIDArray(structI.targets);
	}
}

global.levelObjectInterface.addHlthToStruct(curStruct, hlth);
global.levelObjectInterface.addEnergyToStruct(curStruct, energy);
global.levelObjectInterface.addObject(self, curStruct);