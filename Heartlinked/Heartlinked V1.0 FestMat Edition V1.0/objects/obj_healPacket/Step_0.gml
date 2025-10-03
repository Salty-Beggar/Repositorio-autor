/// @description Insert description here
// You can write your code in this editor

if (place_meeting(x, y, CURRENT_MEMBER_INST) && PartySubmanager.curMember.hlth != PartySubmanager.curMember.hlthMax) {
	PartySubmanager.curMember.hlth = PartySubmanager.curMember.hlthMax;
	instance_destroy();
}
sine++;