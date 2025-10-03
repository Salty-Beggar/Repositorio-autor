/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

die = function() {
	canMoveStack++;
}

curSprSet = spr_skinSimple;
curSprIndex = GameplayManager.selectedSkinID;

curSprIdle = spr_playerIdle;
curSprWalk = spr_playerWalk;
curSprSlide = spr_playerSlide;
curSprSlash = spr_playerSlash;
curSprShoot = spr_playerShoot;

isDoingAction = false;

enum player_animationID {
	idle,
	walk,
	slash,
	slide,
	shoot,
	roll
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
		startAnimation(player_animationID.idle, other.curSprIdle, true, 8);
	},
	startAnimation_walk: function() {
		startAnimation(player_animationID.walk, other.curSprWalk, true, 4);
	},
	startAnimation_slide: function() {
		startAnimation(player_animationID.slide, other.curSprSlide, true, 0);
	},
	startAnimation_slash: function() {
		startAnimation(player_animationID.slash, other.curSprSlash, true, 1);
	},
	startAnimation_slashGreat: function() {
		startAnimation(player_animationID.slash, spr_playerSlashGreat, true, 1);
	},
	startAnimation_diveSlash: function() {
		startAnimation(player_animationID.slash, spr_playerDive, true, 1);
	},
	startAnimation_slideSlash: function() {
		startAnimation(player_animationID.slash, spr_playerSlideSlash, true, 1);
	},
	startAnimation_shoot: function() {
		startAnimation(player_animationID.shoot, other.curSprShoot, true, 2);
		doesAnimLoop = false;
	},
	startAnimation_roll: function() {
		startAnimation(player_animationID.roll, spr_playerRoll, true, 1);
	},
	startAnimation_rollSlash: function() {
		startAnimation(player_animationID.slash, spr_playerRollSlash, true, 1);
	},
	startAnimation_rollSlashDir: function() {
		startAnimation(player_animationID.slash, spr_playerRollSlashDir, true, 1);
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
		if (!_p.rollSlash.isSlashing && !_p.slash.isSlashing && !_p.greatSlash.isSlashing && !_p.diveSlash.isSlashing & !_p.slideSlash.isSlashing) {
			if (_p.roll.isBeingDone) {if (curAnimID != player_animationID.roll) startAnimation_roll();}
			else if (_p.slide.isSliding) {if (curAnimID != player_animationID.slide) startAnimation_slide();}
			else if (_p.shot.isBeingDone) {if (curAnimID != player_animationID.shoot) startAnimation_shoot();}
			else if (_p.curDirection == 0) {if (curAnimID != player_animationID.idle) startAnimation_idle();}
			else if (curAnimID != player_animationID.walk) startAnimation_walk();
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
		draw_sprite_ext(curSpr, curSprIndex, _p.x, _p.y, _p.lastDirection, 1.0, 0, _p.blend, 1.0);
	}
}

selfDrawer.startAnimation_idle();

#region Physics

collisionMask = spr_player;

maxSpd = 3;
accSpd = 1.5;
canMove = true;
canMoveSwitch = true;
canMoveStack = 0;
canChangeDirection = true;
lastDirection = 1;
curDirection = 0;

canBeRepulsedStack = 0;
canBeRepulsedSwitch = true;
isBeingRepulsed = false;

with (ifPhysics) {
	strongKnockbackStartExtra = function() {
		instanceID.canMoveStack++;
		doesFriction = false;
	}
	strongKnockbackEndExtra = function() {
		instanceID.canMoveStack--;
		doesFriction = true;
	}
}

#region Jumping

canJump = true;
canJumpSwitch = true;
canJumpStack = 0;
jumpForce = -11.0;
coyoteFrames = 5;
coyoteFramesCur = coyoteFrames;
isHoldingJump = false;

function jump() {
	isHoldingJump = true;
	coyoteFramesCur = 0;
	if_physics.setVSpeed(ifPhysics, jumpForce);
	if (slide.isSliding) {
		slide.stop();
	}
}

#endregion

#endregion

#region Hlth packet use

healing = {
	p: other,
	canStartSwitch: true,
	canStartStack: 0,
	isHealing: false,
	healDelayFrames: 30,
	healDelayFramesCur: 0,
	barX1: -15,
	barY1: -25,
	barWidth: 30,
	barY2: -17,
	barFillColor: c_red,
	hasCharged: false,
	start: function() {
		isHealing = true;
		healDelayFramesCur = healDelayFrames;
	},
	applyHeal: function() {
		PlayerManager.useHlthPacket(1);
	},
	applyCharge: function() {
		PlayerManager.charge = 6;
		PlayerManager.hlthPacketCur--;
		hasCharged = true;
	},
	stop: function() {
		isHealing = false;
	},
	tick: function() {
		hasCharged = false;
		if (PlayerManager.hlthPacketCur == 0 || !p.ifPhysics.isCollidingDown) {
			canStartSwitch = false;
		}
		if (isHealing) {
			healDelayFramesCur--;
			if (healDelayFramesCur == 0) {
				applyHeal();
				stop();
			}
			
			if (InputManager.isInputActivated(input_ID.hlthPacket)) {
				applyCharge();
				stop();
			}
		}
	},
	draw: function() {
		if (isHealing) {
			var curProgress = (healDelayFrames-healDelayFramesCur)/healDelayFrames;
			draw_set_color(barFillColor);
			draw_rectangle(p.x+barX1, p.y+barY1, p.x+barX1+curProgress*barWidth-1, p.y+barY2-1, false);
		}
	}
};

#endregion

#region Slashing

