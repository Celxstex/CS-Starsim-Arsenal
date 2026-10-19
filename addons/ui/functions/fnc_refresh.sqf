#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates whatever the current view shows after the loadout or preview changes.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (isNull UI_DISPLAY) exitWith {};

switch (GVAR(view)) do {
    case "loadout": {
        call FUNC(updateRail);
        if (((([GVAR(slot)] call FUNC(slot)) select S_KIND)) == "cargo") then {
            call FUNC(fillCargoList);
        } else {
            call FUNC(updateListTags);
        };
        call FUNC(updateBanner);
        call FUNC(updateSidePanel);
    };
    case "weapon": {
        call FUNC(updateWeaponView);
    };
    case "loadouts": {
        call FUNC(updateLoadoutsView);
    };
};

call FUNC(updateHeader);
