#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Adds an entry to the undo stack, keeping the last 30.
 *
 * Arguments:
 * 0: Entry from FUNC(snapshot) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_entry"];

GVAR(undo) pushBack _entry;
if (count GVAR(undo) > 30) then {
    GVAR(undo) deleteAt 0;
};
