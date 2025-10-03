/// @description Insert description here
// You can write your code in this editor
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
event_inherited();

initialize(26, true, 46, false, -1, 15*basePointConstant);

curStageManager = StageManager.currentStage.manager;

sprite = spr_swordsmaster;
collisionMask = sprite_index;
sprWidth = sprite_get_width(spr_swordsmaster);
sprHeight = sprite_get_height(spr_swordsmaster);
barX1 = -20;
barY1 = -20;
barWidth = 40;
barY2 = -12;
shakeHAdd = 0;
shakeVAdd = 0;
function setShake(distanceI) {
	var curAngle = irandom(359);
	shakeHAdd = dcos(curAngle)*distanceI;
	shakeVAdd = -dsin(curAngle)*distanceI;
}

defaultGrv = 0.4;
spd = 3;
acc = 0.8+physicsDefaultFriction;
lastDirection = -1;
canMoveStack = 0;
canChangeDirectionStack = 0;
hasTargetSpdStack = 0;
ignoresPlatforms = false;
ignoresCollisions = false;

isDetecting = false;

#region Generic actions

#region Shooting

shootingEnergy = 3;
shootingDmg = 15;
shooting = {
	p: other,
	projectile: obj_shooterDroneProjectile,
	projectileSpd: 8,
	start: function(projectileSpdI, projectileAngleI, projYAddI) {
		var newBullet = StageObjectManager.type_shooterDroneProjectile.add(p.x, p.y+projYAddI, projectileAngleI, projectileSpdI, p.shootingEnergy, p.shootingDmg, p.stageObjectID);
		StageObjectManager.instantiateObjectByID(newBullet, true);
	}
}

#endregion

#region Slashing

slash = {
	p: other,
	isSlashing: false,
	hasHitPlayer: false,
	animationSprite: spr_swordsmasterSlash1,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 15,
	knockback: 0,
	knockbackAcc: 0.5,
	color: 0,
	targetMap: undefined,
	actionObj: undefined,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, knockbackI, dmgI, colorI) {
		if (!isSlashing) {
			
			isSlashing = true;
			p.canChangeDirectionStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			knockback = knockbackI;
			damage = dmgI;
			color = colorI;
			
			p.ultraHeal.canStartStack++;
			
			targetMap = ds_map_create();
			ds_map_add(targetMap, obj_player.id, undefined);
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, targetMap, false);
			
			hasHitPlayer = false;
		}
	},
	
	hitFunction: function() {
		PlayerManager.receiveDamage(damage);
		if_physics.setHKnockback(obj_player.ifPhysics, knockback*p.lastDirection, false);
		hasHitPlayer = true;
	},
	
	stop: function() {
		isSlashing = false;
		p.canChangeDirectionStack--;
		p.ultraHeal.canStartStack--;
		actionObj.type.stop(actionObj);
		actionObj = undefined;
		ds_map_destroy(targetMap);
		targetMap = undefined;
	},
	
	cleanup: function() {
		if (targetMap != undefined) ds_map_destroy(targetMap);
		if (actionObj != undefined) actionObj.type.stop(actionObj);
	},
	
	tick: function() {
		if (isSlashing) {
			currentFrame++;
			/*if (currentFrame >= attackFrameMin || currentFrame < attackFrameMax) {
				if (!hasHitPlayer) {
					p.mask_index = hitboxSprite;
					p.image_xscale = p.lastDirection;
					with (p) {
						if (place_meeting(x, y, obj_player)) {
							PlayerManager.receiveDamage(other.damage);
							if_physics.setHKnockback(obj_player.ifPhysics, other.knockback*lastDirection, false); // OBSERVATION001 - See if you should target speeds, or add some other thing to replace the effect.
							//obj_player.physics.setHAcceleration(other.knockbackAcc);
							other.hasHitPlayer = true;
						}
					}
					p.mask_index = p.collisionMask;
				}
			}*/
			if (currentFrame == frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
		}
	},

	draw: function() {
		var isDrawing = false;
		var spriteFrame = 0;
		if (isSlashing) {
			isDrawing = true;
			spriteFrame = currentFrame;
		}
		
		if (isDrawing) {
			draw_sprite_ext(
				animationSprite, spriteFrame, p.x, p.y, p.lastDirection, 1.0, 0, color, 1.0
			);
		}
	}
}

#endregion

#region Teleport

