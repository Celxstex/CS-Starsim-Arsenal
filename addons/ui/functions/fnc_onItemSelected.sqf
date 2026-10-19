#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Item list selection: previews the item on the character.
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
    call FUNC(updateCargoInfo);
};

private _sub = (parseSimpleArray ("[" + (_lnb lnbData [_row, 1]) + "]")) param [0, ""];
private _name = [_lnb lnbText [_row, 1], "Nothing"] select (_class == "");

["item", GVAR(slot), _class, _sub, _name] call FUNC(preview);
