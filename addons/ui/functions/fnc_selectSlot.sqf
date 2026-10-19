#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Switches the Loadout view to another slot. A pending preview is reverted.
 *
 * Arguments:
 * 0: Slot id <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_id"];

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};

GVAR(slot) = _id;
GVAR(modFilter) = "";
GVAR(search) = "";
private _search = GVAR(ui) get "search";
_search ctrlSetText "";
(_search getVariable QGVAR(placeholder)) ctrlShow true;
[GVAR(ui) get "searchClear", false] call FUNC(buttonShow);

private _slot = [_id] call FUNC(slot);
private _isCargo = (_slot select S_KIND) == "cargo";
private _panelH = GVAR(ui) get "listPanelH";

// The ITEMS slot gets a container picker, categories and +/- buttons
(GVAR(ui) get "cargoChips") ctrlShow _isCargo;
(GVAR(ui) get "cargoCats") ctrlShow _isCargo;
(GVAR(ui) get "cargoBar") ctrlShow _isCargo;
private _listY = [178, 248] select _isCargo;
private _listH = _panelH - _listY - ([0, CARGO_BAR_H] select _isCargo);
(GVAR(ui) get "listLine") ctrlSetPositionY PX_Y(_listY - 1);
(GVAR(ui) get "listLine") ctrlCommit 0;
(GVAR(ui) get "itemList") ctrlSetPosition [0, PX_Y(_listY), PX_X(LIST_W), PX_Y(_listH)];
(GVAR(ui) get "itemList") ctrlCommit 0;

[_slot select S_CAM] call FUNC(camPreset);

[if (_isCargo) then {
    [["DBL", "Add one"], ["LEFT/RIGHT", "Remove / add"], ["+SHIFT", "x5"], ["+CTRL", "All / fill"], ["P", "Pin"], ["CTRL+F", "Search"], ["CTRL+Z", "Undo"]]
} else {
    [["LMB", "Preview"], ["DBL", "Equip"], ["ENTER", "Equip preview"], ["BKSP", "Revert"], ["C", "Compare"], ["P", "Pin"], ["CTRL+F", "Search"], ["CTRL+Z", "Undo"]]
}] call FUNC(setHints);

call FUNC(fillItemList);
call FUNC(refresh);
