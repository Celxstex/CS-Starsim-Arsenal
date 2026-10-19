#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Saves what the character is wearing to your ACE saved loadouts (the same list ACE uses).
 * Any pending preview is reverted first, so the saved kit is the confirmed one.
 *
 * Arguments:
 * 0: Name <STRING>
 * 1: Role <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_name", ["_role", ""]];

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};

private _extended = CENTER call CBA_fnc_getLoadout;
_extended set [0, [_extended select 0] call ace_arsenal_fnc_replaceUniqueItemsLoadout];

private _data = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
private _index = _data findIf {(_x select 0) == _name};
if (_index == -1) then {
    _index = _data pushBack [_name, _extended];
} else {
    _data set [_index, [_name, _extended]];
};
profileNamespace setVariable ["ace_arsenal_saved_loadouts", _data];

if (_role != "") then {
    private _roles = profileNamespace getVariable [QGVAR(loadoutRoles), createHashMap];
    _roles set ["MINE|" + _name, _role];
    profileNamespace setVariable [QGVAR(loadoutRoles), _roles];
};

GVAR(loadoutName) = _name;
GVAR(dirty) = false;

["ace_arsenal_onLoadoutSave", [_index, _extended select 0]] call CBA_fnc_localEvent;
["ace_arsenal_onLoadoutSaveExtended", [_index, _extended]] call CBA_fnc_localEvent;

[format ["Saved %1", _name]] call FUNC(message);
call FUNC(refresh);
