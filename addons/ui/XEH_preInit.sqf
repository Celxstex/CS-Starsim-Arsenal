#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// [id, short label, title, kind, config root, virtual item indices, current item index, ACE stat tab, camera preset]
GVAR(slots) = [
    ["PRI", "PRIMARY",  "PRIMARY WEAPON",          "weapon",   "CfgWeapons",  [[IDX_VIRT_WEAPONS, IDX_VIRT_PRIMARY_WEAPONS]],   IDX_CURR_PRIMARY_WEAPON,   STAT_PRIMARY,  "weapon"],
    ["HGN", "SIDEARM",  "HANDGUN",                 "weapon",   "CfgWeapons",  [[IDX_VIRT_WEAPONS, IDX_VIRT_HANDGUN_WEAPONS]],   IDX_CURR_HANDGUN_WEAPON,   STAT_HANDGUN,  "hip"],
    ["LCH", "LAUNCHER", "LAUNCHER",                "weapon",   "CfgWeapons",  [[IDX_VIRT_WEAPONS, IDX_VIRT_SECONDARY_WEAPONS]], IDX_CURR_SECONDARY_WEAPON, STAT_LAUNCHER, "back"],
    ["HLM", "HEADGEAR", "HEADGEAR",                "headgear", "CfgWeapons",  [IDX_VIRT_HEADGEAR],                              IDX_CURR_HEADGEAR,         STAT_HEADGEAR, "head"],
    ["FCE", "FACEWEAR", "FACEWEAR",                "goggles",  "CfgGlasses",  [IDX_VIRT_GOGGLES, IDX_VIRT_UNIQUE_GOGGLES],      IDX_CURR_GOGGLES,          STAT_GOGGLES,  "head"],
    ["NVG", "NVG",      "NIGHT VISION",            "nvg",      "CfgWeapons",  [IDX_VIRT_NVG],                                   IDX_CURR_NVG,              STAT_NVG,      "head"],
    ["UNF", "UNIFORM",  "UNIFORM",                 "uniform",  "CfgWeapons",  [IDX_VIRT_UNIFORM],                               IDX_CURR_UNIFORM,          STAT_UNIFORM,  "full"],
    ["VST", "VEST",     "VEST",                    "vest",     "CfgWeapons",  [IDX_VIRT_VEST],                                  IDX_CURR_VEST,             STAT_VEST,     "torso"],
    ["BKP", "BACKPACK", "BACKPACK",                "backpack", "CfgVehicles", [IDX_VIRT_BACKPACK, IDX_VIRT_UNIQUE_BACKPACKS],   IDX_CURR_BACKPACK,         STAT_BACKPACK, "back"],
    ["CRG", "PACKING",  "PACK UNIFORM · VEST · BACKPACK", "cargo", "",            [],                                               -1,                        -1,            "torso"],
    ["BIN", "OPTICS",   "BINOCULARS",              "bino",     "CfgWeapons",  [IDX_VIRT_BINO],                                  IDX_CURR_BINO,             STAT_BINO,     "head"],
    ["LNK", "LINKED",   "MAP · GPS · RADIO",       "linked",   "CfgWeapons",  [],                                               -1,                        -1,            "torso"],
    ["IDN", "IDENTITY", "FACE · VOICE · INSIGNIA", "identity", "",            [],                                               -1,                        -1,            "head"]
];

// Linked item sub-slots: [label, virtual index, current index, ACE stat tab]
GVAR(linkedSlots) = [
    ["MAP",     IDX_VIRT_MAP,     IDX_CURR_MAP,     STAT_MAP],
    ["GPS",     IDX_VIRT_COMMS,   IDX_CURR_COMMS,   STAT_GPS],
    ["RADIO",   IDX_VIRT_RADIO,   IDX_CURR_RADIO,   STAT_RADIO],
    ["COMPASS", IDX_VIRT_COMPASS, IDX_CURR_COMPASS, STAT_COMPASS],
    ["WATCH",   IDX_VIRT_WATCH,   IDX_CURR_WATCH,   STAT_WATCH]
];

// Camera presets: [distance, vertical angle, helper position]. Horizontal angle is kept unless noted.
GVAR(camPresets) = createHashMapFromArray [
    ["full",   [4.2, 0,  [0, 0, 0.9]]],
    ["head",   [1.2, 5,  [0, 0, 1.62]]],
    ["torso",  [2.0, 5,  [0, 0, 1.25]]],
    ["weapon", [1.9, 5,  [0.15, 0.2, 1.3]]],
    ["hip",    [1.7, 0,  [0.15, 0, 1.0]]],
    ["back",   [2.2, 8,  [0, 0, 1.25]]]
];

// Short tags for the mod filter chips, matched against the mod's name
GVAR(modTags) = [
    ["60th", "60TH"],
    ["3AS", "3AS"],
    ["Knightfall", "3AS"],
    ["Legion", "LS"],
    ["Indecisive", "IDA"],
    ["IDA", "IDA"],
    ["Simulations", "JLTS"],
    ["Advanced Combat", "ACE"],
    ["ACE", "ACE"],
    ["Task Force", "TFAR"],
    ["Arma 3", "A3"]
];

GVAR(roles) = ["RIFLEMAN", "MEDIC", "HEAVY", "MARKSMAN", "RECON", "PILOT", "COMMAND", "ENGINEER", "OTHER"];

ADDON = true;
