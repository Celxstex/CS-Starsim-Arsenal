#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Fills the item list for the ITEMS slot: pinned items, then what's already in the
 * chosen container, then everything else, each part sorted by the active sort. Also
 * draws the container picker and category chips.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _lnb = GVAR(ui) get "itemList";
private _search = toLowerANSI GVAR(search);
private _unit = CENTER;
private _containerName = ["UNIFORM", "VEST", "BACKPACK"] select GVAR(cargoTarget);

private _carried = createHashMap;
{
    _carried set [_x, (_carried getOrDefault [_x, 0]) + 1];
} forEach ([uniformItems _unit, vestItems _unit, backpackItems _unit] select GVAR(cargoTarget));

// Misc items are split the way ACE's right panel splits them: one category per
// custom button (ACE adds Medical and Tools, other mods can add more), the rest in MISC
private _customCats = [];
private _customOf = createHashMap; // lower-case class -> category id
{
    if (!isNil "_x") then {
        _x params [["_items", []], "", ["_tooltip", ""]];
        private _id = toUpperANSI _tooltip;
        if (_id == "" || {_id in ["ALL", "AMMO", "MAGS", "THROW", "EXPL", "MISC"]} || {_customCats findIf {(_x select 0) == _id} != -1}) then {
            _id = format ["%1 %2", ["CUSTOM", _id] select (_id != ""), _forEachIndex + 1];
        };
        _customCats pushBack [_id, _tooltip];
        {
            private _key = toLowerANSI _x;
            if !(_key in _customOf) then {_customOf set [_key, _id]};
        } forEach _items;
    };
} forEach (missionNamespace getVariable ["ace_arsenal_customRightPanelButtons", []]);

// Category of each item the arsenal offers
private _catOf = createHashMap;
{
    _x params ["_cat", "_indices"];
    {
        {
            _catOf set [_x, if (_cat == "MISC") then {_customOf getOrDefault [toLowerANSI _x, "MISC"]} else {_cat}];
        } forEach keys (GVAR(allItems) getOrDefault [_x, createHashMap]);
    } forEach _indices;
} forEach [
    ["MAGS", [IDX_VIRT_ITEMS_ALL, IDX_VIRT_UNIQUE_VIRT_ITEMS_ALL]],
    ["THROW", [IDX_VIRT_GRENADES, IDX_VIRT_UNIQUE_GRENADES]],
    ["EXPL", [IDX_VIRT_EXPLOSIVES, IDX_VIRT_UNIQUE_EXPLOSIVES]],
    ["MISC", [IDX_VIRT_MISC_ITEMS, IDX_VIRT_UNIQUE_MISC_ITEMS, IDX_VIRT_MISC_GOGGLES]]
];

// Chips: [id, tooltip], only for categories that have something in them
private _present = createHashMap;
{
    _present set [_y, true];
} forEach _catOf;
private _categories = [
    ["ALL", "Everything"],
    ["AMMO", "Magazines for the weapons you carry"],
    ["MAGS", "All magazines"],
    ["THROW", "Grenades and other throwables"],
    ["EXPL", "Explosives"]
] select {(_x select 0) in ["ALL", "AMMO"] || {(_x select 0) in _present}};
_categories append (_customCats select {(_x select 0) in _present});
if ("MISC" in _present) then {
    _categories pushBack ["MISC", "Everything else"];
};
if (_categories findIf {(_x select 0) == GVAR(cargoCat)} == -1) then {
    GVAR(cargoCat) = "ALL";
};

// AMMO: magazines for every muzzle of the weapons carried
private _ammo = createHashMap;
if (GVAR(cargoCat) == "AMMO") then {
    {
        private _weapon = _x;
        if (_weapon != "") then {
            {
                {
                    _ammo set [toLowerANSI _x, true];
                } forEach (compatibleMagazines [_weapon, _x]);
            } forEach (_weapon call CBA_fnc_getMuzzles);
        };
    } forEach [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit];
};

private _pins = [GVAR(slot)] call FUNC(pinnedClasses);
private _modCounts = createHashMap;
private _pinned = [];
private _inside = [];
private _rest = [];
{
    private _class = _x;
    private _cat = _y;
    private _cfg = [_class] call FUNC(itemConfig);
    private _name = getText (_cfg >> "displayName");
    if (_name != "") then {
        private _tag = [_cfg] call FUNC(modTag);
        private _count = _carried getOrDefault [_class, 0];
        private _entry = [_name, _tag, _cfg, [_class, _name, getText (_cfg >> "picture"), _tag, _count]];
        if (_class in _pins) then {
            // Pinned items ignore search, mod and category
            _pinned pushBack _entry;
        } else {
            private _matches = _search == "" || {(toLowerANSI _name) find _search != -1} || {(toLowerANSI _class) find _search != -1};
            private _inCat = switch (GVAR(cargoCat)) do {
                case "ALL": {true};
                case "AMMO": {(toLowerANSI _class) in _ammo};
                default {_cat == GVAR(cargoCat)};
            };
            if (_matches && _inCat) then {
                _modCounts set [_tag, (_modCounts getOrDefault [_tag, 0]) + 1];
                if (GVAR(modFilter) == "" || {GVAR(modFilter) == _tag}) then {
                    [_rest, _inside] select (_count > 0) pushBack _entry;
                };
            };
        };
    };
} forEach _catOf;

