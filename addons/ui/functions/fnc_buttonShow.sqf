#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Shows or hides every part of a button.
 *
 * Arguments:
 * 0: Button parts <ARRAY>
 * 1: Show <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_parts", "_show"];

{
    if (!isNull _x) then {_x ctrlShow _show};
} forEach _parts;
