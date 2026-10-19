#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the virtual item hashmaps that feed a slot.
 *
 * Arguments:
 * 0: Slot record <ARRAY>
 *
 * Return Value:
 * Hashmaps whose keys are class names <ARRAY>
 *
 * Public: No
 */

params ["_slot"];

(_slot select S_VIRT) apply {
    if (_x isEqualType []) then {
        _x params ["_index", "_sub"];
        (GVAR(allItems) getOrDefault [_index, createHashMap]) getOrDefault [_sub, createHashMap]
    } else {
        GVAR(allItems) getOrDefault [_x, createHashMap]
    }
}
