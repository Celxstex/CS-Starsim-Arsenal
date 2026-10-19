#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Opens or closes the full compare overlay.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(view) != "loadout") exitWith {};

GVAR(compareOpen) = !GVAR(compareOpen);
call FUNC(updateSidePanel);
