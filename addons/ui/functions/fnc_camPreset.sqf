#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Moves ACE's arsenal camera to a preset framing. The target point is in the unit's
 * model space, so it stays on the same part of the body whatever the camera angle.
 *
 * Arguments:
 * 0: Preset name (see XEH_preInit) <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_name"];

private _preset = GVAR(camPresets) getOrDefault [_name, []];
if (_preset isEqualTo [] || {isNil "ace_arsenal_cameraPosition"}) exitWith {};

_preset params ["_distance", "_dirV", "_helper"];

ace_arsenal_cameraPosition set [0, _distance];
ace_arsenal_cameraPosition set [2, _dirV];
ace_arsenal_cameraPosition set [3, +_helper];
if (_name == "back") then {
    ace_arsenal_cameraPosition set [1, 180];
};
