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

enum player_animationID {
	idle,
	walk,
	slash,
	slide,
	shoot
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
		startAnimation(player_animationID.slash, other.curSprSlide, true, 0);
	},
	startAnimation_slash: function() {
		startAnimation(player_animationID.slash, other.curSprSlash, false);
	},
	startAnimation_shoot: function() {
		startAnimation(player_animationID.shoot, other.curSprShoot, true, 2);
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
		if (!_p.slash.isSlashing) {
			if (_p.slide.isSliding) {if (curAnimID != player_animationID.slide) startAnimation_slide();}
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
		draw_sprite_ext(curSpr, curSprIndex, _p.x, _p.y, _p.lastDirection, 1.0, 0, c_white, 1.0);
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
jumpForce = -10.4;
coyoteFrames = 5;
coyoteFramesCur = coyoteFrames;

function jump() {
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
	healDelayFrames: 120,
	healDelayFramesCur: 0,
	barX1: -15,
	barY1: -25,
	barWidth: 30,
	barY2: -17,
	barFillColor: c_red,
	start: function() {
		isHealing = true;
		healDelayFramesCur = healDelayFrames;
		
		if (p.slide.isSliding) p.slide.stop();
		p.canMoveStack++;
		p.slide.canSlideStack++;
		p.canJumpStack++;
		p.slash.canStartStack++;
		canStartStack++;
	},
	applyHeal: function() {
		PlayerManager.useHlthPacket(1);
	},
	stop: function() {
		p.canMoveStack--;
		p.canJumpStack--;
		p.slide.canSlideStack--;
		p.slash.canStartStack--;
		canStartStack--;
		
		isHealing = false;
	},
	tick: function() {
		if (PlayerManager.hlthPacketCur == 0 || !p.ifPhysics.isCollidingDown) {
			canStartSwitch = false;
		}
		if (isHealing) {
			healDelayFramesCur--;
			if (healDelayFramesCur == 0) {
				applyHeal();
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

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, damageI, cooldownI) {
		if (canStartStack == 0 && !isSlashing && !p.slide.isSliding) {
			p.canJumpStack++;
			p.canMoveStack++;
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
		audio_play_sound(snd_enemyHit, 0, false, 0.3, 0, 0.9+random(0.1));
	},
	
	stop: function() {
		p.canMoveStack--;
		p.canJumpStack--;
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
	},

	draw: function() {
		
	}
}

#endregion

#region Shooting

hasShotDebug = false;
shot = {
	_p: other,
	isBeingDone: false,
	isDelaying: false, delayFrames: 30, delayFramesCur: 0,
	isResting: false, restFrames: 20, restFramesCur: 0,
	hitIsThere: false,
	shotSpr: spr_shotOrigin,
	hitSpr: spr_shotHit, hitX: undefined, hitY: undefined, hitDir: undefined,
	hitLifetime: 12, hitLifetimeCur: 0,
	shotEvent: {
		_p: obj_player,
		_action: undefined,
		notifiesEnd: false,
		curY: undefined,
		curDir: undefined,
		notifyCollisionInst: function(instI) {
			if (
				HlthInterface.hasInstance(instI.id)
			) {
				instI.hlthInterface.receiveDamage(2);
				notifiesEnd = true;
			}
		},
		notifyCollisionBlock: function(colTypeI) {
			if (colTypeI == collisionType_normal) notifiesEnd = true;
			else if (_p.lastDirection == 1 && colTypeI == collisionType_onewayLeft) notifiesEnd = true;
			else if (_p.lastDirection == -1 && colTypeI == collisionType_onewayRight) notifiesEnd = true;
		},
		notifyHoriHitscanEnd: function(finalXI) {
			_action.createHit(finalXI, curY, curDir);
		},
		notifyVertHitscanEnd: function(finalYI) {
			
		},
		initialize: function() {
			_action = _p.shot;
		}
	},
	start: function() {
		if (!isBeingDone) {
			isBeingDone = true;
			isDelaying = true;
			delayFramesCur = delayFrames;
			_p.canMoveStack++;
		}
	},
	shoot: function() {
		shotEvent.notifiesEnd = false;
		shotEvent.curY = _p.y;
		shotEvent.curDir =  _p.lastDirection;
		ActionObjectManagers.hitscan.start(_p.x, _p.y, _p.lastDirection, 0, shotEvent);
		audio_play_sound(snd_playerShot, 0, false);
	},
	stop: function() {
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
		if (isDelaying) {
			delayFramesCur--;
			if (delayFramesCur == 0) {
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
	}
}
shot.initialize();

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
		if_physics.setHSpeed(p.ifPhysics, p.lastDirection*spd);
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

