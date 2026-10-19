#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Swaps a weapon. Mirrors ACE's own handling: magazines that only fit the old weapon are
 * removed, compatible attachments carry over, and an empty weapon gets a magazine.
 *
 * Arguments:
 * 0: Slot id ("PRI", "LCH" or "HGN") <STRING>
 * 1: Weapon class, "" to remove <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_slotId", "_item"];

private _unit = CENTER;
private _w = ([_slotId] call FUNC(slot)) select S_CURR; // 0 primary, 1 secondary, 2 handgun
private _current = ace_arsenal_currentItems select _w;
private _currentItems = +(ace_arsenal_currentItems select (IDX_CURR_PRIMARY_WEAPON_ITEMS + _w));
private _fnc_weapon = {[primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit] select _w};

private _fnc_clearMags = {
    if (_current == "") exitWith {};
    private _mags = compatibleMagazines _current;
    if (_item != "") then {
        _mags = _mags - compatibleMagazines _item;
    };
    {
        _unit removeMagazines _x;
    } forEach _mags;
};

if (_item == "") exitWith {
    call _fnc_clearMags;
    _unit removeWeapon (call _fnc_weapon);
};

if (_item == _current) exitWith {};

call _fnc_clearMags;
[_unit, _item] call ace_common_fnc_addWeapon;

// Remove linked attachments that aren't available in this arsenal
{
    if !(_x in ace_arsenal_virtualItemsFlat) then {
        switch (_w) do {
            case 0: {_unit removePrimaryWeaponItem _x};
            case 1: {_unit removeSecondaryWeaponItem _x};
            case 2: {_unit removeHandgunItem _x};
        };
    };
} forEach (([primaryWeaponItems _unit, secondaryWeaponItems _unit, handgunItems _unit] select _w) - [""]);

// Carry over compatible attachments and magazines
{
    if (_x != "" && {_item canAdd _x}) then {
        _unit addWeaponItem [_item, _x, true];
    };
} forEach _currentItems;

// Load a magazine if the primary muzzle is empty
private _loaded = ((getUnitLoadout _unit) select _w) param [4, []];
if (_loaded isEqualTo [] || {(_loaded param [0, ""]) == ""}) then {
    private _mags = compatibleMagazines [_item, "this"];
    private _index = _mags findAny (keys (GVAR(allItems) getOrDefault [IDX_VIRT_ITEMS_ALL, createHashMap]));
    if (_index != -1) then {
        _unit addWeaponItem [_item, _mags select _index, true];
    };
};

_unit selectWeapon (call _fnc_weapon);
