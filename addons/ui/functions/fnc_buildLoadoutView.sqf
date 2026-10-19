#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the Loadout view: slot rail, item list, preview banner, camera bar and the
 * variants / compare / load panel on the right.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display"];

GVAR(screenPx) params ["_wPx", "_hPx"];
private _panelH = _hPx - TOP_H - FOOT_H;
private _fnc_abs = {
    params ["_x", "_y", "_w", "_h"];
    [safeZoneX + PX_X(_x), safeZoneY + PX_Y(_y), PX_X(_w), PX_Y(_h)]
};

// Collapse the right panel when the open area for the character would get too narrow
private _leftW = RAIL_W + LIST_W;
private _collapsed = (_wPx - _leftW - STATS_W) < (MIN_GAP_PCT * _wPx);
GVAR(statsCollapsed) = _collapsed;
private _gapEnd = [_wPx - STATS_W, _wPx - 36] select _collapsed;
GVAR(gapLoadout) = [_leftW, _gapEnd];

private _viewCtrls = [];

// ---- Slot rail
private _rail = [_display, "group", [0, TOP_H, RAIL_W, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _rail;
[_rail, "rect", [0, 0, RAIL_W, _panelH], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_rail, "rect", [RAIL_W - 1, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

private _count = count GVAR(slots);
private _btnH = ((_panelH - 24 - 6 * (_count - 1)) / _count) min 74;
{
    private _id = _x select S_ID;
    private _y = 12 + _forEachIndex * (_btnH + 6);
    private _parts = [_rail, [12, _y, RAIL_W - 24, _btnH], "", compile format ["['%1'] call %2", _id, QFUNC(selectSlot)], "default"] call FUNC(button);
    private _code = [_rail, "textCenter", [12, _y + _btnH / 2 - 17, RAIL_W - 24, 16], _id, C_MUTED, F_MONO, 10] call FUNC(ctrl);
    private _short = [_rail, "textCenter", [12, _y + _btnH / 2 - 1, RAIL_W - 24, 18], _x select S_SHORT, C_SOFT, F_TITLE, 11] call FUNC(ctrl);
    private _dot = [_rail, "rect", [RAIL_W - 24 - 10, _y + 6, 5, 5], "", [], "", -1, C_CHIP_LINE] call FUNC(ctrl);
    // Keep the click area on top of the labels
    ctrlDelete (_parts select 3);
    private _hit = [_rail, "hit", [12, _y, RAIL_W - 24, _btnH]] call FUNC(ctrl);
    _hit ctrlAddEventHandler ["ButtonClick", compile format ["['%1'] call %2", _id, QFUNC(selectSlot)]];
    _hit ctrlSetTooltip (_x select S_LABEL);
    _parts set [3, _hit];
    _hit setVariable [QGVAR(parts), _parts];
    _hit setVariable [QGVAR(style), "default"];
    GVAR(ui) set ["slot_" + _id, [_parts, _code, _short, _dot]];
} forEach GVAR(slots);

// ---- Item list
private _list = [_display, "group", [RAIL_W, TOP_H, LIST_W, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _list;
[_list, "rect", [0, 0, LIST_W, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_list, "rect", [LIST_W - 1, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

GVAR(ui) set ["listTitle", [_list, "text", [18, 16, 300, 32], "", C_WHITE, F_TITLE, 21] call FUNC(ctrl)];
GVAR(ui) set ["listCount", [_list, "textRight", [250, 22, LIST_W - 268, 22], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];

[_list, "rect", [18, 58, LIST_W - 36, 40], "", [], "", -1, C_INPUT] call FUNC(ctrl);
[_list, "frame", [18, 58, LIST_W - 36, 40], "", C_BTN_LINE] call FUNC(ctrl);
[_list, "picture", [28, 70, 16, 16], "\a3\3DEN\Data\Displays\Display3DEN\search_start_ca.paa", C_MUTED] call FUNC(ctrl);
private _placeholder = [_list, "text", [52, 58, LIST_W - 90, 40], "Search name, class or mod", C_DIM] call FUNC(ctrl);
private _search = [_list, "edit", [50, 60, LIST_W - 86 - 34, 36]] call FUNC(ctrl);
_search setVariable [QGVAR(placeholder), _placeholder];
_search ctrlAddEventHandler ["KeyUp", {
    params ["_ctrl"];
    private _text = ctrlText _ctrl;
    (_ctrl getVariable QGVAR(placeholder)) ctrlShow (_text == "");
    [GVAR(ui) get "searchClear", _text != ""] call FUNC(buttonShow);
    if (_text != GVAR(search)) then {
        GVAR(search) = _text;
        call FUNC(fillItemList);
    };
}];
_search ctrlAddEventHandler ["SetFocus", {GVAR(typing) = true}];
_search ctrlAddEventHandler ["KillFocus", {GVAR(typing) = false}];
GVAR(ui) set ["search", _search];

private _clear = [_list, [LIST_W - 18 - 38, 62, 32, 32], "X", {
    private _search = GVAR(ui) get "search";
    _search ctrlSetText "";
    (_search getVariable QGVAR(placeholder)) ctrlShow true;
    [GVAR(ui) get "searchClear", false] call FUNC(buttonShow);
    GVAR(search) = "";
    call FUNC(fillItemList);
}, "ghost", 13] call FUNC(button);
(_clear select 3) ctrlSetTooltip "Clear search";
[_clear, false] call FUNC(buttonShow);
GVAR(ui) set ["searchClear", _clear];

GVAR(ui) set ["modChips", [_list, "group", [18, 108, LIST_W - 36, 30]] call FUNC(ctrl)];
GVAR(ui) set ["sortChips", [_list, "group", [18, 144, LIST_W - 36, 26]] call FUNC(ctrl)];
GVAR(ui) set ["cargoChips", [_list, "group", [18, 178, LIST_W - 36, 30]] call FUNC(ctrl)];
GVAR(ui) set ["cargoCats", [_list, "group", [18, 214, LIST_W - 36, 26]] call FUNC(ctrl)];
GVAR(ui) set ["listLine", [_list, "rect", [0, 177, LIST_W, 1], "", [], "", -1, C_LINE] call FUNC(ctrl)];

private _lnb = [_list, "list", [0, 178, LIST_W, _panelH - 178]] call FUNC(ctrl);
_lnb ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_row"];
    if (GVAR(fillingList)) exitWith {};
    [_ctrl, _row] call FUNC(onItemSelected);
}];
_lnb ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_row"];
    [_ctrl, _row] call FUNC(onItemDblClick);
}];
GVAR(ui) set ["itemList", _lnb];
GVAR(ui) set ["listPanelH", _panelH];

// Cargo controls (only shown for the ITEMS slot)
private _cargoY = _panelH - CARGO_BAR_H;
private _cargoBar = [_list, "group", [0, _cargoY, LIST_W, CARGO_BAR_H]] call FUNC(ctrl);
[_cargoBar, "rect", [0, 0, LIST_W, CARGO_BAR_H], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_cargoBar, "rect", [0, 0, LIST_W, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
GVAR(ui) set ["cargoInfo", [_cargoBar, "text", [18, 8, LIST_W - 36 - 150, 32], "", C_SOFT, F_BODY, 13] call FUNC(ctrl)];

// Type an amount: sets exactly how many are in the container
[_cargoBar, "rect", [LIST_W - 18 - 60 - 6 - 80, 8, 80, 32], "", [], "", -1, C_INPUT] call FUNC(ctrl);
[_cargoBar, "frame", [LIST_W - 18 - 60 - 6 - 80, 8, 80, 32], "", C_BTN_LINE] call FUNC(ctrl);
private _qty = [_cargoBar, "edit", [LIST_W - 18 - 60 - 6 - 76, 10, 72, 28]] call FUNC(ctrl);
_qty ctrlSetTooltip "Type how many you want in the container, then ENTER or SET";
_qty ctrlAddEventHandler ["SetFocus", {GVAR(typing) = true}];
_qty ctrlAddEventHandler ["KillFocus", {GVAR(typing) = false}];
GVAR(ui) set ["cargoQty", _qty];
[_cargoBar, [LIST_W - 18 - 60, 8, 60, 32], "SET", {call FUNC(cargoSetCount)}, "accent", 14] call FUNC(button) select 3 ctrlSetTooltip "Set the amount to the number typed";

// Remove all, remove 5, remove 1 | add 1, add 5, fill
private _cargoX = LIST_W - 18 - (52 + 40 + 40 + 40 + 40 + 52 + 5 * 6);
{
    _x params ["_label", "_delta", "_w", "_style", "_tip"];
    [_cargoBar, [_cargoX, 48, _w, 40], _label, compile format ["[%1] call %2", _delta, QFUNC(cargoChange)], _style, [14, 18] select (_w == 40)] call FUNC(button) select 3 ctrlSetTooltip _tip;
    _cargoX = _cargoX + _w + 6;
} forEach [
    ["-ALL", -1000, 52, "danger", "Remove all of this item (CTRL + LEFT)"],
    ["-5", -5, 40, "default", "Remove five (SHIFT + LEFT)"],
    ["-", -1, 40, "default", "Remove one (LEFT)"],
    ["+", 1, 40, "accent", "Add one (RIGHT)"],
    ["+5", 5, 40, "default", "Add five (SHIFT + RIGHT)"],
    ["FILL", 1000, 52, "default", "Add as many as fit (CTRL + RIGHT)"]
];
GVAR(ui) set ["cargoBar", _cargoBar];

// ---- Preview banner and hint, centred on the open area
private _gapMid = (_leftW + _gapEnd) / 2;
private _bannerW = 600 min ((_gapEnd - _leftW) - 40);
private _banner = [_display, "group", [_gapMid - _bannerW / 2, TOP_H + 40, _bannerW, 64] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _banner;
[_banner, "rect", [0, 0, _bannerW, 64], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_banner, "frame", [0, 0, _bannerW, 64], "", C_ACCENT] call FUNC(ctrl);
GVAR(ui) set ["bannerLabel", [_banner, "text", [18, 8, _bannerW - 260, 18], "PREVIEWING · NOT EQUIPPED", C_ACCENT, F_MONO, 10] call FUNC(ctrl)];
GVAR(ui) set ["bannerName", [_banner, "text", [18, 26, _bannerW - 260, 30], "", C_WHITE, F_TITLE, 19] call FUNC(ctrl)];
[_banner, [_bannerW - 12 - 100 - 8 - 100, 12, 100, 40], "REVERT", {[true] call FUNC(revert)}, "default", 15] call FUNC(button);
[_banner, [_bannerW - 12 - 100, 12, 100, 40], "EQUIP", {call FUNC(commit)}, "primary", 15, F_HEAVY] call FUNC(button);
GVAR(ui) set ["banner", _banner];

private _hintW = 520 min ((_gapEnd - _leftW) - 40);
private _hint = [_display, "textCenter", [_gapMid - _hintW / 2, TOP_H + 52, _hintW, 40] call _fnc_abs, "Click an item to preview it · double-click to equip", C_SOFT, F_BODY, 15, C_BAR_BG, true] call FUNC(ctrl);
_viewCtrls pushBack _hint;
GVAR(ui) set ["bannerHint", _hint];

// ---- Camera bar
private _camW = 448;
private _camY = _hPx - FOOT_H - 16 - 56;
private _cam = [_display, "group", [_gapMid - _camW / 2, _camY, _camW, 56] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _cam;
[_cam, "rect", [0, 0, _camW, 56], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_cam, "frame", [0, 0, _camW, 56], "", C_LINE] call FUNC(ctrl);
[_cam, [6, 6, 44, 44], "<", {[-45] call FUNC(camRotate)}, "default", 18] call FUNC(button) select 3 ctrlSetTooltip "Rotate left";
[_cam, [54, 6, 44, 44], ">", {[45] call FUNC(camRotate)}, "default", 18] call FUNC(button) select 3 ctrlSetTooltip "Rotate right";
[_cam, [102, 6, 168, 44], "FOCUS SLOT", {[[GVAR(slot)] call FUNC(slot) select S_CAM] call FUNC(camPreset)}, "default", 15] call FUNC(button);
[_cam, [274, 6, 168, 44], "FULL BODY", {["full"] call FUNC(camPreset)}, "default", 15] call FUNC(button);

private _camText = [_display, "text", [_gapMid - _camW / 2, _camY - 24, _camW, 18] call _fnc_abs, "", C_SOFT, F_MONO, 10, [], true] call FUNC(ctrl);
_viewCtrls pushBack _camText;
GVAR(ui) set ["camText", _camText];

// ---- Right panel
private _right = [_display, "group", [_wPx - STATS_W, TOP_H, STATS_W, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _right;
[_right, "rect", [0, 0, STATS_W, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_right, "rect", [0, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);
GVAR(ui) set ["rightPanel", _right];
GVAR(ui) set ["rightPanelH", _panelH];

GVAR(ui) set ["variants", [_right, "group", [0, 0, STATS_W, 10]] call FUNC(ctrl)];

private _cmpHead = [_right, "group", [0, 0, STATS_W, 124]] call FUNC(ctrl);
[_cmpHead, "text", [22, 14, 200, 28], "COMPARE", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
GVAR(ui) set ["btnFullCompare", [_cmpHead, [STATS_W - 22 - 170, 14, 170, 28], "FULL COMPARE [C]", {call FUNC(toggleCompare)}, "ghost", 13] call FUNC(button)];
GVAR(ui) set ["btnPin", [_cmpHead, [STATS_W - 22 - 170 - 4 - 110, 14, 110, 28], "PIN [P]", {call FUNC(pin)}, "ghost", 13] call FUNC(button)];
[_cmpHead, "rect", [22, 52, 212, 60], "", [], "", -1, C_CARD] call FUNC(ctrl);
[_cmpHead, "frame", [22, 52, 212, 60], "", C_CHIP_LINE] call FUNC(ctrl);
[_cmpHead, "text", [32, 58, 190, 16], "EQUIPPED", C_MUTED, F_MONO, 9] call FUNC(ctrl);
GVAR(ui) set ["cmpCurName", [_cmpHead, "text", [32, 76, 196, 30], "", C_TEXT, F_BODY, 15] call FUNC(ctrl)];
[_cmpHead, "rect", [246, 52, 212, 60], "", [], "", -1, C_CARD] call FUNC(ctrl);
GVAR(ui) set ["cmpPrevFrame", [_cmpHead, "frame", [246, 52, 212, 60], "", C_CHIP_LINE] call FUNC(ctrl)];
[_cmpHead, "text", [256, 58, 190, 16], "PREVIEW", C_ACCENT, F_MONO, 9] call FUNC(ctrl);
GVAR(ui) set ["cmpPrevName", [_cmpHead, "text", [256, 76, 196, 30], "", C_TEXT, F_BODY, 15] call FUNC(ctrl)];
GVAR(ui) set ["cmpHead", _cmpHead];

GVAR(ui) set ["stats", [_right, "groupScroll", [0, 124, STATS_W, 100]] call FUNC(ctrl)];

// ITEMS slot: container contents in place of compare and stats
private _contents = [_right, "groupScroll", [0, 0, STATS_W, _panelH - 236]] call FUNC(ctrl);
_contents ctrlShow false;
GVAR(ui) set ["contents", _contents];

// Load section, pinned to the bottom of the panel
private _loadH = 236;
private _load = [_right, "group", [0, _panelH - _loadH, STATS_W, _loadH]] call FUNC(ctrl);
[_load, "rect", [0, 0, STATS_W, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
[_load, "text", [22, 12, 200, 28], "LOAD", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
GVAR(ui) set ["loadMass", [_load, "textRight", [200, 14, STATS_W - 222, 24], "", C_TEXT, F_MONO, 12] call FUNC(ctrl)];
{
    private _y = 50 + _forEachIndex * 48;
    [_load, "text", [22, _y, 200, 20], _x, C_SOFT, F_BODY, 14] call FUNC(ctrl);
    private _txt = [_load, "textRight", [200, _y, STATS_W - 222, 20], "", C_SOFT, F_MONO, 10] call FUNC(ctrl);
    [_load, "rect", [22, _y + 26, STATS_W - 44, 6], "", [], "", -1, C_TRACK] call FUNC(ctrl);
    private _bar = [_load, "rect", [22, _y + 26, 0, 6], "", [], "", -1, C_ACCENT] call FUNC(ctrl);
    // Jumps to the ITEMS slot with this container picked
    private _pack = [_load, [110, _y - 3, 100, 24], "PACK ITEMS", compile format ["%1 = %2; ['CRG'] call %3", QGVAR(cargoTarget), _forEachIndex, QFUNC(selectSlot)], "accent", 10, F_MONO] call FUNC(button);
    (_pack select 3) ctrlSetTooltip format ["Add, remove and move items in your %1", toLowerANSI _x];
    GVAR(ui) set ["load_" + str _forEachIndex, [_txt, _bar, _pack]];
} forEach ["Uniform", "Vest", "Backpack"];
[_load, "text", [22, 198, 200, 24], "Carry load", C_SOFT, F_BODY, 14] call FUNC(ctrl);
GVAR(ui) set ["loadTier", [_load, "textRight", [200, 198, STATS_W - 222, 24], "", C_SOFT, F_BODY, 14] call FUNC(ctrl)];
GVAR(ui) set ["loadSection", _load];
GVAR(ui) set ["loadH", _loadH];

// Collapsed mode: a tab on the right edge opens the panel over the world
private _statsTab = [_display, "group", [_wPx - 36, TOP_H + 160, 36, 140] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _statsTab;
[_statsTab, [0, 0, 36, 140], "S", {GVAR(statsPeek) = !GVAR(statsPeek); call FUNC(updateSidePanel)}, "accent", 16] call FUNC(button) select 3 ctrlSetTooltip "Show stats";
GVAR(ui) set ["statsTab", _statsTab];

// ---- Label that follows the mouse while dragging an item between containers
private _ghost = [_display, "text", [0, 0, 360, 30] call _fnc_abs, "", C_SOFT, F_BODY, 14, C_BAR_BG, true] call FUNC(ctrl);
_ghost ctrlEnable false;
_ghost ctrlShow false;
GVAR(ui) set ["dragGhost", _ghost];
// The control that started the drag normally gets the release; this catches the rest
_display displayAddEventHandler ["MouseButtonUp", {
    if ((_this select 1) == 0) then {call FUNC(dragEnd)};
}];

// ---- Full compare overlay
[_display, _panelH] call FUNC(buildCompare);
_viewCtrls pushBack (GVAR(ui) get "compare");

GVAR(ui) set ["view_loadout", _viewCtrls];
