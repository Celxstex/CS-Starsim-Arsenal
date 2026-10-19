#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the line under the ITEMS list for the selected item: how many are in the
 * container, its weight, roughly how many more fit, and a warning when adding one
 * would make the load Heavy. Also fills the amount box with the current count.
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
private _container = [uniform _unit, vest _unit, backpack _unit] select GVAR(cargoTarget);
private _name = ["uniform", "vest", "pack"] select GVAR(cargoTarget);
private _info = GVAR(ui) get "cargoInfo";
private _qty = GVAR(ui) get "cargoQty";

private _lnb = GVAR(ui) get "itemList";
private _row = lnbCurSelRow _lnb;
private _class = if (_row < 0) then {""} else {_lnb lnbData [_row, 0]};

_info ctrlSetTextColor C_SOFT;
_info ctrlSetTooltip "";

if (_container == "") exitWith {
    _info ctrlSetText format ["No %1 worn", _name];
};
if (_class in ["", "#"]) exitWith {
    _info ctrlSetText "Pick an item";
};

private _count = {_x == _class} count ([uniformItems _unit, vestItems _unit, backpackItems _unit] select GVAR(cargoTarget));
if (focusedCtrl (ctrlParent _qty) isNotEqualTo _qty) then {
    _qty ctrlSetText str _count;
};

private _mass = [[_class] call FUNC(itemConfig)] call FUNC(itemMass);
private _load = [loadUniform _unit, loadVest _unit, loadBackpack _unit] select GVAR(cargoTarget);
private _free = getContainerMaxLoad _container * (1 - _load);
private _fits = if (_mass > 0) then {floor ((_free / _mass) + 0.001) max 0} else {-1};

private _parts = [format ["x%1 in %2", _count, _name], format ["%1 kg", (_mass * MASS_TO_KG) toFixed 2]];
_parts pushBack (switch (true) do {
    case (_fits == 0): {"full"};
    case (_fits > 0): {format ["%1 fit", _fits]};
    default {""};
});

// Would one more tip the whole kit into Heavy?
private _ratio = load _unit;
private _max = if (_ratio > 0) then {loadAbs _unit / _ratio} else {getNumber (configFile >> "CfgInventoryGlobalVariable" >> "maxSoldierLoad")};
private _after = if (_max > 0) then {(loadAbs _unit + _mass) / _max} else {0};
if (_fits != 0 && {_ratio < LOAD_HEAVY} && {_after >= LOAD_HEAVY}) then {
    _parts pushBack "HEAVY NEXT";
    _info ctrlSetTextColor C_WORSE;
    _info ctrlSetTooltip "Adding one more puts your carry load over the Heavy limit";
};
if (_ratio >= LOAD_HEAVY) then {
    _parts pushBack "HEAVY";
    _info ctrlSetTextColor C_WORSE;
    _info ctrlSetTooltip "Your carry load is already Heavy";
};

_info ctrlSetText ((_parts select {_x != ""}) joinString " · ");