teleport = {
	p: other,
	start: function(xI) {
		var curY = ceil(obj_player.y/16)*16-16;
		var curY1 = curY;
		var curY2 = curY;
		var outputY = 0;
		var yAdd = 16;
		var yAddUp = -16;
		while (true) {
			if (
				BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY1-p.sprHeight/2, xI+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) ||
				BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY1-p.sprHeight/2, xI+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp) ||
				(
				!BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY1+p.sprHeight/2, xI+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) &&
				!BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY1+p.sprHeight/2, xI+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp)
				)
			) {
				curY1 += yAdd;
			}else {
				outputY = curY1;
				break;
			}
			
			if (
				BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY2-p.sprHeight/2, xI+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) ||
				BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY2-p.sprHeight/2, xI+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp) ||
				(
				!BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY2+p.sprHeight/2, xI+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) &&
				!BlockCollisionGrid.checkCollisionRectangle(xI-p.sprWidth/2, curY2+p.sprHeight/2, xI+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp)
				)
			) {
				curY2 += yAddUp;
			}else {
				outputY = curY2;
				break;
			}
		}
		if_physics.setPosition(p.ifPhysics, xI, outputY);
	},
	startChoice: function(x1I, x2I) {
		var curY = ceil(obj_player.y/16)*16-16;
		var curY1 = curY;
		var curY2 = curY;
		var outputY = 0;
		var yAdd = 16;
		var yAddUp = -16;
		var outputX = 0;
		while (true) {
			var canTeleportX1 = false;
			var canTeleportX2 = false;
			
			#region X1 check
			
			if (x1I >= p.curStageManager.arenaX1+p.sprWidth/2) {
				if (
					BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY1-p.sprHeight/2, x1I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) ||
					BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY1-p.sprHeight/2, x1I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp) ||
					(
					!BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY1+p.sprHeight/2, x1I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) &&
					!BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY1+p.sprHeight/2, x1I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp)
					)
				) {
				}else {
					outputY = curY1;
					canTeleportX1 = true;
				}
			
				if (!canTeleportX1) {
					if (
						BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY2-p.sprHeight/2, x1I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) ||
						BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY2-p.sprHeight/2, x1I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp) ||
						(
						!BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY2+p.sprHeight/2, x1I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) &&
						!BlockCollisionGrid.checkCollisionRectangle(x1I-p.sprWidth/2, curY2+p.sprHeight/2, x1I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp)
						)
					) {
					}else {
						outputY = curY2;
						canTeleportX1 = true;
					}
				}
			}
			
			#endregion
			
			#region X2 check
			
			if (x2I <= p.curStageManager.arenaX2-p.sprWidth/2) {
				if (
					BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY1-p.sprHeight/2, x2I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) ||
					BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY1-p.sprHeight/2, x2I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp) ||
					(
					!BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY1+p.sprHeight/2, x2I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_normal) &&
					!BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY1+p.sprHeight/2, x2I+p.sprWidth/2, curY1+p.sprHeight/2, collisionType_onewayUp)
					)
				) {
				}else {
					outputY = curY1;
					canTeleportX2 = true;
				}
			
				if (!canTeleportX2) {
					if (
						BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY2-p.sprHeight/2, x2I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) ||
						BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY2-p.sprHeight/2, x2I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp) ||
						(
						!BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY2+p.sprHeight/2, x2I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_normal) &&
						!BlockCollisionGrid.checkCollisionRectangle(x2I-p.sprWidth/2, curY2+p.sprHeight/2, x2I+p.sprWidth/2, curY2+p.sprHeight/2, collisionType_onewayUp)
						)
					) {
					}else {
						outputY = curY2;
						canTeleportX2 = true;
					}
				}
			}
			
			#endregion
			
			if (canTeleportX1 && canTeleportX2) {
				outputX = choose(x1I, x2I);
				break;
			}else if (canTeleportX1) {
				outputX = x1I;
				break;
			}else if (canTeleportX2) {
				outputX = x2I;
				break;
			}else {
				curY1 += yAdd;
				curY2 += yAddUp;
			}
		}
		if_physics.setPosition(p.ifPhysics, outputX, outputY);
	}
}

#endregion

#region Lunge

lunge = {
	p: other,
	isBeingDone: false,
	hForce: 0,
	doesBounce: false,
	isFirstFrame: true,
	start: function(hForceI, vForceI, grvI, doesBounceI) {
		isBeingDone = true;
		p.ifPhysics.grv = grvI;
		p.ifPhysics.doesFriction = false;
		if_physics.setHSpeed(p.ifPhysics, hForceI);
		if_physics.setVSpeed(p.ifPhysics, vForceI);
		hForce = hForceI;
		doesBounce = doesBounceI;
		p.trailManager.isTrailActiveStack++;
		p.ultraHeal.canStartStack++;
		isFirstFrame = true;
	},
	stop: function() {
		isBeingDone = false;
		p.ultraHeal.canStartStack--;
		p.ifPhysics.grv = physicsDefaultGrv;
		p.ifPhysics.doesFriction = true;
		p.trailManager.isTrailActiveStack--;
	},
	tick: function() {
		if (isBeingDone) {
			if (doesBounce) {
				if (p.ifPhysics.isCollidingLeft || p.ifPhysics.isCollidingRight) {
					hForce *= -1;
					if_physics.setHSpeed(p.ifPhysics, hForce);
				}
			}
			if (!isFirstFrame && p.ifPhysics.isCollidingDown) {
				stop();
			}
			isFirstFrame = false;
		}
	}
}

#endregion

#region Backstep

backstep = {
	p: other,
	isBeingDone: false,
	canStartStack: 0,
	vForce: -7,
	hForce: 12,
	lungeGrv: 0.6,
	endedInFrame: false,
	start: function() {
		isBeingDone = true;
		var curDirection = sign(p.x-obj_player.x);
		p.lunge.start(curDirection*hForce, vForce, lungeGrv, false);
	},
	stop: function() {
		isBeingDone = false;
		if (p.lunge.isBeingDone) {
			p.lunge.stop();
		}
		endedInFrame = true;
	},
	tick: function() {
		endedInFrame = false;
		if (isBeingDone) {
			if (!p.lunge.isBeingDone) {
				stop();
			}
		}
	}
}

#endregion

#endregion

#region Boss attacks

slashColor = c_aqua;
slashColorEnraged = c_red;

isAttackBeingDone = false;
doesAttackFreezeCooldown = false;

