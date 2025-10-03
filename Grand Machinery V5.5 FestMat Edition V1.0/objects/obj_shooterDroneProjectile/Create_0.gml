/// @description Insert description here
// You can write your code in this editor

if_physics.setHSpeed(ifPhysics, initialHSpd);
if_physics.setVSpeed(ifPhysics, initialVSpd);

ifPhysics.collision.perms.platform = false;

energyObjIgnoreMap = ds_map_create();
ds_map_add(energyObjIgnoreMap, obj_energyCollision, pointer_null);
ds_map_add(energyObjIgnoreMap, obj_shooterDroneProjectile, pointer_null);