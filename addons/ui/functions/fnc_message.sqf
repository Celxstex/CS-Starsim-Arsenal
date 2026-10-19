#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Shows a short message near the top of the screen.
 *
 * Arguments:
 * 0: Text <STRING>
 * 1: Warning <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_text", ["_warning", false]];

private _ctrl = GVAR(ui) getOrDefault ["toast", controlNull];
if (isNull _ctrl) exitWith {};

_ctrl ctrlSetText _text;
_ctrl ctrlSetTextColor ([C_TEXT, C_WARN_TEXT] select _warning);
_ctrl ctrlSetBackgroundColor ([C_BAR_BG, C_WARN_BG] select _warning);
_ctrl ctrlShow true;
_ctrl ctrlSetFade 0;
_ctrl ctrlCommit 0;

private _token = diag_tickTime;
GVAR(toastToken) = _token;

[{
    params ["_ctrl", "_token"];
    if (isNull _ctrl || {GVAR(toastToken) != _token}) exitWith {};
    _ctrl ctrlSetFade 1;
    _ctrl ctrlCommit 0.4;
}, [_ctrl, _token], 3] call CBA_fnc_waitAndExecute;
