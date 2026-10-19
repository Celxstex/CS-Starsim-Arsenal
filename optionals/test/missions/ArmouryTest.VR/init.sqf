// Automated walk-through of the [CS] Starsim Arsenal UI: opens a full arsenal, visits each screen,
// takes screenshots and writes ARMOURY_TEST markers to the RPT log.
[] spawn {
    waitUntil {time > 1};
    sleep 3;

    private _fnc_shot = {
        params ["_name"];
        sleep 2.5;
        diag_log format ["ARMOURY_TEST: shot %1", _name];
        screenshot format ["armoury_%1.png", _name];
        sleep 4;
    };
    private _fnc_selectRow = {
        params ["_lnb", "_condition"];
        for "_row" from 0 to ((lnbSize _lnb) select 0) - 1 do {
            if ([_lnb, _row] call _condition) exitWith {
                _lnb lnbSetCurSelRow _row;
                diag_log format ["ARMOURY_TEST: selected row %1 (%2)", _row, _lnb lnbText [_row, 1]];
            };
        };
    };

    diag_log "ARMOURY_TEST: opening arsenal";
    [player, player, true] call ace_arsenal_fnc_openBox;
    waitUntil {!isNull findDisplay 1127001};
    diag_log format ["ARMOURY_TEST: display open, armoury active %1", (findDisplay 1127001) getVariable ["arsenal_ui_active", false]];

    ["01_loadout"] call _fnc_shot;

    ["HLM"] call arsenal_ui_fnc_selectSlot;
    sleep 1;
    [arsenal_ui_ui get "itemList", {params ["_l", "_r"]; _r > 3 && {(_l lnbData [_r, 0]) != ""}}] call _fnc_selectRow;
    ["02_preview_helmet"] call _fnc_shot;

    ["UNF"] call arsenal_ui_fnc_selectSlot;
    sleep 1;
    [arsenal_ui_ui get "itemList", {params ["_l", "_r"]; ((_l lnbText [_r, 2]) find "VAR") != -1}] call _fnc_selectRow;
    ["03_variants"] call _fnc_shot;

    call arsenal_ui_fnc_toggleCompare;
    ["04_compare"] call _fnc_shot;
    call arsenal_ui_fnc_toggleCompare;

    ["CRG"] call arsenal_ui_fnc_selectSlot;
    ["05_items"] call _fnc_shot;

    ["weapon"] call arsenal_ui_fnc_setView;
    ["06_weapon"] call _fnc_shot;

    ["loadouts"] call arsenal_ui_fnc_setView;
    ["07_loadouts"] call _fnc_shot;

    diag_log "ARMOURY_TEST: done";
};