slash = {
	p: other,
	isSlashing: false,
	canStartSwitch: true,
	canStartStack: 0,
	animationSprite: spr_daggerSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 0,
	cooldownInit: 0,
	cooldownCur: 0,
	hasHit: false,
	actionObj: undefined,
	soundDelayFrames: 1,
	soundDelayFramesCur: 0,
	
	willSlash: false,
	
	isStanding: false,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI) {
		if (canStartStack == 0 && !isSlashing && !p.slide.isSliding) {
			p.isDoingAction = true;
			p.healing.canStartStack++;
			p.slide.canSlideStack++;
			
			isSlashing = true;
			canStartStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			damage = damageI;
			cooldownCur = cooldownI;
			cooldownInit = cooldownI;
			hasHit = false;
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, HlthInterface.map, true);
			obj_player.canMove = false;
			obj_player.selfDrawer.startAnimation_slash();
			
			soundDelayFramesCur = 0;
		}
	},
	
	hitFunction: function(instI) {
		instI.hlthInterface.receiveDamage(damage);
		PlayerManager.charge++;
		if (PlayerManager.charge > PlayerManager.chargeMax) PlayerManager.charge = PlayerManager.chargeMax;
		CameraManager.setPush(2, 90+p.lastDirection*90);
	},
	
	stop: function() {
		p.isDoingAction = false;
		p.healing.canStartStack--;
		p.slide.canSlideStack--;
		
		isSlashing = false;
		canJump = true;
		ActionObjectManagers.slash.stop(actionObj);
		cleanup();
	},
	
	cleanup: function() {
		
	},
	
	tick: function() {
		if (!p.diveSlash.isDiving && !p.slideSlash.isSlashing && InputManager.isInputActivated(input_ID.primaryUseI) && !PlayerManager.isDead) {
			willSlash = true;
		}
		
		if (p.rollSlash.isSlashing) {
			willSlash = false;
		}
		
		if (canStartStack == 0 && willSlash) {
			start(spr_daggerSlash, 1, 6, spr_daggerSlashCollision, 1, 21);
			willSlash = false;
		}
		
		if (isSlashing) {
			if (soundDelayFramesCur == soundDelayFrames) {
				if (random_by_fraction(1, 2)) audio_play_sound(snd_slashSwipe2, 0, false);
				else audio_play_sound(snd_slashSwipe1, 0, false);
				soundDelayFramesCur++;
			}else soundDelayFramesCur++;
			
			obj_player.selfDrawer.setFrameByRatio(currentFrame/frameAmount);
			currentFrame++;
			if (currentFrame == frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
			
			if (p.ifPhysics.isCollidingDown && !isStanding) {
				isStanding = true;
				p.canMoveStack++;
			}else if (isStanding && !p.ifPhysics.isCollidingDown) {
				isStanding = false;
				p.canMoveStack--;
			}
		}
		
		if (isStanding && !isSlashing) {
			isStanding = false;
			p.canMoveStack--;
		}
		
		if (cooldownCur > 0) {
			cooldownCur--;
			if (cooldownCur == 0) {
				canStartStack--;
			}
		}
	},

	draw: function() {
		
	}
}

#endregion

#region Execution slash

executionPip = 0;
executionPipNew = 0;
hasExecuted = false;
willOverkill = false;
executionFrames = 124;
execuitionFramesCur = 0;
blinkingExecFrames = 35;

function applyExecutionPips() {
	if (executionPip = 0) return 0;
	var a = executionPip;
	hasExecuted = true;
	return a;
}

function queueOverkill(a) {
	executionPipNew = a;
	willOverkill = true;
}

blend = c_white;
greatSlash = {
	p: other,
	isSlashing: false,
	canStartSwitch: true,
	canStartStack: 0,
	animationSprite: spr_daggerSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 0,
	cooldownInit: 0,
	cooldownCur: 0,
	hasHit: false,
	actionObj: undefined,
	soundDelayFrames: 0,
	soundDelayFramesCur: 0,
	
	holdFrames: 28,
	holdFramesCur: 0,
	isHolded: false,
	
	execDmg: 0,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI) {
		execDmg = p.applyExecutionPips();
		if (canStartStack == 0 && !isSlashing && !p.slide.isSliding) {
			p.isDoingAction = true;
			p.ifPhysics.isManaged = false;
			p.healing.canStartStack++;
			p.slide.canSlideStack++;
			p.slash.canStartStack++;
			p.diveSlash.canStartStack++;
			
			isSlashing = true;
			canStartStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI)*1;
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			damage = 3;
			cooldownCur = cooldownI;
			cooldownInit = cooldownI;
			hasHit = false;
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, HlthInterface.map, true);
			obj_player.canMove = false;
			obj_player.selfDrawer.startAnimation_slashGreat();
			
			soundDelayFramesCur = 0;
		}
	},
	
	hitFunction: function(instI) {
		var curDmg = damage+execDmg;
		p.applyBlink(curDmg, instI, p.lastDirection);
		var prevHealth = instI.hlthInterface.hlth;
		instI.hlthInterface.receiveDamage(curDmg);
		var overkillDmg = clamp(damage - prevHealth, 0, 2);
		p.executionPip = overkillDmg;
		if (overkillDmg > 0) {
			p.queueOverkill(overkillDmg);
		}
		CameraManager.setPush(2, 90+p.lastDirection*90);
	},
	
	stop: function() {
		p.isDoingAction = false;
		p.ifPhysics.isManaged = true;
		p.healing.canStartStack--;
		p.slide.canSlideStack--;
		p.slash.canStartStack--;
		p.diveSlash.canStartStack--;
		
		isSlashing = false;
		canJump = true;
		ActionObjectManagers.slash.stop(actionObj);
		cleanup();
	},
	
	cleanup: function() {
		
	},
	
	tick: function() {
		
		if (InputManager.isInputActivated(input_ID.primaryUse) && (PlayerManager.charge >= 4 || p.executionPip != 0)) {
			holdFramesCur++;
			if (holdFramesCur >= holdFrames && !isHolded) {
				isHolded = true;
				p.blend = c_purple;
				audio_play_sound(snd_chargeAtt, 0, false);
			}
		}else {
			holdFramesCur = 0;
			if (isHolded) {
				if (PlayerManager.charge >= 4 || p.executionPip != 0) {
					p.blend = c_white;
					start(spr_daggerSlash, 1, 6, spr_greatSlashCollision, 1, 18);
					if (p.executionPip == 0) PlayerManager.charge -= 4;
				}
				p.blend = c_white;
				isHolded = false;
			}
		}
		
		if (isSlashing) {
			p.ifPhysics.hSpd = 0;
			p.ifPhysics.vSpd = 0;
			if (soundDelayFramesCur == soundDelayFrames) {
				audio_play_sound(snd_slashSwipeGreat, 0, false);
				soundDelayFramesCur++;
			}else soundDelayFramesCur++;
			
			obj_player.selfDrawer.setFrameByRatio(currentFrame/frameAmount);
			currentFrame++;
			if (currentFrame == frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
		}
		
		if (cooldownCur > 0) {
			cooldownCur--;
			if (cooldownCur == 0) {
				canStartStack--;
			}
		}
	},

	draw: function() {
		
	}
}

