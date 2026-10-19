#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds the Starsim Arsenal UI on an ACE arsenal display that ACE has already initialised.
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

// Hide ACE's controls. The full-screen mouse area stays: it drives ACE's orbit camera.
private _fnc_hideAce = {
    params ["_display"];
    {
        if (ctrlClassName _x != "mouseArea") then {
            _x ctrlShow false;
            _x ctrlEnable false;
        };
    } forEach (allControls _display select {(_x getVariable [QGVAR(own), false]) isEqualTo false});
};
[_display] call _fnc_hideAce;
// Some of ACE's setup finishes a frame later
[_fnc_hideAce, [_display]] call CBA_fnc_execNextFrame;

uiNamespace setVariable [QGVAR(display), _display];
GVAR(sy) = UNIT_Y;
GVAR(sx) = UNIT_X;

call FUNC(initColors);

// ACE Arsenal Extended swaps ace_arsenal_virtualItems for a list with one entry per model.
// Keep the full list: variants are grouped here instead.
GVAR(allItems) = if (isNil "aceax_arsenal_initialVirtualItems") then {
    ace_arsenal_virtualItems
} else {
    aceax_arsenal_initialVirtualItems
};

GVAR(ui) = createHashMap;
GVAR(view) = "";
GVAR(slot) = ["PRI", "LCH", "HGN", "BIN"] select ((missionNamespace getVariable ["ace_arsenal_selectedWeaponType", 0]) max 0 min 3);
if (GVAR(slot) == "BIN") then {GVAR(slot) = "PRI"};
GVAR(preview) = [];
GVAR(previewLost) = 0;
GVAR(undo) = [];
// Pins and sort are remembered between sessions
GVAR(pins) = createHashMapFromArray ((profileNamespace getVariable [QGVAR(pins), []]) select {
    _x isEqualTypeParams ["", []]
} apply {
    [_x select 0, (_x select 1) select {_x isEqualType ""}]
});
(profileNamespace getVariable [QGVAR(sort), []]) params [["_sort", "NAME", [""]], ["_sortDesc", false, [false]]];
GVAR(sort) = _sort;
GVAR(sortDesc) = _sortDesc;
GVAR(cargoCat) = "ALL";
GVAR(drag) = [];
GVAR(contentsCards) = [];
GVAR(contentsH) = 0;
GVAR(modFilter) = "";
GVAR(search) = "";
GVAR(typing) = false;
GVAR(fillingList) = false;
GVAR(compareOpen) = false;
GVAR(diffOnly) = true;
GVAR(statsCollapsed) = false;
GVAR(statsPeek) = false;
GVAR(dirty) = false;
GVAR(cargoTarget) = 1;
GVAR(weaponTab) = "PRI";
GVAR(attachPoint) = 0;
GVAR(loadoutsSource) = "MINE";
GVAR(loadoutsRole) = "ALL";
GVAR(loadoutsSearch) = "";
GVAR(loadoutsRows) = [];
GVAR(loadoutsSel) = [];
GVAR(popup) = "";
GVAR(deleteArmed) = [];
if (isNil QGVAR(loadoutName)) then {GVAR(loadoutName) = ""};

call FUNC(buildModelIndex);

[_display] call FUNC(buildChrome);
[_display] call FUNC(buildLoadoutView);
[_display] call FUNC(buildWeaponView);
[_display] call FUNC(buildLoadoutsView);
[_display] call FUNC(buildPopup);

["loadout"] call FUNC(setView);
