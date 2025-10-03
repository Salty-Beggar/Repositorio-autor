/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

initialize(MEMBER_TYPE.chaincutter);

slash = ActionObjectSubmanager.slash.construct(self);
notifySlashStop = function() {
	slashCombo.notifySlashStop();
}

isMovingFastStack = 0;

slashCombo = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 0,
	
	// Combo
	isComboBeingDone: false,
	comboSize: 3,
	comboIndex: 0,
	
	isComboCoolingDown: false,
	comboSingleCooldownFrames: 21,
	comboSingleCooldownFramesCur: 0,
	comboCooldownFrames: 28,
	comboCooldownFramesCur: 0,
	
	comboGloryFrames: 30,
	comboGloryFramesCur: 0,
	
	clickFramesCur: 0,
	clickFrames: 8,
	
	// Animation
	animationSprites: [
		spr_playerChaincutterSlash,
		spr_playerChaincutterSlash,
		spr_playerChaincutterSlashLast
	],
	animationFlip: [
		1, -1, 1
	],
	animationSpr: spr_playerChaincutterSlash,
	animationSpeed: 2,
	animationSpeedCur: 0,
	animationFrame: 0,
	
	// Slash
	hasHit: false,
	slashDmg: [3, 3, 5],
	slashKnockback: [3, 3, 4.5],
	slashHeatBuildup: [1, 1, 2],
	
	slashHitFunction: function(instI) {
		if (!hasHit) {
			hasHit = true;
			/*_p.heat.value += slashHeatBuildup[comboIndex];
			if (_p.heat.value >= _p.heat.valueMax) _p.heat.value = _p.heat.valueMax;*/
		}
		
		if (instI.object_index == obj_archerArrow) {
			instI.deflect(_p.slash.direction);
			audio_play_sound(snd_bulletDeflection, 0, false, 1.0, 0, 0.9+random(0.2));
		}else {
			PhysicsMonomanager.setHSpeed(_p.physics, 0);
			PhysicsMonomanager.setVSpeed(_p.physics, 0);
			PhysicsMonomanager.applyKnockback(instI.physics, slashKnockback[comboIndex], _p.slash.direction);
			EnemySubmanager.damageEnemy(instI, slashDmg[comboIndex]);
			EnemySubmanager.stunEnemyTemporary(instI, 80);
		}
	},
	
	start: function() {
		hasHit = false;
		isBeingDone = true;
		_p.dash.canBeDoneStack++;
		animationSpeedCur = 0;
		animationFrame = 0;
		_p.movement.canBeDoneStack++;
		_p.canLeaveStack++;
		PhysicsMonomanager.setHSpeed(_p.physics, dcos(InputSubmanager.joystick2.returnDirection(_p))*4);
		PhysicsMonomanager.setVSpeed(_p.physics, -dsin(InputSubmanager.joystick2.returnDirection(_p))*4);
	},
	step: function() {
		if (isComboCoolingDown) {
			comboCooldownFramesCur--;
			if (comboCooldownFramesCur == 0) {
				stopCooldown();
			}
		}
		
		if (comboGloryFramesCur > 0) {
			comboGloryFramesCur--;
			if (comboGloryFramesCur == 0) {
				comboStop();
			}
		}
		
		if (isBeingDone) {
			animationSpeedCur++;
			if (animationSpeedCur == animationSpeed) {
				animationSpeedCur = 0;
				animationFrame++;
				if (animationFrame == sprite_get_number(animationSpr)) {
					stop();
				}
			}
		}
		
		if (clickFramesCur > 0) clickFramesCur--;
		
		if (IsInputPressed(INPUT_TYPE.primary)) {
			clickFramesCur = clickFrames;
		}
		
		if (comboSingleCooldownFramesCur > 0) comboSingleCooldownFramesCur--;
		
		if (canBeDoneStack == 0 && !isBeingDone && clickFramesCur > 0
		&& comboSingleCooldownFramesCur == 0) {
			comboUpdate();
		}
	},
	stop: function() {
		isBeingDone = false;
		_p.dash.canBeDoneStack--;
		_p.movement.canBeDoneStack--;
		_p.canLeaveStack--;
	},
	notifySlashStop: function() {
		//stop();
	},
	
	comboUpdate: function() {
		if (!isComboBeingDone) {
			isComboBeingDone = true;
			comboIndex = 0;
		}else {
			comboIndex++;
		}
		comboSingleCooldownFramesCur = comboSingleCooldownFrames;
		comboGloryFramesCur = comboGloryFrames;
		var curTarget = ds_map_create();
		for (var i = 0; i < instance_number(obj_enemyParent); i++) {
			ds_map_add(curTarget, instance_find(obj_enemyParent, i), pointer_null);
		}
		for (var i = 0; i < instance_number(obj_archerArrow); i++) {
			ds_map_add(curTarget, instance_find(obj_archerArrow, i), pointer_null);
		}
		start();
		_p.slash.startDefault(3, spr_playerChaincutterSlash, InputSubmanager.joystick2.returnDirection(_p), curTarget, slashHitFunction);
		if (comboIndex == comboSize-1) {
			comboStop();
			startCooldown();
		}
	},
	comboStop: function() {
		isComboBeingDone = false;
	},
	
	startCooldown: function() {
		canBeDoneStack++;
		isComboCoolingDown = true;
		comboCooldownFramesCur = comboCooldownFrames;
	},
	stopCooldown: function() {
		canBeDoneStack--;
		isComboCoolingDown = false;
	},
	
	draw: function() {
		if (isBeingDone) {
			draw_sprite_ext(
				animationSprites[comboIndex], animationFrame,
				_p.x, _p.y, 1.0, animationFlip[comboIndex],
				_p.slash.direction,
				c_white, 1.0
			);
		}
	}
}

