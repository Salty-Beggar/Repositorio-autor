/// @description Insert description here
// You can write your code in this editor

event_inherited();

initialize(16, undefined); // OBSERVATION_ENEMY002.

physics = PhysicsMonomanager.construct(self, DEFAULT_FRICTION);
physics.knockbackMultiplier = 0.5;

stun.canBeStunnedStack++; // OBSERVATION_ENEMY003: Replace this line with stun resistance.

aiManager = {
	_p: other,
	lungeCooldownBase: 160,
	lungeCooldownCur: 78,
	lungeCooldownVar: 50,
	
	canMoveStack: 0,
	
	chargeFrames: 20,
	chargeRetreatForce: 2.6,
	chargeAnimation: {
		_p: undefined,
		isBeingDone: false,
		sprite: spr_enemySentinelCharge,
		speedFrames: 3,
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
			if (isBeingDone) draw_sprite_ext(
				sprite, frame, _p.x, _p.y-_p.z,
				1.0, 1.0, 0,
				c_lime,
				1.0
			);
		}
	},
	
	step: function() {
		chargeAnimation.step();
		if (lungeCooldownCur > 0 && _p.stun.isStunnedStack == 0) lungeCooldownCur--;
		if (lungeCooldownCur == chargeFrames) {
			canMoveStack++;
			chargeAnimation.start();
			audio_play_sound(snd_sentinelTelegraph, 1.0, false, 1.0, 0, 0.8+random(0.4));
			var curRetreatDir = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)+180;
			PhysicsMonomanager.addSpeedToDirection(_p.physics, chargeRetreatForce, curRetreatDir);
		}else if (_p.detection.isDetecting) {
			if (canMoveStack == 0) PhysicsMonomanager.targetMaxSpeedToDirection(
				_p.physics,
				0.5,
				0.8,
				point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)
			);
			if (lungeCooldownCur == 0) {
				canMoveStack--;
				lungeCooldownCur = lungeCooldownBase+irandom(lungeCooldownVar);
				_p.lunge.start(point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y), point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y));
			}
		}
	},
	
	draw: function() {
		chargeAnimation.draw();
	}
}
aiManager.chargeAnimation._p = self;

z = 0;
zSpd = 0;

shooting = {
	_p: other,
	dmg: 10,
	amount: 8,
	start: function() {
		var projAmount = amount;
		for (var i = 0; i < projAmount; i++) {
			var curAngle = 360/projAmount*i;
			var newProj = instance_create_layer(_p.x, _p.y, "Instances", obj_sentinelProjectile, {
				dir: curAngle,
				dmg: self.dmg
			});
		}
	}
}

lunge = {
	_p: other,
	isBeingDone: false,
	canBeDoneStack: 0,
	zForce: 5,
	dirForceBase: 0,
	grv: 0.3,
	isAttackLunge: false,
	frames: 0,
	start: function(dirI, distanceFromTargetI, isAttackLungeI = false) {
		isBeingDone = true;
		_p.aiManager.canMoveStack++;
		_p.zSpd = zForce;
		_p.physics.appliesFrictionStack++;
		_p.physics.knockbackMultiplier = 1.0;
		
		var curDirForce = dirForceBase;
		var jumpFrames = ceil(zForce*2/grv);
		if (distanceFromTargetI < jumpFrames*dirForceBase) curDirForce = distanceFromTargetI/jumpFrames;
		_p.physics.hSpd = dcos(dirI)*curDirForce;
		_p.physics.vSpd = -dsin(dirI)*curDirForce;
		
		isAttackLunge = isAttackLungeI;
	},
	step: function() {
		if (isBeingDone) {
			frames++;
			_p.zSpd -= grv;
			if (_p.z+_p.zSpd < 0) {
				_p.zSpd = 0;
				_p.z = 0;
				stop();
				
				if (true) {
					_p.shooting.start();
				}
			}
		}
	},
	stop: function() {
		audio_play_sound(snd_sentinelLand, 0, false, 1.0, 0, 1);
		isBeingDone = false;
		_p.aiManager.canMoveStack--;
		_p.physics.appliesFrictionStack--;
		_p.physics.hSpd = 0;
		_p.physics.vSpd = 0;
		_p.physics.knockbackMultiplier = 0.5;
	},
	draw: function() {
		if (isBeingDone && frames%4 <= 1) {
			var projAmount = _p.shooting.amount;
			draw_set_alpha(0.5);
			for (var i = 0; i < projAmount; i++) {
				var curAngle = 360/projAmount*i;
				draw_set_color(c_orange);
				draw_line_width(_p.x, _p.y, _p.x+dcos(curAngle)*200, _p.y-dsin(curAngle)*200, 2);
			}
			draw_set_alpha(1.0);
		}
	}
}