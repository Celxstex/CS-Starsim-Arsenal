#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Tries an item (or a whole loadout) on the arsenal unit without committing it.
 * Only one preview exists at a time; a new preview replaces the old one.
 *
 * Arguments:
 * 0: Kind: "item", "attachment" or "loadout" <STRING>
 * 1: Slot id (for loadouts: "") <STRING>
 * 2: Class name, or the extended loadout for kind "loadout" <STRING|ARRAY>
 * 3: Sub-slot <ANY> (default: "")
 * 4: Label shown in the preview banner <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_kind", "_slotId", "_target", ["_sub", ""], ["_label", ""]];

if (GVAR(preview) isNotEqualTo []) then {
    [false] call FUNC(revert);
};

private _from = if (_kind == "loadout") then {""} else {[_slotId, _sub] call FUNC(currentClass)};

// Picking what's already worn just clears the preview
if (_kind != "loadout" && {_target isEqualTo _from}) exitWith {
    call FUNC(refresh);
};

GVAR(preview) = [
    _kind, _slotId, _target, _sub,
    CENTER call CBA_fnc_getLoadout,
    _from,
    loadAbs CENTER,
    _label,
    [ace_arsenal_currentFace, ace_arsenal_currentVoice, ace_arsenal_currentInsignia]
];

GVAR(previewLost) = if (_kind == "loadout") then {
    [_target] call FUNC(applyLoadout);
    0
} else {
    [_slotId, _target, _sub] call FUNC(equip)
};

call FUNC(refresh);
