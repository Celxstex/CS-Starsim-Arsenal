#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Ends a drag from the CONTENTS panel. Dropped on another container: moves the item
 * there. Not moved at all: treated as a click, which picks the item in the list so
 * the amount controls under it apply to it.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (isNil QGVAR(drag) || {GVAR(drag) isEqualTo []}) exitWith {};

GVAR(drag) params ["_class", "_from", "_start"];
private _clicked = (_start distance2D getMousePosition) < 0.01;
private _target = if (_clicked) then {-1} else {call FUNC(dragTarget)};

GVAR(drag) = [];
[GVAR(dragPFH)] call CBA_fnc_removePerFrameHandler;
(GVAR(ui) get "dragGhost") ctrlShow false;

// The control that started the drag may be deleted by the refresh: do the work next frame
[{
    params ["_class", "_from", "_target", "_clicked"];
    if (isNull UI_DISPLAY) exitWith {};

    if (_clicked) exitWith {
        GVAR(cargoTarget) = _from;
        call FUNC(fillCargoList);
        private _lnb = GVAR(ui) get "itemList";
        private _fnc_select = {
            private _found = false;
            for "_row" from 0 to ((lnbSize _lnb) select 0) - 1 do {
                if ((_lnb lnbData [_row, 0]) == _class) exitWith {
                    _lnb lnbSetCurSelRow _row;
                    _found = true;
                };
            };
            _found
        };
        // Hidden by a filter: clear the search, category and mod filter and look again
        if !(call _fnc_select) then {
            GVAR(cargoCat) = "ALL";
            GVAR(modFilter) = "";
            GVAR(search) = "";
            private _search = GVAR(ui) get "search";
            _search ctrlSetText "";
            (_search getVariable QGVAR(placeholder)) ctrlShow true;
            [GVAR(ui) get "searchClear", false] call FUNC(buttonShow);
            call FUNC(fillCargoList);
            call _fnc_select;
        };
        call FUNC(updateCargoInfo);
        call FUNC(updateSidePanel);
    };

    if (_target >= 0 && {_target != _from}) then {
        [_class, _from, _target] call FUNC(cargoMove);
    };
}, [_class, _from, _target, _clicked]] call CBA_fnc_execNextFrame;
