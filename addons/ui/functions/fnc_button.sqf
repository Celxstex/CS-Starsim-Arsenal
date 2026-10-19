#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Creates a flat button: background, outline, label and an invisible click area.
 *
 * Arguments:
 * 0: Parent <DISPLAY|CONTROL>
 * 1: Position [x, y, w, h] in design px <ARRAY>
 * 2: Label <STRING>
 * 3: Click code, receives [_hitControl] <CODE>
 * 4: Style: "default", "primary", "danger", "accent", "chip", "tab", "ghost" <STRING> (default: "default")
 * 5: Font size in design px <NUMBER> (default: 15)
 * 6: Font <STRING> (default: F_TITLE)
 *
 * Return Value:
 * Button parts [bg, frame, label, hit, bar] <ARRAY>
 *
 * Public: No
 */

params ["_parent", "_pos", "_label", "_onClick", ["_style", "default"], ["_size", 15], ["_font", F_TITLE]];

_pos params ["_x", "_y", "_w", "_h"];

private _bg = [_parent, "rect", _pos] call FUNC(ctrl);
private _frame = [_parent, "frame", _pos] call FUNC(ctrl);
private _text = [_parent, "textCenter", _pos, _label, [], _font, _size] call FUNC(ctrl);
private _bar = controlNull;
if (_style == "tab") then {
    _bar = [_parent, "rect", [_x, _y + _h - 3, _w, 3]] call FUNC(ctrl);
};
private _hit = [_parent, "hit", _pos] call FUNC(ctrl);

private _parts = [_bg, _frame, _text, _hit, _bar];
_hit setVariable [QGVAR(parts), _parts];
_hit setVariable [QGVAR(style), _style];
_hit ctrlAddEventHandler ["ButtonClick", _onClick];

[_parts, "normal"] call FUNC(buttonState);

_parts
