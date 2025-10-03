/// @description Insert description here
// You can write your code in this editor

var outlineSize = 1;

var drawSkeleton = function(colorI, outlineSizeI) {
	for (var i = 0; i < array_length(nodes); i++) {
		var curNode = nodes[i];
		draw_set_color(colorI);
		draw_circle(curNode.x, curNode.y, 3+outlineSizeI, false);
		if (i != array_length(nodes)-1) {
			draw_line_width(curNode.x, curNode.y, nodes[i+1].x, nodes[i+1].y, 1+outlineSizeI*2);
		}
	}
}

draw_set_alpha(1.0);
drawSkeleton(c_white, outlineSize*2);
draw_set_alpha(1.0);
drawSkeleton(c_black, outlineSize);
draw_set_alpha(charge/chargeMax);
drawSkeleton(c_aqua, 0);
draw_set_alpha(1.0);