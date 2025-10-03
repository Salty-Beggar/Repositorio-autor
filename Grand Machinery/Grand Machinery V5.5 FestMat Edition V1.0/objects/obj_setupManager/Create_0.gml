 /// @description Insert description here
// You can write your code in this editor

/// @description Insert description here
// You can write your code in this editor

canStartGame = true;
randomize();

#region Resolution

#macro gameResolutionWidth 800
#macro gameResolutionHeight 600
#macro gameResolutionScale 1

#endregion

window_set_size(gameResolutionWidth*gameResolutionScale, gameResolutionHeight*gameResolutionScale);
window_center();

#region All-game permanent object setup

instance_create_depth(0, 0, 0, obj_gameManager);

#endregion

#region Input manager

	#region Input manager itself

	#region Temporary function definition

	var constructInputClass = function() {
		return {
			keyboard: {},
			controller: {},
			mobileIsPressed: false
		}
	}

	var debugCreateKeyboardStruct = function(keyI, isImmediateI, isReleaseI) {
		return {
			key: keyI,
			isImmediate: isImmediateI,
			isRelease: isReleaseI
		}
	}
	
	var debugCreateControllerStruct = function(axisI, isAnalogI, valueI, isImmediateI, isReleaseI) {
		return {
			axis: axisI,
			value: valueI,
			isImmediate: isImmediateI,
			isRelease: isReleaseI,
			isAnalog: isAnalogI
		}
	}

	#endregion

	#macro InputManager global.inputManager
	enum input_ID {
		primaryUse = 0,
		primaryUseI = 17,
		secondaryUse = 16,
		secondaryUseI = 19,
		left = 1,
		right = 2,
		interact = 3,
		down = 4,
		jump = 5,
		restart = 6,
		seeHUD = 7,
		dash = 8,
		dashStart = 10,
		dashEnd = 11,
		dashHold = 18,
		hlthPacket = 9,
		pause = 12,
		escape = 13,
		advance = 14,
		hlthPacketContinuous = 15
	}

	global.inputManager = {
		array: array_create(20),
	
		isControllerActivated: false,
		inputController: -1,
		endStepFunction: function() {
			for (var i = 0; i < 16; i++) {
				if (gamepad_is_connected(i))
					inputController = i;
			}
		},
		isInputActivated: function(inputIndexI) {
			// Keyboard
			var curStruct = array[inputIndexI].keyboard;
			if (curStruct.isRelease) {
				if (keyboard_check_released(curStruct.key)) return true;
			}else if (curStruct.isImmediate) {
				if (keyboard_check_pressed(curStruct.key)) return true;
			}else {
				if (keyboard_check(curStruct.key)) return true;
			}
			
			// Input
			if (array[inputIndexI].mobileIsPressed) {
				return true;
			}
	
			// Controller OBSERVATION001 - Add controller support.
			var curStruct = array[inputIndexI].controller;
			if (!curStruct.isAnalog) {
				if (curStruct.isRelease) {
					if (gamepad_button_check_released(inputController, curStruct.axis)) return true;
				}else if (curStruct.isImmediate) {
					if (gamepad_button_check_pressed(inputController, curStruct.axis)) return true;
				}else {
					if (gamepad_button_check(inputController, curStruct.axis)) return true;
				}
			}else {
				if (gamepad_axis_value(inputController, curStruct.axis) == curStruct.value) return true;
			}
			return false;
		}
	}

	with (InputManager) {
		var length = array_length(array);
		for (var i = 0; i < length; i++) {
			array[i] = constructInputClass();
		}
	
		array[input_ID.primaryUse].keyboard = debugCreateKeyboardStruct(ord("Z"), false, false);
		array[input_ID.primaryUseI].keyboard = debugCreateKeyboardStruct(ord("Z"), true, false);
		array[input_ID.secondaryUse].keyboard = debugCreateKeyboardStruct(ord("X"), false, false);
		array[input_ID.secondaryUseI].keyboard = debugCreateKeyboardStruct(ord("X"), true, false);
		array[input_ID.left].keyboard = debugCreateKeyboardStruct(vk_left, false, false);
		array[input_ID.right].keyboard = debugCreateKeyboardStruct(vk_right, false, false);
		array[input_ID.interact].keyboard = debugCreateKeyboardStruct(vk_up, true, false);
		array[input_ID.down].keyboard = debugCreateKeyboardStruct(vk_down, false, false);
		array[input_ID.jump].keyboard = debugCreateKeyboardStruct(vk_space, false, false);
		array[input_ID.restart].keyboard = debugCreateKeyboardStruct(ord("R"), true, false);
		array[input_ID.seeHUD].keyboard = debugCreateKeyboardStruct(ord("F"), false, false);
		array[input_ID.dash].keyboard = debugCreateKeyboardStruct(vk_shift, false, false);
		array[input_ID.dashStart].keyboard = debugCreateKeyboardStruct(vk_shift, true, false);
		array[input_ID.dashHold].keyboard = debugCreateKeyboardStruct(vk_shift, false, false);
		array[input_ID.dashEnd].keyboard = debugCreateKeyboardStruct(vk_shift, false, true);
		array[input_ID.hlthPacketContinuous].keyboard = debugCreateKeyboardStruct(ord("A"), false, false);
		array[input_ID.hlthPacket].keyboard = debugCreateKeyboardStruct(ord("A"), true, false);
		array[input_ID.pause].keyboard = debugCreateKeyboardStruct(vk_escape, true, false);
		array[input_ID.escape].keyboard = debugCreateKeyboardStruct(vk_escape, true, false);
		array[input_ID.advance].keyboard = debugCreateKeyboardStruct(vk_enter, true, false);
	
		array[input_ID.primaryUse].controller = debugCreateControllerStruct(gp_face3, false, 1, false, false);
		array[input_ID.primaryUseI].controller = debugCreateControllerStruct(gp_face3, false, 1, true, false);
		array[input_ID.secondaryUse].controller = debugCreateControllerStruct(gp_face2, false, 1, false, false);
		array[input_ID.secondaryUseI].controller = debugCreateControllerStruct(gp_face2, false, 1, true, false);
		array[input_ID.left].controller = debugCreateControllerStruct(gp_axislh, true, -1, false, false);
		array[input_ID.right].controller = debugCreateControllerStruct(gp_axislh, true, 1, false, false);
		array[input_ID.interact].controller = debugCreateControllerStruct(gp_axislv, true, -1, false, false);
		array[input_ID.down].controller = debugCreateControllerStruct(gp_axislv, true, 1, false, false);
		array[input_ID.jump].controller = debugCreateControllerStruct(gp_face1, false, 1, false, false);
		array[input_ID.restart].controller = debugCreateControllerStruct(gp_start, false, 1, true, false);
		array[input_ID.seeHUD].controller = debugCreateControllerStruct(gp_shoulderl, false, 1, false, false);
		array[input_ID.dash].controller = debugCreateControllerStruct(gp_shoulderr, false, 1, false, false);
		array[input_ID.dashStart].controller = debugCreateControllerStruct(gp_shoulderr, false, 1, true, false);
		array[input_ID.dashHold].controller = debugCreateControllerStruct(gp_shoulderr, false, 1, false, false);
		array[input_ID.dashEnd].controller = debugCreateControllerStruct(gp_shoulderr, false, 1, false, true);
		array[input_ID.hlthPacketContinuous].controller = debugCreateControllerStruct(gp_face4, false, 1, false, false);
		array[input_ID.hlthPacket].controller = debugCreateControllerStruct(gp_face4, false, 1, true, false);
		array[input_ID.pause].controller = debugCreateControllerStruct(gp_select, false, 1, true, false);
		array[input_ID.escape].controller = debugCreateControllerStruct(gp_select, false, 1, true, false);
		array[input_ID.advance].controller = debugCreateControllerStruct(gp_face2, false, 1, true, false);
	}

	#endregion
	
	#region Mobile control manager
	
	#macro MobileControlManager global.mobileControlManager
	
	global.mobileControlManager = {
		isActive: false,
		gameplay: {
			curDeviceIndex: 0,
			deviceIndexStructArr: [],
			defineDeviceIndex: function(structI) {
				structI.isDeviceIndexDefined = true;
				structI.deviceIndex = curDeviceIndex;
				curDeviceIndex++;
				for (var i = 0; i < array_length(deviceIndexStructArr); i++) {
					if (!deviceIndexStructArr[i].isDeviceIndexDefined) deviceIndexStructArr[i].deviceIndex = curDeviceIndex;
				}
			},
			resetDeviceIndex: function(structI) {
				structI.isDeviceIndexDefined = false;
				curDeviceIndex--;
				for (var i = 0; i < array_length(deviceIndexStructArr); i++) {
					if (!deviceIndexStructArr[i].isDeviceIndexDefined) deviceIndexStructArr[i].deviceIndex = curDeviceIndex;
				}
			},
			movementStick: {
				x: 20, y: 480,
				isDeviceIndexDefined: false,
				deviceIndex: 0,
				width: sprite_get_width(spr_movementJoystick), height: sprite_get_height(spr_movementJoystick),
				boxSprite: spr_movementJoystick,
				gradientSprite: spr_movementJoystickGradient,
				slideColor: c_orange,
				sliderGradientColor: c_orange,
				sliderGradientAlpha: 0.4,
				sliderGradientBlinkFrames: 50,
				sliderGradientBlinkFramesCur: 0,
				sliderGradientBlinkAlphaAdd: 0.6,
				pointer: {
					isHolding: false,
					sprite: spr_movementJoystickBall,
					size: sprite_get_width(spr_movementJoystickBall)/2,
					touchSize: 40,
					defX: sprite_get_width(spr_movementJoystick)/2, defY: sprite_get_width(spr_movementJoystickBall)/2,
					bottomYLimit: sprite_get_height(spr_movementJoystick)-sprite_get_width(spr_movementJoystickBall)/2-2
				},
				
				tick: function() {
					var curMouseX = device_mouse_x_to_gui(deviceIndex);
					var curMouseY = device_mouse_y_to_gui(deviceIndex);
					if (
						!pointer.isHolding &&
						device_mouse_check_button_pressed(deviceIndex, mb_left) &&
						curMouseX > x+pointer.defX-pointer.touchSize &&
						curMouseX < x+pointer.defX+pointer.touchSize &&
						curMouseY > y+pointer.defY-pointer.touchSize &&
						curMouseY < y+pointer.defY+pointer.touchSize
					) {
						pointer.isHolding = true;
						MobileControlManager.gameplay.defineDeviceIndex(self);
					}else if (pointer.isHolding && device_mouse_check_button_released(deviceIndex, mb_left)) {
						pointer.isHolding = false;
						MobileControlManager.gameplay.resetDeviceIndex(self);
					}
					
					if (sliderGradientBlinkFramesCur != 0) {
						sliderGradientBlinkFramesCur--;
					}
					
					if (pointer.isHolding) {
						if (curMouseX < x+pointer.defX) {
							InputManager.array[input_ID.left].mobileIsPressed = true;
							InputManager.array[input_ID.right].mobileIsPressed = false;
						}else {
							InputManager.array[input_ID.right].mobileIsPressed = true;
							InputManager.array[input_ID.left].mobileIsPressed = false;
						}
						
						InputManager.array[input_ID.dashStart].mobileIsPressed = false;
						InputManager.array[input_ID.dashEnd].mobileIsPressed = false;
						if (curMouseY > y+pointer.bottomYLimit && !InputManager.array[input_ID.dash].mobileIsPressed) {
							InputManager.array[input_ID.dash].mobileIsPressed = true;
							InputManager.array[input_ID.dashStart].mobileIsPressed = true;
							sliderGradientBlinkFramesCur = sliderGradientBlinkFrames;
						}else if (curMouseY <= y+pointer.bottomYLimit && InputManager.array[input_ID.dash].mobileIsPressed) {
							InputManager.array[input_ID.dash].mobileIsPressed = false;
							InputManager.array[input_ID.dashEnd].mobileIsPressed = true;
						}
					}else {
						InputManager.array[input_ID.right].mobileIsPressed = false;
						InputManager.array[input_ID.left].mobileIsPressed = false;
						if (InputManager.array[input_ID.dash].mobileIsPressed) {
							InputManager.array[input_ID.dash].mobileIsPressed = false;
							InputManager.array[input_ID.dashEnd].mobileIsPressed = true;
						}
					}
				},
				
				draw: function() {
					draw_sprite(boxSprite, 0, x, y);
					var curGradientAlpha = sliderGradientAlpha+sliderGradientBlinkFramesCur/sliderGradientBlinkFrames*sliderGradientBlinkAlphaAdd;
					draw_sprite_ext(gradientSprite, 0, x, y, 1.0, 1.0, 0, sliderGradientColor, curGradientAlpha);
					var curPointerX = x+pointer.defX;
					var curPointerY = y+pointer.defY;
					if (pointer.isHolding) {
						curPointerX = clamp(device_mouse_x_to_gui(0), x+pointer.size+2, x+width-pointer.size-2);
						curPointerY = clamp(device_mouse_y_to_gui(0), curPointerY, y+pointer.bottomYLimit);
					}
					var curPointerColor = (InputManager.array[input_ID.dash].mobileIsPressed) ? slideColor : c_white;
					draw_sprite_ext(pointer.sprite, 0, curPointerX, curPointerY, 1.0, 1.0, 0, curPointerColor, 1.0);
					
					draw_set_alpha(1.0);
				}
			},
			quickActionInput: {
				deviceIndex: 0,
				isDeviceIndexDefined: false,
				x: 540, y: 525, middleX: 540+165/2,
				buttonDetectXAdd: 96,
				moldSprite: spr_quickActionMold,
				leftButtonSpr: spr_quickActionButtonLeft,
				rightButtonSpr: spr_quickActionButtonRight,
				leftButtonInputIndex: input_ID.jump,
				rightButtonInputIndex: input_ID.primaryUse,
				width: sprite_get_width(spr_quickActionMold), height: sprite_get_height(spr_quickActionMold),
				tick: function() {
					var curMouseX = device_mouse_x_to_gui(deviceIndex);
					var curMouseY = device_mouse_y_to_gui(deviceIndex);
					if (device_mouse_check_button(deviceIndex, mb_left)) {
						if (
							!InputManager.array[leftButtonInputIndex].mobileIsPressed &&
							curMouseX > middleX-buttonDetectXAdd && curMouseX < middleX &&
							curMouseY > y && curMouseY < y+height
						) {
							InputManager.array[leftButtonInputIndex].mobileIsPressed = true;
							MobileControlManager.gameplay.defineDeviceIndex(self);
						}else if (
							InputManager.array[leftButtonInputIndex].mobileIsPressed &&
							(curMouseX < middleX-buttonDetectXAdd || curMouseX > middleX ||
							curMouseY < y || curMouseY > y+height)
						) {
							InputManager.array[leftButtonInputIndex].mobileIsPressed = false;
							MobileControlManager.gameplay.resetDeviceIndex(self);
						}else if (
							!InputManager.array[rightButtonInputIndex].mobileIsPressed &&
							curMouseX > middleX && curMouseX < middleX+buttonDetectXAdd &&
							curMouseY > y && curMouseY < y+height
						) {
							InputManager.array[rightButtonInputIndex].mobileIsPressed = true;
							MobileControlManager.gameplay.defineDeviceIndex(self);
						}else if (
							InputManager.array[rightButtonInputIndex].mobileIsPressed &&
							(curMouseX > middleX || curMouseX < middleX+buttonDetectXAdd ||
							curMouseY < y || curMouseY > y+height)
						) {
							InputManager.array[rightButtonInputIndex].mobileIsPressed = false;
							MobileControlManager.gameplay.resetDeviceIndex(self);
						}
					}else {
						if (InputManager.array[leftButtonInputIndex].mobileIsPressed) {
							InputManager.array[leftButtonInputIndex].mobileIsPressed = false;
							MobileControlManager.gameplay.resetDeviceIndex(self);
						}else if (InputManager.array[rightButtonInputIndex].mobileIsPressed) {
							InputManager.array[rightButtonInputIndex].mobileIsPressed = false;
							MobileControlManager.gameplay.resetDeviceIndex(self);
						}
					}
				},
				draw: function() {
					//draw_rectangle(middleX, 0, middleX, gameResolutionWidth, false);
					draw_sprite(moldSprite, 0, x, y);
					draw_sprite(leftButtonSpr, 0, x, y);
					draw_sprite(rightButtonSpr, 0, x, y);
				}
			},
			buttonArr: array_create(1), index: 0, buttonAmount: 1,
			tickButton: function(buttonI) {
				with (buttonI) {
					var curMouseX = device_mouse_x_to_gui(0);
					var curMouseY = device_mouse_y_to_gui(0);
					if (inputIndexRelease != undefined) InputManager.array[inputIndexRelease].mobileIsPressed = false;
					if (inputIndexImmediate != undefined) InputManager.array[inputIndexImmediate].mobileIsPressed = false;
					if (
						!InputManager.array[inputIndex].mobileIsPressed && device_mouse_check_button_pressed(0, mb_left) &&
						curMouseX > x-size && curMouseX < x+size &&
						curMouseY > y-size && curMouseY < y+size
					) {
						InputManager.array[inputIndex].mobileIsPressed = true;
						if (inputIndexImmediate != undefined) InputManager.array[inputIndexImmediate].mobileIsPressed = true;
					}else if (InputManager.array[inputIndex].mobileIsPressed && device_mouse_check_button_released(0, mb_left)) {
						InputManager.array[inputIndex].mobileIsPressed = false;
						if (inputIndexRelease != undefined) InputManager.array[inputIndexRelease].mobileIsPressed = true;
					}
				}
			},
			drawButton: function(buttonI) {
				draw_set_alpha(0.2);
				draw_circle(buttonI.x, buttonI.y, buttonI.size, false);
				draw_set_alpha(1.0);
			},
			createButton: function(xI, yI, sizeI, inputIndexI, inputIndexImmediateI = undefined, inputIndexReleaseI = undefined) {
				buttonArr[index] = {
					x: xI, y: yI, size: sizeI,
					inputIndex: inputIndexI, inputIndexImmediate: inputIndexImmediateI, inputIndexRelease: inputIndexReleaseI
				};
				index++;
			},
			initializeButtons: function() {
				//createButton(600, 520, 30, input_ID.jump);
				//createButton(670, 500, 30, input_ID.primaryUse);
				createButton(630, 450, 30, input_ID.hlthPacketContinuous, input_ID.hlthPacket);
			},
			buttonJump: {
				x: 600, y: 520, size: 30, inputIndex: input_ID.jump
			},
			beginStepEvent: function() {
				for (var i = 0; i < buttonAmount; i++) {
					tickButton(buttonArr[i]);
				}
				movementStick.tick();
				quickActionInput.tick();
			},
			drawGUIEvent: function() {
				for (var i = 0; i < buttonAmount; i++) {
					drawButton(buttonArr[i]);
				}
				movementStick.draw();
				quickActionInput.draw();
			},
			initialize: function() {
				initializeButtons();
				deviceIndexStructArr = [quickActionInput, movementStick];
			}
		},
		initialize: function() {
			gameplay.initialize();
		}
	}
	
	MobileControlManager.initialize();
	
	#endregion
	
#endregion

#region Language

#macro lng_continue "Continuar"
#macro lng_levels "Fases"
#macro lng_shop "Loja"
#macro lng_leaderboard "Placar"
#macro lng_exit "Sair"

#macro lng_levelMenu_points "Pontos:"
#macro lng_levelMenu_time "Tempo:"
#macro lng_levelMenu_challenges "Desafios:"
#macro lng_levelMenu_playButton "Jogar"

#endregion

#region Buttons

#macro ButtonManager global.buttonManager

global.buttonManager = {
	buttons: ds_queue_create(),
	isInteractionEnabled: true,
	isAnyButtonMarked: false,
	lastMarkedButton: undefined,
	curMarkedButton: undefined,
	isAnyButtonSelected: false,
	curSelectedButton: -1,
	createButton: function(x1I, y1I, x2I, y2I, depthI) {
		var newStruct = {
			_p: ButtonManager,
			isDeleted: false,
			isActivated: true,
			x1: x1I,
			y1: y1I,
			x2: x2I,
			y2: y2I,
			depth: depthI
		}
		if (lastMarkedButton == undefined) lastMarkedButton = newStruct;
		ds_queue_enqueue(buttons, newStruct);
		return newStruct;
	},
	isButtonSelected: function(buttonI) {
		return isAnyButtonSelected && curSelectedButton == buttonI;
	},
	isButtonMarked: function(buttonI) {
		return isAnyButtonMarked && curMarkedButton == buttonI;
	},
	selectButton: function(buttonI) {
		curSelectedButton = buttonI;
		isAnyButtonSelected = true;
	},
	markButton: function(buttonI) {
		lastMarkedButton = buttonI;
		curMarkedButton = buttonI;
		isAnyButtonMarked = true;
	},
	unselectButton: function() {
		curSelectedButton = -1;
		isAnyButtonSelected = false;
	},
	unmarkButton: function() {
		curMarkedButton = -1;
		isAnyButtonMarked = false;
	},
	activateButton: function(buttonI) {
		buttonI.isActivated = true;
	},
	deactivateButton: function(buttonI) {
		buttonI.isActivated = false;
	},
	destroyButton: function(buttonI) {
		buttonI.isDeleted = true;
	},
	clearButtons: function() {
		unmarkButton();
		unselectButton();
		while (!ds_queue_empty(buttons)) {
			var curButton = ds_queue_dequeue(buttons);
			delete curButton;
		}
		ds_queue_clear(buttons);
	},
	beginStepEvent: function() {
		unselectButton();
		unmarkButton();
		if (isInteractionEnabled) {
			var tempQueue = ds_queue_create();
			while (!ds_queue_empty(buttons)) {
				var curButton = ds_queue_dequeue(buttons);
			
				if (curButton.isActivated) {
					var curMouseX = window_mouse_get_x();
					var curMouseY = window_mouse_get_y();
					if (
						curMouseX >= curButton.x1 && curMouseX <= curButton.x2 &&
						curMouseY >= curButton.y1 && curMouseY <= curButton.y2
					) {
						if (!isAnyButtonMarked || curButton.depth < curMarkedButton.depth)
							markButton(curButton);
					}
				}
			
				if (!curButton.isDeleted) { // OBSERVATION000 - You might want to change the order of the deletion and marking conditions
					ds_queue_enqueue(tempQueue, curButton);
				}else {
					delete curButton;
				}
			}
			ds_queue_destroy(buttons);
			buttons = tempQueue;
		
			if (isAnyButtonMarked && mouse_check_button_pressed(mb_left)) {
				selectButton(curMarkedButton);
			}
		}
	}
}

global.drawButtonDefault = function(buttonI, sprI) { // DEBUG
	var isOutlineBase = false;
	var sprColor = c_black;
	var outlineThickness = 2;
	if (ButtonManager.isButtonMarked(buttonI)) {
		isOutlineBase = true;
		sprColor = c_white;
	}
	
	var x1 = buttonI.x1;
	var y1 = buttonI.y1;
	var x2 = buttonI.x2;
	var y2 = buttonI.y2;
	draw_set_color(c_white);
	draw_rectangle(x1, y1, x2-1, y2-1, false);
	if (isOutlineBase) {
		draw_set_color(c_black);
		draw_rectangle(x1+outlineThickness, y1+outlineThickness, x2-outlineThickness-1, y2-outlineThickness-1, false);
	}
	draw_sprite_ext(sprI, 0, x1, y1, 1.0, 1.0, 0, sprColor, 1.0);
}

global.generateButtonSpriteFromText = function(buttonI, textI, fontI) {
	var x1 = buttonI.x1;
	var y1 = buttonI.y1;
	var x2 = buttonI.x2;
	var y2 = buttonI.y2;
	var width = x2-x1+1;
	var height = y2-y1+1;
	var surface = surface_create(width, height);
	
	draw_set_font(fontI);
	draw_set_color(c_white);
	surface_set_target(surface);
	draw_text((width-string_width(textI))/2, (height-string_height(textI))/2, textI);
	surface_reset_target();
	
	var sprite = sprite_create_from_surface(surface, 0, 0, width, height, true, false, 0, 0);
	surface_free(surface);
	return sprite;
}

global.generateRectangleSpriteFromText = function(x1I, y1I, x2I, y2I, textI, fontI) {
	var x1 = x1I;
	var y1 = y1I;
	var x2 = x2I;
	var y2 = y2I;
	var width = x2-x1+1;
	var height = y2-y1+1;
	var surface = surface_create(width, height);
	
	draw_set_font(fontI);
	draw_set_color(c_white);
	surface_set_target(surface);
	draw_text((width-string_width(textI))/2, (height-string_height(textI))/2, textI);
	surface_reset_target();
	
	var sprite = sprite_create_from_surface(surface, 0, 0, width, height, true, false, 0, 0);
	surface_free(surface);
	return sprite;
}

#endregion

#region Scroll areas

#macro ScrollAreaManager global.scrollAreaManager

global.scrollAreaManager = {
	queue: ds_queue_create(),
	isAnyScrollAreaMarked: false,
	lastMarkedScrollArea: undefined,
	curMarkedScrollArea: undefined,
	createScrollArea: function(x1I, y1I, x2I, y2I, widthI, heightI, depthI, surfaceFormatI) {
		var newStruct = {
			_p: ScrollAreaManager,
			isDeleted: false,
			isActivated: true,
			x1: x1I,
			y1: y1I,
			x2: x2I,
			y2: y2I,
			width: widthI,
			height: heightI,
			visualWidth: x2I-x1I,
			visualHeight: y2I-y1I,
			cameraX: 0,
			cameraY: 0,
			depth: depthI,
			surface: undefined
		}
		if (newStruct.width < newStruct.visualWidth) {
			newStruct.width = newStruct.visualWidth;
		}
		if (newStruct.height < newStruct.visualHeight) {
			newStruct.height = newStruct.visualHeight;
		}
		newStruct.surface = surface_create(newStruct.width, newStruct.height, surfaceFormatI);
		if (lastMarkedScrollArea == undefined) lastMarkedScrollArea = newStruct;
		ds_queue_enqueue(queue, newStruct);
		return newStruct;
	},
	isScrollAreaMarked: function(scrollAreaI) {
		return isAnyScrollAreaMarked && curMarkedScrollArea == scrollAreaI;
	},
	markScrollArea: function(scrollAreaI) {
		lastMarkedScrollArea = scrollAreaI;
		curMarkedScrollArea = scrollAreaI;
		isAnyScrollAreaMarked = true;
	},
	unmarkScrollArea: function() {
		curMarkedScrollArea = -1;
		isAnyScrollAreaMarked = false;
	},
	activateScrollArea: function(scrollAreaI) {
		scrollAreaI.isActivated = true;
	},
	deactivateScrollArea: function(scrollAreaI) {
		scrollAreaI.isActivated = false;
	},
	destroyScrollArea: function(scrollAreaI) {
		scrollAreaI.isDeleted = true;
	},
	clearScrollAreas: function() {
		while (!ds_queue_empty(queue)) {
			var curScrollArea = ds_queue_dequeue(queue);
			delete curScrollArea;
		}
		ds_queue_clear(queue);
	},
	setScrollAreaSurfaceTarget: function(scrollAreaI) {
		surface_set_target(scrollAreaI.surface);
	},
	drawScrollArea: function(scrollAreaI) {
		var _sA = scrollAreaI;
		draw_surface_part(_sA.surface, _sA.cameraX, _sA.cameraY, _sA.visualWidth, _sA.visualHeight, _sA.x1, _sA.y1);
	},
	beginStepEvent: function() {
		unmarkScrollArea();
		var tempQueue = ds_queue_create();
		while (!ds_queue_empty(queue)) {
			var curScrollArea = ds_queue_dequeue(queue);
			
			if (curScrollArea.isActivated) {
				var curMouseX = window_mouse_get_x();
				var curMouseY = window_mouse_get_y();
				if (
					curMouseX >= curScrollArea.x1 && curMouseX <= curScrollArea.x2 &&
					curMouseY >= curScrollArea.y1 && curMouseY <= curScrollArea.y2
				) {
					if (!isAnyScrollAreaMarked || curScrollArea.depth < curMarkedScrollArea.depth)
						markScrollArea(curScrollArea);
				}
			}
			
			if (!curScrollArea.isDeleted) { // OBSERVATION000 - You might want to change the order of the deletion and marking conditions
				ds_queue_enqueue(tempQueue, curScrollArea);
			}else {
				surface_free(curScrollArea.surface);
				delete curScrollArea;
			}
		}
		ds_queue_destroy(queue);
		queue = tempQueue;
		
		var scrollValue = 15;
		if (isAnyScrollAreaMarked) {
			if (mouse_wheel_down()) {
				var curScrollArea = lastMarkedScrollArea;
				curScrollArea.cameraY += scrollValue; 
				if (curScrollArea.cameraY > curScrollArea.height-curScrollArea.visualHeight) {
					curScrollArea.cameraY = curScrollArea.height-curScrollArea.visualHeight;
				}
			}else if (mouse_wheel_up()) {
				var curScrollArea = lastMarkedScrollArea;
				curScrollArea.cameraY -= scrollValue; 
				if (curScrollArea.cameraY < 0) {
					curScrollArea.cameraY = 0;
				}
			}
		}
	}
}

#endregion

#region Rankings

#macro RankingManager global.rankingManager
enum rankings {
	D, C, B, A, S, P
}

#macro rankingAmount 6
#macro nonPRankingAmount 5

global.rankingManager = {
	strings: ["D", "C", "B", "A", "S", "P"],
	colors: [c_white, c_white, c_white, c_yellow, c_aqua, c_fuchsia],
	mechcoinMultipliers: [1.0, 2.0, 3.0, 5.0, 10.0, 30.0]
}

#endregion

#region Transition manager

#macro TransitionManager global.transitionManager

global.transitionManager = {
	isTransitioning: false,
	
	transitioningFrames: 16,
	transitioningOutFramesCur: 0,
	transitioningInFramesCur: 0,
	
	applyTransitionOut: function() {
		ButtonManager.isInteractionEnabled = true;
		isTransitioning = false;
		transitioningInFramesCur = transitioningFrames;
	},
	startTransitionOut: function(isImmediate = false) {
		ButtonManager.isInteractionEnabled = false;
		isTransitioning = true;
		if (!isImmediate) transitioningOutFramesCur = transitioningFrames;
		else transitioningOutFramesCur = 0;
	},
	
	// Menu
	isGoingToMenu: false,
	isExittingMenu: false,
	nextMenu: 0,
	goToMenu: function(nextMenuI) {
		startTransitionOut();
		isGoingToMenu = true;
		nextMenu = nextMenuI;
	},
	goToMenuApply: function() {
		isGoingToMenu = false;
		MenuManager.setCurrentMenu(nextMenu);
		MenuManager.menuStartEvent();
	},
	exitMenu: function() {
		isExittingMenu = true;
	},
	exitMenuApply: function() {
		isExittingMenu = false;
		MenuManager.menuEndEvent();
	},
	
	// Stage
	isGoingToStage: false,
	isExittingStage: false,
	isContinuingStage: false,
	nextStage: undefined,
	nextMainLevel: undefined,
	goToStage: function(nextStageI, isContinuingI = false) {
		startTransitionOut();
		isGoingToStage = true;
		nextStage = nextStageI;
		isContinuingStage = isContinuingI;
	},
	goToStageApply: function() {
		isGoingToStage = false;
		StageManager.setCurrentStage(StageManager.getStage(nextMainLevel.stageID));
		if (isGoingToMainLevel) goToMainLevelApply();
		StageManager.stageStartEvent();
	},
	exitStage: function() {
		isExittingStage = true;
	},
	exitStageApply: function() {
		isExittingStage = false;
		if (isExittingMainLevel) exitMainLevelApply();
		GameplayManager.roomEndEvent();
		StageManager.stageEndEvent();
	},
	
	// Main level
	isGoingToMainLevel: false,
	isExittingMainLevel: false,
	isContinuingMainLevel: false,
	nextMainLevel: 0,
	goToMainLevel: function(nextMainLevelI) {
		startTransitionOut();
		isGoingToMainLevel = true;
		nextMainLevel = nextMainLevelI;
		goToStage(StageManager.getStage(nextMainLevelI.stageID));
	},
	continueMainLevel: function() {
		isGoingToMainLevel = true;
		isContinuingMainLevel = true;
		var curNextMainLevel = MainLevelManager.getLevel(UserManager.userContinuedStageInfo.continuedMainLevelID);
		nextMainLevel = curNextMainLevel;
		goToStage(StageManager.getStage(nextMainLevel.stageID), true);
	},
	goToMainLevelApply: function() {
		isGoingToMainLevel = false;
		MainLevelManager.setCurrentMainLevel(nextMainLevel);
		MainLevelManager.isMainLevelBeingPlayed = true;
	},
	exitMainLevel: function() {
		isExittingMainLevel = true;
		exitStage();
	},
	exitMainLevelApply: function() {
		isExittingMainLevel = false;
		MainLevelManager.isMainLevelBeingPlayed = false;
	},
	
	endStepEvent: function() {
		if (transitioningInFramesCur != 0) transitioningInFramesCur--;
		
		if (isTransitioning) {
			if (transitioningOutFramesCur == 0) {
				
				var hasExitted = false;
				if (isExittingMenu) {exitMenuApply(); hasExitted = true;}
				if (isExittingStage) {exitStageApply(); hasExitted = true;}
				
				if (hasExitted) {
					ButtonManager.clearButtons();
					ScrollAreaManager.clearScrollAreas();
				}
				applyTransitionOut();
				if (isGoingToMenu) goToMenuApply();
				if (isGoingToStage) goToStageApply();
				
			}else transitioningOutFramesCur--;
		}
	},
	
	drawGUIEndEvent: function() {
		if (transitioningInFramesCur != 0) {
			draw_set_color(c_black);
			draw_set_alpha(transitioningInFramesCur/transitioningFrames);
			draw_rectangle(0, 0, gameResolutionWidth, gameResolutionHeight, false);
			draw_set_alpha(1.0);
		}
		
		if (isTransitioning) {
			draw_set_color(c_black);
			draw_set_alpha((transitioningFrames - transitioningOutFramesCur)/transitioningFrames);
			draw_rectangle(0, 0, gameResolutionWidth, gameResolutionHeight, false);
			draw_set_alpha(1.0);
		}
	}
}

#endregion

#region Menu manager

#macro MenuManager global.menuManager
global.menuManager = {
	array: array_create(4),
	currentMenu: -1,
	setCurrentMenu: function(newMenuI) {
		currentMenu = newMenuI;
	},
	getMenu: function(indexI) {
		return array[indexI];
	},
	
	// EVENTS
	menuStartEvent: function() {
		instance_create_depth(0, 0, 0, currentMenu.managerObj);
		room_goto(rm_menuRoom);
	},
	menuEndEvent: function() {
		instance_destroy(currentMenu.managerObj);
	}
	
}

var constructMenu = function(indexI, managerI) {
	return {
		index: indexI,
		managerObj: managerI
	};
}

enum menu {
	main, levels, levelFinish, shop
}

MenuManager.array[menu.main] = constructMenu(menu.main, obj_mainMenuManager);
MenuManager.array[menu.levels] = constructMenu(menu.levels, obj_levelMenuManager);
MenuManager.array[menu.levelFinish] = constructMenu(menu.levelFinish, obj_levelFinishMenuManager);
MenuManager.array[menu.shop] = constructMenu(menu.shop, obj_shopMenuManager);

#endregion

#region Stage manager

#macro StageManager global.stageManager

global.stageManager = {
	capacity: 65536,
	array: array_create(65536, undefined),
	nextID: 0,
	currentStage: 0,
	stageRoom: room_add(),
	stageFinishMenuInfo: {
		isRankless: false,
		_FEST_nextLevel: undefined // The next level to put the player in.
	},
	curHasPrevRanking: false, // OBSERVATION001 - See if this variable is of any use or if it's placed well.
	curPrevRanking: undefined, // OBSERVATION001 - See if this variable is of any use or if it's placed well.
	
	stageStartEvent: function() {
		GameplayManager.stageStartEvent();
		room_goto(stageRoom);
		room_set_width(stageRoom, currentStage.roomWidth);
		room_set_height(stageRoom, currentStage.roomHeight);
	},
	stageEndEvent: function() {
		GameplayManager.stageEndEvent();
	},
	
	setCurrentStage: function(stageI) {
		currentStage = stageI;
	},
	getStage: function(idI) {
		if (is_struct(array[idI])) {
			return array[idI];
		}else {
			show_debug_message("StageManager.getStage() function error!!!");
			show_debug_message("Stage of ID "+string(idI)+" not found!!!");
		}
	},
	addStage: function(pointRequirementsI, initialGameplayBlueprintI, roomWidthI, roomHeightI, managerI = undefined) {
		var newStage = {
			isUserStage: false,
			id: StageManager.nextID,
			isRankless: false,
			pointRequirements: pointRequirementsI,
			initialGameplayBlueprint: initialGameplayBlueprintI,
			roomWidth: roomWidthI,
			roomHeight: roomHeightI,
			manager: managerI
		}
		if (managerI == undefined) {
			newStage.manager = constructManager();
		}
		newStage.manager.managedStage = newStage;
		array[nextID] = newStage;
		if (!UserManager.hasSaveFile) addStageUserInfo(nextID);
		
		var curID = nextID;
		nextID++;
		if (nextID == capacity) {
			nextID = 0;
		}
		return curID;
	},
	addStageUserInfo: function(stageIDI) {
		var newInfo = {
			hasBeenFinished: false,
			pointInformation: PointsManager.constructStageUserPointInformation()
		}
		UserManager.setStageInfo(stageIDI, newInfo);
	},
	setStageSize: function(stageIDI, widthI, heightI) {
		var curStage = getStage(stageIDI);
		curStage.roomWidth = widthI;
		curStage.roomHeight = heightI;
		TileManager.assignTileMapToGameplayBlueprint(curStage.initialGameplayBlueprint, widthI, heightI);
	},
	
	constructManager: function() {
		return {
			endStepEvent: function() {
				
			},
			roomStartEvent: function() {
				
			}
		};
	},
	
	finish: function() { // OBSERVATION001 - See if there's a better way to organize finishing functions.
		UserManager.getStageInfoFromStruct(currentStage).hasBeenFinished = true;
		if (MainLevelManager.isMainLevelBeingPlayed) MainLevelManager.finish();
		if (currentStage.isRankless) {
			stageFinishMenuInfo.isRankless = true;
		}
	}
}

#endregion

#region Main level manager

