# 19 · Numbers and Data

The design bible's rules are now **data** that the M1 simulation can load. This doc explains what's in [`data/`](../../data/README.md), how it was built, and the reasoning behind the key numbers. Every number here is a **starting value** for the M1 headless sim to tune, not a final balance.

## What's in `data/`

| File | What it holds | Source of truth? |
|---|---|---|
| [`world/holds.json`](../../data/world/holds.json) | All 130 holds: coordinates, region, tier, boss, faction, **economy** (surplus/want 0–3 for 29 goods, stock), services and needs, population, gang, walls, buildings, **starting Lean**, sub‑faction Presence | **Yes**, after bootstrap |
| [`world/roads.json`](../../data/world/roads.json) | 423 hold‑to‑hold edges: km, road‑class mix, interstate labels, the crossing used, breaks, season | Rebuilt by `tools/build_roads.py` |
| [`rules/resources.json`](../../data/rules/resources.json) | 29 goods (base price, category, spoilage) and 19 services | Yes |
| [`rules/economy.json`](../../data/rules/economy.json) | Price model coefficients, saturation, stock regeneration, upkeep, debt, tolls, chart prices | Yes |
| [`rules/lean.json`](../../data/rules/lean.json) | Thresholds, the player's Lean levers, drift, conquest, tithe | Yes |
| [`rules/time.json`](../../data/rules/time.json) | Calendar and seasons, travel speeds, supply burn, harm clock, **real‑time pacing targets** | Yes |
| [`rules/factions.json`](../../data/rules/factions.json) | Six factions: temperament, grip, lieutenants, **influence‑engine numbers**, targets, countdowns; AI actions; relations; balance targets | Yes |
| [`rules/choir.json`](../../data/rules/choir.json) | The **World Clock** maths, Choir actions, Silenced holds, the Opened, Hum exposure, the League | Yes |
| [`rules/subfactions.json`](../../data/rules/subfactions.json) | 16 sub‑factions: Standing, Presence, backing, verbs, Turning | Yes |

**Tools** (Python 3, in [`tools/`](../../tools)):
- `validate_data.py` checks every file against the others and against the [Gazetteer](16-gazetteer.md): names, tiers, bosses and Lean must match. It's run before every commit and in CI from M1.
- `build_roads.py` rebuilds the road network.
- `bootstrap_holds.py` and `bootstrap_economy.py` are one‑time generators, kept for provenance.

## The road network
**Built from Natural Earth 1:10m** roads and rivers (public domain). OpenStreetMap was avoided because its share‑alike licence would cover the game's map database.

