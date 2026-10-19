#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Swaps a uniform, vest or backpack and keeps its contents. Anything that no longer
 * fits is removed (ACE's preventOverfilling) and counted.
 *
 * Arguments:
 * 0: Container index: 0 uniform, 1 vest, 2 backpack <NUMBER>
 * 1: Container class, "" to remove <STRING>
 *
 * Return Value:
 * Number of items removed <NUMBER>
 *
 * Public: No
 */

params ["_index", "_item"];

private _unit = CENTER;
private _fnc_items = [{uniformItems _unit}, {vestItems _unit}, {backpackItems _unit}] select _index;
private _before = count (call _fnc_items);

if (_item == "") then {
    switch (_index) do {
        case 0: {removeUniform _unit};
        case 1: {removeVest _unit};
        case 2: {removeBackpack _unit};
    };
} else {
    private _loadout = getUnitLoadout _unit;
    private _contents = (_loadout select (3 + _index)) param [1, []];
    _loadout set [3 + _index, [_item, _contents]];
    _unit setUnitLoadout _loadout;

    private _container = [uniformContainer _unit, vestContainer _unit, backpackContainer _unit] select _index;
    [_unit, _container] call ace_arsenal_fnc_preventOverfilling;
};

(_before - count (call _fnc_items)) max 0
