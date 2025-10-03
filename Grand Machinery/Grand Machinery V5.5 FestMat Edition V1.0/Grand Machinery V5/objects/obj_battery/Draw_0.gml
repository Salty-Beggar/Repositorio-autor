/// @description Insert description here
// You can write your code in this editor

draw_self();
var energyRatio = energyInterface.energy/energyInterface.energyMax;
draw_set_color(barColor);
draw_rectangle(x+barX1, y+barY1, x+barX1+barWidth*energyRatio-1, y+barY2, false);