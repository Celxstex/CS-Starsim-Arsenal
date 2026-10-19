#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the full compare overlay (equipped / previewing / pinned) on the right of the
 * Loadout view. Its contents are drawn by FUNC(renderCompare).
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Panel height in design px <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display", "_panelH"];

GVAR(screenPx) params ["_wPx"];
private _w = COMPARE_W min (_wPx - RAIL_W - LIST_W);

private _group = [_display, "group", [safeZoneX + PX_X(_wPx - _w), safeZoneY + PX_Y(TOP_H), PX_X(_w), PX_Y(_panelH)], "", [], "", -1, [], true] call FUNC(ctrl);
[_group, "rect", [0, 0, _w, _panelH], "", [], "", -1, C_OVERLAY_BG] call FUNC(ctrl);
[_group, "rect", [0, 0, 1, _panelH], "", [], "", -1, C_LINE] call FUNC(ctrl);

GVAR(ui) set ["cmpTitle", [_group, "text", [22, 14, 400, 34], "COMPARE", C_WHITE, F_TITLE, 22] call FUNC(ctrl)];
GVAR(ui) set ["cmpCount", [_group, "text", [420, 20, 200, 24], "", C_MUTED, F_MONO, 10] call FUNC(ctrl)];
GVAR(ui) set ["cmpDiffOnly", [_group, [_w - 22 - 200, 14, 200, 32], "DIFFERENCES ONLY", {
    GVAR(diffOnly) = !GVAR(diffOnly);
    call FUNC(renderCompare);
}, "chip", 11, F_MONO] call FUNC(button)];
[_group, "rect", [0, 60, _w, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);

GVAR(ui) set ["cmpBody", [_group, "groupScroll", [0, 61, _w, _panelH - 61 - 72]] call FUNC(ctrl)];

private _footY = _panelH - 72;
[_group, "rect", [0, _footY, _w, 1], "", [], "", -1, C_LINE] call FUNC(ctrl);
[_group, "textMulti", [22, _footY + 14, _w - 22 - 360, 44], "Contents carry over. Anything that doesn't fit is removed.", C_MUTED, F_BODY, 13] call FUNC(ctrl);
[_group, [_w - 22 - 140 - 8 - 190, _footY + 14, 140, 44], "KEEP", {
    [true] call FUNC(revert);
    call FUNC(toggleCompare);
}, "default", 15] call FUNC(button);
GVAR(ui) set ["cmpEquipPreview", [_group, [_w - 22 - 190, _footY + 14, 190, 44], "EQUIP PREVIEWING", {
    call FUNC(commit);
    call FUNC(toggleCompare);
}, "primary", 15, F_HEAVY] call FUNC(button)];

GVAR(ui) set ["compare", _group];
GVAR(ui) set ["compareW", _w];
_group ctrlShow false;
