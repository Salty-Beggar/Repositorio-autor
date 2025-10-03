/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

initialize(MEMBER_TYPE.archer);

isMovementSlowedDownStack = 0;

shot = {
	_p: other,
	start: function(dirI, spdI, dmgI, colorI, knockbackI, piercesI, isChargedI, isHeavyI) {
		var newArrow = instance_create_layer(_p.x, _p.y, "Instances", obj_archerArrow, {
			dir: dirI,
			spd: spdI,
			dmg: dmgI,
			image_blend: colorI,
			knockback: knockbackI,
			pierces: piercesI,
			isCharged: isChargedI,
			debuffStacks: 10,
			isHeavy: isHeavyI,
			playerHSpd: _p.physics.hSpd,
			playerVSpd: _p.physics.vSpd
		});
	},
	startBolt: function(dirI, spdI, dmgI, colorI, knockbackI, piercesI, isChargedI, ratioI) {
		var newArrow = instance_create_layer(_p.x, _p.y, "Instances", obj_archerBolt, {
			dir: dirI,
			spd: spdI,
			dmg: dmgI,
			image_blend: colorI,
			knockback: knockbackI,
			pierces: piercesI,
			isCharged: isChargedI,
			debuffStacks: 10,
			ratio: ratioI,
			memberHSpd: _p.physics.hSpd,
			memberVSpd: _p.physics.vSpd
		});
	}
}

