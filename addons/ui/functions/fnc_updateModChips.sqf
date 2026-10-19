#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Rebuilds the mod filter chips above the item list.
 *
 * Arguments:
 * 0: [[item count, mod tag], ...] <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_mods"];

private _group = GVAR(ui) get "modChips";
[_group] call FUNC(clearGroup);

_mods sort false;
private _tags = [""] + ((_mods select [0, 5]) apply {_x select 1});
if (GVAR(modFilter) != "" && {!(GVAR(modFilter) in _tags)}) then {
    _tags pushBack GVAR(modFilter);
};

private _maxW = LIST_W - 36;
private _pos = 0;
{
    private _label = [_x, "ALL"] select (_x == "");
    private _w = (count _label) * 9 + 22;
    if (_pos + _w <= _maxW) then {
        private _parts = [_group, [_pos, 0, _w, 30], _label, compile format ["%1 = '%2'; call %3", QGVAR(modFilter), _x, QFUNC(fillItemList)], "chip", 11, F_MONO] call FUNC(button);
        [_parts, ["normal", "active"] select (GVAR(modFilter) == _x)] call FUNC(buttonState);
        _pos = _pos + _w + 6;
    };
} forEach _tags;
