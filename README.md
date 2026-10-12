# Dark Horizon: Way of the Wastelanders

> *"In Apocalypse World the horizons are dark, and no roads go to them."*

A single‑player, open‑world exploration, trade and survival RPG for **Windows and macOS**, set in **Apocalypse World** (licensed). For a generation the maelstrom made every road deadly. Now it has eased, and the old interstates are this world's uncharted seas. It brings together the gameplay philosophy of Koei's **Uncharted Waters: New Horizons** (career freedom, scarcity of range, trade as the engine, investment as conquest, discovery) and **Inindo: Way of the Ninja** (a living political map that changes every month, NPCs with their own lives, power learned at strange places, and a tyrant whose shadow keeps growing). The **mechanics** come from those two games; **Apocalypse World** supplies the classes, the setting and the ambiance. The look is **full‑colour pixel art inspired by Mad Max**.

**Status:** design bible (M0) complete. M1 prerequisites are done: the world and rules exist as validated data in [`data/`](data/README.md), including a 130‑hold road network built from public‑domain Natural Earth data. Next is the M1 headless simulation in Godot.

```sh
python3 tools/validate_data.py   # must say "data OK"
```

## Start here
1. [**Vision**](docs/design/00-vision.md): the pitch, pillars, tone and an index of everything.
2. [**Translation matrix**](docs/design/01-translation-matrix.md): every source system and where it goes.
3. [**The world**](docs/design/02-world.md): the Easing, interstates as seas, Last and the Choir's slow creep.
4. [**Gazetteer**](docs/design/16-gazetteer.md): all 130 holds.
5. [**Factions**](docs/design/17-factions.md) and [**sub‑factions**](docs/design/18-sub-factions.md): six hardholder powers, the Choir, and the cults, gangs, guilds and secret societies underneath.

## Design bible (`docs/design/`)
| # | Doc |
|---|---|
| 00 | [Vision](docs/design/00-vision.md) |
| 01 | [Translation matrix](docs/design/01-translation-matrix.md) |
| 02 | [World](docs/design/02-world.md) |
| 03 | [Core loops and time](docs/design/03-core-loops.md) |
| 04 | [Characters, levels and checks](docs/design/04-characters.md) |
| 05 | [Events and the living world](docs/design/05-events.md) |
| 06 | [Playbooks as classes](docs/design/06-playbooks.md) |
| 07 | [Economy](docs/design/07-economy.md) |
| 08 | [Travel, vehicles and the In](docs/design/08-travel-and-vehicles.md) |
| 09 | [Combat](docs/design/09-combat.md) |
| 10 | [Warlords and politics](docs/design/10-warlords-and-politics.md) |
| 11 | [Crew and bonds](docs/design/11-crew-and-bonds.md) |
| 12 | [Progression](docs/design/12-progression.md) |
| 13 | [Content tables](docs/design/13-content-tables.md) |
| 14 | [Art, audio and UI](docs/design/14-art-audio-ui.md) |
| 15 | [Roadmap, client decisions and open questions](docs/design/15-roadmap.md) |
| 16 | [Gazetteer: the 130 holds](docs/design/16-gazetteer.md) |
| 17 | [Factions](docs/design/17-factions.md) |
| 18 | [Sub‑factions](docs/design/18-sub-factions.md) |
| 19 | [Numbers and data](docs/design/19-numbers-and-data.md) |
| — | [Glossary](docs/design/glossary.md) |

## Research (`docs/research/`)
- [Teardown: Uncharted Waters: New Horizons](docs/research/uncharted-waters-new-horizons.md): reverse‑engineered from the ROM (headers, data tables, text) and observed in emulation.
- [Teardown: Inindo: Way of the Ninja](docs/research/inindo-way-of-the-ninja.md): same method.
- [Apocalypse World source notes](docs/research/apocalypse-world-source-notes.md): the AW elements we use as flavour, and the rules we don't.
- [**Platform recommendation**](docs/research/platform-recommendation.md): **Godot 4**, a data‑driven 2D game with a headless simulation core, for Windows and macOS.

## Repo hygiene
- Source ROMs, emulator states and raw extraction dumps are **never committed**, and `.gitignore` enforces this. The research docs contain analysis and short quotations only.
- Apocalypse World © D. Vincent Baker / Lumpley Games, used under the client's license. Uncharted Waters and Inindo © Koei Tecmo. They're referenced for design research only, and none of their content is used in the game.
