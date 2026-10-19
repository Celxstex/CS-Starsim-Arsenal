// Addon options: Options > Addon Options > [CS] Starsim Arsenal
private _general = ["[CS] Starsim Arsenal", "General"];
private _colours = ["[CS] Starsim Arsenal", "Colours"];

[
    QGVAR(enabled), "CHECKBOX",
    ["Use Starsim Arsenal", "Replace the ACE arsenal screen with the Starsim Arsenal. Turn off to get the standard ACE arsenal back."],
    _general,
    true,
    0
] call CBA_fnc_addSetting;

[
    QGVAR(unitName), "EDITBOX",
    ["Unit name", "Shown under the arsenal title."],
    _general,
    "60TH SOLAR DETACHMENT",
    1
] call CBA_fnc_addSetting;

// Colours apply the next time the arsenal is opened. Shades in between (hover,
// selection, disabled text and so on) are mixed from these.
{
    _x params ["_name", "_title", "_tooltip", "_default"];
    [
        _name, "COLOR",
        [_title, _tooltip + " Applies the next time the arsenal opens."],
        _colours,
        _default,
        0
    ] call CBA_fnc_addSetting;
} forEach [
    [QGVAR(accentColor), "Accent", "Highlights: selections, previews, active buttons and better stats.", DEF_ACCENT],
    [QGVAR(textColor), "Text", "Main text.", DEF_TEXT],
    [QGVAR(mutedColor), "Secondary text", "Labels, hints and other quieter text.", DEF_MUTED],
    [QGVAR(panelColor), "Panel background", "Item list and side panels. Lower the opacity to see more of the world behind.", DEF_PANEL],
    [QGVAR(barColor), "Bars", "Top bar, footer, slot rail and banners.", DEF_BAR],
    [QGVAR(cardColor), "Buttons and cards", "Buttons, chips and cards.", DEF_CARD],
    [QGVAR(lineColor), "Borders and lines", "Outlines and dividers.", DEF_LINE],
    [QGVAR(warningColor), "Warnings", "Worse stats, full containers and Heavy load.", DEF_WARNING]
];
