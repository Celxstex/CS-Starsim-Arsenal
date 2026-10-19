#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Puts an item on the arsenal unit (or removes it with "").
 *
 * Arguments:
 * 0: Slot id <STRING>
 * 1: Class name, "" to remove <STRING>
 * 2: Sub-slot (see FUNC(currentClass)) <ANY> (default: "")
 *
 * Return Value:
 * Number of inventory items that no longer fit and were removed <NUMBER>
 *
 * Public: No
 */

params ["_slotId", "_item", ["_sub", ""]];

private _unit = CENTER;
private _slot = [_slotId] call FUNC(slot);
private _lost = 0;

switch (_slot select S_KIND) do {
    case "weapon": {
        if (_sub isEqualType 0) then {
            [_slotId, _sub, _item] call FUNC(equipAttachment);
        } else {
            [_slotId, _item] call FUNC(equipWeapon);
        };
    };
    case "headgear": {
        if (_item == "") then {removeHeadgear _unit} else {_unit addHeadgear _item};
    };
    case "goggles": {
        if (_item == "") then {removeGoggles _unit} else {_unit addGoggles _item};
    };
    case "nvg": {
        if (hmd _unit != "") then {_unit unlinkItem (hmd _unit)};
        if (_item != "") then {_unit linkItem _item};
    };
    case "bino": {
        if (binocular _unit != "") then {_unit removeWeapon (binocular _unit)};
        if (_item != "") then {_unit addWeapon _item};
    };
    case "uniform": {_lost = [0, _item] call FUNC(equipContainer)};
    case "vest": {_lost = [1, _item] call FUNC(equipContainer)};
    case "backpack": {_lost = [2, _item] call FUNC(equipContainer)};
    case "linked": {
        private _current = ace_arsenal_currentItems param [_sub, ""];
        if (_current != "") then {_unit unlinkItem _current};
        if (_item != "") then {_unit linkItem _item};
    };
    case "identity": {
        switch (_sub) do {
            case "face": {
                private _face = [_item, "Default"] select (_item == "");
                _unit setFace _face;
                ace_arsenal_currentFace = _face;
            };
            case "voice": {
                _unit setSpeaker _item;
                ace_arsenal_currentVoice = _item;
            };
            case "insignia": {
                [_unit, ""] call BIS_fnc_setUnitInsignia;
                [_unit, _item] call BIS_fnc_setUnitInsignia;
                ace_arsenal_currentInsignia = _item;
            };
        };
    };
};

call ace_arsenal_fnc_updateCurrentItemsList;

_lost
