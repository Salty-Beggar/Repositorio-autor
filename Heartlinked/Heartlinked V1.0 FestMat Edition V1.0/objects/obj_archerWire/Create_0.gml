/// @description Insert description here
// You can write your code in this editor

function constructNode(xI, yI) {
	return {
		x: xI,
		y: yI
	}
}

function addNode(xI, yI) {
	array_push(nodes, constructNode(xI, yI));
}

dmg = 1.5;

nodes = [];

pulseFrames = 30;
pulseFramesCur = 0;

cooldownFrames = 20;
cooldownFramesCur = 0;

charge = 330;
chargeMax = 330;
chargeDecCur = 1;
chargeDecAcc = 0.01;
chargeHitGain = 60;