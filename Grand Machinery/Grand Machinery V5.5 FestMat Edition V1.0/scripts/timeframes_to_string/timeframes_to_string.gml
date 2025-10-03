// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function timeframes_to_string(timeFramesI){
	var seconds = timeFramesI div game_get_speed(gamespeed_fps);
	var minutes = seconds div 60;
		
	var secondsString = "";
	if (seconds mod 60 < 10)
		secondsString += "0";
	secondsString += string(seconds mod 60);
		
	var minutesString = "";
	if (minutes < 10)
		minutesString += "0";
	minutesString += string(minutes);
		
	var curString = minutesString+":"+secondsString;
	return curString;
}