#macro MainLevelManager global.mainLevelManager
#macro LevelUnlockingManager global.mainLevelManager.levelUnlockingManager
#macro LevelChallengeManager global.mainLevelManager.levelChallengeManager
	enum challenge_ID {
		// Tutorial
		tutorial_text,
		
		// 1st stage
		stage1_ivolado,
		
		// 2nd stage
		stage2_10xCombo,
		stage2_bossEnergy,
		stage2_gun
	}

#macro mainLevelAmount 4

enum mainLevel_ID {
	tutorial,
	first,
	second,
	third
}

global.mainLevelManager = {
	array: array_create(mainLevelAmount),
	nextID: 0,
	currentMainLevel: 0,
	isMainLevelBeingPlayed: false,
	stageFinishMenuInfo: {
		mechcoinGain: 0,
		FEST_nextLevelIndex: undefined
	},
	
	setCurrentMainLevel: function(mainLevelI) {
		currentMainLevel = mainLevelI;
	},
	addLevel: function(nameI, charNameI, stageIDI, hasBSideI = false, buildingSourceRoomI, mechcoinBaseI) { // TODO - Add full fledged B-side support.
		var newLevel = {
			name: nameI,
			charName: charNameI,
			stageID: stageIDI,
			id: MainLevelManager.nextID,
			lockArray: [],
			mechcoinBase: mechcoinBaseI,
			challengeArr: [],
			challengeAmount: 0,
			FEST_nextLevelIndex: undefined
		}
		array[nextID] = newLevel;
		StageBuilderFromRoom.assignRoomToStage(stageIDI, buildingSourceRoomI);
		if (!UserManager.hasSaveFile) addLevelUserInfo(nextID);
		
		nextID++;
		return nextID-1;
	},
	addLevelUserInfo: function(levelIDI) {
		var newInfo = {
			isUnlocked: true,
			lockStatusArray: [],
			isBSideUnlocked: false,
			hasLastMechcoinRanking: false,
			lastMechcoinRanking: -1,
			//Challenges
			completedChallengeAmount: 0
		}
		UserManager.setMainLevelInfo(levelIDI, newInfo);
	},
	getLevel: function(indexI) {
		if (is_struct(array[indexI])) {
			return array[indexI];
		}else {
			show_debug_message("MainLevelManager.getLevel() function error!!!");
			show_debug_message("Level of index "+string(indexI)+" not found!!!");
		}
	},
	initializeLevels: function() {
		var frames = game_get_speed(gamespeed_fps);
		
		// Tutorial level
		/*var stageTManager = StageManager.constructManager();
		with (stageTManager) {
			challengeSign = undefined;
			roomStartEvent = function() {
				hasPlayerMoved = false;
				curDialogue = DialogueManager.constructDialogue("Use as setas para se mover.", false, undefined, false);
				DialogueManager.setDialogue(curDialogue);
			}
			endStepEvent = function() {
				if (InputManager.isInputActivated(input_ID.left) || InputManager.isInputActivated(input_ID.right)) {
					if (!hasPlayerMoved) {
						DialogueManager.removeDialogue(curDialogue);
						hasPlayerMoved = true;
					}
				}
				
				with (StageObjectManager.getObject(challengeSign).instanceID) {
					if (place_meeting(x, y, obj_player)) {
						GameplayManager.completeChallenge(challenge_ID.tutorial_text);
					}
				}
			}
		}
		var stageT = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					0,
					0,
					0,
					0
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [], ds_map_create()
			),
			-1, -1, stageTManager
		);
		StageManager.getStage(stageT).isRankless = true;
		var levelTID = addLevel("Tutorial", "T", stageT, false, rm_levelTutorial, 200);
		//LevelChallengeManager.addChallengeToLevel(levelTID, "Sabe...", spr_challengeSpr1, "Leia a placa bloqueada por um percurso mortal.", 500, false);
		*/
		// First level
		var stage1Manager = StageManager.constructManager();
		#region
		with (stage1Manager) { // OBSERVATION001 - Code that shit better.
			managedLevel = undefined;
			managedStage = undefined;
			challengeSign = undefined;
			roomStartEvent = function() {
				
			}
			endStepEvent = function() {
				var _ivoliSpr = skin_ID.gostoso;
				with (StageObjectManager.getObject(challengeSign).instanceID) {
					if (place_meeting(x, y, obj_player)) {
						GameplayManager.completeChallenge(challenge_ID.tutorial_text);
						obj_player.curSprIndex = _ivoliSpr;
					}
				}
			}
		}
		#endregion
		var stage1 = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					(7)*basePointConstant-280*PointsManager.penaltyPerDmgUnit,
					(7+2*0.3)*basePointConstant-220*PointsManager.penaltyPerDmgUnit,
					(7+4*0.3)*basePointConstant-160*PointsManager.penaltyPerDmgUnit,
					(7+4*0.3)*basePointConstant-60*PointsManager.penaltyPerDmgUnit
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [0], ds_map_create()
			),
			-1, -1, stage1Manager
		);
		var level1ID = addLevel("Centro de construção-003", "1", stage1, false, rm_level1, 800);
		LevelChallengeManager.addChallengeToLevel(level1ID, "IVOLADO!", spr_challengeSpr1, "Seja IVOLADO!!!", 2000, false);
		/*LevelUnlockingManager.addLockToLevel(
			level1ID,
			LevelUnlockingManager.types.levelFinish.construct(
				level1ID,
				levelTID
			)
		);*/
		stage1Manager.managedStage = stage1;
		stage1Manager.managedLevel = level1ID;
		
		// Second level
		var stage2Manager = StageManager.constructManager();
		#region
		with (stage2Manager) {
			managedLevel = undefined;
			bossManager = {
				
			}
			endStepEvent = function() {
				if (PlayerManager.mainInventory.hasItem(tool_ID.gun)) GameplayManager.completeChallenge(challenge_ID.stage2_gun);
				if (PointsManager.curCombo == 10) GameplayManager.completeChallenge(challenge_ID.stage2_10xCombo);
			}
		}
		#endregion
		var stage2 = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					(34+15+6*0.3+1*2*0.3)*basePointConstant-640*PointsManager.penaltyPerDmgUnit,
					(37+15+12*0.3+3*2*0.3)*basePointConstant-590*PointsManager.penaltyPerDmgUnit,
					(40+15+12*0.3+5*2*0.3+4*4*0.3)*basePointConstant-500*PointsManager.penaltyPerDmgUnit,
					(40+15+16*0.3+6*2*0.3+4*4*0.3)*basePointConstant-440*PointsManager.penaltyPerDmgUnit
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [0], ds_map_create()
			),
			-1, -1, stage2Manager
		);
		var level2ID = addLevel("Tiro na robô-mosca", "2", stage2, false, rm_level2, 1000);
		LevelChallengeManager.addChallengeToLevel(level2ID, "Robôs = shit", spr_challengeSpr1, "Consiga um combo de 10x.", 2000, false);
		LevelChallengeManager.addChallengeToLevel(level2ID, "Iphone", spr_challengeSpr1, "Derrote o chefão fazendo ele perder toda sua energia.", 1000, false);
		LevelChallengeManager.addChallengeToLevel(level2ID, "Whenever I see a gun...", spr_challengeSpr1, "...I think about how just petty you are! Encontre a arma.", 3000, true);
		stage2Manager.managedLevel = level2ID;
		/*LevelUnlockingManager.addLockToLevel(
			level2ID,
			LevelUnlockingManager.types.levelFinish.construct(
				level2ID,
				level1ID
			)
		);*/
		
		/*var stage3 = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					(34+15+6*0.3+1*2*0.3)*basePointConstant-640*PointsManager.penaltyPerDmgUnit,
					(37+15+12*0.3+3*2*0.3)*basePointConstant-590*PointsManager.penaltyPerDmgUnit,
					(40+15+12*0.3+5*2*0.3+4*4*0.3)*basePointConstant-500*PointsManager.penaltyPerDmgUnit,
					(40+15+16*0.3+6*2*0.3+4*4*0.3)*basePointConstant-440*PointsManager.penaltyPerDmgUnit
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [0, 1], ds_map_create()
			),
			-1, -1, stage2Manager
		);
		var level3ID = addLevel("Bolas", "3", stage3, false, rm_level3, 1000);*/
		
		var stage4 = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					(34+15+6*0.3+1*2*0.3)*basePointConstant-640*PointsManager.penaltyPerDmgUnit,
					(37+15+12*0.3+3*2*0.3)*basePointConstant-590*PointsManager.penaltyPerDmgUnit,
					(40+15+12*0.3+5*2*0.3+4*4*0.3)*basePointConstant-500*PointsManager.penaltyPerDmgUnit,
					(40+15+16*0.3+6*2*0.3+4*4*0.3)*basePointConstant-440*PointsManager.penaltyPerDmgUnit
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [0, 1], ds_map_create()
			),
			-1, -1, stage2Manager
		);
		var level4ID = addLevel("Bolas 2", "4", stage4, false, rm_level4, 1000);
		
		var stage5 = StageManager.addStage(
			PointsManager.constructStagePointRequirements(
				[
					(34+15+6*0.3+1*2*0.3)*basePointConstant-640*PointsManager.penaltyPerDmgUnit,
					(37+15+12*0.3+3*2*0.3)*basePointConstant-590*PointsManager.penaltyPerDmgUnit,
					(40+15+12*0.3+5*2*0.3+4*4*0.3)*basePointConstant-500*PointsManager.penaltyPerDmgUnit,
					(40+15+16*0.3+6*2*0.3+4*4*0.3)*basePointConstant-440*PointsManager.penaltyPerDmgUnit
				],
				[200*frames, 320*frames, 800*frames, 1200*frames]
			),
			GameplayManager.constructInitialGameplayBlueprint(
				100, 3, [0, 1], ds_map_create()
			),
			-1, -1, stage2Manager
		);
		var level5ID = addLevel("Bolas 3", "5", stage5, false, rm_level5, 1000);
		MainLevelManager.getLevel(level4ID).FEST_nextLevelIndex = level5ID;
		MainLevelManager.getLevel(level5ID).FEST_nextLevelIndex = level4ID;
	},
	finish: function() {
		var curStageInfo = UserManager.getStageInfo(currentMainLevel.stageID);
		var curLevelInfo = UserManager.getMainLevelInfoFromStruct(currentMainLevel);
		var curMechcoinGain;
		if (curLevelInfo.hasLastMechcoinRanking) {
			var diffMultiplier = RankingManager.mechcoinMultipliers[curLevelInfo.lastMechcoinRanking]-RankingManager.mechcoinMultipliers[curStageInfo.pointInformation.ranking];
			curMechcoinGain = diffMultiplier*currentMainLevel.mechcoinBase;
			UserManager.mechcoinAmount += curMechcoinGain;
			curLevelInfo.lastMechcoinRanking = curStageInfo.pointInformation.ranking;
		}else {
			curMechcoinGain = RankingManager.mechcoinMultipliers[curStageInfo.pointInformation.ranking]*currentMainLevel.mechcoinBase;
			UserManager.mechcoinAmount += curMechcoinGain;
			curLevelInfo.hasLastMechcoinRanking = true;
			curLevelInfo.lastMechcoinRanking = curStageInfo.pointInformation.ranking;
		}
		stageFinishMenuInfo.mechcoinGain = curMechcoinGain;
		stageFinishMenuInfo.FEST_nextLevelIndex = currentMainLevel.FEST_nextLevelIndex;
	},
	
	#region Sub-managers
	
	levelUnlockingManager: { // OBSERVATION001 - Use locks in here.
		types: {
			levelFinish: {
				array: [],
				construct: function(levelIDI, requiredLevelIDI) {
					var curLevelInfo = UserManager.getMainLevelInfo(levelIDI);
					var newLock = {
						type: LevelUnlockingManager.types.levelFinish,
						levelID: levelIDI,
						index: array_length(curLevelInfo.lockStatusArray),
						requiredLevelID: requiredLevelIDI
					}
					array_push(array, newLock);
					return newLock;
				},
				isLockDone: function(levelLockI) {
					return StageManager.getStage(MainLevelManager.getLevel(levelLockI.requiredStageID).stageID).hasBeenFinished;
				},
				buildDescriptionString: function(lockI) {
					return "Conclua a fase "+MainLevelManager.getLevel(lockI.requiredLevelID).charName+".";
				}
			}
		},
		updateLock: function(lockI) {
			var curInfo = UserManager.getMainLevelInfo(lockI.levelID);
			curInfo.lockStatusArray[lockI.index] = lockI.type.isLockDone(lockI);
				
			var lockAmount = array_length(curInfo.lockStatusArray);
			for (var i = 0; i < lockAmount; i++) {
				if (curInfo.lockStatusArray[i] == false) return;
			}
			curInfo.isUnlocked = true;
		},
		addLockToLevel: function(levelIDI, lockI) {
			var curLevel = MainLevelManager.getLevel(levelIDI);
			array_push(curLevel.lockArray, lockI);
			
			if (!UserManager.hasSaveFile) {
				var curInfo = UserManager.getMainLevelInfoFromStruct(curLevel);
				curInfo.isUnlocked = false;
				array_push(curInfo.lockStatusArray, false);
			}
		}
	},
	
	levelChallengeManager: {
		curChallengeID: 0,
		challengeArr: [],
		constructChallenge: function(idI, nameI, spriteI, descriptionI, mechcoinRewardI, isHiddenI) {
			return {
				id: idI,
				name: nameI,
				sprite: spriteI,
				description: descriptionI,
				mechcoinReward: mechcoinRewardI,
				isHidden: isHiddenI
			}
		},
		addChallenge: function(nameI, spriteI, descriptionI, mechcoinRewardI, isHiddenI) {
			var newChallenge = constructChallenge(curChallengeID, nameI, spriteI, descriptionI, mechcoinRewardI, isHiddenI);
			array_push(challengeArr, newChallenge);
			curChallengeID++;
			if (!UserManager.hasSaveFile) {
				array_push(UserManager.userLevelChallengeInfo.completedChallengeArr, false);
			}
			return curChallengeID-1;
		},
		assignChallengeToLevel: function(levelIDI, challengeIDI) {
			var curLevel = MainLevelManager.getLevel(levelIDI);
			array_push(curLevel.challengeArr, challengeIDI);
			curLevel.challengeAmount++;
		},
		addChallengeToLevel: function(levelIDI, nameI, spriteI, descriptionI, mechcoinRewardI, isHiddenI) {
			var newChallenge = addChallenge(nameI, spriteI, descriptionI, mechcoinRewardI, isHiddenI);
			assignChallengeToLevel(levelIDI, newChallenge);
		},
		completeChallenge: function(levelIDI, challengeIDI) {
			/*if (!UserManager.userLevelChallengeInfo.completedChallengeArr[challengeIDI]) {
				UserManager.userLevelChallengeInfo.completedChallengeArr[challengeIDI] = true;
				UserManager.mechcoinAmount += LevelChallengeManager.challengeArr[challengeIDI].mechcoinReward;
				UserManager.getMainLevelInfo(levelIDI).completedChallengeAmount++;
			
				UserManager.saveUserInfo();
				return true;
			}*/
			return false;
		}
	}
	
	#endregion
	
}

#endregion

#region User manager

#macro UserManager global.userManager

#macro saveDirectoryNameString "Saves"
#macro saveNameString saveDirectoryNameString+"/Save_"

global.userManager = {
	hasSaveFile: file_exists(saveNameString),
	saveFileVersion: 21,
	
	userStageInfo: array_create(StageManager.capacity),
	userMainLevelInfo: array_create(mainLevelAmount),
	userContinuedStageInfo: {
		isStageBeingContinued: false,
		isContinuedStageMainLevel: false,
		continuedMainLevelID: undefined,
		continuedStageGameplayBlueprint: undefined
	},
	mechcoinAmount: 0,
	userRankingAmount: array_create(6),
	userLevelChallengeInfo: {
		completedChallengeArr: []
	},
	unlockedSkins: undefined,
	shopItemInfoArr: [],
	
	#region Saving && loading
	
	saveUserInfo: function() {
		var newStruct = {
			version: UserManager.saveFileVersion,
			userStageInfo: UserManager.userStageInfo,
			userMainLevelInfo: UserManager.userMainLevelInfo,
			userContinuedStageInfo: {},
			mechcoinAmount: UserManager.mechcoinAmount,
			userRankingAmount: UserManager.userRankingAmount,
			userLevelChallengeInfo: UserManager.userLevelChallengeInfo,
			unlockedSkins: UserManager.unlockedSkins,
			shopItemInfoArr: UserManager.shopItemInfoArr
		}
		saveContinuedStageInfoExtra(newStruct);
		var jsonString = json_stringify(newStruct);
		var buffer = buffer_create(string_byte_length(jsonString)+1, buffer_fixed, 1);
		buffer_write(buffer, buffer_string, jsonString);
		buffer_save(buffer, saveNameString);
		buffer_delete(buffer);
	},
	
	loadUserInfo: function() {
		var buffer = buffer_load(saveNameString);
		var loadedStruct = json_parse(buffer_read(buffer, buffer_string));
		buffer_delete(buffer); 
		userStageInfo = loadedStruct.userStageInfo;
		userMainLevelInfo = loadedStruct.userMainLevelInfo;
		userContinuedStageInfo = loadedStruct.userContinuedStageInfo;
		loadContinuedStageInfoExtra(userContinuedStageInfo, loadedStruct);
		mechcoinAmount = loadedStruct.mechcoinAmount;
		userRankingAmount = loadedStruct.userRankingAmount;
		userLevelChallengeInfo = loadedStruct.userLevelChallengeInfo;
		unlockedSkins = loadedStruct.unlockedSkins;
		shopItemInfoArr = loadedStruct.shopItemInfoArr;
	},
	
	#endregion
	
	setStageInfo: function(stageIDI, newInfoI) {
		userStageInfo[stageIDI] = newInfoI;
	},
	setMainLevelInfo: function(levelIDI, newInfoI) {
		userMainLevelInfo[levelIDI] = newInfoI;
	},
	
	getStageInfo: function(stageIDI) {
		var curID = stageIDI;
		if (is_struct(userStageInfo[curID])) {
			return userStageInfo[curID];
		}else {
			show_debug_message("UserManager.getStageInfo() function error!!!");
			show_debug_message("Stage user information of ID "+string(curID)+" not found!!!");
		}
	},
	getMainLevelInfo: function(levelIDI) {
		var curID = levelIDI;
		if (is_struct(userMainLevelInfo[curID])) {
			return userMainLevelInfo[curID];
		}else {
			show_debug_message("UserManager.getMainLevelInfo() function error!!!");
			show_debug_message("Main level user information of ID "+string(curID)+" not found!!!");
		}
	},
	
	getStageInfoFromStruct: function(stageStructI) {
		var curID = stageStructI.id;
		if (is_struct(userStageInfo[curID])) {
			return userStageInfo[curID];
		}else {
			show_debug_message("UserManager.getStageInfoFromStruct() function error!!!");
			show_debug_message("Stage user information of ID "+string(curID)+" not found!!!");
		}
	},
	getMainLevelInfoFromStruct: function(mainLevelStructI) { 
		var curID = mainLevelStructI.id;
		if (is_struct(userMainLevelInfo[curID])) {
			return userMainLevelInfo[curID];
		}else {
			show_debug_message("UserManager.getMainLevelInfoFromStruct() function error!!!");
			show_debug_message("Main level user information of ID "+string(curID)+" not found!!!");
		}
	},
	
	// Continuing stages
	saveContinuedStageInfoExtra: function(saveStructI) {
		struct_copy_deep(UserManager.userContinuedStageInfo, saveStructI.userContinuedStageInfo, true);
		if (saveStructI.userContinuedStageInfo.isStageBeingContinued)
			saveStructI.userContinuedStageInfo.continuedStageGameplayBlueprint.stageObjectMap = ds_map_map_to_array(saveStructI.userContinuedStageInfo.continuedStageGameplayBlueprint.stageObjectMap);
	},
	loadContinuedStageInfoExtra: function() {
		with (userContinuedStageInfo.continuedStageGameplayBlueprint) {
			if (stageObjectMap != undefined) stageObjectMap = ds_map_array_to_map(stageObjectMap);
		}
	},
	setContinuedMainLevel: function() { // Automatically sets the continued level as the one being currently played.
		if (userContinuedStageInfo.isStageBeingContinued) cleanupContinuedStage();
		userContinuedStageInfo = {
			isStageBeingContinued: true,
			isContinuedStageMainLevel: true,
			continuedMainLevelID: MainLevelManager.currentMainLevel.id,
			continuedStageGameplayBlueprint: {},
			continuedStageStartBlueprint: {}
		}
		struct_copy(GameplayManager.currentGameplayBlueprint, userContinuedStageInfo.continuedStageGameplayBlueprint);
		userContinuedStageInfo.continuedStageGameplayBlueprint.stageObjectMap = ds_map_create();
		ds_map_copy(userContinuedStageInfo.continuedStageGameplayBlueprint.stageObjectMap, GameplayManager.currentGameplayBlueprint.stageObjectMap);
		userContinuedStageInfo.continuedStageStartBlueprint = GameplayManager.constructStartBlueprintFromGameplay();
	},
	resetContinuedMainLevel: function() {
		if (userContinuedStageInfo.isStageBeingContinued) cleanupContinuedStage();
		userContinuedStageInfo = {
			isStageBeingContinued: false,
			isContinuedStageMainLevel: false,
			continuedMainLevelID: undefined,
			continuedStageGameplayBlueprint: undefined
		}
	},
	cleanupContinuedStage: function() {
		ds_map_destroy(userContinuedStageInfo.continuedStageGameplayBlueprint.stageObjectMap);
	},
	
	// EVENTS
	gameStartEvent: function() {
		if (hasSaveFile) {
			loadUserInfo();
		}else {
			directory_create(saveDirectoryNameString);
		}
	},
	gameEndEvent: function() {
		//saveUserInfo();
	}
}

with (UserManager) {
	if (hasSaveFile) {
		var buffer = buffer_load(saveNameString);
		var loadedStruct = json_parse(buffer_read(buffer, buffer_string));
		buffer_delete(buffer);
		if (loadedStruct.version != saveFileVersion) {
			hasSaveFile = false;
			file_delete(saveNameString);
		}else {
			UserManager.loadUserInfo();
		}
	}else {
		directory_create(saveDirectoryNameString);
	}
}

#endregion

#region Lock manager

#macro LockManager global.lockManager

global.lockManager = {
	constructLockArray: function() {
		return {
			array: [],
			isLocked: false
		}
	},
	addLockToArray: function(lockArrayI, lockI) {
		array_push(lockArrayI.array, lockI);
		lockI.lockArray = lockArrayI;
		lockArrayI.isLocked = true;
	},
	updateLock: function(lockI) {
		if (!lockI.isLocking) {
			lockI.isLocking = lockI.type.isLockDone(lockI);
			
			var curLockArray = lockI.lockArray;
			if (!lockI.isLocking) {
				var curLength = array_length(curLockArray.array);
				for (var i = 0; i < curLength; i++) {
					if (curLockArray.array[i].isLocking) return;
				}
				curLockArray.isLocked = false;
			}
		}
	},
	unlockLock: function(lockI) {
		lockI.isLocking = false;
		var curLockArray = lockI.lockArray;
		if (curLockArray != undefined) {
			var curLength = array_length(curLockArray.array);
			for (var i = 0; i < curLength; i++) {
				if (curLockArray.array[i].isLocking) return;
			}
			curLockArray.isLocked = false;
		}
	},
	levelFinish: {
		array: [],
		nextID: 0,
		construct: function(requiredStageIDI) {
			var curLevelInfo = UserManager.getMainLevelInfo(levelIDI);
			var newLock = {
				id: nextID,
				type: LockManager.levelFinish,
				isLocking: true,
				lockArray: undefined,
				requiredStageID: requiredStageIDI
			}
			nextID++;
			array_push(array, newLock);
			return newLock;
		},
		isLockDone: function(levelLockI) {
			return StageManager.getStage(levelLockI.requiredStageID).hasBeenFinished;
		},
		buildDescriptionString: function(lockI) {
			return "Conclua a fase "+string(lockI.levelID)+".";
		},
		updateLocks: function() {
			var curLength = array_length(array);
			for (var i = 0; i < curLength; i++) {
				LockManager.updateLock(array[i]);
			}
		}
	},
	mechcoinBuy: {
		array: [],
		nextID: 0,
		construct: function(mechcoinCostI) {
			var newLock = {
				id: nextID,
				type: LockManager.mechcoinBuy,
				isLocking: true,
				lockArray: undefined,
				mechcoinCost: mechcoinCostI
			}
			nextID++;
			array_push(array, newLock);
			return newLock;
		},
		isLockDone: function(levelLockI) {
			return levelLockI.isLocking;
		},
		buildDescriptionString: function(lockI) {
			return "Compre.";
		},
		buildMenuString: function(lockI) {
			return string(lockI.mechcoinCost)+"M";
		},
		tryUnlockLock: function(lockI) {
			if (UserManager.mechcoinAmount >= lockI.mechcoinCost) {
				UserManager.mechcoinAmount -= lockI.mechcoinCost;
				LockManager.unlockLock(lockI);
				return true;
			}else return false;
		}
	},
	ranking: {
		array: [],
		nextID: 0,
		construct: function(rankingI, amountI) {
			var newLock = {
				id: nextID,
				type: LockManager.ranking,
				isLocking: true,
				lockArray: undefined,
				ranking: rankingI,
				amount: amountI
			}
			nextID++;
			array_push(array, newLock);
			return newLock;
		},
		isLockDone: function(levelLockI) {
			return UserManager.userRankingAmount[levelLockI.ranking] >= levelLockI.amount;
		},
		buildDescriptionString: function(lockI) {
			var rankingStr = (lockI.amount == 1) ? "ranking" : "rankings";
			return "Obtenha "+string(lockI.amount)+" "+rankingStr+" "+RankingManager.strings[lockI.ranking];
		},
		buildMenuString: function(lockI) {
			return string(lockI.amount)+" "+RankingManager.strings[lockI.ranking];
		},
		updateLocks: function() {
			var curLength = array_length(array);
			for (var i = 0; i < curLength; i++) {
				LockManager.updateLock(array[i]);
			}
		}
	}
}

#endregion

#region Shop manager

#macro ShopManager global.shopManager

global.shopManager = {
	itemArr: array_create(0),
	nextID: 0,
	addItem: function(itemI) {
		itemI.id = nextID;
		nextID++;
		show_debug_message(UserManager.shopItemInfoArr);
		array_push(itemArr, itemI);
		if (!UserManager.hasSaveFile) addItemInfo(itemI);
		else {
			if (UserManager.shopItemInfoArr[itemI.id].isBought) LockManager.unlockLock(itemI.lock);
		}
	},
	addItemInfo: function(itemI) {
		array_push(UserManager.shopItemInfoArr, constructItemInfo(itemI.id));
	},
	constructItemBase: function(typeI, lockI) {
		return {
			id: undefined,
			type: typeI,
			lock: lockI
		}
	},
	constructItemInfo: function(idI) {
		return {
			id: idI,
			isBought: false
		}
	},
	buyBase: function(itemI) {
		UserManager.shopItemInfoArr[itemI.id].isBought = true;
		UserManager.saveUserInfo();
	},
	
	type_skin: {
		construct: function(lockI, skinIDI) {
			return {
				type: ShopManager.type_skin,
				lock: lockI,
				skinID: skinIDI
			}
		},
		buy: function(itemI) {
			UserManager.unlockedSkins[itemI.skinID] = true;
			ShopManager.buyBase(itemI);
		},
		menuDraw: function(itemI, xI, yI) {
			draw_sprite(spr_skinSimple, itemI.skinID, xI, yI);
		}
	},
	initialize: function() {
		// Item initialization
		addItem(type_skin.construct(LockManager.mechcoinBuy.construct(300), skin_ID.red));
		addItem(type_skin.construct(LockManager.mechcoinBuy.construct(500), skin_ID.blue));
		addItem(type_skin.construct(LockManager.mechcoinBuy.construct(1500), skin_ID.square));
		addItem(type_skin.construct(LockManager.mechcoinBuy.construct(4000), skin_ID.unpleasantGradient));
		addItem(type_skin.construct(LockManager.ranking.construct(rankings.A, 3), skin_ID.aRank));
		addItem(type_skin.construct(LockManager.ranking.construct(rankings.S, 3), skin_ID.sRank));
		addItem(type_skin.construct(LockManager.ranking.construct(rankings.P, 3), skin_ID.pRank));
		
	}
}
ShopManager.initialize();

#endregion

#region Dialogue manager

#macro DialogueManager global.dialogueManager

global.dialogueManager = { // OBSERVATION005 - Add support for dialogue queue.
	textArrQueueCap: 256,
	textArrQueueSize: 0,
	textArrQueue: array_create(256, undefined),
	textArrQueueIndex: 0,
	curDialogueIndex: 0,
	curDialogue: undefined,
	isQueueActive: false,
	hasDialogue: false,
	
	x1: -1, x2: -1,
	y1: 360, y2: 500,
	textX1: -1, textSprX1: 300, textY1: 370,
	textX2: -1, textY2: 480,
	outlineThickness: 2,
	outlineColor: c_white,
	textFont: ft_dialogue,
	textSpacing: 30,
	
	constructDialogue: function(textI, hasSpriteI, spriteI, hasAdvanceInputI) {
		return {
			text: textI,
			sprite: spriteI,
			hasSprite: hasSpriteI,
			hasAdvanceInput: hasAdvanceInputI
		}
	},
	setDialogue: function(dialogueI) {
		curDialogue = dialogueI;
		activateDialogue();
	},
	removeDialogue: function(dialogueI) {
		if (curDialogue == dialogueI) deactivateDialogue();
	},
	enqueueDialogue: function(dialogueI) {
		textArrQueue[textArrQueueIndex] = dialogueI;
		textArrQueueIndex++;
		if (textArrQueueIndex == textArrQueueCap) {
			textArrQueueIndex = 0;
		}
		textArrQueueSize++;
	},
	enqueueDialogueArray: function(dialogueArrI) {
		var dialogueAmount = array_length(dialogueArrI);
		for (var i = 0; i < dialogueAmount; i++) {
			textArrQueue[textArrQueueIndex] = dialogueArrI[i];
			textArrQueueIndex++;
			if (textArrQueueIndex == textArrQueueCap) {
				textArrQueueIndex = 0;
			}
			textArrQueueSize++;
		}
	},
	dequeueDialogue: function() {
		textArrQueue[curDialogueIndex] = undefined;
		curDialogueIndex++;
		if (curDialogueIndex == textArrQueueCap) {
			curDialogueIndex = 0;
		}
		textArrQueueSize--;
		if (textArrQueueSize == 0) {
			deactivateDialogue();
		}
	},
	activateQueue: function() {
		isQueueActive = true;
	},
	deactivateQueue: function() {
		isQueueActive = false;
	},
	clearDialogueQueue: function() {
		for (var i = curDialogueIndex; i < textArrQueueSize; i++) {
			delete textArrQueue[i];
		}
		textArrQueueSize = 0;
		textArrQueue = array_create(256, undefined);
		textArrQueueIndex = 0;
		curDialogueIndex = 0;
		hasDialogue = false;
	},
	getCurrentQueueDialogue: function() {
		return textArrQueue[curDialogueIndex];
	},
	activateDialogue: function() {
		hasDialogue = true;
	},
	deactivateDialogue: function() {
		hasDialogue = false;
	},
	
	endStepEvent: function() {
		if (!hasDialogue) {
			if (textArrQueueSize != 0) {
				activateDialogue();
			}
		}else {
			if (curDialogue.hasAdvanceInput && InputManager.isInputActivated(input_ID.advance)) {
				deactivateDialogue();
			}
		}
	},
	
	drawGUIEvent: function() {
		if (hasDialogue) {
			draw_set_color(outlineColor);
			draw_rectangle(
				x1-outlineThickness, y1-outlineThickness,
				x2-1+outlineThickness, y2-1+outlineThickness,
			false);
			draw_set_color(c_black);
			draw_rectangle(x1, y1, x2-1, y2-1, false);
			draw_set_font(textFont);
			draw_set_color(c_white);
			var curTextX1 = textX1;
			if (curDialogue.hasSprite) curTextX1 = textSprX1;
			draw_text_ext(curTextX1, textY1, curDialogue.text, textSpacing, textX2-curTextX1);
		}
	},
	initialize: function() {
		var xBorder = 100;
		x1 = xBorder;
		x2 = gameResolutionWidth-xBorder;
		var textXBorder = 40;
		textX1 = x1+textXBorder;
		textX2 = x2-textXBorder;
	}
}

DialogueManager.initialize();

#endregion

#region Gameplay manager

#macro GameplayManager global.gameplayManager
	enum layers {
		entities,
		collision,
		camouflageBack,
		camouflageFront
	}
	enum tool_ID {
		dagger,
		gun
	}
	#macro skinAmount 8
	enum skin_ID {
		green,
		red,
		blue,
		unpleasantGradient,
		square,
		gostoso,
		aRank,
		sRank,
		pRank
	}
#macro PointsManager global.gameplayManager.pointManager
	#macro basePointConstant 100
#macro HUDManager global.gameplayManager.hudManager
#macro PlayerManager global.gameplayManager.playerManager
#macro StageObjectManager global.gameplayManager.stageObjectManager
	#macro defaultStatHUDYoffsetAdd 7
#macro CollisionGridManager global.gameplayManager.collisionGridManager
	#macro collisionGrid_matrix CollisionGridManager.matrix
	#macro collisionGrid_width CollisionGridManager.width
	#macro collisionGrid_height CollisionGridManager.height
	#macro collisionGrid_tileSize 16
	#macro BlockCollisionGrid global.blockCollision
		#macro collisionType_nothing 0b111
		#macro collisionType_normal 0
		#macro collisionType_onewayUp 1
		#macro collisionType_onewayLeft 2
		#macro collisionType_onewayRight 3
		#macro outOfBounds_collisionType collisionType_normal
	#macro InstanceCollisionGrid global.instanceCol
	#macro CamouflageCollisionGrid global.camouflageCol
#macro ObjectManager_Camouflage global.gameplayManager.objectManagers.camouflage
#macro CameraManager global.gameplayManager.cameraManager
#macro PausingManager global.gameplayManager.pausingManager
#macro InterfaceManager global.gameplayManager.interfaceManager
	#macro EnergyInterface global.gameplayManager.energyInterface
	#macro HlthInterface global.gameplayManager.hlthInterface
	#macro TargettingInterface global.gameplayManager.targettingInterface
		enum if_targetting_targetTypes {
			instance, object
		}
	#macro StatHUDInterface global.gameplayManager.statHUDInterface
		#macro statHUDDefaultPipSize 4
	#macro if_physics global.gameplayManager.physicsInterface
		#macro physicsDefaultFriction 0.7
		#macro physicsDefaultGrv 0.6
	#macro if_decoration global.gameplayManager.decorationInterface
#macro AlarmManager global.gameplayManager.alarmManager
#macro ActionObjectManagers global.gameplayManager.actionObjectManagers
#macro TileManager global.gameplayManager.tileManager
	#macro TileMng_defTileSize 16
	#macro tileMapAmount 4
	enum tileMapIndexes {
		background, back, front, camouflage
	}
	#macro type_defaultType_tileAmount 45 // OBSERVATION100 - Rename this variable.
	enum type_defaultType_sprIndex { // OBSERVATION100 - Rename this variable.
		outerCornerLeftUp, outerCornerRightUp, outerCornerTLeftUp, outerCornerTRightUp, outerCornerLeftTUp, outerCornerRightTUp, thinDown, thinRight, borderTLeft, borderTUp,
		outerCornerLeftDown, outerCornerRightDown, outerCornerTLeftDown, outerCornerTRightDown, outerCornerLeftTDown, outerCornerRightTDown, thinUp, thinLeft, borderTDown, borderTRight,
		borderLeft, borderUp, thinCornerRightDown, thinCornerLeftDown, innerCornerLeftUp, innerCornerRightUp, TDown, TUp, thinCrossButRightDown, thinCrossButLeftDown, 
		borderDown, borderRight, thinCornerRightUp, thinCornerLeftUp, innerCornerLeftDown, innerCornerRightDown, TRight, TLeft, thinCrossButRightUp, thinCrossButLeftUp,
		thinVertical, thinHorizontal, single, thinCross, center
	}
	#macro type_defaultThickType_tileAmount 13 // OBSERVATION100 - Rename this variable.
	enum type_defaultThickType_sprIndex { // OBSERVATION100 - Rename this variable.
		outerCornerLeftUp, outerCornerRightUp, innerCornerLeftUp, innerCornerRightUp,
		outerCornerLeftDown, outerCornerRightDown, innerCornerLeftDown, innerCornerRightDown,
		borderLeft, borderUp, borderRight, borderDown,
		center
	}
	#macro type_defaultPlatformType_tileAmount 5 // OBSERVATION100 - Rename this variable.
	enum type_defaultPlatformType_sprIndex { // OBSERVATION100 - Rename this variable.
		middle, borderLeft, borderRight, endLeft, endRight, borderLeftEnd, borderRightEnd, borderAll, endAll
	}
	#macro type_horizontalCyclic_tileAmountPerCycle 4
	enum type_horizontalCyclic_rowRoles { // OBSERVATION100 - Possibly rename this enumerator.
		middle, borderLeft, borderRight, borderAll
	}
	#macro type_line_tileAmount 4
	enum type_line_sprIndexRoles {
		middle, borderLeft, borderRight, borderAll
	}
	enum type_line_direction {
		horizontal, vertical
	}
#macro BackgroundManager global.gameplayManager.backgroundManager

