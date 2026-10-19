#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Reads a loadout from the clipboard (ACE extended or getUnitLoadout format) and previews it.
 * The clipboard text is parsed as data only, never run as code.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _text = if (isMultiplayer) then {
    ("ace" callExtension ["clipboard:loadout", []]) params [["_data", ""], ["_code", 1]];
    ["", _data] select (_code == 0)
} else {
    copyFromClipboard
};

private _loadout = if (_text isEqualType "" && {_text != ""}) then {parseSimpleArray _text} else {[]};

if (count _loadout == 10) then {
    _loadout = [_loadout, createHashMap];
};

if (count _loadout != 2 || {!((_loadout select 0) isEqualType [])} || {count (_loadout select 0) != 10}) exitWith {
    ["The clipboard doesn't contain a loadout", true] call FUNC(message);
};

if (GVAR(view) != "loadouts") then {
    ["loadouts"] call FUNC(setView);
};
GVAR(loadoutsSel) = [];
["loadout", "", _loadout, "", "Imported loadout"] call FUNC(preview);
["Imported. Press LOAD to keep it, then save it."] call FUNC(message);
