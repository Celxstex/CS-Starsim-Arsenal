#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Adds or removes one magazine. Adds go to the vest, then uniform, then backpack.
 *
 * Arguments:
 * 0: Magazine class <STRING>
 * 1: +1 to add, -1 to remove <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_mag", "_delta"];

private _unit = CENTER;
private _before = call FUNC(snapshot);
private _changed = true;

if (_delta > 0) then {
    switch (true) do {
        case (_unit canAddItemToVest _mag): {_unit addItemToVest _mag};
        case (_unit canAddItemToUniform _mag): {_unit addItemToUniform _mag};
        case (_unit canAddItemToBackpack _mag): {_unit addItemToBackpack _mag};
        default {
            _changed = false;
            ["No room for another magazine", true] call FUNC(message);
        };
    };
} else {
    _changed = _mag in magazines _unit;
    if (_changed) then {
        _unit removeMagazine _mag;
    };
};

if (!_changed) exitWith {};

[_before] call FUNC(pushUndo);
GVAR(dirty) = true;
call ace_arsenal_fnc_updateCurrentItemsList;
call FUNC(updateWeaponView);
call FUNC(updateHeader);
