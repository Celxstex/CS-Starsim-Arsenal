#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the Weapon view after the weapon, an attachment or a preview changes.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(view) != "weapon") exitWith {};

private _unit = CENTER;
private _slot = [GVAR(weaponTab)] call FUNC(slot);
private _weapon = [GVAR(weaponTab)] call FUNC(currentClass);
private _cfgWeapon = configFile >> "CfgWeapons" >> _weapon;
private _aceIndex = [2, 0, 1, 3, 4] select GVAR(attachPoint);

// ---- Card
if (_weapon == "") then {
    (GVAR(ui) get "wPicture") ctrlSetText "";
    (GVAR(ui) get "wName") ctrlSetText "No weapon";
    (GVAR(ui) get "wClass") ctrlSetText "Pick one in the Loadout view";
    (GVAR(ui) get "wMagCount") ctrlSetText "";
    (GVAR(ui) get "wRounds") ctrlSetText "";
} else {
    // Spare magazines for any of its muzzles, and rounds including what's loaded
    private _compatible = createHashMap;
    {
        {
            _compatible set [toLowerANSI _x, true];
        } forEach (compatibleMagazines [_weapon, _x]);
    } forEach (_weapon call CBA_fnc_getMuzzles);
    private _spare = 0;
    // ACE stores the base class; the unit may hold a preset variant of it
    private _held = [primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit] select (_slot select S_CURR);
    private _rounds = _unit ammo _held;
    {
        _x params ["_mag", "_ammo"];
        if ((toLowerANSI _mag) in _compatible) then {
            _spare = _spare + 1;
            _rounds = _rounds + _ammo;
        };
    } forEach (magazinesAmmo _unit);
    (GVAR(ui) get "wMagCount") ctrlSetText format ["%1 MAG%2", _spare, ["S", ""] select (_spare == 1)];
    (GVAR(ui) get "wMagCount") ctrlSetTextColor ([C_TEXT, C_WORSE] select (_spare == 0));
    (GVAR(ui) get "wMagCount") ctrlSetTooltip "Spare magazines carried for this weapon (not counting the loaded one)";
    (GVAR(ui) get "wRounds") ctrlSetText format ["%1 RNDS TOTAL", _rounds];

    (GVAR(ui) get "wPicture") ctrlSetText getText (_cfgWeapon >> "picture");
    (GVAR(ui) get "wName") ctrlSetText getText (_cfgWeapon >> "displayName");
    (GVAR(ui) get "wClass") ctrlSetText format ["%1 · %2", _weapon, [_cfgWeapon] call FUNC(modTag)];
};

// ---- Attachment points
private _previewing = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "attachment"};
{
    (GVAR(ui) get ("wpoint_" + str _forEachIndex)) params ["_parts", "_label", "_current", "_count"];
    private _index = _x;
    private _active = _forEachIndex == GVAR(attachPoint);
    [_parts, ["normal", "active"] select _active] call FUNC(buttonState);
    _label ctrlSetTextColor ([C_SOFT, C_WHITE] select _active);

    private _class = if (_previewing && {_active}) then {GVAR(preview) select 2} else {[GVAR(weaponTab), _index] call FUNC(currentClass)};
    private _root = ["CfgWeapons", "CfgMagazines"] select (_index == 4);
    _current ctrlSetText ([getText (configFile >> _root >> _class >> "displayName"), "-"] select (_class == ""));
    _current ctrlSetTextColor ([C_TEXT, C_ACCENT] select (_previewing && _active));
    _count ctrlSetText str count ([_weapon, _forEachIndex] call FUNC(compatibleItems));
} forEach [2, 0, 1, 3, 4];

// ---- List tags
private _lnb = GVAR(ui) get "wList";
private _equipped = [GVAR(weaponTab), _aceIndex] call FUNC(currentClass);
private _previewClass = if (_previewing) then {GVAR(preview) select 2} else {"#none"};
GVAR(fillingList) = true;
private _select = -1;
for "_row" from 0 to ((lnbSize _lnb) select 0) - 1 do {
    private _class = _lnb lnbData [_row, 0];
    if (_class != "#") then {
        private _tag = switch (true) do {
            case (_class == _previewClass): {"PREVIEW"};
            case (_class == _equipped): {"ATTACHED"};
            default {""};
        };
        _lnb lnbSetText [[_row, 3], _tag];
        _lnb lnbSetColor [[_row, 3], [C_SOFT, C_ACCENT] select (_tag == "PREVIEW")];
        if (_tag == "PREVIEW" || {_tag == "ATTACHED" && _select == -1}) then {_select = _row};
    };
};
if (_select != -1 && {lnbCurSelRow _lnb != _select}) then {_lnb lnbSetCurSelRow _select};
GVAR(fillingList) = false;

