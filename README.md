# [CS] Starsim Arsenal

A redesigned ACE arsenal for Arma 3. It replaces the look of the ACE arsenal screen and keeps ACE's data underneath, so saved loadouts, shared loadouts and arsenal restrictions all work as before.

> **Beta.** If something breaks, turn off **Use Starsim Arsenal** in the addon options to get the standard ACE arsenal back. No restart needed.

## Features

- **Gear slots with sorting**: sort any list by name, mod, weight, capacity or armour.
- **Pins**: pin items to keep them at the top of a slot's list across slots, filters and sessions. Compare up to three items side by side.
- **Packing**: fill your uniform, vest and backpack with ACE's categories (Medical, Tools and so on). Add or remove 1, 5 or all, type an exact amount, or drag items between containers.
- **Weight warnings**: see how many more of an item fit, and get a warning before your load turns Heavy.
- **Weapon view**: attachments, magazines and the ammo carried for each weapon.
- **Loadouts**: browse your own, unit, shared and mission loadouts by role, with favourites listed first.
- **Undo**: Ctrl+Z undoes equipping, packing and magazine changes.
- **Themes**: every colour can be changed in the addon options.

## Requirements

- [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)
- [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057)
- Optional: [ACE3 Arsenal Extended](https://steamcommunity.com/workshop/filedetails/?id=2522638637), for grouping gear variants

## Multiplayer

The mod is client side. Each player runs it on their own machine, and players without it get the normal ACE arsenal.

The server doesn't need to run it. If the server checks signatures (`verifySignatures`), add the mod's `.bikey` to the server's `keys` folder.

## Settings

Go to **Options > Addon Options > [CS] Starsim Arsenal**.

| Setting | Who sets it | What it does |
|---|---|---|
| Use Starsim Arsenal | Each player | Turns the new UI on or off |
| Unit name | Server / mission | Shown under the title |
| Colours (8 settings) | Each player | The theme. Applies the next time the arsenal opens |

## Unit loadouts

Missions can add loadouts to the **UNIT** tab. Call this somewhere that runs on every player, such as `init.sqf`:

```sqf
["Rifleman", _cbaExtendedLoadout, "RIFLEMAN"] call arsenal_ui_fnc_addUnitLoadout;
```

## Keys

| Key | Action |
|---|---|
| Click / double-click | Preview / equip |
| Enter, Backspace | Equip preview, revert |
| P | Pin |
| C | Full compare |
| Ctrl+F | Search |
| Ctrl+Z | Undo |
| Ctrl+S | Save loadout |
| Left / Right (packing) | Remove / add one. Shift: five. Ctrl: all / fill |
| F (loadouts) | Favourite |

## Building

Built with [HEMTT](https://github.com/BrettMayson/HEMTT).

```sh
hemtt check     # lint
hemtt dev       # development build
hemtt launch    # build and start Arma with the mods in .hemtt/launch.toml
hemtt release   # signed release build
```
