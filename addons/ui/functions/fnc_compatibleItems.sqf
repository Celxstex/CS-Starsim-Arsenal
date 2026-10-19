#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the attachments or magazines for a weapon point that this arsenal allows.
 *
 * Arguments:
 * 0: Weapon class <STRING>
 * 1: Point: 0 optic, 1 muzzle, 2 side rail, 3 underbarrel, 4 magazine <NUMBER>
 *
 * Return Value:
 * Class names <ARRAY>
 *
 * Public: No
 */

params ["_weapon", "_point"];

if (_weapon == "") exitWith {[]};

private _allowed = ace_arsenal_virtualItemsFlat;

if (_point == 4) exitWith {
    private _mags = [];
    {
        _mags append (compatibleMagazines [_weapon, _x]);
    } forEach (_weapon call CBA_fnc_getMuzzles);
    _mags = _mags arrayIntersect _mags;
    _mags select {_x in _allowed}
};

private _type = [201, 101, 301, 302] select _point;
(compatibleItems _weapon) select {
    _x in _allowed && {getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "type") == _type}
}
