#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Fills the loadout list from the selected source, filtered by search text and role.
 * Sources: MINE (your ACE saved loadouts), UNIT (added with arsenal_ui_fnc_addUnitLoadout),
 * SHARED (ACE shared loadouts) and DEFAULT (ACE default loadouts).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "loadout"}) then {
    [false] call FUNC(revert);
};

private _fnc_extended = {
    params ["_loadout"];
    if (count _loadout == 10) then {[_loadout, createHashMap]} else {_loadout}
};

// Entries: [source, name, author, extended loadout]
private _entries = switch (GVAR(loadoutsSource)) do {
    case "MINE": {
        (profileNamespace getVariable ["ace_arsenal_saved_loadouts", []]) apply {
            ["MINE", _x select 0, profileName, [_x select 1] call _fnc_extended]
        }
    };
    case "UNIT": {
        (missionNamespace getVariable [QGVAR(unitLoadouts), []]) apply {
            ["UNIT", _x select 0, "Unit", [_x select 1] call _fnc_extended]
        }
    };
    case "SHARED": {
        if (missionNamespace getVariable ["ace_arsenal_allowSharedLoadouts", false] && {!isNil "ace_arsenal_sharedLoadoutsNamespace"}) then {
            ((ace_arsenal_sharedLoadoutsNamespace getVariable ["ace_arsenal_sharedLoadoutsVars", []]) apply {
                ace_arsenal_sharedLoadoutsNamespace getVariable [_x, []]
            } select {_x isNotEqualTo []}) apply {
                _x params ["_author", "_name", "_data"];
                ["SHARED", _name, _author, [_data] call _fnc_extended]
            }
        } else {[]}
    };
    case "DEFAULT": {
        (missionNamespace getVariable ["ace_arsenal_defaultLoadoutsList", []]) apply {
            ["DEFAULT", _x select 0, "Mission", [_x select 1] call _fnc_extended]
        }
    };
    default {[]};
};

private _search = toLowerANSI GVAR(loadoutsSearch);
private _rows = [];
{
    _x params ["_source", "_name", "_author", "_loadout"];
    private _role = [_source, _name] call FUNC(loadoutRole);
    if (GVAR(loadoutsRole) == "ALL" || {GVAR(loadoutsRole) == _role}) then {
        private _matches = _search == "" || {(toLowerANSI _name) find _search != -1} || {(toLowerANSI _author) find _search != -1} || {
            (toLowerANSI str (_loadout select 0)) find _search != -1
        };
        if (_matches) then {
            private _unavailable = ([+_loadout] call ace_arsenal_fnc_verifyLoadout) select 2;
            _rows pushBack [_source, _name, _author, _loadout, _role, _unavailable];
        };
    };
} forEach _entries;

// Favourites first
private _favs = profileNamespace getVariable [QGVAR(favLoadouts), createHashMap];
private _favRows = _rows select {((_x select 0) + "|" + (_x select 1)) in _favs};
if (_favRows isNotEqualTo []) then {
    _rows = _favRows + (_rows select {!(((_x select 0) + "|" + (_x select 1)) in _favs)});
};

GVAR(loadoutsRows) = _rows;

// ---- Tabs and chips
private _counts = createHashMapFromArray [
    ["MINE", count (profileNamespace getVariable ["ace_arsenal_saved_loadouts", []])],
    ["UNIT", count (missionNamespace getVariable [QGVAR(unitLoadouts), []])],
    ["DEFAULT", count (missionNamespace getVariable ["ace_arsenal_defaultLoadoutsList", []])]
];
{
    private _parts = GVAR(ui) get ("src_" + _x);
    [_parts, ["normal", "active"] select (_x == GVAR(loadoutsSource))] call FUNC(buttonState);
    (_parts select 2) ctrlSetText ([_x, format ["%1  %2", _x, _counts get _x]] select (_x in _counts));
} forEach ["MINE", "UNIT", "SHARED", "DEFAULT"];
{
    [GVAR(ui) get ("role_" + _x), ["normal", "active"] select (_x == GVAR(loadoutsRole))] call FUNC(buttonState);
} forEach (["ALL"] + GVAR(roles));

// ---- List
private _lnb = GVAR(ui) get "loadoutsList";
GVAR(fillingList) = true;
lnbClear _lnb;
_lnb lnbSetColumnsPos [0, 0.18, 0.74];
private _selectRow = -1;
private _fnc_header = {
    params ["_label"];
    private _row = _lnb lnbAddRow ["", _label, ""];
    _lnb lnbSetValue [[_row, 0], -1];
    _lnb lnbSetColor [[_row, 1], C_ACCENT];
};
{
    _x params ["_source", "_name", "_author", "_loadout", "_role", "_unavailable"];
    private _isFav = _forEachIndex < count _favRows;
    if (_favRows isNotEqualTo []) then {
        if (_forEachIndex == 0) then {[format ["FAVOURITES · %1", count _favRows]] call _fnc_header};
        if (_forEachIndex == count _favRows) then {["ALL LOADOUTS"] call _fnc_header};
    };
    private _status = ["COMPLETE", format ["%1 UNAVAILABLE", count _unavailable]] select (_unavailable isNotEqualTo []);
    private _row = _lnb lnbAddRow [_role, _name, _status];
    _lnb lnbSetValue [[_row, 0], _forEachIndex];
    _lnb lnbSetColor [[_row, 0], C_SOFT];
    if (_isFav) then {
        _lnb lnbSetColor [[_row, 1], C_WHITE];
    };
    _lnb lnbSetColor [[_row, 2], [C_MUTED, C_WORSE] select (_unavailable isNotEqualTo [])];
    _lnb lnbSetTooltip [[_row, 1], format ["%1\nby %2", _name, _author]];
    if ([_source, _name] isEqualTo GVAR(loadoutsSel)) then {_selectRow = _row};
} forEach _rows;

if (_rows isEqualTo []) then {
    private _row = _lnb lnbAddRow ["", ["No loadouts here yet", "No loadouts match"] select (_entries isNotEqualTo []), ""];
    _lnb lnbSetValue [[_row, 0], -1];
    _lnb lnbSetColor [[_row, 1], C_MUTED];
};
if (_selectRow != -1) then {
    _lnb lnbSetCurSelRow _selectRow;
} else {
    GVAR(loadoutsSel) = [];
};
GVAR(fillingList) = false;

call FUNC(updateLoadoutsView);