shooting = {
	_p: other,
	canBeDoneStack: 0,
	isCharging: false,
	chargeFramesCur: 0,
	isInCooldown: false,
	cooldownFrames: 45,
	cooldownFramesCur: 0,
	
	recoilFrames: 15,
	recoilFramesCur: 0,
	
	clickFrames: 12,
	clickFramesCur: 0,
	
	shotTypes: [],
	
	isDelaying: false,
	delayFrames: 9,
	delayFramesCur: 0,
	startDelay: function() {
		_p.canLeaveStack++;
		isDelaying = true;
		delayFramesCur = delayFrames;
		audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 1.5);
	},
	stopDelay: function() {
		_p.canLeaveStack--;
		isDelaying = false;
	},
	
	weakShot: {
		dmg: 2,
		spd: 8,
		chargeFrames: undefined,
		color: c_lime,
		recoilFrames: 1,
		knockback: 3,
		//stuns: false,
		//stunFrames: 0,
		pierces: 4,
		costsStamina: false,
		staminaCost: undefined,
		isCharged: false,
		canCharge: false,
		isHeavy: false
	},
	strongShot: {
		dmg: 7,
		spd: 10,
		chargeFrames: 22,
		color: c_orange,
		recoilFrames: 1,
		knockback: 3,
		//stuns: true,
		//stunFrames: 40,
		pierces: 4,
		costsStamina: true,
		staminaCost: 30,
		isCharged: false,
		canCharge: true,
		isHeavy: false
	},
	ballistaShot: {
		dmg: 6,
		spd: 4,
		chargeFrames: 22,
		color: c_white,
		recoilFrames: 1,
		knockback: 3,
		//stuns: true,
		//stunFrames: 40,
		pierces: 2,
		costsStamina: true,
		staminaCost: 30,
		isCharged: false,
		canCharge: true,
		isHeavy: true
	},
	chargedShot: {
		dmg: 3,
		spd: 10,
		chargeFrames: 34,
		color: c_aqua,
		recoilFrames: 1,
		knockback: 3,
		//stuns: true,
		//stunFrames: 40,
		pierces: 4,
		costsStamina: true,
		staminaCost: 40,
		isCharged: true,
		isHeavy: false
		
	},
	
	initialize: function() {
		shotTypes = [strongShot, weakShot];
	},
	
	startCharge: function() {
		isCharging = true;
		_p.canLeaveStack++;
		_p.isMovementSlowedDownStack++;
	},
	stopCharge: function() {
		isCharging = false;
		_p.canLeaveStack--;
		chargeFramesCur = 0;
		_p.isMovementSlowedDownStack--;
	},
	step: function() {
		if (isDelaying) {
			delayFramesCur--;
			var dashForce = 9.4;
			if (IsInputPressed(INPUT_TYPE.primary)) {
				PartySubmanager.playerIFrames = 20;
				PhysicsMonomanager.setHSpeed(_p.physics, dcos(_p.lastDirection)*dashForce);
				PhysicsMonomanager.setVSpeed(_p.physics, -dsin(_p.lastDirection)*dashForce);
				stopDelay();
				if (_p.memberType.stamina >= chargedShot.staminaCost) shoot(chargedShot);
				else audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 0.4+random(0.2));
			}else if (delayFramesCur == 0) {
				PartySubmanager.playerIFrames = 20;
				PhysicsMonomanager.setHSpeed(_p.physics, dcos(_p.lastDirection)*dashForce);
				PhysicsMonomanager.setVSpeed(_p.physics, -dsin(_p.lastDirection)*dashForce);
				stopDelay();
				shoot(strongShot);
			}
		}
		
		if (recoilFramesCur > 0) {
			recoilFramesCur--;
			if (recoilFramesCur == 0) _p.movement.canBeDoneStack--;
		}
		
		if (isInCooldown) {
			cooldownFramesCur--;
			if (cooldownFramesCur == 0) stopCooldown();
		}
		
		if (isCharging) {
			chargeFramesCur++;
			for (var i = 0; i < array_length(shotTypes); i++) {
				var curType = shotTypes[i];
				if (i != array_length(shotTypes)-1 && chargeFramesCur == curType.chargeFrames) {
					audio_play_sound(snd_defaultCharge, 0, false, 1.0, 0, 1.0+(array_length(shotTypes)-i-2)*0.2);
				}
			}
			if (!IsInputContinuous(INPUT_TYPE.primary)) { // OBSERVATION_INPUT001.
				var wasShotSuccesful = doShotAction();
				stopCharge();
				if (wasShotSuccesful) {
					startCooldown();
					_p.movement.canBeDoneStack++;
				}else audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 0.4+random(0.2));
			}
		}
		
		if (clickFramesCur > 0) clickFramesCur--;
		if (!IsInputContinuous(INPUT_TYPE.utility) && IsInputContinuous(INPUT_TYPE.primary)) {
			clickFramesCur = clickFrames;
		}
		
		if (canBeDoneStack == 0 && !isCharging && clickFramesCur > 0) { // OBSERVATION_INPUT001.
			startCharge();
		}
	},
	
	doShotAction: function() {
		for (var i = 0; i < array_length(shotTypes); i++) {
			var curType = shotTypes[i];
			if (i == array_length(shotTypes)-1 || chargeFramesCur >= curType.chargeFrames) {
				if (!curType.costsStamina || _p.memberType.stamina >= curType.staminaCost) {
					if (!curType.canCharge) {
						shoot(curType);
					}else {
						if (!_p.hook.isBeingDone) {
							startDelay();
						}else {
							shoot(ballistaShot);
							_p.hook.stop(true);
						}
					}
					return true;
				}else return false;
			}
		}
		return false;
	},
	
	shoot: function(typeI) {
		audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 0.8+random(0.3));
		_p.shot.start(
			InputSubmanager.joystick2.returnDirection(_p), typeI.spd, typeI.dmg, typeI.color, typeI.knockback, typeI.pierces, typeI.isCharged,
			typeI.isHeavy
		);
		if (typeI.costsStamina) _p.memberType.stamina -= typeI.staminaCost;
		recoilFramesCur = typeI.recoilFrames;
	},
	
	startCooldown: function() {
		isInCooldown = true;
		cooldownFramesCur = cooldownFrames;
		canBeDoneStack++;
	},
	stopCooldown: function() {
		isInCooldown = false;
		canBeDoneStack--;
	}
}
shooting.initialize();

