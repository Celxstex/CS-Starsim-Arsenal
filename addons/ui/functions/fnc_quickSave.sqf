#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Saves over the current loadout if it's one of yours, otherwise asks for a name.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _data = profileNamespace getVariable ["ace_arsenal_saved_loadouts", []];

if (GVAR(loadoutName) != "" && {_data findIf {(_x select 0) == GVAR(loadoutName)} != -1}) then {
    [GVAR(loadoutName)] call FUNC(saveLoadout);
} else {
    ["save"] call FUNC(showPopup);
};
