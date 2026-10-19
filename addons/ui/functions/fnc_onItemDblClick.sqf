#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Item list double-click: equips the item (or adds one for inventory items).
 *
 * Arguments:
 * 0: List <CONTROL>
 * 1: Row <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_lnb", "_row"];

if (_row < 0) exitWith {};
private _class = _lnb lnbData [_row, 0];
if (_class == "#") exitWith {};

private _slot = [GVAR(slot)] call FUNC(slot);
if ((_slot select S_KIND) == "cargo") exitWith {
    [1] call FUNC(cargoChange);
};

// The click before the double-click already started the preview
if (GVAR(preview) isEqualTo []) then {
    [_lnb, _row] call FUNC(onItemSelected);
};
call FUNC(commit);
