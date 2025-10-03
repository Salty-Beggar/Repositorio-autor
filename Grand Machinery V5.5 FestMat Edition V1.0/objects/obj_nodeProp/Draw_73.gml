/// @description Insert description here
// You can write your code in this editor

var chargeProgress = chargeLifetimeFramesCur/chargeLifetimeFrames;
if (areConnectionsVisible) {
	var curLaserAlpha = laserAlphaUncharged+(laserAlphaCharged-laserAlphaUncharged)*chargeProgress;
	draw_set_alpha(curLaserAlpha);
	draw_set_color(laserColor);
	var curIndex = 0;
	var destinationAmount = array_length(destinations);
	for (var i = 0; i < destinationAmount; i++) {
		var curDest = destinations[i];
		if (instance_exists(curDest)) {
			if (connectionsVisibility[curIndex] == true)
				draw_line_width(x, y, curDest.x, curDest.y, 3);
		}
		curIndex++;
	}
	draw_set_alpha(1.0);
}