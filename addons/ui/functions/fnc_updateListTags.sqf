#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the EQUIPPED / PREVIEW tags in the item list without rebuilding it. Rows for a
 * variant model switch to the variant being previewed or worn.
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
private _slot = [GVAR(slot)] call FUNC(slot);
if ((_slot select S_KIND) == "cargo") exitWith {};

private _root = _slot select S_ROOT;
private _wasFilling = GVAR(fillingList);
GVAR(fillingList) = true;

private _pClass = "";
private _pSub = "";
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_kind", "_slotId", "_class", "_sub"];
    if (_kind == "item" && {_slotId == GVAR(slot)}) then {
        _pClass = _class;
        _pSub = _sub;
    };
};

private _equippedCache = createHashMap;
private _pins = GVAR(pins) getOrDefault [GVAR(slot), []];
private _currentRow = lnbCurSelRow _lnb;
private _selectRow = -1;
private _equippedRow = -1;

for "_row" from 0 to ((lnbSize _lnb) select 0) - 1 do {
    private _class = _lnb lnbData [_row, 0];
    if (_class != "#") then {
        private _sub = (parseSimpleArray ("[" + (_lnb lnbData [_row, 1]) + "]")) param [0, ""];
        private _equipped = _equippedCache getOrDefaultCall [str _sub, {[GVAR(slot), _sub] call FUNC(currentClass)}, true];

        // Swap a model row to the variant that's previewed or worn. Pinned rows stay as pinned.
        private _model = (GVAR(itemModel) getOrDefault [_class, []]) param [1, ""];
        if (_model != "" && {(_lnb lnbValue [_row, 0]) != 1}) then {
            private _target = switch (true) do {
                case (_pClass != "" && {_pSub isEqualTo _sub} && {((GVAR(itemModel) getOrDefault [_pClass, []]) param [1, ""]) == _model}): {_pClass};
                case (((GVAR(itemModel) getOrDefault [_equipped, []]) param [1, ""]) == _model): {_equipped};
                default {_class};
            };
            if (_target != _class) then {
                private _cfg = configFile >> _root >> _target;
                _class = _target;
                _lnb lnbSetData [[_row, 0], _target];
                _lnb lnbSetText [[_row, 1], getText (_cfg >> "displayName")];
                _lnb lnbSetPicture [[_row, 0], getText (_cfg >> "picture")];
                _lnb lnbSetTooltip [[_row, 1], format ["%1\n%2", getText (_cfg >> "displayName"), _target]];
            };
        };

        private _isPreview = _pClass != "" && {_class == _pClass} && {_sub isEqualTo _pSub};
        private _isEquipped = _class == _equipped;

        private _status = switch (true) do {
            case (_isPreview): {"PREVIEW"};
            case (_isEquipped): {"EQUIPPED"};
            case (_class in _pins): {"PINNED"};
            default {""};
        };
        _lnb lnbSetText [[_row, 3], _status];
        _lnb lnbSetColor [[_row, 3], switch (_status) do {
            case "PREVIEW": {C_ACCENT};
            case "PINNED": {C_DIM};
            default {C_SOFT};
        }];
        _lnb lnbSetColor [[_row, 1], [C_TEXT, C_WHITE] select (_isPreview || _isEquipped)];

        // An item can be listed twice (pinned and in the full list): keep the row that was clicked
        if (_isPreview && {_selectRow == -1 || {_row == _currentRow}}) then {_selectRow = _row};
        if (_isEquipped && {_equippedRow == -1 || {_row == _currentRow}}) then {_equippedRow = _row};
    };
};

if (_selectRow == -1) then {_selectRow = _equippedRow};
if (_selectRow != -1 && {lnbCurSelRow _lnb != _selectRow}) then {
    _lnb lnbSetCurSelRow _selectRow;
};

GVAR(fillingList) = _wasFilling;
