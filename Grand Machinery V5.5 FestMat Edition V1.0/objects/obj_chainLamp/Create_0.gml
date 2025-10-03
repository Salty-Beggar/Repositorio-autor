/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

enum obj_chainLamp_segmentID {light, chain}
enum obj_chainLamp_sprIndexes {lampAlone, chainStart, chainMiddle, lampMiddle, lampEnd}

segmentAmount = array_length(segmentArr);
sprIndexArr = array_create(segmentAmount);

for (var i = 0; i < segmentAmount; i++) {
	if (segmentArr[i] == obj_chainLamp_segmentID.light) {
		if (i == 0) sprIndexArr[i] = obj_chainLamp_sprIndexes.lampAlone;
		else if (i != segmentAmount-1) sprIndexArr[i] = obj_chainLamp_sprIndexes.lampMiddle;
		else sprIndexArr[i] = obj_chainLamp_sprIndexes.lampEnd;
	}else {
		if (i == 0) sprIndexArr[i] = obj_chainLamp_sprIndexes.chainStart;
		else sprIndexArr[i] = obj_chainLamp_sprIndexes.chainMiddle;
	}
}

sprite = spr_lamp1;