threeSlashCombo = {
	p: other,
	startDistance: 100,
	startHeightMax: 24,
	startHeightMin: -100,
	delayArray: [85, 85, 95, 65],
	delayFramesCur: 0,
	canStartStack: 0,
	slashAnimations: [spr_swordsmasterSlash1, spr_swordsmasterSlash2, spr_swordsmasterSlash3],
	slashAttackFrames: [[4, 7], [4, 7], [4, 7]],
	slashKnockbacks: [14, 14, 14],
	slashEnergyCosts: [2, 2, 3],
	slashDamages: [15, 15, 25],
	slashHitboxes: [spr_swordsmasterSlash1Hitbox, spr_swordsmasterSlash2Hitbox, spr_swordsmasterSlash1Hitbox],
	hasStrongKnockbacked: false,
	slashIndex: 0,
	enragedSlashColor: c_red,
	isBeingDone: false,
	
	slashHForce: 9,
	
	lastSlashVForce: -7.5,
	isLastSlash: false,
	isNextLastSlash: false,
	lastSlashTeleportDelay: 35,
	lastSlashTeleportDelayCur: 0,
	teleportDistance: 80,
	
	isEnraged: false,
	isNextSecondSlash: false,
	enragedSlashTeleportDelay: 16,
	enragedSlashTeleportDelayCur: 16,
	hasRageTeleported: false,
	
	backstepLostHlth: 1, // How much health the enemy has to lose to be able to backstep after slash end.
	lostHlthCur: 0,
	isBackstepping: false,
	canBackstepStack: 0,
	
	cooldownFrames: 20,
	cooldownFramesCur: 0,
	start: function() {
		isBeingDone = true;
		slashIndex = 0;
		delayFramesCur = delayArray[0];
		p.canMoveStack++;
		p.triShot.canStartStack++;
		p.lungeAttack.canStartStack++;
		p.isAttackBeingDone = true;
		p.doesAttackFreezeCooldown = false;
		hasStrongKnockbacked = false;
		isLastSlash = false;
		isNextSecondSlash = false;
		hasTeleported = false;
		if (isEnraged) {
			hasRageTeleported = false;
			enragedSlashTeleportDelayCur = enragedSlashTeleportDelay;
		}
		lostHlthCur = 0;
		isBackstepping = false;
	},
	stop: function() {
		isBeingDone = false;
		p.isAttackBeingDone = false;
		p.canMoveStack--;
		p.triShot.canStartStack--;
		p.lungeAttack.canStartStack--;
		p.outOfRangeBehaviour.resetOutOfRange();
		cooldownFramesCur = cooldownFrames;
	},
	enrage: function() {
		isEnraged = true;
		delayArray = [45, 65, 65, 40];
	},
	startBackstep: function() {
		p.backstep.start();
		isBackstepping = true;
	},
	tick: function() {
		if (isBeingDone) {
			if (!isBackstepping) {
				delayFramesCur--;
				if (delayFramesCur == 0) {
					if (slashIndex == 3) {
						if (canBackstepStack == 0 && lostHlthCur >= backstepLostHlth) {
							startBackstep();
						}else {
							stop();
						}
					}else {
						p.slash.start(
							slashAnimations[slashIndex],
							slashAttackFrames[slashIndex][0],
							slashAttackFrames[slashIndex][1],
							slashHitboxes[slashIndex],
							slashKnockbacks[slashIndex],
							slashDamages[slashIndex],
							p.slashColor
						);
						if_physics.setHSpeed(p.ifPhysics, slashHForce*p.lastDirection);
						p.energyInterface.useEnergy(slashEnergyCosts[slashIndex]);
						if (slashIndex == 0) {
							isNextSecondSlash = true;
						}else if (slashIndex == 1) {
							isNextLastSlash = true;
							isNextSecondSlash = false;
							lastSlashTeleportDelayCur = lastSlashTeleportDelay;
						}else if (slashIndex == 2) {
							isNextLastSlash = false;
							isLastSlash =  true;
						}
						slashIndex++;
						delayFramesCur = delayArray[slashIndex];
					}
				}
				
				if (isEnraged && isNextSecondSlash) {
					if (enragedSlashTeleportDelayCur != 0) {
						enragedSlashTeleportDelayCur--;
					}else {
						if (!hasRageTeleported) {
							hasRageTeleported = true;
							p.teleport.startChoice(obj_player.x-teleportDistance, obj_player.x+teleportDistance);
						}
					}
				}else if (isNextLastSlash) {
					if (lastSlashTeleportDelayCur != 0) {
						lastSlashTeleportDelayCur--;
					}else {
						if (!hasTeleported) {
							hasTeleported = true;
							p.teleport.startChoice(obj_player.x-teleportDistance, obj_player.x+teleportDistance);
						}
					}
				}else if (isLastSlash) {
					if (p.slash.hasHitPlayer && !hasStrongKnockbacked) {
						obj_player.isStrongKnockbacked = true;
						hasStrongKnockbacked = true;
						if_physics.setVKnockback(obj_player.ifPhysics, lastSlashVForce);
						if_physics.applyFloorStrongKnockback(obj_player.ifPhysics);
					}
				}
			}else {
				if (!p.backstep.isBeingDone) {
					stop();
				}
			}
		}
		
		var yDiff = obj_player.y - p.y;
		if (
			canStartStack == 0 &&
			!isBeingDone &&
			cooldownFramesCur == 0 &&
			abs(p.x - obj_player.x) < startDistance &&
			yDiff < startHeightMax && yDiff > startHeightMin
		) {
			start();
		}
		
		if (cooldownFramesCur != 0) {
			cooldownFramesCur--;
		}
	},
	updateLostHlth: function(hlthI) {
		if (isBeingDone) {
			lostHlthCur += hlthI;
		}
	},
	draw: function() {
		if (!p.slash.isSlashing && isBeingDone) {
			if (slashIndex != 3) {
				var curSlashSprite = slashAnimations[slashIndex];
				draw_sprite_ext(curSlashSprite, 0, p.x, p.y, p.lastDirection, 1.0, 0, p.slashColor, 1.0);
			}else {
				var curSlashSprite = slashAnimations[2];
				draw_sprite_ext(curSlashSprite, sprite_get_number(curSlashSprite)-1, p.x, p.y, p.lastDirection, 1.0, 0, p.slashColor, 1.0);
			}
		}
	}
}

