// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function collision_rectangle_2(x1, y1, x2, y2, obj, prec, notme){
	var colX1 = round(x1);
	var colY1 = round(y1);
	var colX2 = round(x2);
	var colY2 = round(y2);
	if (colX1 == colX2) {
		colX2 += 1;
	}
	if (colY1 == colY2) {
		colY2 += 1;
	}
	return collision_rectangle(colX1, colY1, colX2, colY2, obj, prec, notme);
}