#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the top bar, footer and message toast shared by every view.
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

private _wPx = safeZoneW / GVAR(sx);
private _hPx = safeZoneH / GVAR(sy);
GVAR(screenPx) = [_wPx, _hPx];

// ---- Top bar
private _top = [_display, "group", [safeZoneX, safeZoneY, safeZoneW, PX_Y(TOP_H)], "", [], "", -1, [], true] call FUNC(ctrl);
[_top, "rect", [0, 0, _wPx, TOP_H], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_top, "rect", [0, TOP_H - 1, _wPx, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);

[_top, "text", [24, 9, 268, 30], "STARSIM ARSENAL", C_WHITE, F_HEAVY, 20] call FUNC(ctrl);
private _unitName = missionNamespace getVariable [QGVAR(unitName), ""];
[_top, "text", [24, 36, 360, 18], (["[CS]", _unitName] select {_x != ""}) joinString " · ", C_MUTED, F_MONO, 10] call FUNC(ctrl);

{
    _x params ["_view", "_label"];
    private _parts = [_top, [300 + _forEachIndex * 140, 0, 140, TOP_H], _label, compile format ["['%1'] call %2", _view, QFUNC(setView)], "tab", 17] call FUNC(button);
    GVAR(ui) set ["tab_" + _view, _parts];
} forEach [["loadout", "LOADOUT"], ["weapon", "WEAPON"], ["loadouts", "LOADOUTS"]];

// Right side: current loadout name, save, export, close
private _xClose = _wPx - 24 - 40;
private _xExport = _xClose - 12 - 110;
private _xSave = _xExport - 8 - 100;

GVAR(ui) set ["btnClose", [_top, [_xClose, 12, 40, 40], "X", {(ctrlParent (_this select 0)) closeDisplay 1}, "default", 16] call FUNC(button)];
GVAR(ui) set ["btnExport", [_top, [_xExport, 12, 110, 40], "EXPORT", {call FUNC(exportLoadout)}, "default", 16] call FUNC(button)];
GVAR(ui) set ["btnSave", [_top, [_xSave, 12, 100, 40], "SAVE", {call FUNC(quickSave)}, "accent", 16] call FUNC(button)];

if (is3DEN) then {
    ((GVAR(ui) get "btnClose") select 2) ctrlSetText "OK";
};

private _xName = _xSave - 24 - 320;
[_top, "textRight", [_xName, 10, 320, 18], "LOADOUT", C_MUTED, F_MONO, 10] call FUNC(ctrl);
GVAR(ui) set ["headerName", [_top, "textRight", [_xName, 28, 300, 26], "", C_TEXT, F_TITLE, 17] call FUNC(ctrl)];
GVAR(ui) set ["headerDirty", [_top, "rect", [_xName + 308, 37, 8, 8], "", [], "", -1, C_CLEAR] call FUNC(ctrl)];

// ---- Footer
private _foot = [_display, "group", [safeZoneX, safeZoneY + safeZoneH - PX_Y(FOOT_H), safeZoneW, PX_Y(FOOT_H)], "", [], "", -1, [], true] call FUNC(ctrl);
[_foot, "rect", [0, 0, _wPx, FOOT_H], "", [], "", -1, C_BAR_BG] call FUNC(ctrl);
[_foot, "rect", [0, 0, _wPx, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
GVAR(ui) set ["hints", [_foot, "structured", [24, 10, _wPx - 48, 24]] call FUNC(ctrl)];

// ---- Toast
private _toast = [_display, "textCenter", [safeZoneX + safeZoneW / 2 - PX_X(280), safeZoneY + PX_Y(TOP_H + 120), PX_X(560), PX_Y(40)], "", C_TEXT, F_TITLE, 16, C_BAR_BG, true] call FUNC(ctrl);
_toast ctrlShow false;
GVAR(ui) set ["toast", _toast];

call FUNC(updateHeader);
