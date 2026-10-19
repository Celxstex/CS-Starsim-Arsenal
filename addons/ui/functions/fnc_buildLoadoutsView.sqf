#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the Loadouts view: sources, search, role filters and the loadout list on the left,
 * a preview banner over the world, and loadout details on the right.
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
private _viewCtrls = [];
private _leftW = LOADOUTS_LEFT_W;
private _rightW = LOADOUTS_RIGHT_W;

// ---- Left panel
private _left = [_display, "group", [0, TOP_H, _leftW, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _left;
[_left, "rect", [0, 0, _leftW, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_left, "rect", [_leftW - 1, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

private _tabW = _leftW / 4;
{
    GVAR(ui) set ["src_" + _x, [_left, [_forEachIndex * _tabW, 0, _tabW, 52], _x, compile format ["%1 = '%2'; %3 = []; call %4", QGVAR(loadoutsSource), _x, QGVAR(loadoutsSel), QFUNC(fillLoadouts)], "tab", 15] call FUNC(button)];
} forEach ["MINE", "UNIT", "SHARED", "DEFAULT"];
[_left, "rect", [0, 52, _leftW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);

[_left, "rect", [16, 66, _leftW - 32, 40], "", [], "", -1, C_INPUT] call FUNC(ctrl);
[_left, "frame", [16, 66, _leftW - 32, 40], "", C_BTN_LINE] call FUNC(ctrl);
[_left, "picture", [26, 78, 16, 16], "\a3\3DEN\Data\Displays\Display3DEN\search_start_ca.paa", C_MUTED] call FUNC(ctrl);
private _placeholder = [_left, "text", [50, 66, _leftW - 90, 40], "Search loadouts and items", C_DIM] call FUNC(ctrl);
private _search = [_left, "edit", [48, 68, _leftW - 84, 36]] call FUNC(ctrl);
_search setVariable [QGVAR(placeholder), _placeholder];
_search ctrlAddEventHandler ["KeyUp", {
    params ["_ctrl"];
    private _text = ctrlText _ctrl;
    (_ctrl getVariable QGVAR(placeholder)) ctrlShow (_text == "");
    if (_text != GVAR(loadoutsSearch)) then {
        GVAR(loadoutsSearch) = _text;
        call FUNC(fillLoadouts);
    };
}];
_search ctrlAddEventHandler ["SetFocus", {GVAR(typing) = true}];
_search ctrlAddEventHandler ["KillFocus", {GVAR(typing) = false}];
GVAR(ui) set ["loadoutsSearch", _search];

// Role chips
private _chipX = 0;
private _chipY = 116;
{
    private _w = (count _x) * 9 + 22;
    if (_chipX + _w > _leftW - 32) then {
        _chipX = 0;
        _chipY = _chipY + 36;
    };
    GVAR(ui) set ["role_" + _x, [_left, [16 + _chipX, _chipY, _w, 30], _x, compile format ["%1 = '%2'; call %3", QGVAR(loadoutsRole), _x, QFUNC(fillLoadouts)], "chip", 11, F_MONO] call FUNC(button)];
    _chipX = _chipX + _w + 6;
} forEach (["ALL"] + GVAR(roles));

private _listY = _chipY + 30 + 12;
[_left, "rect", [0, _listY, _leftW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
private _lnb = [_left, "list", [0, _listY + 1, _leftW, _panelH - _listY - 1 - 64]] call FUNC(ctrl);
_lnb ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_row"];
    if (GVAR(fillingList) || {_row < 0}) exitWith {};
    [_row] call FUNC(onLoadoutSelected);
}];
_lnb ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_row"];
    // Headings and the empty-list row have no loadout
    if (_row < 0 || {(_ctrl lnbValue [_row, 0]) < 0}) exitWith {};
    ["load"] call FUNC(loadoutAction);
}];
GVAR(ui) set ["loadoutsList", _lnb];

// Save / import
private _footY = _panelH - 64;
[_left, "rect", [0, _footY, _leftW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
[_left, [16, _footY + 12, 260, 40], "SAVE CURRENT AS", {["save"] call FUNC(showPopup)}, "accent", 15] call FUNC(button);
[_left, [284, _footY + 12, 130, 40], "IMPORT", {call FUNC(importLoadout)}, "default", 15] call FUNC(button);

// ---- Banner
private _gapMid = (_leftW + _wPx - _rightW) / 2;
private _bannerW = 600 min ((_wPx - _rightW - _leftW) - 40);
private _banner = [_display, "group", [_gapMid - _bannerW / 2, TOP_H + 40, _bannerW, 64] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _banner;
[_banner, "rect", [0, 0, _bannerW, 64], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_banner, "frame", [0, 0, _bannerW, 64], "", C_ACCENT] call FUNC(ctrl);
[_banner, "text", [18, 8, _bannerW - 160, 18], "PREVIEWING LOADOUT · NOT APPLIED", C_ACCENT, F_MONO, 10] call FUNC(ctrl);
GVAR(ui) set ["lBannerName", [_banner, "text", [18, 26, _bannerW - 160, 30], "", C_WHITE, F_TITLE, 19] call FUNC(ctrl)];
[_banner, [_bannerW - 12 - 100, 12, 100, 40], "LOAD", {["load"] call FUNC(loadoutAction)}, "primary", 15, F_HEAVY] call FUNC(button);
GVAR(ui) set ["lBanner", _banner];

// ---- Right panel
private _right = [_display, "group", [_wPx - _rightW, TOP_H, _rightW, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _right;
[_right, "rect", [0, 0, _rightW, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_right, "rect", [0, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

GVAR(ui) set ["lMeta", [_right, "text", [20, 16, _rightW - 40, 18], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];
GVAR(ui) set ["lName", [_right, "text", [20, 34, _rightW - 40, 36], "", C_WHITE, F_HEAVY, 24] call FUNC(ctrl)];
GVAR(ui) set ["lStats", [_right, "text", [20, 72, _rightW - 40, 20], "", C_SOFT, F_MONO, 11] call FUNC(ctrl)];

[_right, "text", [20, 102, 60, 30], "ROLE", C_MUTED, F_MONO, 10] call FUNC(ctrl);
private _combo = [_right, "combo", [80, 102, 200, 30]] call FUNC(ctrl);
{
    _combo lbAdd _x;
} forEach GVAR(roles);
_combo ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_index"];
    if (GVAR(fillingList) || {_index < 0}) exitWith {};
    ["role", GVAR(roles) select _index] call FUNC(loadoutAction);
}];
GVAR(ui) set ["lRole", _combo];
GVAR(ui) set ["lFav", [_right, [_rightW - 20 - 130, 102, 130, 30], "FAVOURITE [F]", {call FUNC(toggleFavourite)}, "chip", 10, F_MONO] call FUNC(button)];
[_right, "rect", [0, 144, _rightW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);

private _actionsH = 132;
GVAR(ui) set ["lSummary", [_right, "groupScroll", [0, 145, _rightW, _panelH - 145 - _actionsH - 70]] call FUNC(ctrl)];

private _warnY = _panelH - _actionsH - 66;
GVAR(ui) set ["lWarnBg", [_right, "rect", [20, _warnY, _rightW - 40, 56], "", [], "", -1, C_WARN_BG] call FUNC(ctrl)];
GVAR(ui) set ["lWarnFrame", [_right, "frame", [20, _warnY, _rightW - 40, 56], "", C_WORSE] call FUNC(ctrl)];
GVAR(ui) set ["lWarn", [_right, "textMulti", [30, _warnY + 4, _rightW - 60, 48], "", C_WARN_TEXT, F_BODY, 13] call FUNC(ctrl)];

private _actY = _panelH - _actionsH + 8;
GVAR(ui) set ["lLoad", [_right, [20, _actY, _rightW - 40, 52], "LOAD THIS LOADOUT", {["load"] call FUNC(loadoutAction)}, "primary", 17, F_HEAVY] call FUNC(button)];
private _btnW = (_rightW - 40 - 16) / 3;
GVAR(ui) set ["lRename", [_right, [20, _actY + 60, _btnW, 44], "RENAME", {["rename"] call FUNC(showPopup)}, "default", 15] call FUNC(button)];
GVAR(ui) set ["lShare", [_right, [20 + _btnW + 8, _actY + 60, _btnW, 44], "SHARE", {["share"] call FUNC(loadoutAction)}, "default", 15] call FUNC(button)];
GVAR(ui) set ["lDelete", [_right, [20 + 2 * (_btnW + 8), _actY + 60, _btnW, 44], "DELETE", {["delete"] call FUNC(loadoutAction)}, "danger", 15] call FUNC(button)];
GVAR(ui) set ["lRight", _right];

GVAR(ui) set ["view_loadouts", _viewCtrls];
