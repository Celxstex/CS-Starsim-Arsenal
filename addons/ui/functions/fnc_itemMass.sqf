#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns an item's mass in Arma mass units (0.1 lb).
 *
 * Arguments:
 * 0: Item config <CONFIG>
 *
 * Return Value:
 * Mass <NUMBER>
 *
 * Public: No
 */

params ["_cfg"];

if (isNull _cfg) exitWith {0};

switch (true) do {
    case (isNumber (_cfg >> "WeaponSlotsInfo" >> "mass")): {getNumber (_cfg >> "WeaponSlotsInfo" >> "mass")};
    case (isNumber (_cfg >> "ItemInfo" >> "mass")): {getNumber (_cfg >> "ItemInfo" >> "mass")};
    default {getNumber (_cfg >> "mass")};
}
