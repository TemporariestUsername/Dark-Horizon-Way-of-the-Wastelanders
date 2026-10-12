# 08 · Travel, Vehicles and the In

## The overworld
- A **top‑down tile map** of the Basin (about 512 × 512 tiles at launch). The convoy moves as one marker, like a UWNH fleet.
- **One day** is about 12 tiles on salt flat. Terrain changes that:

| Terrain | Speed | Fuel | Notes |
|---|---|---|---|
| Salt flat | ×1.0 | 1 can/rig/day | Exposed: you're seen from far away |
| Dune | ×0.5 | 2 | Hidden. *Deal with bad terrain* on entry if the rig has low handling |
| Broken ground | ×0.6 | 2 | *Deal with bad terrain* per day. Risk of v‑harm |
| Glass | ×1.0 (×0.5 at noon) | 1 | Navigation −1. Heat harm without shade |
| Wreck field | ×0.7 | 1 | Salvage and ambush |
| Road (ancient, surviving) | ×1.5 | 1 | Rare, and owned by someone |
| Deep Lines (Down) | ×0.8, on foot | 0 | No light means *do something under fire* to navigate. Connects regions |
| Skyline (Up) | lifts and cable | 0 | Vertical layer. Reached only through lift‑towers |

- **Fog of war** reveals as you travel (radius 2, or 4 for the Driver). **Charts** can be bought and sold.
- **Weather** follows the season and the region:
  - **dust storm**: UWNH's storm
  - **fog bank**: navigation −1
  - **the Long Heat**: water use ×1.5
  - **the Calm**: dead still, and the maelstrom gets loud. Radios sing and compasses spin. This is UWNH's eerie calm, made psychic.

## Supplies and attrition
Four gauges, shown for each rig and for the whole convoy:
- **Water** (casks)
- **Guzzoline** (cans)
- **Chow** (crates)
- **Ammo** (boxes)

