#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Draws the full compare overlay: equipped, previewing and pinned items side by side.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _body = GVAR(ui) get "cmpBody";
[_body] call FUNC(clearGroup);

private _slot = [GVAR(slot)] call FUNC(slot);
private _root = _slot select S_ROOT;
private _tab = _slot select S_STAT;
private _width = GVAR(ui) get "compareW";

(GVAR(ui) get "cmpTitle") ctrlSetText format ["COMPARE · %1", _slot select S_LABEL];
[GVAR(ui) get "cmpDiffOnly", ["normal", "active"] select GVAR(diffOnly)] call FUNC(buttonState);

if (_root == "" || {_tab < 0}) exitWith {
    [_body, "text", [22, 20, _width - 44, 24], "Compare works on gear slots. Pick a weapon, helmet, uniform, vest, backpack or similar.", C_MUTED, F_BODY, 14] call FUNC(ctrl);
    (GVAR(ui) get "cmpCount") ctrlSetText "";
};

private _equipped = [GVAR(slot)] call FUNC(currentClass);
private _previewClass = "";
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_pKind", "_pSlot", "_pClass", "_pSub"];
    if (_pKind == "item" && {_pSlot == GVAR(slot)} && {_pSub isEqualTo ""}) then {
        _previewClass = _pClass;
    };
};
private _pins = ([GVAR(slot)] call FUNC(pinnedClasses)) - [_equipped, _previewClass];

// Columns: [tag, class, colour]. Pins fill whatever the preview leaves free.
private _columns = [["EQUIPPED", _equipped, C_SOFT]];
if (_previewClass != "") then {_columns pushBack ["PREVIEWING", _previewClass, C_ACCENT]};
{
    if (count _columns < 3) then {_columns pushBack ["PINNED", _x, C_TEXT]};
} forEach _pins;
private _hidden = count _pins - ({(_x select 0) == "PINNED"} count _columns);
(GVAR(ui) get "cmpCount") ctrlSetText format ["%1 / 3%2", count _columns, ["", format ["  +%1 PINNED", _hidden]] select (_hidden > 0)];
(GVAR(ui) get "cmpCount") ctrlSetTooltip (["", "Unpin an item or clear the preview to see the other pins"] select (_hidden > 0));

[GVAR(ui) get "cmpEquipPreview", ["disabled", "normal"] select (_previewClass != "")] call FUNC(buttonState);

private _labelW = 170;
private _colW = (_width - 44 - _labelW) / 3;
private _colX = {22 + _labelW + _this * _colW};

// ---- Column headers
{
    _x params ["_tag", "_class", "_color"];
    private _x0 = _forEachIndex call _colX;
    private _cfg = configFile >> _root >> _class;
    [_body, "rect", [_x0 + 4, 14, _colW - 8, 92], "", [], "", -1, C_CARD] call FUNC(ctrl);
    [_body, "frame", [_x0 + 4, 14, _colW - 8, 92], "", [C_CHIP_LINE, C_ACCENT] select (_tag == "PREVIEWING")] call FUNC(ctrl);
    [_body, "text", [_x0 + 14, 20, _colW - 28, 18], _tag, _color, F_MONO, 9] call FUNC(ctrl);
    if (_tag == "PINNED") then {
        private _equip = [_body, [_x0 + _colW - 4 - 128, 18, 62, 22], "EQUIP", {
            params ["_ctrl"];
            private _class = _ctrl getVariable [QGVAR(class), ""];
            private _root = ([GVAR(slot)] call FUNC(slot)) select S_ROOT;
            ["item", GVAR(slot), _class, "", getText (configFile >> _root >> _class >> "displayName")] call FUNC(preview);
            call FUNC(commit);
            call FUNC(toggleCompare);
        }, "ghost", 10, F_MONO] call FUNC(button);
        (_equip select 3) setVariable [QGVAR(class), _class];
        private _unpin = [_body, [_x0 + _colW - 4 - 66, 18, 62, 22], "UNPIN", {
            params ["_ctrl"];
            [_ctrl getVariable [QGVAR(class), ""]] call FUNC(pin);
        }, "ghost", 10, F_MONO] call FUNC(button);
        (_unpin select 3) setVariable [QGVAR(class), _class];
    };
    if (_class == "") then {
        [_body, "text", [_x0 + 14, 46, _colW - 28, 26], "Nothing", C_MUTED, F_BODY, 15] call FUNC(ctrl);
    } else {
        [_body, "picture", [_x0 + 14, 44, 44, 44], getText (_cfg >> "picture")] call FUNC(ctrl);
        private _name = [_body, "structured", [_x0 + 64, 40, _colW - 80, 44]] call FUNC(ctrl);
        _name ctrlSetStructuredText parseText format ["<t size='0.95' color='%2'>%1</t>", getText (_cfg >> "displayName"), GVAR(colorsHex) get "text"];
        _name ctrlSetTooltip format ["%1\n%2", getText (_cfg >> "displayName"), _class];
        [_body, "text", [_x0 + 64, 82, _colW - 80, 18], [_cfg] call FUNC(modTag), C_MUTED, F_MONO, 9] call FUNC(ctrl);
    };
} forEach _columns;

