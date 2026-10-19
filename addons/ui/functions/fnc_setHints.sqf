#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Sets the keyboard hints in the footer.
 *
 * Arguments:
 * 0: Hints [[key, label], ...] <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_hints"];

private _text = (_hints apply {
    format ["<t font='%1' color='%4'>[%2]</t> <t font='%1' color='%5'>%3</t>", F_MONO, _x select 0, _x select 1, GVAR(colorsHex) get "text", GVAR(colorsHex) get "muted"]
}) joinString "     ";

(GVAR(ui) get "hints") ctrlSetStructuredText parseText format ["<t size='0.9'>%1</t>", _text];