triShot = {
	p: other,
	cooldownFrames: 800,
	cooldownFramesCur: 800,
	energyCost: 3,
	canStartStack: 0,
	isBeingDone: false,
	delayFrames: 156,
	isAiming: false,
	aimAngle: 0,
	aimAlpha: 0.6,
	aimFlashState: 1,
	aimSprite: spr_swordsmasterArrow,
	telegraphFrames: 20,
	telegraphFramesCur: 20,
	hasShot: false,
	sideShotAngleDiff: 17,
	shotSpd: 10,
	recoveryFrames: 50,
	recoveryFramesCur: 0,
	selfKnockbackMax: 9,
	selfKnockbackMin: 6,
	
	isEnraged: false,
	isSecondShotting: false,
	secondShotDelay: 35,
	secondShotDelayCur: 35,
	sideRageShotAngleDiff: 13,
	rageDelayFrames: 50,
	
	barX1: other.barX1,
	barY1: other.barY1,
	barWidth: other.barWidth,
	barY2: other.barY2,
	barColor: c_white,
	start: function() {
		isAiming = true;
		aimFlashState = 1;
		p.isAttackBeingDone = true;
		p.doesAttackFreezeCooldown = true;
		cooldownFramesCur = cooldownFrames;
		isBeingDone = true;
		delayFramesCur = delayFrames;
		p.threeSlashCombo.canStartStack++;
		p.lungeAttack.canStartStack++;
		p.ultraHeal.canStartStack++;
		p.canMoveStack++;
		hasShot = false;
		
		secondShotDelayCur = secondShotDelay;
		isSecondShotting = false;
	},
	stop: function() {
		p.isAttackBeingDone = false;
		isBeingDone = false;
		p.threeSlashCombo.canStartStack--;
		p.lungeAttack.canStartStack--;
		p.ultraHeal.canStartStack--;
		p.canMoveStack--;
	},
	enrage: function() {
		isEnraged = true;
		delayFrames = rageDelayFrames;
	},
	tick: function() {
		if (isBeingDone) {
			if (!isAiming && telegraphFramesCur != 0) {
				telegraphFramesCur--;
				if (aimFlashState == 0) {
					aimFlashState = 1;
				}else {
					aimFlashState = 0;
				}
			}else if (!isSecondShotting && delayFramesCur != 0) {
				if (isAiming) {
					aimAngle = point_direction(p.x, p.y, obj_player.x, obj_player.y);
				}
				delayFramesCur--;
				if (delayFramesCur == 0) {
					isAiming = false;
					telegraphFramesCur = telegraphFrames;
				}
			}else if (isSecondShotting && secondShotDelayCur != 0) {
				secondShotDelayCur--;
			}else if (!hasShot) {
				var curAngle = aimAngle;
				if (!isSecondShotting) {
					p.energyInterface.useEnergy(energyCost);
					p.shooting.start(shotSpd, curAngle+sideShotAngleDiff, 0);
					p.shooting.start(shotSpd, curAngle, 0);
					p.shooting.start(shotSpd, curAngle-sideShotAngleDiff, 0);
				}else {
					/*curAngle += sideShotAngleDiff/2;
					p.shooting.start(shotSpd, curAngle+sideShotAngleDiff, 0);
					p.shooting.start(shotSpd, curAngle, 0);
					p.shooting.start(shotSpd, curAngle-sideShotAngleDiff, 0);
					p.shooting.start(shotSpd, curAngle-sideShotAngleDiff*2, 0);*/
					p.shooting.start(shotSpd, curAngle+sideShotAngleDiff, 0);
					p.shooting.start(shotSpd, curAngle, 0);
					p.shooting.start(shotSpd, curAngle-sideShotAngleDiff, 0);
				}
				if (!isEnraged || (isEnraged && isSecondShotting)) {
					hasShot = true;
					recoveryFramesCur = recoveryFrames;
				
					var curKnockback = selfKnockbackMin+(abs(dcos(curAngle)))*(selfKnockbackMax-selfKnockbackMin);
					if_physics.setHSpeed(p.ifPhysics, curKnockback*-p.lastDirection);
				}else {
					isSecondShotting = true;
				}
			}else {
				recoveryFramesCur--;
				if (recoveryFramesCur == 0) {
					stop();
				}
			}
		}
		if (canBeDone(true)) {
			start();
		}
		
		if ((!p.doesAttackFreezeCooldown || !p.isAttackBeingDone) && cooldownFramesCur != 0) {
			cooldownFramesCur--;
		}
	},
	draw: function() {
		if (isBeingDone) {
			draw_sprite_ext(aimSprite, 0, p.x, p.y, 1.0, 1.0, aimAngle, c_white, aimAlpha*aimFlashState);
			if (delayFramesCur != 0) {
				var curBarRatio = (delayFrames-delayFramesCur)/delayFrames;
				draw_set_color(barColor);
				draw_rectangle(p.x+barX1, p.y+barY1, p.x+barX1+curBarRatio*barWidth-1, p.y+barY2, false);
			}
		}
	},
	canBeDone: function(byCooldownI) {
		if (!isBeingDone && canStartStack == 0) {
			if (!byCooldownI || cooldownFramesCur == 0) {
				return true;
			}
		}
		return false;
	}
}

