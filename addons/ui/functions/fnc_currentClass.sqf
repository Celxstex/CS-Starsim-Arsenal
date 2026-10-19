#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the class currently worn in a slot. While previewing in that slot,
 * returns what was worn before the preview.
 *
 * Arguments:
 * 0: Slot id <STRING>
 * 1: Sub-slot: ACE current-item index for LNK, "face"/"voice"/"insignia" for IDN,
 *    attachment index for weapon attachments <ANY> (default: "")
 *
 * Return Value:
 * Class name, "" when empty <STRING>
 *
 * Public: No
 */

params ["_slotId", ["_sub", ""]];

private _previewFrom = nil;
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_kind", "_pSlot", "", "_pSub", "", "_from"];
    if (_kind in ["item", "attachment"] && {_pSlot == _slotId} && {_pSub isEqualTo _sub}) then {
        _previewFrom = _from;
    };
};
if (!isNil "_previewFrom") exitWith {_previewFrom};

private _slot = [_slotId] call FUNC(slot);
private _kind = _slot select S_KIND;

switch (true) do {
    case (_sub isEqualType 0 && {_kind == "weapon"}): {
        // Attachment: items array is [muzzle, side, optic, bipod, magazine, magazine 2]
        (ace_arsenal_currentItems select (IDX_CURR_PRIMARY_WEAPON_ITEMS + (_slot select S_CURR))) param [_sub, ""]
    };
    case (_kind == "linked"): {
        ace_arsenal_currentItems param [_sub, ""]
    };
    case (_kind == "identity"): {
        switch (_sub) do {
            case "face": {ace_arsenal_currentFace};
            case "voice": {ace_arsenal_currentVoice};
            case "insignia": {ace_arsenal_currentInsignia};
            default {""};
        }
    };
    case ((_slot select S_CURR) >= 0): {
        ace_arsenal_currentItems select (_slot select S_CURR)
    };
    default {""};
}
