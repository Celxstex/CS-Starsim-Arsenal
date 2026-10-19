#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Fills the item list for the current slot. Items that share an ACE Arsenal Extended
 * model are shown as one row; their variants are picked in the right panel. Rows are
 * sorted by the active sort, and pinned items are listed first whatever the filters.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _slot = [GVAR(slot)] call FUNC(slot);
private _kind = _slot select S_KIND;

call FUNC(updateSortChips);

if (_kind == "cargo") exitWith {
    call FUNC(fillCargoList);
};

private _lnb = GVAR(ui) get "itemList";
private _search = toLowerANSI GVAR(search);
private _fnc_matches = {
    params ["_name", "_class", "_tag"];
    _search == "" || {(toLowerANSI _name) find _search != -1} || {(toLowerANSI _class) find _search != -1} || {(toLowerANSI _tag) find _search != -1}
};

// Rows: [section, class, name, picture, mod tag, variant count, sub, pinned, meta]
private _rows = [];
private _modCounts = createHashMap;

private _fnc_addItems = {
    params ["_root", "_classes", "_section", "_sub"];

    private _equipped = [GVAR(slot), _sub] call FUNC(currentClass);
    private _previewClass = "";
    if (GVAR(preview) isNotEqualTo []) then {
        GVAR(preview) params ["_pKind", "_pSlot", "_pClass", "_pSub"];
        if (_pKind == "item" && {_pSlot == GVAR(slot)} && {_pSub isEqualTo _sub}) then {
            _previewClass = _pClass;
        };
    };

    // Group variants by model
    private _groups = createHashMap;
    private _singles = [];
    {
        private _model = (GVAR(itemModel) getOrDefault [_x, []]) param [1, ""];
        if (_model == "") then {
            _singles pushBack _x;
        } else {
            (_groups getOrDefault [_model, [], true]) pushBack _x;
        };
    } forEach _classes;

    private _entries = _singles apply {[_x, 1]};
    {
        private _members = _y;
        private _rep = switch (true) do {
            case (_equipped in _members): {_equipped};
            case (_previewClass in _members): {_previewClass};
            default {
                private _sorted = _members apply {[getText (configFile >> _root >> _x >> "displayName"), _x]};
                _sorted sort true;
                (_sorted select 0) select 1
            };
        };
        _entries pushBack [_rep, count _members];
    } forEach _groups;

    private _sectionRows = [];
    {
        _x params ["_class", "_variants"];
        private _cfg = configFile >> _root >> _class;
        private _name = getText (_cfg >> "displayName");
        if (_name != "") then {
            private _tag = [_cfg] call FUNC(modTag);
            if ([_name, _class, _tag] call _fnc_matches) then {
                _modCounts set [_tag, (_modCounts getOrDefault [_tag, 0]) + 1];
                if (GVAR(modFilter) == "" || {GVAR(modFilter) == _tag}) then {
                    _sectionRows pushBack [_name, _tag, _cfg, [_section, _class, _name, getText (_cfg >> "picture"), _tag, _variants, _sub, false]];
                };
            };
        };
    } forEach _entries;

    _rows pushBack [_section, "", "<Nothing>", "", "", 0, _sub, false, ""];
    _rows append (([_sectionRows] call FUNC(sortItems)) apply {(_x select 0) + [_x select 1]});
};