// ---- Rows: merge equipped-vs-each comparisons by stat title
private _cfgs = _columns apply {
    private _class = _x select 1;
    if (_class == "") then {configNull} else {configFile >> _root >> _class}
};
private _merged = []; // [title, [[bar, text], ...]]
{
    private _col = _forEachIndex;
    private _rows = ["L", _tab, _cfgs select 0, if (_col == 0) then {configNull} else {_x}] call FUNC(statRows);
    {
        _x params ["_title", "_barA", "_barB", "_textA", "_textB"];
        private _index = _merged findIf {(_x select 0) == _title};
        if (_index == -1) then {
            _index = _merged pushBack [_title, (_columns apply {[-1, ""]}), _barA >= 0 || _barB >= 0];
        };
        private _cells = (_merged select _index) select 1;
        _cells set [0, [_barA, _textA]];
        if (_col > 0) then {
            _cells set [_col, [_barB, _textB]];
        };
    } forEach _rows;
} forEach _cfgs;

// Container fit, from the weight of what's carried in it now
private _containerIndex = ["UNF", "VST", "BKP"] find GVAR(slot);
if (_containerIndex != -1) then {
    private _contents = ((getUnitLoadout CENTER) select (3 + _containerIndex)) param [1, []];
    private _used = 0;
    {
        _x params ["_class", ["_count", 1]];
        if (_class isEqualType []) then {_class = _class select 0};
        _used = _used + ([[_class] call FUNC(itemConfig)] call FUNC(itemMass)) * (_count max 1);
    } forEach _contents;
    _merged pushBack ["Kit fits?", _columns apply {
        private _class = _x select 1;
        if (_class == "") then {[-1, "-"]} else {
            private _capacity = getContainerMaxLoad _class;
            private _text = switch (true) do {
                case (_used > _capacity): {format ["No · %1 / %2", round _used, round _capacity]};
                case (_used > _capacity * 0.85): {format ["Tight · %1 / %2", round _used, round _capacity]};
                default {format ["Yes · %1 / %2", round _used, round _capacity]};
            };
            [-1, _text]
        }
    }, false];
};

private _y = 122;
private _drawn = 0;
{
    _x params ["_title", "_cells", "_hasBar"];
    private _texts = _cells apply {_x select 1};
    private _bars = _cells apply {_x select 0};
    private _same = ((_texts arrayIntersect _texts) isEqualTo [_texts select 0]) && {(_bars arrayIntersect _bars) isEqualTo [_bars select 0]};

    if (!GVAR(diffOnly) || {!_same} || {count _columns == 1}) then {
        _drawn = _drawn + 1;
        private _rowH = [34, 50] select _hasBar;
        [_body, "rect", [22, _y + _rowH - 1, _width - 44, 1], "", [], "", -1, C_CARD_LINE] call FUNC(ctrl);
        [_body, "text", [22, _y + 4, _labelW, 24], _title, C_SOFT, F_BODY, 14] call FUNC(ctrl);

        // Best: highest bar, or lowest mass
        private _best = -1;
        if (count _columns > 1) then {
            if (_title == "Mass") then {
                private _masses = _cfgs apply {[_x] call FUNC(itemMass)};
                private _min = selectMin _masses;
                if ({_x == _min} count _masses == 1) then {_best = _masses find _min};
            } else {
                if (_hasBar) then {
                    private _max = selectMax _bars;
                    if (_max >= 0 && {{_x == _max} count _bars == 1}) then {_best = _bars find _max};
                };
            };
        };

        {
            _x params ["_bar", "_text"];
            private _x0 = _forEachIndex call _colX;
            private _isBest = _forEachIndex == _best;
            private _label = [_text, "-"] select (_text == "");
            if (_isBest) then {
                _label = _label + ([" · BEST", " · LIGHTEST"] select (_title == "Mass"));
            };
            private _color = switch (true) do {
                case (_isBest): {C_ACCENT};
                case (_title == "Kit fits?" && {(_text find "No") == 0}): {C_WORSE};
                default {C_TEXT};
            };
            private _ctrl = [_body, "text", [_x0 + 10, _y + 4, _colW - 20, 22], _label, _color, F_MONO, 10] call FUNC(ctrl);
            _ctrl ctrlSetTooltip _label;
            if (_bar >= 0) then {
                [_body, "rect", [_x0 + 10, _y + 32, _colW - 20, 5], "", [], "", -1, C_TRACK] call FUNC(ctrl);
                [_body, "rect", [_x0 + 10, _y + 32, (_colW - 20) * _bar, 5], "", [], "", -1, [C_EQUIPPED, C_ACCENT] select _isBest] call FUNC(ctrl);
            };
        } forEach _cells;

        _y = _y + _rowH;
    };
} forEach _merged;

if (_drawn == 0) then {
    [_body, "text", [22, _y + 10, _width - 44, 24], "No differences. Turn off Differences only to see every stat.", C_MUTED, F_BODY, 14] call FUNC(ctrl);
};
if (count _columns == 1) then {
    [_body, "text", [22, _y + 14, _width - 44, 24], "Click an item to preview it here. Press P to pin items: pins fill the other columns.", C_MUTED, F_BODY, 14] call FUNC(ctrl);
};
