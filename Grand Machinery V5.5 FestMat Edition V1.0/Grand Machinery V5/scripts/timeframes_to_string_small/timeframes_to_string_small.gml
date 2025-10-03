// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function timeframes_to_string_small(timeFramesI){
	var centiSeconds = floor((timeFramesI mod 60)/60*100);
	if (centiSeconds >= 10) 
		return ","+string(centiSeconds);
	else
		return ","+"0"+string(centiSeconds);
}