hook = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 0,
	
	isInCooldown: false,
	cooldownFrames: 30,
	cooldownFramesCur: 0,
	
	force: DEFAULT_FRICTION+0.65,
	forceBase: DEFAULT_FRICTION+0.2,
	forceVar: 0.4,
	curXTarget: undefined,
	curYTarget: undefined,
	
	ropeFrames: 300,
	ropeFramesCur: 300,
	ropeHookCost: 300,
	
	isCharging: false,
	chargeFrames: 25,
	chargeFramesCur: 0,
	startCharge: function() {
		isCharging = true;
		chargeFramesCur = 0;
		_p.isMovementSlowedDownStack++;
		canBeDoneStack++;
	},
	stopCharge: function() {
		isCharging = false;
		_p.isMovementSlowedDownStack--;
		canBeDoneStack--;
	},
	
	isHookingEnemy: undefined,
	curEnemyTarg: undefined,
	
	hookSpd: 24,
	hookLifetime: 10,
	
	isSpinning: false,
	curSpinSpd: undefined,
	curSpinAngle: undefined,
	curSpinDist: undefined,
	curSpinX: undefined,
	curSpinY: undefined,
	curSpinDir: undefined,
	startSpin: function(spdI, angleI, distI, dirI) {
		isSpinning = true;
		_p.movement.canBeDoneStack++;
		curSpinSpd = spdI;
		curSpinAngle = angleI;
		curSpinDist = distI;
		curSpinDir = dirI;
		curSpinX = curXTarget;
		curSpinY = curYTarget;
	},
	stopSpin: function() {
		isSpinning = false;
		_p.movement.canBeDoneStack--;
	},
	
	startHook: function(dirI, spdI, dmgI, colorI, knockbackI, lifetimeI) {
		var newHook = instance_create_layer(_p.x, _p.y, "Instances", obj_archerHook, {
			dir: dirI,
			spd: spdI,
			dmg: dmgI,
			image_blend: colorI,
			knockback: knockbackI,
			lifetime: lifetimeI
		});
		canBeDoneStack++;
	},
	
	start: function(xTargI, yTargI) {
		audio_play_sound(snd_sentinelLand, 0, false, 1.0, 0, 1.5);
		isBeingDone = true;
		isHookingEnemy = false;
		_p.movement.canBeDoneStack++;
		curXTarget = xTargI;
		curYTarget = yTargI;
		_p.canLeaveStack++;
		_p.shooting.canBeDoneStack++;
	},
	startEnemy: function(enemyTargI) {
		audio_play_sound(snd_sentinelLand, 0, false, 1.0, 0, 1.5);
		isBeingDone = true;
		isHookingEnemy = true;
		curEnemyTarg = enemyTargI;
		_p.canLeaveStack++;
		_p.shooting.canBeDoneStack++;
		EnemySubmanager.stunEnemy(enemyTargI, true);
	},
	step: function() {
		ropeFramesCur++;
		if (ropeFramesCur > ropeFrames) ropeFramesCur = ropeFrames;
		
		if (isBeingDone) {
			PartySubmanager.playerIFrames++;
			if (!isHookingEnemy) {
				var curAngle = point_direction(_p.x, _p.y, curXTarget, curYTarget);
				
				if (!isSpinning) {
					var curForce = force;
				
					PhysicsMonomanager.addHSpeed(_p.physics, dcos(curAngle)*curForce);
					PhysicsMonomanager.addVSpeed(_p.physics, -dsin(curAngle)*curForce);
				}else {
					curSpinAngle += curSpinSpd*spinDir*2;
					_p.x = curXTarget+dcos(curSpinAngle)*curSpinDist;
					_p.y = curYTarget-dsin(curSpinAngle)*curSpinDist;
					PhysicsMonomanager.setHSpeed(_p.physics, dcos(curSpinAngle+90)*curSpinSpd);
					PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curSpinAngle+90)*curSpinSpd);
				}
				
				if (
			
					point_distance(_p.x, _p.y, curXTarget, curYTarget) <= point_distance(0, 0, _p.physics.hSpd, _p.physics.vSpd)
				) {
					if (isSpinning) stopSpin();
					stop(true);
				}
				
			}else {
				var curAngle = point_direction(curEnemyTarg.x, curEnemyTarg.y, _p.x, _p.y);
				PhysicsMonomanager.addHSpeed(curEnemyTarg.physics, dcos(curAngle)*force);
				PhysicsMonomanager.addVSpeed(curEnemyTarg.physics, -dsin(curAngle)*force);
				
				if (
			
					point_distance(_p.x, _p.y, curEnemyTarg.x, curEnemyTarg.y) <= point_distance(0, 0, curEnemyTarg.physics.hSpd, curEnemyTarg.physics.vSpd)
				) {
					stop(true);
				}
			}
			if (isBeingDone && IsInputPressed(INPUT_TYPE.utility)) {
				if (isSpinning) stopSpin();
				stop();
			}
			else if (false && isBeingDone && _p.memberType.stamina >= 30 && IsInputPressed(INPUT_TYPE.primary)) {
				if (isSpinning) stopSpin();
				
				_p.memberType.stamina -= 25;
				_p.shooting.clickFramesCur = 0;
				var ratioMax = 10;
				var curRatio = min(1, point_distance(0, 0, _p.physics.hSpd, _p.physics.vSpd)/ratioMax);
				if (isHookingEnemy)
					curRatio = min(1, point_distance(0, 0, curEnemyTarg.physics.hSpd, curEnemyTarg.physics.vSpd)/ratioMax);
				
				var speedBase = 2;
				var speedVar = 4;
				
				var dmgBase = 2;
				var dmgVar = 4;
				
				var knockbackBase = 4;
				var knockbackVar = 10;
				
				_p.shot.startBolt(
					InputSubmanager.joystick2.returnDirection(_p),
					speedBase+curRatio*speedVar,
					dmgBase+curRatio*dmgVar,
					c_white,
					knockbackBase+curRatio*knockbackVar,
					1,
					false,
					curRatio
				);
				stop(!isHookingEnemy);
				audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 1.8+random(0.2));
				audio_play_sound(snd_archerReload, 0, false, 0.3, 0, 1.0+random(0.2));
			}
		}
		
		if (canBeDoneStack == 0 && !isInCooldown && _p.isControlled && !isCharging && IsInputPressed(INPUT_TYPE.utility)) {
			//start(global.getMouseX(), global.getMouseY());
			startCharge();
		}
		
		if (isCharging) {
			chargeFramesCur++;
			var curRatio = min(1.0, chargeFramesCur/chargeFrames);
			curRatio = min(curRatio, ropeFramesCur/ropeHookCost);
			var linearRatio = curRatio;
			//curRatio = dsin(curRatio*90);
			if (!IsInputContinuous(INPUT_TYPE.utility)) {
				startHook(InputSubmanager.joystick2.returnDirection(_p), hookSpd, 0, c_white, 0, curRatio*hookLifetime);
				stopCharge();
				ropeFramesCur -= linearRatio*ropeHookCost;
			}else if (_p.memberType.stamina >= 25 && IsInputPressed(INPUT_TYPE.primary)) {
				_p.memberType.stamina -= 25;
				var wireX = _p.x+dcos(InputSubmanager.joystick2.returnDirection(_p))*hookSpd*hookLifetime*curRatio;
				var wireY = _p.y-dsin(InputSubmanager.joystick2.returnDirection(_p))*hookSpd*hookLifetime*curRatio;
				_p.wireTrap.start(wireX, wireY);
				audio_play_sound(snd_archerLoad, 0, false, 1.0, 0, 1.0);
				stopCharge();
				ropeFramesCur -= curRatio*ropeHookCost;
			}
		}
		
		if (isInCooldown) {
			cooldownFramesCur--;
			if (cooldownFramesCur <= 0) {
				isInCooldown = false;
			}
		}
	},
	stop: function(immediateStopI) {
		isBeingDone = false;
		audio_play_sound(snd_archerLoad, 0, false, 1.0, 0, 1.0);
		if (!isHookingEnemy) _p.movement.canBeDoneStack--;
		else {
			EnemySubmanager.removeStunStack(curEnemyTarg);
		}
		_p.canLeaveStack--;
		PartySubmanager.playerIFrames += 15;
		if (immediateStopI) {
			if (!isHookingEnemy) {
				PhysicsMonomanager.setHSpeed(_p.physics, 0);
				PhysicsMonomanager.setVSpeed(_p.physics, 0);
			}else {
				PhysicsMonomanager.setHSpeed(curEnemyTarg.physics, 0);
				PhysicsMonomanager.setVSpeed(curEnemyTarg.physics, 0);
			}
		}else {
			if (!isHookingEnemy) {
				PhysicsMonomanager.setHSpeed(_p.physics, _p.physics.hSpd*0.75);
				PhysicsMonomanager.setVSpeed(_p.physics, _p.physics.vSpd*0.75);
			}
		}
		_p.shooting.canBeDoneStack--;
		isInCooldown = true;
		cooldownFramesCur = cooldownFrames;
		canBeDoneStack--;
	},
	draw: function() {
		var curRatio = min(1.0, chargeFramesCur/chargeFrames);
		var maxRatio = min(1.0, ropeFramesCur/ropeHookCost);
		curRatio = min(curRatio, maxRatio);
		var linearRatio = curRatio;
		//curRatio = dsin(curRatio*90);
		if (isCharging) {
			var curDir = InputSubmanager.joystick2.returnDirection(_p);
			draw_set_color(c_lime);
			draw_line_width(_p.x, _p.y, _p.x+dcos(curDir)*curRatio*hookLifetime*hookSpd, _p.y-dsin(curDir)*curRatio*hookLifetime*hookSpd, 1);
			draw_circle(_p.x+dcos(curDir)*curRatio*hookLifetime*hookSpd, _p.y-dsin(curDir)*curRatio*hookLifetime*hookSpd, 3, false);
			draw_circle(_p.x+dcos(curDir)*hookLifetime*hookSpd, _p.y-dsin(curDir)*hookLifetime*hookSpd, 3, false);
		}
		
		if (isBeingDone) {
			if (!isHookingEnemy)
				draw_sprite(spr_archerHookHooked, 0, curXTarget, curYTarget);
			else
				draw_sprite(spr_archerHookHooked, 0, curEnemyTarg.x, curEnemyTarg.y);
		}
		
		var fullRopeRatio = ropeFramesCur/ropeFrames;
		var curRopeRatio = ropeFramesCur/ropeFrames;
		if (isCharging) {
			var curHookCost = linearRatio*ropeHookCost;
			if (ropeFramesCur - curHookCost < 0) curHookCost = 0;
			curRopeRatio = (ropeFramesCur-curHookCost)/ropeFrames;
			/*draw_set_color(c_red);
			draw_rectangle(
				_p.x+16-curHookCost/ropeFrames*32,
				_p.y-40,
				_p.x-16+fullRopeRatio*32 - 1,
				_p.y-36,
				false
			);*/
		}else {
			draw_set_alpha(0.5);
		}
		draw_set_color(c_lime);
		draw_rectangle(
			_p.x-16,
			_p.y-40,
			_p.x-16+curRopeRatio*32 - 1,
			_p.y-36,
			false
		);
		
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

wireTrap = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 0,
	start: function(xI, yI) {
		var newWire = instance_create_layer(0, 0, "Instances", obj_archerWire);
		newWire.addNode(xI, yI);
		newWire.addNode(_p.x, _p.y);
	},
}
