/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();
initialize(8, undefined);

notifyStunStart = function() {
	aiManager.canMoveStack++;
	if (attack.isDelaying) attack.stopDelay();
	attack.canBeDoneStack++;
}

notifyStunEnd = function() {
	aiManager.canMoveStack--;
	attack.canBeDoneStack--;
}

enum bear_aiModes { // OBSERVATION_ENEMY001: how should enemy enums be organized?
	slow,
	fast
}
aiManager = {
	_p: other,
	canMoveStack: 0,
	accSpd: 1,
	maxSpd: 1,
	slowMaxSpd: 1,
	fastMaxSpd: 3,
	curMode: bear_aiModes.slow,
	curChance: 1,
	initialChance: 1,
	chanceAddPerFrame: 0.01,
	step: function() {
		if (_p.detection.isDetecting && canMoveStack == 0) {
			if (irandom(600) <= curChance) {
				curMode = bear_aiModes.fast;
			}
			curChance += chanceAddPerFrame;
			
			if (curMode == bear_aiModes.slow) {
				PhysicsMonomanager.targetMaxSpeedToDirection(
					_p.physics, slowMaxSpd, accSpd, point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)
				);
			}else {
				curChance = initialChance;
				PhysicsMonomanager.targetMaxSpeedToDirection(
					_p.physics, fastMaxSpd, accSpd, point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)
				);
			}
		}
	}
}

slash = ActionObjectSubmanager.slash.construct(self);
notifySlashStop = function() {
	attack.startCooldown();
	stun.canBeStunnedStack++;
}

stun.canBeStunnedStack++;

attack = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 0,
	triggerDistance: 30,
	isDelaying: false,
	delayFrames: 16,
	delayFramesRunning: 22,
	delayFramesCur: 0,
	isInCooldown: false,
	cooldownFrames: 70,
	cooldownFramesCur: 0,
	direction: 0,
	dmg: 10,
	
	threatSound: audio_play_sound(snd_bearClose, 0, true, 0, 0, 1.0),
	soundDistance: 80,
	
	animationSpr: spr_bearAttack,
	animationSpeedFrames: 3,
	animationSpeedFramesCur: 0,
	animationFrame: 0,
	
	chargeAnimation: {
		_p: undefined,
		isBeingDone: false,
		sprite: spr_bearCharge,
		speedFrames: 2,
		speedFramesCur: 0,
		frame: 0,
		start: function() {
			isBeingDone = true;
			frame = 0;
			speedFramesCur = 0;
		},
		step: function() {
			if (isBeingDone) {
				speedFramesCur++;
				if (speedFramesCur == speedFrames) {
					speedFramesCur = 0;
					frame++;
					if (frame == sprite_get_number(sprite)) {
						stop();
					}
				}
			}
		},
		stop: function() {
			isBeingDone = false;
		},
		draw: function() {
			if (isBeingDone) draw_sprite(sprite, frame, _p.x, _p.y);
		}
	},
	
	slashHitFunction: function(instI) {
		PartySubmanager.damageCurrentMember(dmg);
	},
	
	startCooldown: function() {
		isInCooldown = true;
		cooldownFramesCur = cooldownFrames;
		_p.stun.canBeStunnedStack--;
		_p.aiManager.canMoveStack++;
	},
	stopCooldown: function() {
		isInCooldown = false;
		_p.stun.canBeStunnedStack++;
		_p.aiManager.canMoveStack--;
	},
	
	startDelay: function() {
		_p.stun.canBeStunnedStack--;
		audio_play_sound(snd_enemyDelay, 0, false, 2.0, 0, 0.9+random(0.2));
		isDelaying = true;
		chargeAnimation.start();
		//_p.stun.canBeStunnedStack++;
		delayFramesCur = (_p.aiManager.curMode == bear_aiModes.slow) ? delayFrames : delayFramesRunning;
		_p.aiManager.canMoveStack++;
		direction = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
	},
	
	stopDelay: function() {
		_p.stun.canBeStunnedStack++;
		isDelaying = false;
		//_p.stun.canBeStunnedStack--;
		_p.aiManager.canMoveStack--;
	},
	
	start: function() {
		isBeingDone = true;
		_p.dodge.cooldownFramesCur = _p.dodge.cooldownFrames;
		if (isDelaying) stopDelay();
		_p.stun.canBeStunnedStack--;
		_p.aiManager.curMode = bear_aiModes.slow;
		_p.aiManager.canMoveStack++;
		_p.dodge.canBeDoneStack++;
		var targetMap = ds_map_create();
		ds_map_add(targetMap, CURRENT_MEMBER_INST, pointer_null); // OBSERVATION_ACTIONOBJECT001: This will cause an error when the member type switches in the middle of the attack.
		_p.slash.startDefault(
			3,
			spr_bearAttack,
			direction,
			targetMap,
			slashHitFunction
		);
		animationSpeedFramesCur = 0;
		animationFrame = 0;
	},
	step: function() {
		if (_p.aiManager.curMode == bear_aiModes.fast && !isDelaying && !_p.slash.isBeingDone && _p.stun.isStunnedStack == 0 && !isInCooldown) audio_sound_gain(threatSound, max(0, 1-point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)/soundDistance)*0.6, 0);
		else audio_sound_gain(threatSound, 0, 0);
		
		if (isBeingDone) {
			animationSpeedFramesCur++;
			if (animationSpeedFramesCur == animationSpeedFrames) {
				animationSpeedFramesCur = 0;
				animationFrame++;
				if (animationFrame == sprite_get_number(animationSpr)) stop();
			}
		}
		
		if (isInCooldown) {
			if (_p.stun.isStunnedStack == 0) cooldownFramesCur--;
			if (cooldownFramesCur == 0) stopCooldown();
		}
		
		if (isDelaying) {
			delayFramesCur--;
			if (delayFramesCur == 0) {
				start();
			}
		}
		
		if (!isDelaying && !isInCooldown && canBeDoneStack == 0 && !isBeingDone && point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y) < triggerDistance) {
			startDelay();
		}
		
		chargeAnimation.step();
	},
	stop: function() {
		isBeingDone = false;
		_p.aiManager.canMoveStack--;
		_p.dodge.canBeDoneStack--;
	},
	draw: function() {
		if (isBeingDone) {
			draw_sprite_ext(
				animationSpr, animationFrame,
				_p.x, _p.y, 1.0, 1.0,
				_p.slash.direction,
				c_white, 1.0
			);
		}
		chargeAnimation.draw();
	}
}
attack.chargeAnimation._p = self;

