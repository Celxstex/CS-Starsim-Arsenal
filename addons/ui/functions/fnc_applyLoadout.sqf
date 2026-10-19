#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Applies an extended loadout the way ACE's Load button does: verified against the
 * arsenal's items, containers recovered, overfilling prevented, identity restored.
 *
 * Arguments:
 * 0: Extended loadout [loadout, extended info] <ARRAY>
 *
 * Return Value:
 * Unavailable item classes <ARRAY>
 *
 * Public: No
 */

params ["_extendedLoadout"];

private _unit = CENTER;
private _result = [+_extendedLoadout, true] call ace_arsenal_fnc_verifyLoadout;
private _unavailable = _result select 2;
private _verified = ([_unit, _result] call ace_arsenal_fnc_recoverInvalidContainers) select 0;

[_unit, _verified, true] call CBA_fnc_setLoadout;
_unit call ace_arsenal_fnc_preventOverfilling;

_verified params ["", "_extendedInfo"];
if (_extendedInfo isEqualType []) then {_extendedInfo = createHashMapFromArray _extendedInfo};

if ("ace_arsenal_face" in _extendedInfo) then {
    ace_arsenal_currentFace = _extendedInfo get "ace_arsenal_face";
};
if ("ace_arsenal_voice" in _extendedInfo) then {
    ace_arsenal_currentVoice = _extendedInfo get "ace_arsenal_voice";
};
if ("ace_arsenal_insignia" in _extendedInfo) then {
    ace_arsenal_currentInsignia = _extendedInfo get "ace_arsenal_insignia";
} else {
    [_unit, ""] call BIS_fnc_setUnitInsignia;
    [_unit, ace_arsenal_currentInsignia] call BIS_fnc_setUnitInsignia;
};

call ace_arsenal_fnc_updateCurrentItemsList;
call ace_arsenal_fnc_updateUniqueItemsList;

_unavailable