lungeAttack = {
	p: other,
	isBeingDone: false,
	canStartStack: 0,
	cooldownFrames: 530,
	cooldownFramesCur: 530,
	start: function() {
		p.isAttackBeingDone = true;
		p.doesAttackFreezeCooldown = true;
		isBeingDone = true;
		p.threeSlashCombo.canStartStack++;
		p.triShot.canStartStack++;
		p.ultraHeal.canStartStack++;
		if (random_by_fraction(1, 2)) {
			smashAttack.start();
		}else {
			spinSlash.start();
		}
	},
	stop: function() {
		p.isAttackBeingDone = false;
		p.threeSlashCombo.canStartStack--;
		p.triShot.canStartStack--;
		p.ultraHeal.canStartStack--;
		isBeingDone = false;
		cooldownFramesCur = cooldownFrames;
	},
	enrage: function() {
		lungeAttacksLunge.enrage();
		smashAttack.enrage();
		spinSlash.enrage();
	},
	tick: function() {
		if (canBeDone(true)) {
			start();
		}
		if ((!p.doesAttackFreezeCooldown || !p.isAttackBeingDone) && cooldownFramesCur != 0) {
			cooldownFramesCur--;
		}
		
		lungeAttacksLunge.tick();
		
		smashAttack.tick();
		spinSlash.tick();
	},
	canBeDone: function(byCooldownI) {
		return canStartStack == 0 && !isBeingDone && (!byCooldownI || cooldownFramesCur == 0);
	},
	draw: function() {
		spinSlash.draw();
	}
}