global.gameplayManager = {
	isThereGameplay: false,
	hasRoomStarted: false,
	currentGameplayBlueprint: undefined,
	curStartBlueprint: undefined,
	isFinishingStage: false,
	isRestartingRoom: false,
	isSavingGameplay: false,
	
	stageFinishMenuInfo: {
		isMainLevel: false
	},
	
	layerArray: array_create(4),
	
	toolArray: array_create(20),
	
	backgroundColor: c_black,
	
	initialize: function() {
		initializeTools();
		initializeInterfaces();
		initializeSkins();
		PlayerManager.initialize();
		StageObjectManager.initialize();
		CameraManager.initialize();
		CollisionGridManager.initialize();
		PausingManager.initialize();
		TileManager.initializeTileSets();
	},
	
	#region Gameplay blueprint
	
	setGameplayBlueprint: function(gameplayBlueprintI) {
		if (is_struct(currentGameplayBlueprint)) {
			cleanupGameplayBlueprint();
		}
		
		currentGameplayBlueprint = {};
		struct_copy(gameplayBlueprintI, currentGameplayBlueprint);
		currentGameplayBlueprint.stageObjectMap = ds_map_create();
		ds_map_copy(currentGameplayBlueprint.stageObjectMap, gameplayBlueprintI.stageObjectMap);
	},
	cleanupGameplayBlueprint: function() {
		ds_map_destroy(currentGameplayBlueprint.stageObjectMap);
		delete currentGameplayBlueprint;
	},
	loadGameplayBlueprint: function() {
		PointsManager.load();
		PlayerManager.load();
		CameraManager.loadRegionArray(currentGameplayBlueprint);
		StageObjectManager.load();
	},
	saveGameplayBlueprint: function() {
		isSavingGameplay = true;
	},
	saveGameplayBlueprintApply: function() {
		isSavingGameplay = false;
		PointsManager.save();
		PlayerManager.save();
		StageObjectManager.save();
		UserManager.setContinuedMainLevel();
		UserManager.saveUserInfo();
	},
	constructInitialGameplayBlueprint: function(hlthI, hlthPacketsI, mainInventoryArrI, stageObjectMapI) {
		return {
			playerInfo: PlayerManager.constructPlayerInfo(hlthI, hlthPacketsI, mainInventoryArrI),
			isPointInfoSaved: false,
			pointInfo: PointsManager.constructInitialPointInfo(),
			stageObjectMap: stageObjectMapI
		}
	},
	
	#endregion
	
	#region Start blueprint
	
	constructStartBlueprint: function(restartAmountI) {
		var curStruct = {
			restartAmount: restartAmountI,
		}
		return curStruct;
	},
	constructInitialStartBlueprint: function() {
		return constructStartBlueprint(0);
	},
	constructStartBlueprintFromGameplay: function() {
		return constructStartBlueprint(PointsManager.restartAmount);
	},
	
	#endregion
	
	#region Restarting room
	
	restartRoom: function() {
		isRestartingRoom = true;
	},
	restartRoomApply: function() {
		isRestartingRoom = false;
		PointsManager.notifyRestart();
		DialogueManager.clearDialogueQueue();
		room_restart();
	},
	
	#endregion
	
	finishCurrentStage: function() { // OBSERVATION090
		isFinishingStage = true;
		stageFinishMenuInfo.isMainLevel = MainLevelManager.isMainLevelBeingPlayed;
		PointsManager.finish();
		StageManager.finish();
		UserManager.resetContinuedMainLevel();
		UserManager.saveUserInfo();
		
		TransitionManager.exitMainLevel();
		TransitionManager.goToMenu(MenuManager.getMenu(menu.levelFinish));
	},
	
	stageStartSetup: function() { // OBSERVATION001 - See how greatly this function is located. If it can be made better.
		isThereGameplay = true;
		if (!TransitionManager.isContinuingStage) { // OBSERVATION001 - See if you can organize the two options more properly.
			setGameplayBlueprint(StageManager.currentStage.initialGameplayBlueprint);
			curStartBlueprint = constructInitialStartBlueprint();
		}else {
			setGameplayBlueprint(UserManager.userContinuedStageInfo.continuedStageGameplayBlueprint);
			curStartBlueprint = UserManager.userContinuedStageInfo.continuedStageStartBlueprint;
		}
	},
	
	// Challenges
	completeChallenge: function(challengeIDI) {
		var hasCompleted = LevelChallengeManager.completeChallenge(MainLevelManager.currentMainLevel.id, challengeIDI);
		if (hasCompleted) HUDManager.notifyCompletedChallenge(challengeIDI);
	},
	
	// Layers
	instantiateLayers: function() {
		layerArray[0] = layer_create(0);
		layerArray[1] = layer_create(10);
		layerArray[2] = layer_create(20);
		layerArray[3] = layer_create(-10);
	},
	
	// Tools
	initializeTools: function() {
		var constructTool = function(nameI, slotSpriteIndexI) {
			return {
				name: nameI,
				slotSpriteIndex: slotSpriteIndexI,
				isSelected: false,
	
				cleanup: function() {
					
				},
	
				tick: function() {
					
				}
			}
		}
		
		// Dagger
		toolArray[tool_ID.dagger] = constructTool("Dagger", 0);
		with (toolArray[tool_ID.dagger]) {
			tick = function() {
			}
		}
		
		// Gun
		toolArray[tool_ID.gun] = constructTool("Gun", 1);
		with (toolArray[tool_ID.gun]) {
			tick = function() {
			}
		}
	},
	
	// Skins
	selectedSkinID: 0,
	initializeSkins: function() {
		if (!UserManager.hasSaveFile) {
			UserManager.unlockedSkins = array_create(skinAmount);
			UserManager.unlockedSkins[0] = true;
		}
	},
	
	#region EVENTS
	
	stageStartEvent: function() { // OBSERVATION091
		stageStartSetup();
		
		MusicManager.setMusic(music_gameplay); // OBSERVATION096 - Put this function in the right place.
		PointsManager.stageStartEvent();
		CollisionGridManager.stageStartEvent();
		StageObjectManager.stageStartEvent();
		TileManager.stageStartEvent();
		objectManagers.stageStartEvent();
	},
	stageEndEvent: function() { // OBSERVATION092
		isThereGameplay = false;
		isFinishingStage = false;
		cleanupGameplayBlueprint();
		objectManagers.stageEndEvent();
		StageObjectManager.stageEndEvent();
		CollisionGridManager.stageEndEvent();
		TileManager.stageEndEvent();
	},
	roomStartEvent: function() {
		if (isThereGameplay) {
			hasRoomStarted = true;
			
			instantiateLayers();
			loadGameplayBlueprint();
			objectManagers.roomStartEvent();
			HUDManager.roomStartEvent();
			CameraManager.roomStartEvent();
			StageManager.currentStage.manager.roomStartEvent();
		}
	},
	roomEndEvent: function() {
		if (hasRoomStarted) {
			hasRoomStarted = false;
			StageObjectManager.roomEndEvent();
			CollisionGridManager.roomEndEvent();
			HUDManager.roomEndEvent();
			AlarmManager.roomEndEvent();
			ActionObjectManagers.roomEndEvent();
		}
	},
	beginStepEvent: function() {
		if (isThereGameplay) {
			PausingManager.beginStepEvent();
			if (PausingManager.isActive) {
				return;
			}
			
			// Restart
			if (InputManager.isInputActivated(input_ID.restart)) {
				restartRoom();
				return;
			}
			
			if (MobileControlManager.isActive) MobileControlManager.gameplay.beginStepEvent();
			PointsManager.beginStepEvent();
			PlayerManager.beginStepEvent();
			objectManagers.beginStepEvent();
			HUDManager.beginStepEvent();
			CameraManager.beginStepEvent();
		}
	},
	endStepEvent: function() {
		if (isThereGameplay) {
			if (PausingManager.isActive) {
				return;
			}
			InterfaceManager.endStepEvent();
			AlarmManager.endStepEvent();
			ActionObjectManagers.endStepEvent();
			StageManager.currentStage.manager.endStepEvent();
			
			// Applying end actions.
			if (isSavingGameplay) saveGameplayBlueprintApply();
			if (isRestartingRoom) restartRoomApply();
		}
	},
	drawEvent: function() {
		if (isThereGameplay) {
			objectManagers.drawEvent();
		}
	},
	drawBeginEvent: function() {
		if (isThereGameplay) {
			draw_clear(backgroundColor);
			BackgroundManager.drawBeginEvent();
			TileManager.drawBeginEvent();
			objectManagers.drawBeginEvent();
		}
	},
	drawEndEvent: function() {
		if (isThereGameplay) {
			TileManager.drawEndEvent();
			HUDManager.drawEndEvent();
		}
	},
	drawGUIEvent: function() {
		if (isThereGameplay) {
			HUDManager.drawGUIEvent();
			if (MobileControlManager.isActive) MobileControlManager.gameplay.drawGUIEvent();
		}
	},
	drawGUIEndEvent: function() {
		if (isThereGameplay) {
			PausingManager.drawGUIEndEvent();
		}
	},
	
	#endregion
	
	#region Sub-managers
	
	pointManager: {
		curPoints: 0,
		killPoints: 0,
		killAmount: 0,
		comboPoints: 0,
		damagePenalty: 0,
		isTimeActive: true,
		timeFrames: 0,
		isComboActive: false,
		curCombo: 0,
		curComboPointReward: 0,
		comboLifetime: 300,
		comboLifetimeMax: 420,
		comboLifetimeCur: 0,
		comboPerKillMultiplier: 0.3,
		penaltyPerDmgUnit: 1/50*basePointConstant,
		hasRestarted: false,
		restartAmount: 0,
		pRankingPointMultiplier: 1.5,
	
		pointCurRankIndex: 0,
		timeCurRankIndex: 4,
		pointHasARank: false,
		pointHasSRank: false,
		timeHasARank: true,
		timeHasSRank: true,
	
		curRankIndex: 0,
	
		curRequirements: undefined,
	
		pointPopupYAdd: -20, // OBSERVATION001 - Put this into the HUD manager.
		
		stageFinishMenuInfo: undefined,
		
		#region Events
		
		stageStartEvent: function() {
			restartAmount = GameplayManager.curStartBlueprint.restartAmount;
			curRequirements = StageManager.currentStage.pointRequirements;
			resumeTime(); // OBSERVATION001 - See the times when time should be resumed.
		},
		beginStepEvent: function() {
			if (isTimeActive) {
				timeFrames++;
				updateTimeRank();
				HUDManager.setTime(timeFrames); // OBSERVATION001 - Remove this design philosophy, since there isn't going to be a time where the variables at the HUD manager are different to the point manager.
			}
			if (isComboActive) {
				comboDecreaseLifetime(1);
			}
		},
		
		#endregion
	
		constructStagePointRequirements: function(pointArrI, timeArrI) {
			return {
				pointArr: pointArrI,
				timeArr: timeArrI
			}
		},
		constructStageUserPointInformation: function() {
			return {
				points: 0,
				time: 0,
				ranking: 0
			}
		},
		constructLastPointInfo: function() {
			return {
				curPoints: PointsManager.curPoints,
				killPoints: PointsManager.killPoints,
				killAmount: PointsManager.killAmount,
				comboPoints: PointsManager.comboPoints,
				damagePenalty: PointsManager.damagePenalty,
				timeFrames: PointsManager.timeFrames,
				isComboActive: PointsManager.isComboActive,
				curCombo: PointsManager.curCombo,
				comboLifetimeCur: PointsManager.comboLifetimeCur
			}
		},
		constructInitialPointInfo: function() {
			return {
				curPoints: 0,
				killPoints: 0,
				killAmount: 0,
				comboPoints: 0,
				damagePenalty: 0,
				timeFrames: 0,
				isComboActive: false,
				curCombo: 0,
				comboLifetimeCur: 0
			}
		},
		updateStageFinishMenuInfo: function() {
			var curInfo = UserManager.getStageInfoFromStruct(StageManager.currentStage);
			stageFinishMenuInfo = {
				currentStage: StageManager.currentStage,
				curPoints: PointsManager.curPoints,
				killPoints: PointsManager.killPoints,
				comboPoints: PointsManager.comboPoints,
				damagePenalty: PointsManager.damagePenalty,
				timeFrames: PointsManager.timeFrames,
				restartAmount: PointsManager.restartAmount,
				ranking: PointsManager.curRankIndex,
				
				hasPrevScore: curInfo.hasBeenFinished,
				highscore: undefined,
				smallestTime: undefined
			};
			if (stageFinishMenuInfo.hasPrevScore) {
				stageFinishMenuInfo.highscore = curInfo.pointInformation.points;
				stageFinishMenuInfo.smallestTime = curInfo.pointInformation.time;
			}
		},
		updateStagePointInfo: function() {
			var curInfo = UserManager.getStageInfoFromStruct(StageManager.currentStage);
			var curPointInfo = curInfo.pointInformation;
			var curPointRequirements = StageManager.currentStage.pointRequirements;
		
			if (!curInfo.hasBeenFinished || curPoints > curPointInfo.points) curPointInfo.points = curPoints;
			if (!curInfo.hasBeenFinished || timeFrames < curPointInfo.time) curPointInfo.time = timeFrames;
			if (!curInfo.hasBeenFinished || curRankIndex > curPointInfo.ranking) {
				var curPrevRanking = curPointInfo.ranking;
				curPointInfo.ranking = curRankIndex;
				if (!StageManager.currentStage.isRankless) {
					if (curInfo.hasBeenFinished) UserManager.userRankingAmount[curPointInfo.ranking]--;
					UserManager.userRankingAmount[curPointInfo.ranking]++;
				}
			}
		},
		save: function() {
			GameplayManager.currentGameplayBlueprint.pointInfo = constructLastPointInfo();
		},
		load: function() {
			var curPointInfo = GameplayManager.currentGameplayBlueprint.pointInfo;
			curPoints = curPointInfo.curPoints;
			killPoints = curPointInfo.killPoints;
			killAmount = curPointInfo.killAmount;
			comboPoints = curPointInfo.comboPoints;
			damagePenalty = curPointInfo.damagePenalty;
			timeFrames = curPointInfo.timeFrames;
			isComboActive = curPointInfo.isComboActive;
			curCombo = curPointInfo.curCombo;
			comboLifetimeCur = curPointInfo.comboLifetimeCur;
		},
		
		#region Ranking calculation
		calculateRanking: function() {
			curRankIndex = (pointCurRankIndex+timeCurRankIndex) div 2;
		},
		updatePointRank: function() { // OBSERVATION001 - See if it's updating points properly.
			var maxPointRank = rankings.S;
			var minPointRank = 0;
			while (pointCurRankIndex < maxPointRank && curPoints >= curRequirements.pointArr[pointCurRankIndex]) {
				pointCurRankIndex++;
				if (!pointHasSRank && pointCurRankIndex == rankings.S) {
					pointHasSRank = true;
					pointHasARank = true;
					HUDManager.notifyPointSRank();
				}else if (!pointHasARank && pointCurRankIndex == rankings.A) {
					pointHasARank = true;
					HUDManager.notifyPointARank();
				}
			}
			while (pointCurRankIndex > minPointRank && curPoints < curRequirements.pointArr[pointCurRankIndex-1]) {
				pointCurRankIndex--;
				if (pointHasARank && pointCurRankIndex == rankings.B) {
					pointHasSRank = false;
					pointHasARank = false;
					HUDManager.notifyPointNoRank();
				}else if (pointHasSRank && pointCurRankIndex == rankings.A) {
					pointHasSRank = false;
					HUDManager.notifyPointARank();
				}
			}
		},
		updateTimeRank: function() { // OBSERVATION001 - See if it's updating points properly.
			var nonPRankAmount = 4;
			var maxTimeRank = rankings.S;
			var minTimeRank = 0;
			while (timeCurRankIndex < maxTimeRank && timeFrames < curRequirements.timeArr[nonPRankAmount-timeCurRankIndex-1]) {
				timeCurRankIndex++;
				if (!timeHasSRank && timeCurRankIndex == rankings.S) {
					timeHasSRank = true;
					timeHasARank = true;
					HUDManager.notifyTimeSRank();
				}else if (!timeHasARank && timeCurRankIndex == rankings.A) {
					timeHasARank = true;
					HUDManager.notifyTimeARank();
				}
			}
			while (timeCurRankIndex > minTimeRank && timeFrames >= curRequirements.timeArr[nonPRankAmount-timeCurRankIndex]) {
				timeCurRankIndex--;
				if (timeHasARank && timeCurRankIndex == rankings.B) {
					timeHasSRank = false;
					timeHasARank = false;
					HUDManager.notifyTimeNoRank();
				}else if (timeHasSRank && timeCurRankIndex == rankings.A) {
					timeHasSRank = false;
					HUDManager.notifyTimeARank();
				}
			}
		},
		#endregion
		
		#region Time
		stopTime: function() {
			isTimeActive = false;
		},
		resumeTime: function() {
			isTimeActive = true;
		},
		#endregion
		
		#region Notifications
		notifyEnemyKill: function(instI) {
			killAmount++;
			receivePoints(instI.killPoints);
			killPoints += instI.killPoints;
			HUDManager.pointPopups.add(instI.killPoints, instI.x, instI.y-sprite_get_height(instI.sprite_index)/2+pointPopupYAdd);
		
			if (!isComboActive) {
				comboStart();
			}
			comboAddKill(instI.killPoints);
		},
		notifyPlayerDmg: function(dmgI) {
			var curPointPenalty = ceil(penaltyPerDmgUnit*dmgI);
			damagePenalty += curPointPenalty;
			receivePointPenalty(curPointPenalty);
			HUDManager.pointPopups.add(-curPointPenalty, obj_player.x, obj_player.y-sprite_get_height(obj_player.sprite_index)/2+pointPopupYAdd);
		
			if (isComboActive) {
				comboDecreaseLifetime(comboLifetimeMax/4);
			}
		},
		#endregion
		
		#region General point functions
		receivePoints: function(pointsI) {
			curPoints += pointsI;
			updatePointRank();
		
			HUDManager.point.flash();
			HUDManager.pointUpdateAmount(curPoints);
		},
		receivePointPenalty: function(pointsI) {
			curPoints -= pointsI;
			HUDManager.point.flash();
			HUDManager.pointUpdateAmount(curPoints);
		},
		getPoints: function() {
			return curPoints;
		},
		#endregion
		
		#region Combos
		comboStart: function() {
			isComboActive = true;
		},
		comboAddKill: function(killPointRewardI) {
			curCombo++;
			curComboPointReward += killPointRewardI;
			comboLifetimeCur += comboLifetime;
			if (comboLifetimeCur > comboLifetimeMax) comboLifetimeCur = comboLifetimeMax;
		},
		comboDecreaseLifetime: function(decreaseI) {
			comboLifetimeCur -= decreaseI;
			if (comboLifetimeCur <= 0) {
				comboEnd();
			}
		},
		comboEnd: function() {
			isComboActive = false;
			comboLifetimeCur = 0;
			if (curCombo > 1) {
				var curReceivedPoints = curComboPointReward*comboPerKillMultiplier*(curCombo-1);
				comboPoints += curReceivedPoints;
				receivePoints(curReceivedPoints);
				HUDManager.pointPopups.addCombo(curReceivedPoints, curCombo, obj_player.x, obj_player.y-sprite_get_height(obj_player.sprite_index)/2+pointPopupYAdd);
			}
			curCombo = 0;
		},
		getComboLifetimeRatio: function() {
			return comboLifetimeCur/comboLifetime;
		},
		#endregion
		
		// FINISHING
		finish: function() {
			comboEnd();
			stopTime();
			calculateRanking();
			
			updateStageFinishMenuInfo();
			updateStagePointInfo();
		},
		
		// RESTART
		notifyRestart: function() {
			hasRestarted = false;
			restartAmount++;
		}
		
	},
	
	pausingManager: { // OBSERVATION093 - Pausing should remove other stuff too, such as HUD and dialogue.
		isActive: false,
		isMenuActive: false,
		x1: 0, y1: 0, x2: 0, y2: 0,
		buttons: {
			x1: 0, x2: 0,
			yStart: 220, ySpacing: 50,
			height: 40,
			amount: 2,
			array: array_create(2),
			sprArray: ["Continuar", "Salvar e sair"]
		},
		outlineThickness: 2,
		blackBackAlpha: 0.5,
		backSprite: 0,
		
		pause: function() {
			isActive = true;
			backSprite = sprite_create_from_surface(application_surface, 0, 0, gameResolutionWidth, gameResolutionHeight, false, false, 0, 0);
			instance_deactivate_all(false);
			instance_activate_object(obj_gameManager);
		},
		pauseWithMenu: function() {
			pause();
			isMenuActive = true;
			with (buttons) {
				for (var i = 0; i < amount; i++) {
					var curY = yStart+i*ySpacing;
					array[i] = ButtonManager.createButton(x1, curY, x2, curY+height, -100);
				}
			}
		},
		resume: function() {
			sprite_delete(backSprite);
			isActive = false;
			instance_activate_all();
			if (isMenuActive) {
				resumeWithMenu();
			}
		},
		resumeWithMenu: function() {
			isMenuActive = false;
			with (buttons) {
				for (var i = 0; i < amount; i++) {
					ButtonManager.destroyButton(array[i]);
				}
			}
		},
		beginStepEvent: function() {
			if (InputManager.isInputActivated(input_ID.pause)) {
				if (!isActive) {
					pauseWithMenu();
				}else {
					resume();
				}
			}
			
			if (isActive) {
				if (isMenuActive) {
					if (ButtonManager.isButtonSelected(buttons.array[0])) {
						resume();
					}else if (ButtonManager.isButtonSelected(buttons.array[1])) {
						resume();
						TransitionManager.exitMainLevel();
						TransitionManager.goToMenu(MenuManager.getMenu(menu.levels));
					}
				}
			}
		},
		drawGUIEndEvent: function() {
			if (isActive) {
				draw_sprite(backSprite, 0, 0, 0);
				draw_set_alpha(blackBackAlpha);
				draw_set_color(c_black);
				draw_rectangle(0, 0, gameResolutionWidth, gameResolutionHeight, false);
				draw_set_alpha(1.0);
				
				if (isMenuActive) {
					draw_set_color(c_white);
					draw_rectangle(x1, y1, x2-1, y2-1, false);
					draw_set_color(c_black);
					draw_rectangle(x1+outlineThickness, y1+outlineThickness, x2-1-outlineThickness, y2-1-outlineThickness, false);
				
					with (buttons) {
						for (var i = 0; i < amount; i++) {
							global.drawButtonDefault(array[i], sprArray[i]);
						}
					}
				}
			}
		},
		initialize: function() {
			var xAdd = 200;
			var yAdd = 200;
			x1 = xAdd;
			x2 = gameResolutionWidth-xAdd;
			y1 = yAdd;
			y2 = gameResolutionHeight-yAdd;
			
			with (buttons) {
				var width = 136;
				var textArray = ["Continuar", "Salvar e sair"];
				x1 = (gameResolutionWidth-width)/2;
				x2 = (gameResolutionWidth-width)/2+width;
				for (var i = 0; i < amount; i++) {
					var curY = yStart+i*ySpacing;
					var newButton = ButtonManager.createButton(x1, curY, x2, curY+height, -100);
					sprArray[i] = global.generateButtonSpriteFromText(newButton, textArray[i], ft_levelInfo);
					ButtonManager.destroyButton(newButton);
				}
			}
		}
	},
	
	alarmManager: {
		initialArrCap: 128,
		array: array_create(128, undefined),
		index: 0,
		queue: ds_queue_create(),
		
		roomEndEvent: function() {
			deleteAll();
		},
		endStepEvent: function() {
			while (!ds_queue_empty(queue)) {
				var curAlarm = ds_queue_dequeue(queue);
				with (curAlarm) {
					var _func = func;
					with (inst) {
						_func();
					}
				}
			}
		},
		
		constructAlarm: function(instI, functionI) {
			var newAlarm = {
				inst: instI,
				func: functionI
			}
			var curIndex = index;
			array[index] = newAlarm;
			while (index < array_length(array) && array[index] != undefined) {
				index++;
			}
			return curIndex;
		},
		deleteAlarm: function(idI) {
			delete array[idI];
			array[idI] = undefined;
			while (array_length(array) != initialArrCap && array_last(array) == undefined) array_resize(array, array_length(array)-1);
		},
		deleteAll: function() {
			var curLength = array_length(array);
			for (var i = 0; i < curLength; i++) {
				if (array[i] != undefined) deleteAlarm(i);
			}
		},
		activate: function(idI) {
			if (idI >= array_length(array) || array[idI] == undefined) {
				show_debug_message("AlarmManager.activate() function error!!!");
				show_debug_message("Could not find alarm ID "+string(idI)+"!!!");
				return;
			}
			ds_queue_enqueue(queue, array[idI]);
		}
	},
	
	playerManager: {
		hlthMax: 100,
		hlth: undefined,
		hlthPacketMax: 3,
		hlthPacketCur: undefined,
		hlthPacketHeal: 70,
		isDead: false,
		
		charge: 0,
		chargeMax: 6,
		
		constructPlayerInfo: function(hlthI, hlthPacketCurI, mainInventoryArrI) {
			return {
				hlth: hlthI,
				hlthPacketCur: hlthPacketCurI,
				mainInventoryArr: mainInventoryArrI
			}
		},
		load: function() {
			isDead = false;
			charge = 6;
			hlth = GameplayManager.currentGameplayBlueprint.playerInfo.hlth;
			hlthPacketCur = GameplayManager.currentGameplayBlueprint.playerInfo.hlthPacketCur;
			mainInventory.clear();
			var curMainInventoryArr = GameplayManager.currentGameplayBlueprint.playerInfo.mainInventoryArr;
			for (var i = 0; i < array_length(curMainInventoryArr); i++) {
				mainInventory.receiveItem(curMainInventoryArr[i]);
			}
			mainInventory.selectIndex(0);
		},
		save: function() {
			var newPlayerInfo = constructPlayerInfo(hlth, hlthPacketCur, mainInventory.returnBlueprintArr());
			GameplayManager.currentGameplayBlueprint.playerInfo = newPlayerInfo;
		},
		
		initialize: function() {
			mainInventory.initialize();
		},

		mainInventory: {
			capacity: 4,
			array: [],
			occupationArray: [],
			selectedIndex: 0,
	
			initialize: function() {
				clear();
			},
			tick: function() {
				for (var i = 0; i < capacity; i++) {
					if (occupationArray[i]) {
						GameplayManager.toolArray[array[i]].tick();
					}
				}
			},
			selectIndex: function(indexI) {
				if (occupationArray[indexI] == true) {
					GameplayManager.toolArray[array[selectedIndex]].isSelected = false;
					selectedIndex = indexI;
					GameplayManager.toolArray[array[selectedIndex]].isSelected = true;
				}
			},
			getItemStruct: function(indexI) {
				return GameplayManager.toolArray[array[indexI]];
			},
			hasItem: function(toolIDI) {
				for (var i = 0; i < capacity; i++) {
					if (occupationArray[i] && array[i] == toolIDI) {
						return true;
					}
				}
				return false;
			},
			receiveItem: function(itemIndexI) { // OBSERVATION001 - Add limit support. This doesn't check if all slots are occupied.
				var index = 0;
				for (var i = 0; i < capacity; i++) {
					if (occupationArray[i] == false) {
						index = i;
						break;
					}
				}
				array[index] = itemIndexI;
				occupationArray[index] = true;
				selectIndex(index);
			},
			clear: function() {
				selectedIndex = 0;
				array = array_create(capacity);
				occupationArray = array_create(capacity);
			},
			returnBlueprintArr: function() {
				var blueprintArr = [];
				for (var i = 0; i < capacity; i++) {
					if (occupationArray[i] == true) {
						array_push(blueprintArr, array[i]);
					}
				}
				return blueprintArr;
			}
		},
		
		#region EVENTS
		
		beginStepEvent: function() {
			HUDManager.updateMainInventory(mainInventory.array, mainInventory.occupationArray, 4);
		},
		
		#endregion
		
		receiveDamage: function(dmgI) {
			if (obj_player.iFramesCur > 0) return;
			obj_player.iFramesCur = 30;
			audio_play_sound(choose(snd_dmg1, snd_dmg2, snd_dmg3), 0, false);
			PointsManager.notifyPlayerDmg(dmgI);
			if (obj_player.healing.isHealing) obj_player.healing.stop();
			obj_player.damageFlashing.start();
			hlth -= dmgI;
			if (hlth <= 0) {
				hlth = 0;
				isDead = true;
				obj_player.die();
			}
			HUDManager.updateHlth(hlth);
		},

		receiveHlth: function(hlthI) {
			hlth += hlthI;
			if (hlth > hlthMax) {
				hlth = hlthMax;
			}
			HUDManager.updateHlth(hlth);
		},

		setHlth: function(hlthI) {
			hlth = min(hlthI, hlthMax);
			HUDManager.updateHlth(hlth);
		},

		setHlthPacket: function(hlthPacketI) {
			hlthPacketCur = hlthPacketI;
			HUDManager.hlthPacket.flash();
			HUDManager.updateHlthPacket(hlthPacketCur);
		},

		useHlthPacket: function() {
			receiveHlth(hlthPacketHeal);
			HUDManager.hlthPacket.flash();
			hlthPacketCur--;
			HUDManager.updateHlthPacket(hlthPacketCur);
		},

		canReceiveHlthPacket: function(amountI) {
			return hlthPacketCur+amountI <= hlthPacketMax;
		},

		receiveHlthPacket: function(amountI) {
			HUDManager.hlthPacket.flash();
			hlthPacketCur += amountI;
			if (hlthPacketCur > hlthPacketMax) {
				show_debug_message("PlayerManager.receiveHlthPacket() function observation...");
				show_debug_message("Health packet overload (more than the maximum was gotten)");
				hlthPacketCur = hlthPacketMax;
			}
			HUDManager.updateHlthPacket(hlthPacketCur);
		},
		
		initialize: function() {
			mainInventory.initialize();
		}
	},
	
	hudManager: { // OBSERVATION001 - Make the right variables and functions be initialized in struct definition.
		roomStartEvent: function() {
			
			// General
			defaultLifetimeFrames = 260;
			defaultDisappearFrame = 90;
			
			hlthCurLifetime = defaultLifetimeFrames;
			energyCurLifetime = defaultLifetimeFrames;
			fuelCurLifetime = defaultLifetimeFrames;
			
			flashAll = function() {
				healthBar.flash(true);
				hlthPacket.flash(true);
				mainInventory.flash(true);
				point.flash(true);
			}

			notifyPointARank = function() {
				point.pointColor = RankingManager.colors[rankings.A];
			}

			notifyPointSRank = function() {
				point.pointColor = RankingManager.colors[rankings.S];
			}

			notifyPointNoRank = function() {
				point.pointColor = RankingManager.colors[rankings.D];
			}

			notifyTimeARank = function() {
				point.timeColor = RankingManager.colors[rankings.A];
			}

			notifyTimeSRank = function() {
				point.timeColor = RankingManager.colors[rankings.S];
			}

			notifyTimeNoRank = function() {
				point.timeColor = RankingManager.colors[rankings.D];
			}
			
			// Charge
			chargeBar = {
				_p: HUDManager,
				height: 20,
				width: 40,
				lifetimeFrames: HUDManager.defaultLifetimeFrames,
				lifetimeFramesCur: HUDManager.defaultLifetimeFrames,
				disappearFrame: HUDManager.defaultDisappearFrame,
				x: 10,
				y: 50,
				fillColor: c_orange,
				chargePerPip: 2,
				draw: function() {
					var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
					draw_set_alpha(curMainAlpha);
					
					draw_set_color(c_grey);
					draw_rectangle(x, y, x+40*3+12-1, y+height-1, false);
					draw_set_color(c_orange);
					for (var i = 0; i < 3; i++) {
						var curValue = clamp(PlayerManager.charge-i*chargePerPip, 0, chargePerPip)/chargePerPip;
						var curX = x+3+i*43;
						draw_set_color(c_dkgray);
						draw_rectangle(curX, y+2, curX+width-1, y+20-5+1, false);
						draw_set_color(c_orange);
						draw_rectangle(curX, y+2, curX+width*curValue-1, y+20-5+1, false);
					}
					draw_set_alpha(1.0);
				},
				flash: function(isQuickI) {
					if (isQuickI) lifetimeFramesCur = disappearFrame;
					else lifetimeFramesCur = lifetimeFrames;
				}
			}

			// Health
			hlth = undefined;
			hlthMax = 100;

			updateHlth = function(hlthI) {
				hlth = hlthI;
				healthBar.flash(false);
			}
			healthBar = {
				_p: HUDManager,
				lifetimeFrames: HUDManager.defaultLifetimeFrames,
				lifetimeFramesCur: HUDManager.defaultLifetimeFrames,
				disappearFrame: HUDManager.defaultDisappearFrame,
				fillWidth: 119,
				fillHeight: 19,
				fillColor: c_red,
				x: 10, y: 10,
				draw: function() {
					var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
					draw_set_alpha(curMainAlpha);
					draw_set_color(fillColor);
					var curRatio = HUDManager.hlth/HUDManager.hlthMax;
					draw_rectangle(x, y, x+curRatio*fillWidth, y+fillHeight, false);
					draw_sprite_ext(spr_healthBarBase, 0, x, y, 1.0, 1.0, 0, c_white, curMainAlpha);
					draw_set_alpha(1.0);
				},
				flash: function(isQuickI) {
					if (isQuickI) lifetimeFramesCur = disappearFrame;
					else lifetimeFramesCur = lifetimeFrames;
				}
			}
			updateHlth(PlayerManager.hlth);

			// Point
			pointCurAmount = PointsManager.curPoints;
			pointTargAmount =  PointsManager.curPoints;
			pointInitAmount = 0;
			pointIsUpdatingAmount = false;
			pointAmountUpdateFrames = 60;
			pointAmountUpdateFramesCur = 60;

			timeValueFrames = 0;
			setTime = function(timeFramesI) {
				timeValueFrames = timeFramesI;
			}

			point = {
				_p: HUDManager,
				lifetimeFrames: HUDManager.defaultLifetimeFrames,
				lifetimeFramesCur: HUDManager.defaultLifetimeFrames,
				disappearFrame: HUDManager.defaultDisappearFrame,
				x: 670, y: 8,
				width: 120,
				// Points
					pointColor: c_white,
					pointY1: 0,
					pointY2: 32,
					pointFont: ft_HUDPoints,
					pointTextX: 4,
					pointTextY: 0,
				// Time
					timeColor: c_white,
					timeY1: 34,
					timeY2: 58,
					timeSpr: spr_clockSymbol,
					timeSprX: 19, timeSprY: 12,
					timeTextX: 40,
					timeTextY: 9,
					timeSmallTextX: 40,
					timeSmallTextY: 0,
					timeFont: ft_HUDTime,
					timeSmallFont: ft_HUDTimeSmall,
				// Combo
					comboY1: 60,
					comboY2: 70,
					comboColor: c_white,
					comboBarX: 2,
					comboBarWidth: 0,
					comboBarY1: 4,
					comboBarY2: 9,
				backColor: c_black,
				backCornerSprSet: spr_blackBackCorner,
					cornerTopLeft: 0,
					cornerTopRight: 1,
					cornerBottomLeft: 2,
					cornerBottomRight: 3,
				backBorderThickness: 3,
				backBorderAlpha: 0.6,
				draw: function() {
					var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
					drawBack(curMainAlpha, x, y+pointY1, x+width, y+pointY2, true, false);
					drawBack(curMainAlpha, x, y+timeY1, x+width, y+timeY2, false, false);
					drawBack(curMainAlpha, x, y+comboY1, x+width, y+comboY2, false, true);
		
					// Points
					draw_set_font(pointFont);
					draw_set_color(pointColor);
					var curPointString = string(_p.pointCurAmount)+"P";
					draw_text(x+width-pointTextX-string_width(curPointString), y+pointTextY, curPointString);
		
					// Time
					draw_sprite_ext(timeSpr, 0, x+width-timeSprX, timeY1+timeSprY, 1.0, 1.0, 0, timeColor, curMainAlpha);
					var curTimeString = convertFrameToTime();
					var curTimeSmallStr = timeframes_to_string_small(HUDManager.timeValueFrames);
					draw_set_color(timeColor);
					draw_set_font(timeFont);
					draw_text(x+width-string_width(curTimeString)-timeTextX, timeY1+timeTextY, curTimeString);
					draw_set_font(timeSmallFont);
					draw_text(x+width-timeSmallTextX, timeY1+timeTextY+timeSmallTextY, curTimeSmallStr);
		
					// Combo bar
					var curBarRatio = PointsManager.comboLifetimeCur/PointsManager.comboLifetimeMax;
					draw_set_color(comboColor);
					draw_set_alpha(1.0);
					draw_rectangle(x+comboBarX, y+comboY1+comboBarY1, x+comboBarX+curBarRatio*comboBarWidth-1, y+comboY1+comboBarY2-1, false);
				},
				drawBack: function(alphaI, x1I, y1I, x2I, y2I, hasTopI, hasBottomI) {
					var oldAlpha = alphaI;
					alphaI *= backBorderAlpha;
					draw_set_alpha(alphaI);
					draw_set_color(backColor);
					if (hasTopI) {
						draw_sprite_ext(spr_blackBackCorner, cornerTopLeft, x1I, y1I, 1.0, 1.0, 0, c_white, alphaI);
						draw_sprite_ext(spr_blackBackCorner, cornerTopRight, x2I, y1I, 1.0, 1.0, 0, c_white, alphaI);
						draw_rectangle(x1I, y1I-backBorderThickness, x2I-1, y1I-1, false);
						draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
					}else if (hasBottomI) {
						draw_sprite_ext(spr_blackBackCorner, cornerBottomLeft, x1I, y2I, 1.0, 1.0, 0, c_white, alphaI);
						draw_sprite_ext(spr_blackBackCorner, cornerBottomRight, x2I, y2I, 1.0, 1.0, 0, c_white, alphaI);
						draw_rectangle(x1I, y2I, x2I-1, y2I+backBorderThickness-1, false);
						draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
					}else {
						draw_rectangle(x1I-backBorderThickness, y1I, x2I+backBorderThickness-1, y2I-1, false);
					}
					draw_set_alpha(oldAlpha);
				},
				convertFrameToTime: function() {
					return timeframes_to_string(HUDManager.timeValueFrames);
				},
				flash: function(isQuickI) {
					if (isQuickI) lifetimeFramesCur = disappearFrame;
					else lifetimeFramesCur = lifetimeFrames;
				}
			}
			with (point) {
				comboBarWidth = width-comboBarX*2;
				draw_set_font(timeFont);
				var originalHeight = string_height("a");
				draw_set_font(timeSmallFont);
				timeSmallTextY = originalHeight-string_height("a")-1;
			}
			
			notifyPointNoRank();
			var curRequirements = StageManager.currentStage.pointRequirements;
			var index = 0;
			while (index != rankings.S && pointTargAmount >= curRequirements.pointArr[index]) {
				index++;
				if (index == rankings.A) {
					notifyPointARank();
				}else if (index == rankings.S) {
					notifyPointSRank();
				}
			}
			
			notifyTimeSRank();
			index = 0;
			while (index != rankings.S && timeValueFrames > curRequirements.timeArr[index]) {
				index++;
				if (nonPRankingAmount-index == rankings.A) {
					notifyTimeARank();
				}else if (nonPRankingAmount-index == rankings.B) {
					notifyTimeNoRank();
				}
			}

			pointUpdateAmount = function(pointsI) {
				pointIsUpdatingAmount = true;
				pointAmountUpdateFramesCur = pointAmountUpdateFrames;
				pointTargAmount = pointsI;
				pointInitAmount = pointCurAmount;
			}

			// Point popups
			pointPopups = {
				queue: ds_queue_create(),
				lifetimeFrames: 50,
				comboLifetimeFrames: 80,
				disappearFrame: 20,
				yAdd: -20,
				font: ft_pointPopup,
				color: c_white,
				add: function(pointsI, xI, yI) {
					var curStr = "";
					if (pointsI > 0) {
						curStr += "+";
					}
					curStr += string(pointsI);
					draw_set_font(font);
					ds_queue_enqueue(queue, [lifetimeFrames, curStr, xI-string_width(curStr)/2, yI-string_height(curStr)/2]);
				},
				addCombo: function(pointsI, comboI, xI, yI) {
					var curStr = string(comboI)+"x combo\n+"+string(pointsI);
					draw_set_font(font);
					ds_queue_enqueue(queue, [comboLifetimeFrames, curStr, xI-string_width(curStr)/2, yI-string_height(curStr)/2]);
				},
				tick: function() {
					var tempQueue = ds_queue_create();
					while (!ds_queue_empty(queue)) {
						var curPopup = ds_queue_dequeue(queue);
						curPopup[0]--;
						if (curPopup[0] != 0) {
							ds_queue_enqueue(tempQueue, curPopup);
						}
					}
					ds_queue_destroy(queue);
					queue = tempQueue;
				},
				draw: function() {
					draw_set_color(color);
					draw_set_font(font);
		
					var tempQueue = ds_queue_create();
					while (!ds_queue_empty(queue)) {
						var curPopup = ds_queue_dequeue(queue);
						var curAlpha = min(1.0, curPopup[0]/disappearFrame);
						var curYAdd = (lifetimeFrames-curPopup[0])/lifetimeFrames*yAdd;
						draw_set_alpha(curAlpha);
						draw_text(curPopup[2], curPopup[3]+curYAdd, curPopup[1]);
			
						ds_queue_enqueue(tempQueue, curPopup);
					}
					ds_queue_destroy(queue);
					queue = tempQueue;
		
					draw_set_alpha(1.0);
				},
				cleanup: function() {
					ds_queue_destroy(queue);
				}
			}

			pointSetAmount = function(pointsI) {
				pointTargAmount = pointsI;
				pointCurAmount = pointsI;
			}

			// Combo
			combo = {
				_p: HUDManager,
				x: 624, y: 40,
				font: ft_HUDCombo,
				draw: function() {
					if (PointsManager.isComboActive) {
						var curCombo = PointsManager.curCombo;
						var curString = string(curCombo)+"x";
						draw_set_font(font);
						draw_text(x, y, curString);
					}
				}
			}

			// Health packet
			hlthPacketAmount = undefined;
			updateHlthPacket = function(hlthPacketI) {
				hlthPacketAmount = hlthPacketI;
			}
			hlthPacket = {
				_p: HUDManager,
				lifetimeFrames: HUDManager.defaultLifetimeFrames,
				lifetimeFramesCur: HUDManager.defaultLifetimeFrames,
				disappearFrame: HUDManager.defaultDisappearFrame,
				x: 140, y: 10,
				symbolXStart: 170,
				symbolXSpacing: 32,
				symbolAmount: 3,
				baseSpr: spr_healthPacketBase,
				fillSpr: spr_healthPacketFill,
				occupiedSymbolColor: c_red,
				unoccupiedSymbolColor: c_black,
				tick: function() {
					if (lifetimeFramesCur != 0) {
						lifetimeFramesCur--;
					}
				},
				draw: function() {
					var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
		
					for (var i = 0; i < symbolAmount; i++) {
						var curX = symbolXStart+i*symbolXSpacing;
						draw_sprite_ext(baseSpr, 0, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
			
						var curColor = occupiedSymbolColor;
						if (i >= _p.hlthPacketAmount) {
							curColor = unoccupiedSymbolColor;
						}
						draw_sprite_ext(fillSpr, 0, curX, y, 1.0, 1.0, 0, curColor, curMainAlpha);
					}
				},
				flash: function(isQuickI) {
					if (isQuickI) lifetimeFramesCur = disappearFrame;
					else lifetimeFramesCur = lifetimeFrames;
				}
			}
			with (hlthPacket) {
				symbolXStart = x;
			}
			updateHlthPacket(PlayerManager.hlthPacketCur);

			// Main inventory
			mainInventoryArr = [];
			mainInventorySize = 0;
			updateMainInventory = function(inventoryI, occupationArrayI, inventorySizeI) {
				mainInventoryArr = inventoryI;
				for (var i = 0; i < inventorySizeI; i++) {
					if (!occupationArrayI[i]) {
						mainInventoryArr[i] = -1;
					}
				}
				mainInventorySize = inventorySizeI;
			}
			mainInventory = {
				_p: HUDManager,
				lifetimeFrames: HUDManager.defaultLifetimeFrames,
				lifetimeFramesCur: HUDManager.defaultLifetimeFrames,
				disappearFrame: HUDManager.defaultDisappearFrame,
				x: 10, y: 46,
				slotSprSet: spr_inventorySlotBorder,
				slotSeparatorSpr: spr_inventorySlotBorderSep,
				slotAmount: 4,
				slotXSpacing: -1,
				slotBackColor: c_black,
				slotBackColorAlpha: 0.25,
				slotWidth: 32,
				slotHeight: 32,
				draw: function() {
					var curMainAlpha = min(1.0, lifetimeFramesCur/disappearFrame);
					for (var i = 0; i < slotAmount; i++) {
						var curX = x+slotXSpacing*i;
			
						draw_set_alpha(curMainAlpha*slotBackColorAlpha);
						draw_set_color(slotBackColor);
			
						draw_rectangle(curX, y, curX+slotWidth, y+slotHeight, false);
			
						draw_set_alpha(1.0);
			
						var curTool = _p.mainInventoryArr[i];
						if (curTool != -1)
							draw_sprite_ext(spr_slotSprites, GameplayManager.toolArray[curTool].slotSpriteIndex, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
			
						var isFirstSlot = i == 0;
						var isLastSlot = i == slotAmount-1;
						var curSlotSpriteIndex = 1;
						var drawSeparator = true;
						if (isFirstSlot) {
							curSlotSpriteIndex = 0;
						}else if (isLastSlot) {
							curSlotSpriteIndex = 2;
							drawSeparator = false;
						}
						draw_sprite_ext(slotSprSet, curSlotSpriteIndex, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
						if (drawSeparator)
							draw_sprite_ext(slotSeparatorSpr, 0, curX, y, 1.0, 1.0, 0, c_white, curMainAlpha);
					}
				},
				flash: function(isQuickI) {
					if (isQuickI) lifetimeFramesCur = disappearFrame;
					else lifetimeFramesCur = lifetimeFrames;
				}
			}
			with (mainInventory) {
				var itemSprSize = 32;
				slotXSpacing = itemSprSize+sprite_get_width(slotSeparatorSpr);
			}
			
			// Challenge display
			notifyCompletedChallenge = function(challengeIDI) {
				challenges.addChallenge(challengeIDI);
			}
			challenges = {
				queue: array_create(8, undefined),
				queueTailIndex: 0,
				queueHeadIndex: 0,
				queueCap: 8,
				x: 10, yStart: 10, ySpacing: 52,
				width: 300, height: 44,
				backColor: c_black, backAlpha: 0.3,
				sprX: undefined, sprY: undefined, sprScale: 0.5,
				allInfoFont: ft_levelInfoChallenge, allInfoColor: c_white,
				congratsX: 42, congratsY: 6, congratsStr: "Desafio concluído!",
				mechcoinX: 10, mechcoinY: 6,
				nameX: 42, nameY: 24,
				lifetime: 600,
				blinkLifetime: 100, blinkColor: c_white,
				addChallenge: function(challengeIDI) {
					queue[queueTailIndex] = [challengeIDI, lifetime];
					queueTailIndex++;
					if (queueTailIndex == queueCap) queueTailIndex = 0;
				},
				tick: function() {
					for (var i = queueHeadIndex; i != queueTailIndex; i = (i == queueCap) ? 0 : i+1) {
						var curChallenge = queue[i];
						curChallenge[1]--;
						if (curChallenge[1] == 0) {
							queue[i] = undefined;
							queueHeadIndex++;
							if (queueHeadIndex == queueCap) queueHeadIndex = 0;
						}
					}
				},
				draw: function() {
					var pos = 0;
					for (var i = queueHeadIndex; i != queueTailIndex; i = (i == queueCap) ? 0 : i+1) {
						var curChallengeDisplay = queue[i];
						var curChallenge = LevelChallengeManager.challengeArr[curChallengeDisplay[0]];
						var curY = yStart+pos*ySpacing;
						 
						draw_set_color(backColor);
						draw_set_alpha(backAlpha);
						draw_rectangle(gameResolutionWidth-x-width, gameResolutionHeight-curY-height, gameResolutionWidth-x-1, gameResolutionHeight-curY-1, false);
						draw_set_alpha(1.0);
						draw_sprite_ext(curChallenge.sprite, 0, gameResolutionWidth-x+sprX-width, gameResolutionHeight-curY+sprY-height, sprScale, sprScale, 1.0, c_white, 1.0);
						 
						draw_set_color(allInfoColor);
						draw_set_font(allInfoFont);
						draw_text(gameResolutionWidth-x-width+congratsX, gameResolutionHeight-curY-height+congratsY, congratsStr);
						var curMechcoinStr = "+"+string(curChallenge.mechcoinReward)+"M";
						draw_text(gameResolutionWidth-x-mechcoinX-string_width(curMechcoinStr), gameResolutionHeight-curY-height+congratsY, curMechcoinStr);
						draw_text(gameResolutionWidth-x-width+nameX, gameResolutionHeight-curY-height+nameY, curChallenge.name);
						 
						var curBlinkAlpha = 1-((lifetime-curChallengeDisplay[1])/blinkLifetime);
						if (curBlinkAlpha > 0) {
							draw_set_color(blinkColor);
							draw_set_alpha(curBlinkAlpha);
							draw_rectangle(gameResolutionWidth-x-width, gameResolutionHeight-curY-height, gameResolutionWidth-x-1, gameResolutionHeight-curY-1, false);
						}
						draw_set_alpha(1.0);
						
						pos++;
					}
				},
				initialize: function() {
					var spritePos = height/2;
					sprX = spritePos;
					sprY = spritePos;
				}
			}
			challenges.initialize();
		},
		
		roomEndEvent: function() {
			pointPopups.cleanup();
		},
		
		beginStepEvent: function() {
			if (healthBar.lifetimeFramesCur != 0) {
				healthBar.lifetimeFramesCur--;
			}
			
			if (chargeBar.lifetimeFramesCur != 0) {
				healthBar.lifetimeFramesCur--;
			}

			if (mainInventory.lifetimeFramesCur != 0) {
				mainInventory.lifetimeFramesCur--;
			}

			if (point.lifetimeFramesCur != 0) {
				point.lifetimeFramesCur--;
			}

			if (pointIsUpdatingAmount) {
				pointAmountUpdateFramesCur--;
				if (pointAmountUpdateFramesCur == 0) {
					pointIsUpdatingAmount = false;
					pointCurAmount = pointTargAmount;
				}else {
					var curRatio = (pointAmountUpdateFrames-pointAmountUpdateFramesCur)/pointAmountUpdateFrames;
					pointCurAmount = round(pointInitAmount+curRatio*(pointTargAmount-pointInitAmount));
				}
			}

			hlthPacket.tick();
			
			if (InputManager.isInputActivated(input_ID.seeHUD)) {
				flashAll();
			}
			
			pointPopups.tick();
			challenges.tick();
			StatHUDInterface.tickAll();
		},
		
		drawEndEvent: function() {
			pointPopups.draw();
			StatHUDInterface.drawAll();
		},
		
		drawGUIEvent: function() {
			healthBar.draw();
			chargeBar.draw();
			hlthPacket.draw();
			//mainInventory.draw();
			point.draw();
			combo.draw();
			challenges.draw();
		}
	},
	
	cameraManager: {
		camera: camera_create_view(0, 0, gameResolutionWidth, gameResolutionHeight),
		regionCapacity: 512,
		regionArray: array_create(512),
		regionAmount: 0,
		index: 0,
	
		cameraPosUpdateMultiplier: 0.92,
		targX: 0,
		targY: 0,
		curX: 0,
		curY: 0,
		hasRoomStarted: true,
		
		pushCurDistance: 0,
		pushDirection: 0,
		pushDeaccSpd: 0.4,
		
		initialize: function() {
			room_set_camera(StageManager.stageRoom, 0, camera);
			room_set_view_enabled(StageManager.stageRoom, true);
			room_set_viewport(StageManager.stageRoom, 0, true, 0, 0, 1, 1);
		},

		goToCameraPos: function(xI, yI) {
			targX = xI;
			targY = yI;
			//camera_apply(global.levelCamera);
		},
		setCameraPos: function(xI, yI) {
			targX = xI;
			targY = yI;
			curX = xI;
			curY = yI;
		},
		setPush: function(distanceI, directionI) {
			pushCurDistance = distanceI;
			pushDirection = directionI;
		},

		assignRegionArrayToGameplayBlueprint: function(gameplayBlueprintI) {
			gameplayBlueprintI.regionArray = array_create(regionCapacity);
			array_copy(gameplayBlueprintI.regionArray, 0, regionArray, 0, regionCapacity);
			gameplayBlueprintI.regionAmount = regionAmount;
		},
		addRegion_fixed: function(x1I, y1I, x2I, y2I, cameraXI, cameraYI) {
			regionArray[index] = {
				x1: x1I, y1: y1I, x2: x2I, y2: y2I,
				cameraX: cameraXI, cameraY: cameraYI
			}
			regionAmount++;
			index++;
		},
		loadRegionArray: function(gameplayBlueprintI) {
			reset();
			array_copy(regionArray, 0, gameplayBlueprintI.regionArray, 0, regionCapacity);
			regionAmount = gameplayBlueprintI.regionAmount;
		},
		reset: function() {
			regionArray = array_create(regionCapacity);
			index = 0;
			regionAmount = 0;
		},
		
		#region Events
		
		roomStartEvent: function() {
			hasRoomStarted = true;
		},
		beginStepEvent: function() {
			for (var i = 0; i < regionAmount; i++) {
				var curRegion = regionArray[i];
				if (curRegion.y2 >= obj_player.y && curRegion.y1 < obj_player.y && curRegion.x1 < obj_player.x && curRegion.x2 >= obj_player.x) {
					if (!hasRoomStarted) {
						goToCameraPos(curRegion.cameraX, curRegion.cameraY);
					}else {
						setCameraPos(curRegion.cameraX, curRegion.cameraY);
						hasRoomStarted = false;
					}
					break;
				}
			}
			hasRoomStarted = false;

			if (curX != targX || curY != targY) {
				curX = (curX-targX)*cameraPosUpdateMultiplier+targX;
				curY = (curY-targY)*cameraPosUpdateMultiplier+targY;
			}
			
			var pushCurXAdd = dcos(pushDirection)*pushCurDistance;
			var pushCurYAdd = -dsin(pushDirection)*pushCurDistance;
			camera_set_view_pos(view_camera[0], curX+pushCurXAdd, curY+pushCurYAdd);
			pushCurDistance *= pushDeaccSpd;
		}
		
		#endregion
	},
	
	collisionGridManager: {
		matrix: [],
		isBuilt: false,
		width: 0,
		height: 0,
	
		stageStartEvent: function() {
			var curStage = StageManager.currentStage;
			var curWidth = ceil(curStage.roomWidth/collisionGrid_tileSize);
			var curHeight = ceil(curStage.roomHeight/collisionGrid_tileSize);
			width = curWidth;
			height = curHeight;
			
			var tileAmount = width*height;
			matrix = array_create(curWidth);
			for (var i = 0; i < curWidth; i++) {
				matrix[i] = array_create(curHeight);
				for (var j = 0; j < curHeight; j++) {
					var bufferUsedMemory = 68;
					var bufferUnusedMemory = 1;
					var curBuffer = buffer_create(bufferUsedMemory+bufferUnusedMemory, buffer_fast, 1);
					matrix[i][j] = curBuffer;
					BlockCollisionGrid.setCellToCollisionType(i, j, collisionType_nothing);
					InstanceCollisionGrid.clearCell(i, j);
					CamouflageCollisionGrid.clearCell(i, j);
				}
			}
		},
		stageEndEvent: function() {
			cleanup();
		},
		roomEndEvent: function() {
			InstanceCollisionGrid.roomEndEvent();
		},
		
		initialize: function() {
			blockCollision._p = CollisionGridManager;
			instanceCol._p = CollisionGridManager;
			camouflageCol._p = CollisionGridManager;
		},
	
		cleanup: function() {
			for (var i = 0; i < collisionGrid_width; i++) {
				for (var j = 0; j < collisionGrid_height; j++) {
					buffer_delete(matrix[i][j]);
				}
			}
			matrix = [];
		},
		
		isPositionOutOfBounds: function(xI, yI) {
			return xI < 0 || yI < 0 || xI >= collisionGrid_width || yI >= collisionGrid_height;
		},
		
		outOfBoundsDestroy: function(instI) { // OBSERVATION001 - Remove this shit from here.
			if (instI.x < -100 || instI.y < -100 || instI.x > room_width+100 || instI.y > room_height+100) {
				StageObjectManager.destroyObjectByInstance(instI);
			}
		},
		
		blockCollision: {
			_p: -1,
			bufferSize: 1,
		
			setCellToCollisionType: function(xI, yI, collisionTypeI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, 0);
				var bufferValue = buffer_peek(curBuffer, 0, buffer_u8);
				var binaryColType = collisionTypeI << 5;
				buffer_fill(curBuffer, 0, buffer_u8, (bufferValue & 0b00011111) | binaryColType, 1);
			},
		
			isCellOfCollisionType: function(xI, yI, collisionTypeI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				var bufferValue = buffer_peek(curBuffer, 0, buffer_u8);
				var binaryColType = collisionTypeI << 5;
				return (bufferValue & 0b11100000) == binaryColType;
			},
		
			getCellCollisionType: function(xI, yI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				var bufferValue = buffer_peek(curBuffer, 0, buffer_u8);
				return (bufferValue & 0b11100000) >> 5;
			},
	
			setRegion: function(xIndexI, yIndexI, widthI, heightI, collisionTypeI) {
				for (var i = 0; i < widthI; i++) {
					for (var j = 0; j < heightI; j++) {
						setCellToCollisionType(xIndexI+i, yIndexI+j, collisionTypeI);
					}
				}
			},
	
			setRegion2: function(x1IndexI, y1IndexI, x2IndexI, y2IndexI, collisionTypeI) {
				for (var i = x1IndexI; i <= x2IndexI; i++) {
					for (var j = y1IndexI; j <= y2IndexI; j++) {
						setCellToCollisionType(i, j, collisionTypeI);
					}
				}
			},
	
			setRegionByInstance: function(instI, collisionTypeI) {
				setRegion2(
					floor(instI.bbox_left/collisionGrid_tileSize), floor(instI.bbox_top/collisionGrid_tileSize),
					ceil(instI.bbox_right/collisionGrid_tileSize)-1, ceil(instI.bbox_bottom/collisionGrid_tileSize)-1,
					collisionTypeI
				);
			},
		
			isPositionOutOfBounds: function(x1I, y1I, x2I, y2I) {
				return x1I < 0 || y1I < 0 || x2I >= collisionGrid_width || y2I >= collisionGrid_height;
			},
			
			executeCollisionEvents: function(instI, genericEventI, upPlatformEventI, leftPlatformEventI, rightPlatformEventI) {
				var baseColHIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
				var baseColHIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
				var baseColVIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
				var baseColVIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
				var isGenericEventActivated = false;
				var isUpPlatformEventActivated = false;
				var isLeftPlatformEventActivated = false;
				var isRightPlatformEventActivated = false;
				
				for (var i = max(0, baseColHIndex1I); i <= min(collisionGrid_width-1, baseColHIndex2I); i++) {
					for (var j = max(0, baseColVIndex1I); j <= min(collisionGrid_height-1, baseColVIndex2I); j++) {
						var curCellColType = getCellCollisionType(i, j);
						if (curCellColType != collisionType_nothing) {
							switch (curCellColType) {
								case (collisionType_normal):
									if (!isGenericEventActivated) {isGenericEventActivated = true; genericEventI.notifyBaseCollision();}
									break;
								case (collisionType_onewayUp):
									if (!isUpPlatformEventActivated) {isUpPlatformEventActivated = true; upPlatformEventI.notifyBaseCollision();}
									break;
								case (collisionType_onewayLeft):
									if (!isLeftPlatformEventActivated) {isLeftPlatformEventActivated = true; leftPlatformEventI.notifyBaseCollision();}
									break;
								case (collisionType_onewayRight):
									if (!isRightPlatformEventActivated) {isRightPlatformEventActivated = true; rightPlatformEventI.notifyBaseCollision();}
									break;
							}
						}
					}
				}
				
				var isHoriColNecessary = true;
				var isVertColNecessary = true;
				var isDiagColNecessary = true;
				
				baseColHIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
				baseColHIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
				baseColVIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
				baseColVIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
				
				var horiColDirection;
				var horiColHIndex1I = floor((instI.bbox_left+instI.ifPhysics.hSpd)/collisionGrid_tileSize);
				var horiColHIndex2I = ceil((instI.bbox_right+instI.ifPhysics.hSpd)/collisionGrid_tileSize)-1;
				if (horiColHIndex1I < baseColHIndex1I) {
					horiColHIndex2I = baseColHIndex1I-1;
					horiColDirection = -1;
				}else if (horiColHIndex2I > baseColHIndex2I) {
					horiColHIndex1I = baseColHIndex2I+1;
					horiColDirection = 1;
				}else {
					isHoriColNecessary = false;
					isDiagColNecessary = false;
				}
				
				if (isHoriColNecessary) {
					var horiColVIndex1I = baseColVIndex1I;
					var horiColVIndex2I = baseColVIndex2I;
					var isGenericEventActivated = false;
					var isUpPlatformEventActivated = false;
					var isLeftPlatformEventActivated = false;
					var isRightPlatformEventActivated = false;
					for (var i = max(0, horiColHIndex1I); i <= min(collisionGrid_width-1, horiColHIndex2I); i++) {
						for (var j = max(0, horiColVIndex1I); j <= min(collisionGrid_height-1, horiColVIndex2I); j++) {
							var curCellColType = getCellCollisionType(i, j);
							if (curCellColType != collisionType_nothing) {
								switch (curCellColType) {
									case (collisionType_normal):
										if (!isGenericEventActivated) {
											isGenericEventActivated = true;
											genericEventI.notifyHoriCollision();
										}
										break;
									case (collisionType_onewayUp):
										if (!isUpPlatformEventActivated) {
											isUpPlatformEventActivated = true;
											upPlatformEventI.notifyHoriCollision();
										}
										break;
									case (collisionType_onewayLeft):
										if (!isLeftPlatformEventActivated) {
											isLeftPlatformEventActivated = true;
											leftPlatformEventI.notifyHoriCollision();
										}
										break;
									case (collisionType_onewayRight):
										if (!isRightPlatformEventActivated) {
											isRightPlatformEventActivated = true;
											rightPlatformEventI.notifyHoriCollision();
										}
										break;
								}
							}
						}
					}
				}
				
				var vertColVIndex1I = floor((instI.bbox_top+instI.ifPhysics.vSpd)/collisionGrid_tileSize);
				var vertColVIndex2I = ceil((instI.bbox_bottom+instI.ifPhysics.vSpd)/collisionGrid_tileSize)-1;
				
				baseColHIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
				baseColHIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
				baseColVIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
				baseColVIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
				
				var vertColDirection;
				if (vertColVIndex1I < baseColVIndex1I) {
					vertColVIndex2I = baseColVIndex1I-1;
					vertColDirection = 1;
				}else if (vertColVIndex2I > baseColVIndex2I) {
					vertColVIndex1I = baseColVIndex2I+1;
					vertColDirection = -1;
				}else {
					isVertColNecessary = false;
					isDiagColNecessary = false;
				}
				
				if (isVertColNecessary) {
					var vertColHIndex1I = baseColHIndex1I;
					var vertColHIndex2I = baseColHIndex2I;
					var isGenericEventActivated = false;
					var isUpPlatformEventActivated = false;
					var isLeftPlatformEventActivated = false;
					var isRightPlatformEventActivated = false;
					for (var i = max(0, vertColHIndex1I); i <= min(collisionGrid_width-1, vertColHIndex2I); i++) {
						for (var j = max(0, vertColVIndex1I); j <= min(collisionGrid_height-1, vertColVIndex2I); j++) {
							var curCellColType = getCellCollisionType(i, j);
							if (curCellColType != collisionType_nothing) {
								switch (curCellColType) {
									case (collisionType_normal):
										if (!isGenericEventActivated) {isGenericEventActivated = true; genericEventI.notifyVertCollision();}
										break;
									case (collisionType_onewayUp):
										if (!isUpPlatformEventActivated) {isUpPlatformEventActivated = true; upPlatformEventI.notifyVertCollision();}
										break;
									case (collisionType_onewayLeft):
										if (!isLeftPlatformEventActivated) {isLeftPlatformEventActivated = true; leftPlatformEventI.notifyVertCollision();}
										break;
									case (collisionType_onewayRight):
										if (!isRightPlatformEventActivated) {isRightPlatformEventActivated = true;rightPlatformEventI.notifyVertCollision();}
										break;
								}
							}
						}
					}
				}
				
				if (isDiagColNecessary) {
				
					baseColHIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
					baseColHIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
					baseColVIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
					baseColVIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
					
					if (horiColDirection == 1) {
						var diagColHIndex1I = vertColHIndex2I+1;
						var diagColHIndex2I = horiColHIndex2I;
					}else {
						var diagColHIndex1I = horiColHIndex1I;
						var diagColHIndex2I = vertColHIndex1I-1;
					}
					if (vertColDirection == 1) {
						var diagColVIndex1I = horiColVIndex2I+1;
						var diagColVIndex2I = vertColVIndex2I;
					}else {
						var diagColVIndex1I = vertColVIndex1I;
						var diagColVIndex2I = horiColVIndex1I-1;
					}
					var isGenericEventActivated = false;
					var isUpPlatformEventActivated = false;
					var isLeftPlatformEventActivated = false;
					var isRightPlatformEventActivated = false;
					for (var i = max(0, diagColHIndex1I); i <= min(collisionGrid_width-1, diagColHIndex2I); i++) {
						for (var j = max(0, diagColVIndex1I); j <= min(collisionGrid_height-1, diagColVIndex2I); j++) {
							var curCellColType = getCellCollisionType(i, j);
							if (curCellColType != collisionType_nothing) {
								switch (curCellColType) {
									case (collisionType_normal):
										if (!isGenericEventActivated) {isGenericEventActivated = true; genericEventI.notifyDiagCollision();}
										break;
									case (collisionType_onewayUp):
										if (!isUpPlatformEventActivated) {isUpPlatformEventActivated = true; upPlatformEventI.notifyDiagCollision();}
										break;
									case (collisionType_onewayLeft):
										if (!isLeftPlatformEventActivated) {isLeftPlatformEventActivated = true; leftPlatformEventI.notifyDiagCollision();}
										break;
									case (collisionType_onewayRight):
										if (!isRightPlatformEventActivated) {isRightPlatformEventActivated = true; rightPlatformEventI.notifyDiagCollision();}
										break;
								}
							}
						}
					}
				}
			},
		
			checkCollisionInstance: function(instI, instXAddI, instYAddI, collisionTypeI) {
				var hIndex1I = floor((instI.bbox_left+instXAddI)/collisionGrid_tileSize);
				var hIndex2I = ceil((instI.bbox_right+instXAddI)/collisionGrid_tileSize)-1;
				var vIndex1I = floor((instI.bbox_top+instYAddI)/collisionGrid_tileSize);
				var vIndex2I = ceil((instI.bbox_bottom+instYAddI)/collisionGrid_tileSize)-1;
			
				/*if (collisionTypeI == outOfBounds_collisionType && isPositionOutOfBounds(hIndex1I, vIndex1I, hIndex2I, vIndex2I)) {
					return true;
				}*/
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
							return true;
						}
					}
				}
			
				/*var hIndex1I = floor((instI.bbox_left+instXAddI/2)/collisionGrid_tileSize);
				var hIndex2I = ceil((instI.bbox_right+instXAddI/2)/collisionGrid_tileSize)-1;
				var vIndex1I = floor((instI.bbox_top+instYAddI/2)/collisionGrid_tileSize);
				var vIndex2I = ceil((instI.bbox_bottom+instYAddI/2)/collisionGrid_tileSize)-1;
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
							return true;
						}
					}
				}*/
				return false;
			},
		
			checkPlatformCollisionInstance: function(instI, instXAddI, instYAddI, collisionTypeI, hPlatformDirI, vPlatformDirI) {
				if (vPlatformDirI == 1) {
					var hIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
					var hIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
					var vIndex1I = floor((instI.bbox_bottom)/collisionGrid_tileSize);
					var vIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
					var hNextIndex1I = floor((instI.bbox_left+instXAddI)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_right+instXAddI)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_bottom+instYAddI)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_bottom+instYAddI)/collisionGrid_tileSize)-1;
				
					for (var i = hIndex1I; i <= hIndex2I; i++) {
						for (var j = vIndex1I; j <= vIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return false;
							}
						}
					}
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}
					/*var hNextIndex1I = floor((instI.bbox_left+instXAddI/2)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_right+instXAddI/2)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_bottom+instYAddI/2)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_bottom+instYAddI/2)/collisionGrid_tileSize)-1;
			
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}*/
					return false;
				}
				else if (hPlatformDirI == 1) {
					var hIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
					var hIndex2I = ceil((instI.bbox_left)/collisionGrid_tileSize)-1;
					var vIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
					var vIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
					var hNextIndex1I = floor((instI.bbox_left+instXAddI)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_left+instXAddI)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_top+instYAddI)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_bottom+instYAddI)/collisionGrid_tileSize)-1;
				
					for (var i = hIndex1I; i <= hIndex2I; i++) {
						for (var j = vIndex1I; j <= vIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return false;
							}
						}
					}
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}
					/*var hNextIndex1I = floor((instI.bbox_left+instXAddI/2)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_left+instXAddI/2)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_top+instYAddI/2)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_bottom+instYAddI/2)/collisionGrid_tileSize)-1;
			
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}*/
					return false;
				}
				else if (hPlatformDirI == -1) {
					var hIndex1I = floor((instI.bbox_right)/collisionGrid_tileSize);
					var hIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
					var vIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
					var vIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
					var hNextIndex1I = floor((instI.bbox_right+instXAddI)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_right+instXAddI)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_top+instYAddI)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_bottom+instYAddI)/collisionGrid_tileSize)-1;
				
					for (var i = hIndex1I; i <= hIndex2I; i++) {
						for (var j = vIndex1I; j <= vIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return false;
							}
						}
					}
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}
					/*var hNextIndex1I = floor((instI.bbox_right+instXAddI/2)/collisionGrid_tileSize);
					var hNextIndex2I = ceil((instI.bbox_right+instXAddI/2)/collisionGrid_tileSize)-1;
					var vNextIndex1I = floor((instI.bbox_bottom+instYAddI/2)/collisionGrid_tileSize);
					var vNextIndex2I = ceil((instI.bbox_top+instYAddI/2)/collisionGrid_tileSize)-1;
			
					for (var i = hNextIndex1I; i <= hNextIndex2I; i++) {
						for (var j = vNextIndex1I; j <= vNextIndex2I; j++) {
							if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
								return true;
							}
						}
					}*/
					return false;
				}
			},
	
			checkCollisionRectangle: function(x1I, y1I, x2I, y2I, collisionTypeI) {
				var hIndex1I = floor(x1I/collisionGrid_tileSize);
				var hIndex2I = ceil(x2I/collisionGrid_tileSize)-1;
				var vIndex1I = floor(y1I/collisionGrid_tileSize);
				var vIndex2I = ceil(y2I/collisionGrid_tileSize)-1;
				if (hIndex2I < hIndex1I) {
					var backupIndex = hIndex2I;
					hIndex2I = hIndex1I;
					hIndex1I = backupIndex;
				}
				if (vIndex2I < vIndex1I) {
					var backupIndex = vIndex2I;
					vIndex2I = vIndex1I;
					vIndex1I = backupIndex;
				}
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
							return true;
						}
					}
				}
				return false;
			},
	
			checkNoCollisionRectangle: function(x1I, y1I, x2I, y2I, collisionTypeI) {
				var hIndex1I = floor(x1I/collisionGrid_tileSize);
				var hIndex2I = ceil(x2I/collisionGrid_tileSize)-1;
				var vIndex1I = floor(y1I/collisionGrid_tileSize);
				var vIndex2I = ceil(y2I/collisionGrid_tileSize)-1;
				if (hIndex2I < hIndex1I) {
					var backupIndex = hIndex2I;
					hIndex2I = hIndex1I;
					hIndex1I = backupIndex;
				}
				if (vIndex2I < vIndex1I) {
					var backupIndex = vIndex2I;
					vIndex2I = vIndex1I;
					vIndex1I = backupIndex;
				}
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j) && isCellOfCollisionType(i, j, collisionTypeI)) {
							return false;
						}
					}
				}
				return true;
			},
	
			checkCollisionPoint: function(xI, yI, collisionTypeI) {
				var hIndex1I = ceil(xI/collisionGrid_tileSize)-1;
				var hIndex2I = floor(xI/collisionGrid_tileSize);
				var vIndex1I = ceil(yI/collisionGrid_tileSize)-1;
				var vIndex2I = floor(yI/collisionGrid_tileSize);
			
				if (collisionTypeI == outOfBounds_collisionType && isPositionOutOfBounds(hIndex1I, vIndex1I, hIndex2I, vIndex2I)) {
					return true;
				}
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (isCellOfCollisionType(i, j, collisionTypeI)) {
							return true;
						}
					}
				}
				return false;
			},
	
			checkNoCollisionPoint: function(xI, yI, collisionTypeI) {
				var hIndex1I = ceil(xI/collisionGrid_tileSize)-1;
				var hIndex2I = floor(xI/collisionGrid_tileSize);
				var vIndex1I = ceil(yI/collisionGrid_tileSize)-1;
				var vIndex2I = floor(yI/collisionGrid_tileSize);
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (isCellOfCollisionType(i, j, collisionTypeI)) {
							return false;
						}
					}
				}
				return true;
			},
			
			pointGetFirstCollisionType: function(xI, yI) {
				var hIndex1I = ceil(xI/collisionGrid_tileSize)-1;
				var hIndex2I = floor(xI/collisionGrid_tileSize);
				var vIndex1I = ceil(yI/collisionGrid_tileSize)-1;
				var vIndex2I = floor(yI/collisionGrid_tileSize);
			
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!isCellOfCollisionType(i, j, collisionType_nothing)) {
							return getCellCollisionType(i, j);
						}
					}
				}
				return undefined;
			},
			
			checkOutOfBoundsInstance: function(instI, instXAddI, instYAddI) {
				if (
					instI.bbox_left+instXAddI < 0 || instI.bbox_right+instXAddI > room_width ||
					instI.bbox_top+instYAddI < 0 || instI.bbox_bottom+instYAddI >= room_height
				) {
					return true;
				}
				return false;
			}
		},
		instanceCol: {
			_p: -1,
			bufferStart: 3,
			bufferEnd: 20,
			bufferSize: 17,
			binaryIDArrMap: array_create(0b111111111111),
			existingBinaryIDArr: array_create(0b111111111111),
			nullValue: 0b111111111111,
			curBinaryID: 0,
			instCapacity: 0b111111111111,
			nonNullInstCapacity: 0b111111111111 - 1,
		
			#region Events
		
			roomEndEvent: function() {
				curBinaryID = 0;
			},
		
			#endregion
		
			instanceAssign: function(instI) {
				while (existingBinaryIDArr[curBinaryID] == true) {
					curBinaryID++;
					if (curBinaryID == nonNullInstCapacity)
						curBinaryID = 0;
				}
				existingBinaryIDArr[curBinaryID] = true;
				instI.instanceBufferIndex = -1;
				instI.binaryID = curBinaryID;
				binaryIDArrMap[curBinaryID] = instI.id;
			
				instanceInitializeOccupyingCells(instI);
			},
		
			instanceDeassign: function(instI) {
				binaryIDArrMap[instI.binaryID] = 0;
				existingBinaryIDArr[instI.binaryID] = false;
				setRegionToInstance(instI, false);
			},
		
			clearCell: function(xI, yI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
				buffer_write(curBuffer, buffer_u8, 0b00000000);
				for (var i = bufferStart+1; i < bufferEnd; i++) {
					buffer_write(curBuffer, buffer_u8, 0b11111111);
				}
			},
		
			instanceInitializeOccupyingCells: function(instI) {
				instI.lastOccupyingX1 = floor(instI.bbox_left/collisionGrid_tileSize);
				instI.lastOccupyingX2 = ceil(instI.bbox_right/collisionGrid_tileSize)-1;
				instI.lastOccupyingY1 = floor(instI.bbox_top/collisionGrid_tileSize);
				instI.lastOccupyingY2 = ceil(instI.bbox_bottom/collisionGrid_tileSize)-1;
				setRegionRaw( // OBSERVATION001 - Certificate if this causes tile update leaks.
					instI,
					instI.lastOccupyingX1, instI.lastOccupyingX2,
					instI.lastOccupyingY1, instI.lastOccupyingY2,
					true
				);
			},
		
			instanceUpdateOccupyingCells: function(instI) {
				var newX1 = floor((instI.bbox_left)/collisionGrid_tileSize);
				var newX2 = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
				var newY1 = floor((instI.bbox_top)/collisionGrid_tileSize);
				var newY2 = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
				if (
					instI.lastOccupyingX1 != newX1 ||
					instI.lastOccupyingX2 != newX2 ||
					instI.lastOccupyingY1 != newY1 ||
					instI.lastOccupyingY2 != newY2
				) {
					setRegionRaw(
						instI,
						instI.lastOccupyingX1, instI.lastOccupyingX2,
						instI.lastOccupyingY1, instI.lastOccupyingY2,
						false
					);
					setRegionRaw(
						instI,
						newX1, newX2,
						newY1, newY2,
						true
					);
					instI.lastOccupyingX1 = newX1;
					instI.lastOccupyingX2 = newX2;
					instI.lastOccupyingY1 = newY1;
					instI.lastOccupyingY2 = newY2;
					return true;
				}
				return false;
			},
		
			initialAddInstanceToCell: function(xI, yI, instIDI, instI) { // Does the initial addition of instance to cell, returning where it was added.
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
				var bufferValueIndex = buffer_read(curBuffer, buffer_u8);
				var curIndex = bufferValueIndex;
				buffer_seek(curBuffer, buffer_seek_relative, curIndex<<1);
			
				var instBinaryPart1 = (instIDI & 0b1111111100000000) >> 8;
				var instBinaryPart2 = instIDI & 0b0000000011111111;
				buffer_write(curBuffer, buffer_u8, instBinaryPart1);
				buffer_write(curBuffer, buffer_u8, instBinaryPart2);
				instI.instanceBufferIndex = curIndex;
			
				// Sets new index
				curIndex++;
				buffer_fill(curBuffer, bufferStart, buffer_u8, curIndex, 1);
			},
		
			shortcutAddInstanceToCell: function(xI, yI, instIDI, instI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
			
				var curIndex = instI.instanceBufferIndex;
				var curBufferIndex = buffer_read(curBuffer, buffer_u8);
				buffer_seek(curBuffer, buffer_seek_relative, curIndex<<1);
				var hasWritten = false;
				do {
					var bufferValueInstPart1 = buffer_read(curBuffer, buffer_u8);
					var bufferValueInstPart2 = buffer_read(curBuffer, buffer_u8);
					if (bufferValueInstPart1 == 0b11111111 && bufferValueInstPart2 == 0b11111111) {
						buffer_seek(curBuffer, buffer_seek_relative, -2);
						buffer_write(curBuffer, buffer_u8, (instIDI & 0b1111111100000000) >> 8);
						buffer_write(curBuffer, buffer_u8, instIDI & 0b0000000011111111);
						if (curIndex >= curBufferIndex) {
							var hasFoundNextEmpty = false;
							curIndex++;
							if (curIndex == 8) {
								buffer_fill(curBuffer, bufferStart, buffer_u8, 8, 1);
								return;
							}
						
							do {
								bufferValueInstPart1 = buffer_read(curBuffer, buffer_u8);
								bufferValueInstPart2 = buffer_read(curBuffer, buffer_u8);
								if (bufferValueInstPart1 == 0b11111111 && bufferValueInstPart2 == 0b11111111) {
									buffer_fill(curBuffer, bufferStart, buffer_u8, curIndex, 1);
									hasFoundNextEmpty = true;
								}else {
									curIndex++;
									if (curIndex == 8) {
										buffer_fill(curBuffer, bufferStart, buffer_u8, 8, 1);
										return;
									}
								}
							}until (hasFoundNextEmpty)
						}
						hasWritten = true;
					}else {
						curIndex++;
						if (curIndex == 8) {
							curIndex = 0;
							buffer_seek(curBuffer, buffer_seek_start, bufferStart+1);
						}
					}
				} until (hasWritten);
			},
		
			removeInstanceFromCell: function(xI, yI, instIDI, instI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
			
				var curIndex = instI.instanceBufferIndex;
				var curBufferIndex = buffer_read(curBuffer, buffer_u8);
				buffer_seek(curBuffer, buffer_seek_relative, curIndex<<1);
				var hasRemoved = false;
				var instIDPart1 = (instIDI & 0b1111111100000000) >> 8;
				var instIDPart2 = instIDI & 0b0000000011111111;
				var repeats = 0;
				do {
					if (repeats == 8) { // OBSERVATION001 - Certify this doesn't cause tile memory leaks
						show_debug_message("InstanceCollisionGrid.removeInstanceFromCell() function observation...");
						show_debug_message("Instance binary ID "+string(instIDI)+" was not found in cell "+string(xI)+" "+string(yI));
						return;
					}
					repeats++;
					var bufferValueInstPart1 = buffer_read(curBuffer, buffer_u8);
					var bufferValueInstPart2 = buffer_read(curBuffer, buffer_u8);
					if (bufferValueInstPart1 == instIDPart1 && bufferValueInstPart2 == instIDPart2) {
						buffer_seek(curBuffer, buffer_seek_relative, -2);
						buffer_write(curBuffer, buffer_u8, 0b11111111);
						buffer_write(curBuffer, buffer_u8, 0b11111111);
						hasRemoved = true;
						if (curIndex < curBufferIndex) {
							buffer_fill(curBuffer, bufferStart, buffer_u8, curIndex, 1);
						}
					}else {
						curIndex++;
						if (curIndex == 8) {
							curIndex = 0;
							buffer_seek(curBuffer, buffer_seek_start, bufferStart+1);
						}
					}
				} until (hasRemoved);
			},
		
			setRegionRaw: function(instI, hIndex1I, hIndex2I, vIndex1I, vIndex2I, stateI) {
				var firstSetting = true;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j)) {
							if (stateI == true) {
								if (firstSetting) {
									firstSetting = false;
									initialAddInstanceToCell(i, j, instI.binaryID, instI.id);
								}else {
									shortcutAddInstanceToCell(i, j, instI.binaryID, instI.id);
								}
							}else {
								removeInstanceFromCell(i, j, instI.binaryID, instI.id);
							}
						}
					}
				}
			},
		
			setRegionToInstance: function(instI, stateI) {
				var hIndex1I = floor(instI.bbox_left/collisionGrid_tileSize);
				var hIndex2I = ceil(instI.bbox_right/collisionGrid_tileSize)-1;
				var vIndex1I = floor(instI.bbox_top/collisionGrid_tileSize);
				var vIndex2I = ceil(instI.bbox_bottom/collisionGrid_tileSize)-1;
				var firstSetting = true;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j)) {
							if (stateI == true) {
								if (firstSetting) {
									firstSetting = false;
									initialAddInstanceToCell(i, j, instI.binaryID, instI.id);
								}else {
									shortcutAddInstanceToCell(i, j, instI.binaryID, instI.id);
								}
							}else {
								removeInstanceFromCell(i, j, instI.binaryID, instI.id);
							}
						}
					}
				}
			},
	
			instanceGetCollidedInstances: function(instI, xAddI, yAddI) {
				var hIndex1I = floor((instI.bbox_left+xAddI)/collisionGrid_tileSize);
				var hIndex2I = ceil((instI.bbox_right+xAddI)/collisionGrid_tileSize)-1;
				var vIndex1I = floor((instI.bbox_top+yAddI)/collisionGrid_tileSize);
				var vIndex2I = ceil((instI.bbox_bottom+yAddI)/collisionGrid_tileSize)-1;
				var collidedArr = array_create(48);
			
				var addedInstances = array_create(instCapacity, false);
				var curIndex = 0;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j)) {
							var curBuffer = collisionGrid_matrix[i][j];
							buffer_seek(curBuffer, buffer_seek_start, bufferStart);
							var endingIndex = buffer_read(curBuffer, buffer_u8);
							for (var c = 0; c < 8; c++) {
								var curItemPart1 = buffer_read(curBuffer, buffer_u8);
								var curItemPart2 = buffer_read(curBuffer, buffer_u8);
								if (curItemPart1 != 0b11111111 || curItemPart2 != 0b11111111) {
									var curBinInst = (curItemPart1<<8)|curItemPart2;
									if (!addedInstances[curBinInst]) {
										addedInstances[curBinInst] = true;
										collidedArr[curIndex] = curBinInst;
										curIndex++;
									}
								}
							}
						}
					}
				}
				array_resize(collidedArr, curIndex);
				for (var i = 0; i < curIndex; i++) {
					collidedArr[i] = binaryIDArrMap[collidedArr[i]];
				}
				return collidedArr;
			},
			
			rectangleGetCollidedInstances: function(x1I, y1I, x2I, y2I) {
				var hIndex1I = floor(x1I/collisionGrid_tileSize);
				var hIndex2I = ceil(x2I/collisionGrid_tileSize)-1;
				var vIndex1I = floor(y1I/collisionGrid_tileSize);
				var vIndex2I = ceil(y2I/collisionGrid_tileSize)-1;
				var collidedArr = array_create(48);
			
				var addedInstances = array_create(instCapacity, false);
				var curIndex = 0;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j)) {
							var curBuffer = collisionGrid_matrix[i][j];
							buffer_seek(curBuffer, buffer_seek_start, bufferStart);
							var endingIndex = buffer_read(curBuffer, buffer_u8);
							for (var c = 0; c < 8; c++) {
								var curItemPart1 = buffer_read(curBuffer, buffer_u8);
								var curItemPart2 = buffer_read(curBuffer, buffer_u8);
								if (curItemPart1 != 0b11111111 || curItemPart2 != 0b11111111) {
									var curBinInst = (curItemPart1<<8)|curItemPart2;
									if (!addedInstances[curBinInst]) {
										addedInstances[curBinInst] = true;
										collidedArr[curIndex] = curBinInst;
										curIndex++;
									}
								}
							}
						}
					}
				}
				array_resize(collidedArr, curIndex);
				for (var i = 0; i < curIndex; i++) {
					collidedArr[i] = binaryIDArrMap[collidedArr[i]];
				}
				return collidedArr;
			},
			
			pointGetCollidedInstances: function(xI, yI) {
				var hIndex1I = max(0, ceil(xI/collisionGrid_tileSize)-1);
				if (hIndex1I >= collisionGrid_width) return [];
		
				var hIndex2I = min(collisionGrid_width-1, floor(xI/collisionGrid_tileSize));
				if (hIndex1I < 0) return [];
		
				var vIndex1I = max(0, ceil(yI/collisionGrid_tileSize)-1);
				if (vIndex1I >= collisionGrid_height) return [];
		
				var vIndex2I = min(collisionGrid_height-1, floor(yI/collisionGrid_tileSize));
				if (vIndex1I < 0) return [];
		
				var collidedArr = array_create(8*4);
				
				//show_debug_message("Getting point collision");
				var addedInstances = array_create(instCapacity, false);
				var curIndex = 0;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					var curRow = collisionGrid_matrix[i];
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						if (!_p.isPositionOutOfBounds(i, j)) {
							var curBuffer = curRow[j];
							buffer_seek(curBuffer, buffer_seek_start, bufferStart);
							var endingIndex = buffer_read(curBuffer, buffer_u8);
							for (var c = 0; c < 8; c++) {
								//if (!cock) show_debug_message(buffer_tell(curBuffer));
								var curItemPart1 = buffer_read(curBuffer, buffer_u8);
								var curItemPart2 = buffer_read(curBuffer, buffer_u8);
								if (curItemPart1 != 0b11111111 || curItemPart2 != 0b11111111) {
									var curBinInst = (curItemPart1<<8)|curItemPart2;
									if (!addedInstances[curBinInst]) {
										addedInstances[curBinInst] = true;
										collidedArr[curIndex] = curBinInst;
										curIndex++;
									}
								}
							}
						}
					}
				}
				array_resize(collidedArr, curIndex);
				for (var i = 0; i < curIndex; i++) {
					collidedArr[i] = binaryIDArrMap[collidedArr[i]];
				}
				//show_debug_message("");
				return collidedArr;
			}
		},
		camouflageCol: {
			_p: -1,
			bufferSize: 2,
			bufferStart: 1,
			clusterCapacity: 15,
			visibleClusters: [],
			nullCluster: 0b1111,
		
			clearCell: function(xI, yI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
			
				var bufferFillValue = 0b11111111;
				buffer_write(curBuffer, buffer_u8, bufferFillValue);
				buffer_write(curBuffer, buffer_u8, bufferFillValue);
			},
		
			addClusterToCell: function(xI, yI, clusterIDI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				var bufferClusterCapacity = 4;
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
				var curValue1 = buffer_read(curBuffer, buffer_u8);
				var curValue2 = buffer_read(curBuffer, buffer_u8);
				if ((curValue1 & 0b11110000) >> 4 == nullCluster) {
					var binaryClusterID = clusterIDI << 4;
					buffer_seek(curBuffer, buffer_seek_relative, -2);
					buffer_write(curBuffer, buffer_u8, 0b00001111 & curValue1 | binaryClusterID);
				}else if (curValue1 & 0b00001111 == nullCluster) {
					var binaryClusterID = clusterIDI;
					buffer_seek(curBuffer, buffer_seek_relative, -2);
					buffer_write(curBuffer, buffer_u8, 0b11110000 & curValue1 | binaryClusterID);
				}else if ((curValue2 & 0b11110000) >> 4 == nullCluster) {
					var binaryClusterID = clusterIDI << 4;
					buffer_seek(curBuffer, buffer_seek_relative, -1);
					buffer_write(curBuffer, buffer_u8, 0b00001111 & curValue2 | binaryClusterID);
				}else if (curValue2 & 0b00001111 == nullCluster) {
					var binaryClusterID = clusterIDI;
					buffer_seek(curBuffer, buffer_seek_relative, -1);
					buffer_write(curBuffer, buffer_u8, 0b11110000 & curValue2 | binaryClusterID);
				}
			},
		
			cellHasCluster: function(xI, yI, clusterIDI) {
				var curBuffer = collisionGrid_matrix[xI][yI];
				var bufferClusterCapacity = 4;
				buffer_seek(curBuffer, buffer_seek_start, bufferStart);
				var curValue1 = buffer_read(curBuffer, buffer_u8);
				var curValue2 = buffer_read(curBuffer, buffer_u8);
				if ((curValue1 & 0b11110000) >> 4 == clusterIDI) {
					return true;
				}else if (curValue1 & 0b00001111 == clusterIDI) {
					return true;
				}else if ((curValue2 & 0b11110000) >> 4 == clusterIDI) {
					return true;
				}else if (curValue2 & 0b00001111 == clusterIDI) {
					return true;
				}
				return false;
			},
		
			instanceGetOccupyingClusters: function(instI) {
				var hIndex1I = floor((instI.bbox_left)/collisionGrid_tileSize);
				var hIndex2I = ceil((instI.bbox_right)/collisionGrid_tileSize)-1;
				var vIndex1I = floor((instI.bbox_top)/collisionGrid_tileSize);
				var vIndex2I = ceil((instI.bbox_bottom)/collisionGrid_tileSize)-1;
			
				var outputArr = array_create(8);
				var curIndex = 0;
				for (var i = hIndex1I; i <= hIndex2I; i++) {
					for (var j = vIndex1I; j <= vIndex2I; j++) {
						var curBuffer = collisionGrid_matrix[i][j];
						buffer_seek(curBuffer, buffer_seek_start, bufferStart);
						var bufferValue1 = buffer_read(curBuffer, buffer_u8);
						var bufferValue2 = buffer_read(curBuffer, buffer_u8);
						var cluster1 = (bufferValue1 & 0b11110000) >> 4;
						var cluster2 = bufferValue1 & 0b00001111;
						var cluster3 = (bufferValue2 & 0b11110000) >> 4;
						var cluster4 = bufferValue2 & 0b00001111;
						if (cluster1 != nullCluster) {
							outputArr[curIndex] = cluster1;
							curIndex++;
						}
						if (cluster2 != nullCluster) {
							outputArr[curIndex] = cluster2;
							curIndex++;
						}
						if (cluster3 != nullCluster) {
							outputArr[curIndex] = cluster3;
							curIndex++;
						}
						if (cluster4 != nullCluster) {
							outputArr[curIndex] = cluster4;
							curIndex++;
						}
					}
				}
				array_resize(outputArr, curIndex);
				return outputArr;
			},
		
			setRegion: function(xIndexI, yIndexI, widthI, heightI, clusterIDI) {
				for (var i = 0; i < widthI; i++) {
					for (var j = 0; j < heightI; j++) {
						addClusterToCell(xIndexI+i, yIndexI+j, clusterIDI);
					}
				}
			},
	
			setRegion2: function(x1IndexI, y1IndexI, x2IndexI, y2IndexI, clusterIDI) {
				for (var i = x1IndexI; i <= x2IndexI; i++) {
					for (var j = y1IndexI; j <= y2IndexI; j++) {
						addClusterToCell(i, j, clusterIDI);
					}
				}
			},
	
			setRegionByInstance: function(instI, clusterIDI) {
				setRegion2(
					floor(instI.bbox_left/collisionGrid_tileSize), floor(instI.bbox_top/collisionGrid_tileSize),
					ceil(instI.bbox_right/collisionGrid_tileSize)-1, ceil(instI.bbox_bottom/collisionGrid_tileSize)-1,
					clusterIDI
				);
			}
		}
	},
	
	stageObjectManager: {
		map: ds_map_create(),
		capacity: 65536,
		nextID: 0,
		
		nextTypeID: 0,
		typeArr: [],
		
		initialize: function() {
			var constructStageObjType = function(objectIndexI, layerI, hasInstanceColSupportI = false, hasPositionI = false, hasScalingI = false, hasAngleI = false, hasHlthInterfaceI = false, hasEnergyInterfaceI = false, hasTargettingInterfaceI = false, hasStatHUDInterfaceI = false, hasPhysicsInterfaceI = false) {
				var newStageObjType = {
					id: StageObjectManager.nextTypeID,
					objectIndex: objectIndexI,
					layer: layerI,
					hasInstanceColSupport: hasInstanceColSupportI,
					hasPosition: hasPositionI,
					hasScaling: hasScalingI,
					hasAngle: hasAngleI,
					hasHlthInterface: hasHlthInterfaceI,
					hasEnergyInterface: hasEnergyInterfaceI,
					hasTargettingInterface: hasTargettingInterfaceI,
					hasStatHUDInterface: hasStatHUDInterfaceI,
					hasPhysicsInterface: hasPhysicsInterfaceI,
					hasDecorationInterface: false,
					add: function(/*[Input arguments]*/) {
						/*with (StageObjectManager) {
							var newStageObj = constructBase([this type]);
							AddStuff1(newStageObj, [Respective arguments from the inut]);
							AddStuff2(newStageObj, [Respective arguments from the inut]);
							AddStuff3(newStageObj, [Respective arguments from the inut]);
							...
							AddStuffN(newStageObj, [Respective arguments from the inut]);
							addStructToMap(newStageObj);
						}*/
					},
					constructLoadingExtra: function(stageObjI, loadingStructI) {
						
					},
					saveObjectExtra: function(stageObjI) {
			
					},
					destroyObjectExtra: function(stageObjI) {
			
					},
					gameplayConvertExtra: function(stageObjI) {
						
					},
					savingConvertExtra: function(stageObjI) {
						
					},
					copyExtra: function(stageObjI, copiedObjI) {
						
					}
				}
				array_push(StageBuilderFromRoom.adderObjects, objectIndexI);
				array_push(typeArr, newStageObjType);
				nextTypeID++;
				return newStageObjType;
			}
			
			#region obj_player
			type_player = constructStageObjType(
				obj_player, layers.entities,
				true, // Instance collision support
				true, // Position
				false, // Scaling
				false, // Angle
				false, // Health interface
				false, // Energy interface
				false, // Targetting interface
				false, // Stat HUD interface
				true // Physics interface
			);
			type_player.add = function(xI, yI) {
				with (StageObjectManager) {
					var newStageObj = constructBase(type_player);
					addPosition(newStageObj, xI, yI);
					addPhysicsInterface(newStageObj, 1.0, physicsDefaultGrv, physicsDefaultFriction);
					addStructToMap(newStageObj);
				}
				return newStageObj.id;
			}
			#endregion
			
			#region obj_healthItem
			type_healthItem = constructStageObjType(
				obj_healthItem, layers.entities,
				true, // Instance collision support
				true, // Position
				false, // Scaling
				false, // Angle
				false, // Health interface
				false, // Energy interface
				false // Targetting interface
			);
			type_healthItem.add = function(xI, yI) {
				with (StageObjectManager) {
					var newStageObj = constructBase(type_healthItem);
					addPosition(newStageObj, xI, yI);
					addStructToMap(newStageObj);
				}
				return newStageObj.id;
			}
			#endregion
			
			#region DECORATION
			
				#region obj_chainLamp
				
				type_chainLamp = constructStageObjType(
					obj_chainLamp, layers.entities,
					true, // Instance collision support
					true, // Position
					false, // Scaling
					false, // Angle
					false, // Health interface
					false, // Energy interface
					false // Targetting interface
				);
				type_chainLamp.hasDecorationInterface = true;
				type_chainLamp.add = function(xI, yI, segmentArrI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_chainLamp);
						addPosition(newStageObj, xI, yI);
						addStructToMap(newStageObj);
						addDecorationInterface(newStageObj, true, true);
						newStageObj.segmentArr = segmentArrI;
					}
					return newStageObj.id;
				}
				type_chainLamp.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.segmentArr = [];
					array_copy(loadingStructI.segmentArr, 0, stageObjI.segmentArr, 0, array_length(stageObjI.segmentArr));
				}
				
				#endregion
			
				#region obj_simpleDecoration
				
				type_simpleDecoration = constructStageObjType(
					obj_simpleDecoration, layers.entities,
					true, // Instance collision support
					true, // Position
					false, // Scaling
					false, // Angle
					false, // Health interface
					false, // Energy interface
					false // Targetting interface
				);
				type_simpleDecoration.hasDecorationInterface = true;
				type_simpleDecoration.add = function(xI, yI, spriteI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_simpleDecoration);
						addPosition(newStageObj, xI, yI);
						addStructToMap(newStageObj);
						addDecorationInterface(newStageObj, true, true);
						newStageObj.sprite = spriteI;
					}
					return newStageObj.id;
				}
				type_simpleDecoration.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.sprite = stageObjI.sprite;
				}
				
				#endregion
			
			#endregion
			
			#region COLLISIONS
			
				#region obj_collision
				type_collision = constructStageObjType(
					obj_collision, layers.collision,
					false,
					true,
					true,
					false,
					false,
					false,
					false
				);
				type_collision.add = function(xI, yI, xScaleI, yScaleI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_collision);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				#endregion
				
				#region obj_collisionPlatform
				type_collisionPlatform = constructStageObjType(
					obj_collisionPlatform, layers.collision,
					false,
					true,
					true,
					false,
					false,
					false,
					false
				);
				type_collisionPlatform.add = function(xI, yI, xScaleI, yScaleI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_collisionPlatform);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				#endregion
				
				#region obj_collisionPlatformLeft
				type_collisionPlatformLeft = constructStageObjType(
					obj_collisionPlatformLeft, layers.collision,
					false,
					true,
					true,
					false,
					false,
					false,
					false
				);
				type_collisionPlatformLeft.add = function(xI, yI, xScaleI, yScaleI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_collisionPlatformLeft);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				#endregion
				
				#region obj_collisionPlatformRight
				type_collisionPlatformRight = constructStageObjType(
					obj_collisionPlatformRight, layers.collision,
					false,
					true,
					true,
					false,
					false,
					false,
					false
				);
				type_collisionPlatformRight.add = function(xI, yI, xScaleI, yScaleI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_collisionPlatformRight);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				#endregion
			
			#endregion
			
			#region ENEMIES
				
				#region obj_slicerDrone
				
				type_slicerDrone = constructStageObjType(
					obj_slicerDrone, layers.entities,
					true,
					true,
					false,
					false,
					true,
					true,
					true,
					true,
					true
				);
				type_slicerDrone.add = function(xI, yI, targetsI, targetTypesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_slicerDrone);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, 6, 6);
						addHlthInterface(newStageObj, 5, 5);
						addTargettingInterface(newStageObj, targetsI, targetTypesI);
						addPhysicsInterface(newStageObj, 1.0, physicsDefaultGrv, physicsDefaultFriction);
						var newBarArr = [
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_health.id,
								4,
								statHUDDefaultPipSize,
								1,
								5
							),
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_energy.id,
								4,
								statHUDDefaultPipSize,
								1,
								6
							)
						];
						var sprSize = 32;
						addStatHUDInterface(newStageObj, newBarArr, 0, -sprSize/2-defaultStatHUDYoffsetAdd);
						
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				
				#endregion
				
				#region obj_shooterDrone
				
				type_shooterDrone = constructStageObjType(
					obj_shooterDrone, layers.entities,
					true,
					true,
					false,
					false,
					true,
					true,
					true,
					true,
					true
				);
				type_shooterDrone.add = function(xI, yI, targetsI, targetTypesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_shooterDrone);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, 7, 7);
						addHlthInterface(newStageObj, 3, 3);
						addTargettingInterface(newStageObj, targetsI, targetTypesI);
						addPhysicsInterface(newStageObj, 1.0, physicsDefaultGrv, physicsDefaultFriction);
						var newBarArr = [
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_health.id,
								4,
								statHUDDefaultPipSize,
								1,
								3
							),
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_energy.id,
								4,
								statHUDDefaultPipSize,
								1,
								7
							)
						];
						var sprSize = 32;
						addStatHUDInterface(newStageObj, newBarArr, 0, -sprSize/2-defaultStatHUDYoffsetAdd);
						newStageObj.shootingCooldownFramesInit = 0;
						
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_shooterDrone.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.shootingCooldownFramesInit = stageObjI.shootingCooldownFramesInit;
				}
				type_shooterDrone.saveObjectExtra = function(stageObjI) {
					stageObjI.shootingCooldownFramesInit = stageObjI.instanceID.shooting.cooldownFramesCur;
				}
				
				#endregion
				
					#region obj_shooterDroneProjectile
				
				type_shooterDroneProjectile = constructStageObjType(
					obj_shooterDroneProjectile, layers.entities,
					true,
					true,
					false,
					false,
					false,
					true,
					false,
					false,
					true
				);
				type_shooterDroneProjectile.add = function(xI, yI, directionI, spdI, energyI, shootingDmgI, shooterInstI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_shooterDroneProjectile);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, energyI, -1);
						addPhysicsInterface(newStageObj, 1.0, 0, 0);
						newStageObj.initialHSpd = dcos(directionI)*spdI;
						newStageObj.initialVSpd = -dsin(directionI)*spdI;
						newStageObj.playerDmg = shootingDmgI;
						newStageObj.shooterInst = shooterInstI;
						
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_shooterDroneProjectile.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.initialHSpd = stageObjI.initialHSpd;
					loadingStructI.initialVSpd = stageObjI.initialVSpd;
					loadingStructI.playerDmg = stageObjI.playerDmg;
					loadingStructI.shooterInst = stageObjI.shooterInst;
				}
				type_shooterDroneProjectile.gameplayConvertExtra = function(stageObjI) {
					stageObjI.instanceID.shooterInst = tryGameplayConversion(stageObjI.shooterInst);
				}
				
				#endregion
				
				#region Bosses
				
					#region obj_swordsmaster
					
					type_swordsmaster_boss = constructStageObjType(
						obj_swordsmaster, layers.entities,
						true,
						true,
						false,
						false,
						true,
						true,
						true,
						true,
						true
					);
					type_swordsmaster_boss.add = function(xI, yI, targetsI, targetTypesI) {
						with (StageObjectManager) {
							var newStageObj = constructBase(type_swordsmaster_boss);
							addPosition(newStageObj, xI, yI);
							addEnergyInterface(newStageObj, 2, 46);
							addHlthInterface(newStageObj, 26, 26);
							addTargettingInterface(newStageObj, targetsI, targetTypesI);
							addPhysicsInterface(newStageObj, 2.0, physicsDefaultGrv, physicsDefaultFriction);
							var newBarArr = [
								StatHUDInterface.constructBar(
									StatHUDInterface.barType_health.id,
									6,
									8,
									1,
									26
								),
								StatHUDInterface.constructBar(
									StatHUDInterface.barType_energy.id,
									6,
									8,
									2,
									46
								)
							];
							var sprSize = 64;
							addStatHUDInterface(newStageObj, newBarArr, 0, -sprSize/2-defaultStatHUDYoffsetAdd);
						
							addStructToMap(newStageObj);
						}
						return newStageObj.id;
					}
					
					#endregion
				
				#endregion
				
			#endregion
			
			#region PROPS
			
				#region obj_jumpPad
				type_jumpPad = constructStageObjType(
					obj_jumpPad, layers.entities,
					true,
					true,
					false,
					false,
					false,
					false,
					false
				);
				type_jumpPad.add = function(xI, yI, vForceI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_jumpPad);
						addPosition(newStageObj, xI, yI);
						newStageObj.vForce = vForceI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_jumpPad.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.vForce = stageObjI.vForce;
				}
				#endregion
			
				#region obj_energyCollision
				type_energyCollision = constructStageObjType(
					obj_energyCollision, layers.entities,
					true,
					true,
					true,
					false,
					false,
					true,
					false
				);
				type_energyCollision.add = function(xI, yI, xScaleI, yScaleI, energyUseFrameI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_energyCollision);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						addEnergyInterface(newStageObj, energyUseFrameI, energyUseFrameI);
						newStageObj.energyUseFrame = energyUseFrameI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_energyCollision.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.energyUseFrame = stageObjI.energyUseFrame;
				}
				#endregion
			
				#region obj_battery
				type_battery = constructStageObjType(
					obj_battery, layers.entities,
					true,
					true,
					false,
					false,
					false,
					true,
					false
				);
				type_battery.add = function(xI, yI, destinationsI, energyMaxI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_battery);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, energyMaxI, energyMaxI);
						newStageObj.destinations = destinationsI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_battery.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.destinations = [];
					array_copy(loadingStructI.destinations, 0, stageObjI.destinations, 0, array_length(stageObjI.destinations));
				}
				type_battery.gameplayConvertExtra = function(stageObjI) {
					var curDestinations = stageObjI.instanceID.destinations;
					for (var i = 0; i < array_length(curDestinations); i++) {
						curDestinations[i] = tryGameplayConversion(curDestinations[i]);
					}
				}
			
				#endregion
			
				#region obj_nodeProp
				type_nodeProp = constructStageObjType(
					obj_nodeProp, layers.entities,
					true,
					true,
					false,
					false,
					true,
					true,
					false,
					true
				);
				type_nodeProp.add = function(xI, yI, destinationsI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_nodeProp);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, 0, -1);
						addHlthInterface(newStageObj, 2, 2);
						var newBarArr = [
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_health.id,
								statHUDDefaultPipSize,
								statHUDDefaultPipSize,
								1,
								2
							)
						];
						var sprSize = 32;
						addStatHUDInterface(newStageObj, newBarArr, 0, -sprSize/2-defaultStatHUDYoffsetAdd);
						newStageObj.destinations = destinationsI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_nodeProp.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.destinations = [];
					array_copy(loadingStructI.destinations, 0, stageObjI.destinations, 0, array_length(stageObjI.destinations));
				}
				type_nodeProp.gameplayConvertExtra = function(stageObjI) {
					var curDestinations = stageObjI.instanceID.destinations;
					for (var i = 0; i < array_length(curDestinations); i++) {
						curDestinations[i] = tryGameplayConversion(curDestinations[i]);
					}
				}
				#endregion
			
				#region obj_nodePropGenerator
				type_nodePropGenerator = constructStageObjType(
					obj_nodePropGenerator, layers.entities,
					true,
					true,
					false,
					false,
					true,
					true,
					false,
					true
				);
				type_nodePropGenerator.add = function(xI, yI, destinationsI, energyCooldownI, energyCooldownCurI, energyGenerationI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_nodePropGenerator);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, 0, -1);
						addHlthInterface(newStageObj, 2, 2);
						var newBarArr = [
							StatHUDInterface.constructBar(
								StatHUDInterface.barType_health.id,
								statHUDDefaultPipSize,
								statHUDDefaultPipSize,
								1,
								2
							)
						];
						var sprSize = 32;
						addStatHUDInterface(newStageObj, newBarArr, 0, -sprSize/2-defaultStatHUDYoffsetAdd);
					
						newStageObj.destinations = destinationsI;
						newStageObj.energyCooldown = energyCooldownI;
						newStageObj.energyCooldownCur = energyCooldownCurI;
						newStageObj.energyGeneration = energyGenerationI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_nodePropGenerator.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.destinations = [];
					array_copy(loadingStructI.destinations, 0, stageObjI.destinations, 0, array_length(stageObjI.destinations));
					loadingStructI.energyCooldown = stageObjI.energyCooldown;
					loadingStructI.energyCooldownCur = stageObjI.energyCooldownCur;
					loadingStructI.energyGeneration = stageObjI.energyGeneration;
				}
				type_nodePropGenerator.saveObjectExtra = function(stageObjI) {
					stageObjI.energyCooldownCur = stageObjI.instanceID.energyCooldownCur;
				}
				type_nodePropGenerator.gameplayConvertExtra = function(stageObjI) {
					var curDestinations = stageObjI.instanceID.destinations;
					for (var i = 0; i < array_length(curDestinations); i++) {
						curDestinations[i] = tryGameplayConversion(curDestinations[i]);
					}
				}
				#endregion
			
				#region obj_laserProp
				type_laserProp = constructStageObjType(
					obj_laserProp, layers.entities,
					true,
					true,
					false,
					true,
					false,
					true,
					false
				);
				type_laserProp.add = function(xI, yI, angleI, shootDelayFramesI, shortcuttedShotsIsItI, shortcuttedShotsInstancesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_laserProp);
						addPosition(newStageObj, xI, yI);
						addAngle(newStageObj, angleI);
						addEnergyInterface(newStageObj, 0, -1);
						newStageObj.shootDelayFrames = shootDelayFramesI;
						newStageObj.shootDelayFramesCur = 0;
						newStageObj.isShooting = false;
						newStageObj.shortcuttedShotsIsIt = shortcuttedShotsIsItI;
						newStageObj.shortcuttedShotsInstances = shortcuttedShotsInstancesI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_laserProp.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.shootDelayFrames = stageObjI.shootDelayFrames;
					loadingStructI.shootDelayFramesCur = stageObjI.shootDelayFramesCur;
					loadingStructI.isShooting = stageObjI.isShooting;
					loadingStructI.shortcuttedShotsIsIt = [];
					loadingStructI.shortcuttedShotsInstances = [];
					array_copy(loadingStructI.shortcuttedShotsIsIt, 0, stageObjI.shortcuttedShotsIsIt, 0, array_length(stageObjI.shortcuttedShotsIsIt));
					array_copy(loadingStructI.shortcuttedShotsInstances, 0, stageObjI.shortcuttedShotsInstances, 0, array_length(stageObjI.shortcuttedShotsInstances));
				}
				type_laserProp.saveObjectExtra = function(stageObjI) {
					stageObjI.shootDelayFramesCur = stageObjI.instanceID.shootDelayFramesCur;
					stageObjI.isShooting = stageObjI.instanceID.isShooting;
				}
				type_laserProp.gameplayConvertExtra = function(stageObjI) {
					var curTargetInstances = stageObjI.instanceID.shortcuttedShotsInstances;
					var curShortcutTruths = stageObjI.instanceID.shortcuttedShotsIsIt;
					for (var i = 0; i < array_length(curTargetInstances); i++) {
						if (curShortcutTruths[i]) curTargetInstances[i] = tryGameplayConversion(curTargetInstances[i]);
					}
				}
				type_laserProp.gameplayConvertExtra = function(stageObjI) {
					var curTargetInstances = stageObjI.instanceID.shortcuttedShotsInstances;
					var curShortcutTruths = stageObjI.instanceID.shortcuttedShotsIsIt;
					for (var i = 0; i < array_length(curTargetInstances); i++) {
						if (curShortcutTruths[i]) curTargetInstances[i] = tryGameplayConversion(curTargetInstances[i]);
					}
				}
				#endregion
			
				#region obj_laserPropDouble
				type_laserPropDouble = constructStageObjType(
					obj_laserPropDouble, layers.entities,
					true,
					true,
					false,
					true,
					false,
					true,
					false
				);
				type_laserPropDouble.add = function(xI, yI, angleI, shootDelayFramesI, shortcuttedShotsIsItI, shortcuttedShotsInstancesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_laserPropDouble);
						addPosition(newStageObj, xI, yI);
						addAngle(newStageObj, angleI);
						addEnergyInterface(newStageObj, 0, -1);
						newStageObj.shootDelayFrames = shootDelayFramesI;
						newStageObj.shootDelayFramesCur = 0;
						newStageObj.isShooting = false;
						newStageObj.shortcuttedShotsIsIt = shortcuttedShotsIsItI;
						newStageObj.shortcuttedShotsInstances = shortcuttedShotsInstancesI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_laserPropDouble.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.shootDelayFrames = stageObjI.shootDelayFrames;
					loadingStructI.shootDelayFramesCur = stageObjI.shootDelayFramesCur;
					loadingStructI.isShooting = stageObjI.isShooting;
					loadingStructI.shortcuttedShotsIsIt = [];
					loadingStructI.shortcuttedShotsInstances = [];
					array_copy(loadingStructI.shortcuttedShotsIsIt, 0, stageObjI.shortcuttedShotsIsIt, 0, array_length(stageObjI.shortcuttedShotsIsIt));
					array_copy(loadingStructI.shortcuttedShotsInstances, 0, stageObjI.shortcuttedShotsInstances, 0, array_length(stageObjI.shortcuttedShotsInstances));
				}
				type_laserPropDouble.saveObjectExtra = function(stageObjI) {
					stageObjI.shootDelayFramesCur = stageObjI.instanceID.shootDelayFramesCur;
					stageObjI.isShooting = stageObjI.instanceID.isShooting;
				}
				type_laserPropDouble.gameplayConvertExtra = function(stageObjI) {
					var curTargetInstances = stageObjI.instanceID.shortcuttedShotsInstances;
					var curShortcutTruths = stageObjI.instanceID.shortcuttedShotsIsIt;
					for (var i = 0; i < array_length(curTargetInstances); i++) {
						if (curShortcutTruths[i]) curTargetInstances[i] = tryGameplayConversion(curTargetInstances[i]);
					}
				}
				#endregion
			
				#region obj_laserPropGenerator
				type_laserPropGenerator = constructStageObjType(
					obj_laserPropGenerator, layers.entities,
					true,
					true,
					false,
					true,
					false,
					true,
					false
				);
				type_laserPropGenerator.add = function(xI, yI, angleI, energyCooldownI, energyCooldownCurI, shortcuttedShotsIsItI, shortcuttedShotsInstancesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_laserPropGenerator);
						addPosition(newStageObj, xI, yI);
						addAngle(newStageObj, angleI);
						addEnergyInterface(newStageObj, 0, -1);
						newStageObj.energyCooldown = energyCooldownI;
						newStageObj.energyCooldownCur = energyCooldownCurI;
						newStageObj.isShooting = false;
						newStageObj.shortcuttedShotsIsIt = shortcuttedShotsIsItI;
						newStageObj.shortcuttedShotsInstances = shortcuttedShotsInstancesI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_laserPropGenerator.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.energyCooldown = stageObjI.energyCooldown;
					loadingStructI.energyCooldownCur = stageObjI.energyCooldownCur;
					loadingStructI.isShooting = stageObjI.isShooting;
					loadingStructI.shortcuttedShotsIsIt = [];
					loadingStructI.shortcuttedShotsInstances = [];
					array_copy(loadingStructI.shortcuttedShotsIsIt, 0, stageObjI.shortcuttedShotsIsIt, 0, array_length(stageObjI.shortcuttedShotsIsIt));
					array_copy(loadingStructI.shortcuttedShotsInstances, 0, stageObjI.shortcuttedShotsInstances, 0, array_length(stageObjI.shortcuttedShotsInstances));
				}
				type_laserPropGenerator.saveObjectExtra = function(stageObjI) {
					stageObjI.energyCooldownCur = stageObjI.instanceID.energyCooldownCur;
					stageObjI.isShooting = stageObjI.instanceID.isShooting;
				}
				type_laserPropGenerator.gameplayConvertExtra = function(stageObjI) {
					var curTargetInstances = stageObjI.instanceID.shortcuttedShotsInstances;
					var curShortcutTruths = stageObjI.instanceID.shortcuttedShotsIsIt;
					for (var i = 0; i < array_length(curTargetInstances); i++) {
						if (curShortcutTruths[i]) curTargetInstances[i] = tryGameplayConversion(curTargetInstances[i]);
					}
				}
				#endregion
				
				#region obj_mobilePulser
				type_mobilePulser = constructStageObjType(
					obj_mobilePulser, layers.entities,
					true,
					true,
					false,
					false,
					false,
					true,
					false,
					false,
					true
				);
				type_mobilePulser.add = function(xI, yI, pulseDelayFramesI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_mobilePulser);
						addPosition(newStageObj, xI, yI);
						addEnergyInterface(newStageObj, 0, -1);
						addPhysicsInterface(newStageObj, 1.0, physicsDefaultGrv, physicsDefaultFriction);
						// TODO - pulse delay fraems
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_mobilePulser.constructLoadingExtra = function(stageObjI, loadingStructI) {
						// TODO - pulse delay fraems
				}
				type_mobilePulser.saveObjectExtra = function(stageObjI) {
						// TODO - pulse delay fraems
				}
				#endregion
				
			#endregion
			
			#region MISCELLANEOUS
			
				#region obj_camouflage
				type_camouflage = constructStageObjType(
					obj_camouflage, layers.entities,
					false,
					true,
					true,
					false,
					false,
					false,
					false
				);
				type_camouflage.add = function(xI, yI, xScaleI, yScaleI, clusterIDI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_camouflage);
						addPosition(newStageObj, xI, yI);
						addScaling(newStageObj, xScaleI, yScaleI);
						newStageObj.clusterID = clusterIDI;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_camouflage.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.clusterID = stageObjI.clusterID;
				}
				#endregion
			
				#region obj_checkpoint
				type_checkpoint = constructStageObjType(
					obj_checkpoint, layers.entities,
					false,
					true,
					false,
					false,
					false,
					false,
					false
				);
				type_checkpoint.add = function(xI, yI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_checkpoint);
						addPosition(newStageObj, xI, yI);
						newStageObj.isUsed = false;
					
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_checkpoint.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.isUsed = stageObjI.isUsed;
				}
				type_checkpoint.saveObjectExtra = function(stageObjI) {
					stageObjI.isUsed = stageObjI.instanceID.isUsed;
				}
				#endregion
			
				#region obj_finish
				type_finish = constructStageObjType(
					obj_finish, layers.entities,
					true, // Instance collision support
					true, // Position
					false, // Scaling
					false, // Angle
					false, // Health interface
					false, // Energy interface
					false // Targetting interface
				);
				type_finish.add = function(xI, yI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_finish);
						addPosition(newStageObj, xI, yI);
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				#endregion
				
				#region obj_sign
				type_sign = constructStageObjType(
					obj_sign, layers.entities,
					false, // Instance collision support
					true, // Position
					false, // Scaling
					false, // Angle
					false, // Health interface
					false, // Energy interface
					false // Targetting interface
				);
				type_sign.add = function(xI, yI, textI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_sign);
						addPosition(newStageObj, xI, yI);
						newStageObj.text = textI;
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_sign.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.text = stageObjI.text;
				}
				#endregion
				
				#region obj_toolItem
				type_toolItem = constructStageObjType(
					obj_toolItem, layers.entities,
					false, // Instance collision support
					true, // Position
					false, // Scaling
					false, // Angle
					false, // Health interface
					false, // Energy interface
					false // Targetting interface
				);
				type_toolItem.add = function(xI, yI, toolIndexI) {
					with (StageObjectManager) {
						var newStageObj = constructBase(type_toolItem);
						addPosition(newStageObj, xI, yI);
						newStageObj.toolIndex = toolIndexI;
						addStructToMap(newStageObj);
					}
					return newStageObj.id;
				}
				type_toolItem.constructLoadingExtra = function(stageObjI, loadingStructI) {
					loadingStructI.toolIndex = stageObjI.toolIndex;
				}
				#endregion
				
			#endregion
			
		},
		
		setMap: function(mapI) {
			map = mapI;
		},
		getMap: function() {
			return map;
		},
		
		stageStartEvent: function() {
			setMap(ds_map_create());
		},
		stageEndEvent: function() {
			ds_map_destroy(map);
		},
		roomEndEvent: function() {
			destroyAll();
		},
		
		load: function() {
			ds_map_clear(map);
			var curMapArr = ds_map_map_to_array(GameplayManager.currentGameplayBlueprint.stageObjectMap);
			for (var i = 0; i < array_length(curMapArr); i++) {
				ds_map_add(map, curMapArr[i][0], copyObject(curMapArr[i][1]));
			}
			instantiateAll();
			gameplayConvertAll();
		},
		
		getObject: function(idI) {
			return map[?idI];
		},
		objectExists: function(idI) {
			return ds_map_exists(map, idI);
		},
		
		#region Instantiation
		instantiateObject: function(stageObjI, withConversionI = false) {
			var curType = typeArr[stageObjI.typeID];
			var loadingStruct = constructLoadingBase(stageObjI);
			curType.constructLoadingExtra(stageObjI, loadingStruct);
			instantiateWithLoadingStruct(stageObjI, loadingStruct);
			if (withConversionI) gameplayConvertObject(stageObjI);
		},
		instantiateObjectByID: function(stageObjIDI, withConversionI = false) {
			instantiateObject(getObject(stageObjIDI), withConversionI);
		},
		instantiateAll: function() {
			var curStageObjects = ds_map_values_to_array(map);
			var stageObjectAmount = array_length(curStageObjects);
			for (var i = 0; i < stageObjectAmount; i++) {
				instantiateObject(curStageObjects[i]);
			}
		},
		#endregion
		
		#region Saving
		saveObject: function(stageObjI) {
			var curType = typeArr[stageObjI.typeID];
			saveObjectBase(stageObjI);
			curType.saveObjectExtra(stageObjI);
			savingConvertBase(stageObjI);
			curType.savingConvertExtra(stageObjI);
		},
		saveAll: function() {
			var curStageObjects = ds_map_values_to_array(map);
			var stageObjectAmount = array_length(curStageObjects);
			for (var i = 0; i < stageObjectAmount; i++) {
				saveObject(curStageObjects[i]);
			}
		},
		save: function() {
			saveAll();
			ds_map_copy(GameplayManager.currentGameplayBlueprint.stageObjectMap, map);
		},
		#endregion
		
		#region Destruction
		destroyObject: function(stageObjI) {
			var curType = typeArr[stageObjI.typeID];
			destroyObjectBase(stageObjI);
			curType.destroyObjectExtra(stageObjI);
			ds_map_delete(map, stageObjI.id);
			instance_destroy(stageObjI.instanceID);
		},
		destroyObjectByInstance: function(instI) {
			destroyObject(getObject(instI.stageObjectID));
		},
		destroyAll: function() {
			var curStageObjects = ds_map_values_to_array(map);
			var stageObjectAmount = array_length(curStageObjects);
			for (var i = 0; i < stageObjectAmount; i++) {
				destroyObject(curStageObjects[i]);
			}
		},
		#endregion
		
		#region Conversion
		gameplayConvertObject: function(stageObjI) {
			var curType = typeArr[stageObjI.typeID];
			gameplayConvertBase(stageObjI);
			curType.gameplayConvertExtra(stageObjI);
		},
		gameplayConvertAll: function() {
			var curStageObjects = ds_map_values_to_array(map);
			var stageObjectAmount = array_length(curStageObjects);
			for (var i = 0; i < stageObjectAmount; i++) {
				gameplayConvertObject(curStageObjects[i]);
			}
		},
		
		savingConvertObject: function(stageObjI) {
			var curType = typeArr[stageObjI.typeID];
			savingConvertBase(stageObjI);
			curType.savingConvertExtra(stageObjI);
		},
		savingConvertAll: function() {
			var curStageObjects = ds_map_values_to_array(map);
			var stageObjectAmount = array_length(curStageObjects);
			for (var i = 0; i < stageObjectAmount; i++) {
				savingConvertObject(curStageObjects[i]);
			}
		},
		
		arrayConvertToInstanceID: function(arrayI) {
			for (var i = 0; i < array_length(arrayI); i++) {
				arrayI[i] = getObject(arrayI[i]).instanceID;
			}
		},
		arrayConvertToStageObjectID: function(arrayI) {
			for (var i = 0; i < array_length(arrayI); i++) {
				arrayI[i] = arrayI[i].stageObjectID;
			}
		},
		#endregion
		
		#region Copying
		
		copyObject: function(stageObjI) {
			var copiedObj = {};
			struct_copy_deep(stageObjI, copiedObj, true);
			typeArr[stageObjI.typeID].copyExtra(stageObjI, copiedObj);
			copiedObj.typeID = stageObjI.typeID;
			return copiedObj;
		},
		
		#endregion
		
		#region Private
		
			#region Addition
			addStructToMap: function(stageObjI) {
				stageObjI.id = nextID;
				ds_map_add(map, nextID, stageObjI);
				var curID = nextID;
				do {
					nextID++;
					if (nextID == capacity) {
						nextID = 0;
					}
				}until (!objectExists(nextID));
			},
			constructBase: function(stageObjI) {
				return {
					typeID: stageObjI.id,
					instanceID: -1
				}
			},
			addPosition: function(structI, xI, yI) {
				structI.x = xI;
				structI.y = yI;
			},
			addScaling: function(structI, xScaleI, yScaleI) {
				structI.image_xscale = xScaleI;
				structI.image_yscale = yScaleI;
			},
			addAngle: function(structI, angleI) {
				structI.image_angle = angleI;
			},
			addHlthInterface: function(structI, hlthI, hlthMaxI) {
				structI.hlth = hlthI;
				structI.hlthMax = hlthMaxI;
			},
			addEnergyInterface: function(structI, energyI, energyMaxI) {
				structI.energy = energyI;
				structI.energyMax = energyMaxI;
			},
			addTargettingInterface: function(structI, targetsI, targetTypesI) {
				structI.targets = targetsI;
				structI.targetTypes = targetTypesI;
			},
			addStatHUDInterface: function(structI, barArrI, xAddI, yAddI) {
				structI.barArr = barArrI;
				structI.barXAdd = xAddI;
				structI.barYAdd = yAddI;
			},
			addPhysicsInterface: function(structI, massI, gravityI, frictionI) {
				structI.mass = massI;
				structI.grv = gravityI;
				structI.frictionSpd = frictionI;
				structI.hSpd = 0;
				structI.vSpd = 0;
				structI.hAcc = 0;
				structI.vAcc = 0;
			},
			addDecorationInterface: function(structI, hasEnergyI, isPoweredI) {
				structI.hasEnergy = hasEnergyI;
				structI.isPowered = isPoweredI;
			},
			addEnemy: function(structI, xI, yI, hlthI, hlthMaxI, energyI, energyMaxI, targetsI) {
				addPosition(structI, xI, yI);
				addHlthInterface(structI, hlthI, hlthMaxI);
				addEnergyInterface(structI, energyI, energyMaxI);
				addTargettingInterface(structI, targetsI);
			},
			#endregion
		
			#region Loading
			constructLoadingBase: function(stageObjI) {
				var curType = typeArr[stageObjI.typeID];
				var struct = {
					stageObjectID: stageObjI.id,
					hasInstanceColSupport: curType.hasInstanceColSupport
				}
				if (curType.hasPosition) {
					struct.x = stageObjI.x;
					struct.y = stageObjI.y;
				}
				if (curType.hasScaling) {
					struct.image_xscale = stageObjI.image_xscale;
					struct.image_yscale = stageObjI.image_yscale;
				}
				if (curType.hasAngle) {
					struct.image_angle = stageObjI.image_angle;
				}
				if (curType.hasHlthInterface) {
					struct.hlthInterface = HlthInterface.construct(stageObjI.hlth, stageObjI.hlthMax);
				}
				if (curType.hasEnergyInterface) {
					struct.energyInterface = EnergyInterface.construct(stageObjI.energy, stageObjI.energyMax);
				}
				if (curType.hasTargettingInterface) {
					var curTargets = [];
					array_copy(curTargets, 0, stageObjI.targets, 0, array_length(stageObjI.targets));
					var curTargetTypes = [];
					array_copy(curTargetTypes, 0, stageObjI.targetTypes, 0, array_length(stageObjI.targetTypes));
					struct.targettingInterface = TargettingInterface.construct(curTargets, curTargetTypes);
				}
				if (curType.hasStatHUDInterface) {
					var curBarArr = array_create(array_length(stageObjI.barArr));
					for (var i = 0; i < array_length(stageObjI.barArr); i++) {
						curBarArr[i] = {};
						struct_copy(stageObjI.barArr[i], curBarArr[i]);
					}
					struct.statHUDInterface = StatHUDInterface.construct(curBarArr, stageObjI.barXAdd, stageObjI.barYAdd);
				}
				if (curType.hasPhysicsInterface) {
					struct.ifPhysics = if_physics.construct(
						stageObjI.mass, stageObjI.grv, stageObjI.frictionSpd,
						stageObjI.hSpd, stageObjI.vSpd, stageObjI.hAcc, stageObjI.vAcc
					);
				}
				return struct;
			},
			instantiateWithLoadingStruct: function(stageObjI, loadingStructI) {
				var curType = typeArr[stageObjI.typeID];
				var newInst = instance_create_layer(loadingStructI.x, loadingStructI.y, GameplayManager.layerArray[curType.layer], curType.objectIndex, loadingStructI);
				
				if (curType.hasInstanceColSupport)
					InstanceCollisionGrid.instanceAssign(newInst);
				if (curType.hasEnergyInterface)
					EnergyInterface.assign(newInst, newInst.energyInterface);
				if (curType.hasHlthInterface)
					HlthInterface.assign(newInst, newInst.hlthInterface);
				if (curType.hasTargettingInterface)
					TargettingInterface.assign(newInst, newInst.targettingInterface);
				if (curType.hasStatHUDInterface)
					StatHUDInterface.assign(newInst, newInst.statHUDInterface);
				if (curType.hasPhysicsInterface)
					if_physics.assign(newInst, newInst.ifPhysics);
				
				stageObjI.instanceID = newInst.id;
			},
			#endregion
			
			#region Saving
			saveObjectBase: function(stageObjI) {
				var curType = typeArr[stageObjI.typeID];
				var curInst = stageObjI.instanceID;
				
				if (curType.hasPosition) {stageObjI.x = curInst.x; stageObjI.y = curInst.y;}
				if (curType.hasScaling) {stageObjI.image_xscale = curInst.image_xscale; stageObjI.image_yscale = curInst.image_yscale;}
				if (curType.hasAngle) {stageObjI.image_angle = curInst.image_angle;}
				if (curType.hasHlthInterface) {stageObjI.hlth = curInst.hlthInterface.hlth; stageObjI.hlthMax = curInst.hlthInterface.hlthMax;}
				if (curType.hasEnergyInterface) {stageObjI.energy = curInst.energyInterface.energy; stageObjI.energyMax = curInst.energyInterface.energyMax;}
				if (curType.hasTargettingInterface) {
					array_copy(stageObjI.targets, 0, curInst.targettingInterface.targetCheckingOrder, 0, array_length(curInst.targettingInterface.targetCheckingOrder));
				}
				if (curType.hasPhysicsInterface) {
					stageObjI.mass = curInst.ifPhysics.mass;
					stageObjI.grv = curInst.ifPhysics.grv;
					stageObjI.frictionSpd = curInst.ifPhysics.friction;
					stageObjI.hSpd = curInst.ifPhysics.hSpd;
					stageObjI.vSpd = curInst.ifPhysics.vSpd;
					stageObjI.hAcc = curInst.ifPhysics.hAcc;
					stageObjI.vAcc = curInst.ifPhysics.vAcc;
				}
			},
			#endregion
			
			#region Destruction
			destroyObjectBase: function(stageObjI) {
				var curType = typeArr[stageObjI.typeID];
				if (curType.hasInstanceColSupport)
					InstanceCollisionGrid.instanceDeassign(stageObjI.instanceID);
				if (curType.hasEnergyInterface)
					EnergyInterface.deassign(stageObjI.instanceID);
				if (curType.hasHlthInterface)
					HlthInterface.deassign(stageObjI.instanceID);
				if (curType.hasTargettingInterface)
					TargettingInterface.deassign(stageObjI.instanceID);
				if (curType.hasStatHUDInterface)
					StatHUDInterface.deassign(stageObjI.instanceID);
				if (curType.hasPhysicsInterface)
					if_physics.deassign(stageObjI.instanceID);
			},
			#endregion
			
			#region Conversion
			
			gameplayConvertBase: function(stageObjI) {
				var curType = typeArr[stageObjI.typeID];
				if (curType.hasTargettingInterface) {
					var curInterface = stageObjI.instanceID.targettingInterface;
					var curLength = array_length(curInterface.targetCheckingOrder);
					for (var i = 0; i < curLength; i++) {
						curInterface.targetCheckingOrder[i] = tryGameplayConversion(curInterface.targetCheckingOrder[i]);
					}
				}
			},
			savingConvertBase: function(stageObjI) {
				var curType = typeArr[stageObjI.typeID];
				if (curType.hasTargettingInterface) {
					var curLength = array_length(stageObjI.targets);
					for (var i = 0; i < curLength; i++) {
						stageObjI.targets[i] = trySavingConversion(stageObjI.targets[i]);
					}
				}
			},
			tryGameplayConversion: function(stageObjIDI) {
				if (objectExists(stageObjIDI))
					return StageObjectManager.getObject(stageObjIDI).instanceID;
				else return undefined;
			},
			trySavingConversion: function(instanceIDI) {
				if (instance_exists(instanceIDI))
					return instanceIDI.stageObjectID;
				else return undefined;
			}
			
			#endregion
			
		#endregion
		
	},
	
	objectManagers: {
		stageStartEvent: function() {
			camouflage.stageStartEvent();
		},
		stageEndEvent: function() {
			camouflage.stageEndEvent();
		},
		roomStartEvent: function() {
			camouflage.roomStartEvent();
		},
		beginStepEvent: function() {
			camouflage.beginStepEvent();
		},
		drawBeginEvent: function() {
			
		},
		drawEvent: function() {
			
		},
		
		// Managers themselves
		camouflage: {
			clusterCapacity: 16,
			clusterObjectCapacity: 20,
			camouflageClusters: 0,
			visibleCamouflageBlend: make_color_rgb(150, 150, 195),
			invisibleCamouflageBlend: make_color_rgb(90, 90, 90),
			
			stageStartEvent: function() {
				isBuilt = false;
				camouflageClusters = ds_map_create();
			},
			stageEndEvent: function() {
				ds_map_destroy(camouflageClusters);
			},
			roomStartEvent: function() {
				instance_create_layer(0, 0, GameplayManager.layerArray[layers.camouflageBack], obj_camouflageRendererBack);
				instance_create_layer(0, 0, GameplayManager.layerArray[layers.camouflageFront], obj_camouflageRendererFront);
				if (!isBuilt) {
					
					var constructCluster = function(idI) {
						return {
							id: idI,
							objects: array_create(clusterObjectCapacity),
							objAmount: 0,
							visibility: true
						};
					}
					for (var i = 0; i < instance_number(obj_camouflage); i++) {
						var curCamouflage = instance_find(obj_camouflage, i);
						if (!ds_map_exists(camouflageClusters, curCamouflage.clusterID)) {
							ds_map_add(camouflageClusters, curCamouflage.clusterID, constructCluster(curCamouflage.clusterID));
						}
						var curCluster = camouflageClusters[? curCamouflage.clusterID];
						curCluster.objects[curCluster.objAmount] = curCamouflage.id;
						curCluster.objAmount++;
						CamouflageCollisionGrid.setRegionByInstance(curCamouflage, curCamouflage.clusterID);
					}
					isBuilt = true;
				}else {
					
					var curClusters = ds_map_values_to_array(camouflageClusters);
					for (var i = 0; i < array_length(curClusters); i++) {
						var curCluster = curClusters[i];
						curCluster.objAmount = 0;
					}
					for (var i = 0; i < instance_number(obj_camouflage); i++) {
						var curCamouflage = instance_find(obj_camouflage, i);
						var curCluster = camouflageClusters[? curCamouflage.clusterID];
						curCluster.objects[curCluster.objAmount] = curCamouflage.id;
						curCluster.objAmount++;
					}
				}
			},
			beginStepEvent: function() { // Updates the revealed clusters
				var curClusters = ds_map_values_to_array(camouflageClusters);
				var newVisibleClusters = CamouflageCollisionGrid.instanceGetOccupyingClusters(obj_player);
				for (var i = 0; i < array_length(curClusters); i++) {
					var curCluster = curClusters[i];
					curCluster.visibility = true;
				}
				for (var i = 0; i < array_length(newVisibleClusters); i++) {
					var curCluster = camouflageClusters[?newVisibleClusters[i]];
					curCluster.visibility = false;
				}
			},
			drawBackCamouflage: function() {
				var clustersArr = ds_map_keys_to_array(camouflageClusters);
				for (var i = 0; i < array_length(clustersArr); i++) {
					var curCluster = camouflageClusters[? clustersArr[i]];
					if (curCluster.visibility == false) {
						for (var j = 0; j < curCluster.objAmount; j++) {
							var curCamouflage = curCluster.objects[j];
							with (curCamouflage) {
								image_blend = other.invisibleCamouflageBlend;
								image_alpha = 0.6;
								draw_self();
								image_alpha = 1.0;
							}
						}
					}
				}
			},
			drawFrontCamouflage: function() {
				var clustersArr = ds_map_keys_to_array(camouflageClusters);
				for (var i = 0; i < array_length(clustersArr); i++) {
					var curCluster = camouflageClusters[? clustersArr[i]];
					if (curCluster.visibility == true) {
						for (var j = 0; j < curCluster.objAmount; j++) {
							var curCamouflage = curCluster.objects[j];
							with (curCamouflage) {
								image_blend = other.visibleCamouflageBlend;
								draw_self();
							}
						}
					}
				}
			},
			
			instanceIsCamouflaged: function(instI) { // OBSERVATION094 - Optimize camouflage updating to occur only when objects move.
				var instOccupyingClusters = CamouflageCollisionGrid.instanceGetOccupyingClusters(instI);
				for (var i = 0; i < array_length(instOccupyingClusters); i++) {
					if (camouflageClusters[?instOccupyingClusters[i]].visibility == true) {
						return false;
					}
				}
				return true;
			}
		}
	},
	
	actionObjectManagers: {
		queue: ds_queue_create(),
		
		endStepEvent: function() {
			var tempQueue = ds_queue_create();
			while (!ds_queue_empty(queue)) {
				var curActionObj = ds_queue_dequeue(queue);
				if (curActionObj.isDeleted) {
					curActionObj.type.cleanup(curActionObj);
					delete curActionObj;
				}else {
					ds_queue_enqueue(tempQueue, curActionObj);
					curActionObj.type.endStepEventOfActionObj(curActionObj);
				}
			}
			ds_queue_destroy(queue);
			queue = tempQueue;
		},
		
		roomEndEvent: function() {
			cleanup();
		},
		
		cleanup: function() {
			while (!ds_queue_empty(queue)) {
				var curActionObj = ds_queue_dequeue(queue);
				curActionObj.type.cleanup(curActionObj);
				delete curActionObj;
			}
		},
		
		slash: {
			start: function(frameMinI, frameMaxI, hitboxSprI, starterInstI, starterInstDirI, hitFunctionI, targetsI, isSingleTargetI) {
				var newActionObj = {
					type: ActionObjectManagers.slash,
					isDeleted: false,
					frameMin: frameMinI, frameMax: frameMaxI,
					frame: 0,
					hitboxSpr: hitboxSprI,
					starterInst: starterInstI,
					starterInstDir: starterInstDirI,
					hitFunction: hitFunctionI,
					targets: targetsI,
					hitInstances: ds_map_create(),
					isSingleTarget: isSingleTargetI,
					hasHit: false
				}
				ds_queue_enqueue(ActionObjectManagers.queue, newActionObj);
				return newActionObj;
			},
			stop: function(actionObjI) {
				actionObjI.isDeleted = true;
			},
			cleanup: function(actionObjI) {
				ds_map_destroy(actionObjI.hitInstances);
			},
			endStepEventOfActionObj: function(actionObjI) {
				var curStarterInst = actionObjI.starterInst;
				var xOffset = sprite_get_xoffset(actionObjI.hitboxSpr);
				var yOffset = sprite_get_yoffset(actionObjI.hitboxSpr);
				var colX1;
				var colX2;
				if (actionObjI.starterInstDir == 1) {
					colX1 = curStarterInst.x-xOffset+sprite_get_bbox_left(actionObjI.hitboxSpr);
					colX2 = curStarterInst.x-xOffset+sprite_get_bbox_right(actionObjI.hitboxSpr);
				}
				else {
					colX1 = curStarterInst.x+xOffset-sprite_get_bbox_right(actionObjI.hitboxSpr);
					colX2 = curStarterInst.x+xOffset-sprite_get_bbox_left(actionObjI.hitboxSpr);
				}
				var colY1 = curStarterInst.y-yOffset+sprite_get_bbox_top(actionObjI.hitboxSpr);
				var colY2 = curStarterInst.y-yOffset+sprite_get_bbox_bottom(actionObjI.hitboxSpr);
				var gridCollisions = InstanceCollisionGrid.rectangleGetCollidedInstances(colX1, colY1, colX2, colY2);
				if (actionObjI.frame >= actionObjI.frameMin && actionObjI.frame < actionObjI.frameMax) {
					var gridCollisionLength = array_length(gridCollisions);
					var hitEntities = array_create(16);
					var index = 0;
					var length = 0;
					var hasHitFrame = false;
					for (var i = 0; i < gridCollisionLength; i++) {
						var curInst = gridCollisions[i];
						if (
							!actionObjI.hasHit &&
							ds_map_exists(actionObjI.targets, curInst.id) &&
							!ds_map_exists(actionObjI.hitInstances, curInst.id) &&
							!BlockCollisionGrid.checkCollisionRectangle(curStarterInst.x, curStarterInst.y, curInst.x, curInst.y, collisionType_normal) &&
							collision_rectangle(colX1, colY1, colX2, colY2, curInst, true, true)
						) {
							if (actionObjI.isSingleTarget) {
								hitEntities[index] = curInst;
								index++;
								length++;
								hasHitFrame = true;
							}else {
								ds_map_add(actionObjI.hitInstances, curInst.id, undefined);
								actionObjI.hitFunction(curInst);
							}
						}
					}
					if (hasHitFrame) {
						actionObjI.hasHit = true;
						var nearestInst = hitEntities[0];
						for (var i = 1; i < length; i++) {
							if (actionObjI.starterInstDir == 1) {
								if (hitEntities[i].bbox_left - colX1 < nearestInst.bbox_left - colX1) nearestInst = hitEntities[i];
							}else {
								if (colX2 - hitEntities[i].bbox_right < colX2 - nearestInst.bbox_right) nearestInst = hitEntities[i];
							}
						}
						ds_map_add(actionObjI.hitInstances, nearestInst.id, undefined);
						actionObjI.hitFunction(nearestInst);
					}
				}
			},
			setFrame: function(actionObjI, frameI) {
				actionObjI.frame = frameI;
			}
		},
		hitscan: {
			start: function(xI, yI, hDirI, vDirI, eventI) {
				var checkingChunkLength = collisionGrid_tileSize;
				if (hDirI != 0) {
					if (xI%collisionGrid_tileSize == 0) xI += hDirI;
					var initX = xI;
					var curX = xI;
					var hasEnded = false;
					
					curX += hDirI*checkingChunkLength;
					while (!hasEnded) {
						var curX1 = min(curX, curX+hDirI*checkingChunkLength);
						var curX2 = max(curX, curX+hDirI*checkingChunkLength);
						
						if (BlockCollisionGrid.checkNoCollisionPoint(curX, yI, collisionType_nothing)) {
							eventI.notifyCollisionBlock(BlockCollisionGrid.pointGetFirstCollisionType(curX, yI));
							if (eventI.notifiesEnd) {
								hasEnded = true;
								curX = (hDirI == 1) ? floor(curX/collisionGrid_tileSize)*collisionGrid_tileSize : ceil(curX/collisionGrid_tileSize)*collisionGrid_tileSize;
								break;
							}
						}
						
						var curGridCollisions = InstanceCollisionGrid.pointGetCollidedInstances(curX, yI);
						for (var i = 0; i < array_length(curGridCollisions); i++) {
							var curObj = curGridCollisions[i];  // OBSERVATION001 - The grid check is only for bounding. There might be no collision here.
							var curObjBBoxLeft = curObj.bbox_left;
							var curObjBBoxRight = curObj.bbox_right;
							eventI.notifyCollisionInst(curObj);
							if (eventI.notifiesEnd) {
								hasEnded = true;
								curX = (hDirI == 1) ? curObjBBoxLeft : curObjBBoxRight;
								break;
							}
						}
						
						if (!hasEnded) curX += hDirI*checkingChunkLength;
					}
		
					eventI.notifyHoriHitscanEnd(curX);
				}
				else if (vDirI != 0) {
					if (yI%collisionGrid_tileSize == 0) yI += vDirI;
					var initY = yI;
					var curY = yI;
					var hasEnded = false;
					
					curY += vDirI*checkingChunkLength;
					while (!hasEnded) {
						var curY1 = min(curY, curY+vDirI*checkingChunkLength);
						var curY2 = max(curY, curY+vDirI*checkingChunkLength);
						
						if (BlockCollisionGrid.checkNoCollisionPoint(xI, curY, collisionType_nothing)) {
							eventI.notifyCollisionBlock(BlockCollisionGrid.pointGetFirstCollisionType(xI, curY));
							if (eventI.notifiesEnd) {
								hasEnded = true;
								curY = (vDirI == 1) ? floor(curY/collisionGrid_tileSize)*collisionGrid_tileSize : ceil(curY/collisionGrid_tileSize)*collisionGrid_tileSize;
								break;
							}
						}
						
						var curGridCollisions = InstanceCollisionGrid.pointGetCollidedInstances(xI, curY);
						for (var i = 0; i < array_length(curGridCollisions); i++) {
							var curObj = curGridCollisions[i];
							var curObjBBoxTop = curObj.bbox_top;
							var curObjBBoxBottom = curObj.bbox_bottom;
							eventI.notifyCollisionInst(curObj);
							if (eventI.notifiesEnd) {
								hasEnded = true;
								curY = (vDirI == 1) ? curObjBBoxTop : curObjBBoxBottom;
								break;
							}
						}
						
						if (!hasEnded) curY += vDirI*checkingChunkLength;
					}
		
					eventI.notifyVertHitscanEnd(curY);
				}
			},
			startShortcutInst: function(xI, yI, hDirI, vDirI, eventI, instI) {
				if (hDirI != 0) {
					var curObj = instI;
					var curObjBBoxLeft = curObj.bbox_left;
					var curObjBBoxRight = curObj.bbox_right;
					eventI.notifyCollisionInst(curObj);
					var curX = (hDirI == 1) ? curObjBBoxLeft : curObjBBoxRight;
					eventI.notifyHoriHitscanEnd(curX);
				}
				else if (vDirI != 0) {
					var curObj = instI;
					var curObjBBoxTop = curObj.bbox_top;
					var curObjBBoxBottom = curObj.bbox_bottom;
					eventI.notifyCollisionInst(curObj);
					var curY = (vDirI == 1) ? curObjBBoxTop : curObjBBoxBottom;
					eventI.notifyVertHitscanEnd(curY);
				}
			}
		}
	},
	
	// Interfaces
	initializeInterfaces: function() { // OBSERVATION095 - Change all interface instance variable by if[respective interface]
		var constructInterface = function() {
			return {
				map: ds_map_create(),
				construct: function(/*[Input arguments]*/) {
					/*return {
						instanceID: undefined, // Obligatory
						[...] // Speccific stuff for the interface.
					};*/
				},
				assign: function(instI, structI) {
					structI.instanceID = instI.id;
					ds_map_add(map, instI.id, structI);
				},
				deassign: function(instI) {
					delete map[?instI];
					ds_map_delete(map, instI);
				},
				clean: function() {
					var curKeys = ds_map_keys_to_array(map);
					for (var i = 0; i < array_length(curKeys); i++) {
						var curKey = curKeys[i];
						deassign(curKey);
					}
				},
				getInstances: function() {
					return ds_map_keys_to_array(map);
				},
				hasInstance: function(instI) {
					return ds_map_exists(map, instI.id);
				}
			}
		}
		
		// OBSERVATION096 - Generic functions like receiveHealth() should not be something defined inside the instance itself, as it should be a static function. receiveHealthExtra() would be enough in that example.
		
		// Energy
		energyInterface = constructInterface();
		energyInterface.construct = function(energyI, energyMaxI) {
			return {
				instanceID: undefined,
				energy: energyI,
				energyMax: energyMaxI,
				hasEnergy: energyI != 0,
				useEnergy: function(energyI) {
					useEnergyExtra(energyI);
					energy -= energyI;
					if (StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasEnergy) StatHUDInterface.flashBarEnergy(instanceID.statHUDInterface);
					if (energy == 0) {
						if (hasEnergy) {
							hasEnergy = false;
							powerOffExtra();
						}
					}else if (energy < 0) {
						if (hasEnergy) {
							hasEnergy = false;
							powerOffExtra();
						}
						show_debug_message("useEnergy() function error in newEnergyStat struct of instance "+string(instanceID)+"!!!");
						show_debug_message("object of instance: "+object_get_name(instanceID.object_index));
						show_debug_message("energy underflow!!!");
						energy = 0;
					}
				},
				receiveEnergy: function(energyI) {
					receiveEnergyExtra(energyI);
					if (StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasEnergy) {
						StatHUDInterface.flashBarEnergy(instanceID.statHUDInterface);
						StatHUDInterface.addHighlightEnergy(instanceID.statHUDInterface, energy, energy+energyI);
					}
					energy += energyI;
					if (energyMax != -1 && energy > energyMax) {
						energy = energyMax;
					}
					if (!hasEnergy) {
						hasEnergy = true;
						powerOnExtra();
					}
				},
				setEnergy: function(energyI) {
					setEnergyExtra(energyI);
					if (energy < energyI && StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasEnergy) {
						StatHUDInterface.flashBarEnergy(instanceID.statHUDInterface);
						StatHUDInterface.addHighlightEnergy(instanceID.statHUDInterface, energy, energyI);
					}
					energy = energyI;
					if (energy == 0 && hasEnergy) {
						hasEnergy = false;
						powerOffExtra();
					}else if (energy != 0 && !hasEnergy) {
						hasEnergy = true;
						powerOnExtra();
					}
				},
				setMaxEnergy: function(energyMaxI) {
					energyMax = energyMaxI;
				},
		
				// Extras
				useEnergyExtra: function(energyI) {
			
				},
				receiveEnergyExtra: function(energyI) {
			
				},
				setEnergyExtra: function(energyI) {
			
				},
				powerOffExtra: function() {
			
				},
				powerOnExtra: function() {
			
				}
			};
		}
		
		// Health
		hlthInterface = constructInterface();
		hlthInterface.construct = function(hlthI, hlthMaxI) {
			return {
				instanceID: undefined,
				hlth: hlthI,
				hlthMax: hlthMaxI,
				isDead: false,
				receiveDamage: function(hlthI) {
					receiveDamageExtra(hlthI);
					hlth -= hlthI;
					if (StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasHlth) StatHUDInterface.flashBarHlth(instanceID.statHUDInterface);
					if (hlth <= 0) {
						hlth = 0;
						if (!isDead) {
							dieExtra();
							isDead = true;
						}
					}
				},
				receiveHlth: function(hlthI) {
					receiveHlthExtra(hlthI);
					if (StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasHlth) {
						StatHUDInterface.flashBarHlth(instanceID.statHUDInterface);
						StatHUDInterface.addHighlightHlth(instanceID.statHUDInterface, hlth, hlth+hlthI);
					}
					hlth += hlthI;
					if (hlthMax != -1 && hlth > hlthMax) {
						hlth = hlthMax;
					}
				},
				setHlth: function(hlthI) {
					setHlthExtra(hlthI);
					if (hlth < hlthI && StatHUDInterface.hasInstance(instanceID) && instanceID.statHUDInterface.hasHlth) {
						StatHUDInterface.flashBarHlth(instanceID.statHUDInterface);
						StatHUDInterface.addHighlightHlth(instanceID.statHUDInterface, hlth, hlthI);
					}
					hlth = hlthI;
					if (hlth <= 0) {
						hlth = 0;
						if (!isDead) {
							dieExtra();
							isDead = true;
						}
					}
				},
				setMaxHlth: function(hlthMaxI) {
					hlthMax = hlthMaxI;
				},
		
				// Extras
				receiveDamageExtra: function(hlthI) {
			
				},
				receiveHlthExtra: function(hlthI) {
			
				},
				setHlthExtra: function(hlthI) {
			
				},
				dieExtra: function() {
			
				}
			};
		}
		
		// Targetting interface
		#region
		targettingInterface = constructInterface();
		targettingInterface.construct = function(targetsI, targetTypesI) {
			var curTargets = [];
			var curTargetTypes = [];
			array_copy(curTargets, 0, targetsI, 0, array_length(targetsI));
			array_copy(curTargetTypes, 0, targetTypesI, 0, array_length(targetTypesI));
			var newStruct = {
				instanceID: undefined,
				targetMemoryCapacity: 64,
				isTargetting: false,
				canTarget: false,
				targetCheckingOrder: curTargets, // In which order targets are checked, left to right. Supports both instances and objects.
				targetTypes: curTargetTypes,
				targetCheckingActivated: [], // Which targets are activated.
				curTarget: -1,
				updateCurrentTarget: function() {
					isTargetting = false;
					if (!canTarget) {
						return;
					}
					for (var i = 0; i < array_length(targetCheckingOrder); i++) {
						if (targetCheckingActivated[i]) {
							var curCandidate = targetCheckingOrder[i];
							if (targetTypes[i] == if_targetting_targetTypes.object && object_exists(curCandidate)) {
								var targettedInstance = getTargettedObject(curCandidate);
								if (targettedInstance != undefined) {
									curTarget = targettedInstance;
									isTargetting = true;
									break;
								}
							}else if (targetTypes[i] == if_targetting_targetTypes.instance && instance_exists(curCandidate)) {
								if (isInstanceTargetted(curCandidate)) {
									curTarget = curCandidate;
									isTargetting = true;
									break;
								}
							}
						}
						isTargetting = false;
					}
				},
				isInstanceTargetted: function(targetI) {
					
				},
				getTargettedObject: function(objectI) {
					for (var i = 0; i < instance_number(objectI); i++) {
						var curObj = instance_find(objectI, i);
						if (isInstanceTargetted(curObj)) {
							return curObj;
						}
					}
					return undefined;
				},
				setTargetActivation: function(indexI, stateI) {
					targetCheckingActivated[indexI] = stateI;
				}
			};
			newStruct.targetCheckingActivated = array_create(array_length(newStruct.targetCheckingOrder), true);
			return newStruct;
		}
		
		with (targettingInterface) {
			canInstanceGoToInstance = function(sourceInstI, targetInstI, ignoresHPlatformsI, ignoresVPlatformI) { // See if this can be optimized.
				if (true) {
					var sourceX = sourceInstI.x;
					var sourceY = sourceInstI.y;
					var targetX = targetInstI.x;
					var targetY = targetInstI.y;
					if (BlockCollisionGrid.checkCollisionRectangle(sourceX, sourceY, targetX, targetY, collisionType_normal)) {
						return false;
					}else if (!ignoresHPlatformsI) {
						if (sourceX < targetX && BlockCollisionGrid.checkCollisionRectangle(sourceX, sourceY, targetX, targetY, collisionType_onewayLeft)) {
							return false;
						}else if (sourceX != targetX  && BlockCollisionGrid.checkCollisionRectangle(sourceX, sourceY, targetX, targetY, collisionType_onewayRight)) {
							return false;
						}
					}else if (!ignoresVPlatformI) {
						if (sourceY < targetY && BlockCollisionGrid.checkCollisionRectangle(sourceX, sourceY, targetX, targetY, collisionType_onewayUp)) {
							return false;
						}
					}
					return true;
				}else {
					return false;
				}
			}
		}
		
		#endregion
		
		// Stat HUD
		#region
		statHUDInterface = constructInterface();
		with (statHUDInterface) {
			borderThickness = 2;
			barLifetime = 120;
			barDisappearFrame = 30;
			barHighlightArrCap = 8;
			barHighlightColor = c_white;
			barHighlightLifetime = 40;
			borderColor = c_gray;
			emptyColor = c_black;
		}
		statHUDInterface.constructBar = function(typeIDI, pipWidthI, pipHeightI, pipCapacityI, valueI) {
			return {
				typeID: typeIDI,
				pipWidth: pipWidthI,
				pipHeight: pipHeightI,
				pipCapacity: pipCapacityI,
				lifetimeCur: 0,
				highlightArr: array_create(StatHUDInterface.barHighlightArrCap, [0, 0, 0]),
				highlightArrIndex: 0,
				value: valueI
			}
		}
		statHUDInterface.flashBar = function(barI) {
			barI.lifetimeCur = StatHUDInterface.barLifetime;
		}
		statHUDInterface.flashBarHlth = function(interfaceI) {
			StatHUDInterface.flashBar(interfaceI.barArr[interfaceI.hlthBarIndex]);
		}
		statHUDInterface.flashBarEnergy = function(interfaceI) {
			StatHUDInterface.flashBar(interfaceI.barArr[interfaceI.energyBarIndex]);
		}
		statHUDInterface.addHighlight = function(barI, startValueI, endValueI) {
			barI.highlightArr[barI.highlightArrIndex] = [
				StatHUDInterface.barHighlightLifetime,
				startValueI,
				endValueI
			];
			barI.highlightArrIndex++;
			if (barI.highlightArrIndex == StatHUDInterface.barHighlightArrCap)
				barI.highlightArrIndex = 0;
		}
		statHUDInterface.addHighlightHlth = function(interfaceI, startValueI, endValueI) {
			StatHUDInterface.addHighlight(interfaceI.barArr[interfaceI.hlthBarIndex], startValueI, endValueI);
		}
		statHUDInterface.addHighlightEnergy = function(interfaceI, startValueI, endValueI) {
			StatHUDInterface.addHighlight(interfaceI.barArr[interfaceI.energyBarIndex], startValueI, endValueI);
		}
		statHUDInterface.barType_health = {
			id: 0,
			fillColor: c_red,
			getValue: function(instI) {
				return instI.hlthInterface.hlth;
			},
			getValueMax: function(instI) {
				return instI.hlthInterface.hlthMax;
			}
		};
		statHUDInterface.barType_energy = {
			id: 1,
			fillColor: c_yellow,
			getValue: function(instI) {
				return instI.energyInterface.energy;
			},
			getValueMax: function(instI) {
				return instI.energyInterface.energyMax;
			}
		};
		with (statHUDInterface) {
			barTypeArr = [barType_health, barType_energy];
		}
		statHUDInterface.construct = function(barArrI, xAddI, yAddI) {
			var newInterface = {
				instanceID: undefined,
				isVisible: true,
				hasHlth: false,
				hlthBarIndex: undefined,
				hasEnergy: false,
				energyBarIndex: undefined,
				barArr: barArrI,
				barAmount: array_length(barArrI),
				barXOffset: xAddI,
				barYOffset: yAddI,
				totalBarWidth: undefined
			};
			var maxBarWidth = 0;
			for (var i = 0; i < array_length(barArrI); i++) {
				var curBar = barArrI[i];
				if (curBar.typeID == StatHUDInterface.barType_health.id) {
					newInterface.hasHlth = true;
					newInterface.hlthBarIndex = i;
				}
				if (curBar.typeID == StatHUDInterface.barType_energy.id) {
					newInterface.hasEnergy = true;
					newInterface.energyBarIndex = i;
				}
				
				maxBarWidth = max(maxBarWidth, (StatHUDInterface.borderThickness+curBar.pipWidth)*curBar.value/curBar.pipCapacity+StatHUDInterface.borderThickness);
			}
			newInterface.totalBarWidth = maxBarWidth;
			return newInterface;
		}
		
		statHUDInterface.tick = function(interfaceI) {
			for (var i = 0; i < interfaceI.barAmount; i++) {
				var curBar = interfaceI.barArr[i];
				if (curBar.lifetimeCur != 0) {
					curBar.lifetimeCur--;
				}
				for (var j = 0; j < StatHUDInterface.barHighlightArrCap; j++) {
					var curItem = curBar.highlightArr[j];
					if (curItem[0] != 0) {
						curItem[0]--;
					}
				}
			}
		}
		statHUDInterface.tickAll = function() {
			var curInterfaces = ds_map_values_to_array(StatHUDInterface.map);
			for (var i = 0; i < array_length(curInterfaces); i++) {
				StatHUDInterface.tick(curInterfaces[i]);
			}
		}
		
		statHUDInterface.draw = function(interfaceI) {
			var curInst = interfaceI.instanceID;
			if (interfaceI.isVisible) {
				var curYAdd = 0;
				for (var j = interfaceI.barAmount-1; j >= 0; j--) {
					var curBar = interfaceI.barArr[j];
					var curY2 = curYAdd;
					var curYAddSubtract = StatHUDInterface.borderThickness+curBar.pipHeight;
					var curY1 = curY2-curYAddSubtract-StatHUDInterface.borderThickness;
					
					var pipWidth = curBar.pipWidth;
					var pipHeight = curBar.pipHeight;
					var pipCapacity = curBar.pipCapacity;
					var curValueMax = StatHUDInterface.barTypeArr[curBar.typeID].getValueMax(curInst);
					var pipAmount = curValueMax/pipCapacity;
					var curValue =  StatHUDInterface.barTypeArr[curBar.typeID].getValue(curInst);
					
					var barWidth = (pipWidth+StatHUDInterface.borderThickness)*pipAmount+StatHUDInterface.borderThickness;
					var pipColor =  StatHUDInterface.barTypeArr[curBar.typeID].fillColor;
					var pipSpacing = pipWidth+StatHUDInterface.borderThickness;
					var barAlpha = min(1.0, curBar.lifetimeCur/StatHUDInterface.barDisappearFrame);
					var remainingValue = curValue/pipCapacity;
					var pipHighlightArr = curBar.highlightArr;
					curYAdd -= curYAddSubtract;
			
					if (barAlpha != 0) {
						var curMainX = curInst.x-interfaceI.totalBarWidth/2+interfaceI.barXOffset;
						var curMainY = curInst.y+interfaceI.barYOffset+curYAdd;
						var barHeight = curY2-curY1;
				
						draw_set_alpha(barAlpha);
						draw_set_color(StatHUDInterface.borderColor);
						draw_rectangle(
							curMainX, curMainY,
							curMainX+barWidth-1, curMainY+barHeight-1,
							false
						);
		
						var curPipX = StatHUDInterface.borderThickness;
						var pipY = StatHUDInterface.borderThickness;
						for (var pip = 0; pip < pipAmount; pip++) {
					
							draw_set_alpha(barAlpha);
					
							// Back of pip
							draw_set_color(StatHUDInterface.emptyColor);
							draw_rectangle(
								curMainX+curPipX, curMainY+pipY, curMainX+curPipX+pipWidth-1, curMainY+pipY+pipHeight-1, false
							);
					
							// Pip itself
							var curPipRatio = max(0, min(1, remainingValue));
							var isHorizontal = pipWidth > pipHeight;
							var curPipProgress = pip+curPipRatio;
					
							draw_set_color(pipColor);
							if (isHorizontal) {
								draw_rectangle(
									curMainX+curPipX, curMainY+pipY, curMainX+curPipX+curPipRatio*pipWidth-1, curMainY+pipY+pipHeight-1, false
								);
							}else {
								draw_rectangle(
									curMainX+curPipX, curMainY+pipY, curMainX+curPipX+pipWidth-1, curMainY+pipY+curPipRatio*pipHeight-1, false
								);
							}
					
							draw_set_color(StatHUDInterface.barHighlightColor);
							for (var c = 0; c < StatHUDInterface.barHighlightArrCap; c++) {
								var curHighlight = pipHighlightArr[c];
								var valueStart = curHighlight[1]/pipCapacity;
								var valueEnd = curHighlight[2]/pipCapacity;
								if (pip >= valueStart && pip < valueEnd) {
									var curHighlightAlpha = curHighlight[0]/StatHUDInterface.barHighlightLifetime;
									var curPipStartRatio = max(0.0, valueStart-pip);
									var curPipEndRatio = min(1.0, valueEnd-pip);
									draw_set_alpha(curHighlightAlpha*barAlpha);
									if (isHorizontal) {
										draw_rectangle(
											curMainX+curPipX+curPipStartRatio*pipWidth, curMainY+pipY, curMainX+curPipX+curPipEndRatio*pipWidth-1, curMainY+pipY+pipHeight-1, false
										);
									}else {
										draw_rectangle(
											curMainX+curPipX, curMainY+pipY+curPipStartRatio*pipHeight, curMainX+curPipX+pipWidth-1, curMainY+pipY+curPipEndRatio*pipHeight-1, false
										);
									}
								}
							}
							draw_set_alpha(1.0);
					
							remainingValue--;
							curPipX += pipSpacing;
						}
					}
				}
			}
		}
		statHUDInterface.drawAll = function() {
			var curInterfaces = ds_map_values_to_array(StatHUDInterface.map);
			for (var i = 0; i < array_length(curInterfaces); i++) {
				StatHUDInterface.draw(curInterfaces[i]);
			}
		}
		#endregion
		
		// Physics interface
		#region
		physicsInterface = constructInterface(); // OBSERVATION001 - Add extra-type function support.
		physicsInterface.construct = function(massI, gravityI, frictionI) {
			var newInterface = {
				isManaged: true,
				
				hasSettedH: false,
				hasSettedV: false,
				
				hSpd: 0,
				vSpd: 0,
				hAcc: 0,
				vAcc: 0,
				
				mass: massI,
				
				doesGrv: true,
				grv: gravityI,
				
				doesFriction: true,
				friction: frictionI,
				
				isStrongKnockbackedStack: false,
				strongKnockbackTemp: {
					isActive: false,
					framesCur: 0
				},
				strongKnockbackFloor: {
					isActive: false,
					isFirstFrame: false
				},
				strongKnockbackStartExtra: function() {
					
				},
				strongKnockbackEndExtra: function() {
					
				},
				
				/*isAbleToMoveStack: 0,
				unableToMoveTemp: {
					isActive: false,
					framesCur: 0
				},*/
				
				isCollidingRight: false,
				isCollidingLeft: false,
				isCollidingDown: false,
				isCollidingUp: false,
				
				collision: {
					isCollidingRight: false,
					isCollidingLeft: false,
					isCollidingDown: false,
					isCollidingUp: false,
					perms: {
						any: true,
						platform: true,
						hPlatform: true,
						vPlatform: true
					}
				},
				
				collisionEvents: {
					generic: {
						interface: undefined,
						preExecution: function() {
							hasCollided = false;
						},
						notifyBaseCollision: function() {
							
						},
						notifyHoriCollision: function() {
							hasCollided = true;
							var curInst = interface.instanceID;
							var p = interface;
							with (curInst) {
								if (p.hSpd > 0 && !p.isCollidingRight) {
									x = ceil(x/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, 1, 0, collisionType_normal)) {
										x += 8;
									}
									p.isCollidingRight = true;
									p.hSpd = 0;
								}else if (p.hSpd != 0 && !p.isCollidingLeft) {
									x = floor(x/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, -1, 0, collisionType_normal)) {
										x -= 8;
									}
									p.isCollidingLeft = true;
									p.hSpd = 0;
								}
							}
						},
						notifyVertCollision: function() {
							hasCollided = true;
							var curInst = interface.instanceID;
							var p = interface;
							with (curInst) {
								if (p.vSpd > 0 && !p.isCollidingDown) {
									y = ceil(y/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, 0, 1, collisionType_normal)) {
										y += 8;
									}
									p.isCollidingDown = true;
									p.vSpd = 0;
								}else if (p.vSpd != 0 && !p.isCollidingUp) {
									y = floor(y/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, 0, -1, collisionType_normal)) {
										y -= 8;
									}
									p.isCollidingUp = true;
									p.vSpd = 0;
								}
							}
						},
						notifyDiagCollision: function() {
							if (!hasCollided && !interface.isCollidingUp && !interface.isCollidingDown && !interface.isCollidingLeft && !interface.isCollidingRight) {
								var curInst = interface.instanceID;
								var p = interface;
								with (curInst) {
									if (p.hSpd > 0) {
										x = ceil(x/8)*8;
										while (!BlockCollisionGrid.checkCollisionInstance(self, 1, p.vSpd, collisionType_normal)) {
											x += 8;
										}
										p.isCollidingRight = true;
									}else {
										x = floor(x/8)*8;
										while (!BlockCollisionGrid.checkCollisionInstance(self, -1, p.vSpd, collisionType_normal)) {
											x -= 8;
										}
										p.isCollidingLeft = true;
									}
									p.hSpd = 0;
								}
							}
						},
						postExecution: function() {
							
						}
					},
					upPlatform: {
						interface: undefined,
						preExecution: function() {
							isInside = false;
						},
						notifyBaseCollision: function() {
							//isInside = true;
						},
						notifyHoriCollision: function() {
							
						},
						notifyVertCollision: function() {
							if (interface.checkVPlatforms && !isInside && !interface.isCollidingDown && interface.vSpd > 0) {
								var curInst = interface.instanceID;
								var p = interface;
								with (curInst) {
									y = ceil(y/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, 0, 1, collisionType_onewayUp)) {
										y += 8;
									}
									p.isCollidingDown = true;
									p.vSpd = 0;
								}
							}
						},
						notifyDiagCollision: function() {
							
						},
						postExecution: function() {
							
						}
					},
					leftPlatform: {
						interface: undefined,
						preExecution: function() {
							isInside = false;
						},
						notifyBaseCollision: function() {
							//isInside = true;
						},
						notifyHoriCollision: function() {
							if (interface.checkHPlatforms && !isInside && !interface.isCollidingRight && interface.hSpd > 0) {
								var curInst = interface.instanceID;
								var p = interface;
								with (curInst) {
									x = ceil(x/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, 1, 0, collisionType_onewayLeft)) {
										x += 8;
									}
									p.isCollidingRight = true;
									p.hSpd = 0;
								}
							}
						},
						notifyVertCollision: function() {
							
						},
						notifyDiagCollision: function() {
							
						},
						postExecution: function() {
							
						}
					},
					rightPlatform: {
						interface: undefined,
						preExecution: function() {
							isInside = false;
						},
						notifyBaseCollision: function() {
							//isInside = true;
						},
						notifyHoriCollision: function() {
							if (interface.checkHPlatforms && !isInside && !interface.isCollidingLeft && interface.hSpd < 0) {
								var curInst = interface.instanceID;
								var p = interface;
								with (curInst) {
									x = floor(x/8)*8;
									while (!BlockCollisionGrid.checkCollisionInstance(self, -1, 0, collisionType_onewayRight)) {
										x -= 8;
									}
									p.isCollidingLeft = true;
									p.hSpd = 0;
								}
							}
						},
						notifyVertCollision: function() {
							
						},
						notifyDiagCollision: function() {
							
						},
						postExecution: function() {
							
						}
					}
				},
				
				targetMaxHSpeedRequests: {
					hasPositive: false,
					positiveAdd: undefined,
					positiveMax: undefined,
					hasNegative: false,
					negativeAdd: undefined,
					negativeMax: undefined
				},
				
				targetHSpeedRequests: {
					hasValue: false,
					biggestMax: undefined,
					smallestMax: undefined,
					arrCap: 16,
					array: array_create(16),
					index: 0,
				}
			};
			newInterface.collisionEvents.generic.interface = newInterface;
			newInterface.collisionEvents.upPlatform.interface = newInterface;
			newInterface.collisionEvents.leftPlatform.interface = newInterface;
			newInterface.collisionEvents.rightPlatform.interface = newInterface;
			return newInterface;
		}
		
		#region Setting
		physicsInterface.setPosition = function(interfaceI, xI, yI) {
			interfaceI.instanceID.x = xI;
			interfaceI.instanceID.y = yI;
			InstanceCollisionGrid.instanceUpdateOccupyingCells(interfaceI.instanceID);
		}
		physicsInterface.setHSpeed = function(interfaceI, hSpdI) {
			interfaceI.hSpd = hSpdI;
			interfaceI.hasSettedH = true;
		}
		physicsInterface.setVSpeed = function(interfaceI, vSpdI) {
			interfaceI.vSpd = vSpdI;
			interfaceI.hasSettedV = true;
		}
		physicsInterface.setHAcceleration = function(interfaceI, hAccI) {
			interfaceI.hAcc = hAccI;
		}
		physicsInterface.setVAcceleration = function(interfaceI, vAccI) {
			interfaceI.vAcc = vAccI;
		}
		#endregion
		
		#region Adding
		physicsInterface.addPosition = function(interfaceI, xAddI, yAddI) {
			interfaceI.instanceID.x += xAddI;
			interfaceI.instanceID.y += yAddI;
			InstanceCollisionGrid.instanceUpdateOccupyingCells(interfaceI.instanceID);
		}
		physicsInterface.addHSpeed = function(interfaceI, hSpdAddI) {
			interfaceI.hSpd += hSpdAddI;
		}
		physicsInterface.addVSpeed = function(interfaceI, vSpdAddI) {
			interfaceI.vSpd += vSpdAddI;
		}
		physicsInterface.addHAcceleration = function(interfaceI, hAccAddI) {
			interfaceI.hAcc += hAccAddI;
		}
		physicsInterface.addVAcceleration = function(interfaceI, vAccAddI) {
			interfaceI.vAcc += vAccAddI;
		}
		#endregion
		
		#region Targetting
		physicsInterface.targetHSpeed = function(interfaceI, hSpdTargI, addI) {
			if_physics.addTargetRequest(interfaceI.targetHSpeedRequests, hSpdTargI, addI);
		}
		
		physicsInterface.targetMaxHSpeed = function(interfaceI, hSpdTargI, addI) {
			if_physics.addTargetMaxRequest(interfaceI.targetMaxHSpeedRequests, hSpdTargI, addI);
		}
		physicsInterface.targetMaxVSpeed = function(interfaceI, vSpdTargI, addI) {
			with (interfaceI) {
				if (abs(vSpd-vSpdTargI) <= addI) {
					vSpd = vSpdTargI;
				}else {
					vSpd += sign(vSpdTargI-vSpd)*addI;
				}
			}
		}
		physicsInterface.targetHAcceleration = function(interfaceI, hAccTargI, addI) {
			with (interfaceI) {
				if (abs(hAcc-hAccTargI) <= addI) {
					hAcc = hAccTargI;
				}else {
					hAcc += sign(hAccTargI-hAcc)*addI;
				}
			}
		}
		physicsInterface.targetVAcceleration = function(interfaceI, vAccTargI, addI) {
			with (interfaceI) {
				if (abs(vAcc-vAccTargI) <= addI) {
					vAcc = vAccTargI;
				}else {
					vAcc += sign(vAccTargI-vAcc)*addI;
				}
			}
		}
		
		// Private
		physicsInterface.addTargetMaxRequest = function(interfaceTargStructI, valueTargI, valueAddI) {
			if (valueTargI == 0) {
				return;
			}
			with (interfaceTargStructI) {
				if (valueTargI > 0) {
					if (!hasPositive) positiveAdd = 0;
					positiveAdd += valueAddI;
					if (!hasPositive || valueTargI > positiveMax) {
						positiveMax = valueTargI;
					}
					hasPositive = true;
				}else {
					if (!hasNegative) negativeAdd = 0;
					negativeAdd += valueAddI;
					if (!hasNegative || valueTargI < negativeMax) {
						negativeMax = valueTargI;
					}
					hasNegative = true;
				}
			}
		}
		physicsInterface.addTargetRequest = function(interfaceTargStructI, valueTargI, valueAddI) {
			with (interfaceTargStructI) {
				if (!hasValue) {
					smallestMax = valueTargI;
					biggestMax = valueTargI;
					hasValue = true;
				}else {
					if (valueTargI < smallestMax) {
						smallestMax = valueTargI;
					}else if (valueTargI > biggestMax) {
						biggestMax = valueTargI;
					}
				}
				interfaceTargStructI.array[interfaceTargStructI.index] = [valueTargI, valueAddI];
				interfaceTargStructI.index++;
				if (interfaceTargStructI.index == interfaceTargStructI.arrCap) {
					show_debug_message("if_physics.addTargetRequest function great observation!...");
					show_debug_message("The array capacity of a target request has reached its array capacity!...");
				}
			}
		}
		physicsInterface.applyTargetMaxHSpeedRequest = function(interfaceI) {
			var curRequests = interfaceI.targetMaxHSpeedRequests;
			if (interfaceI.hasSettedH) {
				curRequests.hasPositive = false;
				curRequests.positiveMax = undefined;
				curRequests.positiveAdd = undefined;
				curRequests.hasNegative = false;
				curRequests.negativeMax = undefined;
				curRequests.negativeAdd = undefined;
				return;
			}
			if (curRequests.hasPositive && interfaceI.hSpd < curRequests.positiveMax) {
				interfaceI.hSpd += curRequests.positiveAdd;
				if (curRequests.hasPositive && interfaceI.hSpd > curRequests.positiveMax) {
					interfaceI.hSpd = curRequests.positiveMax;
				}
			}
			if (curRequests.hasNegative && interfaceI.hSpd > curRequests.negativeMax) {
				interfaceI.hSpd -= curRequests.negativeAdd;
				if (curRequests.hasNegative && interfaceI.hSpd < curRequests.negativeMax) {
					interfaceI.hSpd = curRequests.negativeMax;
				}
			}
			curRequests.hasPositive = false;
			curRequests.positiveMax = undefined;
			curRequests.positiveAdd = undefined;
			curRequests.hasNegative = false;
			curRequests.negativeMax = undefined;
			curRequests.negativeAdd = undefined;
		}
		physicsInterface.applyTargetHSpeedRequest = function(interfaceI) {
			var curRequests = interfaceI.targetHSpeedRequests;
			if (interfaceI.hasSettedH) {
				curRequests.array = array_create(curRequests.arrCap);
				curRequests.index = 0;
				curRequests.smallestMax = undefined;
				curRequests.biggestMax = undefined;
				curRequests.hasValue = false;
				return;
			}
			var hasSmallMax = true;
			var hasBigMax = true;
			if (interfaceI.hSpd < curRequests.smallestMax) {
				hasSmallMax = false;
			}else if (interfaceI.hSpd > curRequests.biggestMax) {
				hasBigMax = false;
			}
			var doneRequests = array_create(curRequests.arrCap, false);
			var areRequestsDone = false;
			while (!areRequestsDone) {
				var hasNonNullSign = false;
				var hasNullSign = false;
				for (var i = 0; i < curRequests.index; i++) {
					if (!doneRequests[i]) {
						var curRequest = curRequests.array[i];
						var _sign = sign(curRequest[0] - interfaceI.hSpd);
						if (_sign != 0) {
							interfaceI.hSpd += _sign*curRequest[1];
							hasNonNullSign = true;
							doneRequests[i] = true;
						}else {
							hasNullSign = true;
						}
					}
				}
				if ((hasNullSign && !hasNonNullSign) || !hasNullSign) {
					areRequestsDone = true;
				}
			}
			if (hasSmallMax && interfaceI.hSpd < curRequests.smallestMax) {
				interfaceI.hSpd = curRequests.smallestMax;
			}else if (hasBigMax && interfaceI.hSpd > curRequests.biggestMax) {
				interfaceI.hSpd = curRequests.biggestMax;
			}
			
			curRequests.array = array_create(curRequests.arrCap);
			curRequests.index = 0;
			curRequests.smallestMax = undefined;
			curRequests.biggestMax = undefined;
			curRequests.hasValue = false;
		}
		#endregion
		
		#region Collisions
		physicsInterface.applyCollisionBlock = function(interfaceI, checkHPlatformsI, checkVPlatformsI) {
			interfaceI.isCollidingRight = false;
			interfaceI.isCollidingLeft = false;
			interfaceI.isCollidingUp = false;
			interfaceI.isCollidingDown = false;
			interfaceI.checkHPlatforms = checkHPlatformsI;
			interfaceI.checkVPlatforms = checkVPlatformsI;
			
			var p = interfaceI;
			
			interfaceI.collisionEvents.generic.preExecution();
			interfaceI.collisionEvents.upPlatform.preExecution();
			interfaceI.collisionEvents.leftPlatform.preExecution();
			interfaceI.collisionEvents.rightPlatform.preExecution();
			BlockCollisionGrid.executeCollisionEvents(
				interfaceI.instanceID,
				interfaceI.collisionEvents.generic,
				interfaceI.collisionEvents.upPlatform,
				interfaceI.collisionEvents.leftPlatform,
				interfaceI.collisionEvents.rightPlatform
			);
			if (BlockCollisionGrid.isPositionOutOfBounds())
			InstanceCollisionGrid.instanceUpdateOccupyingCells(interfaceI.instanceID);
			
		}
		#endregion
		
		#region Knockback
		
			#region Default knockbacks
			physicsInterface.setKnockback = function(interfaceI, hForceI, vForceI) {
				if_physics.setHSpeed(interfaceI, hForceI);
				if_physics.setVSpeed(interfaceI, vForceI);
			}
		
			physicsInterface.setHKnockback = function(interfaceI, hForceI) {
				if_physics.setHSpeed(interfaceI, hForceI);
			}
		
			physicsInterface.setVKnockback = function(interfaceI, vForceI) {
				if_physics.setVSpeed(interfaceI, vForceI);
			}
			#endregion
		
			#region Strong knockbacks
			physicsInterface.applyFloorStrongKnockback = function(interfaceI) {
				interfaceI.isStrongKnockbackedStack++;
				interfaceI.strongKnockbackFloor.isFirstFrame = true;
				interfaceI.strongKnockbackFloor.isActive = true;
				interfaceI.strongKnockbackStartExtra();
			}
			physicsInterface.applyTemporaryStrongKnockback = function(interfaceI, durationFramesI) {
				interfaceI.isStrongKnockbackedStack++;
				interfaceI.strongKnockbackTemp.framesCur = durationFramesI;
				interfaceI.strongKnockbackTemp.isActive = true;
				interfaceI.strongKnockbackStartExtra();
			}
			#endregion
		
		// PRIVATE
		physicsInterface.tickKnockback = function(interfaceI) {
			if (interfaceI.isStrongKnockbackedStack != 0) {
				if (interfaceI.strongKnockbackFloor.isActive && interfaceI.isCollidingDown) {
					if (interfaceI.strongKnockbackFloor.isFirstFrame) {
						interfaceI.strongKnockbackFloor.isFirstFrame = false;
					}else {
						interfaceI.strongKnockbackFloor.isActive = false;
						interfaceI.isStrongKnockbackedStack--;
					}
				}
				if (interfaceI.strongKnockbackTemp.isActive) {
					interfaceI.strongKnockbackTemp.framesCur--;
					if (interfaceI.strongKnockbackTemp.framesCur == 0) {
						interfaceI.strongKnockbackTemp.isActive = false;
						interfaceI.isStrongKnockbackedStack--;
					}
				}
				if (interfaceI.isStrongKnockbackedStack == 0) interfaceI.strongKnockbackEndExtra();
			}
		}
		#endregion
		
		#region Executions && Tickings
		
		physicsInterface.executeSpeeds = function(interfaceI) {
			if_physics.addPosition(interfaceI, interfaceI.hSpd, interfaceI.vSpd);
		}
		physicsInterface.executeAccelerations = function(interfaceI) {
			if_physics.addHSpeed(interfaceI, interfaceI.hAcc);
			if_physics.addVSpeed(interfaceI, interfaceI.vAcc);
		}
		physicsInterface.executeGravity = function(interfaceI) {
			if (interfaceI.doesGrv) if_physics.addVSpeed(interfaceI, interfaceI.grv);
		}
		physicsInterface.executeFriction = function(interfaceI) { // OBSERVATION001 - Add support of being over moving or pseudo-moving objects such as moving platforms and treadmills respectively.
			if (interfaceI.doesFriction) if_physics.targetHSpeed(interfaceI, 0, interfaceI.friction);
		}
		physicsInterface.executeAllTargetRequests = function(interfaceI) {
			//if (!interfaceI.hasSettedH) {
				if_physics.applyTargetHSpeedRequest(interfaceI);
				if_physics.applyTargetMaxHSpeedRequest(interfaceI);
			//}
			interfaceI.hasSettedH = false;
		}
		
		#endregion
		
		physicsInterface.tick = function(interfaceI) {
			if_physics.tickKnockback(interfaceI);
			if_physics.executeFriction(interfaceI);
			if_physics.executeGravity(interfaceI);
			if_physics.executeAccelerations(interfaceI);
			if_physics.executeAllTargetRequests(interfaceI);
			var curCollision = interfaceI.collision;
			if (curCollision.perms.any) if_physics.applyCollisionBlock(interfaceI,
				curCollision.perms.platform && curCollision.perms.hPlatform,
				curCollision.perms.platform && curCollision.perms.vPlatform
			);
			if_physics.executeSpeeds(interfaceI);
		}
		physicsInterface.tickAll = function() {
			var curInterfaces = ds_map_values_to_array(if_physics.map);
			for (var i = 0; i < array_length(curInterfaces); i++) {
				if (curInterfaces[i].isManaged) if_physics.tick(curInterfaces[i]);
			}
		}
		
		#endregion
		
		// Decoration interface
		decorationInterface = constructInterface();
		decorationInterface.construct = function(hasEnergyI, isPoweredI) {
			return {
				hasEnergy: hasEnergyI,
				isPowered: isPoweredI,
				powerOn: function() {
					
				},
				powerOff: function() {
					
				}
			}
		}
	},
	interfaceManager: {
		endStepEvent: function() {
			if_physics.tickAll();
		}
	},
	
	tileManager: {
		// Tile arrays are used to create tile maps when generating the stages.
		// Tile maps are the finished products which are used for rendering tiles during stages.
		
		tileMapArr: undefined,
		stageBuilding: {
			isReplacingCollision: false,
			collisionTile: undefined,
			
			replaceCollision: function(tileSetI) {
				isReplacingCollision = true;
				collisionTile = tileSetI;
			},
			replaceCollisionsApply: function() {
				if (isReplacingCollision) {
					for (var i = 0; i < instance_number(obj_collision); i++) {
						var curCol = instance_find(obj_collision, i);
						if (object_get_parent(curCol.object_index) != obj_collision)
							TileManager.type_default.setTileTypesByInstance(curCol, collisionTile, false);
					}
				}
			},
			
			isReplacingPlatforms: false,
			platformTile: undefined,
			replacePlatform: function(tileSetI) {
				isReplacingPlatforms = true;
				platformTile = tileSetI;
			},
			replacePlatformsApply: function() {
				if (isReplacingPlatforms) {
					for (var i = 0; i < instance_number(obj_collisionPlatform); i++) {
						var curCol = instance_find(obj_collisionPlatform, i);
						TileManager.type_platformDefault.setTileTypesByInstance(curCol, platformTile, 0, false);
					}
					for (var i = 0; i < instance_number(obj_collisionPlatformLeft); i++) {
						var curCol = instance_find(obj_collisionPlatformLeft, i);
						TileManager.type_platformDefault.setTileTypesByInstance(curCol, platformTile, 1, false);
					}
					for (var i = 0; i < instance_number(obj_collisionPlatformDown); i++) {
						var curCol = instance_find(obj_collisionPlatformDown, i);
						TileManager.type_platformDefault.setTileTypesByInstance(curCol, platformTile, 2, false);
					}
					for (var i = 0; i < instance_number(obj_collisionPlatformRight); i++) {
						var curCol = instance_find(obj_collisionPlatformRight, i);
						TileManager.type_platformDefault.setTileTypesByInstance(curCol, platformTile, 3, false);
					}
				}
			},
			setupForBuild: function() {
				isReplacingCollision = false;
				collisionTile = undefined;
				isReplacingPlatforms = false;
				platformTile = undefined;
			}
		},
		
		#region EVENTS
		stageStartEvent: function() {
			tileMap = StageManager.currentStage.initialGameplayBlueprint.tileMap;
		},
		stageEndEvent: function() {
			
		},
		drawBeginEvent: function() {
			drawTileMap(tileMap, tileMapIndexes.background);
			drawTileMap(tileMap, tileMapIndexes.back);
			drawTileMap(tileMap, tileMapIndexes.front);
		},
		drawEndEvent: function() {
			drawTileMap(tileMap, tileMapIndexes.camouflage);
		},
		#endregion
		
		#region Tile map creation
		curTileArr: undefined,
		assignTileMapToGameplayBlueprint: function(gameplayBlueprintI, roomWidthI, roomHeightI) {
			var curW = ceil(roomWidthI/TileMng_defTileSize);
			var curH = ceil(roomHeightI/TileMng_defTileSize);
			
			var tileMap = array_create(curW);
			for (var i = 0; i < curW; i++) {
				tileMap[i] = array_create(curH);
				for (var j = 0; j < curH; j++) {
					tileMap[i][j] = array_create(tileMapAmount, undefined);
				}
			}
			gameplayBlueprintI.tileMap = tileMap;
		},
		constructTileSetFromTileMap: function(tileMapI) {
			var tileArr = array_create(array_length(tileMapI));
			for (var i = 0; i < array_length(tileMapI); i++) {
				tileArr[i] = array_create(array_length(tileMapI[0]));
				for (var j = 0; j < array_length(tileMapI[0]); j++) {
					tileArr[i][j] = array_create(tileMapAmount, undefined);
				}
			}
			return tileArr;
		},
		defineTileMapFromTileArr: function(tileMapI, tileArrI) {
			for (var i = 0; i < array_length(tileArrI); i++) {
				var curRow = tileArrI[i];
				for (var j = 0; j < array_length(curRow); j++) {
					for (var r = 0; r < tileMapAmount; r++) {
						var curTile = curRow[j][r];
						if (curTile != undefined) { // OBSERVATION_LOCAL - It's extending the tilemap unnecessarily since there are 0s. Fix that and the problem is likely solved.
							tileMapI[i][j][r] = curTile.tileSet.type.constructTileFromBlueprint(curTile.tileSet, tileArrI, i, j);
						}
					}
				}
			}
		},
		#endregion
		
		#region Loading
		drawTileMap: function(tileMapI, tileMapIndexI) {
			var camX1 = floor(CameraManager.curX/TileMng_defTileSize);
			var camY1 = floor(CameraManager.curY/TileMng_defTileSize);
			var camX2 = ceil((CameraManager.curX+gameResolutionWidth)/TileMng_defTileSize);
			var camY2 = ceil((CameraManager.curY+gameResolutionHeight)/TileMng_defTileSize);
			var mapW = array_length(tileMapI);
			var mapH = array_length(tileMapI[0]);
			for (var i = camX1; i < camX2; i++) {
				for (var j = camY1; j < camY2; j++) {
					var curTile = tileMapI[i][j][tileMapIndexI];
					if (curTile != undefined) {
						curTile.tileSet.type.drawTile(curTile, i, j);
					}
				}
			}
		},
		#endregion
		
		#region Types
		tileSet_metal: undefined,
		tileSet_metalPlatform: undefined,
		tileSet_metalTop: undefined,
		initializeTileSets: function() {
			tileSet_metal = type_default.construct(tileSpr_metal2, tileMapIndexes.front);
			tileSet_metalPlatform = type_platformDefault.construct(tileSpr_platform1, tileMapIndexes.front);
			tileSet_metalTop = type_horizontalCyclic.construct(tileSpr_metalTop1, tileMapIndexes.front, 4);
			tileSet_metalBack = type_defaultThick.construct(tileSpr_metalBack1, tileMapIndexes.back);
			tileSet_metalBackground = type_plainBigger.construct(tileSpr_metalBackground, tileMapIndexes.background);
			tileSet_metalBackgroundTunnel = type_line.construct(tileSpr_metalBackgroundTunnel, tileMapIndexes.background);
			tileSet_glassBackground = type_default.construct(tileSpr_glassBackground, tileMapIndexes.background, false);
		},
		
		type_default: {
			constructTileBlueprint: function(tileSetI) { // Only for stage building from room.
				return {
					tileSet: tileSetI
				}
			},
			constructTile: function(tileSetI, sprIndexI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex));
			},
			drawTile: function(tileI, xI, yI) {
				draw_sprite(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
			},
			construct: function(baseSprI, tileMapIndexI, connectsWithOtherTileSetsI = true) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tilePerRow = 10;
				var j = 0;
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < type_defaultType_tileAmount; i++) {
					var iMod = i%tilePerRow;
					if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
						sprSurf, iMod*tileSize, j*tileSize, tileSize, tileSize,
						false, false, 0, 0
					);
					else sprite_add_from_surface(
						tileSetSpr, sprSurf, i%tilePerRow*tileSize, j*tileSize, tileSize, tileSize,
						false, false
					);
					
					if (iMod == tilePerRow-1) {
						j++;
					}
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_default,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr,
					connectsWithOtherTileSets: connectsWithOtherTileSetsI
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				var curTile = tileArrI[xI][yI][tileMapIndexI];
				
				// Connects to stage boundaries
				var curAdj = array_create(8, false);
				if (yI-1 < 0) curAdj[0] = true;
				if (yI-1 < 0 || xI+1 >= w) curAdj[1] = true;
				if (xI+1 >= w) curAdj[2] = true;
				if (xI+1 >= w || yI+1 >= h) curAdj[3] = true;
				if (yI+1 >= h) curAdj[4] = true;
				if (yI+1 >= h || xI-1 < 0) curAdj[5] = true;
				if (xI-1 < 0) curAdj[6] = true;
				if (xI-1 < 0 || yI-1 < 0) curAdj[7] = true;
				
				// Connects to other tiles
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined && tileArrI[xI][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI][yI-1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[0] = true;
				}
				if (!curAdj[1] && (yI-1 >= 0 && xI+1 < w) && tileArrI[xI+1][yI-1][tileMapIndexI] != undefined && tileArrI[xI+1][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI+1][yI-1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[1] = true;
				}
				if (!curAdj[2] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined && tileArrI[xI+1][yI][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI+1][yI][tileMapIndexI].tileSet == curTile.tileSet) curAdj[2] = true;
				}
				if (!curAdj[3] && (xI+1 < w && yI+1 < h) && tileArrI[xI+1][yI+1][tileMapIndexI] != undefined && tileArrI[xI+1][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI+1][yI+1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[3] = true;
				}
				if (!curAdj[4] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined && tileArrI[xI][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI][yI+1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[4] = true;
				}
				if (!curAdj[5] && (yI+1 < h && xI-1 >= 0) && tileArrI[xI-1][yI+1][tileMapIndexI] != undefined && tileArrI[xI-1][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI-1][yI+1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[5] = true;
				}
				if (!curAdj[6] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined && tileArrI[xI-1][yI][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI-1][yI][tileMapIndexI].tileSet == curTile.tileSet) curAdj[6] = true;
				}
				if (!curAdj[7] && (xI-1 >= 0 && yI-1 >= 0) && tileArrI[xI-1][yI-1][tileMapIndexI] != undefined && tileArrI[xI-1][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					if (curTile.tileSet.connectsWithOtherTileSets || !curTile.tileSet.connectsWithOtherTileSets && tileArrI[xI-1][yI-1][tileMapIndexI].tileSet == curTile.tileSet) curAdj[7] = true;
				}
				
				/*
				How the adjacency list works:
				7 0 1
				6   2
				5 4 3
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				var adjAmount = 0;
				for (var r = 0; r < 4; r++) {
					adjAmount += curAdj[r*2];
				}
				for (var r = 0; r < 4; r++) {
					if (curAdj[r*2+1]) {
						var hasLaterals = curAdj[r*2] && curAdj[(r*2+2)%8];
						adjAmount += hasLaterals;
					}
				}
				if (adjAmount == 8) {
					return type_defaultType_sprIndex.center;
				}else if (adjAmount == 7) {
					if (!curAdj[1]) return type_defaultType_sprIndex.innerCornerRightUp;
					else if (!curAdj[3]) return type_defaultType_sprIndex.innerCornerRightDown;
					else if (!curAdj[5]) return type_defaultType_sprIndex.innerCornerLeftDown;
					else if (!curAdj[7]) return type_defaultType_sprIndex.innerCornerLeftUp;
				}else if (adjAmount == 6) {
					if (!curAdj[1] && !curAdj[3]) return type_defaultType_sprIndex.borderTLeft;
					else if (!curAdj[3] && !curAdj[5]) return type_defaultType_sprIndex.borderTDown;
					else if (!curAdj[5] && !curAdj[7]) return type_defaultType_sprIndex.borderTRight;
					else if (!curAdj[7] && !curAdj[1]) return type_defaultType_sprIndex.borderTUp;
				}else if (adjAmount == 5) {
					// Borders
					if (!curAdj[0]) return type_defaultType_sprIndex.borderUp;
					else if (!curAdj[2]) return type_defaultType_sprIndex.borderRight;
					else if (!curAdj[4]) return type_defaultType_sprIndex.borderDown;
					else if (!curAdj[6]) return type_defaultType_sprIndex.borderLeft;
					// Corners
					else if (curAdj[1]) return type_defaultType_sprIndex.thinCrossButRightUp;
					else if (curAdj[3]) return type_defaultType_sprIndex.thinCrossButRightDown;
					else if (curAdj[5]) return type_defaultType_sprIndex.thinCrossButLeftDown;
					else if (curAdj[7]) return type_defaultType_sprIndex.thinCrossButLeftUp;
				}else if (adjAmount == 4) {
					if (!curAdj[1] && !curAdj[3] && !curAdj[5] && !curAdj[7]) return type_defaultType_sprIndex.thinCross;
					else {
						if (curAdj[0] && curAdj[1] && curAdj[2]) {
							if (!curAdj[4]) return type_defaultType_sprIndex.outerCornerTLeftDown;
							if (!curAdj[6]) return type_defaultType_sprIndex.outerCornerLeftTDown;
						}else if (curAdj[2] && curAdj[3] && curAdj[4]) {
							if (!curAdj[6]) return type_defaultType_sprIndex.outerCornerLeftTUp;
							if (!curAdj[0]) return type_defaultType_sprIndex.outerCornerTLeftUp;
						}else if (curAdj[4] && curAdj[5] && curAdj[6]) {
							if (!curAdj[0]) return type_defaultType_sprIndex.outerCornerTRightUp;
							if (!curAdj[2]) return type_defaultType_sprIndex.outerCornerRightTUp;
						}else if (curAdj[6] && curAdj[7] && curAdj[0]) {
							if (!curAdj[2]) return type_defaultType_sprIndex.outerCornerRightTDown;
							if (!curAdj[4]) return type_defaultType_sprIndex.outerCornerTRightDown;
						}
					}
				}else if (adjAmount == 3) {
					if (!curAdj[4] && !curAdj[6]) return type_defaultType_sprIndex.outerCornerLeftDown;
					else if (!curAdj[6] && !curAdj[0]) return type_defaultType_sprIndex.outerCornerLeftUp;
					else if (!curAdj[0] && !curAdj[2]) return type_defaultType_sprIndex.outerCornerRightUp;
					else if (!curAdj[2] && !curAdj[4]) return type_defaultType_sprIndex.outerCornerRightDown;
					else if (curAdj[0] && curAdj[4]) {
						if (curAdj[2]) return type_defaultType_sprIndex.TRight;
						else return type_defaultType_sprIndex.TLeft;
					}else if (curAdj[2] && curAdj[6]) {
						if (curAdj[0]) return type_defaultType_sprIndex.TUp;
						else return type_defaultType_sprIndex.TDown;
					}
				}else if (adjAmount == 2) {
					if (curAdj[0]) {
						if (curAdj[2]) return type_defaultType_sprIndex.thinCornerRightUp;
						else if (curAdj[4]) return type_defaultType_sprIndex.thinVertical;
						else if (curAdj[6]) return type_defaultType_sprIndex.thinCornerLeftUp;
					}else if (curAdj[2]) {
						if (curAdj[4]) return type_defaultType_sprIndex.thinCornerRightDown;
						else if (curAdj[6]) return type_defaultType_sprIndex.thinHorizontal;
					}else if (curAdj[4]) {
						if (curAdj[6]) return type_defaultType_sprIndex.thinCornerLeftDown;
					}
				}else if (adjAmount == 1) {
					if (curAdj[0]) return type_defaultType_sprIndex.thinUp;
					else if (curAdj[2]) return type_defaultType_sprIndex.thinRight;
					else if (curAdj[4]) return type_defaultType_sprIndex.thinDown;
					else if (curAdj[6]) return type_defaultType_sprIndex.thinLeft;
				}
				return type_defaultType_sprIndex.single;
			},
			setTileTypesByInstance: function(instI, tileSetI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI);
					}
				}
			}
		},
		type_defaultThick: {
			constructTileBlueprint: function(tileSetI) { // Only for stage building from room.
				return {
					tileSet: tileSetI
				}
			},
			constructTile: function(tileSetI, sprIndexI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex));
			},
			drawTile: function(tileI, xI, yI) {
				draw_sprite(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
			},
			construct: function(baseSprI, tileMapIndexI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tilePerRow = 4;
				var j = 0;
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < type_defaultThickType_tileAmount; i++) {
					var iMod = i%tilePerRow;
					if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
						sprSurf, iMod*tileSize, j*tileSize, tileSize, tileSize,
						false, false, 0, 0
					);
					else sprite_add_from_surface(
						tileSetSpr, sprSurf, i%tilePerRow*tileSize, j*tileSize, tileSize, tileSize,
						false, false
					);
					
					if (iMod == tilePerRow-1) {
						j++;
					}
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_defaultThick,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				
				// Connects to stage boundaries
				var curAdj = array_create(8, false);
				if (yI-1 < 0) curAdj[0] = true;
				if (yI-1 < 0 || xI+1 >= w) curAdj[1] = true;
				if (xI+1 >= w) curAdj[2] = true;
				if (xI+1 >= w || yI+1 >= h) curAdj[3] = true;
				if (yI+1 >= h) curAdj[4] = true;
				if (yI+1 >= h || xI-1 < 0) curAdj[5] = true;
				if (xI-1 < 0) curAdj[6] = true;
				if (xI-1 < 0 || yI-1 < 0) curAdj[7] = true;
				
				// Connects to other tiles
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined && tileArrI[xI][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					curAdj[0] = true;
				}
				if (!curAdj[1] && (yI-1 >= 0 && xI+1 < w) && tileArrI[xI+1][yI-1][tileMapIndexI] != undefined && tileArrI[xI+1][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[1] = true;
				}
				if (!curAdj[2] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined && tileArrI[xI+1][yI][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[2] = true;
				}
				if (!curAdj[3] && (xI+1 < w && yI+1 < h) && tileArrI[xI+1][yI+1][tileMapIndexI] != undefined && tileArrI[xI+1][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[3] = true;
				}
				if (!curAdj[4] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined && tileArrI[xI][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[4] = true;
				}
				if (!curAdj[5] && (yI+1 < h && xI-1 >= 0) && tileArrI[xI-1][yI+1][tileMapIndexI] != undefined && tileArrI[xI-1][yI+1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[5] = true;
				}
				if (!curAdj[6] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined && tileArrI[xI-1][yI][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[6] = true;
				}
				if (!curAdj[7] && (xI-1 >= 0 && yI-1 >= 0) && tileArrI[xI-1][yI-1][tileMapIndexI] != undefined && tileArrI[xI-1][yI-1][tileMapIndexI].tileSet.type != TileManager.type_platformDefault) {
					curAdj[7] = true;
				}
				
				/*
				How the adjacency list works:
				7 0 1
				6   2
				5 4 3
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				var adjAmount = 0;
				for (var r = 0; r < 4; r++) {
					adjAmount += curAdj[r*2];
				}
				for (var r = 0; r < 4; r++) {
					if (curAdj[r*2+1]) {
						var hasLaterals = curAdj[r*2] && curAdj[(r*2+2)%8];
						adjAmount += hasLaterals;
					}
				}
				if (adjAmount == 8) {
					return type_defaultThickType_sprIndex.center;
				}else if (adjAmount == 7) {
					if (!curAdj[1]) return type_defaultThickType_sprIndex.innerCornerRightUp;
					else if (!curAdj[3]) return type_defaultThickType_sprIndex.innerCornerRightDown;
					else if (!curAdj[5]) return type_defaultThickType_sprIndex.innerCornerLeftDown;
					else if (!curAdj[7]) return type_defaultThickType_sprIndex.innerCornerLeftUp;
				}else if (adjAmount == 5) {
					// Borders
					if (!curAdj[0]) return type_defaultThickType_sprIndex.borderUp;
					else if (!curAdj[2]) return type_defaultThickType_sprIndex.borderRight;
					else if (!curAdj[4]) return type_defaultThickType_sprIndex.borderDown;
					else if (!curAdj[6]) return type_defaultThickType_sprIndex.borderLeft;
				}else if (adjAmount == 3) {
					if (!curAdj[4] && !curAdj[6]) return type_defaultThickType_sprIndex.outerCornerLeftDown;
					else if (!curAdj[6] && !curAdj[0]) return type_defaultThickType_sprIndex.outerCornerLeftUp;
					else if (!curAdj[0] && !curAdj[2]) return type_defaultThickType_sprIndex.outerCornerRightUp;
					else if (!curAdj[2] && !curAdj[4]) return type_defaultThickType_sprIndex.outerCornerRightDown;
				}else {
					show_debug_message("TILESET_ERROR!!!");
					show_debug_message("A tileset of type type_defaultThick has not been setup correctly!!!");
				}
			},
			setTileTypesByInstance: function(instI, tileSetI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI);
					}
				}
			}
		},
		type_platformDefault: {
			constructTileBlueprint: function(tileSetI, directionI) { // Only for stage building from room.
				return {
					tileSet: tileSetI,
					direction: directionI
				}
			},
			constructTile: function(tileSetI, sprIndexI, directionI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI,
					direction: directionI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex), tileArrI[xI][yI][tileSetI.tileMapIndex].direction);
			},
			drawTile: function(tileI, xI, yI) {
				if (tileI.direction == 0)
					draw_sprite(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
				else if (tileI.direction == 1)
					draw_sprite_ext(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, (yI+1)*TileMng_defTileSize, 1.0, 1.0, 90, c_white, 1.0);
				else if (tileI.direction == 2)
					draw_sprite_ext(tileI.tileSet.tileSprites, tileI.sprIndex, (xI+1)*TileMng_defTileSize, (yI+1)*TileMng_defTileSize, 1.0, 1.0, 180, c_white, 1.0);
				else
					draw_sprite_ext(tileI.tileSet.tileSprites, tileI.sprIndex, (xI+1)*TileMng_defTileSize, yI*TileMng_defTileSize, 1.0, 1.0, 270, c_white, 1.0);
			},
			construct: function(baseSprI, tileMapIndexI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < type_defaultPlatformType_tileAmount; i++) {
					if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
						sprSurf, i*tileSize, 0, tileSize, tileSize,
						false, false, 0, 0
					);
					else sprite_add_from_surface(
						tileSetSpr, sprSurf, i*tileSize, 0, tileSize, tileSize,
						false, false
					);
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_platformDefault,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				
				// Connects to stage boundaries
				var curAdj = array_create(8, false);
				if (yI-1 < 0) curAdj[0] = true;
				if (xI+1 >= w) curAdj[1] = true;
				if (yI+1 >= h) curAdj[2] = true;
				if (xI-1 < 0) curAdj[3] = true;
				
				// Connects to other tiles
				var platformAdjID = 1; // The identifier for platform adjacency.
				var nonPlatformAdjID = 2; // The identifier for non-platform adjacency.
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					curAdj[0] = (tileArrI[xI][yI-1][tileMapIndexI].tileSet.type == TileManager.type_platformDefault) ? platformAdjID : nonPlatformAdjID;
				}
				if (!curAdj[1] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined) {
					curAdj[1] = (tileArrI[xI+1][yI][tileMapIndexI].tileSet.type == TileManager.type_platformDefault) ? platformAdjID : nonPlatformAdjID;
				}
				if (!curAdj[2] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined) {
					curAdj[2] = (tileArrI[xI][yI+1][tileMapIndexI].tileSet.type == TileManager.type_platformDefault) ? platformAdjID : nonPlatformAdjID;
				}
				if (!curAdj[3] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined) {
					curAdj[3] = (tileArrI[xI-1][yI][tileMapIndexI].tileSet.type == TileManager.type_platformDefault) ? platformAdjID : nonPlatformAdjID;
				}
				
				/*
				How the adjacency list works:
				  0
				3   1
				  2
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				var curTileDir = tileArrI[xI][yI][tileMapIndexI].direction;
				if (curTileDir == 0) {
					if (curAdj[3] == nonPlatformAdjID && curAdj[1] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderAll;
					else if (curAdj[3] == platformAdjID && curAdj[1] == platformAdjID)
						return type_defaultPlatformType_sprIndex.middle;
					else if (curAdj[3] == 0 && curAdj[1] == 0)
						return type_defaultPlatformType_sprIndex.endAll;
					else if (curAdj[3] == nonPlatformAdjID && curAdj[1] == platformAdjID)
						return type_defaultPlatformType_sprIndex.borderLeft;
					else if (curAdj[3] == platformAdjID && curAdj[1] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRight;
					else if (curAdj[3] == nonPlatformAdjID && curAdj[1] == 0)
						return type_defaultPlatformType_sprIndex.borderLeftEnd;
					else if (curAdj[3] == 0 && curAdj[1] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRightEnd;
					else if (curAdj[3] == 0 && curAdj[1] == platformAdjID)
						return type_defaultPlatformType_sprIndex.endLeft;
					else if (curAdj[3] == platformAdjID && curAdj[1] == 0)
						return type_defaultPlatformType_sprIndex.endRight;
				}else if (curTileDir == 1) {
					if (curAdj[2] == nonPlatformAdjID && curAdj[0] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderAll;
					else if (curAdj[2] == platformAdjID && curAdj[0] == platformAdjID)
						return type_defaultPlatformType_sprIndex.middle;
					else if (curAdj[2] == 0 && curAdj[0] == 0)
						return type_defaultPlatformType_sprIndex.endAll;
					else if (curAdj[2] == nonPlatformAdjID && curAdj[0] == platformAdjID)
						return type_defaultPlatformType_sprIndex.borderLeft;
					else if (curAdj[2] == platformAdjID && curAdj[0] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRight;
					else if (curAdj[2] == nonPlatformAdjID && curAdj[0] == 0)
						return type_defaultPlatformType_sprIndex.borderLeftEnd;
					else if (curAdj[2] == 0 && curAdj[0] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRightEnd;
					else if (curAdj[2] == 0 && curAdj[0] == platformAdjID)
						return type_defaultPlatformType_sprIndex.endLeft;
					else if (curAdj[2] == platformAdjID && curAdj[0] == 0)
						return type_defaultPlatformType_sprIndex.endRight;
				}else if (curTileDir == 2) {
					if (curAdj[1] == nonPlatformAdjID && curAdj[3] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderAll;
					else if (curAdj[1] == platformAdjID && curAdj[3] == platformAdjID)
						return type_defaultPlatformType_sprIndex.middle;
					else if (curAdj[1] == 0 && curAdj[3] == 0)
						return type_defaultPlatformType_sprIndex.endAll;
					else if (curAdj[1] == nonPlatformAdjID && curAdj[3] == platformAdjID)
						return type_defaultPlatformType_sprIndex.borderLeft;
					else if (curAdj[1] == platformAdjID && curAdj[3] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRight;
					else if (curAdj[1] == nonPlatformAdjID && curAdj[3] == 0)
						return type_defaultPlatformType_sprIndex.borderLeftEnd;
					else if (curAdj[1] == 0 && curAdj[3] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRightEnd;
					else if (curAdj[1] == 0 && curAdj[3] == platformAdjID)
						return type_defaultPlatformType_sprIndex.endLeft;
					else if (curAdj[1] == platformAdjID && curAdj[3] == 0)
						return type_defaultPlatformType_sprIndex.endRight;
				}else {
					if (curAdj[0] == nonPlatformAdjID && curAdj[2] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderAll;
					else if (curAdj[0] == platformAdjID && curAdj[2] == platformAdjID)
						return type_defaultPlatformType_sprIndex.middle;
					else if (curAdj[0] == 0 && curAdj[2] == 0)
						return type_defaultPlatformType_sprIndex.endAll;
					else if (curAdj[0] == nonPlatformAdjID && curAdj[2] == platformAdjID)
						return type_defaultPlatformType_sprIndex.borderLeft;
					else if (curAdj[0] == platformAdjID && curAdj[2] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRight;
					else if (curAdj[0] == nonPlatformAdjID && curAdj[2] == 0)
						return type_defaultPlatformType_sprIndex.borderLeftEnd;
					else if (curAdj[0] == 0 && curAdj[2] == nonPlatformAdjID)
						return type_defaultPlatformType_sprIndex.borderRightEnd;
					else if (curAdj[0] == 0 && curAdj[2] == platformAdjID)
						return type_defaultPlatformType_sprIndex.endLeft;
					else if (curAdj[0] == platformAdjID && curAdj[2] == 0)
						return type_defaultPlatformType_sprIndex.endRight;
				}
				
			},
			setTileTypesByInstance: function(instI, tileSetI, directionI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI, directionI);
					}
				}
			}
		},
		type_horizontalCyclic: {
			constructTileBlueprint: function(tileSetI) { // Only for stage building from room.
				return {
					tileSet: tileSetI,
					cycleIndex: undefined
				}
			},
			constructTile: function(tileSetI, sprIndexI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex));
			},
			drawTile: function(tileI, xI, yI) {
				draw_sprite(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
			},
			construct: function(baseSprI, tileMapIndexI, cycleSizeI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tilePerRow = cycleSizeI;
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < type_horizontalCyclic_tileAmountPerCycle; i++) {
					for (var j = 0; j < tilePerRow; j++) {
						if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
							sprSurf, j*tileSize, i*tileSize, tileSize, tileSize,
							false, false, 0, 0
						);
						else sprite_add_from_surface(
							tileSetSpr, sprSurf, j*tileSize, i*tileSize, tileSize, tileSize,
							false, false
						);
					}
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_horizontalCyclic,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr,
					cycleSize: cycleSizeI
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				var curTile = tileArrI[xI][yI][tileMapIndexI];
				
				// Connects to stage boundaries
				var curAdj = array_create(4, false);
				if (yI-1 < 0) curAdj[0] = true;
				if (xI+1 >= w) curAdj[1] = true;
				if (yI+1 >= h) curAdj[2] = true;
				if (xI-1 < 0) curAdj[3] = true;
				
				// Connects to other tiles
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined && tileArrI[xI][yI-1][tileMapIndexI].tileSet == curTile.tileSet) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					curAdj[0] = true;
				}
				if (!curAdj[1] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined && tileArrI[xI+1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[1] = true;
				}
				if (!curAdj[2] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined && tileArrI[xI][yI+1][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[2] = true;
				}
				if (!curAdj[3] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined && tileArrI[xI-1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[3] = true;
				}
				
				/*
				How the adjacency list works:
				  0
				3   1
				  2
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				if (curAdj[3] && curAdj[1]) {
					var curCycleIndex = (xI-1 >= 0) ? ((tileArrI[xI-1][yI][tileMapIndexI].cycleIndex+1)%(curTile.tileSet.cycleSize-1)) : irandom(curTile.tileSet.cycleSize-2);
					curTile.cycleIndex = curCycleIndex;
					return curTile.tileSet.cycleSize*type_horizontalCyclic_rowRoles.middle+curCycleIndex;
				}else if (curAdj[3]) {
					var curCycleIndex = (xI-1 >= 0) ? ((tileArrI[xI-1][yI][tileMapIndexI].cycleIndex+1)%(curTile.tileSet.cycleSize-1)) : irandom(curTile.tileSet.cycleSize-2);
					curTile.cycleIndex = curCycleIndex;
					return curTile.tileSet.cycleSize*type_horizontalCyclic_rowRoles.borderRight+curCycleIndex;
				}else if (curAdj[1]) {
					var curCycleIndex = irandom(curTile.tileSet.cycleSize-2);
					curTile.cycleIndex = curCycleIndex;
					return curTile.tileSet.cycleSize*type_horizontalCyclic_rowRoles.borderLeft+curCycleIndex;
				}else {
					var curCycleIndex = irandom(curTile.tileSet.cycleSize-2);
					curTile.cycleIndex = curCycleIndex;
					return curTile.tileSet.cycleSize*type_horizontalCyclic_rowRoles.borderAll+curCycleIndex;
				}
			},
			setTileTypesByInstance: function(instI, tileSetI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI);
					}
				}
			}
		},
		type_plain: {
			constructTileBlueprint: function(tileSetI) { // Only for stage building from room.
				return {
					tileSet: tileSetI
				}
			},
			constructTile: function(tileSetI) {
				return {
					tileSet: tileSetI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI);
			},
			drawTile: function(tileI, xI, yI) {
				draw_sprite(tileI.tileSet.tileSprites, 0, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
			},
			construct: function(baseSprI, tileMapIndexI, cycleSizeI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tileSize = TileMng_defTileSize;
				tileSetSpr = sprite_create_from_surface(
					sprSurf, 0, 0, tileSize, tileSize,
					false, false, 0, 0
				);
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_plain,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr
				}
			},
			setTileTypesByInstance: function(instI, tileSetI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI);
					}
				}
			}
		},
		type_plainBigger: {
			constructTileBlueprint: function(tileSetI) { // Only for stage building from room.
				return {
					tileSet: tileSetI,
					cycleIndex: undefined
				}
			},
			constructTile: function(tileSetI, sprIndexI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex));
			},
			drawTile: function(tileI, xI, yI) {
				draw_sprite(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize);
			},
			construct: function(baseSprI, tileMapIndexI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tilePerRow = sprWidth/TileMng_defTileSize;
				var tilePerColumn = sprHeight/TileMng_defTileSize;
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < tilePerColumn; i++) {
					for (var j = 0; j < tilePerRow; j++) {
						if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
							sprSurf, j*tileSize, i*tileSize, tileSize, tileSize,
							false, false, 0, 0
						);
						else sprite_add_from_surface(
							tileSetSpr, sprSurf, j*tileSize, i*tileSize, tileSize, tileSize,
							false, false
						);
					}
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_plainBigger,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr,
					cycleWidth: tilePerRow,
					cycleHeight: tilePerColumn
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var curTile = tileArrI[xI][yI][tileMapIndexI];
				var curTileSet = curTile.tileSet;
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				
				// Connects to other tiles
				var curAdj = array_create(4, false);
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined && tileArrI[xI][yI-1][tileMapIndexI].tileSet == curTile.tileSet) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					curAdj[0] = true;
				}
				if (!curAdj[1] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined && tileArrI[xI+1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[1] = true;
				}
				if (!curAdj[2] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined && tileArrI[xI][yI+1][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[2] = true;
				}
				if (!curAdj[3] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined && tileArrI[xI-1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[3] = true;
				}
				
				/*
				How the adjacency list works:
				  0
				3   1
				  2
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				if (curAdj[3]) {
					var adjTileCycleIndex = tileArrI[xI-1][yI][tileMapIndexI].cycleIndex;
					var adjTileCycleIndexModule = adjTileCycleIndex%curTileSet.cycleWidth;
					var curCycleIndex = (adjTileCycleIndex-adjTileCycleIndexModule)+((adjTileCycleIndex+1)%curTileSet.cycleWidth);
					curTile.cycleIndex = curCycleIndex;
					return curCycleIndex;
				}else if (curAdj[0]) {
					var adjTileCycleIndex = tileArrI[xI][yI-1][tileMapIndexI].cycleIndex;
					var adjTileCycleIndexModule = adjTileCycleIndex%curTileSet.cycleWidth;
					var curCycleIndex = ((floor(adjTileCycleIndex/curTileSet.cycleWidth)+1)%curTileSet.cycleHeight)*curTileSet.cycleWidth+adjTileCycleIndexModule;
					curTile.cycleIndex = curCycleIndex;
					return curCycleIndex;
				}else {
					curTile.cycleIndex = 0;
					return 0;
				}
			},
			setTileTypesByInstance: function(instI, tileSetI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI);
					}
				}
			}
		},
		type_line: {
			constructTileBlueprint: function(tileSetI, directionI) { // Only for stage building from room.
				return {
					tileSet: tileSetI,
					direction: directionI
				}
			},
			constructTile: function(tileSetI, sprIndexI, directionI) {
				return {
					tileSet: tileSetI,
					sprIndex: sprIndexI,
					direction: directionI
				}
			},
			constructTileFromBlueprint: function(tileSetI, tileArrI, xI, yI) {
				return constructTile(tileSetI, returnTileSprIndex(tileArrI, xI, yI, tileSetI.tileMapIndex), tileArrI[xI][yI][tileSetI.tileMapIndex].direction);
			},
			drawTile: function(tileI, xI, yI) { // RIGHT_NOW - Fix this fucking thing not being rendered right. 
				draw_sprite_ext(tileI.tileSet.tileSprites, tileI.sprIndex, xI*TileMng_defTileSize, yI*TileMng_defTileSize+tileI.direction*TileMng_defTileSize, 1.0, 1.0, tileI.direction*90, c_white, 1.0);
			},
			construct: function(baseSprI, tileMapIndexI) {
				var sprWidth = sprite_get_width(baseSprI)*2;
				var sprHeight = sprite_get_height(baseSprI)*2;
				
				var tileSetSpr = undefined;
				var sprSurf = surface_create(sprWidth, sprHeight);
				
				surface_set_target(sprSurf);
				draw_sprite_ext(baseSprI, 0, 0, 0, 2.0, 2.0, 0, c_white, 1.0);
				surface_reset_target();
				
				var tileSize = TileMng_defTileSize;
				for (var i = 0; i < type_line_tileAmount; i++) {
					if (tileSetSpr == undefined) tileSetSpr = sprite_create_from_surface(
						sprSurf, i*tileSize, 0, tileSize, tileSize,
						false, false, 0, 0
					);
					else sprite_add_from_surface(
						tileSetSpr, sprSurf, i*tileSize, 0, tileSize, tileSize,
						false, false
					);
				}
				
				surface_free(sprSurf);
				
				return {
					type: TileManager.type_line,
					tileMapIndex: tileMapIndexI,
					tileSprites: tileSetSpr
				}
			},
			returnTileSprIndex: function(tileArrI, xI, yI, tileMapIndexI) {
				var w = array_length(tileArrI);
				var h = array_length(tileArrI[0]);
				var curTile = tileArrI[xI][yI][tileMapIndexI];
				
				// Connects to stage boundaries
				var curAdj = array_create(4, false);
				if (yI-1 < 0) curAdj[0] = true;
				if (xI+1 >= w) curAdj[1] = true;
				if (yI+1 >= h) curAdj[2] = true;
				if (xI-1 < 0) curAdj[3] = true;
				
				// Connects to other tiles
				if (!curAdj[0] && (yI-1 >= 0) && tileArrI[xI][yI-1][tileMapIndexI] != undefined && tileArrI[xI][yI-1][tileMapIndexI].tileSet == curTile.tileSet) { // OBSERVATION001 - Making the tile only connect to speccific tiles, not to any tile. (!= undefined makes it connect to any tile)
					curAdj[0] = true;
				}
				if (!curAdj[1] && (xI+1 < w) && tileArrI[xI+1][yI][tileMapIndexI] != undefined && tileArrI[xI+1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[1] = true;
				}
				if (!curAdj[2] && (yI+1 < h) && tileArrI[xI][yI+1][tileMapIndexI] != undefined && tileArrI[xI][yI+1][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[2] = true;
				}
				if (!curAdj[3] && (xI-1 >= 0) && tileArrI[xI-1][yI][tileMapIndexI] != undefined && tileArrI[xI-1][yI][tileMapIndexI].tileSet == curTile.tileSet) {
					curAdj[3] = true;
				}
				
				/*
				How the adjacency list works:
				  0
				3   1
				  2
				Each number refers to an index to the array. If that index is occupied with a tile of the same type, it becomes true since there's an adjacent block in there.
				*/
				
				if (curTile.direction == type_line_direction.horizontal) {
					if (curAdj[3] && curAdj[1]) {
						return type_line_sprIndexRoles.middle;
					}else if (curAdj[3]) {
						return type_line_sprIndexRoles.borderRight;
					}else if (curAdj[1]) {
						return type_line_sprIndexRoles.borderLeft;
					}else {
						return type_line_sprIndexRoles.borderAll;
					}
				}else {
					if (curAdj[2] && curAdj[0]) {
						return type_line_sprIndexRoles.middle;
					}else if (curAdj[2]) {
						return type_line_sprIndexRoles.borderRight;
					}else if (curAdj[0]) {
						return type_line_sprIndexRoles.borderLeft;
					}else {
						return type_line_sprIndexRoles.borderAll;
					}
				}
			},
			setTileTypesByInstance: function(instI, tileSetI, directionI, overrideExistingTilesI = true) {
				var x1 = instI.bbox_left/TileMng_defTileSize;
				var y1 = instI.bbox_top/TileMng_defTileSize;
				var x2 = instI.bbox_right/TileMng_defTileSize;
				var y2 = instI.bbox_bottom/TileMng_defTileSize;
				for (var i = x1; i < x2; i++) {
					for (var j = y1; j < y2; j++) {
						if (overrideExistingTilesI || TileManager.curTileArr[i][j][tileSetI.tileMapIndex] == undefined) TileManager.curTileArr[i][j][tileSetI.tileMapIndex] = constructTileBlueprint(tileSetI, directionI);
					}
				}
			}
		}
		
		#endregion
	},
	
	backgroundManager: {
		drawBeginEvent: function() {
			draw_sprite(spr_alphaCage, 0, CameraManager.curX/4*3, CameraManager.curY/4*3);
		}
	}
	
	#endregion
	
}

