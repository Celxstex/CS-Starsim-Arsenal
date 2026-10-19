#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the sort that applies to a slot. A sort the slot doesn't offer (e.g. ARMOR
 * on weapons) falls back to name, without forgetting the choice for other slots.
 *
 * Arguments:
 * 0: Slot id <STRING>
 *
 * Return Value:
 * [mode, descending, available modes] <ARRAY>
 *
 * Public: No
 */

params ["_slotId"];

private _options = switch (([_slotId] call FUNC(slot)) select S_KIND) do {
    case "identity": {["NAME"]};
    case "headgear": {["NAME", "MOD", "MASS", "ARMOR"]};
    case "vest": {["NAME", "MOD", "MASS", "LOAD", "ARMOR"]};
    case "uniform";
    case "backpack": {["NAME", "MOD", "MASS", "LOAD"]};
    default {["NAME", "MOD", "MASS"]};
};

if (GVAR(sort) in _options) then {
    [GVAR(sort), GVAR(sortDesc), _options]
} else {
    ["NAME", false, _options]
}
