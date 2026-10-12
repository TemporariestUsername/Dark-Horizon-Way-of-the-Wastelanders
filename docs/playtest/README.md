# Playtesting M2

M2 asks one question: **are the fights and the events fun and fair?** The benches ([battles](../reports/m2-battle-bench.md), [events](../reports/m2-event-bench.md)) show the numbers hit their targets with the AI playing. Only people playing can say how it feels. This page covers getting builds to testers and turning what comes back into numbers.

## 1. Get the builds
Every push builds a Windows and a macOS zip (the **Playtest builds** workflow, [`.github/workflows/playtest-builds.yml`](../../.github/workflows/playtest-builds.yml)). On GitHub: *Actions → Playtest builds →* the run for the commit you want *→ Artifacts*. Each artifact is a zip holding the build's own zip; unzip once and send that inner zip (`DarkHorizon-playtest-<commit>-windows.zip` or `-macos.zip`). Artifacts are kept for 30 days.

To build locally (Linux x86_64): `tools/export.sh` writes both zips to `build/out/`, after a smoke test of an exported Linux build.

Each zip includes [`PLAYTEST.txt`](PLAYTEST.txt): how to start the game, including getting past Windows SmartScreen and macOS Gatekeeper (the builds aren't signed or notarized; see the [platform recommendation](../research/platform-recommendation.md#macos-without-an-apple-developer-account)), the controls, and how to send the log. The build id (the commit) shows on the menu and in every log record.

## 2. What testers do
Play anything from the menu: skirmishes, road wars, journeys. After each fight and journey the game asks **Too easy / About right / Too hard**. When they're done, they click **Open log folder** on the menu and send `log.jsonl`, plus any notes.

## 3. What the log records
One JSON object per line ([`game/playtest_log.gd`](../../game/playtest_log.gd)). Each record has the time, a random session id, the build and a kind:

| Kind | What's in it |
|---|---|
| `session` | OS name, Godot version, UI language. Once per launch |
| `skirmish`, `road_war` | What was fought (encounter or convoy, rating, party level, seed, or the journey and day it came from), the result, rounds, the player's actions by kind (move, attack, skill, Auto…), seconds played |
| `feel` | The tester's verdict on a fight or a journey |
| `journey_start`, `journey_end` | Route, level, seed; at the end: arrived or abandoned, days against expected, battles, defeats, cargo, barter, morale |
| `card` | An event card: its id and tone, the chances shown for each choice, the choice picked, and whether its check succeeded |
| `journey_battle` | A battle on a journey: fought in its screen or auto-resolved, and how it went |

No names, file paths, hardware or network details are recorded. With the seed, any menu fight can be replayed exactly.

## 4. Read what came back
Put the logs in a folder (the names don't matter; a log sent twice is only counted once) and run:
```sh
python3 tools/playtest_report.py playtest-logs/ -o tools/out/playtest-report.md
```
The report shows, for each skirmish and road war, the players' win rate against the bench's target and the feel votes, flagging fights that fall outside the target (from 10 plays) or that testers call too easy or too hard (from 3 votes). For journeys: arrivals, days, fought against auto-resolved battles. For event cards: what players pick, and **whether the chances shown are honest**: checks grouped by the chance shown, against how often they succeeded.

Keep the logs out of the repository: they're testers' data. Reports worth keeping go in [`docs/reports/`](../reports/).

## What to look for
- **Fights everyone calls too hard (or too easy)**, even if the bench says they're in range: the bench plays like a sensible AI, not like a person.
- **Players winning far less than the AI does**: the controls or the information on screen are failing them.
- **A high Auto share**: players are handing the fight to the AI. Is the fight tedious, or unclear?
- **Choices nobody picks**: the card's options aren't real choices.
- **Shown chances that don't match outcomes**: a bug, since the chance shown is the chance rolled. With few checks, expect noise.
