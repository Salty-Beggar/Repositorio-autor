/// @description Insert description here
// You can write your code in this editor

global.getMouseX = function() {
	return camera_get_view_x(CameraSubmanager.gameplayCamera)+window_mouse_get_x()/RESOLUTION_SCALE;
}
global.getMouseY = function() {
	return camera_get_view_y(CameraSubmanager.gameplayCamera)+window_mouse_get_y()/RESOLUTION_SCALE;
}

#region Gameplay manager

enum hordeDifficulty {
	easy, medium, hard
}
enum INPUT_TYPE {
	primary, secondary, utility, memberSwitch
}
#macro IsInputContinuous InputSubmanager.isInputContinuous
#macro IsInputReleased InputSubmanager.isInputReleased
#macro IsInputPressed InputSubmanager.isInputPressed

#macro GameplayManager global.gameplayManager
	#macro CameraSubmanager global.gameplayManager.cameraSubmanager
		#macro BASE_RESOLUTION_WIDTH 640
		#macro BASE_RESOLUTION_HEIGHT 360
		#macro RESOLUTION_SCALE 3
	#macro PartySubmanager global.gameplayManager.partySubmanager
		#macro MEMBER_TYPE PartySubmanager.memberTypes
		#macro CURRENT_MEMBER_INST PartySubmanager.curMemberInst
	#macro InterfaceSubmanager global.gameplayManager.interfaceSubmanager
		#macro PhysicsMonomanager InterfaceSubmanager.physicsMonomanager
			#macro DEFAULT_FRICTION 0.4
	#macro InputSubmanager global.gameplayManager.inputSubmanager
		enum INPUT_DEVICE {
			keyboard,
			controller
		}
		#macro KEYBOARD_DIRECTION_MATRIX [[135, 90, 45], [180, undefined, 0], [225, 270, 315]]
	#macro EntitySubmanager global.gameplayManager.entitySubmanager
		#macro EnemySubmanager global.gameplayManager.entitySubmanager.enemySubmanager
	#macro ActionObjectSubmanager global.gameplayManager.actionAssetSubmanager
	#macro HUDSubmanager global.gameplayManager.hudSubmanager