#endregion

#region Dive slash

diveSlash = {
	p: other,
	isSlashing: false,
	canStartSwitch: true,
	canStartStack: 0,
	animationSprite: spr_daggerSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 0,
	cooldownInit: 0,
	cooldownCur: 0,
	hasHit: false,
	actionObj: undefined,
	soundDelayFrames: 1,
	soundDelayFramesCur: 0,
	
	isStanding: false,
	
	isDiving: false,
	diveSpd: 28,
	
	initPos: undefined,
	buffHeight: 170,
	buffDmg: 1,
	
	startDive: function() {
		execDmg = p.applyExecutionPips();
		initPos = p.y;
		isDiving = true;
		p.ifPhysics.doesGrv = false;
		p.ifPhysics.hSpd = 0;
		p.ifPhysics.vSpd = diveSpd;
		p.canMoveStack++;
		p.greatSlash.canStartStack++;
		p.slash.canStartStack++;
		p.isDoingAction = true;
	},
	startDiveDirectioned: function() {
		execDmg = p.applyExecutionPips();
		initPos = p.y;
		isDiving = true;
		p.ifPhysics.doesGrv = false;
		p.ifPhysics.hSpd = 7*p.lastDirection;
		p.ifPhysics.vSpd = diveSpd;
		p.canMoveStack++;
		p.greatSlash.canStartStack++;
		p.slash.canStartStack++;
		p.isDoingAction = true;
	},
	stopDive: function() {
		p.iFramesCur = 14;
		audio_play_sound(snd_s, 0, false);
		isDiving = false;
		p.ifPhysics.doesGrv = true;
		var curDmg = 2;
		if (p.y - initPos >= buffHeight) {
			curDmg += buffDmg;
			audio_play_sound(snd_sex, 0, false);
		}
		start(spr_daggerSlash, 1, 6, spr_diveCollision, curDmg, 18);
	},

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI) {
		p.slideSlash.repulsionFramesCur = p.slideSlash.repulsionFrames;
		p.canBeRepulsedStack++;
		if (canStartStack == 0 && !isSlashing && !p.slide.isSliding) {
			p.healing.canStartStack++;
			p.slide.canSlideStack++;
			
			isSlashing = true;
			canStartStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			damage = damageI;
			cooldownCur = cooldownI;
			cooldownInit = cooldownI;
			hasHit = false;
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, HlthInterface.map, false);
			obj_player.canMove = false;
			obj_player.selfDrawer.startAnimation_diveSlash();
			
			soundDelayFramesCur = 0;
		}
	},
	
	hitFunction: function(instI) {
		var curDmg = damage+execDmg;
		p.applyBlink(curDmg, instI, sign(instI.x-p.x));
		instI.hlthInterface.receiveDamage(curDmg);
		if (PlayerManager.charge > PlayerManager.chargeMax) PlayerManager.charge = PlayerManager.chargeMax;
		CameraManager.setPush(2, 90+p.lastDirection*90);
	},
	
	stop: function() {
		p.isDoingAction = false;
		p.healing.canStartStack--;
		p.slide.canSlideStack--;
		p.canMoveStack--;
		p.greatSlash.canStartStack--;
		p.slash.canStartStack--;
		
		isSlashing = false;
		canJump = true;
		ActionObjectManagers.slash.stop(actionObj);
		cleanup();
	},
	
	cleanup: function() {
		
	},
	
	tick: function() {
		if ((PlayerManager.charge >= 4 || p.executionPip != 0) && canStartStack == 0 && InputManager.isInputActivated(input_ID.primaryUseI) && InputManager.isInputActivated(input_ID.down) && !PlayerManager.isDead) {
			if (!isDiving) {
				if (p.executionPip == 0) PlayerManager.charge -= 4;
				if (!InputManager.isInputActivated(input_ID.left) && !InputManager.isInputActivated(input_ID.right)) startDive();
				else startDiveDirectioned();
			}
		}
		
		if (isDiving && p.ifPhysics.isCollidingDown) {
			stopDive();
		}
		
		if (isSlashing) {
			if (soundDelayFramesCur == soundDelayFrames) {
				soundDelayFramesCur++;
			}else soundDelayFramesCur++;
			
			obj_player.selfDrawer.setFrameByRatio(currentFrame/frameAmount);
			currentFrame++;
			if (currentFrame >= frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
			
			if (p.ifPhysics.isCollidingDown && !isStanding) {
				isStanding = true;
				p.canMoveStack++;
			}else if (isStanding && !p.ifPhysics.isCollidingDown) {
				isStanding = false;
				p.canMoveStack--;
			}
		}
		
		if (isStanding && !isSlashing) {
			isStanding = false;
			p.canMoveStack--;
		}
		
		if (cooldownCur > 0) {
			cooldownCur--;
			if (cooldownCur == 0) {
				canStartStack--;
			}
		}
	},

	draw: function() {
		
	}
}

