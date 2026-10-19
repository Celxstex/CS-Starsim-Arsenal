#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Reads the colour settings from the addon options and works out every colour the
 * UI uses (see the C_ macros in defines.hpp). In-between shades are mixed from the
 * main colours so any theme stays consistent.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// Setting value as [r, g, b, a]
private _fnc_get = {
    params ["_setting", "_default"];
    private _color = +(missionNamespace getVariable [_setting, _default]);
    if !(_color isEqualTypeAll 0 && {count _color in [3, 4]}) then {_color = +_default};
    if (count _color == 3) then {_color pushBack 1};
    _color
};
// Mix two colours: _t = 0 gives _a, 1 gives _b. Alpha is set separately.
private _fnc_mix = {
    params ["_a", "_b", "_t", ["_alpha", 1]];
    ([0, 1, 2] apply {((_a select _x) * (1 - _t)) + ((_b select _x) * _t)}) + [_alpha]
};
private _fnc_alpha = {
    params ["_color", "_alpha"];
    (_color select [0, 3]) + [_alpha]
};

private _accent = [QGVAR(accentColor), DEF_ACCENT] call _fnc_get;
private _text = [QGVAR(textColor), DEF_TEXT] call _fnc_get;
private _muted = [QGVAR(mutedColor), DEF_MUTED] call _fnc_get;
private _panel = [QGVAR(panelColor), DEF_PANEL] call _fnc_get;
private _bar = [QGVAR(barColor), DEF_BAR] call _fnc_get;
private _card = [QGVAR(cardColor), DEF_CARD] call _fnc_get;
private _line = [QGVAR(lineColor), DEF_LINE] call _fnc_get;
private _warning = [QGVAR(warningColor), DEF_WARNING] call _fnc_get;
private _white = [1, 1, 1, 1];

// Text on an accent background: dark on a light accent, white on a dark one
_accent params ["_r", "_g", "_b"];
private _luminance = 0.2126 * _r + 0.7152 * _g + 0.0722 * _b;

GVAR(colors) = createHashMapFromArray [
    ["accent", [_accent, 1] call _fnc_alpha],
    ["text", [_text, 1] call _fnc_alpha],
    ["muted", [_muted, 1] call _fnc_alpha],
    ["soft", [_text, _muted, 0.5] call _fnc_mix],
    ["dim", [_muted, _card, 0.3] call _fnc_mix],
    ["disabled", [_muted, _card, 0.55] call _fnc_mix],
    ["bright", [_text, _white, 0.75] call _fnc_mix],
    ["onAccent", [[1, 1, 1, 1], [0.020, 0.031, 0.051, 1]] select (_luminance > 0.45)],
    ["warning", [_warning, 1] call _fnc_alpha],
    ["warnBg", [_bar, _warning, 0.08, 0.95] call _fnc_mix],
    ["warnText", [_warning, _white, 0.6] call _fnc_mix],
    ["bar", _bar],
    ["panel", _panel],
    ["overlay", [_panel, ((_panel select 3) + 0.06) min 1] call _fnc_alpha],
    ["variantBg", [_panel, _accent, 0.03, ((_panel select 3) + 0.05) min 1] call _fnc_mix],
    ["line", [_line, 1] call _fnc_alpha],
    ["card", [_card, 1] call _fnc_alpha],
    ["cardLine", [_card, _line, 0.75] call _fnc_mix],
    ["sel", [_card, _accent, 0.07] call _fnc_mix],
    ["input", [_card, _bar, 0.65] call _fnc_mix],
    ["chipLine", [_line, _accent, 0.08] call _fnc_mix],
    ["btnLine", [_line, _text, 0.06] call _fnc_mix],
    ["equipped", [_card, _muted, 0.48] call _fnc_mix],
    ["track", [_card, _line, 0.5] call _fnc_mix]
];

// Hex versions for structured text
private _fnc_hex = {
    params ["_color"];
    private _digits = "0123456789ABCDEF";
    "#" + (((_color select [0, 3]) apply {
        private _v = round (((_x max 0) min 1) * 255);
        (_digits select [floor (_v / 16), 1]) + (_digits select [_v mod 16, 1])
    }) joinString "")
};
GVAR(colorsHex) = createHashMapFromArray [
    ["text", [_text] call _fnc_hex],
    ["muted", [_muted] call _fnc_hex]
];