// Lunge attacks themselves
	with (lungeAttack) {
		lungeAttacksLunge = {
			p: other.lungeAttack.p,
			isBeingDone: false,
			isFinished: false,
			backstepDistance: 150,
			isBackstepping: false,
			jumpHForce: 8,
			jumpForce: -18,
			lungeGrv: 0.5,
			rageJumpHForce: 9,
			rageJumpVForce: -22,
			rageLungeGrv: 0.6,
			start: function(canBackstepI = true) {
				isBeingDone = true;
				isFinished = false;
				if (!canBackstepI || p.backstep.endedInFrame || abs(p.x-obj_player.x) > backstepDistance) {
					startMainLunge();
				}else {
					isBackstepping = true;
					p.backstep.start();
				}
			},
			stop: function() {
				isBeingDone = false;
				if (p.backstep.isBeingDone) {
					p.backstep.stop();
				}else if (p.lunge.isBeingDone) {
					p.lunge.stop();
				}
			},
			enrage: function() {
				jumpHForce = rageJumpHForce;
				jumpForce = rageJumpVForce;
				lungeGrv = rageLungeGrv;
			},
			startMainLunge: function() {
				p.lunge.start(sign(obj_player.x-p.x)*jumpHForce, jumpForce, lungeGrv, true);
				p.ignoresPlatforms = true;
				isBackstepping = false;
			},
			tick: function() {
				if (isBeingDone) {
					if (isBackstepping) {
						if (!p.backstep.isBeingDone) {
							startMainLunge();
						}
					}else {
						if (!p.lunge.isBeingDone) {
							stop();
						}
					}
				}
			}
		}

		smashAttack = {
			p: other.lungeAttack.p,
			lA: other.lungeAttack,
			isBeingDone: false,
			smashEnergyCost: 3,
			smashDmg: 20,
			canStartStack: 0,
			/*jumpHForce: 9,
			jumpForce: -20,
			lungeGrv: 0.6,*/
			smashGrv: 0.7,
			hasSmashStarted: false,
			smashStartVForce: -5,
			
			smashStartArenaDistance: 40,
	
			/*backstepDistance: 150,*/
			isBackstepping: false,
			isEnraged: false,
			isRageSmash: false,
	
			projectileSpd: 8,
			projectileYAdd: 16,
			start: function() {
				isBeingDone = true;
				p.threeSlashCombo.canStartStack++;
				p.triShot.canStartStack++;
				p.ultraHeal.canStartStack++;
				p.hasTargetSpdStack++;
				hasSmashStarted = false;
				isRageSmash = false;
				//show_debug_message("Penis");
		
				lA.lungeAttacksLunge.start();
				isBackstepping = lA.lungeAttacksLunge.isBackstepping;
			},
			stop: function() {
				isBeingDone = false;
				p.threeSlashCombo.canStartStack--;
				p.triShot.canStartStack--;
				p.ultraHeal.canStartStack--;
				p.hasTargetSpdStack--;
				p.ignoresPlatforms = false;
				p.ifPhysics.grv = physicsDefaultGrv;
				lA.stop();
			},
			startSmash: function() {
				p.trailManager.isTrailActiveStack++;
				hasSmashStarted = true;
				lA.lungeAttacksLunge.stop();
				if_physics.setHSpeed(p.ifPhysics, 0);
				if_physics.setVSpeed(p.ifPhysics, smashStartVForce);
				p.ifPhysics.grv = smashGrv;
			},
			smashEnd: function() {
				p.trailManager.isTrailActiveStack--;
				p.energyInterface.useEnergy(smashEnergyCost);
				var isCollidingPlayer = false;
				with (p) {
					if (place_meeting(x, y, obj_player)) {
						isCollidingPlayer = true;
					}
				}
				if (!isCollidingPlayer) {
					p.shooting.start(projectileSpd, 0, projectileYAdd);
					p.shooting.start(projectileSpd, 180, projectileYAdd);
				}else {
					PlayerManager.receiveDamage(smashDmg);
				}
			},
			enrage: function() {
				isEnraged = true;
			},
			tick: function() {
				if (isBeingDone) {
					if (!lA.lungeAttacksLunge.isBackstepping) {
						if (p.ifPhysics.isCollidingDown && !p.backstep.endedInFrame) {
							if (hasSmashStarted) {
								smashEnd();
								if (isEnraged && random_by_fraction(1, 2) && !isRageSmash) {
									hasSmashStarted = false;
									isRageSmash = true;
									lA.lungeAttacksLunge.start(false);
								}else {
									lA.lungeAttacksLunge.stop();
									stop();
								}
							}else {
								lA.lungeAttacksLunge.stop();
								stop();
							}
						}else if (!hasSmashStarted) {
							var xDiff = abs(obj_player.x-p.x);
							if (xDiff <= lA.lungeAttacksLunge.jumpHForce || ((p.x-p.curStageManager.arenaX1 <= smashStartArenaDistance || p.curStageManager.arenaX2-p.x <= smashStartArenaDistance) && abs(obj_player.x-p.x) <= smashStartArenaDistance)) {
								startSmash();
							}
						}
					}
					//isBackstepping = lA.lungeAttacksLunge.isBackstepping;
				}
			},
			canBeDone: function(byCooldownI) {
				if (canStartStack == 0 && !isBeingDone) {
					if (!byCooldownI || cooldownFramesCur == 0) {
						return true;
					}
				}
				return false;
			}
		}

		spinSlash = {
			p: other.lungeAttack.p,
			lA: other.lungeAttack,
			isBeingDone: false,
			energyCost: 6,
			canStartStack: 0,
			isSpinning: false,
			spinDirection: 0,
			spinHSpd: 7,
			isLunging: false,
			jumpVForce: -8,
			jumpMaxDistance: 90,
			durationFrames: 120,
			durationFramesCur: 0,
			spinAnimation: spr_swordsmasterSpinSlash,
			animationNumber: sprite_get_number(spr_swordsmasterSpinSlash),
			curAnimationIndex: 0,
		
			isBackstepping: false,
			
			hasRageLunged: false,
			isEnraged: false,
			enragedDurationFrames: 190,
			secondLungeDelay: 75,
			secondLungeDelayCur: 75,
		
			dmg: 8,
			dmgCooldown: 20,
			dmgCooldownCur: 0,
			knockbackForce: 18,
			hitbox: spr_swordsmasterSpinSlashHitbox,
			start: function() {
				isBeingDone = true;
				isSpinning = false;
				p.hasTargetSpdStack++;
				p.threeSlashCombo.canStartStack++;
				p.triShot.canStartStack++;
				p.ultraHeal.canStartStack++;
				lA.lungeAttacksLunge.start();
				isLunging = true;
				secondLungeDelayCur = secondLungeDelay;
				hasRageLunged = false;
			},
			startSpin: function() {
				p.energyInterface.useEnergy(energyCost);
				isSpinning = true;
				spinDirection = sign(p.ifPhysics.hSpd);
				p.ifPhysics.doesFriction = false;
				if (!isEnraged) {
					durationFramesCur = durationFrames;
				}else {
					durationFramesCur = enragedDurationFrames;
				}
				if_physics.setHSpeed(p.ifPhysics, spinDirection*spinHSpd);
			},
			stop: function() {
				isBeingDone = false;
				p.threeSlashCombo.canStartStack--;
				p.triShot.canStartStack--;
				p.ultraHeal.canStartStack--;
				p.hasTargetSpdStack--;
				p.ifPhysics.doesFriction = true;
				lA.stop();
			},
			enrage: function() {
				isEnraged = true;
			},
			tick: function() {
				if (isBeingDone) {
					if (isLunging) {
						if (!lA.lungeAttacksLunge.isBeingDone) {
							p.ignoresPlatforms = false;
							isLunging = false;
							if (!isSpinning) {
								startSpin();
							}
						}
					}
					if (isSpinning) {
						if (isEnraged) {
							if (secondLungeDelayCur == 0) {
								if (p.ifPhysics.isCollidingDown && !isLunging && !hasRageLunged) {
									isLunging = true;
									hasRageLunged = true;
									lA.lungeAttacksLunge.start(false);
								}
							}else {
								secondLungeDelayCur--;
							}
						}
						curAnimationIndex++;
						if (curAnimationIndex == animationNumber) {
							curAnimationIndex = 0;
						}
						if (p.ifPhysics.isCollidingLeft || p.ifPhysics.isCollidingRight) {
							spinDirection *= -1;
							if_physics.setHSpeed(p.ifPhysics, spinDirection*spinHSpd);
						}
					
						var hasHitPlayer = false;
						if (dmgCooldownCur == 0) {
							with (p) {
								mask_index = other.hitbox;
								if (place_meeting(x, y, obj_player)) {
									hasHitPlayer = true;
								}
								mask_index = spr_swordsmaster;
							}
						}else {
							dmgCooldownCur--;
						}
					
						if (hasHitPlayer) {
							PlayerManager.receiveDamage(dmg);
							if_physics.setHKnockback(obj_player.ifPhysics, sign(obj_player.x-p.x)*knockbackForce, false);
							dmgCooldownCur = dmgCooldown;
						}
				
						if (durationFramesCur == 0) {
							if (p.ifPhysics.isCollidingDown) {
								stop();
							}
						}else {
							durationFramesCur--;
						}
					}
				}
			},
			draw: function() {
				if (isBeingDone && isSpinning) {
					draw_sprite_ext(spinAnimation, curAnimationIndex, p.x, p.y, 1.0, 1.0, 0, p.slashColor, 1.0);
				}
			}
		}
	}

