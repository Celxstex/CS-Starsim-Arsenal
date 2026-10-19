#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Keeps the current preview. The loadout from before it goes on the undo stack.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(preview) isEqualTo []) exitWith {};

GVAR(preview) params ["_kind", "", "", "", "_snapshot", "", "", "_label", "_identity"];

[[_snapshot, _identity]] call FUNC(pushUndo);

if (_kind == "loadout") then {
    GVAR(loadoutName) = _label;
    GVAR(dirty) = false;
    [format ["Loaded %1", _label]] call FUNC(message);
} else {
    GVAR(dirty) = true;
};

if (GVAR(previewLost) > 0) then {
    [format ["%1 item(s) didn't fit and were removed", GVAR(previewLost)], true] call FUNC(message);
};

GVAR(preview) = [];
GVAR(previewLost) = 0;

call FUNC(refresh);
