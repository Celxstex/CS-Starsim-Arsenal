#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Shows the preview banner (or the hint when nothing is previewed) and the camera text.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _previewing = GVAR(preview) isNotEqualTo [] && {(GVAR(preview) select 0) == "item"};

(GVAR(ui) get "banner") ctrlShow _previewing;
(GVAR(ui) get "bannerHint") ctrlShow !_previewing;

if (_previewing) then {
    GVAR(preview) params ["", "_slotId", "_class", "", "", "_from", "", "_label"];
    private _sameModel = _from != "" && {_class != ""} && {
        private _a = (GVAR(itemModel) getOrDefault [_from, []]) param [1, ""];
        _a != "" && {_a == ((GVAR(itemModel) getOrDefault [_class, []]) param [1, ""])}
    };
    (GVAR(ui) get "bannerLabel") ctrlSetText (["PREVIEWING · NOT EQUIPPED", "CHANGING VARIANT · NOT EQUIPPED"] select _sameModel);
    (GVAR(ui) get "bannerName") ctrlSetText _label;
};

private _slot = [GVAR(slot)] call FUNC(slot);
(GVAR(ui) get "camText") ctrlSetText format ["CAM FOCUS · %1", toUpper (_slot select S_CAM)];