#endregion

#region Slide slash

slideSlash = {
	p: other,
	isSlashing: false,
	canStartSwitch: true,
	canStartStack: 0,
	animationSprite: spr_daggerSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 0,
	cooldownInit: 0,
	cooldownCur: 0,
	hasHit: false,
	actionObj: undefined,
	actionObjSingle: undefined,
	soundDelayFrames: 1,
	soundDelayFramesCur: 0,
	
	repulsionFrames: 30,
	repulsionFramesCur: 0,
	
	cock: false,
	
	willSlash: false,
	
	isStanding: false,
	
	hspdBoost: 11,
	
	peakSpd: 0,
	peakFrames: 6,
	peakFramesCur: 0,
	buffSpd: 12,
	
	pipDmg: undefined,
	
	firstHitInst: undefined,
	
	isBuffed: undefined,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI) {
		p.isDoingAction = true;
		p.iFramesCur = 20;
		var isDoing = false;
		if (abs(peakSpd) < buffSpd) {
			var curDir = p.lastDirection
		}else {
			var curDir = sign(peakSpd);
			isDoing = true;
		}
		pipDmg = p.applyExecutionPips();
		
		if (p.slide.isSliding) p.slide.stop();
		if_physics.setPosition(p.ifPhysics, p.x+curDir*40, p.y);
		
		if (!isDoing) {
			isBuffed = false;
			if_physics.setHSpeed(p.ifPhysics, curDir*hspdBoost);
		}else {
			isBuffed = true;
			if_physics.setHSpeed(p.ifPhysics, peakSpd);
			audio_play_sound(snd_superDash, 0, false);
		}
		
		repulsionFramesCur = repulsionFrames;
		p.canBeRepulsedStack++;
		
		if (canStartStack == 0 && !isSlashing) {
			p.healing.canStartStack++;
			p.slide.canSlideStack++;
			p.slash.canStartStack++;
			
			isSlashing = true;
			canStartStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			damage = damageI;
			cooldownCur = cooldownI;
			cooldownInit = cooldownI;
			hasHit = false;
			actionObjSingle = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction2, HlthInterface.map, true);
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, HlthInterface.map, false);
			obj_player.canMove = false;
			obj_player.selfDrawer.startAnimation_slideSlash();
			
			soundDelayFramesCur = 0;
		}
	},
	
	hitFunction: function(instI) {
		if (instI != firstHitInst) {
			var curDmg = damage+pipDmg+isBuffed*2;
			p.applyBlink(curDmg, instI, p.lastDirection);
			instI.hlthInterface.receiveDamage(curDmg);
			CameraManager.setPush(2, 90+p.lastDirection*90);
		}
	},
	
	hitFunction2: function(instI) {
		var curDmg = damage+pipDmg+1+isBuffed;
		p.applyBlink(curDmg, instI, p.lastDirection);
		instI.hlthInterface.receiveDamage(curDmg);
		CameraManager.setPush(2, 90+p.lastDirection*90);
		firstHitInst = instI;
	},
	
	stop: function() {
		p.isDoingAction = false;
		p.healing.canStartStack--;
		p.slide.canSlideStack--;
		p.slash.canStartStack--;
		
		isSlashing = false;
		canJump = true;
		ActionObjectManagers.slash.stop(actionObj);
		ActionObjectManagers.slash.stop(actionObjSingle);
		cleanup();
	},
	
	cleanup: function() {
		
	},
	
	tick: function() {
		if (repulsionFramesCur >= 0) {
			repulsionFramesCur--;
			if (repulsionFramesCur == 0) p.canBeRepulsedStack--;
		}
		
		if ((PlayerManager.charge >= 4 || p.executionPip != 0) && canStartStack == 0 && InputManager.isInputActivated(input_ID.primaryUseI) && InputManager.isInputActivated(input_ID.dashHold) && !PlayerManager.isDead) {
			start(spr_daggerSlash, 1, 6, spr_slideSlashCollision, 1, 18);
			if (p.executionPip == 0) PlayerManager.charge -= 4;
		}
		
		if (isSlashing) {
			if (soundDelayFramesCur == soundDelayFrames) {
				audio_play_sound(snd_slideufck, 0, false);
				soundDelayFramesCur++;
			}else soundDelayFramesCur++;
			
			obj_player.selfDrawer.setFrameByRatio(currentFrame/frameAmount);
			currentFrame++;
			if (currentFrame == frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObjSingle, currentFrame);
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
			
			if (p.ifPhysics.isCollidingDown && !isStanding) {
				isStanding = true;
				p.canMoveStack++;
			}else if (isStanding && !p.ifPhysics.isCollidingDown) {
				isStanding = false;
				p.canMoveStack--;
			}
		}
		
		if (isStanding && !isSlashing) {
			isStanding = false;
			p.canMoveStack--;
		}
		
		if (cooldownCur > 0) {
			cooldownCur--;
			if (cooldownCur == 0) {
				canStartStack--;
			}
		}
	},

	draw: function() {
		
	}
}

#endregion

#region Shooting

queuedBlink = false;
queuedBlinkDmg = undefined;
queuedBlinkY = undefined;
queuedBlinkX = undefined;
queuedBlinkDir = undefined;
function applyBlink(dmgI, instI, dirI) {
	if (shot.isEnemyBlinkWindow && instI == shot.blinkedEnemy) {
		queuedBlinkDir = dirI;
		queuedBlinkY = shot.blinkedEnemy.y;
		if (lastDirection == 1) {
			queuedBlinkX = shot.blinkedEnemy.bbox_right;
		}
		else {
			queuedBlinkX = shot.blinkedEnemy.bbox_left;
		}
		queuedBlinkDmg = dmgI;
		queuedBlink = true;
	}
}

