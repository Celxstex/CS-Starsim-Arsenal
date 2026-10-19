#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Highlights the selected slot and marks slots that have something equipped.
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

{
    private _id = _x select S_ID;
    (GVAR(ui) get ("slot_" + _id)) params ["_parts", "_code", "_short", "_dot"];
    private _active = _id == GVAR(slot);
    [_parts, ["normal", "active"] select _active] call FUNC(buttonState);
    _code ctrlSetTextColor ([C_MUTED, C_ACCENT] select _active);
    _short ctrlSetTextColor ([C_SOFT, C_WHITE] select _active);

    private _has = switch (_x select S_KIND) do {
        case "linked": {(assignedItems _unit - [hmd _unit, binocular _unit]) isNotEqualTo []};
        case "cargo": {(uniformItems _unit + vestItems _unit + backpackItems _unit) isNotEqualTo []};
        case "identity": {true};
        default {([_id] call FUNC(currentClass)) != ""};
    };
    _dot ctrlSetBackgroundColor ([C_CHIP_LINE, C_ACCENT] select _has);
} forEach GVAR(slots);