chainsawSlash = {
	_p: other,
	isBeingDone: false,
	dmg: 1.75,
	dmgBase: 0.5,
	dmgVar: 1,
	
	staminaCost: 2.75,
	
	slashHitFunction: function(instI) {
		var curRatio = _p.heat.value/_p.heat.valueMax;
		curRatio = 1;
		EnemySubmanager.damageEnemy(instI, dmg);
		_p.heat.receiveHeat(1);
		//EnemySubmanager.stunEnemyTemporary(instI, 30);
	},
	
	cycle: {
		_p: obj_playerChaincutter,
		_cS: other,
		isBeingDone: false,
		amount: 1,
		curIndex: 0,
		durationFrames: 5,
		durationFramesCur: 0,
		start: function() {
			var curTarget = ds_map_create();
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				ds_map_add(curTarget, instance_find(obj_enemyParent, i), pointer_null);
			}
			_p.slash.startDefault(
				2,
				spr_chaincutterSawSlash,
				InputSubmanager.joystick2.returnDirection(_p),
				curTarget,
				_cS.slashHitFunction
			);
			isBeingDone = true;
			curIndex++;
			durationFramesCur = 0;
		},
		reset: function() {
			durationFramesCur = 0;
			curIndex = 0;
		}
	},
	
	animationSprite: spr_chaincutterSawSlash,
	animationSpeed: 2,
	animationSpeedCur: 0,
	animationFrame: 0,
	
	isCharging: false,
	attackChargeFrames: 14,
	chargeFramesCur: 0,
	
	isDissipationWindow: false,
	dissipationWindowFrames: 14,
	dissipationWindowFramesCur: 0,
	
	startCharge: function() {
		isCharging = true;
		_p.canLeaveStack++;
	},
	stopCharge: function() {
		isCharging = false;	
		chargeFramesCur = 0;
		_p.canLeaveStack--;
	},
	
	start: function() {
		isBeingDone = true;
		cycle.reset();
		cycle.start();
		_p.canLeaveStack++;
		_p.isMovingFastStack++;
	},
	step: function() {
		if (isBeingDone) {
			cycle.durationFramesCur++;
			if (cycle.durationFramesCur == cycle.durationFrames) {
				if (cycle.curIndex == cycle.amount) {
					stop();
				}else {
					cycle.start();
				}
			}
			
			animationSpeedCur++;
			if (animationSpeedCur == animationSpeed) {
				animationSpeedCur = 0;
				animationFrame++;
				if (animationFrame == sprite_get_number(animationSprite)) {
					animationFrame = 0;
				}
			}
		}
		
		if (isDissipationWindow) {
			dissipationWindowFramesCur++;
			if (dissipationWindowFramesCur == dissipationWindowFrames) isDissipationWindow = false;
			else {
				if (IsInputPressed(INPUT_TYPE.secondary)) {
					isDissipationWindow = false;
					_p.flameThrow.startCharge();
				}
			}
		}
		
		if (!_p.flameThrow.isCharging && isCharging) {
			chargeFramesCur++;
			if (chargeFramesCur == attackChargeFrames) audio_play_sound(snd_defaultCharge, 0, false, 1.0, 0, 1.0);
			if (IsInputContinuous(INPUT_TYPE.secondary)) {
				//if (chargeFrames >= attackChargeFrames) {
					if (!cycle.isBeingDone) {
						if (MEMBER_TYPE.chaincutter.stamina >= staminaCost && chargeFramesCur >= attackChargeFrames) {
							MEMBER_TYPE.chaincutter.stamina -= staminaCost;
							start();
						}
					}
				//}
			}else {
				isDissipationWindow = true;
				dissipationWindowFramesCur = 0;
				// if (chargeFramesCur < attackChargeFrames) _p.flameThrow.start();
				stopCharge();
			}
		}
		
		if (!isCharging && IsInputContinuous(INPUT_TYPE.secondary)) {
			startCharge();
		}
	},
	stop: function() {
		isBeingDone = false;
		cycle.isBeingDone = false;
		_p.canLeaveStack--;
		_p.isMovingFastStack--;
		//_p.heat.value = 0;
	},
	draw: function() {
		if (isBeingDone) {
			draw_sprite_ext(
				animationSprite, animationFrame,
				_p.x, _p.y, 1.0, 1.0,
				_p.slash.direction,
				c_white, 1.0
			);
		}
	}
}

