#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Groups the arsenal's items into ACE Arsenal Extended models so each model shows
 * as one row with variant options. Reads the same config ACE Arsenal Extended uses:
 * XtdGearInfos >> root >> class (or root >> class >> XtdGearInfo) and XtdGearModels.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

GVAR(itemModel) = createHashMap; // class -> [root, model, option values]
GVAR(models) = createHashMap;    // "root|model" -> hashmap of option values -> class

private _cache = uiNamespace getVariable QGVAR(modelInfoCache);
if (isNil "_cache") then {
    _cache = createHashMap;
    uiNamespace setVariable [QGVAR(modelInfoCache), _cache];
};

private _fnc_info = {
    params ["_root", "_class"];
    _cache getOrDefaultCall [_root + "|" + _class, {
        private _info = configFile >> "XtdGearInfos" >> _root >> _class;
        if (!isClass _info) then {
            _info = configFile >> _root >> _class >> "XtdGearInfo";
        };
        private _model = getText (_info >> "model");
        if (_model == "") then {
            []
        } else {
            private _options = getArray (configFile >> "XtdGearModels" >> _root >> _model >> "options");
            [_model, _options apply {getText (_info >> _x)}]
        };
    }, true]
};

{
    private _root = _x select S_ROOT;
    if (_root != "" && {(_x select S_VIRT) isNotEqualTo []}) then {
        {
            {
                private _class = _x;
                private _info = [_root, _class] call _fnc_info;
                if (_info isNotEqualTo []) then {
                    _info params ["_model", "_values"];
                    GVAR(itemModel) set [_class, [_root, _model, _values]];
                    (GVAR(models) getOrDefault [_root + "|" + _model, createHashMap, true]) set [_values, _class];
                };
            } forEach (keys _x);
        } forEach ([_x] call FUNC(slotItemMaps));
    };
} forEach GVAR(slots);

// Variants hidden from the arsenal list but reachable through options (ACE Arsenal Extended's scopeHiddenArsenal)
if (!isNil "aceax_arsenal_hiddenOptions") then {
    {
        private _key = _x;
        (_key splitString "|") params ["_root", "_model"];
        private _hidden = aceax_arsenal_hiddenOptions getOrDefault [_model, createHashMap];
        {
            private _class = configName _y;
            private _variants = GVAR(models) get _key;
            if !(_x in _variants) then {
                _variants set [_x, _class];
                GVAR(itemModel) set [_class, [_root, _model, _x]];
            };
        } forEach _hidden;
    } forEach (keys GVAR(models));
};
