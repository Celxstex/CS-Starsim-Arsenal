#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Sets how many of the selected item are in the picked container, from the amount
 * typed in the box under the list. Adds or removes the difference.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _text = ctrlText (GVAR(ui) get "cargoQty");
if !(_text regexMatch "^\s*\d+\s*$") exitWith {
    ["Type a number", true] call FUNC(message);
    call FUNC(updateCargoInfo);
};

private _lnb = GVAR(ui) get "itemList";
private _row = lnbCurSelRow _lnb;
private _class = if (_row < 0) then {""} else {_lnb lnbData [_row, 0]};
if (_class in ["", "#"]) exitWith {
    ["Pick an item in the list first", true] call FUNC(message);
};

private _wanted = (floor parseNumber _text) max 0;
private _unit = CENTER;
private _have = {_x == _class} count ([uniformItems _unit, vestItems _unit, backpackItems _unit] select GVAR(cargoTarget));

if (_wanted == _have) exitWith {
    call FUNC(updateCargoInfo);
};
[_wanted - _have] call FUNC(cargoChange);
