#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the small centred popup used to name a loadout (save as, rename).
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

// Dim layer that also blocks clicks to everything behind the popup
private _shade = [_display, "rect", [safeZoneX, safeZoneY, safeZoneW, safeZoneH], "", [], "", -1, [0, 0, 0, 0.55], true] call FUNC(ctrl);
_shade ctrlShow false;
GVAR(ui) set ["popupShade", _shade];

private _w = 480;
private _h = 236;
private _group = [_display, "group", [safeZoneX + safeZoneW / 2 - PX_X(_w / 2), safeZoneY + safeZoneH / 2 - PX_Y(_h / 2), PX_X(_w), PX_Y(_h)], "", [], "", -1, [], true] call FUNC(ctrl);
[_group, "rect", [0, 0, _w, _h], "", [], "", -1, C_OVERLAY_BG] call FUNC(ctrl);
[_group, "frame", [0, 0, _w, _h], "", C_ACCENT] call FUNC(ctrl);
GVAR(ui) set ["popupTitle", [_group, "text", [22, 16, _w - 44, 30], "", C_WHITE, F_TITLE, 20] call FUNC(ctrl)];

[_group, "text", [22, 58, 100, 20], "NAME", C_MUTED, F_MONO, 10] call FUNC(ctrl);
[_group, "rect", [22, 80, _w - 44, 40], "", [], "", -1, C_INPUT] call FUNC(ctrl);
[_group, "frame", [22, 80, _w - 44, 40], "", C_BTN_LINE] call FUNC(ctrl);
private _edit = [_group, "edit", [30, 82, _w - 60, 36]] call FUNC(ctrl);
_edit ctrlAddEventHandler ["SetFocus", {GVAR(typing) = true}];
_edit ctrlAddEventHandler ["KillFocus", {GVAR(typing) = false}];
GVAR(ui) set ["popupEdit", _edit];

GVAR(ui) set ["popupRoleLabel", [_group, "text", [22, 132, 100, 30], "ROLE", C_MUTED, F_MONO, 10] call FUNC(ctrl)];
private _combo = [_group, "combo", [90, 132, 200, 30]] call FUNC(ctrl);
{
    _combo lbAdd _x;
} forEach GVAR(roles);
GVAR(ui) set ["popupRole", _combo];

[_group, [_w - 22 - 130 - 8 - 110, _h - 58, 110, 40], "CANCEL", {[""] call FUNC(showPopup)}, "default", 15] call FUNC(button);
GVAR(ui) set ["popupOk", [_group, [_w - 22 - 130, _h - 58, 130, 40], "SAVE", {call FUNC(popupConfirm)}, "primary", 15, F_HEAVY] call FUNC(button)];

_group ctrlShow false;
GVAR(ui) set ["popup", _group];
