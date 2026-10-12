# sim/

The M1 headless simulation: the world turn from [docs/design/10](../docs/design/10-warlords-and-politics.md#the-world-turn-end-of-each-month), in plain GDScript with no scene or Node code, so it runs in tests, in the balance runner, and later under the game.

| Script | What it does |
|---|---|
| `sim_data.gd` | Loads `data/` once (holds, roads, rules). Read-only |
| `road_graph.gd` | The road network: all-pairs shortest paths (year-round), nearest-first neighbour lists, travel days by road class |
| `world.gd` | One seed's mutable state, `world_turn()`, the ambition-condition queries, and per-month metrics |
| `lean.gd` | Lean shares: drift (independent first, then the largest share), conquest, contested |
| `gang_war.gd` | Inindo's province war from `rules/war.json` |
| `conditions.gd` | Parses and evaluates ambition `when` strings from `rules/factions.json` |
| `economy.gd` | Stock, NPC trade, wants rising under disruption, the category price index, prices |
| `factions.gd` | Influence engines, monthly actions, ambitions, grip, seats, deaths, home rule |
| `choir.gd` | The Hum's seep, the Choir's actions by reach, coffles, the Opened marching, Silencing |
| `subfactions.gd` | Backing drift, monthly verbs (raid, grow, preach, work, hide, back), Turning |
| `characters.gd` | Check chance, XP curve, derived stats (M1 tests them; battles use them from M2) |

**Determinism.** Every random draw goes through the World's one `RandomNumberGenerator`, seeded per run, and every loop walks dictionaries in insertion order. The same seed always replays the same history (`tests/run_tests.gd` checks it).

**Not in M1.** The player, the Wanderer AI (it needs the named-NPC roster, M2), the League (it needs a broker, the player), battles other than gang war (M2).

## Running
```sh
GODOT=$(tools/get_godot.sh)                       # pinned Godot 4.4.1, checksum-verified (Linux)
"$GODOT" --headless --path . --script res://tests/run_tests.gd
"$GODOT" --headless --path . --script res://tools/sim_runner.gd -- --months 120 --seeds 200
"$GODOT" --headless --path . --script res://tools/debug_seed.gd -- --seed 1 --months 48 --kinds choir,war
```
The runner writes `tools/out/report.md` and `report.json` and exits 1 if a balance target fails. On Windows or macOS, use your own Godot 4.4.1 in place of `$GODOT`.