// ---- Banner
(GVAR(ui) get "wBanner") ctrlShow _previewing;
if (_previewing) then {
    (GVAR(ui) get "wBannerName") ctrlSetText (GVAR(preview) select 7);
};

// ---- Stats: the weapon, then equipped vs previewed attachment
private _rows = if (_weapon == "") then {[]} else {
    ["L", _slot select S_STAT, _cfgWeapon, configNull] call FUNC(statRows)
};
private _statTab = [STAT_R_OPTIC, STAT_R_MUZZLE, STAT_R_SIDE, STAT_R_BIPOD, STAT_R_MAG] select GVAR(attachPoint);
private _attachRoot = ["CfgWeapons", "CfgMagazines"] select (GVAR(attachPoint) == 4);
private _cfgA = if (_equipped == "") then {configNull} else {configFile >> _attachRoot >> _equipped};
private _cfgB = if (_previewing && {(GVAR(preview) select 2) != ""}) then {configFile >> _attachRoot >> (GVAR(preview) select 2)} else {configNull};
private _attachRows = if (isNull _cfgA && {isNull _cfgB}) then {[]} else {
    ["R", _statTab, _cfgA, _cfgB] call FUNC(statRows)
};
if (_attachRows isNotEqualTo []) then {
    _rows pushBack [format ["— %1 —", ["OPTIC", "MUZZLE", "SIDE RAIL", "UNDERBARREL", "MAGAZINE"] select GVAR(attachPoint)], -1, -1, "", "", 0];
    _rows append _attachRows;
};
[GVAR(ui) get "wStats", _rows, WEAPON_RIGHT_W, _previewing, "No weapon"] call FUNC(renderStats);

// ---- Magazines
private _magsGroup = GVAR(ui) get "wMags";
[_magsGroup] call FUNC(clearGroup);
private _mags = [_weapon, 4] call FUNC(compatibleItems);
private _carried = magazines _unit;
private _total = 0;
{
    private _mag = _x;
    private _cfg = configFile >> "CfgMagazines" >> _mag;
    private _count = {_x == _mag} count _carried;
    _total = _total + _count;
    private _y = _forEachIndex * 50;
    [_magsGroup, "text", [22, _y + 2, 260, 24], getText (_cfg >> "displayName"), C_TEXT, F_BODY, 14] call FUNC(ctrl);
    [_magsGroup, "text", [22, _y + 24, 260, 18], format ["%1 rnd · %2 kg each", getNumber (_cfg >> "count"), (([_cfg] call FUNC(itemMass)) * MASS_TO_KG) toFixed 2], C_MUTED, F_MONO, 9] call FUNC(ctrl);
    [_magsGroup, [WEAPON_RIGHT_W - 22 - 128, _y + 6, 36, 34], "-", compile format ["[%1, -1] call %2", str _mag, QFUNC(magChange)], "default", 18] call FUNC(button);
    [_magsGroup, "textCenter", [WEAPON_RIGHT_W - 22 - 88, _y + 6, 48, 34], str _count, [C_DIM, C_WHITE] select (_count > 0), F_MONO, 13] call FUNC(ctrl);
    [_magsGroup, [WEAPON_RIGHT_W - 22 - 36, _y + 6, 36, 34], "+", compile format ["[%1, 1] call %2", str _mag, QFUNC(magChange)], "accent", 18] call FUNC(button);
} forEach _mags;
if (_mags isEqualTo []) then {
    [_magsGroup, "text", [22, 4, WEAPON_RIGHT_W - 44, 24], "No magazines available", C_MUTED, F_BODY, 14] call FUNC(ctrl);
};
(GVAR(ui) get "wMagsInfo") ctrlSetText format ["Added to vest first, then uniform, then backpack · %1 carried", _total];
