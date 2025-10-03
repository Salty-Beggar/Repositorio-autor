/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

initialize(6, undefined); // OBSERVATION_ENEMY002: Associate with enemy type.

notifyStunStart = function() {
	aiManager.canMoveStack++;
	aiManager.shot.cooldownFramesCur = aiManager.shot.cooldownFramesBase;
}

notifyStunEnd = function() {
	aiManager.canMoveStack--;
}

shooting = {
	_p: other,
	dmg: 10,
	start: function(dirI) {
		audio_play_sound(snd_mageShot, 0, false, 1.0, 0, 0.9+random(0.2));
		var newProj = instance_create_layer(
			_p.x, _p.y, "Instances", obj_mageProjectile,
			{
				dir: dirI,
				dmg: self.dmg
			}
		);
	}
}

aiManager = {
	_p: other,
	canMoveStack: 0,
	accSpd: 1,
	retreatAccSpd: 1,
	maxSpd: 1,
	stopDistance: 230,
	retreatDistance: 50,
	shot: {
		_p: undefined,
		cooldownFramesBase: 94,
		cooldownFramesVar: 66,
		cooldownFramesCur: 60,
		
		chargeAppearFrames: 30,
		
		step: function() {
			if (_p.detection.isDetecting) {
				
				cooldownFramesCur--;
				if (cooldownFramesCur == 0) {
					cooldownFramesCur = cooldownFramesBase+irandom(cooldownFramesVar);
					_p.shooting.start(
						point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)
					);
				}
			}
		},
		draw: function() {
			if (cooldownFramesCur <= chargeAppearFrames) {
				draw_sprite(spr_mageCharge, floor((chargeAppearFrames-cooldownFramesCur)/chargeAppearFrames*(sprite_get_number(spr_mageCharge))), _p.x, _p.y);
			}
		}
	},
	step: function() {
		if (canMoveStack == 0 && _p.detection.isDetecting) {
			var curDistance = point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y);
			if (curDistance > stopDistance) {
				PhysicsMonomanager.targetMaxSpeedToDirection(
					_p.physics,
					maxSpd, accSpd,
					point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)
				);
			}else if (curDistance < retreatDistance) {
				PhysicsMonomanager.targetMaxSpeedToDirection(
					_p.physics,
					maxSpd, retreatAccSpd,
					point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)+180
				);
			}else {
				if (irandom(200) == 1) {
					var curDir = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y) + choose(90, -90);
					PhysicsMonomanager.setHSpeed(_p.physics, dcos(curDir)*5);
					PhysicsMonomanager.setVSpeed(_p.physics, -dsin(curDir)*5);
				}
			}
		}
		shot.step();
	},
	draw: function() {
		shot.draw();
	}
}

aiManager.shot._p = self;