hasShotDebug = false;
shot = {
	_p: other,
	
	canStartStack: 0,
	isBeingDone: false,
	isDelaying: false, delayFrames: 19, delayFramesCur: 0,
	isResting: false, restFrames: 20, restFramesCur: 0,
	hitIsThere: false,
	shotSpr: spr_shotOrigin,
	hitSpr: spr_shotHit, hitX: undefined, hitY: undefined, hitDir: undefined,
	hitLifetime: 12, hitLifetimeCur: 0,
	pierces: 2, piercesCur: 0,
	secondPiercePenalty: 1,
	execDmg: 0,
	blinkFrames: 60,
	blinkFramesInit: 10,
	blinkFramesCur: 60,
	isBlinkWindow: false,
	blinkWindowFrames: 12,
	blinkWindowFramesCur: 12,
	
	isBlinkingEnemy: false,
	blinkedEnemy: undefined,
	enemyBlinks: 3,
	enemyBlinksCur: 3,
	enemyBlinkFramesCur: 70,
	enemyBlinkFrames: 70,
	isEnemyBlinkWindow: false,
	enemyBlinkWindowFrames: 17,
	enemyBlinkWindowFramesCur: 17,
	
	doneInFrame: false,
	
	blink: function() {
		isBlinkWindow = true;
		blinkWindowFramesCur = blinkWindowFrames;
		blinkFramesCur = blinkFrames;
		audio_play_sound(snd_blink, 0, false);
	},
	
	shotEvent: {
		_p: obj_player,
		_action: undefined,
		notifiesEnd: false,
		curY: undefined,
		curDir: undefined,
		hitInstances: ds_map_create(),
		notifyCollisionInst: function(instI) {
			if (
				!ds_map_exists(hitInstances, instI.id) &&
				HlthInterface.hasInstance(instI.id)
			) {
				ds_map_add(hitInstances, instI.id, undefined);
				if (_action.isBlinkWindow) {
					_action.blinkedEnemy = instI;
					_action.isBlinkingEnemy = true;
					_action.enemyBlinkFramesCur = _action.enemyBlinkFrames;
					_action.enemyBlinksCur = _action.enemyBlinks;
					PlayerManager.charge += 2;
					if (PlayerManager.charge >= PlayerManager.chargeMax) PlayerManager.charge = PlayerManager.chargeMax;
					notifiesEnd = true;
					instI.hlthInterface.receiveDamage(1+_action.execDmg);
				}else {
					var curDmg = 1+_action.execDmg+(_action.piercesCur == 0 ? 1 : 0);
					_p.applyBlink(curDmg, instI, _p.lastDirection);
					instI.hlthInterface.receiveDamage(curDmg);
					_action.piercesCur++;
					if (_action.piercesCur == _action.pierces) notifiesEnd = true;
				}
			}
		},
		notifyCollisionBlock: function(colTypeI) {
			if (colTypeI == collisionType_normal) notifiesEnd = true;
			else if (_p.lastDirection == 1 && colTypeI == collisionType_onewayLeft) notifiesEnd = true;
			else if (_p.lastDirection == -1 && colTypeI == collisionType_onewayRight) notifiesEnd = true;
		},
		notifyHoriHitscanEnd: function(finalXI) {
			_action.createHit(finalXI, curY, curDir);
			var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_shotTrail);
			newLaserTrail.initialize(_p.x, _p.y, _p.lastDirection, 0, abs(finalXI-_p.x), c_yellow);
			_action.execDmg = 0;
		},
		notifyVertHitscanEnd: function(finalYI) {
			
		},
		initialize: function() {
			_action = _p.shot;
		}
	},
	blinkShotEvent: {
		initInst: undefined,
		dmg: undefined,
		_p: obj_player,
		_action: undefined,
		notifiesEnd: false,
		curY: undefined,
		curDir: undefined,
		notifyCollisionInst: function(instI) {
			if (
				HlthInterface.hasInstance(instI.id) &&
				(!instance_exists(initInst) ||
				instI.id != initInst.id)
			) {
				if (instI.hlthInterface.hlth - dmg > 0) {
					_action.blinkedEnemy = instI;
					_action.isBlinkingEnemy = true;
					_action.enemyBlinkFramesCur = _action.enemyBlinkFrames;
					_action.enemyBlinksCur = _action.enemyBlinks;
				}
				show_debug_message("Why???????");
				instI.hlthInterface.receiveDamage(dmg);
				notifiesEnd = true;
			}
		},
		notifyCollisionBlock: function(colTypeI) {
			if (colTypeI == collisionType_normal) notifiesEnd = true;
			else if (_p.queuedBlinkDir == 1 && colTypeI == collisionType_onewayLeft) notifiesEnd = true;
			else if (_p.queuedBlinkDir == -1 && colTypeI == collisionType_onewayRight) notifiesEnd = true;
		},
		notifyHoriHitscanEnd: function(finalXI) {
			_action.createHit(finalXI, curY, curDir);
			var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_shotTrail);
			newLaserTrail.initialize(_p.x, _p.y, _p.queuedBlinkDir, 0, abs(finalXI-_p.x), c_fuchsia);
			_action.execDmg = 0;
		},
		notifyVertHitscanEnd: function(finalYI) {
			
		},
		initialize: function() {
			_action = _p.shot;
		}
	},
	start: function() {
		if (!isBeingDone) {
			doneInFrame = true;
			_p.isDoingAction = true;
			isBeingDone = true;
			isDelaying = true;
			delayFramesCur = delayFrames;
			_p.canMoveStack++;
		}
	},
	shoot: function() {
		if (execDmg == 0) PlayerManager.charge -= 4;
		shotEvent.notifiesEnd = false;
		shotEvent.curY = _p.y;
		shotEvent.curDir =  _p.lastDirection;
		piercesCur = 0;
		ds_map_clear(shotEvent.hitInstances);
		ActionObjectManagers.hitscan.start(_p.x, _p.y, _p.lastDirection, 0, shotEvent);
		audio_play_sound(snd_playerShot, 0, false);
		if (isBlinkWindow) audio_play_sound(snd_blinkSuper, 0, false);
		isBlinkWindow = false;
	},
	stop: function() {
		_p.isDoingAction = false;
		isBeingDone = false;
		_p.canMoveStack--;
	},
	createHit: function(xI, yI, dirI) {
		hitIsThere = true;
		hitLifetimeCur = hitLifetime;
		hitX = xI; hitY = yI;
		hitDir = dirI;
	},
	tick: function() {
		doneInFrame = false;
		if (!_p.downwardsShot.doneInFrame && !isBeingDone && canStartStack == 0 && (PlayerManager.charge >= 4 || _p.executionPip != 0) && InputManager.isInputActivated(input_ID.secondaryUseI) && !PlayerManager.isDead) {
			if (_p.executionPip != 0) execDmg = _p.applyExecutionPips();
			obj_player.shot.start();
			blinkFramesCur = blinkFramesInit;
		}
		
		if (isEnemyBlinkWindow) {
			enemyBlinkWindowFramesCur--;
			if (enemyBlinkWindowFramesCur == 0) {
				if (!isBlinkingEnemy) {
					blinkedEnemy = undefined;
				}
				isEnemyBlinkWindow = false;
			}
		}
		
		if (isBlinkingEnemy) {
			enemyBlinkFramesCur--;
			if (enemyBlinkFramesCur <= 0) {
				audio_play_sound(snd_blink, 0, false, 1.0, 0, 1.0-((enemyBlinks-enemyBlinksCur)*0.06));
				enemyBlinksCur--;
				if (enemyBlinksCur == 0) {
					isBlinkingEnemy = false;
				}
				enemyBlinkFramesCur = enemyBlinkFrames;
				enemyBlinkWindowFramesCur = enemyBlinkWindowFrames;
				isEnemyBlinkWindow = true;
			}
		}
		
		if (isDelaying) {
			
			if (isBlinkWindow) {
				blinkWindowFramesCur--;
				if (blinkWindowFramesCur == 0) isBlinkWindow = false;
			}
			
			if (delayFramesCur > 0) delayFramesCur--;
			else {
				blinkFramesCur--;
				if (blinkFramesCur <= 0) {
					blink();
				}
			}
			if (delayFramesCur == 0 && !InputManager.isInputActivated(input_ID.secondaryUse)) {
				shoot();
				isDelaying = false;
				isResting = true;
				restFramesCur = restFrames;
			}
		}else if (isResting) {
			restFramesCur--;
			if (restFramesCur == 0) {
				isResting = false;
				stop();
			}
		}
		
		if (hitIsThere) {
			hitLifetimeCur--;
			if (hitLifetimeCur == 0) {
				hitIsThere = false;
			}
		}
	},
	draw: function() {
		if (hitIsThere) {
			var sprFrameAmount = sprite_get_number(hitSpr);
			draw_sprite_ext(hitSpr, floor((1-hitLifetimeCur/hitLifetime)*sprFrameAmount), hitX, hitY, hitDir, 1.0, 0, c_white, 1.0);
			sprFrameAmount = sprite_get_number(shotSpr);
			draw_sprite_ext(shotSpr, floor((1-hitLifetimeCur/hitLifetime)*sprFrameAmount), _p.x, _p.y, hitDir, 1.0, 0, c_white, 1.0);
		}
	},
	initialize: function() {
		shotEvent.initialize();
		blinkShotEvent.initialize();
	}
}
shot.initialize();