ultraHeal = {
	p: other,
	isBeingDone: false,
	willHeal: false,
	canStartStack: 0,
	energyCost: 28,
	delayFrames: 70,
	delayFramesCur: 70,
	recoveryFrames: 75,
	recoveryFramesCur: 75,
	hlthForStart: 9,
	hasCured: false,
	
	knockbackHDistance: 200,
	knockbackVDistance: 200,
	knockbackHForce: 18,
	knockbackVForce: -18,
	explosionRange: 220,
	explosionColor: c_white,
	explosionLifetimeFrames: 50,
	explosionLifetimeFramesCur: 0,
	
	barX1: other.barX1,
	barY1: other.barY1,
	barWidth: other.barWidth,
	barY2: other.barY2,
	barColor: c_white,
	start: function() {
		p.isAttackBeingDone = true;
		p.doesAttackFreezeCooldown = true;
		delayFramesCur = delayFrames;
		recoveryFramesCur = recoveryFrames;
		isBeingDone = true;
		hasCured = false;
		p.threeSlashCombo.canStartStack++;
		p.triShot.canStartStack++;
		p.lungeAttack.canStartStack++;
		if (p.threeSlashCombo.isBeingDone) p.threeSlashCombo.stop();
		if (p.triShot.isBeingDone) p.triShot.stop();
		if (p.lungeAttack.isBeingDone) p.lungeAttack.stop();
		p.canMoveStack++;
	},
	stop: function() {
		p.isAttackBeingDone = false;
		isBeingDone = false;
		p.threeSlashCombo.canStartStack--;
		p.triShot.canStartStack--;
		p.lungeAttack.canStartStack--;
		p.canMoveStack--;
	},
	tick: function() {
		if (isBeingDone) {
			if (!hasCured) {
				delayFramesCur--;
				if (delayFramesCur == 0) {
					if (abs(obj_player.x-p.x) < knockbackHDistance && abs(obj_player.y-p.y) < knockbackVDistance) {
						if_physics.setKnockback(obj_player.ifPhysics, sign(obj_player.x-p.x)*knockbackHForce, knockbackVForce);
						if_physics.applyFloorStrongKnockback(obj_player.ifPhysics);
					}
					explosionLifetimeFramesCur = explosionLifetimeFrames;
					p.hlthInterface.setHlth(p.hlthInterface.hlthMax);
					p.energyInterface.useEnergy(energyCost);
					hasCured = true;
				}
			}else {
				recoveryFramesCur--;
				if (recoveryFramesCur == 0) {
					stop();
				}
			}
		}
		
		if (!willHeal && !isBeingDone && p.hlthInterface.hlth <= hlthForStart) {
			willHeal = true;
			p.threeSlashCombo.canBackstepStack++;
		}
		
		if (canBeDone() && willHeal) {
			willHeal = false;
			start();
			p.threeSlashCombo.canBackstepStack--;
		}
		
		if (explosionLifetimeFramesCur != 0) {
			explosionLifetimeFramesCur--;
		}
	},
	canBeDone: function() {
		return canStartStack == 0 && !isBeingDone && p.energyInterface.energy >= energyCost;
	},
	draw: function() {
		if (isBeingDone) {
			draw_set_color(barColor);
			draw_set_alpha((delayFrames-delayFramesCur)/delayFrames);
			draw_rectangle(p.x+barX1, p.y+barY1, p.x+barX1+barWidth, p.y+barY2, false);
			draw_set_alpha(1.0);
		}
	},
	preDraw: function() {
		draw_set_color(explosionColor);
		draw_set_alpha((explosionLifetimeFramesCur)/explosionLifetimeFrames);
		draw_circle(p.x, p.y, explosionRange, false);
		draw_set_alpha(1.0);
	}
}

enrage = {
	p: other,
	isEnraged: false,
	isBeingDone: false,
	maxShakeDistance: 12,
	enragingNodeAmount: 1,
	delayFrames: 80,
	delayFramesCur: 80,
	chargeSpr: spr_swordsmasterEnrageCharge,
	start: function() {
		isBeingDone = true;
		p.isAttackBeingDone = true;
		p.doesAttackFreezeCooldown = true;
		p.threeSlashCombo.canStartStack++;
		p.triShot.canStartStack++;
		p.lungeAttack.canStartStack++;
		p.ultraHeal.canStartStack++;
		p.canMoveStack++;
	},
	stop: function() {
		isBeingDone = false;
		delayFramesCur = delayFrames;
		p.threeSlashCombo.canStartStack--;
		p.triShot.canStartStack--;
		p.lungeAttack.canStartStack--;
		p.ultraHeal.canStartStack--;
		p.isAttackBeingDone = false;
		p.doesAttackFreezeCooldown = false;
		p.canMoveStack--;
	},
	enrage: function() {
		p.slashColor = p.slashColorEnraged;
		p.threeSlashCombo.enrage();
		p.triShot.enrage();
		p.lungeAttack.enrage();
		p.outOfRangeBehaviour.enrage();
		isEnraged = true;
	},
	draw: function() {
		if (isEnraged) {
			draw_sprite(chargeSpr, 0, p.x, p.y);
		}
	},
	tick: function() {
		if (!isEnraged) {
			if (!isBeingDone) {
				var existingNodes = 0;
				for (var i = 0; i < array_length(p.curStageManager.arenaNodes); i++) {
					if (StageObjectManager.objectExists(p.curStageManager.arenaNodes[i])) {
						existingNodes++;
					}
				}
				if (existingNodes == enragingNodeAmount) {
					start();
				}
			}else {
				if (delayFramesCur != 0) {
					p.setShake((delayFrames-delayFramesCur)/delayFrames*maxShakeDistance);
					delayFramesCur--;
				}else {
					p.setShake(0);
					stop();
					enrage();
				}
			}
		}
	}
}

#endregion

#region Attack pattern management

outOfRangeBehaviour = {
	p: other,
	outOfRangeFrames: 110,
	outOfRangeFramesCur: 110,
	resetOutOfRange: function() {
		outOfRangeFramesCur = outOfRangeFrames;
	},
	enrage: function() {
		outOfRangeFrames = 90;
	},
	tick: function() {
		if (p.threeSlashCombo.isBeingDone || p.triShot.isBeingDone || p.lungeAttack.isBeingDone) {
			resetOutOfRange();
		}else if (outOfRangeFramesCur != 0) {
			outOfRangeFramesCur--;
		}
		
		if (outOfRangeFramesCur == 0) {
			if (p.triShot.canBeDone(false) && p.triShot.cooldownFramesCur < p.lungeAttack.cooldownFramesCur) {
				p.triShot.start();
				resetOutOfRange();
			}else if (p.lungeAttack.canBeDone(false)) {
				p.lungeAttack.start();
				resetOutOfRange();
			}
		}
	}
}

