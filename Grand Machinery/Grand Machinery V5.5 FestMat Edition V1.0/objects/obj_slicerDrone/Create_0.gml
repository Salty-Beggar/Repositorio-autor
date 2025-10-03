/// @description Insert description here
// You can write your code in this editor
if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;
// Inherit the parent event
event_inherited();

initialize(5, true, 6, false, -1, 100);
//assignEnemyHUDDefault();

accSpd = physicsDefaultFriction+0.3;
deaccSpd = 0.3;
maxSpd = 2;
targetDistance = 60;
targetMaxY1 = -50;
targetMaxY2 = 1;
lastDirection = 1;
canChangeDirection = true;
canMove = true;
hasTargetSpd = true;
isMoving = false;

reactionTime = 12;
reactionTimeCur = 0;
targDir = 1;

with (targettingInterface) {
	isInstanceTargetted = function(instI) {
		var p = instanceID;
		if (instI.y-p.y < p.detectionHeightMax) {
			if (TargettingInterface.canInstanceGoToInstance(p, instI, false, true) &&
			!BlockCollisionGrid.checkCollisionRectangle(p.x, p.y, instI.x, instI.y, collisionType_onewayUp)) {
				return true;
			}else {
				return false;
			}
		}
		return false;
	}
}
isDetecting = false;
detectionHeightMax = 1;
inSight = false;

lungeChargeSpr = spr_slicerDroneJump;

stoppingDistance = 20;

collisionMask = sprite_index;

slashEnergyCost = 1;

isPreparing = false;
isRecovering = false;

#region Slashing

slashDmg = 20;
slashStartDelay = 80;
slashStartDelayCur = 0;
willSlash = false;
slashAnimationSprite = spr_slicerDroneSlash;
lungeAnimationSprite = spr_slicerDroneLungeSlash;
slash = {
	p: other,
	isSlashing: false,
	canStart: true,
	animationSprite: spr_slicerDroneSlash,
	currentFrame: 0,
	frameAmount: 0,
	attackFrameMin: 0,
	attackFrameMax: 0,
	hitboxSprite: -1,
	cooldown: 30,
	cooldownCur: 0,
	damage: 20,
	actionObj: undefined,
	targetMap: undefined,

	start: function(spriteI, attackFrameMinI, attackFrameMaxI, hitboxI, isLungeSlashI) {
		if (!isSlashing) {
			p.energyInterface.useEnergy(p.slashEnergyCost);
			p.canMove = false;
			if (!isLungeSlashI) {
				p.lunge.tryStartFromSlash();
			}
			
			isSlashing = true;
			p.canChangeDirection = false;
			animationSprite = spriteI;
			currentFrame = 0;
			frameAmount = sprite_get_number(spriteI);
			attackFrameMin = attackFrameMinI;
			attackFrameMax = attackFrameMaxI;
			hitboxSprite = hitboxI;
			targetMap = ds_map_create();
			show_debug_message("Startred");
			ds_map_add(targetMap, obj_player.id, undefined);
			actionObj = ActionObjectManagers.slash.start(attackFrameMinI, attackFrameMaxI, hitboxI, p.id, p.lastDirection, hitFunction, targetMap, true);
			cooldownCur = cooldown;
		}
	},
	startDefault: function(isLungeSlashI) {
		start(animationSprite, 2, 5, spr_slicerDroneSlashHitbox, isLungeSlashI);
	},
	
	cleanup: function() {
		if (targetMap != undefined && ds_exists(targetMap, ds_type_map)) ds_map_destroy(targetMap);
	},
	
	hitFunction: function(instI) {
		PlayerManager.receiveDamage(p.slashDmg);
	},
	
	stop: function() {
		isSlashing = false;
		ds_map_destroy(targetMap);
		targetMap = undefined;
		ActionObjectManagers.slash.stop(actionObj);
		p.isRecovering = true;
		p.isPreparing = false;
		p.canChangeDirection = true;
	},
	
	tick: function() {
		if (isSlashing) {
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
				if (!p.lunge.willLunge) {
					canStart = true;
				}
				p.lunge.canStart = true;
				p.lunge.canAttempt = true;
				p.canMove = true;
				p.isRecovering = false;
			}
		}
	},

	draw: function() {
		var isDrawing = false;
		var spriteFrame = 0;
		if (isSlashing) {
			isDrawing = true;
			spriteFrame = currentFrame;
		}else {
			if (p.isPreparing) {
				isDrawing = true;
				draw_sprite(spr_slicerDroneAttack, 0, p.x, p.y);
			}else if (p.isRecovering) {
				isDrawing = true;
				spriteFrame = frameAmount-1;
			}
		}
		
		if (isDrawing) {
			draw_sprite_ext(
				animationSprite, spriteFrame, p.x, p.y, p.lastDirection, 1.0, 0, c_white, 1.0
			);
		}
	}
}

#endregion

#region Lunging

lungeEnergyCost = 1;
lunge = {
	p: other,
	startDistance: 120, // How close the enemy has to be to the player to start the lunge itself.
	willLunge: false,
	canAttempt: true,
	canStart: true,
	isLunging: false,
	startChancePerFrameNumerator: 1,
	startChancePerFrameDenominator: 850,
	startChancePerNormalSlashNumerator: 3,
	startChancePerNormalSlashDenominator: 10,
	startDelay: 80,
	startDelayCur: 0,
	hMaxForce: 4,
	vForce: -7,
	start: function() {
		audio_play_sound(snd_tele2, 0, false);
		isLunging = true;
		willLunge = false;
		canAttempt = false;
		p.slash.animationSprite = p.lungeAnimationSprite;
		startDelayCur = startDelay;
		p.canMove = false;
		p.isPreparing = true;
	},
	tryStart: function() {
		if (!willLunge && p.energyInterface.energy >= 2) {
			if (startChancePerFrameNumerator-1 >= irandom(startChancePerFrameDenominator-1)) {
				willLunge = true;
				p.slash.canStart = false;
				canMove = false;
			}
		}
	},
	tryStartFromSlash: function() {
		if (!willLunge && p.energyInterface.energy >= 2) {
			if (startChancePerNormalSlashNumerator-1 >= irandom(startChancePerNormalSlashDenominator-1)) {
				willLunge = true;
				p.slash.canStart = false;
				canMove = false;
			}
		}
	},
	tick: function() {
		if (isLunging) {
			if (startDelayCur > 0) {
				startDelayCur--;
				if (startDelayCur == 0) {
					startLunge();
				}
			}else {
				if (p.ifPhysics.isCollidingDown) {
					stop();
					p.slash.startDefault(true);
				}
			}
		}else if (p.isTargetting) {
			var yDiff = p.lastTarget.y - p.y;
			if (willLunge && abs(p.x-p.lastTarget.x) < startDistance && yDiff >= p.targetMaxY1 && yDiff <= p.targetMaxY2 && canStart) {
				start();
				willLunge = false;
			}
		}
	},
	startLunge: function() {
		p.energyInterface.useEnergy(p.lungeEnergyCost);
		if_physics.setHSpeed(p.ifPhysics, p.lastDirection*hMaxForce);
		if_physics.setVSpeed(p.ifPhysics, vForce);
		p.ifPhysics.doesFriction = false;
		p.repulsesPlayer = false;
	},
	stop: function() {
		isLunging = false;
		p.ifPhysics.doesFriction = true;
		p.repulsesPlayer = true;
	},
	draw: function() {
		if (startDelayCur > 0) {
			draw_sprite(p.lungeChargeSpr, 0, p.x, p.y);
		}
	}
};

#endregion
