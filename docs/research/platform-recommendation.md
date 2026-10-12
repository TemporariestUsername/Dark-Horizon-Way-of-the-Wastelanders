# Platform Recommendation

**Recommendation: Godot 4 (GDScript), 2D, data‑driven, with the simulation core kept separate from the presentation layer. Ship on PC (Steam, Steam Deck) first. Console comes later, through a porting partner.**

This follows from what reverse‑engineering the two source games showed about their structure.

## What the reverse‑engineering told us about the shape of this game

| Finding | Source | Engine requirement |
|---|---|---|
| Both are **2D tile worlds at 256×224**: a top‑down town plus an overworld map | Emulation | Strong 2D tilemaps, a pixel‑perfect camera, nothing 3D |
| **Most of the screens are menus and dialogue**: portrait + text box + list menus, stat sheets, market tables | Emulation | A first‑class UI system with layout containers, theming and gamepad focus navigation |
| **The content is tabular and small**: 25 hulls, ~130 ports, ~47 goods, 13 regions (UWNH); 30 provinces, 15 daimyo, ~105 officers, ~40 spells, ~120 monsters (Inindo) | ROM tables | Data‑driven content in human‑editable files (designers will be tuning hundreds of rows) |
| **All text is uncompressed ASCII**, and there's a lot of it: rumors, dialogue, item descriptions | ROM | A string pipeline, localization, and an authoring format for dialogue |
| **Simulation ticks by day and by month**: wages, interest, the daimyo turn, autonomous NPC verbs (*Move, Attack, Flee, Seek work, Work, Train, Wait, Meet*) | ROM text | A deterministic sim core you can test headlessly and run many months ahead for balancing |
| **Grid tactics** with lineup/formation (Inindo) and **grid fleet battles** (UWNH) | Emulation / Play | Grid maps, turn order, AI evaluation. Nothing that needs physics |
| **Battery saves** (32 KB / 8 KB SRAM) hold a whole world state | Header | Serialising the full world state is cheap. Save anywhere is fine |
| **Two‑tone + red** visual identity (Inindo's title, AW's art) | Emulation / PDF | Palette and shader control for the two‑tone dithered look, with red as the only accent |

## Options considered

| Option | Strengths | Weaknesses | Verdict |
|---|---|---|---|
| **Godot 4** | Excellent 2D and TileMap support. The **Control/UI system suits menu‑heavy games**. No royalties, MIT licence. Runs headless for sim tests (`--headless`, GUT tests). Resources and JSON for data. Exports to Windows, macOS, Linux, Steam Deck, Web, Android and iOS. Console through partners such as W4 Games. | Console export isn't built in. GDScript is slower than C#, but this game is never CPU‑bound. | **Chosen** |
| Browser TypeScript (Vite + Canvas/Pixi) | Fastest to prototype and share. Easy to test. | You build your own UI layout, input‑focus and tilemap tools. Desktop and console distribution needs wrappers (Electron/Tauri), and polish costs more. | Good for a throwaway paper prototype of the moves engine. Not for the game. |
| Unity | Mature, console‑ready, big asset store. | Licensing and pricing history is a trust risk. It's heavyweight for a 2D menu game, and 2D UI (UGUI/UI Toolkit) is more friction. | Not chosen |
| SNES homebrew (65816, ca65, or PVSnesLib) | Maximum authenticity, which would make a great marketing stunt. | The text‑heavy design, mature content, a Director AI and a world sim in 128 KB of WRAM would cut the design to pieces. Tiny audience. | No. Could be revisited later as a demake/promo |
| Custom engine (Rust/Bevy, MonoGame…) | Full control. | Months spent on tooling that Godot already provides. | No |

## Recommended architecture
```
/sim         Pure GDScript classes, with no Node dependencies: world state,
             moves engine, Director, economy, warlord AI, countdowns.
             Deterministic: seeded RNG; all dice go through one Dice service
             that logs rolls for replays and tuning.
/data        JSON/CSV content (holds, resources, playbooks, moves, threats,
             vehicles, weapons, names, rumors), schema‑validated in CI.
/game        Godot scenes: overworld, hold, skirmish, road war, sheets, dialogue.
/tools       Headless sim runner ("simulate 36 months, 200 seeds"), balance reports.
/tests       GUT unit tests for /sim; golden‑file tests for the Director.
```
- **Resolution**: a native canvas of **480×270**, integer‑scaled. That's the 16:9 equivalent of the SNES's 256×224, and it scales cleanly to 1080p, 1440p and 4K.
- **Look**: two‑tone dithered pixel art plus a single red, enforced with a palette shader so every asset stays on‑model.
- **Saves**: JSON world snapshots, versioned, with save anywhere. Ironman mode is optional. AW's "*life is untenable*" should mean something, so ironman fits.
- **Accessibility**: remappable input, a text‑speed setting, full dice transparency (show the 2d6 and the modifiers), and a colour‑independent harm display.

## Next step for engineering (out of scope this round)
Spike in Godot 4: the moves engine plus a 10‑hold economy plus a 12‑month headless sim. Success means a balance report that shows allegiance shifting and the economy neither inflating nor collapsing. See [`../design/15-roadmap.md`](../design/15-roadmap.md).
