#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Pins or unpins an item. Pinned items sit at the top of their slot's list whatever
 * the search, mod filter or category, stay pinned when you change slot or view, are
 * remembered between sessions, and fill the extra columns of the full compare.
 *
 * Arguments:
 * 0: Class name, "" for the previewed or selected item <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_class", ""]];

private _slot = [GVAR(slot)] call FUNC(slot);
if ((_slot select S_KIND) in ["linked", "identity"]) exitWith {
    ["Pins work on gear and inventory items", true] call FUNC(message);
};

if (_class == "") then {
    if (GVAR(preview) isNotEqualTo []) then {
        GVAR(preview) params ["_kind", "_slotId", "_pClass", "_sub"];
        if (_kind == "item" && {_slotId == GVAR(slot)} && {_sub isEqualTo ""}) then {
            _class = _pClass;
        };
    };
};
if (_class == "") then {
    private _lnb = GVAR(ui) get "itemList";
    private _row = lnbCurSelRow _lnb;
    if (_row >= 0) then {
        _class = _lnb lnbData [_row, 0];
    };
};
if (_class in ["", "#"]) exitWith {
    ["Select an item first, then press P to pin it"] call FUNC(message);
};

private _name = getText (([_class, _slot select S_ROOT] call FUNC(itemConfig)) >> "displayName");
private _pins = GVAR(pins) getOrDefault [GVAR(slot), [], true];
if (_class in _pins) then {
    _pins deleteAt (_pins find _class);
    if (_pins isEqualTo []) then {
        GVAR(pins) deleteAt GVAR(slot);
    };
    [format ["Unpinned %1", _name]] call FUNC(message);
} else {
    _pins pushBack _class;
    [format ["Pinned %1", _name]] call FUNC(message);
};

profileNamespace setVariable [QGVAR(pins), GVAR(pins) apply {[_x, _y]}];
GVAR(profileDirty) = true;

call FUNC(fillItemList);
call FUNC(updateSidePanel);
