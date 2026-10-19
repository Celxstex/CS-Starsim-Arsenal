#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Draws stat rows (from FUNC(statRows)) into a scrolling group: label, values and
 * two bars, equipped above preview. Better and worse are coloured.
 *
 * Arguments:
 * 0: Controls group <CONTROL>
 * 1: Rows <ARRAY>
 * 2: Group width in design px <NUMBER>
 * 3: Show the B column <BOOL>
 * 4: Text when there are no rows <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_group", "_rows", "_width", "_showB", ["_emptyText", ""]];

[_group] call FUNC(clearGroup);

if (_rows isEqualTo []) exitWith {
    [_group, "text", [22, 14, _width - 44, 24], _emptyText, C_MUTED, F_BODY, 14] call FUNC(ctrl);
};

private _barW = _width - 44;
private _y = 10;

{
    _x params ["_title", "_barA", "_barB", "_textA", "_textB", "_verdict"];
    private _color = switch (_verdict) do {
        case 1: {C_ACCENT};
        case -1: {C_WORSE};
        default {C_MUTED};
    };

    [_group, "text", [22, _y, 200, 22], _title, C_SOFT, F_BODY, 14] call FUNC(ctrl);

    private _value = if (_showB && {_textB != "" || _barB >= 0}) then {
        private _a = [_textA, "-"] select (_textA == "");
        private _b = [_textB, "-"] select (_textB == "");
        if (_a == _b) then {_a} else {format ["%1  >  %2", _a, _b]}
    } else {
        _textA
    };
    private _valueCtrl = [_group, "textRight", [200, _y, _barW - 178, 22], _value, [C_TEXT, _color] select (_verdict != 0), F_MONO, 10] call FUNC(ctrl);
    _valueCtrl ctrlSetTooltip _value;

    if (_barA >= 0 || _barB >= 0) then {
        [_group, "rect", [22, _y + 26, _barW, 5], "", [], "", -1, C_TRACK] call FUNC(ctrl);
        [_group, "rect", [22, _y + 26, _barW * (_barA max 0), 5], "", [], "", -1, C_EQUIPPED] call FUNC(ctrl);
        if (_showB && {_barB >= 0}) then {
            [_group, "rect", [22, _y + 33, _barW, 5], "", [], "", -1, C_TRACK] call FUNC(ctrl);
            [_group, "rect", [22, _y + 33, _barW * _barB, 5], "", [], "", -1, [C_EQUIPPED, _color] select (_verdict != 0)] call FUNC(ctrl);
        };
        _y = _y + 48;
    } else {
        _y = _y + 30;
    };
} forEach _rows;

// Legend
if (_showB) then {
    _y = _y + 4;
    {
        _x params ["_label", "_color"];
        [_group, "rect", [22 + _forEachIndex * 96, _y + 7, 8, 8], "", [], "", -1, _color] call FUNC(ctrl);
        [_group, "text", [34 + _forEachIndex * 96, _y, 80, 22], _label, C_MUTED, F_BODY, 12] call FUNC(ctrl);
    } forEach [["Equipped", C_EQUIPPED], ["Better", C_ACCENT], ["Worse", C_WORSE]];
};
