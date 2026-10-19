#include "..\script_component.hpp"
/*
 * Author: Celxste
 * onUnload for ace_arsenal_display. Cleans up the Starsim Arsenal UI (reverting any preview)
 * before ACE tears down its state.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Exit code <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display", "_exitCode"];

if (_display getVariable [QGVAR(active), false]) then {
    [_display, _exitCode] call FUNC(close);
};

["onUnload", [_display, _exitCode], "ace_arsenal_display"] call ace_arsenal_fnc_onArsenalClose;
