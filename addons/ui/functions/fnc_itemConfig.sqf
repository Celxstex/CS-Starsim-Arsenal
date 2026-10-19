#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the config of an item, looking it up in the usual roots if none is given.
 *
 * Arguments:
 * 0: Class name <STRING>
 * 1: Config root, e.g. "CfgWeapons" <STRING> (default: "")
 *
 * Return Value:
 * Config <CONFIG>
 *
 * Public: No
 */

params ["_class", ["_root", ""]];

if (_class == "") exitWith {configNull};
if (_root != "") exitWith {configFile >> _root >> _class};

private _cfg = configNull;
{
    if (isClass (configFile >> _x >> _class)) exitWith {
        _cfg = configFile >> _x >> _class;
    };
} forEach ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses"];

_cfg
