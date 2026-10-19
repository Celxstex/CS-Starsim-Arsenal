#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the slot record for a slot id.
 *
 * Arguments:
 * 0: Slot id, e.g. "PRI" <STRING>
 *
 * Return Value:
 * Slot record (see XEH_preInit) <ARRAY>
 *
 * Public: No
 */

params ["_id"];

private _index = GVAR(slots) findIf {(_x select S_ID) == _id};
GVAR(slots) select (_index max 0)
