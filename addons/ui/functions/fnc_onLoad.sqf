#include "..\script_component.hpp"
/*
 * Author: Celxste
 * onLoad for ace_arsenal_display. ACE sets up its state, camera and events first,
 * then the Starsim Arsenal UI is built over the top when it's enabled.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display"];

private _active = missionNamespace getVariable [QGVAR(enabled), true];
_display setVariable [QGVAR(active), _active];

["onLoad", [_display], "ace_arsenal_display"] call ace_arsenal_fnc_onArsenalOpen;

if (_active) then {
    [_display] call FUNC(open);
};
