#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Loadout list selection: previews the loadout on the character.
 *
 * Arguments:
 * 0: Row <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_row"];

private _lnb = GVAR(ui) get "loadoutsList";
private _index = _lnb lnbValue [_row, 0];
if (_index < 0) exitWith {};

(GVAR(loadoutsRows) select _index) params ["_source", "_name", "", "_loadout"];
GVAR(loadoutsSel) = [_source, _name];
GVAR(deleteArmed) = [];

["loadout", "", +_loadout, "", _name] call FUNC(preview);
