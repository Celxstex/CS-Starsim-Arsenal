#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns a loadout's role: the one set for it, or a guess from its name.
 *
 * Arguments:
 * 0: Source <STRING>
 * 1: Loadout name <STRING>
 *
 * Return Value:
 * Role <STRING>
 *
 * Public: No
 */

params ["_source", "_name"];

if (_source == "UNIT") then {
    private _unitRole = (missionNamespace getVariable [QGVAR(unitRoles), createHashMap]) getOrDefault [_name, ""];
    if (_unitRole in GVAR(roles)) exitWith {_source = _unitRole};
};
if (_source in GVAR(roles)) exitWith {_source};

private _roles = profileNamespace getVariable [QGVAR(loadoutRoles), createHashMap];
private _set = _roles getOrDefault [_source + "|" + _name, ""];
if (_set != "") exitWith {_set};

private _lower = " " + (toLowerANSI _name) + " ";
private _guess = "OTHER";
{
    _x params ["_role", "_words"];
    if (_words findIf {(_lower find _x) != -1} != -1) exitWith {
        _guess = _role;
    };
} forEach [
    ["MEDIC", ["medic", "corpsman", " doc"]],
    ["PILOT", ["pilot", "crew", "aviat"]],
    ["COMMAND", ["lead", "command", "officer", "sgt", "sergeant", " lt ", "captain", " cpt", " nco", " sl ", "comms"]],
    ["MARKSMAN", ["marksman", "sniper", "dmr", "sharpshoot"]],
    ["RECON", ["recon", "scout", " arc ", "pathfind"]],
    ["ENGINEER", ["engineer", " eod", "sapper", "demo"]],
    ["HEAVY", ["heavy", "repeater", "support", "autorifle", " ar ", " mg", " at ", "anti-tank", " aa "]],
    ["RIFLEMAN", ["rifle", "trooper", "infantry", "standard"]]
];

_guess