#endregion

#region Roll slash

rollSlash = {
	
	p: other,
	isSlashing: false,
	canStartSwitch: true,
	canStartStack: 0,
	animationSprite: spr_daggerSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	damage: 0,
	cooldownInit: 0,
	cooldownCur: 0,
	hasHit: false,
	actionObj: undefined,
	soundDelayFrames: 1,
	soundDelayFramesCur: 0,
	
	willSlash: false,
	
	isStanding: false,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI, isDirectionedI) {
		if (canStartStack == 0 && !isSlashing && !p.slide.isSliding) {
			p.isDoingAction = true;
			p.healing.canStartStack++;
			p.slide.canSlideStack++;
			
			isSlashing = true;
			canStartStack++;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			damage = damageI;
			cooldownCur = cooldownI;
			cooldownInit = cooldownI;
			hasHit = false;
			if (!isDirectionedI) {
				obj_player.selfDrawer.startAnimation_rollSlash();
				actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, HlthInterface.map, true);
			}else {
				obj_player.selfDrawer.startAnimation_rollSlashDir();
				actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunctionDirectioned, HlthInterface.map, true);
			}
			obj_player.canMove = false;
			
			soundDelayFramesCur = 0;
		}
	},
	
	hitFunction: function(instI) {
		instI.hlthInterface.receiveDamage(2);
		audio_play_sound(snd_boing2, 0, false);
		if_physics.setVSpeed(p.ifPhysics, -6);
		CameraManager.setPush(2, 90+p.lastDirection*90);
	},
	
	hitFunctionDirectioned: function(instI) {
		instI.hlthInterface.receiveDamage(damage);
		audio_play_sound(snd_boing, 0, false);
		if_physics.setVSpeed(p.ifPhysics, -5);
		if_physics.setHSpeed(p.ifPhysics, 0);
		PlayerManager.charge += 1;
		if (PlayerManager.charge > PlayerManager.chargeMax) PlayerManager.charge = PlayerManager.chargeMax;
		CameraManager.setPush(2, 90+p.lastDirection*90);
		p.roll.stop();
	},
	
	stop: function() {
		p.isDoingAction = false;
		p.healing.canStartStack--;
		p.slide.canSlideStack--;
		
		isSlashing = false;
		canJump = true;
		ActionObjectManagers.slash.stop(actionObj);
		cleanup();
	},
	
	cleanup: function() {
		
	},
	
	tick: function() {
		if (canStartStack == 0 && !p.diveSlash.isDiving && !p.slideSlash.isSlashing && !InputManager.isInputActivated(input_ID.down) && InputManager.isInputActivated(input_ID.primaryUseI) && p.roll.isBeingDone) {
			start(spr_daggerSlash, 1, 6, spr_playerRollSlashCollisionDir, 2, 12, true);
		}
		
		if (isSlashing) {
			if (soundDelayFramesCur == soundDelayFrames) {
				if (random_by_fraction(1, 2)) audio_play_sound(snd_slashSwipe2, 0, false);
				else audio_play_sound(snd_slashSwipe1, 0, false);
				soundDelayFramesCur++;
			}else soundDelayFramesCur++;
			
			obj_player.selfDrawer.setFrameByRatio(currentFrame/frameAmount);
			currentFrame++;
			if (currentFrame == frameAmount) {
				stop();
			}else {
				ActionObjectManagers.slash.setFrame(actionObj, currentFrame);
			}
		}
		
		if (cooldownCur > 0) {
			cooldownCur--;
			if (cooldownCur == 0) {
				canStartStack--;
			}
		}
	}
}

