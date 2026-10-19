#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the loadout name and unsaved-changes dot in the top bar.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _name = GVAR(ui) getOrDefault ["headerName", controlNull];
if (isNull _name) exitWith {};

_name ctrlSetText ([GVAR(loadoutName), "Unsaved loadout"] select (GVAR(loadoutName) == ""));
(GVAR(ui) get "headerDirty") ctrlSetBackgroundColor ([C_CLEAR, C_WORSE] select GVAR(dirty));
(GVAR(ui) get "headerDirty") ctrlSetTooltip (["", "Unsaved changes"] select GVAR(dirty));
