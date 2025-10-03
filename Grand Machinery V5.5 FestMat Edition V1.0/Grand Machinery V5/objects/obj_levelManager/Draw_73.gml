/// @description Insert description here
// You can write your code in this editor
/*
for (var i = 0; i < 41; i++) {
	for (var j = 0; j < 31; j++) {
		var curBuffer = collisionGrid_matrix[i][j];
		buffer_seek(curBuffer, buffer_seek_start, 3);
		var cock = buffer_read(curBuffer, buffer_u8);
		var amount = 0;
		var hasPlayer = false;
		var curID = 0;
		//var endingIndex = buffer_read(curBuffer, buffer_u8);
		for (var c = 0; c < 16; c++) {
			var curItemPart1 = buffer_read(curBuffer, buffer_u8);
			var curItemPart2 = buffer_read(curBuffer, buffer_u8);
			if (curItemPart1 != 0b11111111 || curItemPart2 != 0b11111111) {
				amount++;
			}
		}
		draw_text(i*16, j*16, amount);
	}
}
/*with (global.collisionGrid) {
	for (var i = 0; i < array_length(matrix); i++) {
		for (var j = 0; j < array_length(matrix[0]); j++) {
			draw_set_color(c_green);
			if (!matrix[i][j].blockCollisionType != collisionType_onewayUp) {
				draw_set_color(c_red);
			}
			draw_rectangle(i*tileSize, j*tileSize, (i+1)*tileSize, (j+1)*tileSize, true);
		}
	}
}