#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Copies the current loadout to the clipboard in ACE's format, using ACE's clipboard
 * extension so it also works in multiplayer.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _loadout = if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) select 4
} else {
    CENTER call CBA_fnc_getLoadout
};

"ace" callExtension ["clipboard:append", [str _loadout]];
"ace" callExtension ["clipboard:complete", []];

["ace_arsenal_loadoutExported", [UI_DISPLAY, false]] call CBA_fnc_localEvent;
["Loadout copied to clipboard"] call FUNC(message);