switch (_kind) do {
    case "linked": {
        {
            _x params ["_label", "_virt", "_curr"];
            private _classes = keys (GVAR(allItems) getOrDefault [_virt, createHashMap]);
            _rows pushBack [_label, "#", _label, "", "", 0, _curr];
            ["CfgWeapons", _classes, _label, _curr] call _fnc_addItems;
        } forEach GVAR(linkedSlots);
    };
    case "identity": {
        if (is3DEN || {!(missionNamespace getVariable ["ace_arsenal_enableIdentityTabs", true])}) exitWith {
            _rows pushBack ["", "#", "Identity changes are turned off for this arsenal", "", "", 0, ""];
        };
        private _equippedFace = ["IDN", "face"] call FUNC(currentClass);
        private _equippedVoice = ["IDN", "voice"] call FUNC(currentClass);
        private _equippedInsignia = ["IDN", "insignia"] call FUNC(currentClass);

        {
            _x params ["_label", "_sub", "_entries"];
            _rows pushBack [_label, "#", _label, "", "", 0, _sub];
            private _sectionRows = [];
            {
                _x params ["_class", "_name", "_picture"];
                if ([_name, _class, ""] call _fnc_matches) then {
                    _sectionRows pushBack [_name, "", configNull, [_label, _class, _name, _picture, "", 0, _sub, false]];
                };
            } forEach _entries;
            if (_sub == "insignia") then {
                _rows pushBack [_label, "", "<Nothing>", "", "", 0, _sub];
            };
            _rows append (([_sectionRows] call FUNC(sortItems)) apply {(_x select 0) + [""]});
        } forEach [
            ["FACE", "face", (keys ace_arsenal_faceCache) apply {[_x, (ace_arsenal_faceCache get _x) select 0, ""]}],
            ["VOICE", "voice", (keys ace_arsenal_voiceCache) apply {[_x, getText (configFile >> "CfgVoice" >> _x >> "displayName"), ""]}],
            ["INSIGNIA", "insignia", (keys ace_arsenal_insigniaCache) apply {
                private _root = [configFile, campaignConfigFile, missionConfigFile] select (ace_arsenal_insigniaCache get _x);
                [_x, getText (_root >> "CfgUnitInsignia" >> _x >> "displayName"), getText (_root >> "CfgUnitInsignia" >> _x >> "texture")]
            }]
        ];
        GVAR(identityEquipped) = createHashMapFromArray [["face", _equippedFace], ["voice", _equippedVoice], ["insignia", _equippedInsignia]];
    };
    default {
        private _classes = [];
        {
            _classes append (keys _x);
        } forEach ([_slot] call FUNC(slotItemMaps));
        _classes = _classes arrayIntersect _classes;

        // Pinned items first, untouched by search and filters, as their exact variant
        private _pins = [GVAR(slot)] call FUNC(pinnedClasses);
        if (_pins isNotEqualTo []) then {
            private _root = _slot select S_ROOT;
            private _pinned = _pins apply {
                private _cfg = configFile >> _root >> _x;
                private _name = getText (_cfg >> "displayName");
                private _tag = [_cfg] call FUNC(modTag);
                [_name, _tag, _cfg, ["PINNED", _x, _name, getText (_cfg >> "picture"), _tag, 1, "", true]]
            };
            _rows pushBack ["PINNED", "#", format ["PINNED · %1", count _pins], "", "", 0, ""];
            _rows append (([_pinned] call FUNC(sortItems)) apply {(_x select 0) + [_x select 1]});
            _rows pushBack ["", "#", "ALL ITEMS", "", "", 0, ""];
        };

        [_slot select S_ROOT, _classes, "", ""] call _fnc_addItems;
    };
};

// ---- Write rows
GVAR(fillingList) = true;
lnbClear _lnb;
_lnb lnbSetColumnsPos [0, 0.17, 0.66, 0.8];

{
    _x params ["_section", "_class", "_name", "_picture", "_tag", "_variants", "_sub", ["_pinned", false], ["_meta", ""]];
    private _row = if (_class == "#") then {
        private _r = _lnb lnbAddRow ["", _name, "", ""];
        _lnb lnbSetColor [[_r, 1], C_ACCENT];
        _r
    } else {
        // The meta column shows what the list is sorted by, or the mod tag
        if (_meta == "") then {_meta = _tag};
        if (_meta == _tag && {_variants > 1}) then {_meta = format ["%1 · %2 VAR", _tag, _variants]};
        private _r = _lnb lnbAddRow ["", _name, _meta, ""];
        if (_picture != "") then {
            _lnb lnbSetPicture [[_r, 0], _picture];
        };
        _lnb lnbSetColor [[_r, 2], C_MUTED];
        private _details = [_tag, format ["%1 · %2 variants", _tag, _variants]] select (_variants > 1);
        _lnb lnbSetTooltip [[_r, 1], [format ["%1\n%2\n%3", _name, _class, _details], format ["%1\n%2", _name, _class]] select (_details == "")];
        _r
    };
    _lnb lnbSetData [[_row, 0], _class];
    _lnb lnbSetData [[_row, 1], str _sub];
    // Pinned rows keep their exact variant (see updateListTags)
    _lnb lnbSetValue [[_row, 0], [0, 1] select _pinned];
} forEach _rows;

(GVAR(ui) get "listTitle") ctrlSetText (_slot select S_LABEL);
(GVAR(ui) get "listCount") ctrlSetText format ["%1 ITEMS", {!((_x select 1) in ["", "#"]) && {!(_x param [7, false])}} count _rows];

[keys _modCounts apply {[_modCounts get _x, _x]}] call FUNC(updateModChips);

call FUNC(updateListTags);
GVAR(fillingList) = false;
