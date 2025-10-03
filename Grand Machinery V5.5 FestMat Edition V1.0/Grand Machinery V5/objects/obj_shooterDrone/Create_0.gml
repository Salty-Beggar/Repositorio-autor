/// @description Insert description here
// You can write your code in this editor
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
event_inherited();

initialize(3, true, 7, false, -1, 100);

#region Animation

curSprIdle = spr_shooterDroneIdle;
curSprShoot = spr_shooterDroneShoot;
curSprRecoil = spr_shooterDroneRecoil;

enum shooterDrone_animationID {
	idle,
	shoot,
	recoil
}

selfDrawer = {
	_p: other,
	curAnimID: undefined,
	curSpr: other.curSprIdle,
	curSprIndex: 0,
	curSprLength: sprite_get_number(other.curSprIdle),
	isAutoAnimated: true,
	doesAnimLoop: true,
	curSpd: 8,
	curSpdCur: 0,
	lastPlayerDirection: 0,
	
	startAnimation_idle: function() {
		startAnimation(shooterDrone_animationID.idle, other.curSprIdle, true, 8);
	},
	startAnimation_shoot: function() {
		startAnimation(shooterDrone_animationID.shoot, other.curSprShoot, true, 4);
	},
	startAnimation_recoil: function() {
		startAnimation(shooterDrone_animationID.recoil, other.curSprRecoil, true, 4);
		doesAnimLoop = false;
	},
	startAnimation: function(animIDI, sprI, isAutoAnimatedI, spdI) {
		curAnimID = animIDI;
		curSpr = sprI;
		curSprIndex = 0;
		curSprLength = sprite_get_number(sprI);
		curSpd = spdI;
		curSpdCur = 0;
		isAutoAnimated = isAutoAnimatedI;
		doesAnimLoop = true;
	},
	setFrame: function(frameI) {
		curSprIndex = frameI%curSprLength;
	},
	setFrameByRatio: function(ratioI) {
		curSprIndex = min(curSprLength-1, floor(ratioI*curSprLength));
	},
	tick: function() {
		if (!isAutoAnimated || curAnimID != shooterDrone_animationID.recoil) {
			if (_p.targettingInterface.isTargetting) {if (curAnimID != shooterDrone_animationID.shoot) startAnimation_shoot();}
			else if (curAnimID != shooterDrone_animationID.idle) startAnimation_idle();
		}
		
		if (isAutoAnimated) {
			curSpdCur++;
			if (curSpdCur == curSpd) {
				curSpdCur = 0;
				curSprIndex++;
				if (curSprIndex == curSprLength) {
					if (doesAnimLoop) curSprIndex = 0;
					else {curSprIndex--; isAutoAnimated = false;}
				}
			}
		}
	},
	draw: function() {
		draw_sprite_ext(curSpr, curSprIndex, _p.x, _p.y, _p.currentDirection, 1.0, 0, c_white, 1.0);
	}
}

selfDrawer.startAnimation_idle();

#endregion

currentDirection = 1;
lockedDir = 0;
if (lockedDir != 0) {
	currentDirection = lockedDir;
}else if (currentDirection == 0) {
	currentDirection = 1;
}

with (targettingInterface) {
	isInstanceTargetted = function(instI) {
		var p = instanceID.id;
		var yDistanceDiff = p.y-instI.y;
		return yDistanceDiff >= p.detectionHeightMin && !BlockCollisionGrid.checkCollisionRectangle(p.x, p.y, instI.x, instI.y, collisionType_normal);
	}
}
detectionHeightMin = -1;
hasDetectedPlayer = false;

enemyReceiveDmgExtra = function(hlthI) {
	shooting.stun();
}

#region Shooting

