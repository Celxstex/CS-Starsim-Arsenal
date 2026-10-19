#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns a short tag for the mod an item comes from, e.g. "LS" or "3AS".
 *
 * Arguments:
 * 0: Item config <CONFIG>
 *
 * Return Value:
 * Tag <STRING>
 *
 * Public: No
 */

params ["_cfg"];

if (isNull _cfg) exitWith {""};

private _cache = uiNamespace getVariable QGVAR(modTagCache);
if (isNil "_cache") then {
    _cache = createHashMap;
    uiNamespace setVariable [QGVAR(modTagCache), _cache];
};

// The mod that created the class: configSourceMod returns the last mod to change it (often ACE)
private _source = (configSourceModList _cfg) param [0, configSourceMod _cfg];

_cache getOrDefaultCall [_source, {
    private _name = if (_source == "") then {"Arma 3"} else {(modParams [_source, ["name"]]) param [0, _source]};
    if (_name == "") then {_name = _source};

    private _match = GVAR(modTags) findIf {(_name find (_x select 0)) != -1};
    if (_match != -1) then {
        (GVAR(modTags) select _match) select 1
    } else {
        // First word, letters and digits only
        private _word = (_name splitString " -_:") param [0, "MOD"];
        toUpper (_word select [0, 5])
    }
}, true]
