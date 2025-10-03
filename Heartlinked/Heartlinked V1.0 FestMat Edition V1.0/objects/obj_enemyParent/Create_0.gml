/// @description Insert description here
// You can write your code in this editor

physics = PhysicsMonomanager.construct(self, DEFAULT_FRICTION);

detection = {
	_p: other,
	isDetecting: false,
	detectionRange: 360,
	step: function() {
		if (
			!collision_line(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y, obj_collision, false, false) &&
			point_distance(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y) <= detectionRange
		) {
			isDetecting = true;
		}else {
			isDetecting = false;
		}
	}
}

hlth = undefined;
hlthMax = undefined;

stun = {
	_p: other,
	framesCur: 0,
	canBeStunnedStack: 0,
	isStunnedStack: 0,
	isStunnedTemporary: false,
	step: function() {
		if (isStunnedStack != 0) {
			if (isStunnedTemporary) {
				framesCur--;
				if (framesCur <= 0) {
					isStunnedStack--;
					isStunnedTemporary = false;
					_p.notifyStunEnd();
				}
			}
		}
	},
	draw: function() {
		if (isStunnedStack != 0) draw_sprite(spr_stunned, 0, _p.x, _p.y);
	}
}

electricityDebuff = {
	_p: other,
	curStacks: 0,
	isActive: false,
	hitDistance: 100,
	appearFrames: 30,
	appearFramesCur: 0,
	curDir: 0,
	notifyDamage: function(dmgI) {
		if (isActive) {
			appearFramesCur = appearFrames;
			
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				var curEnemy = instance_find(obj_enemyParent, i);
				if (
					curEnemy.id != _p.id &&
					curEnemy.electricityDebuff.isActive
				) {
					EnemySubmanager.damageEnemyElectric(curEnemy, dmgI);
				}
			}
			
			
			/*curDir = point_direction(_p.x, _p.y, CURRENT_MEMBER_INST.x, CURRENT_MEMBER_INST.y)+180;
			var nearestEnemy = undefined;
			var nearestEnemyDist = undefined;
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				var curEnemy = instance_find(obj_enemyParent, i);
				if (
					collision_line(_p.x, _p.y, _p.x+dcos(curDir)*hitDistance, _p.y-dsin(curDir)*hitDistance, curEnemy, false, true) &&
					curEnemy.id != _p.id &&
					nearestEnemy == undefined || _p.x-curEnemy.x+_p.y-curEnemy.y < nearestEnemyDist
				) {
					nearestEnemy = curEnemy;
					nearestEnemyDist = _p.x-curEnemy.x+_p.y-curEnemy.y;
				}
			}
			if (nearestEnemy != undefined) {
				EnemySubmanager.damageEnemy(nearestEnemy, dmgI);
				EnemySubmanager.applyElectricity(nearestEnemy);
			}
			isActive = false;
			EnemySubmanager.removeStunStack(_p);*/
		}
	},
	cleanUp: function() {	
		
	},
	step: function() {
		if (appearFramesCur != 0) appearFramesCur--;
	},
	draw: function() {
		if (isActive) {
			draw_sprite(spr_enemyElectrified, irandom(3), _p.x, _p.y);
		}
		draw_sprite_ext(
			spr_electricCharge, 0,
			_p.x, _p.y,
			0.5, 1.0,
			curDir, c_white,
			appearFramesCur/appearFrames
		);
	}
}

fireDebuff = {
	_p: other,
	curStacks: 0,
	isActive: false,
	dmgPerStack: 0.5,
	dmgPerStackGradual: 0.35,
	stackFrames: 25,
	stackFramesCur: 0,
	notifyDamage: function(dmgI) {
		if (!isActive) return;
		var stackDec = min(curStacks, dmgI);
		curStacks -= stackDec;
		EnemySubmanager.damageEnemyFire(_p, stackDec*dmgPerStack);
		if (curStacks <= 0) {
			curStacks = 0;
			isActive = false;
			stackFramesCur = 0;
		}
	},
	step: function() {
		if (isActive) {
			stackFramesCur++;
			if (stackFramesCur == stackFrames) {
				stackFramesCur = 0;
				curStacks--;
				EnemySubmanager.damageEnemyFire(_p, dmgPerStackGradual);
				if (curStacks <= 0) {
					curStacks = 0;
					isActive = false;
				}
			}
		}
	},
	draw: function() {
		if (isActive) {
			draw_sprite(spr_enemyFire, 0, _p.x, _p.y);
		}
	}
}

thrownDebuff = {
	_p: other,
	isActive: false,
	curFrames: 0,
	hitEnemies: ds_map_create(),
	step: function() {
		if (isActive) {
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				var curEnemy = instance_find(obj_enemyParent, i);
				var _s = self;
				with (_p) {
					if (instance_exists(curEnemy) && !ds_map_exists(_s.hitEnemies, curEnemy.id) && place_meeting(x, y, curEnemy)) {
						ds_map_add(_s.hitEnemies, curEnemy.id, pointer_null);
						EnemySubmanager.stunEnemyTemporary(curEnemy, 40);
						PhysicsMonomanager.setHSpeed(curEnemy.physics, physics.hSpd);
						PhysicsMonomanager.setVSpeed(curEnemy.physics, physics.vSpd);
						//PhysicsMonomanager.applyKnockback(curEnemy.physics, 9, point_direction(0, 0, physics.hSpd, physics.vSpd));
						EnemySubmanager.damageEnemy(curEnemy, 4);
					audio_play_sound(snd_archerBallistaHit, 0, false, 0.75, 0, 1.5+random(0.2));
					}
				}
			}
			
			curFrames--;
			if (curFrames <= 0) {
				isActive = false;
			}
		}
	},
	cleanUp: function() {
		ds_map_destroy(hitEnemies);
	},
	start: function(framesI) {
		ds_map_clear(hitEnemies);
		isActive = true;
		curFrames = framesI;
	}
}

enemyType = undefined;

function notifyStunApply() {
	
}

function notifyStunStart() { // OBSERVATION_ENTITY002: This should be a static function between enemy types.
	
}

function notifyStunEnd() {
	
}

function initialize(hlthI, enemyTypeI) {
	hlth = hlthI;
	hlthMax = hlthI;
	enemyType = enemyTypeI;
}