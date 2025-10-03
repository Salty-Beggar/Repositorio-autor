/// @description Insert description here
// You can write your code in this editor

/*if (UserManager.hasSaveFile) {
}else {
	directory_create(saveDirectoryNameString);
}*/

MainLevelManager.initializeLevels();
StageBuilderFromRoom.buildNext();

if (!UserManager.hasSaveFile) {
	UserManager.saveUserInfo();
	UserManager.hasSaveFile = true;
}
