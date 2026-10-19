#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Picks a variant option value. Previews the exact variant if it exists, otherwise the
 * variant with that value that keeps the most other options the same.
 *
 * Arguments:
 * 0: Option index <NUMBER>
 * 1: Value <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_optIndex", "_value"];

private _equipped = [GVAR(slot)] call FUNC(currentClass);
private _target = _equipped;
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_pKind", "_pSlot", "_pClass", "_pSub"];
    if (_pKind == "item" && {_pSlot == GVAR(slot)} && {_pSub isEqualTo ""}) then {
        _target = _pClass;
    };
};

private _info = GVAR(itemModel) getOrDefault [_target, []];
if (_info isEqualTo []) exitWith {};
_info params ["_root", "_model", "_values"];
private _variants = GVAR(models) getOrDefault [_root + "|" + _model, createHashMap];

private _wanted = +_values;
_wanted set [_optIndex, _value];

private _class = _variants getOrDefault [_wanted, ""];
if (_class == "") then {
    private _bestScore = -1;
    {
        if ((_x param [_optIndex, ""]) == _value) then {
            private _candidate = _x;
            private _candidateClass = _y;
            private _score = 0;
            {
                if (_x == (_candidate param [_forEachIndex, ""])) then {_score = _score + 1};
            } forEach _wanted;
            if (_score > _bestScore) then {
                _bestScore = _score;
                _class = _candidateClass;
            };
        };
    } forEach _variants;
};

if (_class == "") exitWith {};

if (_class == _equipped) then {
    [true] call FUNC(revert);
} else {
    ["item", GVAR(slot), _class, "", getText (configFile >> _root >> _class >> "displayName")] call FUNC(preview);
};