chainsawSlash_old = {
	_p: other,
	isBeingDone: false,
	dmgBase: 0.5,
	dmgVar: 1,
	
	slashHitFunction: function(instI) {
		var curRatio = _p.heat.value/_p.heat.valueMax;
		curRatio = 1;
		EnemySubmanager.damageEnemy(instI, dmgBase+curRatio*dmgVar);
		EnemySubmanager.stunEnemyTemporary(instI, 30);
	},
	
	cycle: {
		_p: obj_playerChaincutter,
		_cS: other,
		isBeingDone: false,
		amount: 1,
		curIndex: 0,
		durationFrames: 5,
		durationFramesCur: 0,
		start: function() {
			var curTarget = ds_map_create();
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				ds_map_add(curTarget, instance_find(obj_enemyParent, i), pointer_null);
			}
			_p.slash.startDefault(
				2,
				spr_chaincutterSawSlash,
				InputSubmanager.joystick2.returnDirection(_p),
				curTarget,
				_cS.slashHitFunction
			);
			isBeingDone = true;
			curIndex++;
			durationFramesCur = 0;
		},
		reset: function() {
			durationFramesCur = 0;
			curIndex = 0;
		}
	},
	
	animationSprite: spr_chaincutterSawSlash,
	animationSpeed: 2,
	animationSpeedCur: 0,
	animationFrame: 0,
	
	isCharging: false,
	attackChargeFrames: 10,
	chargeFramesCur: 0,
	startCharge: function() {
		isCharging = true;
		_p.canLeaveStack++;
	},
	stopCharge: function() {
		isCharging = false;	
		chargeFramesCur = 0;
		_p.canLeaveStack--;
	},
	
	start: function() {
		isBeingDone = true;
		cycle.reset();
		cycle.start();
		_p.movement.canBeDoneStack++;
		_p.canLeaveStack++;
	},
	step: function() {
		if (isBeingDone) {
			cycle.durationFramesCur++;
			if (cycle.durationFramesCur == cycle.durationFrames) {
				if (cycle.curIndex == cycle.amount) {
					stop();
				}else {
					cycle.start();
				}
			}
			
			animationSpeedCur++;
			if (animationSpeedCur == animationSpeed) {
				animationSpeedCur = 0;
				animationFrame++;
				if (animationFrame == sprite_get_number(animationSprite)) {
					animationFrame = 0;
				}
			}
		}
		
		if (isCharging) {
			chargeFramesCur++;
			if (chargeFramesCur == attackChargeFrames) audio_play_sound(snd_defaultCharge, 0, false, 1.0, 0, 1.0);
			if (!IsInputContinuous(INPUT_TYPE.secondary)) {
				if (MEMBER_TYPE.chaincutter.stamina >= 30 && chargeFramesCur >= attackChargeFrames) {
					MEMBER_TYPE.chaincutter.stamina -= 30;
					start();
				}
				stopCharge();
			}
		}
		
		if (!isCharging && IsInputContinuous(INPUT_TYPE.secondary)) {
			startCharge();
		}
	},
	stop: function() {
		isBeingDone = false;
		_p.movement.canBeDoneStack--;
		_p.canLeaveStack--;
		_p.heat.value = 0;
	},
	draw: function() {
		if (isBeingDone) {
			draw_sprite_ext(
				animationSprite, animationFrame,
				_p.x, _p.y, 1.0, 1.0,
				_p.slash.direction,
				c_white, 1.0
			);
		}
	}
}

