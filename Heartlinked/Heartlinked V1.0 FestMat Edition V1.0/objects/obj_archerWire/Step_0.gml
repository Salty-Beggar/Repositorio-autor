/// @description Insert description here
// You can write your code in this editor

if (pulseFramesCur > 0) pulseFramesCur--;

cooldownFramesCur--;
if (cooldownFramesCur <= 0) {
	cooldownFramesCur = cooldownFrames;
	pulseFramesCur = pulseFrames;
	for (var i = 0; i < instance_number(obj_enemyParent); i++) {
		var curEnemy = instance_find(obj_enemyParent, i);
		if (collision_line(nodes[0].x, nodes[0].y, nodes[1].x, nodes[1].y, curEnemy, false, false)) {
			EnemySubmanager.damageEnemy(curEnemy, dmg);
			//charge -= 80;
			charge += chargeHitGain;
		}
	}
}

charge -= chargeDecCur;
chargeDecCur += chargeDecAcc;
if (charge <= 0) instance_destroy();