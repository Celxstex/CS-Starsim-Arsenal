#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Moves every copy of an item from one container to another, as many as fit.
 *
 * Arguments:
 * 0: Class name <STRING>
 * 1: From container: 0 uniform, 1 vest, 2 backpack <NUMBER>
 * 2: To container <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_class", "_from", "_to"];

private _unit = CENTER;
if (([uniform _unit, vest _unit, backpack _unit] select _to) == "") exitWith {
    ["Nothing to put it in", true] call FUNC(message);
};

private _have = {_x == _class} count ([uniformItems _unit, vestItems _unit, backpackItems _unit] select _from);
if (_have == 0) exitWith {};

private _before = call FUNC(snapshot);
private _moved = 0;
for "_i" from 1 to _have do {
    private _canAdd = switch (_to) do {
        case 0: {_unit canAddItemToUniform _class};
        case 1: {_unit canAddItemToVest _class};
        default {_unit canAddItemToBackpack _class};
    };
    if (!_canAdd) exitWith {};
    switch (_from) do {
        case 0: {_unit removeItemFromUniform _class};
        case 1: {_unit removeItemFromVest _class};
        default {_unit removeItemFromBackpack _class};
    };
    switch (_to) do {
        case 0: {_unit addItemToUniform _class};
        case 1: {_unit addItemToVest _class};
        default {_unit addItemToBackpack _class};
    };
    _moved = _moved + 1;
};

private _toName = ["uniform", "vest", "backpack"] select _to;
if (_moved == 0) exitWith {
    [format ["No room in the %1", _toName], true] call FUNC(message);
};

[_before] call FUNC(pushUndo);
if (_moved < _have) then {
    [format ["Moved %1 of %2 · the %3 is full", _moved, _have, _toName], true] call FUNC(message);
} else {
    [format ["Moved %1 to the %2", _moved, _toName]] call FUNC(message);
};

GVAR(dirty) = true;
call ace_arsenal_fnc_updateCurrentItemsList;
call FUNC(refresh);
