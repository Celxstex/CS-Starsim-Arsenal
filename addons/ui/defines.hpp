// Shared by config and SQF.

// ---------------------------------------------------------------------------
// Layout
// The design is drawn at 1920x1080 with the Normal interface size. One design
// pixel is converted to screen units below. UI_SCALE follows the player's
// interface size (getResolution #5 is 0.7 at Normal) within sensible limits.
// ---------------------------------------------------------------------------
#define UI_SCALE ((((getResolution select 5) / 0.7) max 0.8) min 1.3)
#define UNIT_Y ((safeZoneH / 1080) * UI_SCALE)
#define UNIT_X (UNIT_Y * (pixelW / pixelH))

// Config expressions (evaluated when a control is created)
#define CFG_PX_Y(n) QUOTE((n) * UNIT_Y)
#define CFG_FONT(n) QUOTE((n) * 1.4 * UNIT_Y)

// Runtime conversions (GVAR(sx)/GVAR(sy) are cached on open)
#define PX_X(n) ((n) * GVAR(sx))
#define PX_Y(n) ((n) * GVAR(sy))
#define FONT(n) ((n) * 1.4 * GVAR(sy))
#define LINE_X (pixelW)
#define LINE_Y (pixelH)

// Design sizes (px)
#define TOP_H 64
#define FOOT_H 40
#define RAIL_W 96
#define LIST_W 432
#define STATS_W 480
#define COMPARE_W 864
#define LOADOUTS_LEFT_W 576
#define LOADOUTS_RIGHT_W 432
#define WEAPON_LEFT_W 528
#define WEAPON_RIGHT_W 432
#define MIN_GAP_PCT 0.4

// ---------------------------------------------------------------------------
// Colours
// Set in the addon options and worked out by FUNC(initColors) when the arsenal
// opens: the settings give the main colours, the in-between shades are mixed from them.
// ---------------------------------------------------------------------------
#define DEF_ACCENT  [0.310, 0.765, 0.969]
#define DEF_TEXT    [0.863, 0.902, 0.949]
#define DEF_MUTED   [0.561, 0.627, 0.706]
#define DEF_PANEL   [0.031, 0.051, 0.078, 0.90]
#define DEF_BAR     [0.020, 0.035, 0.055, 0.92]
#define DEF_CARD    [0.043, 0.067, 0.102]
#define DEF_LINE    [0.122, 0.173, 0.231]
#define DEF_WARNING [1, 0.624, 0.263]

#define UI_COLOR(name) (GVAR(colors) get name)
#define C_TEXT        UI_COLOR("text")
#define C_SOFT        UI_COLOR("soft")
#define C_MUTED       UI_COLOR("muted")
#define C_DIM         UI_COLOR("dim")
#define C_DISABLED    UI_COLOR("disabled")
#define C_WHITE       UI_COLOR("bright")
#define C_ON_ACCENT   UI_COLOR("onAccent")
#define C_WORSE       UI_COLOR("warning")
#define C_WARN_BG     UI_COLOR("warnBg")
#define C_WARN_TEXT   UI_COLOR("warnText")
#define C_BAR_BG      UI_COLOR("bar")
#define C_PANEL_BG    UI_COLOR("panel")
#define C_OVERLAY_BG  UI_COLOR("overlay")
#define C_VARIANT_BG  UI_COLOR("variantBg")
#define C_LINE        UI_COLOR("line")
#define C_CARD        UI_COLOR("card")
#define C_CARD_LINE   UI_COLOR("cardLine")
#define C_SEL2        UI_COLOR("sel")
#define C_INPUT       UI_COLOR("input")
#define C_CHIP_LINE   UI_COLOR("chipLine")
#define C_BTN_LINE    UI_COLOR("btnLine")
#define C_EQUIPPED    UI_COLOR("equipped")
#define C_TRACK       UI_COLOR("track")
#define C_ACCENT      UI_COLOR("accent")
#define C_DANGER      [1, 0.659, 0.659, 1]
#define C_DANGER_LINE [0.416, 0.188, 0.188, 1]
#define C_CLEAR       [0, 0, 0, 0]

// Config defaults for controls (runtime colours are applied over these)
#define CFG_C_TEXT    {0.863, 0.902, 0.949, 1}
#define CFG_C_MUTED   {0.561, 0.627, 0.706, 1}
#define CFG_C_CARD    {0.043, 0.067, 0.102, 1}
#define CFG_C_SEL     {1, 1, 1, 0.08}
#define CFG_C_INPUT   {0.027, 0.047, 0.075, 1}
#define CFG_C_LINE    {0.165, 0.231, 0.314, 1}
#define CFG_C_ACCENT  {0.310, 0.765, 0.969, 1}
#define CFG_C_CLEAR   {0, 0, 0, 0}

// ---------------------------------------------------------------------------
// Fonts
// ---------------------------------------------------------------------------
#define F_TITLE "PuristaSemibold"
#define F_HEAVY "PuristaBold"
#define F_BODY  "RobotoCondensed"
#define F_BODYB "RobotoCondensedBold"
#define F_MONO  "EtelkaMonospacePro"

// ---------------------------------------------------------------------------
// ACE arsenal indices (mirrors ace\addons\arsenal\defines.hpp)
// ---------------------------------------------------------------------------
#define IDD_ACE_ARSENAL 1127001

