#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Undoes the current preview, restoring the loadout from before it.
 *
 * Arguments:
 * 0: Refresh the UI afterwards <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_refresh", true]];

if (GVAR(preview) isEqualTo []) exitWith {};

GVAR(preview) params ["", "", "", "", "_snapshot", "", "", "", "_identity"];
GVAR(preview) = [];
GVAR(previewLost) = 0;

[_snapshot, _identity] call FUNC(restoreLoadout);

if (_refresh) then {
    call FUNC(refresh);
};
