// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function random_by_fraction(numeratorI, denominatorI){
	return irandom(numeratorI-1) >= irandom(denominatorI-1);
}