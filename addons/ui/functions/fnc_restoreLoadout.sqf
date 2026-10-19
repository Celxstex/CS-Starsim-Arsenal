#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Restores a snapshot taken with CBA_fnc_getLoadout, plus face, voice and insignia.
 *
 * Arguments:
 * 0: Extended loadout <ARRAY>
 * 1: [face, voice, insignia] <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_snapshot", "_identity"];
_identity params ["_face", "_voice", "_insignia"];

private _unit = CENTER;
[_unit, _snapshot] call CBA_fnc_setLoadout;

if (_face != ace_arsenal_currentFace) then {
    _unit setFace _face;
    ace_arsenal_currentFace = _face;
};
if (_voice != ace_arsenal_currentVoice) then {
    _unit setSpeaker _voice;
    ace_arsenal_currentVoice = _voice;
};
if (_insignia != ace_arsenal_currentInsignia) then {
    [_unit, ""] call BIS_fnc_setUnitInsignia;
    [_unit, _insignia] call BIS_fnc_setUnitInsignia;
    ace_arsenal_currentInsignia = _insignia;
};

call ace_arsenal_fnc_updateCurrentItemsList;
