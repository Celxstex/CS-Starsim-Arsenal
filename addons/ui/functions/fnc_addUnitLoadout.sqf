#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Adds a loadout to the UNIT tab of the Loadouts view on this machine. Call it from a mission
 * or a unit mod's postInit on every client (it is local).
 *
 * Arguments:
 * 0: Name <STRING>
 * 1: Loadout, getUnitLoadout or CBA extended format <ARRAY>
 * 2: Role, e.g. "MEDIC" <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["Medic - Standard", getUnitLoadout player, "MEDIC"] call arsenal_ui_fnc_addUnitLoadout
 *
 * Public: Yes
 */

params [["_name", "", [""]], ["_loadout", [], [[]]], ["_role", "", [""]]];

if (_name == "" || {!(count _loadout in [2, 10])}) exitWith {
    WARNING_1("addUnitLoadout: bad loadout for %1",_name);
};

if (isNil QGVAR(unitLoadouts)) then {GVAR(unitLoadouts) = []};
if (isNil QGVAR(unitRoles)) then {GVAR(unitRoles) = createHashMap};

private _index = GVAR(unitLoadouts) findIf {(_x select 0) == _name};
if (_index == -1) then {
    GVAR(unitLoadouts) pushBack [_name, _loadout];
} else {
    GVAR(unitLoadouts) set [_index, [_name, _loadout]];
};

if (_role != "") then {
    GVAR(unitRoles) set [_name, toUpper _role];
};