#endregion

#region Dying

death = {
	p: other,
	willStart: false,
	isDying: false,
	isGettingOut: false,
	hForceRange: 7,
	vForce: -14,
	dyingKnockback: 9,
	delayFrames: 120,
	delayFramesCur: 120,
	shakeStartFrame: 80,
	shakeDistance: 12,
	start: function() {
		willStart = true;
	},
	jumpToJump: function() {
		delayFramesCur = 0;
	},
	startProcess: function() {
		if (p.threeSlashCombo.isBeingDone) p.threeSlashCombo.stop();
		if (p.triShot.isBeingDone) p.triShot.stop();
		if (p.lungeAttack.isBeingDone) p.lungeAttack.stop();
		isDying = true;
	},
	tick: function() {
		if (willStart && !p.slash.isSlashing && !p.lunge.isBeingDone) {
			startProcess();
		}
		if (isDying) {
			if (delayFramesCur == 0) {
				if (!isGettingOut) {
					getOut();
				}
			}else {
				delayFramesCur--;
				p.setShake((1-min(1.0, delayFramesCur/shakeStartFrame))*shakeDistance);
			}
			if (p.y > p.curStageManager.disappearY) {
				PointsManager.notifyEnemyKill(other);
				StageObjectManager.destroyObjectByInstance(other);
			}
		}
	},
	getOut: function() {
		isGettingOut = true;
		if_physics.setHSpeed(p.ifPhysics, choose(-1, 1)*irandom(hForceRange));
		if_physics.setVSpeed(p.ifPhysics, vForce);
		p.ifPhysics.doesFriction = false;
		p.ignoresCollisions = true;
		p.setShake(0);
		p.hasTargetSpdStack++;
	}
}

energyDeath = {
	_p: other,
	isDying: false,
	energyDeathDelay: 170,
	energyDeathDelayCur: 0,
	barX1: -60, barWidth: 120,
	barY1: -90, barY2: -80,
	barColor: c_white,
	isExploding: false,
	explosionAmount: 5,
	explosionCurIndex: 0,
	explosionDelays: [50, 40, 20, 20, 20],
	shakeValue: 8, shakeDurationFrames: 9, shakeDurationFramesCur: 0,
	explosionCurDelay: 0,
	tick: function() {
		if (!isDying) {
			if (!_p.energyInterface.hasEnergy) {
				energyDeathDelayCur++;
				if (energyDeathDelayCur == energyDeathDelay) {
					startDeath();
				}
			}else {
				energyDeathDelayCur = 0;
			}
		}else {
			if (isExploding) {
				explosionCurDelay++;
				if (explosionCurDelay == explosionDelays[explosionCurIndex]) {
					explosionCurDelay = 0;
					shakeDurationFramesCur = shakeDurationFrames;
					explosionCurIndex++;
					if (explosionCurIndex == explosionAmount) {
						GameplayManager.completeChallenge(challenge_ID.stage2_bossEnergy);
						isExploding = false;
						_p.death.jumpToJump();
						_p.death.start();
						stop();
					}
				}
			}
		}
		if (shakeDurationFramesCur != 0) {
			shakeDurationFramesCur--;
			_p.setShake(shakeDurationFramesCur/shakeDurationFrames*shakeValue);
		}
	},
	draw: function() {
		if (!_p.energyInterface.hasEnergy) {
			draw_set_color(c_white);
			var curBarRatio = (energyDeathDelay-energyDeathDelayCur)/energyDeathDelay;
			draw_rectangle(_p.x+barX1, _p.y+barY1, _p.x+barX1+barWidth*curBarRatio-1, _p.y+barY2-1, false);
		}
	},
	startDeath: function() {
		isDying = true;
		isExploding = true;
		explosionCurDelay = 0;
		_p.canMoveStack++;
		if (_p.threeSlashCombo.isBeingDone) _p.threeSlashCombo.stop();
		if (_p.triShot.isBeingDone) _p.triShot.stop();
		if (_p.lungeAttack.isBeingDone) _p.lungeAttack.stop();
	},
	stop: function() {
		_p.canMoveStack--;
		isDying = false;
	}
}

function die() {
	death.start();
}

#endregion

enemyReceiveDmgExtra = function(hlthI) {
	threeSlashCombo.updateLostHlth(hlthI);
}

trailManager = {
	p: other,
	isTrailActiveStack: 0,
	cooldown: 5,
	cooldownCur: 5,
	lifetime: 50,
	trailArrCapacity: 16,
	trailArr: array_create(16, [0, 0, 0]),
	trailArrIndex: 0,
	tick: function() {
		if (isTrailActiveStack != 0) {
			if (cooldownCur != 0) {
				cooldownCur--;
			}else {
				cooldownCur = cooldown;
				trailArr[trailArrIndex] = [lifetime, p.x, p.y];
				trailArrIndex++;
				if (trailArrIndex == trailArrCapacity) {
					trailArrIndex = 0;
				}
			}
		}
		
		for (var i = 0; i < trailArrCapacity; i++) {
			var curTrail = trailArr[i];
			if (curTrail[0] != 0) {
				curTrail[0]--;
			}
		}
	},
	draw: function() {
		for (var i = 0; i < trailArrCapacity; i++) {
			var curTrail = trailArr[i];
			if (curTrail[0] != 0) {
				var curAlpha = curTrail[0]/lifetime;
				draw_sprite_ext(p.sprite, 0, curTrail[1], curTrail[2], 1.0, 1.0, 0, c_white, curAlpha);
			}
		}
	}
}