1. Roads inside the map are classified as **interstate** (US Interstates, Mexican expressways, Canadian major highways) or **highway**.
2. **Living rivers are barriers.** A road over the Mississippi, Ohio, Missouri, Tennessee, Niagara or Detroit survives only within 35 km of one of the [15 crossings](02-world.md#regions) that covers that river. **157 bridge segments were cut.**
3. Holds are snapped onto the main network, and the graph is contracted to hold‑to‑hold edges, pruning any edge that a two‑hop route covers within 8%.
4. Authored edges are added where the data has no road:
   - dry riverbeds (the Rio Grande, Red, Arkansas, Pecos)
   - winter ice roads on Lakes Ontario and Erie
   - Harrowgate's lift and cables
   - the Deep Lines' tunnels and entrances
   - the Brace Win dam road and Helena's bridge
5. **Breaks** (overpasses down, pileups) are seeded: about one per 175 km of road (763 in total). Each costs half a day's detour until cleared.

**What the real geography produced** (none of this was designed in; it's what the map does):
- **The Forty is broken at the Tennessee.** I‑40's bridge isn't a crossing, so Memphis to Nashville runs by Shoals or Spillway. That makes those two Tennessee crossings valuable.
- **New Orleans can only be reached from the west through Capitol** (Baton Rouge), or under the river through **Junction**. That's what makes Tum Tum's toll at Capitol bite.
- **The Lakes connect to the rest of the map through the Tunnel and the Falls**, which is why Highwater's southern expansion runs through Detroit.
- **The Sierra Coast is a month away.** It's the map's Caribbean. A Hocus starting at Barrow begins at the edge of the world.
- **No hold is unreachable** year‑round, and no edge crosses a living river except at a crossing (checked against the Mississippi's real course).

## The economy in numbers
- **29 goods** at base prices from 0.2 (crude) to 4.0 (hi‑tech) barter per lot.
- **Per hold**: the first good in the gazetteer's surplus list starts at level 3 and the rest at 2. The same goes for wants. Regional texture adds level‑1 goods (Lakes water, Rag‑Wastes crude, Glass luxuries, and so on).
- **Scarcity is deliberate**:

  | Good | Holds supplying it | Holds wanting it |
  |---|---|---|
  | Medical supplies | 7 | 94 |
  | Guzzoline | 12 | 51 |
  | Drinking water | 18 | 48 |
  | Ammo | 8 | 14 |

  Medicine is the always‑wanted good. Fuel and water are the factions' leashes.
- **Price**: buy = base × (1 − 0.15·S + 0.20·W), and sell = base × (0.70 − 0.10·S + 0.25·W) × (1 − saturation). Each is also multiplied by the category index (0.7–1.6) and tribute. Saturation is 4% per lot sold, capped at 60%, and halves monthly. Design targets: a great route returns 2.5×, a typical one 1.3–1.8×, and selling 15 lots in one hold crushes the margin.

## Starting Lean (UWNH‑style partial shares)
- **Seats** start at 100% for their faction. **Aligned holds** start at 60%.
- **Independent holds** carry partial shares from every faction seat by road distance: 25 × e^(−km/350), capped at 35 in total.
- So Gnarly, near Memphis, starts 22% Lighthouse, and the Reserve starts 19% Burning Water. On day one the map already shows who's reaching for what, as UWNH's port shares did.

## The World Clock maths
- **Six segments** needing **12, 12, 12, 8, 6 and 6** progress points.
- **Base rate**: the Choir earns 1 point a month, so with no help and no resistance 9:00 lands at **month 36** and 12:00 at **month 56**.
- **What speeds it up**:
  - every Silenced hold (+0.05 a month each)
  - every coffle delivered (+0.25)
  - every turned sub‑faction (+0.2 a month)
  - a faction seat Silenced (+6)
- **What pushes it back**:
  - a coffle stopped (−0.5)
  - a hold liberated (−3)
  - a sub‑faction saved (−4)
  - Pellet taken (−12, a whole segment)
  - a Harrowgate node destroyed (−6)
- **Target**: 9:00 between months 36 and 54 in a typical game. The campaign runs 60–96 months.

## Faction engines in numbers

| Faction | Engine | Key numbers |
|---|---|---|
| The Lighthouse | Passage | +1 Lean a month to holds within 800 km that cross through its crossings. +0.5 per extra crossing, max +4. Shut off if any of its crossings tolls |
| Sweetwell | Thirst | +2 a month to holds with water want ≥2 within 700 km, ×2 in the Long Heat. Shut‑off on a 4‑month cooldown. **The aquifer ticks every 12 months** |
| Highwater | Freight | +1.5 a month on standing routes, ×2 in winter. 50% chance a month to extend a route by up to 300 km. A raid costs −3 along the whole route |
| The Exchange | Debt | 30 barter a month to invest. Lends 5–15 barter to holds with a want ≥2. +2 a month slide until repaid (15% repay chance a month) |
| Burning Water | Fuel | +1 or +2 a month to fuel‑wanting holds within 900 km. Embargo: ×2 fuel price, and the hold submits (+5) or turns (−5), 50/50. Teeth raid the crude 25% of months |
| Cerro | Walls | Fortifies one hold a month within 500 km. +2 a month per walled hold. +0.5 tolls on the Rio Grande bed |

**Sub‑faction backing** adds Presence × 2 a month to the backed faction in every chapter hold.

## Time and pacing

| Unit | Value |
|---|---|
| Calendar | 30 days a month. Spring floods, summer's Long Heat, autumn twisters, winter ice roads. The game starts on the first day of spring in year two of the Easing |
| Speeds | 125 km a day on interstate, 88 on highway, 62 on back roads, 112 on dry riverbed (150 for light rigs), 38 in the Rough, 150 on lake ice, 30 on foot in the Deep Lines |
| Supply burn | Water: 1 cask per 4 crew a day. Chow: 1 crate per 6 crew a day. Guzzoline: 1 can per rig a day (2 in the Rough or snow). Water ×1.5 in heat |

**Real‑time pacing**:
- A road day plays in about 20 seconds at 1× speed.
- A typical month is 8–12 road days, 2–4 hold visits and 1–3 scenes or battles, which comes to **35–45 minutes**.
- Over **60–96 months**, that's the **40–60 hour** campaign target.

## What M1 does with this
M1 is the headless Godot simulation. It loads these files and runs the world turn ([10](10-warlords-and-politics.md#the-world-turn-end-of-each-month)) for 48 months across 200 seeds. It then reports against the balance targets in `factions.json` and `choir.json`:
- 4–6 factions alive
- at least 25 holds changing Lean, and no faction above 30%
- at least 4 sub‑factions switching backing
- 9:00 between months 36 and 54
- **without a player, the Choir wins**: 15 or more holds Silenced by month 60

Whatever the sim shows, the numbers here change, the docs that quote them change with them, and the validator keeps the two in step.
