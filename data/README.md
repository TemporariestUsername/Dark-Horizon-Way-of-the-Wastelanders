# data/

Game data for *Dark Horizon*: the world, and the rules as numbers. It's loaded by the simulation (M1 onward) and explained in [`docs/design/19-numbers-and-data.md`](../docs/design/19-numbers-and-data.md).

```
world/holds.json        130 holds: place, people, economy, defences, Lean, sub-faction Presence
world/roads.json        hold-to-hold road network (generated)
rules/resources.json    goods and services
rules/economy.json      prices, stock, upkeep, debt, tolls
rules/lean.json         loyalty thresholds and levers
rules/time.json         calendar, travel, supply burn, pacing
rules/factions.json     the six factions, their AI and influence engines
rules/choir.json        the Choir and the World Clock
rules/subfactions.json  cults, road gangs, guilds, secret societies
```

## Working with it
```sh
python3 tools/validate_data.py                 # run after any edit; must say "data OK"
pip install pyshp && python3 tools/build_roads.py   # rebuild roads.json (downloads Natural Earth into data/raw/)
```
- Edit `holds.json` and `rules/*.json` by hand. **Keep them in step with the design docs.** The validator cross‑checks the hold names, tiers, bosses and factions against `docs/design/16-gazetteer.md`.
- `roads.json` is generated. Change `tools/build_roads.py` (its authored edges, crossings or breaks), not the JSON.
- `tools/bootstrap_*.py` were one‑time generators. Re‑running them overwrites hand edits to `holds.json`.

## Sources and licences
- **Road and river geometry**: [Natural Earth](https://www.naturalearthdata.com/) 1:10m cultural and physical vectors, **public domain**. Raw downloads live in `data/raw/`, which is gitignored and never committed.
- Everything else is original design data for this project.
