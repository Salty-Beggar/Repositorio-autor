/// @description Insert description here
// You can write your code in this editor

var sprHeight = 32;
for (var i = 0; i < segmentAmount; i++) {
	var curIndex = sprIndexArr[i];
	draw_sprite(sprite, curIndex, x, y+sprHeight*i);
}