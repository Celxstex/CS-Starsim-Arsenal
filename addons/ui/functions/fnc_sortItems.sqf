#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Sorts item list entries by the active sort and works out the value shown next to
 * each one (mod tag, mass, capacity or armour).
 *
 * Arguments:
 * 0: Entries [name, mod tag, config, payload] <ARRAY>
 *
 * Return Value:
 * Sorted [payload, meta text] <ARRAY>
 *
 * Public: No
 */

params ["_entries"];

([GVAR(slot)] call FUNC(sortMode)) params ["_mode", "_desc"];

private _armorCache = uiNamespace getVariable QGVAR(armorCache);
if (isNil "_armorCache") then {
    _armorCache = createHashMap;
    uiNamespace setVariable [QGVAR(armorCache), _armorCache];
};

// Each entry becomes [key 1, key 2, index]. Numbers are negated for descending so
// names stay A-Z on ties.
private _metas = [];
private _keyed = _entries apply {
    _x params ["_name", "_tag", "_cfg"];
    private _meta = _tag;
    private _key = switch (_mode) do {
        case "MOD": {[_tag, _name]};
        case "MASS": {
            private _kg = ([_cfg] call FUNC(itemMass)) * MASS_TO_KG;
            _meta = format ["%1 kg", _kg toFixed 1];
            [[_kg, -_kg] select _desc, _name]
        };
        case "LOAD": {
            private _capacity = if (isNull _cfg) then {0} else {getContainerMaxLoad (configName _cfg)};
            _meta = format ["%1 load", round _capacity];
            [[_capacity, -_capacity] select _desc, _name]
        };
        case "ARMOR": {
            private _armor = _armorCache getOrDefaultCall [configName _cfg, {
                private _max = 0;
                {
                    _max = _max max getNumber (_x >> "armor");
                } forEach configProperties [_cfg >> "ItemInfo" >> "HitpointsProtectionInfo", "isClass _x", true];
                _max
            }, true];
            _meta = format ["%1 armor", round _armor];
            [[_armor, -_armor] select _desc, _name]
        };
        default {[_name, ""]};
    };
    _key pushBack (_metas pushBack _meta);
    _key
};

_keyed sort true;
if (_desc && {_mode in ["NAME", "MOD"]}) then {
    reverse _keyed;
};

_keyed apply {
    private _index = _x select 2;
    [(_entries select _index) select 3, _metas select _index]
}
