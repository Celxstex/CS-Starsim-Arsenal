#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Sets a button's visual state.
 *
 * Arguments:
 * 0: Button parts from FUNC(button) <ARRAY>
 * 1: State: "normal", "active" or "disabled" <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_parts", "_state"];
_parts params ["_bg", "_frame", "_text", "_hit", "_bar"];

private _style = _hit getVariable [QGVAR(style), "default"];
private _active = _state == "active";

// [background, outline, text]
private _colors = switch (_style) do {
    case "primary": {[C_ACCENT, C_ACCENT, C_ON_ACCENT]};
    case "danger": {[C_CARD, C_DANGER_LINE, C_DANGER]};
    case "accent": {[C_CARD, C_ACCENT, C_TEXT]};
    case "chip": {
        [[C_CARD, C_CHIP_LINE, C_SOFT], [C_ACCENT, C_ACCENT, C_ON_ACCENT]] select _active
    };
    case "tab": {
        [[C_CLEAR, C_CLEAR, C_MUTED], [C_SEL2, C_CLEAR, C_WHITE]] select _active
    };
    case "ghost": {
        [[C_CLEAR, C_CLEAR, C_MUTED], [C_CLEAR, C_CLEAR, C_WHITE]] select _active
    };
    default {
        [[C_CARD, C_BTN_LINE, C_TEXT], [C_SEL2, C_ACCENT, C_WHITE]] select _active
    };
};
_colors params ["_cBg", "_cLine", "_cText"];

if (_state == "disabled") then {
    _cText = C_DISABLED;
    if (_style == "primary") then {_cBg = C_CARD};
    _cLine = [_cLine, C_LINE] select (_cLine isNotEqualTo C_CLEAR);
};

_bg ctrlSetBackgroundColor _cBg;
_frame ctrlSetTextColor _cLine;
_text ctrlSetTextColor _cText;
_hit ctrlEnable (_state != "disabled");
if (!isNull _bar) then {
    _bar ctrlSetBackgroundColor ([C_CLEAR, C_ACCENT] select _active);
};