global.blockCollision = CollisionGridManager.blockCollision;
global.instanceCol = CollisionGridManager.instanceCol;
global.camouflageCol = CollisionGridManager.camouflageCol;

#endregion

#region Music manager

#macro MusicManager global.musicManager

#macro music_menu snd_menuMusic
#macro music_gameplay snd_music1

global.musicManager = {
	curMusic: undefined,
	setMusic: function(musicI) {
		if (curMusic != musicI) {
			//if (curMusic != undefined) audio_stop_sound(curMusic);
			//curMusic = audio_play_sound(musicI, 100, true);
		}
	}
}

MusicManager.setMusic(music_menu);

#endregion

#region Stage construction from room

#macro StageBuilderFromRoom global.stageBuilderFromRoom

global.doesStageBuilderFromRoomExist = true;
global.stageBuilderFromRoom = {
	stageBuildingUserEvent: 0,
	conversionUserEvent: 1,
	currentGameplayBlueprint: undefined,
	currentStageID: 0,
	stageBuildingArr: array_create(0),
	index: 0,
	adderObjects: [],
	
	isBuilding: false,
	
	#region EVENTS
	
	roomStartEvent: function() {
		if (isBuilding) {
			var adderList = preAssignStageObjectIDs();
			var cockMap = ds_map_create();
			StageObjectManager.nextID = 0;
			var curStage = StageManager.getStage(currentStageID);
			StageManager.setStageSize(currentStageID, room_width, room_height);
			TileManager.curTileArr = TileManager.constructTileSetFromTileMap(curStage.initialGameplayBlueprint.tileMap);
			TileManager.stageBuilding.setupForBuild();
			var penis = array_create(instance_count);
			//array_copy(penis, 0, instance_id, 0, instance_count);
			for (var i = 0; i < instance_count; i++) {
				var curInstance = instance_id[i];
				penis[i] = curInstance;
			}
			
			for (var i = 0; i < array_length(adderList); i++) {
				var curInstance = adderList[i];
				ds_map_add(cockMap, curInstance.id, undefined)
			}
			
			for (var i = 0; i < array_length(adderList); i++) {
				var curInstance = adderList[i];
				with (curInstance) {
					event_user(StageBuilderFromRoom.stageBuildingUserEvent);
				}
			}
			for (var i = 0; i < instance_count; i++) {
				var curInstance = instance_id[i];
				if (!ds_map_exists(cockMap, curInstance.id)) {
					with (curInstance) {
						event_user(StageBuilderFromRoom.stageBuildingUserEvent);
					}
				}
			}
			
			for (var i = 0; i < array_length(adderList); i++) {
				var curInstance = adderList[i];
				with (curInstance) {
					event_user(StageBuilderFromRoom.conversionUserEvent);
				}
			}
			for (var i = 0; i < instance_count; i++) {
				var curInstance = instance_id[i];
				if (!ds_map_exists(cockMap, curInstance.id)) {
					with (curInstance) {
						event_user(StageBuilderFromRoom.conversionUserEvent);
					}
				}
			}
			
			ds_map_destroy(cockMap);
			
			CameraManager.assignRegionArrayToGameplayBlueprint(curStage.initialGameplayBlueprint);
			TileManager.stageBuilding.replaceCollisionsApply();
			TileManager.stageBuilding.replacePlatformsApply();
			
			TileManager.defineTileMapFromTileArr(curStage.initialGameplayBlueprint.tileMap, TileManager.curTileArr);
			TileManager.curTileArr = undefined;
			
			for (var i = 0; i < instance_count; i++) {
				var curInstance = instance_id[i];
				if (curInstance.object_index != obj_gameManager) instance_destroy(curInstance);
			}
			
			buildNext();
		}
	},
	
	#endregion
	
	preAssignStageObjectIDs: function() {
		var nextStageObjectID = 0;
		var adderList = array_create(1024);
		var index = 0;
		for (var i = 0; i < instance_count; i++) {
			var curInstance = instance_id[i];
			var isAdderObject = false;
			for (var j = 0; j < array_length(adderObjects); j++) {
				if (curInstance.object_index == adderObjects[j]) {
					isAdderObject = true;
					adderList[index] = curInstance;
					index++;
					break;
				}
			}
			if (isAdderObject) {
				curInstance.stageObjectID = nextStageObjectID;
				nextStageObjectID++;
			}
		}
		array_resize(adderList, index);
		return adderList;
	},
	
	destroy: function() {
		global.doesStageBuilderFromRoomExist = false;
		TransitionManager.goToMenu(MenuManager.getMenu(menu.main));
		delete StageBuilderFromRoom;
	},
	
	assignRoomToStage: function(stageIDI, roomI) {
		array_push(stageBuildingArr, [stageIDI, roomI]);
	},
	
	buildStageFromRoom: function(stageIDI, roomI) {
		currentStageID = stageIDI;
		currentGameplayBlueprint = StageManager.getStage(currentStageID).initialGameplayBlueprint;
		StageObjectManager.setMap(currentGameplayBlueprint.stageObjectMap);
		CameraManager.reset();
		room_goto(roomI);
	},
	
	buildNext: function() {
		if (!isBuilding) {
			isBuilding = true;
			buildStageFromRoom(stageBuildingArr[index][0], stageBuildingArr[index][1]);
		}else {
			index++;
			if (index == array_length(stageBuildingArr)) {
				destroy();
			}else {
				buildStageFromRoom(stageBuildingArr[index][0], stageBuildingArr[index][1]);
			}
		}
	}
}

#endregion

GameplayManager.initialize();