#endregion

impulseShot = {
	_p: other,
	
	start: function(hSpdI, vSpdI) {
		if (_p.slide.isSliding) _p.slide.stop();
		_p.roll.start();
		if_physics.setVSpeed(_p.ifPhysics, vSpdI);
		if_physics.setHSpeed(_p.ifPhysics, _p.ifPhysics.hSpd+hSpdI);
	},
	start2: function(hSpdI, vSpdI) {
		if (_p.slide.isSliding) _p.slide.stop();
		_p.roll.start();
		if_physics.setVSpeed(_p.ifPhysics, vSpdI);
		if_physics.setHSpeed(_p.ifPhysics, hSpdI);
	},
	start3: function(hSpdI, vSpdI) {
		if (_p.slide.isSliding) _p.slide.stop();
		if_physics.setVSpeed(_p.ifPhysics, vSpdI);
		if_physics.setHSpeed(_p.ifPhysics, _p.ifPhysics.hSpd+hSpdI);
	},
	tick: function() {
		
	}
}

#region Downwards shot

downwardsShot = {
	_p: other,
	canStartStack: 0,
	isBeingDone: false,
	doneInFrame: false,
	execDmg: 0,
	shotEvent: {
		_p: obj_player,
		_action: undefined,
		notifiesEnd: false,
		curX: undefined,
		curDir: undefined,
		hitInstances: ds_map_create(),
		notifyCollisionInst: function(instI) {
			if (
				!ds_map_exists(hitInstances, instI.id) &&
				HlthInterface.hasInstance(instI.id)
			) {
				var curDmg = 2+_action.execDmg;
				_p.applyBlink(curDmg, instI, _p.lastDirection);
				
				_action.sideShotEvent.notifiesEnd = false;
				_action.sideShotEvent.initX = instI.bbox_right;
				_action.sideShotEvent.curY = instI.y;
				_action.sideShotEvent.curDir = 1;
				ActionObjectManagers.hitscan.start(instI.bbox_right, instI.y, 1, 0, _action.sideShotEvent);
				
				_action.sideShotEvent.notifiesEnd = false;
				_action.sideShotEvent.initX = instI.bbox_left;
				_action.sideShotEvent.curY = instI.y;
				_action.sideShotEvent.curDir = -1;
				ActionObjectManagers.hitscan.start(instI.bbox_left, instI.y, -1, 0, _action.sideShotEvent);
				
				instI.hlthInterface.receiveDamage(curDmg);
				notifiesEnd = true;
			}
		},
		notifyCollisionBlock: function(colTypeI) {
			if (colTypeI == collisionType_normal || colTypeI == collisionType_onewayUp) notifiesEnd = true;
		},
		notifyVertHitscanEnd: function(finalYI) {
			var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_shotTrail);
			newLaserTrail.initialize(_p.x, _p.y, 0, 1, abs(finalYI-_p.y), c_yellow);
		},
		initialize: function() {
			_action = _p.downwardsShot;
		}
	},
	sideShotEvent: {
		_p: obj_player,
		_action: undefined,
		notifiesEnd: false,
		curY: undefined,
		initX: undefined,
		curDir: undefined,
		hitInstances: ds_map_create(),
		curDir: undefined,
		notifyCollisionInst: function(instI) {
			if (
				!ds_map_exists(hitInstances, instI.id) &&
				HlthInterface.hasInstance(instI.id)
			) {
				var curDmg = 1+_action.execDmg;
				_p.applyBlink(curDmg, instI, curDir);
				instI.hlthInterface.receiveDamage(curDmg);
				notifiesEnd = true;
			}
		},
		notifyCollisionBlock: function(colTypeI) {
			if (colTypeI == collisionType_normal) notifiesEnd = true;
			else if (curDir == 1 && colTypeI == collisionType_onewayLeft) notifiesEnd = true;
			else if (curDir == -1 && colTypeI == collisionType_onewayRight) notifiesEnd = true;
		},
		notifyHoriHitscanEnd: function(finalXI) {
			var newLaserTrail = instance_create_layer(0, 0, GameplayManager.layerArray[layers.entities], obj_shotTrail);
			newLaserTrail.initialize(initX, curY, curDir, 0, abs(finalXI-initX), c_yellow);
		},
		initialize: function() {
			_action = _p.downwardsShot;
		}
	},
	startBase: function () {
		
	},
	start: function() {
		startBase();
		audio_play_sound(snd_weakShot, 0, false);
		isBeingDone = true;
		_p.impulseShot.start2((max(abs(_p.ifPhysics.hSpd), 9))*_p.lastDirection, -7);
	},
	startStrong: function() {
		startBase();
		doneInFrame = true;
		execDmg = _p.applyExecutionPips();
		shotEvent.notifiesEnd = false;
		shotEvent.curX = _p.x;
		shotEvent.curDir =  _p.lastDirection;
		ds_map_clear(shotEvent.hitInstances);
		ActionObjectManagers.hitscan.start(_p.x, _p.y, 0, 1, shotEvent);
		execDmg = 0;
		
		audio_play_sound(snd_playerShot, 0, false);
		_p.isHoldingJump = false;
		_p.impulseShot.start3(_p.lastDirection*1, -7);
	},
	stop: function() {
		isBeingDone = false;
	},
	tick: function() {
		doneInFrame = false;
		if (!_p.isDoingAction && canStartStack == 0 && InputManager.isInputActivated(input_ID.down) && InputManager.isInputActivated(input_ID.secondaryUseI)) {
			if (_p.ifPhysics.isCollidingDown) {
				if (PlayerManager.charge >= 2 || _p.executionPip > 0 || _p.roll.rollEndFramesCur > 0) {
					start();
					if (_p.roll.rollEndFramesCur == 0 && _p.executionPip == 0) PlayerManager.charge -= 2;
				}
			}else {
				if (PlayerManager.charge >= 4 || _p.executionPip > 0) {
					startStrong();
					if (_p.executionPip == 0) PlayerManager.charge -= 4;
				}
			}
		}
		if (isBeingDone && !_p.roll.isBeingDone) {
			stop();
		}
	},
	initialize: function() {
		shotEvent.initialize();
		sideShotEvent.initialize();
	}
}
downwardsShot.initialize();

