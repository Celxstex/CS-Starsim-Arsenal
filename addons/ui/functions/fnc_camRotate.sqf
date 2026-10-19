#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Turns ACE's arsenal camera around the character, keeping the same target point.
 *
 * Arguments:
 * 0: Degrees <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_degrees"];

if (isNil "ace_arsenal_cameraPosition") exitWith {};

ace_arsenal_cameraPosition set [1, (ace_arsenal_cameraPosition select 1) + _degrees];
