# 08 · Travel, Vehicles and the In

## Exploration is the point
For twenty‑five years nobody drove the interstates. The Easing has opened them, so **every road on the map is a road nobody alive has driven end to end.** Exploration isn't a side activity. It's what the whole world is doing this year, and you're doing it first. This is UWNH's age of discovery, made literal.

- **Fog of war** covers everything past your starting region. Your starting playbook knows the roads around its home, and nothing else.
- **Charts are the most valuable thing you can carry.** A charted road (its breaks, crossings, holds, tolls and threats) sells to the News and to hardholders, and Rothschild pays well for exclusive charts.
- **Holds have been strangers for a generation.** Your **first arrival** at a hold is an event: a *read a sitch* and a *first contact* scene. The hold doesn't know who runs the next town. You might be the first outsider anyone there has seen in years. **First contact** gives Rep and Lean you can't get any other way. It's the Driver's bread and butter.
- **Old maps lie.** Golden‑age road atlases are oddments. They show the roads as they were: right about where the interstates go, wrong about every break, bridge and town. The Quarantine reads them best.
- **The Loud has edges.** Where an interstate runs into the Loud, the howl gets louder mile by mile. Pushing in is a series of *open your brain* rolls and costs Hum exposure. The Driver's arc is about finding out how far the Easing goes.

