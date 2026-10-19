#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Shows the compatible items for an attachment point of the selected weapon.
 *
 * Arguments:
 * 0: Point: 0 optic, 1 muzzle, 2 side rail, 3 underbarrel, 4 magazine <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_point"];

if (GVAR(preview) isNotEqualTo [] && {GVAR(attachPoint) != _point}) then {
    [false] call FUNC(revert);
};
GVAR(attachPoint) = _point;

private _lnb = GVAR(ui) get "wList";
private _weapon = [GVAR(weaponTab)] call FUNC(currentClass);
private _label = ["OPTIC", "MUZZLE", "SIDE RAIL", "UNDERBARREL", "MAGAZINE"] select _point;
(GVAR(ui) get "wCompatTitle") ctrlSetText format ["COMPATIBLE · %1", _label];

GVAR(fillingList) = true;
lnbClear _lnb;
_lnb lnbSetColumnsPos [0, 0.17, 0.68, 0.84];

if (_weapon != "") then {
    private _items = [_weapon, _point] call FUNC(compatibleItems);
    private _root = ["CfgWeapons", "CfgMagazines"] select (_point == 4);
    private _rows = _items apply {
        private _cfg = configFile >> _root >> _x;
        [getText (_cfg >> "displayName"), _x, getText (_cfg >> "picture"), [_cfg] call FUNC(modTag)]
    };
    _rows sort true;

    private _none = _lnb lnbAddRow ["", "<Nothing>", "", ""];
    _lnb lnbSetData [[_none, 0], ""];
    {
        _x params ["_name", "_class", "_picture", "_tag"];
        private _row = _lnb lnbAddRow ["", _name, _tag, ""];
        _lnb lnbSetPicture [[_row, 0], _picture];
        _lnb lnbSetData [[_row, 0], _class];
        _lnb lnbSetColor [[_row, 2], C_MUTED];
        _lnb lnbSetTooltip [[_row, 1], format ["%1\n%2", _name, _class]];
    } forEach _rows;
} else {
    private _row = _lnb lnbAddRow ["", "No weapon in this slot. Pick one in the Loadout view.", "", ""];
    _lnb lnbSetData [[_row, 0], "#"];
    _lnb lnbSetColor [[_row, 1], C_MUTED];
};
GVAR(fillingList) = false;

call FUNC(updateWeaponView);
