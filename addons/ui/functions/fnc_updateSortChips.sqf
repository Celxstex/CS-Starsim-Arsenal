#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Rebuilds the sort chips above the item list for the current slot.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _group = GVAR(ui) get "sortChips";
[_group] call FUNC(clearGroup);

([GVAR(slot)] call FUNC(sortMode)) params ["_mode", "_desc", "_options"];

[_group, "text", [0, 0, 40, 26], "SORT", C_DIM, F_MONO, 9] call FUNC(ctrl);

private _tips = createHashMapFromArray [
    ["NAME", "Sort by name"],
    ["MOD", "Sort by mod, then name"],
    ["MASS", "Sort by weight"],
    ["LOAD", "Sort by how much the container holds"],
    ["ARMOR", "Sort by the best protection it gives"]
];

private _pos = 42;
{
    private _w = (count _x) * 8 + 18;
    private _parts = [_group, [_pos, 0, _w, 26], _x, compile format ["['%1'] call %2", _x, QFUNC(setSort)], "chip", 10, F_MONO] call FUNC(button);
    [_parts, ["normal", "active"] select (_x == _mode)] call FUNC(buttonState);
    (_parts select 3) ctrlSetTooltip (_tips getOrDefault [_x, ""]);
    _pos = _pos + _w + 6;
} forEach _options;

private _dirW = 50;
private _dir = [_group, [LIST_W - 36 - _dirW, 0, _dirW, 26], ["ASC", "DESC"] select _desc, compile format ["['DIR'] call %1", QFUNC(setSort)], "chip", 10, F_MONO] call FUNC(button);
(_dir select 3) ctrlSetTooltip "Flip the sort direction";
