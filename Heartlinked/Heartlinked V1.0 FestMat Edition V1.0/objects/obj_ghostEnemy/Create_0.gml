/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

initialize(8, undefined); // OBSERVATION_ENEMY002.

notifyStunStart = function() {
	aiManager.isMovingStack++;
	if (aiManager.dash.isBeingDone) aiManager.dash.stop();
}

notifyStunEnd = function() {
	aiManager.isMovingStack--;
}

physics.friction = 0.2;

aiManager = {
	_p: other,
	isMovingStack: 0,
	moveCooldownFramesBase: 70,
	moveCooldownFramesVar: 50,
	moveCooldownFramesCur: 100,
	
	dash: {
		_p: undefined,
		isBeingDone: false,
		cooldownFramesBase: 260,
		cooldownFramesVar: 40,
		cooldownFramesCur: 100,
		curDir: undefined,
		spd: 5,
		accSpd: 0.3,
		curTargetDistance: 200,
		curDistance: 0,
		
		teleportDir: undefined,
		teleportDistance: 177,
		teleportsCur: 0,
		teleports: 1,
		teleportX: undefined,
		teleportY: undefined,
		teleportSound: audio_play_sound(snd_bearClose, 0, true, 0.0, 0, 1.3),
		
		trailFrames: 6,
		trailFramesCur: 0,
		
		rotation: 0,
		scale: 0,
		chargeAppearFrames: 36,
		doDash: function(sharpTurnI = false) {
			curDir = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
			if (sharpTurnI) {
				PhysicsMonomanager.setHSpeed(_p.physics, dcos(curDir)*spd);
				PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curDir)*spd);
			}
			_p.image_angle = curDir+90;
			curDistance = 0;
			curTargetDistance = (true)
				? point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)+40
				: 300;
		},
		start: function() {
			isBeingDone = true;
			_p.sprite_index = spr_ghostDashing;
			_p.mask_index = spr_ghostDashing;
			_p.physics.appliesFrictionStack++;
			_p.aiManager.isMovingStack++;
			_p.stun.canBeStunnedStack++;
			teleportsCur = 0;
			var curTeleportDir = irandom(359);
			teleportDir = curTeleportDir;
			teleportX = CURRENT_MEMBER_INST.x+dcos(teleportDir)*teleportDistance;
			teleportY = CURRENT_MEMBER_INST.y-dsin(teleportDir)*teleportDistance;
			scale = 0.5;
			doDash();
		},
		stop: function() {
			isBeingDone = false;
			_p.sprite_index = spr_ghost;
			_p.mask_index = spr_ghost;
			_p.physics.appliesFrictionStack--;
			_p.aiManager.isMovingStack--;
			_p.stun.canBeStunnedStack--;
			_p.image_angle = 0;
		},
		step: function() {
			if (_p.stun.isStunnedStack == 0) cooldownFramesCur--;
			if (cooldownFramesCur == 0) {
				cooldownFramesCur = cooldownFramesBase+irandom(cooldownFramesVar);
				start();
				audio_play_sound(snd_ghostDash, 0, false, 1.0, 0, 1.0);
			}
			
			audio_sound_gain(teleportSound, 0, 0);
			if (isBeingDone) {
				var curRatio = curDistance/curTargetDistance;
				rotation += curRatio*15;
				scale += curRatio*0.05;
				
				var a = 80;
				var soundRatio = max(0, (curDistance-curTargetDistance+a)/(a));
				if (teleportsCur != teleports) audio_sound_gain(teleportSound, soundRatio*0.45, 0);
				with (_p) {
					if (place_meeting(x, y, CURRENT_MEMBER_INST)) {
						PartySubmanager.damageCurrentMember(10);
					}
				}
				curDistance += point_distance(0, 0, _p.physics.hSpd, _p.physics.vSpd); // OBSERVATION_PHYSICS001: Create a function of sorts to keep track of delta distance.
				PhysicsMonomanager.targetMaxSpeedToDirection(_p.physics, spd, accSpd, curDir);
				if (curDistance >= curTargetDistance) {
					if (teleportsCur < teleports) {
						_p.x = teleportX;
						_p.y = teleportY;
						doDash(true);
						teleportsCur++;
						audio_play_sound(snd_ghostDash, 0, false, 1.0, 0, 1.0+1*0.3);
					}else stop();
				}
				
				if (teleportsCur < teleports) {
					var targTeleX = CURRENT_MEMBER_INST.x+dcos(teleportDir)*teleportDistance;
					var targTeleY = CURRENT_MEMBER_INST.y-dsin(teleportDir)*teleportDistance;
					teleportX = teleportX+(targTeleX-teleportX)*0.08;
					teleportY = teleportY+(targTeleY-teleportY)*0.08;
				}
				
				trailFramesCur++;
				if (trailFramesCur == trailFrames) {
					trailFramesCur = 0;
					instance_create_layer(_p.x, _p.y, "Instances", obj_archerArrowTrail, {
						dir: _p.image_angle,
						sprite_index: spr_ghost,
						baseAlpha: 0.65,
					});
				}
			}
		},
		draw: function() {
			
			if (isBeingDone) {
				if (teleportsCur != teleports) {
					draw_sprite_ext(
						spr_ghostTeleport, 0, teleportX, teleportY,
						scale, scale,
						rotation,
						c_white,
						1.0
					);
					var curRatio = curDistance/curTargetDistance;
					var curRatio = curRatio*curRatio;
					var curDir = point_direction(teleportX, teleportY, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
					draw_set_color(c_aqua);
					draw_set_alpha(curRatio*0.5);
					draw_line_width(
						teleportX, teleportY,
						teleportX+dcos(curDir)*400, teleportY-dsin(curDir)*400,
						1
					);
					draw_set_alpha(1);
				}
			}
		},
		drawAfter: function() {
			if (cooldownFramesCur <= chargeAppearFrames) {
				draw_sprite(spr_ghostCharge, floor((chargeAppearFrames-cooldownFramesCur)/chargeAppearFrames*(sprite_get_number(spr_mageCharge))), _p.x, _p.y);
				var curRatio = 1-cooldownFramesCur/chargeAppearFrames;
				var curRatio = curRatio*curRatio;
				var curDir = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
				draw_set_color(c_lime);
				draw_set_alpha(curRatio*0.5);
				draw_line_width(
					_p.x, _p.y,
					_p.x+dcos(curDir)*400, _p.y-dsin(curDir)*400,
					1
				);
				draw_set_alpha(1);
			}
		}
	},
	
	step: function() {
		dash.step();
		
		if (isMovingStack == 0 && _p.detection.isDetecting) {
			moveCooldownFramesCur--;
			if (moveCooldownFramesCur <= 0) {
				var curDir = irandom(359);
				var curForce = 4;
				PhysicsMonomanager.setHSpeed(_p.physics, dcos(curDir)*curForce);
				PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curDir)*curForce);
			
				moveCooldownFramesCur = moveCooldownFramesBase+irandom(moveCooldownFramesVar);
			}
		}else {
			moveCooldownFramesCur = moveCooldownFramesBase+irandom(moveCooldownFramesVar);
		}
	},
	draw: function() {
		dash.draw();
	},
	drawAfter: function() {
		dash.drawAfter();	
	}
}

aiManager.dash._p = self;