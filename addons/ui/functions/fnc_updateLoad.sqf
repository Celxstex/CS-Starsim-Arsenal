#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates total mass, container fill and the carry-load tier.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _unit = CENTER;
private _mass = loadAbs _unit;

private _delta = "";
if (GVAR(preview) isNotEqualTo []) then {
    private _diff = (_mass - (GVAR(preview) select 6)) * MASS_TO_KG;
    if (abs _diff >= 0.05) then {
        _delta = format ["  (%1%2)", ["", "+"] select (_diff > 0), _diff toFixed 1];
    };
};
(GVAR(ui) get "loadMass") ctrlSetText format ["%1 kg%2", (_mass * MASS_TO_KG) toFixed 1, _delta];

private _barW = STATS_W - 44;
{
    _x params ["_class", "_load"];
    (GVAR(ui) get ("load_" + str _forEachIndex)) params ["_text", "_bar", "_pack"];
    [_pack, switch (true) do {
        case (_class == ""): {"disabled"};
        case (GVAR(slot) == "CRG" && {GVAR(cargoTarget) == _forEachIndex}): {"active"};
        default {"normal"};
    }] call FUNC(buttonState);
    if (_class == "") then {
        _text ctrlSetText "NONE";
        _bar ctrlSetPositionW 0;
    } else {
        private _capacity = getContainerMaxLoad _class;
        _text ctrlSetText format ["%1 / %2", round (_load * _capacity), round _capacity];
        _bar ctrlSetPositionW PX_X(_barW * ((_load max 0) min 1));
        _bar ctrlSetBackgroundColor ([C_ACCENT, C_WORSE] select (_load > 0.9));
    };
    _bar ctrlCommit 0;
} forEach [
    [uniform _unit, loadUniform _unit],
    [vest _unit, loadVest _unit],
    [backpack _unit, loadBackpack _unit]
];

private _fnc_tier = {
    params ["_ratio"];
    switch (true) do {
        case (_ratio < LOAD_MODERATE): {"Light"};
        case (_ratio < LOAD_HEAVY): {"Moderate"};
        default {"Heavy"};
    }
};
private _ratio = load _unit;
private _tier = [_ratio] call _fnc_tier;

// While previewing, say when the item changes the tier
private _was = "";
if (GVAR(preview) isNotEqualTo [] && {_ratio > 0}) then {
    private _ratioBefore = (GVAR(preview) select 6) * _ratio / _mass;
    private _tierBefore = [_ratioBefore] call _fnc_tier;
    if (_tierBefore != _tier) then {_was = format [" (was %1)", _tierBefore]};
};
(GVAR(ui) get "loadTier") ctrlSetText format ["%1 · %2%3%4", _tier, round (_ratio * 100), "%", _was];
(GVAR(ui) get "loadTier") ctrlSetTextColor ([C_SOFT, C_WORSE] select (_tier == "Heavy"));
