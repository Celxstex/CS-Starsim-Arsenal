#include "..\script_component.hpp"
/*
 * Author: Celxste
 * Captures the current loadout and identity as an undo entry.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * [CBA extended loadout, [face, voice, insignia]] <ARRAY>
 *
 * Public: No
 */

[CENTER call CBA_fnc_getLoadout, [ace_arsenal_currentFace, ace_arsenal_currentVoice, ace_arsenal_currentInsignia]]
