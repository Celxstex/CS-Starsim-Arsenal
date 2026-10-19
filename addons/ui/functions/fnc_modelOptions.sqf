#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns a model's options and the values that exist for it in this arsenal.
 *
 * Arguments:
 * 0: Config root <STRING>
 * 1: Model <STRING>
 *
 * Return Value:
 * [[option name, label, [[value, label, image], ...]], ...] <ARRAY>
 *
 * Public: No
 */

params ["_root", "_model"];

private _variants = GVAR(models) getOrDefault [_root + "|" + _model, createHashMap];
private _def = configFile >> "XtdGearModels" >> _root >> _model;
private _fallback = configFile >> "XtdGearModels" >> "Conventional";
private _result = [];

{
    private _index = _forEachIndex;
    private _opt1 = _def >> _x;
    private _opt2 = _fallback >> _x;
    private _label = [getText (_opt1 >> "label"), getText (_opt2 >> "label"), _x] select {_x != ""} select 0;

    // Values that exist on at least one variant, in the order the model lists them
    private _present = (keys _variants) apply {_x param [_index, ""]};
    _present = _present arrayIntersect _present;
    private _order = getArray (_opt1 >> "values");
    if (_order isEqualTo []) then {_order = getArray (_opt2 >> "values")};
    private _values = (_order select {_x in _present}) + ((_present - _order) select {_x != ""});

    _result pushBack [_x, toUpper _label, _values apply {
        private _v1 = _opt1 >> _x;
        private _v2 = _opt2 >> _x;
        [
            _x,
            [getText (_v1 >> "label"), getText (_v2 >> "label"), _x] select {_x != ""} select 0,
            [getText (_v1 >> "image"), getText (_v2 >> "image")] select {_x != ""} param [0, ""]
        ]
    }];
} forEach getArray (_def >> "options");

_result
