#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Cleans up the Starsim Arsenal UI. An unconfirmed preview is reverted.
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

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};

uiNamespace setVariable [QGVAR(display), displayNull];
GVAR(view) = "";
GVAR(ui) = nil;
GVAR(allItems) = nil;
GVAR(preview) = nil;
GVAR(undo) = nil;
GVAR(pins) = nil;
GVAR(drag) = [];
// Pins and sort are written to the profile as they change; save it once on close
if (missionNamespace getVariable [QGVAR(profileDirty), false]) then {
    GVAR(profileDirty) = false;
    saveProfileNamespace;
};
GVAR(loadoutsRows) = nil;
GVAR(models) = nil;
GVAR(itemModel) = nil;
