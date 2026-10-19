#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Confirms the naming popup: saves the current loadout or renames the selected one.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _name = (ctrlText (GVAR(ui) get "popupEdit")) trim [" ", 0];
if (_name == "") exitWith {
    ["Give the loadout a name", true] call FUNC(message);
};

switch (GVAR(popup)) do {
    case "save": {
        private _combo = GVAR(ui) get "popupRole";
        [_name, GVAR(roles) param [lbCurSel _combo, ""]] call FUNC(saveLoadout);
        [""] call FUNC(showPopup);
        if (GVAR(view) == "loadouts") then {
            GVAR(loadoutsSource) = "MINE";
            GVAR(loadoutsSel) = ["MINE", _name];
            call FUNC(fillLoadouts);
        };
    };
    case "rename": {
        private _entry = call FUNC(selectedLoadout);
        if (_entry isEqualTo []) exitWith {[""] call FUNC(showPopup)};
        private _old = _entry select 1;
        if (_old == _name) exitWith {[""] call FUNC(showPopup)};

        private _data = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];
        if (_data findIf {(_x select 0) == _name} != -1) exitWith {
            ["A loadout with that name already exists", true] call FUNC(message);
        };
        if (!isNil "ace_arsenal_sharedLoadoutsNamespace" && {(profileName + _old) in (ace_arsenal_sharedLoadoutsNamespace getVariable ["ace_arsenal_sharedLoadoutsVars", []])}) exitWith {
            ["Stop sharing it before renaming", true] call FUNC(message);
        };

        private _index = _data findIf {(_x select 0) == _old};
        if (_index != -1) then {
            (_data select _index) set [0, _name];
            profileNamespace setVariable ["ace_arsenal_saved_loadouts", _data];
        };

        private _roles = profileNamespace getVariable [QGVAR(loadoutRoles), createHashMap];
        private _role = _roles getOrDefault ["MINE|" + _old, ""];
        _roles deleteAt ("MINE|" + _old);
        if (_role != "") then {_roles set ["MINE|" + _name, _role]};
        profileNamespace setVariable [QGVAR(loadoutRoles), _roles];

        private _favs = profileNamespace getVariable [QGVAR(favLoadouts), createHashMap];
        if (("MINE|" + _old) in _favs) then {
            _favs deleteAt ("MINE|" + _old);
            _favs set ["MINE|" + _name, true];
            profileNamespace setVariable [QGVAR(favLoadouts), _favs];
        };

        if (GVAR(loadoutName) == _old) then {GVAR(loadoutName) = _name};
        if (GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 7) == _old}) then {GVAR(preview) set [7, _name]};
        GVAR(loadoutsSel) = ["MINE", _name];
        [""] call FUNC(showPopup);
        [format ["Renamed to %1", _name]] call FUNC(message);
        call FUNC(fillLoadouts);
        call FUNC(updateHeader);
    };
};
