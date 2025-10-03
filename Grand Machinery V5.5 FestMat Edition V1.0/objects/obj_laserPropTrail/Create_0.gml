/// @description Insert description here
// You can write your code in this editor

lifetime = 60;
lifetimeCur = lifetime;
color = c_aqua;

x1 = 0;
y1 = 0;
x2 = 0;
y2 = 0;

function initialize(xI, yI, hDirI, vDirI, lengthI) {
	if (hDirI == 1) {
		x1 = xI;
		y1 = yI-1;
		x2 = xI+lengthI;
		y2 = yI+1;
	}else if (hDirI == -1) {
		x1 = xI-lengthI;
		y1 = yI-1;
		x2 = xI;
		y2 = yI+1;
	}else if (vDirI == 1) {
		x1 = xI-1;
		y1 = yI;
		x2 = xI+1;
		y2 = yI+lengthI;
	}else {
		x1 = xI-1;
		y1 = yI-lengthI;
		x2 = xI+1;
		y2 = yI;
	}
}