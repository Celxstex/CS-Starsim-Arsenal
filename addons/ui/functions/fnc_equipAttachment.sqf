#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Changes a weapon attachment or the loaded magazine.
 *
 * Arguments:
 * 0: Weapon slot id ("PRI", "LCH" or "HGN") <STRING>
 * 1: Attachment index: 0 muzzle, 1 side rail, 2 optic, 3 underbarrel, 4 magazine <NUMBER>
 * 2: Class name, "" to remove <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_slotId", "_index", "_item"];

private _unit = CENTER;
private _w = ([_slotId] call FUNC(slot)) select S_CURR;
private _weapon = [primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit] select _w;
if (_weapon == "") exitWith {};

private _fnc_remove = {
    params ["_class"];
    if (_class == "") exitWith {};
    switch (_w) do {
        case 0: {_unit removePrimaryWeaponItem _class};
        case 1: {_unit removeSecondaryWeaponItem _class};
        case 2: {_unit removeHandgunItem _class};
    };
};

if (_index == 4) then {
    private _loaded = (((getUnitLoadout _unit) select _w) param [4, []]) param [0, ""];
    if (_item == "") then {
        [_loaded] call _fnc_remove;
    } else {
        _unit addWeaponItem [_weapon, _item, true];
    };
} else {
    private _attached = ([primaryWeaponItems _unit, secondaryWeaponItems _unit, handgunItems _unit] select _w) param [_index, ""];
    if (_item == "") then {
        [_attached] call _fnc_remove;
    } else {
        _unit addWeaponItem [_weapon, _item, true];
    };
};
