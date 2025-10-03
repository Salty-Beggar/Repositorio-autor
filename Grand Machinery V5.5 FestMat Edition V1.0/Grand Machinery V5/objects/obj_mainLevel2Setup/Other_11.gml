/// @description Insert description here
// You can write your code in this editor

var secondIndex = 2;
var curManager = StageManager.getStage(MainLevelManager.getLevel(secondIndex).stageID).manager;

StageObjectManager.arrayConvertToStageObjectID(arenaNodes);
curManager.blockingEnergyCollision = blockingEnergyCollision.stageObjectID;