flameThrow = {
	_p: other,
	
	isCharging: false,
	chargeFrames: 50,
	chargeFramesCur: 0,
	startCharge: function() {
		isCharging = true;
		chargeFramesCur = 0;
	},
	stopCharge: function() {
		isCharging = false;
	},
	
	start: function() {
		audio_play_sound(snd_chaincutterShotgun, 0, false, 1.0, 0, 1.0);
		
		var curChargeRatio = min(1, chargeFramesCur/chargeFrames);
		var curRatio = _p.heat.value/_p.heat.valueMax;
		
		//curRatio = 1;
		
		var dmgBase = 0.8;
		var dmgVar = -0.4;
		
		var angleDiffBase = 20;
		var angleDiffVar = -17;
		
		var spdBase = 3.5;
		var spdVar = 1.0;
		
		var spdVarBase = 1.5;
		var spdVarVar = -1.0;
		
		var lifetimeBase = 15;
		var lifetimeVar = 25;
		
		for (var i = 0; i < curRatio*10; i++) {
			var newProj = instance_create_layer(
				_p.x, _p.y,
				"Instances",
				obj_chaincutterFireProj,
				{
					dir: InputSubmanager.joystick2.returnDirection(_p)+choose(1, -1)*irandom(angleDiffBase+curChargeRatio*angleDiffVar),
					spd: spdBase+curChargeRatio*spdVar+random(spdVarBase+curChargeRatio*spdVarVar),
					lifetime: lifetimeBase+curChargeRatio*lifetimeVar,
					dmg: dmgBase+curChargeRatio*dmgVar,
					stacks: 4-curChargeRatio*2,
					knockback: 5-curChargeRatio*2
				}
			);
		}
		_p.heat.value = 0;
	},
	step: function() {
		if (isCharging) {
			chargeFramesCur++;
			if (!IsInputContinuous(INPUT_TYPE.secondary)) {
				stopCharge();
				if (_p.memberType.stamina >= 20) {
					_p.memberType.stamina -= 20;
					start();
				}
			}
		}
		
		/*if (mouse_check_button_pressed(mb_right)) {
			start();
		}*/
	},
	draw: function() {
		if (isCharging) {
			var curChargeRatio = min(1, chargeFramesCur/chargeFrames);
		
			var angleDiffBase = 20;
			var angleDiffVar = -18;
			
			var sizeBase = 50;
			var sizeVar = 62;
			var curSize = sizeBase+curChargeRatio*sizeVar;
			
			draw_set_color(c_orange);
			draw_line_width(_p.x, _p.y, _p.x+dcos(InputSubmanager.joystick2.returnDirection(_p)+angleDiffBase+curChargeRatio*angleDiffVar)*curSize, _p.y-dsin(InputSubmanager.joystick2.returnDirection(_p)+angleDiffBase+curChargeRatio*angleDiffVar)*curSize, 2);
			draw_line_width(_p.x, _p.y, _p.x+dcos(InputSubmanager.joystick2.returnDirection(_p)-(angleDiffBase+curChargeRatio*angleDiffVar))*curSize, _p.y-dsin(InputSubmanager.joystick2.returnDirection(_p)-(angleDiffBase+curChargeRatio*angleDiffVar))*curSize, 2);
		}
	}
}

