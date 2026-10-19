#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Draws the variant options for the previewed (or worn) item in the current slot.
 * Options come from ACE Arsenal Extended config. A value that needs other options to change
 * as well is dimmed; picking it jumps to the closest variant that has it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Height of the section in design px, 0 when hidden <NUMBER>
 *
 * Public: No
 */

private _group = GVAR(ui) get "variants";
[_group] call FUNC(clearGroup);

private _slot = [GVAR(slot)] call FUNC(slot);
private _hide = {
    _group ctrlShow false;
    0
};
if !((_slot select S_KIND) in ["weapon", "headgear", "goggles", "nvg", "uniform", "vest", "backpack", "bino"]) exitWith _hide;

private _equipped = [GVAR(slot)] call FUNC(currentClass);
private _target = _equipped;
private _isPreview = false;
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_pKind", "_pSlot", "_pClass", "_pSub"];
    if (_pKind == "item" && {_pSlot == GVAR(slot)} && {_pSub isEqualTo ""}) then {
        _target = _pClass;
        _isPreview = true;
    };
};

private _info = GVAR(itemModel) getOrDefault [_target, []];
if (_info isEqualTo []) exitWith _hide;
_info params ["_root", "_model", "_values"];

private _options = [_root, _model] call FUNC(modelOptions);
if (_options isEqualTo []) exitWith _hide;
private _variants = GVAR(models) getOrDefault [_root + "|" + _model, createHashMap];

private _width = STATS_W;
private _inner = _width - 44;
_group ctrlShow true;

private _bg = [_group, "rect", [0, 0, _width, 10], "", [], "", -1, C_VARIANT_BG] call FUNC(ctrl);
[_group, "text", [22, 12, 200, 28], "VARIANTS", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
private _combos = 1;
{_combos = _combos * (count (_x select 2) max 1)} forEach _options;
[_group, "textRight", [200, 16, _width - 222, 22], format ["%1 / %2 COMBOS", count _variants, _combos], C_MUTED, F_MONO, 10] call FUNC(ctrl);

// Whose options are shown
private _sameModel = _isPreview && {((GVAR(itemModel) getOrDefault [_equipped, []]) param [1, ""]) == _model};
private _tag = switch (true) do {
    case (_sameModel): {"EQUIPPED · CHANGING"};
    case (_isPreview): {"PREVIEW"};
    default {"EQUIPPED"};
};
private _tagW = (count _tag) * 8 + 16;
[_group, "rect", [22, 48, _tagW, 22], "", [], "", -1, [C_CHIP_LINE, C_ACCENT] select _isPreview] call FUNC(ctrl);
[_group, "textCenter", [22, 48, _tagW, 22], _tag, [C_TEXT, C_ON_ACCENT] select _isPreview, F_MONO, 9] call FUNC(ctrl);
[_group, "text", [30 + _tagW, 46, _inner - _tagW - 8, 26], getText (configFile >> _root >> _target >> "displayName"), C_TEXT, F_BODY, 15] call FUNC(ctrl);

private _y = 82;
{
    _x params ["_optName", "_label", "_optValues"];
    private _optIndex = _forEachIndex;
    private _current = _values param [_optIndex, ""];

    [_group, "text", [22, _y, _inner, 18], _label, C_MUTED, F_MONO, 10] call FUNC(ctrl);
    _y = _y + 22;

    private _xPos = 0;
    {
        _x params ["_value", "_valueLabel", "_image"];
        private _w = ((count _valueLabel) * 8 + 26 + ([0, 20] select (_image != ""))) max 52;
        if (_xPos > 0 && {_xPos + _w > _inner}) then {
            _xPos = 0;
            _y = _y + 38;
        };

        private _selected = _value == _current;
        private _wanted = +_values;
        _wanted set [_optIndex, _value];
        private _exact = _wanted in _variants;

        private _code = compile format ["[%1, %2] call %3", _optIndex, str _value, QFUNC(onVariantPick)];
        private _parts = [_group, [22 + _xPos, _y, _w, 32], _valueLabel, _code, "default", 13, F_BODY] call FUNC(button);
        [_parts, ["normal", "active"] select _selected] call FUNC(buttonState);
        if (!_selected && !_exact) then {
            (_parts select 2) ctrlSetTextColor C_DIM;
            (_parts select 1) ctrlSetTextColor C_LINE;
            (_parts select 3) ctrlSetTooltip "Changes other options too";
        };
        if (_image != "") then {
            (_parts select 2) ctrlSetPositionX PX_X(22 + _xPos + 10);
            (_parts select 2) ctrlCommit 0;
            [_group, "picture", [22 + _xPos + 8, _y + 9, 14, 14], _image] call FUNC(ctrl);
        };
        _xPos = _xPos + _w + 6;
    } forEach _optValues;

    _y = _y + 42;
} forEach _options;

[_group, "text", [22, _y, _inner, 18], format ["CLASS · %1", _target], C_DIM, F_MONO, 9] call FUNC(ctrl);
_y = _y + 28;

[_group, "rect", [0, _y - 1, _width, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
_bg ctrlSetPositionH PX_Y(_y);
_bg ctrlCommit 0;
_group ctrlSetPositionH PX_Y(_y);
_group ctrlCommit 0;

_y
