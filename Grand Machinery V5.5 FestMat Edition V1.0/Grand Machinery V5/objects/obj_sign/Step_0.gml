/// @description Insert description here
// You can write your code in this editor

if (place_meeting(x, y, obj_player)) {
	if (!isBeingRead) {
		isBeingRead = true;
		DialogueManager.setDialogue(dialogue);
	}
}else {
	if (isBeingRead) {
		isBeingRead = false;
		DialogueManager.removeDialogue(dialogue);
	}
}