#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Creates a control. Positions are design pixels relative to the parent group,
 * or screen units when the parent is the display and _absolute is set.
 *
 * Arguments:
 * 0: Parent display or controls group <DISPLAY|CONTROL>
 * 1: Class name suffix, e.g. "text" for arsenal_ui_text <STRING>
 * 2: Position [x, y, w, h] <ARRAY>
 * 3: Text <STRING> (default: "")
 * 4: Text colour <ARRAY> (default: [])
 * 5: Font <STRING> (default: "")
 * 6: Font size in design px <NUMBER> (default: -1)
 * 7: Background colour <ARRAY> (default: [])
 * 8: Position is in screen units <BOOL> (default: false)
 *
 * Return Value:
 * Control <CONTROL>
 *
 * Public: No
 */

params ["_parent", "_class", "_pos", ["_text", ""], ["_color", []], ["_font", ""], ["_size", -1], ["_bg", []], ["_absolute", false]];

private _isDisplay = _parent isEqualType displayNull;
private _display = if (_isDisplay) then {_parent} else {ctrlParent _parent};
private _ctrl = if (_isDisplay) then {
    _display ctrlCreate [(QUOTE(ADDON) + "_" + _class), -1]
} else {
    _display ctrlCreate [(QUOTE(ADDON) + "_" + _class), -1, _parent]
};
_ctrl setVariable [QGVAR(own), true];

if (_absolute) then {
    _ctrl ctrlSetPosition _pos;
} else {
    _pos params ["_x", "_y", "_w", "_h"];
    _ctrl ctrlSetPosition [PX_X(_x), PX_Y(_y), PX_X(_w), PX_Y(_h)];
};

if (_text != "") then {_ctrl ctrlSetText _text};
// Inputs and lists take the theme's text colour unless told otherwise
if (_color isEqualTo [] && {_class in ["edit", "list", "listCompact", "combo"]}) then {_color = C_TEXT};
if (_color isNotEqualTo []) then {_ctrl ctrlSetTextColor _color};
if (_font != "") then {_ctrl ctrlSetFont _font};
if (_size > 0) then {_ctrl ctrlSetFontHeight FONT(_size)};
if (_bg isNotEqualTo []) then {_ctrl ctrlSetBackgroundColor _bg};
_ctrl ctrlCommit 0;

_ctrl
