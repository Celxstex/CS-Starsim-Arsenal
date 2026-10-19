#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Updates the Loadout view's right panel: variants, equipped vs preview stats, and load.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(view) != "loadout") exitWith {};

private _right = GVAR(ui) get "rightPanel";
private _panelH = GVAR(ui) get "rightPanelH";

// Collapsed: the panel only shows when its edge tab is toggled, and never with full compare open
private _showRight = (!GVAR(statsCollapsed) || GVAR(statsPeek)) && !GVAR(compareOpen);
_right ctrlShow _showRight;
(GVAR(ui) get "statsTab") ctrlShow (GVAR(statsCollapsed) && !GVAR(compareOpen));
(GVAR(ui) get "compare") ctrlShow GVAR(compareOpen);

if (GVAR(compareOpen)) exitWith {
    call FUNC(renderCompare);
};
if (!_showRight) exitWith {};

private _slot = [GVAR(slot)] call FUNC(slot);
private _kind = _slot select S_KIND;

// ---- Variants
private _variantsH = call FUNC(updateVariants);

// ---- ITEMS: what's in each container replaces compare and stats
private _isCargo = _kind == "cargo";
(GVAR(ui) get "contents") ctrlShow _isCargo;
(GVAR(ui) get "cmpHead") ctrlShow !_isCargo;
(GVAR(ui) get "stats") ctrlShow !_isCargo;
if (_isCargo) exitWith {
    call FUNC(updateContents);
    call FUNC(updateLoad);
};

// ---- Equipped vs preview
private _sub = "";
private _previewClass = "";
private _hasPreview = false;
if (GVAR(preview) isNotEqualTo []) then {
    GVAR(preview) params ["_pKind", "_pSlot", "_pClass", "_pSub"];
    if (_pKind == "item" && {_pSlot == GVAR(slot)}) then {
        _hasPreview = true;
        _previewClass = _pClass;
        _sub = _pSub;
    };
};

// Linked items: compare within the sub-slot of the selected row
if (_kind == "linked" && {!_hasPreview}) then {
    private _lnb = GVAR(ui) get "itemList";
    private _row = lnbCurSelRow _lnb;
    _sub = if (_row >= 0) then {
        (parseSimpleArray ("[" + (_lnb lnbData [_row, 1]) + "]")) param [0, IDX_CURR_MAP]
    } else {
        IDX_CURR_MAP
    };
    if !(_sub isEqualType 0) then {_sub = IDX_CURR_MAP};
};

private _root = _slot select S_ROOT;
private _tab = _slot select S_STAT;
if (_kind == "linked") then {
    private _index = GVAR(linkedSlots) findIf {(_x select 2) isEqualTo _sub};
    _tab = (GVAR(linkedSlots) param [_index, []]) param [3, -1];
};

private _equipped = if (_kind in ["cargo", "identity"]) then {""} else {[GVAR(slot), _sub] call FUNC(currentClass)};
private _cfgA = if (_equipped == "" || {_root == ""}) then {configNull} else {configFile >> _root >> _equipped};
private _cfgB = if (_previewClass == "" || {_root == ""}) then {configNull} else {configFile >> _root >> _previewClass};

private _fnc_name = {
    params ["_cfg", "_fallback"];
    if (isNull _cfg) then {_fallback} else {getText (_cfg >> "displayName")}
};

(GVAR(ui) get "cmpCurName") ctrlSetText ([_cfgA, "Nothing"] call _fnc_name);
(GVAR(ui) get "cmpPrevName") ctrlSetText ([[_cfgB, "Nothing"] call _fnc_name, "Select an item"] select !_hasPreview);
(GVAR(ui) get "cmpPrevFrame") ctrlSetTextColor ([C_CHIP_LINE, C_ACCENT] select _hasPreview);

// Pin button: acts on the previewed item, or the worn one
private _pinTarget = [_equipped, _previewClass] select _hasPreview;
private _pinParts = GVAR(ui) get "btnPin";
private _pinned = _pinTarget in (GVAR(pins) getOrDefault [GVAR(slot), []]);
(_pinParts select 2) ctrlSetText (["PIN [P]", "UNPIN [P]"] select _pinned);
[_pinParts, if (_kind in ["linked", "identity"] || {_pinTarget == ""}) then {"disabled"} else {["normal", "active"] select _pinned}] call FUNC(buttonState);
(_pinParts select 3) ctrlSetTooltip "Pinned items stay at the top of this slot's list and appear in the full compare";

private _cmpHead = GVAR(ui) get "cmpHead";
_cmpHead ctrlSetPositionY PX_Y(_variantsH);
_cmpHead ctrlCommit 0;

private _loadH = GVAR(ui) get "loadH";
private _stats = GVAR(ui) get "stats";
private _statsY = _variantsH + 124;
_stats ctrlSetPosition [0, PX_Y(_statsY), PX_X(STATS_W), PX_Y((_panelH - _loadH - _statsY) max 0)];
_stats ctrlCommit 0;

private _rows = if (_kind in ["cargo", "identity"] || {_tab < 0}) then {
    []
} else {
    ["L", _tab, _cfgA, [_cfgB, configNull] select !_hasPreview] call FUNC(statRows)
};
[_stats, _rows, STATS_W, _hasPreview, ["No stats for this slot", "Nothing to compare"] select (_kind in ["cargo", "identity"])] call FUNC(renderStats);

call FUNC(updateLoad);
