#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns a slot's pinned items that this arsenal offers. Pins are kept per slot for
 * the whole session (and between sessions), so they can name items another arsenal
 * doesn't have.
 *
 * Arguments:
 * 0: Slot id <STRING>
 *
 * Return Value:
 * Class names <ARRAY>
 *
 * Public: No
 */

params ["_slotId"];

private _pins = GVAR(pins) getOrDefault [_slotId, []];
if (_pins isEqualTo []) exitWith {[]};

private _slot = [_slotId] call FUNC(slot);
private _maps = if ((_slot select S_KIND) == "cargo") then {
    CARGO_VIRT apply {GVAR(allItems) getOrDefault [_x, createHashMap]}
} else {
    [_slot] call FUNC(slotItemMaps)
};

// Variants hidden from the list but reachable through options are in the model index
_pins select {
    private _class = _x;
    _class in GVAR(itemModel) || {_maps findIf {_class in _x} != -1}
}
