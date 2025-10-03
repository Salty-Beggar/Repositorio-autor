/// @description Insert description here
// You can write your code in this editor

var curStageObject = StageObjectManager.getObject(stageObjectID);
curArr = curStageObject.shortcuttedShotsInstances;
curArr2 = curStageObject.shortcuttedShotsIsIt;
for (var i = 0; i < array_length(curArr); i++) {
	if (curArr2[i]) curArr[i] = curArr[i].stageObjectID;
}