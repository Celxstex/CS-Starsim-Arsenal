#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Steps back to the loadout before the last confirmed change.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(preview) isNotEqualTo []) exitWith {
    [true] call FUNC(revert);
};

if (GVAR(undo) isEqualTo []) exitWith {
    ["Nothing to undo"] call FUNC(message);
};

(GVAR(undo) deleteAt (count GVAR(undo) - 1)) params ["_snapshot", "_identity"];
[_snapshot, _identity] call FUNC(restoreLoadout);
GVAR(dirty) = true;

["Undone"] call FUNC(message);
call FUNC(refresh);
