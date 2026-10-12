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
| [`rules/time.json`](../../data/rules/time.json) | Calendar and seasons, travel speeds, supply burn, healing, **real‑time pacing targets** | Yes |
| [`rules/factions.json`](../../data/rules/factions.json) | Six factions: temperament, grip, lieutenants, **influence‑engine numbers**, targets, **ambitions**; AI actions; relations; balance targets | Yes |
| [`rules/choir.json`](../../data/rules/choir.json) | The **Choir's spread**: Hum levels, seep, defences, voices, actions by reach, reach tiers, Silenced holds, pushback, the Opened, cantors, the League | Yes |
| [`rules/subfactions.json`](../../data/rules/subfactions.json) | 16 sub‑factions: Standing (−100 to +100), Presence, backing, verbs, perks, Turning progress | Yes |
| [`rules/characters.json`](../../data/rules/characters.json) | Attributes, derived‑stat formulas, the three XP tracks, skills and training, Renown, checks, Hum exposure | Yes |
| [`rules/war.json`](../../data/rules/war.json) | Gang war: troops by size, the strength formula, losses, morale, walls, tags | Yes |
| [`rules/classes.json`](../../data/rules/classes.json) | The six launch classes and four companion classes: attributes, growth, skills, starting gear, abilities by track and level | Yes |
| [`rules/equipment.json`](../../data/rules/equipment.json) | Weapons, armour, rig guns, frames, hood ornaments | Yes |
| [`rules/disciplines.json`](../../data/rules/disciplines.json) | The twelve disciplines' techniques as battle data | Yes |
| [`rules/battle.json`](../../data/rules/battle.json) | Skirmish and road‑war rules, statuses, the Choir in battle, encounter targets | Yes |
| [`units/units.json`](../../data/units/units.json) | Enemy units and rated encounters | Yes |

**Tools** (Python 3, in [`tools/`](../../tools)):
- `validate_data.py` checks every file against the others and against the [Gazetteer](16-gazetteer.md): names, tiers, bosses and Lean must match. It's run before every commit and in CI from M1.
- `build_roads.py` rebuilds the road network.
- `bootstrap_holds.py` and `bootstrap_economy.py` are one‑time generators, kept for provenance.
- `sim_choir.py` runs the Choir's spread over the road network with no player, to tune [`choir.json`](../../data/rules/choir.json) against its balance targets.

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

## The Choir's spread in numbers
There's no clock. The Choir spreads hold by hold ([02](02-world.md#the-choirs-creep-no-clock), [17](17-factions.md#the-choir-the-nobunaga-faction)):
- **Start**: Harrowgate and the Gondola are Silenced (Hum 100), and Wisher is at 45. The Choir has 20 **voices**.
- **Seep**: each month, every Silenced hold adds **0.9 × (1 − km ÷ 420)** Hum to each hold within 420 km by road. Marked holds seep at a quarter of that. Everything is multiplied by **1 + voices ÷ 200**.
- **Defences** multiply the Hum a hold gains: a Deaf faction's Lean ×0.6, each point of Keeper or Watcher Presence ×0.85, the player patrolling ×0.5, Static or a jammer ×0. A Hum‑touched faction's Lean is ×1.3, and a turned sub‑faction's chapter with Presence 2 or more adds 1 Hum a month per point, past every defence, once the hold is Touched.
- **Decay**: a hold with no source nearby loses 2 Hum a month.
- **Voices**: +4 per coffle delivered, +6 per hold Silenced, −25 per Harrowgate node destroyed, up to 160.
- **Actions**: 1 a month, 2 from 5 Silenced. From 15 Silenced, a 15% chance each month of a march: an Opened gang war against a neighbouring Marked hold.
- **Pushback**: a liberated hold drops to 0 and its neighbours lose 20; a saved sub‑faction loses 40 Turning; taking Pellet stops the coffles.

**Measured with no player** (the M1 sim, median of 200 seeds; [report](../reports/m1-balance-report.md)):

| Month | 36 | 60 | 72 | 96 | 120 |
|---|---|---|---|---|---|
| Silenced holds | 9 | 14 | 19 | 31 | 42 |
| Reach | Spreading | Spreading | Marching | Drowning | Drowning |

**Targets** (`choir.json`): at most 9 by month 36, 11–16 by month 60, 30–45 by month 120. That's slow and steady: the Choir reaches **Marching** between months 60 and 72 and **Drowning** around month 96 if nobody resists. A campaign runs 60–96 months, so a passive player will see it Marching, and a hard‑pushing one can hold it at Spreading or push it back.

## Faction engines in numbers

| Faction | Engine | Key numbers |
|---|---|---|
| The Lighthouse | Passage | +0.75 Lean a month to holds within 600 km that cross through its crossings. +0.25 per extra crossing, max +2. Shut off if any of its crossings tolls |
| Sweetwell | Thirst | +1.5 a month to holds with water want ≥2 within 700 km, ×2 in the Long Heat. Shut‑off on a 4‑month cooldown. **The aquifer** level drops 8 a year (11 in a Long Heat year) |
| Highwater | Freight | +1.5 a month on standing routes, ×2 in winter. 50% chance a month to extend a route by up to 300 km. A raid costs −3 along the whole route |
| The Exchange | Debt | 10 barter a month to invest. Lends 5–15 barter to holds with a want ≥2. +1.5 a month slide until repaid (15% repay chance a month) |
| Burning Water | Fuel | +1 or +2 a month to fuel‑wanting holds within 900 km. Embargo: ×2 fuel price, and the hold submits (+5) or turns (−5), 50/50. Teeth raid the crude 25% of months |
| Cerro | Walls | Fortifies one hold a month within 500 km. +2 a month per walled hold. +0.5 tolls on the Rio Grande bed |

