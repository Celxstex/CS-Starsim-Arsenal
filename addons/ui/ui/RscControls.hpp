// Base controls for the [CS] Starsim Arsenal UI. Everything is created at runtime with ctrlCreate.
class ctrlStatic;
class ctrlStaticPictureKeepAspect;
class ctrlButton;
class ctrlEdit;
class ctrlListNBox;
class ctrlControlsGroupNoScrollbars;
class ctrlControlsGroupNoHScrollbars;
class ctrlCombo;
class ctrlCheckbox;
class ctrlStructuredText;

class GVAR(text): ctrlStatic {
    font = F_BODY;
    sizeEx = CFG_FONT(15);
    shadow = 0;
    colorText[] = CFG_C_TEXT;
    colorBackground[] = CFG_C_CLEAR;
};
class GVAR(textRight): GVAR(text) {
    style = 1;
};
class GVAR(textCenter): GVAR(text) {
    style = 2;
};
class GVAR(textMulti): GVAR(text) {
    style = 16;
    lineSpacing = 1;
};
class GVAR(rect): GVAR(text) {};

// Outline. Colour is set with ctrlSetTextColor.
class GVAR(frame): GVAR(text) {
    style = 64;
    colorText[] = CFG_C_LINE;
};

class GVAR(picture): ctrlStaticPictureKeepAspect {
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = CFG_C_CLEAR;
};

// Invisible clickable area laid over a rect + label. Only shows a faint hover tint.
class GVAR(hit): ctrlButton {
    text = "";
    shadow = 0;
    colorBackground[] = CFG_C_CLEAR;
    colorBackgroundDisabled[] = CFG_C_CLEAR;
    colorBackgroundActive[] = {1, 1, 1, 0.05};
    colorFocused[] = CFG_C_CLEAR;
    colorText[] = CFG_C_CLEAR;
    colorDisabled[] = CFG_C_CLEAR;
    colorBorder[] = CFG_C_CLEAR;
    colorShadow[] = CFG_C_CLEAR;
    offsetPressedX = 0;
    offsetPressedY = 0;
    periodFocus = 0;
    periodOver = 0;
};

class GVAR(edit): ctrlEdit {
    style = 512; // ST_NO_RECT
    font = F_BODY;
    sizeEx = CFG_FONT(15);
    shadow = 0;
    colorBackground[] = CFG_C_CLEAR;
    colorText[] = CFG_C_TEXT;
    colorSelection[] = CFG_C_ACCENT;
};

class GVAR(list): ctrlListNBox {
    font = F_BODY;
    sizeEx = CFG_FONT(15);
    rowHeight = CFG_PX_Y(44);
    shadow = 0;
    disableOverflow = 1;
    colorText[] = CFG_C_TEXT;
    colorBackground[] = CFG_C_CLEAR;
    colorSelectBackground[] = CFG_C_SEL;
    colorSelectBackground2[] = CFG_C_SEL;
    colorSelect[] = {1, 1, 1, 1};
    colorSelect2[] = {1, 1, 1, 1};
    colorShadow[] = CFG_C_CLEAR;
};
class GVAR(listCompact): GVAR(list) {
    sizeEx = CFG_FONT(14);
    rowHeight = CFG_PX_Y(34);
};

class GVAR(group): ctrlControlsGroupNoScrollbars {};
class GVAR(groupScroll): ctrlControlsGroupNoHScrollbars {};

class GVAR(combo): ctrlCombo {
    font = F_BODY;
    sizeEx = CFG_FONT(15);
    shadow = 0;
    colorBackground[] = CFG_C_INPUT;
    colorSelectBackground[] = CFG_C_SEL;
    colorText[] = CFG_C_TEXT;
};

class GVAR(checkbox): ctrlCheckbox {};

class GVAR(structured): ctrlStructuredText {
    size = CFG_FONT(14);
    shadow = 0;
    colorBackground[] = CFG_C_CLEAR;
    class Attributes {
        font = F_BODY;
        color = "#DCE6F2";
        align = "left";
        shadow = 0;
    };
};