#define IDX_VIRT_WEAPONS 0
#define IDX_VIRT_PRIMARY_WEAPONS 0
#define IDX_VIRT_SECONDARY_WEAPONS 1
#define IDX_VIRT_HANDGUN_WEAPONS 2
#define IDX_VIRT_ATTACHMENTS 1
#define IDX_VIRT_OPTICS_ATTACHMENTS 0
#define IDX_VIRT_FLASHLIGHT_ATTACHMENTS 1
#define IDX_VIRT_MUZZLE_ATTACHMENTS 2
#define IDX_VIRT_BIPOD_ATTACHMENTS 3
#define IDX_VIRT_ITEMS_ALL 2
#define IDX_VIRT_HEADGEAR 3
#define IDX_VIRT_UNIFORM 4
#define IDX_VIRT_VEST 5
#define IDX_VIRT_BACKPACK 6
#define IDX_VIRT_GOGGLES 7
#define IDX_VIRT_NVG 8
#define IDX_VIRT_BINO 9
#define IDX_VIRT_MAP 10
#define IDX_VIRT_COMPASS 11
#define IDX_VIRT_RADIO 12
#define IDX_VIRT_WATCH 13
#define IDX_VIRT_COMMS 14
#define IDX_VIRT_GRENADES 15
#define IDX_VIRT_EXPLOSIVES 16
#define IDX_VIRT_MISC_ITEMS 17
#define IDX_VIRT_MISC_GOGGLES 18
#define IDX_VIRT_UNIQUE_MISC_ITEMS 19
#define IDX_VIRT_UNIQUE_VIRT_ITEMS_ALL 20
#define IDX_VIRT_UNIQUE_GRENADES 21
#define IDX_VIRT_UNIQUE_EXPLOSIVES 22
#define IDX_VIRT_UNIQUE_ATTACHMENTS 23
#define IDX_VIRT_UNIQUE_BACKPACKS 24
#define IDX_VIRT_UNIQUE_GOGGLES 25

// Everything the ITEMS slot can put in a container
#define CARGO_VIRT [IDX_VIRT_ITEMS_ALL, IDX_VIRT_GRENADES, IDX_VIRT_EXPLOSIVES, IDX_VIRT_MISC_ITEMS, IDX_VIRT_UNIQUE_MISC_ITEMS, IDX_VIRT_UNIQUE_VIRT_ITEMS_ALL, IDX_VIRT_UNIQUE_GRENADES, IDX_VIRT_UNIQUE_EXPLOSIVES, IDX_VIRT_MISC_GOGGLES]

#define IDX_CURR_PRIMARY_WEAPON 0
#define IDX_CURR_SECONDARY_WEAPON 1
#define IDX_CURR_HANDGUN_WEAPON 2
#define IDX_CURR_HEADGEAR 3
#define IDX_CURR_UNIFORM 4
#define IDX_CURR_VEST 5
#define IDX_CURR_BACKPACK 6
#define IDX_CURR_GOGGLES 7
#define IDX_CURR_NVG 8
#define IDX_CURR_BINO 9
#define IDX_CURR_MAP 10
#define IDX_CURR_COMPASS 11
#define IDX_CURR_RADIO 12
#define IDX_CURR_WATCH 13
#define IDX_CURR_COMMS 14
#define IDX_CURR_PRIMARY_WEAPON_ITEMS 18
#define IDX_CURR_SECONDARY_WEAPON_ITEMS 19
#define IDX_CURR_HANDGUN_WEAPON_ITEMS 20

// ACE stat tabs (left panel)
#define STAT_PRIMARY 0
#define STAT_HANDGUN 1
#define STAT_LAUNCHER 2
#define STAT_UNIFORM 3
#define STAT_VEST 4
#define STAT_BACKPACK 5
#define STAT_HEADGEAR 6
#define STAT_GOGGLES 7
#define STAT_NVG 8
#define STAT_BINO 9
#define STAT_MAP 10
#define STAT_GPS 11
#define STAT_RADIO 12
#define STAT_COMPASS 13
#define STAT_WATCH 14

// ACE stat tabs (right panel)
#define STAT_R_OPTIC 0
#define STAT_R_SIDE 1
#define STAT_R_MUZZLE 2
#define STAT_R_BIPOD 3
#define STAT_R_MAG 4

// Arma mass units (0.1 lb) to kg
#define MASS_TO_KG 0.045359

// Carry load tiers (fraction of the soldier's max load)
#define LOAD_MODERATE 0.4
#define LOAD_HEAVY 0.7

// Height of the ITEMS slot's bar under the list (amount box + buttons)
#define CARGO_BAR_H 96

// Keys
#define DIK_ESCAPE 0x01
#define DIK_BACKSPACE 0x0E
#define DIK_RETURN 0x1C
#define DIK_NUMPADENTER 0x9C
#define DIK_C 0x2E
#define DIK_P 0x19
#define DIK_S 0x1F
#define DIK_Z 0x2C
#define DIK_F 0x21
#define DIK_LEFT 0xCB
#define DIK_RIGHT 0xCD
#define DIK_1 0x02
#define DIK_5 0x06

// Center unit shorthand
#define CENTER ace_arsenal_center

// Slot record indices (see XEH_preInit)
#define S_ID 0
#define S_SHORT 1
#define S_LABEL 2
#define S_KIND 3
#define S_ROOT 4
#define S_VIRT 5
#define S_CURR 6
#define S_STAT 7
#define S_CAM 8

// The open display lives in uiNamespace (displays can't be serialised in missionNamespace)
#define UI_DISPLAY (uiNamespace getVariable [QGVAR(display), displayNull])
