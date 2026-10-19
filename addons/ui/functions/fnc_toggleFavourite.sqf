#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Favourites or unfavourites the selected loadout. Favourites are listed first in
 * every source tab and are remembered between sessions.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _entry = call FUNC(selectedLoadout);
if (_entry isEqualTo []) exitWith {
    ["Pick a loadout first"] call FUNC(message);
};
_entry params ["_source", "_name", "", "_loadout"];
private _previewing = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "loadout"} && {(GVAR(preview) select 7) == _name};

private _favs = profileNamespace getVariable [QGVAR(favLoadouts), createHashMap];
private _key = _source + "|" + _name;
if (_key in _favs) then {
    _favs deleteAt _key;
    [format ["Removed %1 from favourites", _name]] call FUNC(message);
} else {
    _favs set [_key, true];
    [format ["Added %1 to favourites", _name]] call FUNC(message);
};
profileNamespace setVariable [QGVAR(favLoadouts), _favs];
GVAR(profileDirty) = true;

// Rebuilding the list reverts the preview: put it back
call FUNC(fillLoadouts);
if (_previewing) then {
    ["loadout", "", +_loadout, "", _name] call FUNC(preview);
};
