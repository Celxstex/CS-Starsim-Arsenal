#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Starts dragging an item from the CONTENTS panel. A label follows the mouse and
 * names the container under it; letting go calls FUNC(dragEnd).
 *
 * Arguments:
 * 0: Class name <STRING>
 * 1: Container it's in: 0 uniform, 1 vest, 2 backpack <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_class", "_from"];

if (GVAR(drag) isNotEqualTo []) exitWith {};

private _name = getText (([_class] call FUNC(itemConfig)) >> "displayName");
private _count = {_x == _class} count ([uniformItems CENTER, vestItems CENTER, backpackItems CENTER] select _from);
GVAR(drag) = [_class, _from, getMousePosition, _name, _count];

GVAR(dragPFH) = [{
    params ["", "_pfh"];
    if (isNull UI_DISPLAY || {isNil QGVAR(ui)} || {GVAR(drag) isEqualTo []}) exitWith {
        [_pfh] call CBA_fnc_removePerFrameHandler;
    };
    private _ghost = GVAR(ui) getOrDefault ["dragGhost", controlNull];
    if (isNull _ghost) exitWith {
        [_pfh] call CBA_fnc_removePerFrameHandler;
    };

    GVAR(drag) params ["", "_from", "_start", "_name", "_count"];
    getMousePosition params ["_mx", "_my"];

    // Only show the label once the mouse has actually moved: a plain click selects the item
    if ((_start distance2D [_mx, _my]) < 0.01) exitWith {};

    private _target = call FUNC(dragTarget);
    private _valid = _target >= 0 && {_target != _from};
    _ghost ctrlSetText (if (_valid) then {
        format ["Move %1 x%2 to the %3", _name, _count, ["uniform", "vest", "backpack"] select _target]
    } else {
        format ["%1 x%2 · drop on a container", _name, _count]
    });
    _ghost ctrlSetTextColor ([C_SOFT, C_ON_ACCENT] select _valid);
    _ghost ctrlSetBackgroundColor ([C_BAR_BG, C_ACCENT] select _valid);
    _ghost ctrlSetPosition [_mx + PX_X(14), _my + PX_Y(10)];
    _ghost ctrlShow true;
    _ghost ctrlCommit 0;
}, 0] call CBA_fnc_addPerFrameHandler;
