#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the mass of a loadout (getUnitLoadout format) in Arma mass units.
 *
 * Arguments:
 * 0: Loadout <ARRAY>
 *
 * Return Value:
 * Mass <NUMBER>
 *
 * Public: No
 */

params ["_loadout"];

private _fnc_mass = {
    params ["_class"];
    if (!(_class isEqualType "") || {_class == ""}) exitWith {0};
    [[_class] call FUNC(itemConfig)] call FUNC(itemMass)
};

private _fnc_weapon = {
    params ["_weapon"];
    private _sum = 0;
    {
        if (_x isEqualType "") then {
            _sum = _sum + ([_x] call _fnc_mass);
        } else {
            if (_x isEqualType [] && {_x isNotEqualTo []}) then {
                _sum = _sum + ([_x select 0] call _fnc_mass);
            };
        };
    } forEach _weapon;
    _sum
};

private _total = 0;
{
    private _part = _loadout param [_x, []];
    if (_part isNotEqualTo []) then {
        _total = _total + ([_part] call _fnc_weapon);
    };
} forEach [0, 1, 2, 8];

{
    (_loadout param [_x, []]) params [["_container", ""], ["_contents", []]];
    _total = _total + ([_container] call _fnc_mass);
    {
        _x params ["_item", ["_count", 1]];
        private _each = if (_item isEqualType []) then {[_item] call _fnc_weapon} else {[_item] call _fnc_mass};
        _total = _total + _each * (_count max 1);
    } forEach _contents;
} forEach [3, 4, 5];

_total = _total + ([_loadout param [6, ""]] call _fnc_mass) + ([_loadout param [7, ""]] call _fnc_mass);
{
    _total = _total + ([_x] call _fnc_mass);
} forEach (_loadout param [9, []]);

_total
