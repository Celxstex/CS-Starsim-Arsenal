#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the container under the mouse while dragging: one of the container cards
 * in the CONTENTS panel, or one of the container chips above the item list.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Container: 0 uniform, 1 vest, 2 backpack, -1 for none <NUMBER>
 *
 * Public: No
 */

getMousePosition params ["_mx", "_my"];
GVAR(screenPx) params ["_wPx"];

// Local design px of the mouse relative to a point given in design px from the safe zone corner
private _fnc_local = {
    params ["_x0", "_y0"];
    [(_mx - safeZoneX) / GVAR(sx) - _x0, (_my - safeZoneY) / GVAR(sy) - _y0]
};

// Container chips above the list (they don't scroll)
([RAIL_W + 18, TOP_H + 178] call _fnc_local) params ["_cx", "_cy"];
private _chip = -1;
if (_cy >= 0 && {_cy <= 30}) then {
    for "_i" from 0 to 2 do {
        if (_cx >= _i * 132 && {_cx <= _i * 132 + 126}) exitWith {_chip = _i};
    };
};
if (_chip != -1) exitWith {_chip};

// Container cards in the CONTENTS panel, allowing for how far it's scrolled
private _contents = GVAR(ui) get "contents";
if (!ctrlShown _contents || {!ctrlShown (GVAR(ui) get "rightPanel")}) exitWith {-1};
([_wPx - STATS_W, TOP_H] call _fnc_local) params ["_px", "_py"];
private _viewH = (GVAR(ui) get "rightPanelH") - (GVAR(ui) get "loadH");
if (_px < 0 || {_px > STATS_W} || {_py < 0} || {_py > _viewH}) exitWith {-1};

private _scroll = (ctrlScrollValues _contents) param [0, -1];
private _offset = if (_scroll > 0) then {_scroll * ((GVAR(contentsH) - _viewH) max 0)} else {0};
private _y = _py + _offset;

private _card = -1;
{
    _x params ["_index", "_top", "_bottom"];
    if (_y >= _top && {_y <= _bottom}) exitWith {_card = _index};
} forEach GVAR(contentsCards);
_card
