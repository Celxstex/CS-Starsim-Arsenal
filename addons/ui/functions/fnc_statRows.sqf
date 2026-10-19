#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Builds comparison rows from ACE's arsenal stats (the same stats ACE shows), plus mass.
 *
 * Arguments:
 * 0: "L" for left panel stats (gear), "R" for right panel stats (attachments, magazines) <STRING>
 * 1: ACE stat tab index <NUMBER>
 * 2: Item A config (equipped) <CONFIG>
 * 3: Item B config (preview), configNull for none <CONFIG>
 *
 * Return Value:
 * Rows [[title, bar A, bar B, text A, text B, verdict], ...]. Bars are 0..1 or -1 when the
 * stat has no bar. Verdict is 1 when B is better, -1 when worse, 0 otherwise. <ARRAY>
 *
 * Public: No
 */

params ["_side", "_tab", "_cfgA", "_cfgB"];

private _list = [missionNamespace getVariable ["ace_arsenal_statsListLeftPanel", []], missionNamespace getVariable ["ace_arsenal_statsListRightPanel", []]] select (_side == "R");
private _stats = _list param [_tab, []];
private _hasB = !isNull _cfgB;
private _rows = [];

// Mass first (lower is better)
private _massA = [_cfgA] call FUNC(itemMass);
private _massB = [_cfgB] call FUNC(itemMass);
private _fnc_kg = {
    params ["_mass", "_cfg"];
    if (isNull _cfg) then {"-"} else {format ["%1 kg", (_mass * MASS_TO_KG) toFixed 2]}
};
_rows pushBack [
    "Mass", -1, -1,
    [_massA, _cfgA] call _fnc_kg,
    [_massB, _cfgB] call _fnc_kg,
    if (_hasB && {!isNull _cfgA}) then {
        if (abs (_massB - _massA) < 0.01) then {0} else {[1, -1] select (_massB > _massA)}
    } else {0}
];

private _fnc_text = {
    params ["_result"];
    if (_result isEqualType []) then {_result = _result joinString ", "};
    if !(_result isEqualType "") then {_result = str _result};
    _result
};

{
    _x params ["", "_entry", "_title", "_bools", "_statements", ["_name", ""]];
    if ((_name find "ACE_mass") != 0) then {
        _bools params ["_showBar", "_showText"];
        _statements params [["_barCode", {}, [{}]], ["_textCode", {}, [{}]], ["_condition", {true}, [{}]]];

        private _okA = !isNull _cfgA && {[_entry, _cfgA] call _condition};
        private _okB = _hasB && {[_entry, _cfgB] call _condition};

        if (_okA || _okB) then {
            private _barA = -1;
            private _barB = -1;
            if (_showBar) then {
                if (_okA) then {_barA = (([_entry, _cfgA] call _barCode) max 0) min 1};
                if (_okB) then {_barB = (([_entry, _cfgB] call _barCode) max 0) min 1};
            };
            private _textA = "";
            private _textB = "";
            if (_showText) then {
                if (_okA) then {_textA = [[_entry, _cfgA] call _textCode] call _fnc_text};
                if (_okB) then {_textB = [[_entry, _cfgB] call _textCode] call _fnc_text};
            };
            private _verdict = 0;
            if (_showBar && {_okA} && {_okB} && {abs (_barB - _barA) > 0.005}) then {
                _verdict = [-1, 1] select (_barB > _barA);
            };
            _rows pushBack [_title, _barA, _barB, _textA, _textB, _verdict];
        };
    };
} forEach _stats;

_rows