**Sub‑faction backing** adds Presence × 0.5 a month to the backed faction in every chapter hold.

**Home rule** pulls the other way: every month, each hold that isn't a living faction's seat moves 1.75 points from its largest faction share back to independent, unless that share is already 60 or more. Loose influence has to be kept up, but a firm hold stays held. Without it, the factions swallowed the independents within two years in the M1 sim; without the 60 exemption, they couldn't keep what they conquered. A living faction's seat can only be taken or Silenced: drift, raids and the Marked drain don't touch it.

**Faction actions** ([`factions.json`](../../data/rules/factions.json) `actions`): a show of force is +2 Lean in up to 3 holds within 300 km; buying out allies spends 12 barter (6 points); a faction claims territory by gang war at most once every 8 months.

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

## What M1 found
M1 is the headless Godot simulation ([`sim/`](../../sim/README.md)). It loads these files and runs the world turn ([10](10-warlords-and-politics.md#the-world-turn-end-of-each-month)) with no player, across 200 seeds × 120 months, and reports against the balance targets in `factions.json` and `choir.json`. **Every target passes** in the [latest report](../reports/m1-balance-report.md):

| Target | Result (median) |
|---|---|
| 4–6 factions alive at month 48 | 5 |
| ≥ 25 holds changing Lean by month 48 | 53 |
| No faction above 30% of holds | the largest holds 8% |
| ≥ 50% of independents still independent | 57% |
| ≥ 4 sub‑factions switching backing | 10 |
| Choir: ≤ 9 / 11–16 / 30–45 Silenced at months 36 / 60 / 120 | 9 / 14 / 42 |
| Family and Cross‑folk turned by month 60 | both, every seed |

**What the first runs changed** (each is now in the data and the docs above):
- **The economy measures disruption, not scarcity.** The map is scarce by design (medicine supply covers about a fifth of demand), so judged against an absolute bar every hold looked afflicted on day one. A want now rises when its supply falls below half of that hold's own starting level, which is what a Silenced supplier, an embargo or a raid does. Prices and wants are stable without a player; about 29 holds carry a disrupted want by month 48.
- **Home rule.** Without a pull back to independence, the factions absorbed every independent hold within two years. Home rule (1.75 a month, below a 60 share) means loose influence has to be kept up.
- **Softer engines and actions**, and a claim at most every 8 months: the factions grow slowly and fight over the edges, as UWNH's nations did.
- **Turned chapters work at the Hum's edge.** Letting them work anywhere seeded outbreaks across the map, which drowned it by year seven (96 Silenced at month 120). Voices are capped at 160 and the Opened march 15% of months.

**Findings to watch** (for the M2 design pass):
- **Burning Water falls in almost every seed** (98%), usually between months 20 and 40, because its seat is Harrowgate's neighbour. The design wants it bought or broken by month 60 without a player, so this is on purpose but early. Saving it is the player's clearest first job.
- **The factions barely grow on their own**: +1 to +4 holds each by month 48, and Sweetwell shrinks (4 to 3) despite winning 5 gang wars, because conquered holds drift back. The player's investment and gigs should matter a lot, which is the intent, but the AI may need stronger ways to *keep* what it takes.
- **Ambitions are uneven**: the Lighthouse and Cerro finish all four stages by month 48; the Exchange rarely finishes its first (70 Lean at Fuse is far from Tampa); Highwater stalls at its first. Stage conditions need a second look.
- **Not simulated yet**: the Wanderer AI (it needs the named‑NPC roster), the League (it needs a broker: the player), and every battle except gang war (M2).

Whatever the sim shows, the numbers here change, the docs that quote them change with them, and the validator and tests keep the two in step.

## M2: skirmish balance
The [battle bench](../reports/m2-battle-bench.md) fights every rated encounter 500 times against a Driver, an Angel and a Gunlugger at the encounter's level. **All eleven encounters land in their rating's window.** What the first runs changed:
- **Ammo counts attacks.** A fighter carries 12 attacks' worth, so the machine gun (3 rounds an attack) no longer runs dry after four bursts.
- **Cantors hit harder**: 8 + 30% of Weird (was 10%), so a cantor is worth killing first.
- **Weak attackers need real teeth.** Damage is Attack minus Defense, so the Opened and the beasts did almost nothing. The Opened's hands and bites are now 16 Attack, and the Opened are stronger (Hard 60), which keeps them fragile but dangerous in numbers.
- **Encounters were re‑sized** to their ratings (in [`units.json`](../../data/units/units.json)).

**Findings to watch:** fair fights leave the party at 20–40% of its HP with one or two members down; and the Catchers, Wellguard and Sings‑Back fights run 14–17 rounds, past the 10‑round pacing target.
