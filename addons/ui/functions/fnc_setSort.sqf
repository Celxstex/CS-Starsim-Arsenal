#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Changes the item list sort. Picking the active sort again flips its direction.
 * The choice is remembered between sessions.
 *
 * Arguments:
 * 0: Mode ("NAME", "MOD", "MASS", "LOAD", "ARMOR") or "DIR" to flip the direction <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_mode"];

([GVAR(slot)] call FUNC(sortMode)) params ["_current", "_desc"];

if (_mode in ["DIR", _current]) then {
    GVAR(sort) = _current;
    GVAR(sortDesc) = !_desc;
} else {
    GVAR(sort) = _mode;
    // Bigger is usually what you're looking for with capacity and armour
    GVAR(sortDesc) = _mode in ["LOAD", "ARMOR"];
};

profileNamespace setVariable [QGVAR(sort), [GVAR(sort), GVAR(sortDesc)]];
GVAR(profileDirty) = true;

call FUNC(fillItemList);
