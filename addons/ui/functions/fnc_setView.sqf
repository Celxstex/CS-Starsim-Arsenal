#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Switches between the Loadout, Weapon and Loadouts views. A pending preview is reverted.
 *
 * Arguments:
 * 0: View: "loadout", "weapon" or "loadouts" <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_view"];

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};
if (GVAR(popup) != "") then {
    [""] call FUNC(showPopup);
};

GVAR(view) = _view;
GVAR(compareOpen) = false;

{
    private _name = _x;
    private _show = _name == _view;
    {
        _x ctrlShow _show;
    } forEach (GVAR(ui) getOrDefault ["view_" + _name, []]);
    [GVAR(ui) get ("tab_" + _name), ["normal", "active"] select _show] call FUNC(buttonState);
} forEach ["loadout", "weapon", "loadouts"];

switch (_view) do {
    case "loadout": {
        // Hints depend on the slot
        [GVAR(slot)] call FUNC(selectSlot);
    };
    case "weapon": {
        [[["LMB", "Preview"], ["DBL", "Attach"], ["ENTER", "Attach preview"], ["BKSP", "Revert"], ["1-5", "Jump to slot"], ["CTRL+Z", "Undo"]]] call FUNC(setHints);
        [GVAR(weaponTab)] call FUNC(selectWeapon);
    };
    case "loadouts": {
        [[["LMB", "Preview loadout"], ["DBL", "Load"], ["ENTER", "Load preview"], ["F", "Favourite"], ["CTRL+F", "Search"], ["ESC", "Back to your kit"]]] call FUNC(setHints);
        ["full"] call FUNC(camPreset);
        call FUNC(fillLoadouts);
    };
};
