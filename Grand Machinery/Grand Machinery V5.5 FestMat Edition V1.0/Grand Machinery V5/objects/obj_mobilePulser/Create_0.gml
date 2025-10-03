/// @description Insert description here
// You can write your code in this editor

if (global.doesStageBuilderFromRoomExist && StageBuilderFromRoom.isBuilding)
	return;

with (energyInterface) {
	powerOnExtra = function() {
		instanceID.pulse.start();
	}
}

pulse = {
	_p: other,
	isBeingDone: false,
	radius: 96,
	delayFrames: 20,
	delayFramesCur: 0,
	start: function() {
		isBeingDone = true;
		_p.pulseDrawer.startCharge();
		delayFramesCur = 0;
	},
	doPulse: function() {
		_p.pulseDrawer.start();
		var gridInstances = InstanceCollisionGrid.rectangleGetCollidedInstances(
			_p.x-radius, _p.y-radius, _p.x+radius, _p.y+radius
		);
		for (var i = 0; i < array_length(gridInstances); i++) {
			var curInst = gridInstances[i];
			if (EnergyInterface.hasInstance(curInst) && point_distance(_p.x, _p.y, curInst.x, curInst.y)) {
				curInst.energyInterface.receiveEnergy(_p.energyInterface.energy);
			}
		}
		_p.energyInterface.useEnergy(_p.energyInterface.energy);
	},
	stop: function() {
		isBeingDone = false;
	},
	tick: function() {
		if (isBeingDone) {
			if (delayFramesCur == delayFrames) {
				doPulse();
				stop();
			}else {
				delayFramesCur++;
			}
		}
	}
}

pulseDrawer = {
	_p: other,
	frames: 60,
	framesCur: 0,
	isCharging: false,
	isPulsing: false,
	pulseAlpha: 0.45,
	pulseColor: c_aqua,
	startCharge: function() {
		isCharging = true;
	},
	start: function() {
		isPulsing = true;
		isCharging = false;
		framesCur = 0;
	},
	tick: function() {
		if (framesCur == frames) {
			isPulsing = false;
		}else {
			framesCur++;
		}
	},
	drawBack: function() {
		if (isPulsing) {
			var curRatio = 1.0-framesCur/frames;
			draw_set_alpha(curRatio*pulseAlpha);
			draw_set_color(pulseColor);
			draw_circle(_p.x, _p.y, _p.pulse.radius, false);
			draw_set_alpha(1.0);
		}
	},
	drawFront: function() {
		if (isPulsing) {
			var curRatio = 1.0-framesCur/frames;
			draw_sprite_ext(spr_mobilePulserCharge, 0, _p.x, _p.y, 1.0, 1.0, 0, c_white, curRatio);
		}else if (isCharging) {
			draw_sprite_ext(spr_mobilePulserCharge, 0, _p.x, _p.y, 1.0, 1.0, 0, c_white, 1.0);
		}
	}
}