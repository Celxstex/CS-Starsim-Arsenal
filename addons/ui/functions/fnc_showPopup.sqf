#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Opens the naming popup, or closes it.
 *
 * Arguments:
 * 0: Mode: "save", "rename", or "" to close <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_mode"];

private _entry = call FUNC(selectedLoadout);
if (_mode == "rename" && {(_entry param [0, ""]) != "MINE"}) exitWith {};

GVAR(popup) = _mode;
private _show = _mode != "";
(GVAR(ui) get "popup") ctrlShow _show;
(GVAR(ui) get "popupShade") ctrlShow _show;

if (!_show) exitWith {
    GVAR(typing) = false;
};

private _edit = GVAR(ui) get "popupEdit";
private _combo = GVAR(ui) get "popupRole";
private _isSave = _mode == "save";

(GVAR(ui) get "popupTitle") ctrlSetText (["RENAME LOADOUT", "SAVE CURRENT LOADOUT"] select _isSave);
((GVAR(ui) get "popupOk") select 2) ctrlSetText (["RENAME", "SAVE"] select _isSave);
_combo ctrlShow _isSave;
(GVAR(ui) get "popupRoleLabel") ctrlShow _isSave;

private _name = if (_isSave) then {GVAR(loadoutName)} else {_entry select 1};
_edit ctrlSetText _name;
_combo lbSetCurSel ((GVAR(roles) find (["MINE", _name] call FUNC(loadoutRole))) max 0);

ctrlSetFocus _edit;
GVAR(typing) = true;
