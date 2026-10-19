#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Draws what's carried in the uniform, vest and backpack on the right panel for the
 * ITEMS slot. Each item can be added, removed or moved to another container, and
 * clicking a container makes it the one the item list adds to.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _group = GVAR(ui) get "contents";
[_group] call FUNC(clearGroup);

private _unit = CENTER;
private _w = STATS_W;
private _inner = _w - 44;
private _right = 22 + _inner;

private _containers = [
    [uniform _unit, uniformItems _unit, loadUniform _unit, "CfgWeapons"],
    [vest _unit, vestItems _unit, loadVest _unit, "CfgWeapons"],
    [backpack _unit, backpackItems _unit, loadBackpack _unit, "CfgVehicles"]
];
private _names = ["UNIFORM", "VEST", "BACKPACK"];
private _short = ["UNIF", "VEST", "PACK"];

[_group, "text", [22, 14, 200, 28], "CONTENTS", C_WHITE, F_TITLE, 19] call FUNC(ctrl);
private _total = 0;
{
    _total = _total + count (_x select 1);
} forEach _containers;
[_group, "textRight", [200, 18, _w - 222, 22], format ["%1 ITEMS CARRIED", _total], C_MUTED, F_MONO, 10] call FUNC(ctrl);

private _cards = [];
private _y = 54;
{
    _x params ["_container", "_items", "_load", "_root"];
    private _index = _forEachIndex;
    private _isTarget = GVAR(cargoTarget) == _index;
    private _worn = _container != "";

    // ---- Container card. Clicking it makes it the one the list adds to; items can be dropped on it.
    _cards pushBack [_index, _y, _y + 48];
    [_group, "rect", [22, _y, _inner, 48], "", [], "", -1, [C_CARD, C_SEL2] select _isTarget] call FUNC(ctrl);
    [_group, "frame", [22, _y, _inner, 48], "", [C_CHIP_LINE, C_ACCENT] select _isTarget] call FUNC(ctrl);
    [_group, "text", [32, _y + 5, 240, 16], (_names select _index) + (["", " · ADDING HERE"] select _isTarget), [C_MUTED, C_ACCENT] select _isTarget, F_MONO, 9] call FUNC(ctrl);
    [_group, "text", [32, _y + 21, _inner - 120, 24], [getText (configFile >> _root >> _container >> "displayName"), "Not worn"] select !_worn, [C_DIM, C_TEXT] select _worn, F_BODY, 14] call FUNC(ctrl);

    if (_worn) then {
        private _capacity = getContainerMaxLoad _container;
        [_group, "textRight", [_right - 160, _y + 5, 150, 16], format ["%1 / %2", round (_load * _capacity), round _capacity], C_SOFT, F_MONO, 9] call FUNC(ctrl);
        [_group, "rect", [22, _y + 45, _inner * ((_load max 0) min 1), 3], "", [], "", -1, [C_ACCENT, C_WORSE] select (_load > 0.9)] call FUNC(ctrl);
        if (_items isNotEqualTo []) then {
            private _empty = [_group, [_right - 70, _y + 22, 62, 22], "EMPTY", compile format ["[%1] call %2", _index, QFUNC(cargoEmpty)], "ghost", 10, F_MONO] call FUNC(button);
            (_empty select 3) ctrlSetTooltip format ["Remove everything from the %1", toLowerANSI (_names select _index)];
        };
        private _hit = [_group, "hit", [22, _y, _inner - 80, 48]] call FUNC(ctrl);
        _hit ctrlAddEventHandler ["ButtonClick", compile format ["%1 = %2; call %3; call %4", QGVAR(cargoTarget), _index, QFUNC(fillCargoList), QFUNC(updateSidePanel)]];
        _hit ctrlSetTooltip format ["Add items from the list to the %1", toLowerANSI (_names select _index)];
    };
    _y = _y + 54;

    if (_worn) then {
        // Count each class, in the order first carried
        private _counts = createHashMap;
        private _order = [];
        {
            if !(_x in _counts) then {_order pushBack _x};
            _counts set [_x, (_counts getOrDefault [_x, 0]) + 1];
        } forEach _items;

        if (_order isEqualTo []) then {
            [_group, "text", [32, _y, _inner - 20, 24], "Empty", C_DIM, F_BODY, 13] call FUNC(ctrl);
            _y = _y + 30;
        };

        private _rows = _order apply {[getText (([_x] call FUNC(itemConfig)) >> "displayName"), _x]};
        _rows sort true;

        {
            _x params ["_name", "_class"];
            private _cfg = [_class] call FUNC(itemConfig);
            private _count = _counts get _class;
            // Weapons and backpacks stored inside can only be cleared with EMPTY
            private _editable = !(
                (isClass (configFile >> "CfgWeapons" >> _class) && {getNumber (configFile >> "CfgWeapons" >> _class >> "type") in [1, 2, 4]})
                || {isClass (configFile >> "CfgVehicles" >> _class)}
            );

            [_group, "picture", [26, _y + 3, 40, 28], getText (_cfg >> "picture")] call FUNC(ctrl);
            private _label = [_group, "text", [72, _y, _right - 242 - 72, 34], [_name, _class] select (_name == ""), C_TEXT, F_BODY, 13] call FUNC(ctrl);
            private _tooltip = format ["%1\n%2\n%3 kg each", _name, _class, (([_cfg] call FUNC(itemMass)) * MASS_TO_KG) toFixed 2];
            _label ctrlSetTooltip _tooltip;

            // Grab area over the picture and name: drag onto another container to move it all,
            // or click to pick it in the list so the amount controls apply to it
            if (_editable) then {
                private _grab = [_group, "hit", [22, _y, _right - 242 - 22, 34]] call FUNC(ctrl);
                _grab setVariable [QGVAR(drag), [_class, _index]];
                _grab ctrlSetTooltip (_tooltip + "\nClick to select · drag onto another container to move it");
                _grab ctrlAddEventHandler ["MouseButtonDown", {
                    params ["_ctrl", "_button"];
                    if (_button == 0) then {
                        (_ctrl getVariable QGVAR(drag)) call FUNC(dragStart);
                    };
                }];
                _grab ctrlAddEventHandler ["MouseButtonUp", {
                    if ((_this select 1) == 0) then {call FUNC(dragEnd)};
                }];
            };
            [_group, "textRight", [_right - 238, _y, 34, 34], format ["x%1", _count], C_ACCENT, F_MONO, 11] call FUNC(ctrl);

            if (_editable) then {
                [_group, [_right - 200, _y + 4, 34, 26], "ALL", compile format ["[-1000, %1, %2] call %3", str _class, _index, QFUNC(cargoChange)], "danger", 9, F_MONO] call FUNC(button) select 3 ctrlSetTooltip "Remove all";
                [_group, [_right - 162, _y + 4, 28, 26], "-", compile format ["[-1, %1, %2] call %3", str _class, _index, QFUNC(cargoChange)], "default", 16] call FUNC(button) select 3 ctrlSetTooltip "Remove one";
                [_group, [_right - 130, _y + 4, 28, 26], "+", compile format ["[1, %1, %2] call %3", str _class, _index, QFUNC(cargoChange)], "accent", 16] call FUNC(button) select 3 ctrlSetTooltip "Add one";
                private _xMove = _right - 96;
                {
                    if (_forEachIndex != _index) then {
                        private _parts = [_group, [_xMove, _y + 4, 46, 26], _short select _forEachIndex, compile format ["[%1, %2, %3] call %4", str _class, _index, _forEachIndex, QFUNC(cargoMove)], "chip", 9, F_MONO] call FUNC(button);
                        (_parts select 3) ctrlSetTooltip format ["Move all to the %1", toLowerANSI (_names select _forEachIndex)];
                        if ((_x select 0) == "") then {
                            [_parts, "disabled"] call FUNC(buttonState);
                        };
                        _xMove = _xMove + 50;
                    };
                } forEach _containers;
            } else {
                [_group, "textRight", [_right - 162, _y, 162, 34], "STORED", C_DIM, F_MONO, 9] call FUNC(ctrl);
            };

            [_group, "rect", [72, _y + 34, _inner - 50, 1], "", [], "", -1, C_CARD_LINE] call FUNC(ctrl);
            _y = _y + 36;
        } forEach _rows;
    };

    _y = _y + 10;
} forEach _containers;

// For working out where a dragged item is dropped (FUNC(dragTarget))
GVAR(contentsCards) = _cards;
GVAR(contentsH) = _y;
