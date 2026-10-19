#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the Loadouts view's banner and detail panel.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(view) != "loadouts") exitWith {};

private _previewing = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "loadout"};
(GVAR(ui) get "lBanner") ctrlShow _previewing;
if (_previewing) then {
    (GVAR(ui) get "lBannerName") ctrlSetText (GVAR(preview) select 7);
};

private _entry = call FUNC(selectedLoadout);
private _summary = GVAR(ui) get "lSummary";
[_summary] call FUNC(clearGroup);

if (_entry isEqualTo []) exitWith {
    (GVAR(ui) get "lMeta") ctrlSetText "";
    (GVAR(ui) get "lName") ctrlSetText "No loadout selected";
    (GVAR(ui) get "lStats") ctrlSetText "Pick one on the left to try it on";
    (GVAR(ui) get "lRole") ctrlShow false;
    {(GVAR(ui) get _x) ctrlShow false} forEach ["lWarnBg", "lWarnFrame", "lWarn"];
    {[GVAR(ui) get _x, "disabled"] call FUNC(buttonState)} forEach ["lLoad", "lRename", "lShare", "lDelete", "lFav"];
};

_entry params ["_source", "_name", "_author", "_loadout", "_role", "_unavailable"];
private _items = _loadout select 0;

(GVAR(ui) get "lMeta") ctrlSetText format ["%1 · %2 · %3", _role, _source, _author];
(GVAR(ui) get "lName") ctrlSetText _name;

private _itemCount = 0;
{
    {
        _itemCount = _itemCount + ((_x param [1, 1]) max 1);
    } forEach ((_items select _x) param [1, []]);
} forEach [3, 4, 5];
(GVAR(ui) get "lStats") ctrlSetText format ["%1 kg · %2 items carried", (([_items] call FUNC(loadoutMass)) * MASS_TO_KG) toFixed 1, _itemCount];

private _combo = GVAR(ui) get "lRole";
_combo ctrlShow true;
GVAR(fillingList) = true;
_combo lbSetCurSel (GVAR(roles) find _role);
GVAR(fillingList) = false;
_combo ctrlEnable (_source == "MINE");

// Gear summary
private _fnc_name = {
    params ["_root", "_class"];
    if (_class isEqualType []) then {_class = _class param [0, ""]};
    if (_class == "") exitWith {""};
    getText (configFile >> _root >> _class >> "displayName")
};
private _fnc_class = {
    params ["_value"];
    if (_value isEqualType []) then {_value param [0, ""]} else {_value}
};
private _assigned = _items param [9, []];
private _lines = [
    ["PRI", "CfgWeapons", _items select 0],
    ["LCH", "CfgWeapons", _items select 1],
    ["HGN", "CfgWeapons", _items select 2],
    ["HLM", "CfgWeapons", _items select 6],
    ["FCE", "CfgGlasses", _items select 7],
    ["UNF", "CfgWeapons", _items select 3],
    ["VST", "CfgWeapons", _items select 4],
    ["BKP", "CfgVehicles", _items select 5],
    ["NVG", "CfgWeapons", _assigned param [5, ""]],
    ["BIN", "CfgWeapons", _items select 8]
] apply {
    _x params ["_code", "_root", "_value"];
    [_code, [_root, _value] call _fnc_name, [_value] call _fnc_class]
} select {(_x select 1) != ""};

{
    _x params ["_code", "_label", "_class"];
    private _missing = _class in _unavailable;
    private _y = _forEachIndex * 42;
    [_summary, "text", [20, _y, 44, 42], _code, C_MUTED, F_MONO, 10] call FUNC(ctrl);
    [_summary, "text", [66, _y, LOADOUTS_RIGHT_W - 66 - 120, 42], _label, [C_TEXT, C_WORSE] select _missing, F_BODY, 15] call FUNC(ctrl);
    if (_missing) then {
        [_summary, "textRight", [LOADOUTS_RIGHT_W - 140, _y, 120, 42], "NOT ALLOWED", C_WORSE, F_MONO, 9] call FUNC(ctrl);
    };
    [_summary, "rect", [20, _y + 41, LOADOUTS_RIGHT_W - 40, 1], "", [], "", -1, C_CARD_LINE] call FUNC(ctrl);
} forEach _lines;

private _hasWarning = _unavailable isNotEqualTo [];
{(GVAR(ui) get _x) ctrlShow _hasWarning} forEach ["lWarnBg", "lWarnFrame", "lWarn"];
if (_hasWarning) then {
    (GVAR(ui) get "lWarn") ctrlSetText format ["%1 item(s) aren't available in this arsenal and will be left out.", count _unavailable];
    (GVAR(ui) get "lWarn") ctrlSetTooltip ((_unavailable apply {
        private _cfg = [_x] call FUNC(itemConfig);
        [getText (_cfg >> "displayName"), _x] select (isNull _cfg)
    }) joinString endl);
};

private _mine = _source == "MINE";
private _canShare = _mine && {missionNamespace getVariable ["ace_arsenal_allowSharedLoadouts", false]} && {isMultiplayer};
private _shared = !isNil "ace_arsenal_sharedLoadoutsNamespace" && {(profileName + _name) in (ace_arsenal_sharedLoadoutsNamespace getVariable ["ace_arsenal_sharedLoadoutsVars", []])};
[GVAR(ui) get "lLoad", "normal"] call FUNC(buttonState);
private _isFav = (_source + "|" + _name) in (profileNamespace getVariable [QGVAR(favLoadouts), createHashMap]);
[GVAR(ui) get "lFav", ["normal", "active"] select _isFav] call FUNC(buttonState);
((GVAR(ui) get "lFav") select 2) ctrlSetText (["FAVOURITE [F]", "FAVOURITED [F]"] select _isFav);
((GVAR(ui) get "lFav") select 3) ctrlSetTooltip "Favourites are listed first";
[GVAR(ui) get "lRename", ["disabled", "normal"] select _mine] call FUNC(buttonState);
[GVAR(ui) get "lDelete", ["disabled", "normal"] select _mine] call FUNC(buttonState);
[GVAR(ui) get "lShare", ["disabled", "normal"] select _canShare] call FUNC(buttonState);
((GVAR(ui) get "lShare") select 2) ctrlSetText (["SHARE", "UNSHARE"] select (_mine && _shared));
((GVAR(ui) get "lDelete") select 2) ctrlSetText (["DELETE", "CONFIRM?"] select ((missionNamespace getVariable [QGVAR(deleteArmed), []]) isEqualTo [_source, _name]));