dodge = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 1,
	isInCooldown: false,
	cooldownFrames: 200,
	cooldownFramesCur: 0,
	durationFrames: 30,
	durationFramesCur: 0,
	force: 6,
	angleAdd: 35,
	triggerDistance: 50,
	start: function() {
		audio_play_sound(snd_enemyDelay, 0, false, 2.0, 0, 0.9+random(0.2));
		//_p.stun.canBeStunnedStack++;
		isBeingDone = true;
		_p.aiManager.canMoveStack++;
		durationFramesCur = durationFrames;
		cooldownFramesCur = cooldownFrames;
		isInCooldown = true;
		
		var dodgeDirection = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
		dodgeDirection += choose(-1, 1)*angleAdd;
		_p.physics.hSpd = dcos(dodgeDirection)*force; // PHYSICS_OBSERVATION001
		_p.physics.vSpd = -dsin(dodgeDirection)*force; // PHYSICS_OBSERVATION001
	},
	stop: function() {
		isBeingDone = false;
		//_p.stun.canBeStunnedStack--;
		_p.aiManager.canMoveStack--;
	},
	step: function() {
		if (cooldownFramesCur > 0) {
			cooldownFramesCur--;
			if (cooldownFramesCur == 0) isInCooldown = false;
		}
		
		if (isBeingDone) {
			durationFramesCur--;
			if (durationFramesCur == 0) {
				_p.attack.direction = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
				_p.attack.start();
				stop();
			}
		}
		
		if (canBeDoneStack == 0 && _p.aiManager.curMode == bear_aiModes.slow && !isInCooldown && point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y) < triggerDistance) {
			start();
		}
	}
}