global.gameplayManager = {
	createEvent: function() {
		cameraSubmanager.createEvent();
		partySubmanager.createEvent();
		inputSubmanager.createEvent();
		gameplayStartEvent();
	},
	gameplayStartEvent: function() {
		cameraSubmanager.gameplayStartEvent();
	},
	roomStartEvent: function() {
		cameraSubmanager.roomStartEvent();
		partySubmanager.roomStartEvent();
		DEBUG_hordeManager.roomStartEvent();
	},
	stepEvent: function() {
		cameraSubmanager.stepEvent();
		partySubmanager.stepEvent();
		DEBUG_hordeManager.stepEvent();
	},
	drawEndEvent: function() {
		hudSubmanager.drawEndEvent();
	},
	drawGUIEvent: function() {
		hudSubmanager.drawGUIEvent();
	},
	
	#region Submanagers
	
	DEBUG_hordeManager: {
		haveHordesStarted: false,
		haveHordesEnded: false,
		curHorde: 0,
		hordeLayers: undefined,
		hordeGroups: [],
		
		tutorialHordes: [],
		tutorialHasStarted: false,
		tutorialHordeIndex: 0,
		hordeBruhDelay: 0,
		
		mainHordes: [[], [], []], // Easy, medium and hard hordes
		curHordeCredit: 0,
		hordeCreditCost: [10, 30, 90],
		creditPerHorde: 20, // The credit gained per horde.
		creditGainAddPerHorde: 1.0,
		selectedHorde: undefined,
		
		hordeCooldown: 100,
		hordeCooldownCur: 100,
		hordeIsInCooldown: false,
		
		hordeRestCooldown: 8*60,
		hordeRestCooldownCur: 0,
		hordeRestHordeCooldown: 6,
		hordeRestHordeCooldownCur: 0,
		hordeIsInRest: false,
		
		isTelegraphingHorde: false,
		
		cock: 5,
		initializeHordes: function() {
			tutorialHordes = [
				layer_get_id("WaveC_1"),
				layer_get_id("WaveC_2"),
				layer_get_id("WaveC_3"),
				layer_get_id("WaveC_4"),
				layer_get_id("WaveC_7"),
				layer_get_id("WaveC_8"),
				layer_get_id("WaveC_12"),
				layer_get_id("WaveC_13")
			];
			mainHordes = [
				[ // Easy
				layer_get_id("WaveC_19"),
				layer_get_id("WaveC_5"),
				layer_get_id("WaveC_6"),
				layer_get_id("WaveC_9"),
				layer_get_id("WaveC_20"),
				layer_get_id("WaveC_22"),
				layer_get_id("WaveC_23")
				],
				[ // Medium
				layer_get_id("WaveC_27"),
				layer_get_id("WaveC_10"),
				layer_get_id("WaveC_11"),
				layer_get_id("WaveC_14"),
				layer_get_id("WaveC_15"),
				layer_get_id("WaveC_16"),
				layer_get_id("WaveC_18"),
				layer_get_id("WaveC_21"),
				layer_get_id("WaveC_25"),
				layer_get_id("WaveC_26")
				],
				[ // Hard
				layer_get_id("WaveC_24"),
				layer_get_id("WaveC_28"),
				layer_get_id("WaveC_17")
				]
			];
			
			var layerEnemyMap = ds_map_create();
			for (var i = 0; i < 3; i++) {
				var curHordeArr = mainHordes[i];
				for (var j = 0; j < array_length(curHordeArr); j++) {
					ds_map_add(layerEnemyMap, curHordeArr[j], []);
				}
			}
			for (var i = 0; i < array_length(tutorialHordes); i++) {
				ds_map_add(layerEnemyMap, tutorialHordes[i], []);
			}
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				var curEnemy = instance_find(obj_enemyParent, i);	
				array_push(layerEnemyMap[?curEnemy.layer], curEnemy);
			}
			
			for (var i = 0; i < 3; i++) {
				var curHordeArr = mainHordes[i];
				var curHordeStruct = {
					remainingAmount: array_length(curHordeArr),
					hordes: [], // Matrix of horde objects per horde.
					hordeHasStarted: array_create(array_length(curHordeArr), false) // Boolean
				};
				for (var j = 0; j < array_length(curHordeArr); j++) {
					var curHorde2 = curHordeArr[j];
					var curHordeObjects = layerEnemyMap[?curHorde2];
					var penis = [];
					for (var k = 0; k < array_length(curHordeObjects); k++) {
						var curHordeObject = curHordeObjects[k];
						array_push(penis, [
							curHordeObject.object_index,
							curHordeObject.x,
							curHordeObject.y
						]);
					}
					layer_destroy(curHorde2);
					array_push(curHordeStruct.hordes, penis);
				}
				mainHordes[i] = curHordeStruct;
			}
			// Tutorial horde conversion
			var curHordeStruct = {
				hordes: [], // Matrix of horde objects per horde.
			};
			for (var j = 0; j < array_length(tutorialHordes); j++) {
				var curHorde2 = tutorialHordes[j];
				var curHordeObjects = layerEnemyMap[?curHorde2];
				var penis = [];
				for (var k = 0; k < array_length(curHordeObjects); k++) {
					var curHordeObject = curHordeObjects[k];
					array_push(penis, [
						curHordeObject.object_index,
						curHordeObject.x,
						curHordeObject.y
					]);
				}
				layer_destroy(curHorde2);
				array_push(curHordeStruct.hordes, penis);
			}
			tutorialHordes = curHordeStruct;
		},
		
		roomStartEvent: function() {
			
			initializeHordes();
			/*for (var i = 0; i < array_length(hordeGroups); i++) {
				for (var j = 0; j < array_length(hordeGroups[i]); j++) {
					var curLayer = hordeGroups[i][j];
					layer_set_visible(curLayer, true);
					layer_destroy(curLayer);
				}
			}*/
		},
		stepEvent: function() {
			if (haveHordesStarted) {
				if (array_length(layer_get_all_elements("Enemies")) == 0) {
					if (!hordeIsInCooldown && !hordeIsInRest) {
						selectHorde();
						hordeRestHordeCooldownCur++;
						if (hordeRestHordeCooldownCur >= hordeRestHordeCooldown) {
							hordeIsInRest = true;
							hordeRestHordeCooldownCur = 0;
							hordeRestCooldownCur = hordeRestCooldown;
							obj_hordeRestStuff.spawnPackets();
						}else {
							isTelegraphingHorde = true;
							hordeIsInCooldown = true;
							hordeCooldownCur = hordeCooldown;
						}
					}
					if (hordeIsInCooldown) {
						hordeCooldownCur--;
						if (hordeCooldownCur <= 0) {
							hordeIsInCooldown = false;
							spawnHorde();
						}
					}else if (hordeIsInRest) {
						hordeRestCooldownCur--;
						if (hordeRestCooldownCur <= 100) {
							isTelegraphingHorde = true;
						}
						if (hordeRestCooldownCur <= 0) {
							hordeIsInRest = false;
							spawnHorde();
						}
					}
				}
			}
			
			if (tutorialHasStarted) {
				if (array_length(layer_get_all_elements("Enemies")) == 0) {
					if (!hordeIsInCooldown) {
						if (tutorialHordeIndex == array_length(tutorialHordes.hordes)) {
							tutorialHasStarted = false;
							instance_create_layer(obj_hordeRestStuff.x, obj_hordeRestStuff.y, "Instances", obj_hordeActivation);
							hordeBruhDelay = 300;
						}
						selectHorde();
						isTelegraphingHorde = true;
						hordeIsInCooldown = true;
						hordeCooldownCur = hordeCooldown;
					}
					if (hordeIsInCooldown) {
						hordeCooldownCur--;
						if (hordeCooldownCur <= 0) {
							hordeIsInCooldown = false;
							spawnHorde();
						}
					}
				}
			}
			
			if (hordeBruhDelay > 0) hordeBruhDelay--;
			if (hordeBruhDelay <= 0 && !haveHordesStarted && collision_rectangle(
				CURRENT_MEMBER_INST.bbox_left,
				CURRENT_MEMBER_INST.bbox_top,
				CURRENT_MEMBER_INST.bbox_right,
				CURRENT_MEMBER_INST.bbox_bottom,
				obj_hordeActivation,
				false,
				false
			)) {
				startHorde();
				instance_destroy(obj_hordeActivation);
				if (instance_exists(obj_hordeActivationTutorial)) instance_destroy(obj_hordeActivationTutorial);
			}
			if (!haveHordesStarted && collision_rectangle(
				CURRENT_MEMBER_INST.bbox_left,
				CURRENT_MEMBER_INST.bbox_top,
				CURRENT_MEMBER_INST.bbox_right,
				CURRENT_MEMBER_INST.bbox_bottom,
				obj_hordeActivationTutorial,
				false,
				false
			)) {
				startTutorialHorde();
				instance_destroy(obj_hordeActivation);
				instance_destroy(obj_hordeActivationTutorial);
			}
		},
		selectHorde: function() {
			if (tutorialHasStarted) {
				selectedHorde = tutorialHordes.hordes[tutorialHordeIndex];
				tutorialHordeIndex++;
				return;
			}
			curHordeCredit += creditPerHorde;
			creditPerHorde += creditGainAddPerHorde;
			var creditRandom = irandom(curHordeCredit);
			for (var i = 0; i < 3; i++) {
				if (mainHordes[i].remainingAmount > 0 && (i == 2 || creditRandom <= hordeCreditCost[i+1])) {
					var chosenHordeIndex = undefined;
					do {
						chosenHordeIndex = irandom(array_length(mainHordes[i].hordes)-1);
					}until (!mainHordes[i].hordeHasStarted[chosenHordeIndex]);
							
					curHordeCredit -= hordeCreditCost[i];
							
					// Instantiating the objects
					mainHordes[i].hordeHasStarted[chosenHordeIndex] = true;
					mainHordes[i].remainingAmount--;
					if (mainHordes[i].remainingAmount == 0) {
						for (var j = 0; j < array_length(mainHordes[i].hordeHasStarted[j]); j++) {
							mainHordes[i].hordeHasStarted[j] = false;
						}
					}
					var chosenHorde = mainHordes[i].hordes[chosenHordeIndex];
					selectedHorde = chosenHorde;
					break;
				}
			}
		},
		spawnHorde: function() {
			instance_destroy(obj_healPacket);
			var chosenHorde = selectedHorde;
			for (var j = 0; j < array_length(chosenHorde); j++) {
				var curHordeObject = chosenHorde[j];
				instance_create_layer(curHordeObject[1], curHordeObject[2], "Enemies", curHordeObject[0]);
			}
			isTelegraphingHorde = false;
		},
		startHorde: function() {
			haveHordesStarted = true;
			spawnHorde();
		},
		advanceHorde: function() {
			curHorde++;
		},
		
		#region Tutorial hordes
		startTutorialHorde: function() {
			tutorialHasStarted = true;
		},
		#endregion
		
		drawEndEvent: function() {
			if (isTelegraphingHorde) {
				draw_set_alpha(0.5+random(0.5));
				
				for (var j = 0; j < array_length(selectedHorde); j++) {
					var curHordeObject = selectedHorde[j];
					var curSpr = undefined;
					switch(curHordeObject[0]) {
						case obj_enemyBear:
							curSpr = spr_bearWarn;
							break;
						case obj_enemyMage:
							curSpr = spr_mageEnemyWarn;
							break;
						case obj_enemySentinel:
							curSpr = spr_enemySentinelWarn;
							break;
						case obj_ghostEnemy:
							curSpr = spr_ghosWarn;
							break;
					}
					draw_sprite(curSpr, 0, curHordeObject[1], curHordeObject[2]);
				}
				
				draw_set_alpha(1.0);
			}
		}
	},
	
	cameraSubmanager: {
		gameplayCamera: undefined,
		createEvent: function() {
				
		},
		gameplayStartEvent: function() {
			gameplayCamera = camera_create();
			camera_set_view_size(
				gameplayCamera,
				BASE_RESOLUTION_WIDTH,
				BASE_RESOLUTION_HEIGHT
			);
			room_set_camera(rm_forest_room1, 0, gameplayCamera);
			room_set_view_enabled(rm_forest_room1, true);
			room_set_viewport(rm_forest_room1, 0, true, 0, 0, 1, 1);
		},
		roomStartEvent: function() {
			view_camera[0] = gameplayCamera;
		},
		stepEvent: function() {
			
		},
		notifyPlayerMovementFinish: function() {
			var targCameraX = PartySubmanager.curMemberInst.x-BASE_RESOLUTION_WIDTH/2;
			var targCameraY = PartySubmanager.curMemberInst.y-BASE_RESOLUTION_HEIGHT/2;
			
			var screenRatio = BASE_RESOLUTION_HEIGHT/BASE_RESOLUTION_WIDTH;
			var mouseRatio = 0.4;
			if (InputSubmanager.inputMode == INPUT_DEVICE.controller) {
				targCameraX = (PartySubmanager.curMemberInst.x-BASE_RESOLUTION_WIDTH/2+gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrh)*BASE_RESOLUTION_WIDTH*0.35)*screenRatio*mouseRatio + targCameraX*(1-mouseRatio*screenRatio);
				targCameraY = (PartySubmanager.curMemberInst.y-BASE_RESOLUTION_HEIGHT/2+gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrv)*BASE_RESOLUTION_HEIGHT*0.35)*mouseRatio + targCameraY*(1-mouseRatio);
			}else {
				targCameraX = (global.getMouseX()-BASE_RESOLUTION_WIDTH/2)*screenRatio*mouseRatio + targCameraX*(1-mouseRatio*screenRatio);
				targCameraY = (global.getMouseY()-BASE_RESOLUTION_HEIGHT/2)*mouseRatio + targCameraY*(1-mouseRatio);
			}
			var newCameraX = camera_get_view_x(gameplayCamera) - 0.08*(camera_get_view_x(gameplayCamera) - targCameraX);
			var newCameraY = camera_get_view_y(gameplayCamera) - 0.08*(camera_get_view_y(gameplayCamera) - targCameraY);
			
			newCameraX = clamp(newCameraX, 0, room_width-BASE_RESOLUTION_WIDTH);
			newCameraY = clamp(newCameraY, 0, room_height-BASE_RESOLUTION_HEIGHT);
			camera_set_view_pos(
				gameplayCamera,
				newCameraX,
				newCameraY
			);
		}
	},
	
	partySubmanager: {
		curParty: [],
		curPartySize: undefined,
		curMember: undefined,
		curMemberIndex: undefined,
		curMemberInst: undefined,
		
		memberTypeAmount: 1,
		memberTypes: undefined,
		
		playerIFrames: 0,
		DEBUG_hitIFrames: 0,
		
		createEvent: function() {
			var constructMemberType = function(objI, hlthI) {
				return {
					obj: objI,
					hlth: hlthI,
					hlthMax: hlthI,
					isDown: false,
					stamina: 100,
					staminaMax: 100
				}
			}
			memberTypes = {
				chaincutter: constructMemberType(obj_playerChaincutter, 80),
				archer: constructMemberType(obj_playerArcher, 60)
			}
			
			setCurrentParty([MEMBER_TYPE.chaincutter, MEMBER_TYPE.archer]);
			setCurrentMember(0);
		},
		roomStartEvent: function() {
			initialInstantiateCurrentMember();
		},
		stepEvent: function() {
			for (var i = 0; i < curPartySize; i++) {
				curParty[i].stamina += 0.035;
				if (curParty[i].stamina > curParty[i].staminaMax) curParty[i].stamina = curParty[i].staminaMax;
				if (InputSubmanager.inputMode == INPUT_DEVICE.keyboard && curMemberIndex != i && keyboard_check_pressed(ord(string(i+1)))) {
					if (!curParty[i].isDown) {
						setCurrentMember(i);
						swapInstantiateCurrentMember();
					}
				}
			}
			if (InputSubmanager.inputMode == INPUT_DEVICE.controller && gamepad_is_connected(InputSubmanager.inputGamepad) && gamepad_button_check_pressed(InputSubmanager.inputGamepad, gp_face4)) {
				var i = 0;
				if (curMemberIndex == 0) i = 1;
				if (!curParty[i].isDown) {
					setCurrentMember(i);
					swapInstantiateCurrentMember();
				}
			}
			if (playerIFrames > 0) playerIFrames--;
			if (DEBUG_hitIFrames > 0) DEBUG_hitIFrames--;
		},
		
		setCurrentParty: function(partyI) {
			curParty = partyI;
			curPartySize = array_length(partyI);
			if (curMemberIndex >= curPartySize) {
				curMemberIndex = curPartySize-1;
				curMember = curParty[curMemberIndex];
			}
		},
		
		setCurrentMember: function(indexI) {
			curMemberIndex = indexI;
			curMember = curParty[indexI];
		},
		
		initialInstantiateCurrentMember: function() {
			var newMemberInst = instance_create_layer(
				obj_playerSpawner.x, obj_playerSpawner.y,
				"Instances", // OBSERVATION_LAYER001
				curMember.obj
			);
			curMemberInst = newMemberInst;
			instance_destroy(obj_playerSpawner);
		},
		
		swapInstantiateCurrentMember: function() {
			var newMemberInst = instance_create_layer(
				curMemberInst.x, curMemberInst.y,
				"Instances", // OBSERVATION_LAYER001
				curMember.obj
			);
			curMemberInst.isControlled = false;
			curMemberInst = newMemberInst;
		},
		
		damageCurrentMember: function(dmgI) {
			if (playerIFrames > 0) return false;
			audio_play_sound(snd_playerHit, 0, false, 1.0, 0, 1.0);
			curMember.hlth -= dmgI;
			if (curMember.hlth <= 0) {
				curMember.isDown = true;
				if (MEMBER_TYPE.chaincutter.isDown && MEMBER_TYPE.archer.isDown) {
				}else {
					if (curMemberIndex == 0) {
						setCurrentMember(1);
					}else {
						setCurrentMember(0);
					}
					swapInstantiateCurrentMember();
				}
			}
			playerIFrames = 60;
			DEBUG_hitIFrames = 60;
			return true;
		},
		
		DEBUG_drawSelfDefault: function(instI) {
			if (DEBUG_hitIFrames % 4 <= 1) draw_sprite_ext(
				instI.sprite_index, 0, instI.x, instI.y,
				1.0, 1.0,
				0, c_white,
				(DEBUG_hitIFrames == 0 && playerIFrames > 0) ? 0.5 : 1.0
			);
		}
	},
	
	interfaceSubmanager: {
		physicsMonomanager: {
			construct: function(instI, frictionI) {
				return {
					instance: instI,
					hSpd: 0,
					vSpd: 0,
					appliesFrictionStack: 0,
					isColliding: false,
					knockbackMultiplier: 1.0,
					friction: frictionI
				}
			},
			applySpeed: function(interfaceI) {
				interfaceI.instance.x += interfaceI.hSpd;
				interfaceI.instance.y += interfaceI.vSpd;
			},
			setHSpeed: function(physicsI, spdI) {
				physicsI.hSpd = spdI;
			},
			setVSpeed: function(physicsI, spdI) {
				physicsI.vSpd = spdI;
			},
			addHSpeed: function(physicsI, spdAddI) {
				physicsI.hSpd += spdAddI;
			},
			addVSpeed: function(physicsI, spdAddI) {
				physicsI.vSpd += spdAddI;
			},
			addSpeedToDirection: function(interfaceI, forceI, dirI) {
				addHSpeed(interfaceI, dcos(dirI)*forceI);
				addVSpeed(interfaceI, -dsin(dirI)*forceI);
			},
			
			applyKnockback: function(interfaceI, forceI, dirI) {
				setHSpeed(interfaceI, interfaceI.knockbackMultiplier*dcos(dirI)*forceI);
				setVSpeed(interfaceI, interfaceI.knockbackMultiplier*-dsin(dirI)*forceI);
			},
	
			targetHSpeed: function(physicsI, targSpdI, spdAddI) {
				if (abs(physicsI.hSpd-targSpdI) <= spdAddI) physicsI.hSpd = targSpdI;
				else physicsI.hSpd += sign(targSpdI-physicsI.hSpd)*spdAddI;
			},
			targetVSpeed: function(physicsI, targSpdI, spdAddI) {
				if (abs(physicsI.vSpd-targSpdI) <= spdAddI) physicsI.vSpd = targSpdI;
				else physicsI.vSpd += sign(targSpdI-physicsI.vSpd)*spdAddI;
			},
			targetNullSpeed: function(physicsI, spdAddI) {
				var curAngle = point_direction(0, 0, physicsI.hSpd, physicsI.vSpd);
				var curSpd = point_distance(0, 0, physicsI.hSpd, physicsI.vSpd);
		
				var curHSub = dcos(curAngle)*spdAddI;
				var curVSub = -dsin(curAngle)*spdAddI;
				if (point_distance(0, 0, physicsI.hSpd, physicsI.vSpd) <= spdAddI) {
					physicsI.hSpd = 0;
					physicsI.vSpd = 0;
				}else {
					physicsI.hSpd -= curHSub;
					physicsI.vSpd -= curVSub;
				}
			},
	
			targetMaxHSpeed: function(physicsI, maxSpdI, spdAddI) {
				if (sign(maxSpdI)*physicsI.hSpd >= abs(maxSpdI)-spdAddI) {
					physicsI.hSpd = maxSpdI;
				}else physicsI.hSpd += sign(maxSpdI)*spdAddI;
			},
			targetMaxVSpeed: function(physicsI, maxSpdI, spdAddI) {
				if (sign(maxSpdI)*physicsI.vSpd >= abs(maxSpdI)-spdAddI) {
					physicsI.vSpd = maxSpdI;
				}else physicsI.vSpd += sign(maxSpdI)*spdAddI;
			},
			targetMaxSpeedToDirection: function(physicsI, maxSpdI, spdAddI, directionI) {
				var curSpd = point_distance(0, 0, physicsI.hSpd, physicsI.vSpd);
				var curAngle = point_direction(0, 0, physicsI.hSpd, physicsI.vSpd);
				
				var curSpdToDir = dcos(curAngle-directionI)*curSpd;
				if (curSpdToDir < maxSpdI) {
					if (curSpdToDir+spdAddI <= maxSpdI) {
						physicsI.hSpd += dcos(directionI)*spdAddI;
						physicsI.vSpd += -dsin(directionI)*spdAddI;
					}else {
						physicsI.hSpd += dcos(directionI)*(maxSpdI-curSpdToDir);
						physicsI.vSpd += -dsin(directionI)*(maxSpdI-curSpdToDir);
					}
				}
			},
			
			// Friction
			applyFriction: function(physicsI) {
				if (physicsI.appliesFrictionStack == 0) targetNullSpeed(physicsI, physicsI.friction);
			},
	
			// Collisions
			applyCollision: function(physicsI) {
				physicsI.isColliding = false;
				with (physicsI.instance) {
					if (place_meeting(x+physicsI.hSpd, y, obj_collision)) {
						physicsI.isColliding = true;
						while (!place_meeting(x+sign(physicsI.hSpd), y, obj_collision)) {
							x += sign(physicsI.hSpd);
						}
						physicsI.hSpd = 0;
					}
			
					if (place_meeting(x, y+physicsI.vSpd, obj_collision)) {
						physicsI.isColliding = true;
						while (!place_meeting(x, y+sign(physicsI.vSpd), obj_collision)) {
							y += sign(physicsI.vSpd);
						}
						physicsI.vSpd = 0;
					}
				}
			},
			
			stepInterface: function(physicsI) {
				if (physicsI.appliesFrictionStack == 0) applyFriction(physicsI);
				applySpeed(physicsI);
			},
			
			// Corrections
			correntDiagonalMovement: function(physicsI) {
				var spdDiff = abs(abs(physicsI.hSpd) - abs(physicsI.vSpd));
				if (spdDiff <= 0.1) {
					if (abs(physicsI.hSpd) < abs(physicsI.vSpd)) physicsI.hSpd = sign(physicsI.hSpd)*abs(physicsI.vSpd);
					else physicsI.vSpd = sign(physicsI.vSpd)*abs(physicsI.hSpd);
					
					if (physicsI.instance.x != physicsI.instance.y) {
						physicsI.instance.x = round(physicsI.instance.x);
						physicsI.instance.y = round(physicsI.instance.y);
					}
				}
			}
		}
	},
	
	entitySubmanager: {
		enemySubmanager: {
			damageEnemy: function(enemyI, dmgI) {
				if (!instance_exists(enemyI)) return;
				audio_play_sound_at(snd_enemyHit, 0, 0, 0, 100, 0, 1, false, 0, 0.3, 0, 0.8+random(0.3));
				enemyI.hlth -= dmgI;
				enemyI.electricityDebuff.notifyDamage(dmgI);
				enemyI.fireDebuff.notifyDamage(dmgI);
				if (!instance_exists(enemyI)) return;
				if (enemyI.hlth <= 0) {
					instance_destroy(enemyI);
				}
			},
			damageEnemyElectric: function(enemyI, dmgI) {
				if (!instance_exists(enemyI)) return;
				audio_play_sound_at(snd_enemyHit, 0, 0, 0, 100, 0, 1, false, 0, 0.3, 0, 1.4+random(0.3));
				enemyI.hlth -= dmgI/10*enemyI.electricityDebuff.curStacks;
				if (enemyI.hlth <= 0) {
					instance_destroy(enemyI);
				}
			},
			damageEnemyFire: function(enemyI, dmgI) {
				if (!instance_exists(enemyI)) return;
				audio_play_sound_at(snd_enemyHit, 0, 0, 0, 100, 0, 1, false, 0, 0.3, 0, 1.4+random(0.3));
				enemyI.hlth -= dmgI;
				if (enemyI.hlth <= 0) {
					instance_destroy(enemyI);
				}
			},
			stunEnemyTemporary: function(enemyI, stunFramesI, ignoreInvincibilityI = false) {
				if (!instance_exists(enemyI) || (enemyI.stun.canBeStunnedStack != 0 && !ignoreInvincibilityI)) return;
				enemyI.notifyStunApply();
				enemyI.stun.framesCur = stunFramesI;
				if (!enemyI.stun.isStunnedTemporary) {
					enemyI.stun.isStunnedStack++;
					enemyI.stun.isStunnedTemporary = true;
					enemyI.notifyStunStart();
				}
			},
			stunEnemy: function(enemyI, ignoreInvincibilityI) {
				if (!instance_exists(enemyI) || (enemyI.stun.canBeStunnedStack != 0 && !ignoreInvincibilityI)) return;
				enemyI.notifyStunApply();
				if (enemyI.stun.isStunnedStack == 0) {
					enemyI.notifyStunStart();
				}
				enemyI.stun.isStunnedStack++;
			},
			removeStunStack: function(enemyI) {
				if (!instance_exists(enemyI)) return;
				enemyI.stun.isStunnedStack--;
				show_debug_message(enemyI.stun.isStunnedStack);
				if (enemyI.stun.isStunnedStack == 0) enemyI.notifyStunEnd();
			},
			applyElectricity: function(enemyI, stacksI) {
				if (!instance_exists(enemyI)) return;
				enemyI.electricityDebuff.curStacks += stacksI;
				enemyI.electricityDebuff.isActive = true;
			},
			applyFire: function(enemyI, stacksI) {
				if (!instance_exists(enemyI)) return;
				enemyI.fireDebuff.curStacks += stacksI;
				enemyI.fireDebuff.isActive = true;
			}
		}
	},
	
	actionAssetSubmanager: {
		slash: {
			construct: function(instI) {
				return {
					_p: instI,
					curSlashInst: undefined,
					isBeingDone: false,
					canBeDoneStack: 0,
					hitFrames: undefined,
					hitFramesCur: undefined,
					hitBox: undefined,
					direction: undefined,
					targetMap: undefined,
					hitFunction: undefined,
					startDefault: function(hitFramesI, hitBoxI, directionI, targetMapI, hitFunctionI) {
						if (canBeDoneStack == 0) {
							isBeingDone = true;
							hitFrames = hitFramesI;
							hitFramesCur = 0;
							hitBox = hitBoxI;
							direction = directionI;
							targetMap = targetMapI;
							hitFunction = hitFunctionI;
							curSlashInst = instance_create_layer(
								_p.x, _p.y,
								"Collision",
								actObj_slash,
								{
									hitBox: hitBoxI,
									direction: directionI,
									image_angle: directionI,
									mask_index: hitBoxI
								}
							);
						}
					},
					stop: function() {
						ActionObjectSubmanager.slash.stop(self);
					}
				}
			},
			step: function(slashI) {
				with (slashI) {
					if (isBeingDone) {
						curSlashInst.x = slashI._p.x;
						curSlashInst.y = slashI._p.y;
						with (curSlashInst) {
							image_angle = direction;
							var curTargetArr = ds_map_keys_to_array(slashI.targetMap);
							for (var i = 0; i < array_length(curTargetArr); i++) {
								if (place_meeting(x, y, curTargetArr[i])) {
									slashI.hitFunction(curTargetArr[i]);
									ds_map_delete(slashI.targetMap, curTargetArr[i]);
								}
							}
						}
						hitFramesCur++;
						if (hitFramesCur == hitFrames) stop();
					}
				}
			},
			stop: function(slashI) {
				with (slashI) {
					isBeingDone = false;
					_p.notifySlashStop(); // OBSERVATION_ACTIONOBJECT002: Differentiate between default stops and interruption stop.
					ds_map_destroy(targetMap);
					instance_destroy(curSlashInst);
				}
			}
		}
	},
	
	inputSubmanager: {
		inputMode: INPUT_DEVICE.controller,
		inputGamepad: 0,
		inputTypes: [0, 0, 0, 0],
		initializeInputTypes: function() {
			var createInputType = function(keyboardI, mouseI, gamepadI) {
				return {
					keyboard: keyboardI,
					mouse: mouseI,
					gamepad: gamepadI
				};
			}
			inputTypes[INPUT_TYPE.primary] = createInputType(undefined, mb_left, gp_shoulderrb);
			inputTypes[INPUT_TYPE.secondary] = createInputType(undefined, mb_right, gp_shoulderlb);
			inputTypes[INPUT_TYPE.utility] = createInputType(vk_shift, undefined, gp_face1);
			inputTypes[INPUT_TYPE.memberSwitch] = createInputType(vk_shift, undefined, gp_face4);
		},
		isInputContinuous: function(inputTypeI) {
			var curType = inputTypes[inputTypeI];
			if (inputMode == INPUT_DEVICE.keyboard) {
				if (curType.mouse == undefined)
					return keyboard_check(curType.keyboard);
				else
					return mouse_check_button(curType.mouse);
			}else
				return gamepad_button_check(inputGamepad, curType.gamepad);
		},
		isInputReleased: function(inputTypeI) {
			var curType = inputTypes[inputTypeI];
			if (inputMode == INPUT_DEVICE.keyboard) {
				if (curType.mouse == undefined)
					return keyboard_check_released(curType.keyboard);
				else
					return mouse_check_button_released(curType.mouse);
			}else
				return gamepad_button_check_released(inputGamepad, curType.gamepad);
		},
		isInputPressed: function(inputTypeI) {
			var curType = inputTypes[inputTypeI];
			if (inputMode == INPUT_DEVICE.keyboard) {
				if (curType.mouse == undefined)
					return keyboard_check_pressed(curType.keyboard);
				else
					return mouse_check_button_pressed(curType.mouse);
			}else
				return gamepad_button_check_pressed(inputGamepad, curType.gamepad);
		},
		
		createEvent: function() {
			initializeInputTypes();
			joystick.create();
			joystick2.create();
		},
		endStepEvent: function() {
			for (var i = 0; i < 16; i++) {
				if (gamepad_is_connected(i)) {
					inputGamepad = i;
					gamepad_set_axis_deadzone(i, 0.2);
				}
			}
			
			if (keyboard_check_pressed(vk_anykey)) {
				inputMode = INPUT_DEVICE.keyboard;
			}else if (gamepad_button_check_pressed(inputGamepad, gp_select)) {
				inputMode = INPUT_DEVICE.controller;
			}
		},
		
		joystick: {
			_manager: undefined,
			isPressed: false,
			
			create: function() {
				_manager = InputSubmanager;
			},
			
			isBeingPressed: function() {
				switch (_manager.inputMode) {
					case INPUT_DEVICE.keyboard:
						return (keyboard_check(ord("D")) - keyboard_check(ord("A")) != 0) || (keyboard_check(ord("S")) - keyboard_check(ord("W")) != 0);
					case INPUT_DEVICE.controller:
						return gamepad_axis_value(InputSubmanager.inputGamepad, gp_axislh) != 0 || gamepad_axis_value(InputSubmanager.inputGamepad, gp_axislv) != 0
				}
			},
			returnDirection: function() {
				switch (_manager.inputMode) {
					case INPUT_DEVICE.keyboard:
						var hMove = keyboard_check(ord("D")) - keyboard_check(ord("A"));
						var vMove = keyboard_check(ord("S")) - keyboard_check(ord("W"));
						if (hMove == 0 && vMove == 0) show_error("Error in GameplayManager.InputSubmanager: Trying to retrieve angle from joystick despite not being pressed.", true);
						return KEYBOARD_DIRECTION_MATRIX[vMove+1][hMove+1];
					case INPUT_DEVICE.controller:
						return point_direction(
							0, 0, 
							gamepad_axis_value(InputSubmanager.inputGamepad, gp_axislh),
							gamepad_axis_value(InputSubmanager.inputGamepad, gp_axislv)
						);
				}
			}
		},
		joystick2: {
			_manager: undefined,
			isPressed: false,
			
			create: function() {
				_manager = InputSubmanager;
			},
			
			isBeingPressed: function() {
				return true;
			},
			returnDirection: function(playerInstI = CURRENT_MEMBER_INST) {
				switch (_manager.inputMode) {
					case INPUT_DEVICE.keyboard:
						return point_direction(
							playerInstI.x,
							playerInstI.y,
							global.getMouseX(),
							global.getMouseY()
						);
					case INPUT_DEVICE.controller:
						return point_direction(
							0, 0, 
							gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrh),
							gamepad_axis_value(InputSubmanager.inputGamepad, gp_axisrv)
						);
				}
			}
		}
	},
	
	hudSubmanager: {
		drawEndEvent: function() {
			var DEBUG_drawBar = function(xI, yI, widthI, heightI, colorI, ratioI) {
				draw_set_color(c_black);
				draw_rectangle(
					xI, yI,
					xI+widthI, yI+heightI,
					false
				);
				draw_set_color(colorI);
				draw_rectangle(
					xI, yI,
					xI+ratioI*widthI, yI+heightI,
					false
				);
			}
			
			for (var i = 0; i < instance_number(obj_enemyParent); i++) {
				var curEnemy = instance_find(obj_enemyParent, i);
				DEBUG_drawBar(
					curEnemy.x - 20,
					curEnemy.y - 40,
					40,
					6, c_green, curEnemy.hlth/curEnemy.hlthMax
				);
			}
		},
		drawGUIEvent: function() {
			var DEBUG_drawBar = function(xI, yI, widthI, heightI, colorI, ratioI) {
				draw_set_color(c_black);
				draw_rectangle(
					xI, yI,
					xI+widthI, yI+heightI,
					false
				);
				draw_set_color(colorI);
				draw_rectangle(
					xI, yI,
					xI+ratioI*widthI, yI+heightI,
					false
				);
			}
			
			var DEBUG_partySprites = [ // OBSERVATION_HUD001: The logo sprite for each member should be within the member type's class.
				spr_playerChaincutterLogo,
				spr_playerArcherLogo
			];
			
			draw_set_alpha(0.5);
			draw_set_colour(c_black);
			draw_rectangle(10, 10, 10+68-1, 10+48-1, false);
			draw_set_alpha(1.0);
			draw_sprite_ext(
				DEBUG_partySprites[PartySubmanager.curMemberIndex], 0,
				10, 10,
				2.0, 2.0, 0, c_white, 1.0
			);
			DEBUG_drawBar(90, 10, 150, 15, c_green, PartySubmanager.curMember.hlth/PartySubmanager.curMember.hlthMax);
			DEBUG_drawBar(90, 34, 150, 15, c_orange, PartySubmanager.curMember.stamina/PartySubmanager.curMember.staminaMax);
			
			var curIndex = 0;
			for (var i = 0; i < PartySubmanager.curPartySize; i++) {
				if (i != PartySubmanager.curMemberIndex) {
					var curMemberItem = PartySubmanager.curParty[i];
					var curX = 260+curIndex*120;
				
					draw_sprite(DEBUG_partySprites[i], 0, curX, 10);
					DEBUG_drawBar(curX+36, 10, 54, 8, c_green, curMemberItem.hlth/curMemberItem.hlthMax);
					DEBUG_drawBar(curX+36, 24, 54, 8, c_orange, curMemberItem.stamina/curMemberItem.staminaMax);
					curIndex++;
				}
			}
		}
	}
	
	#endregion
}
GameplayManager.createEvent();

#endregion

window_set_size(BASE_RESOLUTION_WIDTH*RESOLUTION_SCALE, BASE_RESOLUTION_HEIGHT*RESOLUTION_SCALE);
window_center();
gpu_set_tex_filter(false);

randomise();
room_goto(rm_forest_room1);