#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Keyboard handling for ace_arsenal_display. Passes to ACE when the Starsim Arsenal UI isn't active.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Key code <NUMBER>
 * 2: Shift <BOOL>
 * 3: Ctrl <BOOL>
 * 4: Alt <BOOL>
 *
 * Return Value:
 * Handled <BOOL>
 *
 * Public: No
 */

params ["_display", "_key", "_shift", "_ctrl", "_alt"];

if !(_display getVariable [QGVAR(active), false]) exitWith {
    ["onKeyDown", _this, "ace_arsenal_display"] call ace_arsenal_fnc_onKeyDown
};

// Typing in a text box: only Escape (leave the box) and Enter (confirm a popup) are ours
if (GVAR(typing)) exitWith {
    switch (true) do {
        case (_key == DIK_ESCAPE): {
            if (GVAR(popup) != "") then {
                [""] call FUNC(showPopup);
            } else {
                ctrlSetFocus (GVAR(ui) getOrDefault [["itemList", "loadoutsList"] select (GVAR(view) == "loadouts"), controlNull]);
                GVAR(typing) = false;
            };
            true
        };
        case (_key in [DIK_RETURN, DIK_NUMPADENTER] && {GVAR(popup) != ""}): {
            call FUNC(popupConfirm);
            true
        };
        case (_key in [DIK_RETURN, DIK_NUMPADENTER] && {focusedCtrl _display isEqualTo (GVAR(ui) getOrDefault ["cargoQty", controlNull])}): {
            call FUNC(cargoSetCount);
            true
        };
        default {false};
    }
};

private _kind = if (GVAR(view) == "loadout") then {([GVAR(slot)] call FUNC(slot)) select S_KIND} else {""};

switch (true) do {
    case (_key == DIK_ESCAPE): {
        switch (true) do {
            case (GVAR(popup) != ""): {[""] call FUNC(showPopup)};
            case (GVAR(compareOpen)): {call FUNC(toggleCompare)};
            case (GVAR(preview) isNotEqualTo [] && {GVAR(view) == "loadouts"}): {[true] call FUNC(revert)};
            default {_display closeDisplay 2};
        };
        true
    };
    case (_key in [DIK_RETURN, DIK_NUMPADENTER]): {
        if (GVAR(popup) != "") then {
            call FUNC(popupConfirm);
        } else {
            call FUNC(commit);
        };
        true
    };
    case (_key == DIK_BACKSPACE): {
        [true] call FUNC(revert);
        true
    };
    case (_key == DIK_Z && {_ctrl}): {
        call FUNC(undo);
        true
    };
    case (_key == DIK_S && {_ctrl}): {
        call FUNC(quickSave);
        true
    };
    case (_key == DIK_F && {_ctrl} && {GVAR(view) in ["loadout", "loadouts"]}): {
        ctrlSetFocus (GVAR(ui) getOrDefault [["search", "loadoutsSearch"] select (GVAR(view) == "loadouts"), controlNull]);
        true
    };
    case (_key == DIK_F && {!_ctrl} && {GVAR(view) == "loadouts"}): {
        call FUNC(toggleFavourite);
        true
    };
    case (_key == DIK_C && {!_ctrl} && {GVAR(view) == "loadout"}): {
        call FUNC(toggleCompare);
        true
    };
    case (_key == DIK_P && {!_ctrl} && {GVAR(view) == "loadout"}): {
        call FUNC(pin);
        true
    };
    case (_key in [DIK_LEFT, DIK_RIGHT] && {_kind == "cargo"}): {
        // SHIFT: five at a time, CTRL: all / fill
        [([-1, 1] select (_key == DIK_RIGHT)) * (switch (true) do {case (_ctrl): {1000}; case (_shift): {5}; default {1}})] call FUNC(cargoChange);
        true
    };
    case (_key >= DIK_1 && {_key <= DIK_5} && {GVAR(view) == "weapon"}): {
        [_key - DIK_1] call FUNC(selectAttachPoint);
        true
    };
    default {false};
}
