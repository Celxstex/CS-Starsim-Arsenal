#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Switches the Weapon view to another weapon. A pending preview is reverted.
 *
 * Arguments:
 * 0: Weapon slot id ("PRI", "HGN" or "LCH") <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_id"];

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};

GVAR(weaponTab) = _id;
{
    [GVAR(ui) get ("wtab_" + _x), ["normal", "active"] select (_x == _id)] call FUNC(buttonState);
} forEach ["PRI", "HGN", "LCH"];

private _weapon = [_id] call FUNC(currentClass);
if (_weapon != "") then {
    CENTER selectWeapon ([primaryWeapon CENTER, secondaryWeapon CENTER, handgunWeapon CENTER] select (([_id] call FUNC(slot)) select S_CURR));
};
["weapon"] call FUNC(camPreset);
if (_id == "HGN") then {["hip"] call FUNC(camPreset)};

[GVAR(attachPoint)] call FUNC(selectAttachPoint);
