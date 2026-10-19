#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Removes everything carried in a container. Undo brings it back.
 *
 * Arguments:
 * 0: Container: 0 uniform, 1 vest, 2 backpack <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_index"];

private _unit = CENTER;
if (([uniformItems _unit, vestItems _unit, backpackItems _unit] select _index) isEqualTo []) exitWith {};

private _before = call FUNC(snapshot);

// Through the loadout array so weapons stored inside go too
private _loadout = _unit call CBA_fnc_getLoadout;
private _container = (_loadout select 0) select (3 + _index);
if (_container isNotEqualTo []) then {
    _container set [1, []];
};
[_unit, _loadout] call CBA_fnc_setLoadout;

[_before] call FUNC(pushUndo);
[format ["Emptied the %1 · CTRL+Z to undo", ["uniform", "vest", "backpack"] select _index]] call FUNC(message);

GVAR(dirty) = true;
call ace_arsenal_fnc_updateCurrentItemsList;
call FUNC(refresh);