Burn rates are in [03](03-core-loops.md#scarcity-budget-tuning-targets-for-the-slice).

**Running out:**
- **Water at 0**: each day every crew member takes 1‑harm ("*thirst*"), and crew Hx drops. On day 3, crew start to desert.
- **Guzzoline at 0**: the rig stops. You can tow it, abandon it, or send someone walking.
- **Chow at 0**: −1 ongoing to all rolls, and a *pack alpha* bid on day 4.
- **Ammo at 0**: *loud* and *reload* weapons can't be used.

**Road events** (Director moves drawn from road threats, never a random table):

| Event | Source threat | Fix or counter |
|---|---|---|
| **Dust storm** | Terrain/Landscape (*Furnace*) | Hunker down (lose a day) or *do something under fire* to push through |
| **The Calm** | Affliction (*Condition*) / the Hum | Wait, or *open your brain* to find the way out |
| **Scavvers in the stores** | Brute (*Hunting pack*) | Traps (an item), or lose chow |
| **Rot** (UWNH's scurvy) | Affliction (*Disease*) | Fresh foods, an Angel, antiseptic |
| **Raiders** | Warlord/Brute | Road war, tribute, or *outdistance* |
| **Wreck sighted** | Opportunity | Salvage: costs time, gives loot, may be a trap |
| **Straggler camp** | Opportunity | Trade, **dig for water** (+sharp), or **raid** (Chopper) |
| **A rig breaks down** | Vehicle (*its weakness*) | Mechanic crew, or a Savvyhead |

## Vehicles (UWNH's hulls → AW Driver frames)
Each vehicle has these properties, all from AW:

| Property | Range | Effect |
|---|---|---|
| **Frame** | bike, compact, large, battle (and a few special frames) | Base stats, crew and cargo |
| **Speed** | 0–3 | Overworld speed, and *outdistance or overtake* |
| **Handling** | 0–3 | Added to *deal with bad terrain*. Subtracted from v‑harm against you |
| **Armor** | 0–3 | Harm reduction for the vehicle |
| **Massive** | 0–3 | Ramming harm. Adds to v‑harm you inflict |
| **Strengths** (choose 1–2) | fast, rugged, aggressive, tight, huge, off‑road, responsive, uncomplaining, capacious, workhorse, easily repaired | Situational +1s |
| **Looks** (choose 1–2) | sleek, vintage, pristine, powerful, luxe, flashy, muscular, quirky, pretty, handcrafted, spikes & plates, garish | Affects Hot rolls and Rep at holds |
| **Weakness** (choose 1–2) | slow, sloppy, lazy, loud, picky, guzzler, unreliable, rabbity, cramped, bucking, skittish | Activated as a Director *stuff's downside* move |
| **Crew** min/max | e.g. 1/2 (bike), 2/6 (compact), 4/20 (large), 6/30 (rig/hauler) | UWNH's min/max crew |
| **Cargo** | lots | UWNH's capacity |
| **Hood ornament** | skull, saint, hula girl, steer horns, chrome angel, doll's head… | UWNH's figurehead: +1 to a narrow kind of roll |

**Frames at launch** (16, standing in for UWNH's 25 hulls):

| Frame | Speed / Handling / Armor / Massive | Crew | Cargo | Notes |
|---|---|---|---|---|
| Dirt bike | 3/2/0/0 | 1/1 | 1 | Scout. Chopper gangs |
| Hog | 2/1/1/1 | 1/2 | 2 | Chopper bike |
| Sand buggy | 3/2/0/1 | 1/3 | 4 | Fast courier |
| Compact | 2/2/1/1 | 2/4 | 8 | Starting Driver option |
| Pickup | 1/1/1/2 | 2/6 | 16 | Workhorse |
| Ute with a gun ring | 2/1/1/2 | 3/6 | 10 | Battle car |
| Interceptor | 3/3/1/1 | 1/2 | 4 | *My other car is a tank* path |
| Bus | 0/0/2/3 | 4/30 | 40 | Hardholder caravan, Hocus followers |
| Hauler (semi) | 1/0/2/3 | 2/8 | 60 | Trade backbone |
| Tanker | 0/0/2/3 | 2/6 | 50 water/fuel only | Grome's leash, if you can get one |
| Half‑track | 1/1/3/2 | 3/10 | 20 | Dune and broken ground |
| War rig | 1/0/3/3 | 6/20 | 30 | Mid‑game flagship |
| Land yacht | 2/1/0/1 | 3/12 | 25 | **Sail‑driven: no fuel on salt flat, needs wind.** UWNH's love letter |
| Salt skiff | 3/2/0/0 | 2/4 | 6 | Sail‑driven. Salt only |
| Tank (ancient) | 0/1/4/4 | 4/6 | 2 | Late game. Gas‑hungry |
| Gondola car | — | 2/8 | 10 | Up layer only. Rides on cables |

- **Convoy**: up to **6 rigs**, each needing a **driver** (crew role). The *flagship* is your own rig.
- **Garage**: buy, sell or repair rigs. **Upgrades** (+1 to a stat, a new strength, removing a weakness) take workspace time (Savvyhead) or barter (the garage).

## Discovery: Sights
These are UWNH's discoveries. There are about 50 at launch, in seven categories:

| Category | Examples |
|---|---|
| **Wreck** | The *Hesper*, a whole ocean liner upright on the salt. A submarine half‑buried in a dune. |
| **Monument** | The Lighthouse's lens. The Sea Wall. A statue knee‑deep in salt. |
| **Beast** | Salt crabs the size of dogs. The last whale's bones. Glass‑eyed hounds. |
| **Growth** | A forest of drowned kelp turned to stone. Mushroom caves in the Down. |
| **Ruin** | The Fuse vault. A drowned cathedral. The stasis bunker. |
| **Grotesque** | The Breeding pit. The Choir's first hollow. |
| **Maelstrom Wonder** | **Burning Water** (an eternal oil fire). A mirage city that is always the same. The Drop's downward wind. |

A Sight pays out to the News, adds Rep, gives the Driver experience, and may open a **maelstrom site**.

## The In
**The In is the maelstrom as a place.** It's a parallel layer over the whole map, which you enter by *opening your brain* at a site, or at any time with Weird +2 or more.

- **What it looks like.** The overworld redrawn in negative: white ground, black sky, red veins where the Hum runs. Holds show up as clusters of lights (people's minds). Threats show up as shapes.
- **Moving through it.** Distance doesn't work normally. Moving between nodes costs **strain**, not supplies.
- **What you find there:**
  - **Maelstrom sites**, Inindo's mountains: each has a **weird master** who teaches a discipline (see [04](04-moves-engine.md#weird-disciplines-inindos-magic-schools-translated)). Their "training" is a short In‑dungeon plus a test move.
  - **Echoes**: things that happened at a place. Useful as rumors, and very useful as a hold's secrets.
  - **Countdown glimpses**: see the next tick of a threat's countdown.
  - **The Choir**: Hum veins lead to Harrowgate. Following them is how you find the Choir's antenna nodes.
- **Risk.** Ψ‑harm. Getting **lost** (the Director's *separate them*, inside your head). And **Hum exposure**.

### Hum exposure
A hidden 0–5 track for each character, including crew:
- **+1** for each visit to the In while the World Clock is at 9:00 or later, for each *open your brain* miss inside a Hum zone, and for each Choir move that hits you.
- **At 3**, Last can make Prophet threat moves at you *directly*: dreams, whispered commands, crew who repeat your words back to you.
- **At 5**, the "*join them*" ending options open, and crew at 5 may walk to Harrowgate on their own.
- **Lowering it**: the Static discipline, the Savvyhead's jammer, a Hocus's *Divine protection*, and time spent deaf, a whole month without entering the In.
