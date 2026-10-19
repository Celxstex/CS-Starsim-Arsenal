#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Actions on the selected loadout in the Loadouts view.
 *
 * Arguments:
 * 0: Action: "load", "share", "delete" or "role" <STRING>
 * 1: Argument, the role for "role" <ANY> (default: nil)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_action", "_arg"];

private _entry = call FUNC(selectedLoadout);

// An imported loadout is previewed without being in the list
if (_entry isEqualTo [] && {_action == "load"} && {GVAR(preview) isNotEqualTo []} && {(GVAR(preview) select 0) == "loadout"}) exitWith {
    call FUNC(commit);
    GVAR(loadoutName) = "";
    GVAR(dirty) = true;
    call FUNC(updateHeader);
};
if (_entry isEqualTo []) exitWith {};
_entry params ["_source", "_name", "_author", "_loadout"];

switch (_action) do {
    case "load": {
        private _previewingThis = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "loadout"} && {(GVAR(preview) select 7) == _name};
        if (!_previewingThis) then {
            ["loadout", "", +_loadout, "", _name] call FUNC(preview);
        };
        call FUNC(commit);
        if (_source != "MINE") then {
            // Saving would create a new personal copy rather than overwrite this one
            GVAR(loadoutName) = "";
            GVAR(dirty) = true;
            call FUNC(updateHeader);
        };
        ["ace_arsenal_onLoadoutLoadExtended", [_loadout, _name]] call CBA_fnc_localEvent;
        ["ace_arsenal_onLoadoutLoad", [_loadout select 0, _name]] call CBA_fnc_localEvent;
    };
    case "share": {
        if (_source != "MINE" || {!isMultiplayer} || {isNil "ace_arsenal_sharedLoadoutsNamespace"}) exitWith {};
        private _var = profileName + _name;
        private _vars = +(ace_arsenal_sharedLoadoutsNamespace getVariable ["ace_arsenal_sharedLoadoutsVars", []]);
        if (_var in _vars) then {
            ace_arsenal_sharedLoadoutsNamespace setVariable [_var, nil, true];
            ace_arsenal_sharedLoadoutsNamespace setVariable ["ace_arsenal_sharedLoadoutsVars", _vars - [_var], true];
            ["ace_arsenal_loadoutUnshared", [controlNull, profileName, _name]] call CBA_fnc_remoteEvent;
            [format ["Stopped sharing %1", _name]] call FUNC(message);
        } else {
            ace_arsenal_sharedLoadoutsNamespace setVariable [_var, [profileName, _name, _loadout], true];
            _vars pushBackUnique _var;
            ace_arsenal_sharedLoadoutsNamespace setVariable ["ace_arsenal_sharedLoadoutsVars", _vars, true];
            ["ace_arsenal_loadoutShared", [controlNull, [profileName, _name, _loadout]]] call CBA_fnc_remoteEvent;
            [format ["Shared %1", _name]] call FUNC(message);
        };
        call FUNC(updateLoadoutsView);
    };
    case "delete": {
        if (_source != "MINE") exitWith {};
        // First click arms, second click deletes
        if (GVAR(deleteArmed) isNotEqualTo [_source, _name]) exitWith {
            GVAR(deleteArmed) = [_source, _name];
            call FUNC(updateLoadoutsView);
            [{
                GVAR(deleteArmed) = [];
                if (!isNull UI_DISPLAY) then {call FUNC(updateLoadoutsView)};
            }, [], 3] call CBA_fnc_waitAndExecute;
        };
        GVAR(deleteArmed) = [];

        if (GVAR(preview) isNotEqualTo []) then {[false] call FUNC(revert)};

        private _data = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
        private _index = _data findIf {(_x select 0) == _name};
        if (_index != -1) then {_data deleteAt _index};
        profileNamespace setVariable ["ace_arsenal_saved_loadouts", _data];

        if (!isNil "ace_arsenal_sharedLoadoutsNamespace") then {
            private _var = profileName + _name;
            private _vars = ace_arsenal_sharedLoadoutsNamespace getVariable ["ace_arsenal_sharedLoadoutsVars", []];
            if (_var in _vars) then {
                ace_arsenal_sharedLoadoutsNamespace setVariable [_var, nil, true];
                ace_arsenal_sharedLoadoutsNamespace setVariable ["ace_arsenal_sharedLoadoutsVars", _vars - [_var], true];
                ["ace_arsenal_loadoutUnshared", [controlNull, profileName, _name]] call CBA_fnc_remoteEvent;
            };
        };

        private _roles = profileNamespace getVariable [QGVAR(loadoutRoles), createHashMap];
        _roles deleteAt ("MINE|" + _name);
        profileNamespace setVariable [QGVAR(loadoutRoles), _roles];

        private _favs = profileNamespace getVariable [QGVAR(favLoadouts), createHashMap];
        _favs deleteAt ("MINE|" + _name);
        profileNamespace setVariable [QGVAR(favLoadouts), _favs];

        if (GVAR(loadoutName) == _name) then {GVAR(loadoutName) = ""};
        GVAR(loadoutsSel) = [];
        ["ace_arsenal_onLoadoutDelete", [_name]] call CBA_fnc_localEvent;
        [format ["Deleted %1", _name]] call FUNC(message);
        call FUNC(fillLoadouts);
    };
    case "role": {
        if (_source != "MINE") exitWith {};
        private _roles = profileNamespace getVariable [QGVAR(loadoutRoles), createHashMap];
        _roles set ["MINE|" + _name, _arg];
        profileNamespace setVariable [QGVAR(loadoutRoles), _roles];
        // Rebuilding the list reverts the preview: put it back
        private _previewing = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "loadout"} && {(GVAR(preview) select 7) == _name};
        call FUNC(fillLoadouts);
        if (_previewing) then {
            ["loadout", "", +_loadout, "", _name] call FUNC(preview);
        };
    };
};
