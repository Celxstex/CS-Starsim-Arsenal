#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Deletes every control inside a controls group.
 *
 * Arguments:
 * 0: Controls group <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_group"];

{
    ctrlDelete _x;
} forEach ((allControls (ctrlParent _group)) select {ctrlParentControlsGroup _x isEqualTo _group});