#endregion

#region Slide shot

slideShot = {
	_p: other,
	canStartStack: 0,
	isBeingDone: false,
	start: function() {
		audio_play_sound(snd_playerShot, 0, false);
		isBeingDone = true;
		_p.lastDirection *= -1;
		_p.impulseShot.start2(-1 * _p.ifPhysics.hSpd, -7);
	},
	tick: function() {
		/*if (!_p.isDoingAction && canStartStack == 0 && !_p.roll.isBeingDone && _p.ifPhysics.isCollidingDown && !InputManager.isInputActivated(input_ID.down) && InputManager.isInputActivated(input_ID.secondaryUseI) && _p.slide.isSliding) {
			if (PlayerManager.charge >= 2) {
				start();
				PlayerManager.charge -= 2;
			}
		}*/
		if (isBeingDone && !_p.roll.isBeingDone) {
			isBeingDone = false;
		}
	}
}

#endregion

#region

roll = {
	_p: other,
	isBeingDone: false,
	rollEndFrames: 8,
	rollEndFramesCur: 0,
	start: function() {
		if (!isBeingDone) {
			_p.slash.canStartStack++;
			_p.shot.canStartStack++;
			
			_p.canMoveStack++;
			_p.shot.canStartStack++;
			isBeingDone = true;
		
			_p.ifPhysics.doesFriction = false;
			_p.canBeRepulsedStack++;
		}
	},
	stop: function() {
		_p.slash.canStartStack--;
		_p.shot.canStartStack--
		
		_p.canMoveStack--;
		_p.shot.canStartStack--;
		isBeingDone = false;
		rollEndFramesCur = rollEndFrames;
		_p.ifPhysics.doesFriction = true;
		_p.canBeRepulsedStack--;
	},
	tick: function() {
		if (rollEndFramesCur > 0) {
			rollEndFramesCur--;
		}
		if (isBeingDone && _p.ifPhysics.isCollidingDown) {
			stop();
		}
	}
}

#endregion

#region Sliding

slide = {
	p: other,
	canSlideSwitch: false,
	canSlideStack: 0,
	isSliding: false,
	spd: 6,
	start: function() {
		isSliding = true;
		p.canMoveStack++;
		trailCooldownFramesCur = 0;
		if (abs(p.ifPhysics.hSpd) < spd) if_physics.setHSpeed(p.ifPhysics, p.lastDirection*spd);
		p.ifPhysics.doesFriction = false;
		p.canChangeDirection = false;
		p.slash.canStartStack++;
	},
	stop: function() {
		isSliding = false;
		p.canMoveStack--;
		if_physics.setHSpeed(p.ifPhysics, p.maxSpd*p.lastDirection);
		p.ifPhysics.doesFriction = true;
		p.canChangeDirection = true;
		p.slash.canStartStack--;
	},
	tick: function() {
		if (isSliding) {
			if_physics.targetMaxHSpeed(p.ifPhysics, p.lastDirection*spd, 10);
		}
		if (!p.ifPhysics.isCollidingDown) canSlideSwitch = false;
	},
	cleanup: function() {
		//ds_queue_destroy(trails);
	}
};

#endregion

#region Damage flashing

damageFlashing = {
	p: other,
	isDmgFlashing: false,
	durationFrames: 22,
	durationFramesCur: 0,
	flashCooldownFrames: 1,
	flashCooldownFramesCur: 0,
	curAlpha: 1.0,
	start: function() {
		if (isDmgFlashing) {
			stop();
		}
		durationFramesCur = durationFrames;
		isDmgFlashing = true;
	},
	stop: function() {
		isDmgFlashing = false;
	},
	tick: function() {
		if (isDmgFlashing) {
			if (flashCooldownFramesCur == 0) {
				flashCooldownFramesCur = flashCooldownFrames;
				if (curAlpha == 1.0) {
					curAlpha = 0.0;
				}else {
					curAlpha = 1.0;
				}
			}else {
				flashCooldownFramesCur--;
			}
			
			durationFramesCur--;
			if (durationFramesCur == 0) {
				stop();
			}
			p.image_alpha = curAlpha;
		}
	},
	draw: function() {
	}
}

#endregion

iFramesCur = 0;

