#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the Weapon view: weapon tabs, attachment points and compatible items on the left,
 * weapon stats and magazines on the right.
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
private _leftW = WEAPON_LEFT_W;
private _rightW = WEAPON_RIGHT_W;

// ---- Left panel
private _left = [_display, "group", [0, TOP_H, _leftW, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _left;
[_left, "rect", [0, 0, _leftW, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_left, "rect", [_leftW - 1, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

private _tabW = _leftW / 3;
{
    _x params ["_id", "_label"];
    GVAR(ui) set ["wtab_" + _id, [_left, [_forEachIndex * _tabW, 0, _tabW, 52], _label, compile format ["['%1'] call %2", _id, QFUNC(selectWeapon)], "tab", 15] call FUNC(button)];
} forEach [["PRI", "PRIMARY"], ["HGN", "HANDGUN"], ["LCH", "LAUNCHER"]];
[_left, "rect", [0, 52, _leftW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);

// Current weapon card
[_left, "rect", [18, 66, _leftW - 36, 72], "", [], "", -1, C_CARD] call FUNC(ctrl);
[_left, "frame", [18, 66, _leftW - 36, 72], "", C_CARD_LINE] call FUNC(ctrl);
GVAR(ui) set ["wPicture", [_left, "picture", [28, 74, 112, 56], ""] call FUNC(ctrl)];
GVAR(ui) set ["wName", [_left, "text", [150, 76, _leftW - 186 - 120, 28], "", C_WHITE, F_TITLE, 18] call FUNC(ctrl)];
GVAR(ui) set ["wClass", [_left, "text", [150, 104, _leftW - 186 - 120, 22], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];
// Ammo carried for this weapon
GVAR(ui) set ["wMagCount", [_left, "textRight", [_leftW - 28 - 130, 76, 130, 28], "", C_TEXT, F_TITLE, 16] call FUNC(ctrl)];
GVAR(ui) set ["wRounds", [_left, "textRight", [_leftW - 28 - 130, 104, 130, 22], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];

[_left, "text", [18, 150, 300, 20], "ATTACHMENT SLOTS", C_MUTED, F_MONO, 10] call FUNC(ctrl);
{
    private _y = 174 + _forEachIndex * 52;
    private _parts = [_left, [18, _y, _leftW - 36, 46], "", compile format ["[%1] call %2", _forEachIndex, QFUNC(selectAttachPoint)], "default"] call FUNC(button);
    private _label = [_left, "text", [30, _y, 150, 46], format ["%1  %2", _forEachIndex + 1, _x], C_SOFT, F_TITLE, 14] call FUNC(ctrl);
    private _current = [_left, "text", [180, _y, _leftW - 36 - 162 - 60, 46], "", C_TEXT, F_BODY, 14] call FUNC(ctrl);
    private _count = [_left, "textRight", [_leftW - 18 - 70, _y, 58, 46], "", C_MUTED, F_MONO, 10] call FUNC(ctrl);
    ctrlDelete (_parts select 3);
    private _hit = [_left, "hit", [18, _y, _leftW - 36, 46]] call FUNC(ctrl);
    _hit ctrlAddEventHandler ["ButtonClick", compile format ["[%1] call %2", _forEachIndex, QFUNC(selectAttachPoint)]];
    _hit setVariable [QGVAR(parts), _parts];
    _hit setVariable [QGVAR(style), "default"];
    _parts set [3, _hit];
    GVAR(ui) set ["wpoint_" + str _forEachIndex, [_parts, _label, _current, _count]];
} forEach ["OPTIC", "MUZZLE", "SIDE RAIL", "UNDERBARREL", "MAGAZINE"];

private _listY = 174 + 5 * 52 + 12;
GVAR(ui) set ["wCompatTitle", [_left, "text", [18, _listY, 400, 20], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];
[_left, "rect", [0, _listY + 27, _leftW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
private _lnb = [_left, "list", [0, _listY + 28, _leftW, _panelH - _listY - 28]] call FUNC(ctrl);
_lnb ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_row"];
    if (GVAR(fillingList) || {_row < 0}) exitWith {};
    private _class = _ctrl lnbData [_row, 0];
    private _index = [2, 0, 1, 3, 4] select GVAR(attachPoint);
    ["attachment", GVAR(weaponTab), _class, _index, [_ctrl lnbText [_row, 1], "Nothing"] select (_class == "")] call FUNC(preview);
}];
_lnb ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_row"];
    if (_row < 0) exitWith {};
    if (GVAR(preview) isEqualTo []) then {
        private _class = _ctrl lnbData [_row, 0];
        private _index = [2, 0, 1, 3, 4] select GVAR(attachPoint);
        ["attachment", GVAR(weaponTab), _class, _index, _ctrl lnbText [_row, 1]] call FUNC(preview);
    };
    call FUNC(commit);
}];
GVAR(ui) set ["wList", _lnb];

// ---- Banner over the world
private _gapStart = _leftW;
private _gapEnd = _wPx - _rightW;
private _gapMid = (_gapStart + _gapEnd) / 2;
private _bannerW = 600 min ((_gapEnd - _gapStart) - 40);
private _banner = [_display, "group", [_gapMid - _bannerW / 2, TOP_H + 40, _bannerW, 64] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _banner;
[_banner, "rect", [0, 0, _bannerW, 64], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_banner, "frame", [0, 0, _bannerW, 64], "", C_ACCENT] call FUNC(ctrl);
[_banner, "text", [18, 8, _bannerW - 260, 18], "PREVIEWING ON WEAPON", C_ACCENT, F_MONO, 10] call FUNC(ctrl);
GVAR(ui) set ["wBannerName", [_banner, "text", [18, 26, _bannerW - 260, 30], "", C_WHITE, F_TITLE, 19] call FUNC(ctrl)];
[_banner, [_bannerW - 12 - 100 - 8 - 100, 12, 100, 40], "REVERT", {[true] call FUNC(revert)}, "default", 15] call FUNC(button);
[_banner, [_bannerW - 12 - 100, 12, 100, 40], "ATTACH", {call FUNC(commit)}, "primary", 15, F_HEAVY] call FUNC(button);
GVAR(ui) set ["wBanner", _banner];

// ---- Camera views
private _camW = 440;
private _cam = [_display, "group", [_gapMid - _camW / 2, _hPx - FOOT_H - 16 - 56, _camW, 56] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _cam;
[_cam, "rect", [0, 0, _camW, 56], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_cam, "frame", [0, 0, _camW, 56], "", C_LINE] call FUNC(ctrl);
{
    _x params ["_label", "_code"];
    [_cam, [6 + _forEachIndex * 144, 6, 140, 44], _label, _code, "default", 15] call FUNC(button);
} forEach [
    ["SIDE", {["weapon"] call FUNC(camPreset); ace_arsenal_cameraPosition set [1, -90]}],
    ["TOP", {["weapon"] call FUNC(camPreset); ace_arsenal_cameraPosition set [2, 70]}],
    ["FULL BODY", {["full"] call FUNC(camPreset)}]
];

// ---- Right panel
private _right = [_display, "group", [_wPx - _rightW, TOP_H, _rightW, _panelH] call _fnc_abs, "", [], "", -1, [], true] call FUNC(ctrl);
_viewCtrls pushBack _right;
[_right, "rect", [0, 0, _rightW, _panelH], "", [], "", -1, C_PANEL_BG] call FUNC(ctrl);
[_right, "rect", [0, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

private _magsH = 300;
[_right, "text", [22, 14, 300, 28], "WEAPON STATS", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
GVAR(ui) set ["wStats", [_right, "groupScroll", [0, 48, _rightW, _panelH - _magsH - 48]] call FUNC(ctrl)];

private _magsY = _panelH - _magsH;
[_right, "rect", [0, _magsY, _rightW, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
[_right, "text", [22, _magsY + 12, 300, 28], "MAGAZINES", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
GVAR(ui) set ["wMags", [_right, "groupScroll", [0, _magsY + 48, _rightW, _magsH - 48 - 40]] call FUNC(ctrl)];
GVAR(ui) set ["wMagsInfo", [_right, "text", [22, _panelH - 36, _rightW - 44, 24], "", C_MUTED, F_BODY, 13] call FUNC(ctrl)];

GVAR(ui) set ["view_weapon", _viewCtrls];
