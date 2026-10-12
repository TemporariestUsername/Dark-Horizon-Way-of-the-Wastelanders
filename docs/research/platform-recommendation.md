# Platform Recommendation

**Recommendation: Godot 4 (GDScript), 2D, data‑driven, with the simulation core kept separate from the presentation layer. Ship on Windows and macOS only (client decision), through Steam, with GOG and itch.io optional.**

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
| **Battery saves** (32 KB / 8 KB SRAM) hold a whole world state | Header | Serialising the full world state is cheap, so a conventional save system with many slots is easy |
| **Full‑colour pixel art** with a restricted palette, inspired by Mad Max (client decision) | Art direction | Palette control (a ~48‑colour master palette with regional shifts), cheap particles for dust, smoke and fire, and a desaturation shader for Hum levels |

## Options considered

| Option | Strengths | Weaknesses | Verdict |
|---|---|---|---|
| **Godot 4** | Excellent 2D and TileMap support. The **Control/UI system suits menu‑heavy games**. No royalties, MIT licence. Runs headless for sim tests (`--headless`, GUT tests). Resources and JSON for data. **First‑class Windows and macOS export**, including universal macOS builds and ad‑hoc code signing, so no Apple Developer account is needed. | GDScript is slower than C#, but this game is never CPU‑bound. | **Chosen** |
| Browser TypeScript (Vite + Canvas/Pixi) | Fastest to prototype and share. Easy to test. | You build your own UI layout, input‑focus and tilemap tools. Desktop distribution needs a wrapper (Electron or Tauri), and polish costs more. | Good for a throwaway paper prototype of the battle formulas. Not for the game. |
| Unity | Mature, big asset store. | Licensing and pricing history is a trust risk. It's heavyweight for a 2D menu game, and 2D UI (UGUI/UI Toolkit) is more friction. | Not chosen |
| SNES homebrew (65816, ca65, or PVSnesLib) | Maximum authenticity, which would make a great marketing stunt. | The text‑heavy design, mature content, an event system and a world sim in 128 KB of WRAM would cut the design to pieces. Tiny audience. | No. Could be revisited later as a demake/promo |
| Custom engine (Rust/Bevy, MonoGame…) | Full control. | Months spent on tooling that Godot already provides. | No |

## Recommended architecture
```
/sim         Pure GDScript classes, with no Node dependencies: world state,
             characters and checks, battles, events, economy, faction AI,
             ambitions, the Choir's spread.
             Deterministic: seeded RNG; every random draw goes through one
             RNG service that logs draws for replays and tuning.
/data        JSON/CSV content (holds, resources, classes, abilities, threats,
             vehicles, weapons, names, rumors), schema‑validated in CI.
/game        Godot scenes: overworld, hold, skirmish, road war, sheets, dialogue.
/tools       Headless sim runner ("simulate 36 months, 200 seeds"), balance reports.
/tests       GUT unit tests for /sim; golden‑file tests for events and battles.
```
- **Resolution**: a native canvas of **480×270**, integer‑scaled. That's the 16:9 equivalent of the SNES's 256×224, and it scales cleanly to 1080p, 1440p and 4K.
- **Look**: full‑colour pixel art on a restricted ~48‑colour master palette, Mad Max‑inspired ([14](../design/14-art-audio-ui.md)). A palette shader keeps every asset on‑model and drains colour from holds as their Hum level rises.
- **Saves** (client decision: a conventional save system): JSON world snapshots (gzip), versioned with migrations. Manual slots, rotating autosaves and quicksave. The RNG service's seed is saved, so reloading doesn't re‑roll results. Stored in Godot's `user://` (`%APPDATA%` on Windows, `~/Library/Application Support` on macOS), with Steam Cloud sync. See [03](../design/03-core-loops.md#saving-client-decision-a-conventional-save-system).
- **Input**: mouse and keyboard first, with gamepad supported. Trackpad gestures (pan and zoom on the overworld) on macOS. Platform‑native shortcuts (⌘ on macOS, Ctrl on Windows).
- **Rendering**: Godot's **Compatibility** renderer (OpenGL 3.3, falling back to ANGLE/Metal on macOS) is enough for a 2D pixel‑art game and runs on older Intel Macs and integrated GPUs. Minimum targets: Windows 10, macOS 11 on Apple Silicon or Intel, 8 GB RAM.
- **Overworld scale**: about 440 × 580 tiles at 5 km per tile, with a **road graph** layered over it for pathing and simulation. The world sim runs on the graph (130 holds plus about 600 road segments), not the tiles, so a 48‑month headless run stays fast.
- **macOS release pipeline**: a universal binary, **ad‑hoc signed** in CI. There's no Apple Developer account (client decision), so builds aren't notarized. See [below](#macos-without-an-apple-developer-account). Steam builds for both platforms from the same pipeline.
- **Accessibility**: remappable input, a text‑speed setting, every check's chance and modifiers shown, colour‑independent Hum and danger displays, and UI scaling for laptop screens.

## macOS without an Apple Developer account
The client has no Apple Developer account. That no longer blocks anything:
- **Builds are ad‑hoc signed.** Apple Silicon requires every binary to carry a signature, and Godot's macOS export applies an ad‑hoc one by default. No account is needed.
- **Builds aren't notarized.** Notarization needs a Developer ID, so Gatekeeper will treat a downloaded build as from an "unidentified developer".
- **Steam is fine.** Apps installed by the Steam client don't carry the quarantine flag, so they launch normally. Steam is the main Mac channel.
- **Direct downloads** (testers, itch.io): macOS blocks the first launch once. On macOS 15 and later the tester allows it in *System Settings → Privacy & Security → Open Anyway*; on macOS 14 and earlier, **right‑click → Open** also works. Testers can instead clear the flag with `xattr -dr com.apple.quarantine "Dark Horizon.app"`. The tester instructions say so.
- **When to get an account**: only if a public, non‑Steam Mac download (such as GOG or a direct sale) becomes a goal. It costs $99 a year, and the CI pipeline can add notarization later without other changes.

## Next step for engineering (out of scope this round)
Spike in Godot 4: the character and check formulas, the road graph, the 130‑hold economy, gang war, the Choir's spread and a 48‑month headless sim. Success means a balance report that shows allegiance shifting, the Choir creeping on target, and the economy neither inflating nor collapsing, plus an ad‑hoc‑signed macOS build and a Windows build from CI. See [`../design/15-roadmap.md`](../design/15-roadmap.md).
