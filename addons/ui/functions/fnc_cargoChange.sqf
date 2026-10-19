#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Adds or removes copies of an item in a container. Each change can be undone.
 *
 * Arguments:
 * 0: Copies to add (positive) or remove (negative) <NUMBER>
 * 1: Class name, "" for the item selected in the list <STRING> (default: "")
 * 2: Container: 0 uniform, 1 vest, 2 backpack, -1 for the one picked above the list <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_delta", ["_class", ""], ["_target", -1]];

if (_class == "") then {
    private _lnb = GVAR(ui) get "itemList";
    private _row = lnbCurSelRow _lnb;
    if (_row >= 0) then {
        _class = _lnb lnbData [_row, 0];
    };
};
if (_class in ["", "#"]) exitWith {};
if (_target < 0) then {_target = GVAR(cargoTarget)};

private _unit = CENTER;
if (([uniform _unit, vest _unit, backpack _unit] select _target) == "") exitWith {
    ["Nothing to put it in", true] call FUNC(message);
};

private _before = call FUNC(snapshot);
private _ratioBefore = load _unit;
private _done = 0;

if (_delta > 0) then {
    for "_i" from 1 to _delta do {
        private _canAdd = switch (_target) do {
            case 0: {_unit canAddItemToUniform _class};
            case 1: {_unit canAddItemToVest _class};
            default {_unit canAddItemToBackpack _class};
        };
        if (!_canAdd) exitWith {};
        switch (_target) do {
            case 0: {_unit addItemToUniform _class};
            case 1: {_unit addItemToVest _class};
            default {_unit addItemToBackpack _class};
        };
        _done = _done + 1;
    };
    switch (true) do {
        case (_done == 0): {["Not enough room", true] call FUNC(message)};
        case (_delta > 1 && {_done < _delta}): {[format ["Added %1 · now full", _done]] call FUNC(message)};
        case (_delta > 1): {[format ["Added %1", _done]] call FUNC(message)};
    };
} else {
    private _have = {_x == _class} count ([uniformItems _unit, vestItems _unit, backpackItems _unit] select _target);
    for "_i" from 1 to ((abs _delta) min _have) do {
        switch (_target) do {
            case 0: {_unit removeItemFromUniform _class};
            case 1: {_unit removeItemFromVest _class};
            default {_unit removeItemFromBackpack _class};
        };
        _done = _done + 1;
    };
    switch (true) do {
        case (_have == 0): {[format ["None in the %1", ["uniform", "vest", "backpack"] select _target], true] call FUNC(message)};
        case (_done > 1): {[format ["Removed %1", _done]] call FUNC(message)};
    };
};

if (_done == 0) exitWith {};

[_before] call FUNC(pushUndo);
if (_ratioBefore < LOAD_HEAVY && {load _unit >= LOAD_HEAVY}) then {
    [format ["Heavy load now · %1%2 of max", round (load _unit * 100), "%"], true] call FUNC(message);
};
GVAR(dirty) = true;
call ace_arsenal_fnc_updateCurrentItemsList;
call FUNC(refresh);