// Rows: ["#", label] for headers, [class, name, picture, tag, count, meta, pinned] for items
private _rows = [];
private _headers = _pinned isNotEqualTo [] || {_inside isNotEqualTo []};
private _fnc_section = {
    params ["_label", "_entries", "_isPinned"];
    if (_entries isEqualTo []) exitWith {};
    if (_headers) then {_rows pushBack ["#", _label]};
    {
        _x params ["_payload", "_meta"];
        _rows pushBack (_payload + [_meta, _isPinned]);
    } forEach ([_entries] call FUNC(sortItems));
};
[format ["PINNED · %1", count _pinned], _pinned, true] call _fnc_section;
[format ["IN %1", _containerName], _inside, false] call _fnc_section;
[
    createHashMapFromArray [["ALL", "ALL ITEMS"], ["AMMO", "AMMO FOR YOUR WEAPONS"], ["MAGS", "MAGAZINES"], ["THROW", "THROWABLES"], ["EXPL", "EXPLOSIVES"], ["MISC", "MISC ITEMS"]] getOrDefault [GVAR(cargoCat), GVAR(cargoCat)],
    _rest, false
] call _fnc_section;

GVAR(fillingList) = true;
private _selected = _lnb lnbData [(lnbCurSelRow _lnb) max 0, 0];
lnbClear _lnb;
_lnb lnbSetColumnsPos [0, 0.17, 0.68, 0.85];
private _selectRow = -1;
{
    if ((_x select 0) == "#") then {
        private _row = _lnb lnbAddRow ["", _x select 1, "", ""];
        _lnb lnbSetColor [[_row, 1], C_ACCENT];
        _lnb lnbSetData [[_row, 0], "#"];
    } else {
        _x params ["_class", "_name", "_picture", "_tag", "_count", "_meta", "_isPinned"];
        private _row = _lnb lnbAddRow ["", _name, _meta, ["", format ["x%1", _count]] select (_count > 0)];
        _lnb lnbSetPicture [[_row, 0], _picture];
        _lnb lnbSetData [[_row, 0], _class];
        _lnb lnbSetData [[_row, 1], """"""];
        _lnb lnbSetColor [[_row, 2], C_MUTED];
        _lnb lnbSetColor [[_row, 3], [C_DIM, C_ACCENT] select (_count > 0)];
        _lnb lnbSetTooltip [[_row, 1], format ["%1\n%2\n%3%4", _name, _class, _tag, ["", " · pinned"] select _isPinned]];
        if (_class == _selected && {_selectRow == -1}) then {
            _selectRow = _row;
        };
    };
} forEach _rows;
if (_rows isEqualTo []) then {
    private _row = _lnb lnbAddRow ["", "No items match", "", ""];
    _lnb lnbSetData [[_row, 0], "#"];
    _lnb lnbSetColor [[_row, 1], C_MUTED];
};
if (_selectRow != -1) then {
    _lnb lnbSetCurSelRow _selectRow;
};
GVAR(fillingList) = false;

(GVAR(ui) get "listTitle") ctrlSetText format ["PACKING · %1", _containerName];
(GVAR(ui) get "listCount") ctrlSetText format ["%1 ITEMS", count _inside + count _rest];

[keys _modCounts apply {[_modCounts get _x, _x]}] call FUNC(updateModChips);

// Container picker, with how full each one is
private _chips = GVAR(ui) get "cargoChips";
[_chips] call FUNC(clearGroup);
{
    private _has = [uniform _unit, vest _unit, backpack _unit] select _forEachIndex;
    private _load = [loadUniform _unit, loadVest _unit, loadBackpack _unit] select _forEachIndex;
    private _label = if (_has == "") then {_x} else {format ["%1 %2%3", _x, round (_load * 100), "%"]};
    private _parts = [_chips, [_forEachIndex * 132, 0, 126, 30], _label, compile format ["%1 = %2; call %3; call %4", QGVAR(cargoTarget), _forEachIndex, QFUNC(fillCargoList), QFUNC(updateSidePanel)], "chip", 11, F_MONO] call FUNC(button);
    (_parts select 3) ctrlSetTooltip format ["Add items to the %1", toLowerANSI _x];
    [_parts, switch (true) do {
        case (_has == ""): {"disabled"};
        case (GVAR(cargoTarget) == _forEachIndex): {"active"};
        default {"normal"};
    }] call FUNC(buttonState);
} forEach ["UNIFORM", "VEST", "BACKPACK"];

// Category chips, wrapping onto more lines when mods add categories
private _cats = GVAR(ui) get "cargoCats";
[_cats] call FUNC(clearGroup);
private _maxW = LIST_W - 36;
private _xPos = 0;
private _yPos = 0;
{
    _x params ["_id", "_tip"];
    private _w = ((count _id) * 8 + 18) min _maxW;
    if (_xPos > 0 && {_xPos + _w > _maxW}) then {
        _xPos = 0;
        _yPos = _yPos + 32;
    };
    private _parts = [_cats, [_xPos, _yPos, _w, 26], _id, compile format ["%1 = %2; call %3", QGVAR(cargoCat), str _id, QFUNC(fillCargoList)], "chip", 10, F_MONO] call FUNC(button);
    [_parts, ["normal", "active"] select (GVAR(cargoCat) == _id)] call FUNC(buttonState);
    (_parts select 3) ctrlSetTooltip _tip;
    _xPos = _xPos + _w + 6;
} forEach _categories;

// Fit the list under however many lines of chips there are
private _catsH = _yPos + 26;
_cats ctrlSetPositionH PX_Y(_catsH);
_cats ctrlCommit 0;
private _listY = 214 + _catsH + 8;
(GVAR(ui) get "listLine") ctrlSetPositionY PX_Y(_listY - 1);
(GVAR(ui) get "listLine") ctrlCommit 0;
_lnb ctrlSetPosition [0, PX_Y(_listY), PX_X(LIST_W), PX_Y((GVAR(ui) get "listPanelH") - _listY - CARGO_BAR_H)];
_lnb ctrlCommit 0;

call FUNC(updateCargoInfo);
