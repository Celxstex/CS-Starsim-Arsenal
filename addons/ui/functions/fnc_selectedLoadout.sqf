#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Returns the selected loadout row.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * [source, name, author, extended loadout, role, unavailable items], or [] <ARRAY>
 *
 * Public: No
 */

if (GVAR(loadoutsSel) isEqualTo []) exitWith {[]};

private _index = GVAR(loadoutsRows) findIf {[_x select 0, _x select 1] isEqualTo GVAR(loadoutsSel)};
GVAR(loadoutsRows) param [_index, []]