## The overworld
- A **top‑down tile map** at **5 km per tile**: about 440 × 580 tiles from the Lakes to the Sierra Coast. The convoy moves as one marker along the road network, like a UWNH fleet on the sea.
- **The road network is the sea** (see [02](02-world.md#the-map-as-a-road-network)). Convoys move freely along roads and can't enter the Rough unless every rig in the convoy is off‑road capable. Fog reveals along the roads you drive.
- **One day** is about **25 tiles (125 km) on a clear interstate**. Terrain changes that:

| Terrain | Speed | Fuel | Notes |
|---|---|---|---|
| Interstate | ×1.0 | 1 can/rig/day | 5 lanes. Exposed: you're seen from far away. Breaks every 50–200 km. |
| Highway | ×0.7 | 1 | 3 lanes. Cover from the treeline. |
| Back road | ×0.5 | 1 | 1 lane. Haulers, buses and tankers roll *deal with bad terrain* each day. |
| Dry riverbed | ×0.9 (×1.2 for light rigs) | 1 | Land yachts sail it with no fuel when the wind blows. Flash floods in storm season. |
| The Rough | ×0.3 | 2 | **Off‑road frames only** (bikes, buggies, half‑tracks, interceptors with *off‑road*). *Deal with bad terrain* each day. |
| Break (overpass down, pileup) | impassable | — | Detour, clear it (a project), or a light rig picks a way through with *do something under fire*. |
| Crossing (bridge, dam, ferry, tunnel) | — | — | The only way over a living river. Usually a toll, sometimes a fight. Spring floods can close ferries and fords. |
| Lake ice road | ×1.2 | 1 | **Winter only** (3 months). Thin‑ice *deal with bad terrain* near the edges of the season. |
| Deep Lines (Down) | ×0.8, on foot | 0 | No light means *do something under fire* to navigate. **Goes under rivers.** |
| Harrowgate (Up) | lifts and cable | 0 | Vertical layer. Reached only through lift‑towers. |

- **Travel times**. These are computed from the built road network ([`data/world/roads.json`](../../data/world/roads.json)) at the speeds in [`data/rules/time.json`](../../data/rules/time.json), including expected detours for breaks. See [19](19-numbers-and-data.md#the-road-network).

| Route | km | Days | Crossings used |
|---|---|---|---|
| The Lighthouse → the Arch | 462 | 4.8 | the Lighthouse, the Arch |
| The Lighthouse → Strings (Nashville) | 560 | 5.4 | Shoals: the Forty's Tennessee bridge is out |
| The Lighthouse → Orleans | 718 | 8.6 | — |
| The Lighthouse → Sweetwell | 1,375 | 14.3 | the Lighthouse |
| The Lighthouse → Highwater (Toronto) | 1,721 | 17.2 | the Lighthouse, Fork, the Tunnel |
| Harrowgate → the Exchange (the length of the Ten) | 1,806 | 20.3 | Capitol |
| The Lighthouse → the Fort (Veracruz) | 3,237 | 36.8 | the Lighthouse |

  The Lakes and the length of the Ten are **long voyages** of two to three weeks. **The Sierra Coast is the great voyage**: more than a month from the Crossing down the Gulf coast and the MEX‑180. That's the map's Caribbean. You'll need resupply at holds, or stashes laid along the way.
- **Weather** follows the season and the region:
  - **dust storm** (the Rag‑Wastes, the Bravo): UWNH's storm
  - **fog bank** (the Ten, the Delta): navigation −1
  - **twister** (the Forty, the Seventy): a Terrain threat that crosses the road. Shelter in an overpass or *do something under fire*
  - **flood** (spring, along the living rivers): crossings close, and dry riverbeds run
  - **ice and snow** (the Lakes, the Seventy in winter): fuel ×1.5, and the ice roads open
  - **the Long Heat** (the south in summer): water use ×1.5
  - **a Howl**: a local flare of the old maelstrom on one stretch of road. Radios sing, compasses spin and crew hear voices. You wait it out, push through with *open your brain*, or detour. This is UWNH's eerie calm, made psychic. Howls get more frequent as the World Clock advances.

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
| **A Howl** | Affliction (*Condition*) / the Hum | Wait it out, detour, or *open your brain* to find the quiet way through |
| **Scavvers in the stores** | Brute (*Hunting pack*) | Traps (an item), or lose chow |
| **Rot** (UWNH's scurvy) | Affliction (*Disease*) | Fresh foods, an Angel, antiseptic |
| **Raiders** | Warlord/Brute | Road war, tribute, or *outdistance* |
| **Pileup sighted** | Opportunity | Salvage a thousand dead cars: costs time, gives loot, may be a trap |
| **Break ahead** | Terrain (*a wall*) | Detour, clear it, or squeeze a light rig through |
| **Crossing toll** | Warlord/Brute (*Enforcers*) | Pay, *go aggro*, run it (road war on a bridge), or find another crossing |
| **First contact** | Opportunity | A hold, camp or traveller that hasn't seen outsiders since the Howling |
| **Straggler camp** | Opportunity | Trade, **dig for water** (+sharp), or **raid** (Chopper). Camps sit at off‑ramps and rest areas. |
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
| Dirt bike | 3/2/0/0 | 1/1 | 1 | Off‑road. Scout. Chopper gangs |
| Hog | 2/1/1/1 | 1/2 | 2 | Chopper bike |
| Sand buggy | 3/2/0/1 | 1/3 | 4 | Off‑road. Fast courier |
| Compact | 2/2/1/1 | 2/4 | 8 | Starting Driver option |
| Pickup | 1/1/1/2 | 2/6 | 16 | Workhorse |
| Ute with a gun ring | 2/1/1/2 | 3/6 | 10 | Battle car |
| Interceptor | 3/3/1/1 | 1/2 | 4 | *My other car is a tank* path |
| Bus | 0/0/2/3 | 4/30 | 40 | Hardholder caravan, Hocus followers |
| Hauler (semi) | 1/0/2/3 | 2/8 | 60 | Trade backbone |
| Tanker | 0/0/2/3 | 2/6 | 50 water/fuel only | Grome's leash, if you can get one |
| Half‑track | 1/1/3/2 | 3/10 | 20 | Off‑road. The Rough and dunes |
| War rig | 1/0/3/3 | 6/20 | 30 | Mid‑game flagship |
| Land yacht | 2/1/0/1 | 3/12 | 25 | **Sail‑driven: no fuel on dry riverbeds, open interstate and lake ice, but needs wind.** Built at Pesca. UWNH's love letter |
| Ice skiff | 3/2/0/0 | 2/4 | 6 | Sail‑driven. Lake ice and riverbeds only. Fastest thing on the winter Lakes |
| Tank (ancient) | 0/1/4/4 | 4/6 | 2 | Late game. Gas‑hungry |
| Gondola car | — | 2/8 | 10 | Up layer only. Rides on cables |

- **Off‑road capability** works like a UWNH ship's draught. Big frames (bus, hauler, tanker, war rig, tank) are bound to the roads. Bikes, buggies and half‑tracks can take the Rough, and any frame with the *off‑road* strength can too.
- **Convoy**: up to **6 rigs**, each needing a **driver** (crew role). The *flagship* is your own rig.
- **Garage**: buy, sell or repair rigs. **Upgrades** (+1 to a stat, a new strength, removing a weakness) take workspace time (Savvyhead) or barter (the garage).

## Discovery: Sights
These are UWNH's discoveries: about 50 at launch, in seven categories, spread across the map so that every region has something worth driving to.

| Category | Examples |
|---|---|
| **Wreck** | The thousand‑car pileup on the Ten. An airliner on the Forty's median. A riverboat stranded on a levee. |
| **Monument** | The Arch. The Lighthouse bridge lights. The Sphere. The Parthenon (Temple). The miniature cathedrals at Abbey. |
| **Beast** | Feral cattle herds on the Thirty‑Five. River gar as long as a rig. Glass‑eyed hounds in the Glass. |
| **Growth** | The town swallowed by kudzu. The bayou cypress cathedrals. The mushroom halls in the Deep Lines. |
| **Ruin** | The Vault's inner door. The Fuse rocket garden. The stasis bunker beneath Junction. The Kingdom. |
| **Grotesque** | Krin's breeding pit. The Choir's first hollow. |
| **Maelstrom Wonder** | **Burning Water** (an eternal refinery fire). The Falls, which still fall. The Always City (a mirage on the Ten west of Last Stop). The edge of the Loud. |

A Sight pays out to the News, adds Rep, gives the Driver experience, and may open a **maelstrom site**.

## The In
**The In is the maelstrom as a place.** It's a parallel layer over the whole map, which you enter by *opening your brain* at a site, or at any time with Weird +2 or more.

- **What it looks like.** The overworld redrawn in negative: white roads, black land, red veins where the Hum runs. Since the Easing the In is quieter and easier to walk than it has been in a generation, which is why so many people are learning disciplines this year. Holds show up as clusters of lights (people's minds). Threats show up as shapes.
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