shootingEnergyCost = 1;
shootingDmg = 15;
shootingEnergy = 3;
shooting = {
	p: other,
	canStart: false,
	isCooldownActive: false,
	projectile: obj_shooterDroneProjectile,
	projectileSpd: 5,
	cooldownFrames: 140,
	cooldownFramesCur: other.shootingCooldownFramesInit,
	isAiming: false,
	aimFrames: 30,
	aimFramesCur: 0,
	aimAlphaState: 1,
	aimAlphaFrames: 2,
	aimAlphaFramesCur: 2,
	stunFrames: 20,
	stunFramesCur: 0,
	barX1: -12, barY1: 2,
	barWidth: 24, barY2: 12,
	barColor: c_white,
	barColorInactive: c_grey,
	resetCooldown: function() {
		cooldownFramesCur = cooldownFrames;
	},
	start: function() {
		canStart = false;
		cooldownFramesCur = cooldownFrames;
		p.energyInterface.useEnergy(p.shootingEnergyCost);
		var newBullet = StageObjectManager.type_shooterDroneProjectile.add(p.x, p.y, 90-p.currentDirection*90, projectileSpd, p.shootingEnergy, p.shootingDmg, p.stageObjectID);
		StageObjectManager.instantiateObjectByID(newBullet, true);
		p.selfDrawer.startAnimation_recoil();
	},
	startAim: function() {
		aimFramesCur = aimFrames;
		isAiming = true;
	},
	stun: function() {
		stunFramesCur = stunFrames;
	},
	tick: function() {
		if (p.hasDetectedPlayer && stunFramesCur == 0) {
			isCooldownActive = true;
		}else {
			isCooldownActive  = false;
		}
		var willShoot = false;
		if (!willShoot) {
			if (cooldownFramesCur != 0 && isCooldownActive) {
				cooldownFramesCur--;
			}else if (!isAiming && p.energyInterface.hasEnergy && cooldownFramesCur == 0 && p.targettingInterface.isTargetting) {
				startAim();
			}else if (isAiming) {
				aimFramesCur--;
				if (aimFramesCur == 0) {
					isAiming = false;
					willShoot = true;
				}
				
				aimAlphaFramesCur--;
				if (aimAlphaFramesCur == 0) {
					aimAlphaFramesCur = aimAlphaFrames;
					if (aimAlphaState == 1) {
						aimAlphaState = 0.8;
					}else {
						aimAlphaState = 1;
					}
				}
			}
		}
		if (willShoot) {
			if (p.energyInterface.energy >= p.shootingEnergyCost) {
				canStart = true;
			}
		}
		if (stunFramesCur != 0) {
			stunFramesCur--;
		}
	},
	draw: function() {
		var curBarRatio = (cooldownFrames-cooldownFramesCur)/cooldownFrames;
		draw_set_color(barColor);
		if (!isCooldownActive) {
			draw_set_color(barColorInactive);
		}
		var curAlpha = 1.0;
		if (isAiming) {
			curAlpha *= aimAlphaState;
		}
		draw_set_alpha(curAlpha);
		draw_rectangle(
			p.x+barX1, p.y+barY1,
			p.x+barX1+curBarRatio*barWidth-1, p.y+barY2-1,
			false
		);
		draw_set_alpha(1.0);
	}
}

#endregion

#region Blowing

blowingEnergyCost = 1;
blowingDistance = 60;
blowingHeightMin = -1;
blowingHeightMax = 10;

isChargingBlow = false;
blowingChargeFrames = 30;
blowingChargeFramesCur = 0;
isRecoveringBlow = false;
blowingRecoveryFrames = 30;
blowingRecoveryFramesCur = 0;
blowing = {
	parentObj: other,
	canBlow: true,
	sprite: spr_shooterDroneBlow,
	hForce: 17,
	start: function() {
		parentObj.energyInterface.useEnergy(parentObj.blowingEnergyCost);
		parentObj.shooting.isCooldownActive = true;
		var yDistanceDiff = parentObj.y-parentObj.lastTarget.y;
		if (abs(parentObj.lastTarget.x - parentObj.x) <= parentObj.blowingDistance && yDistanceDiff >= parentObj.blowingHeightMin && yDistanceDiff < parentObj.blowingHeightMax) {
			if_physics.setHKnockback(parentObj.lastTarget.ifPhysics, hForce*parentObj.currentDirection, false);
			if_physics.applyTemporaryStrongKnockback(parentObj.lastTarget.ifPhysics, 9);
		}
		with (parentObj) {
			isRecoveringBlow = true;
			blowingRecoveryFramesCur = blowingRecoveryFrames;
		}
	},
	draw: function() {
		with (parentObj) {
			if (isRecoveringBlow) {
				draw_sprite_ext(blowing.sprite, 0, x, y, currentDirection, 1.0, 0, c_white, blowingRecoveryFramesCur/blowingRecoveryFrames);
			}
		}
	}
}

#endregion