fireSlice = {
	_p: other,
	dashDistance: 100,
	dmg: 6,
	isResting: false,
	restFrames: 12,
	restFramesCur: 0,
	start: function(dirI) {
		_p.memberType.stamina -= 30;
		isResting = true;
		restFramesCur = restFrames;
		_p.slashCombo.canBeDoneStack++;
		var hAdd = dcos(dirI)*dashDistance;
		var vAdd = -dsin(dirI)*dashDistance;
		for (var i = 0; i < instance_number(obj_enemyParent); i++) {
			var curEnemy = instance_find(obj_enemyParent, i);
			if (collision_line(_p.x, _p.y, _p.x+hAdd, _p.y+vAdd, curEnemy, true, false)) {
				EnemySubmanager.damageEnemy(curEnemy, dmg);
			}
		}
		for (var i = 0; i < 4; i++) {
			instance_create_layer(_p.x+hAdd/5*(i+1), _p.y+vAdd/5*(i+1), "Instances", obj_chaincutterFire, {
				lifetimeCur: 250
			});
		}
		_p.x += hAdd;
		_p.y += vAdd;
	},
	step: function() {
		if (isResting) {
			restFramesCur--;
			if (restFramesCur <= 0) {
				isResting = false;
				_p.slashCombo.canBeDoneStack--;
			}
		}
		
		if (_p.memberType.stamina >= 30 && IsInputPressed(INPUT_TYPE.primary) && _p.dash.clickFramesCur != 0) {
			if (_p.slashCombo.isComboCoolingDown) _p.slashCombo.stopCooldown();
			_p.dash.clickFramesCur = 0;
			audio_play_sound(snd_chaincutterSlice, 0, false, 1.0, 0, 1);
			start(InputSubmanager.joystick2.returnDirection(_p));
		}
	}
}

dash = { // OBSERVATION_PLAYER001: Refactor the dash.
	_p: other,
	canBeDoneStack: 0,
	isBeingDone: false,
	durationFrames: 6,
	durationFramesCur: 0,
	spd: 15,
	curDir: undefined,
	
	cooldownFrames: 60,
	cooldownFramesCur: 0,
	
	clickFrames: 3,
	clickFramesCur: 0,
	
	start: function(dirI) {
		PartySubmanager.playerIFrames = 30;
		isBeingDone = true;
		cooldownFramesCur = cooldownFrames;
		curDir = dirI;
		durationFramesCur = durationFrames;
		PhysicsMonomanager.setHSpeed(_p.physics, dcos(curDir)*spd);
		PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curDir)*spd);
	},
	step: function() {
		if (cooldownFramesCur > 0) cooldownFramesCur--;
		
		if (isBeingDone) {
			PhysicsMonomanager.setHSpeed(_p.physics, dcos(curDir)*spd);
			PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curDir)*spd);
			durationFramesCur--;
			if (durationFramesCur == 0) {
				isBeingDone = false;
				stop();
			}
		}
		
		if (clickFramesCur > 0) clickFramesCur--;
		if (IsInputPressed(INPUT_TYPE.utility)) clickFramesCur = clickFrames;
		if (_p.isControlled && cooldownFramesCur == 0 && canBeDoneStack == 0 && clickFramesCur == 1) {
			start(_p.lastDirection);
			audio_play_sound(snd_archerLoad, 0, false, 1.0, 0, 1);
		}
	},
	stop: function() {
		isBeingDone = false;
		PhysicsMonomanager.setHSpeed(_p.physics, 0);
		PhysicsMonomanager.setVSpeed(_p.physics, 0);
	}
}

heat = {
	_p: other,
	valueMax: 15,
	value: 0,
	resetFrames: 400,
	resetFramesCur: 0,
	blinkingFrames: 60,
	receiveHeat: function(valueI) {
		value += valueI;
		resetFramesCur = 0;
		if (value > valueMax) value = valueMax; // OBSERVATION_PLAYER003: There should be a punishment for reaching max heat.
	},
	step: function() {
		if (value != 0) {
			//resetFramesCur++;
			if (resetFramesCur == resetFrames) {
				value = 0;
				resetFramesCur = 0;
			}
		}
	},
	draw: function() {
		if (resetFrames-resetFramesCur > blinkingFrames || resetFramesCur%3 == 1) {
			draw_set_color(c_orange);
			draw_rectangle(
				_p.x-16,
				_p.y-40,
				_p.x-16+value/valueMax*32 - 1,
				_p.y-36,
				false
			);
		}
		draw_set_alpha(0.3);
		draw_set_color(c_white);
		draw_rectangle(
			_p.x-16,
			_p.y-40,
			_p.x+16 - 1,
			_p.y-36,
			true
		);
		draw_set_alpha(1.0);
	}
}
