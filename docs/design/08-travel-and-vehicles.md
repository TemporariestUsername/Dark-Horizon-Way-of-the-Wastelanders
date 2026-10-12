# 08 · Travel, Vehicles and the In

## Exploration is the point
For twenty‑five years nobody drove the interstates. The Easing has opened them, so **every road on the map is a road nobody alive has driven end to end.** Exploration isn't a side activity. It's what the whole world is doing this year, and you're doing it first. This is UWNH's age of discovery, made literal.

- **Fog of war** covers everything past your starting region. Your starting playbook knows the roads around its home, and nothing else.
- **Charts are the most valuable thing you can carry.** A charted road (its breaks, crossings, holds, tolls and threats) sells to the News and to hardholders, and Rothschild pays well for exclusive charts.
- **Holds have been strangers for a generation.** Your **first arrival** at a hold is an event: a *first contact* scene at the gate. The hold doesn't know who runs the next town. You might be the first outsider anyone there has seen in years. **First contact** gives Rep and Lean you can't get any other way. It's the Driver's bread and butter.
- **Old maps lie.** Golden‑age road atlases are oddments. They show the roads as they were: right about where the interstates go, wrong about every break, bridge and town. The Quarantine reads them best.
- **The Loud has edges.** Where an interstate runs into the Loud, the howl gets louder mile by mile. Pushing in is a series of Weird checks, and it costs Grit and Hum exposure. The Driver's arc is about finding out how far the Easing goes.

## The overworld
- A **top‑down tile map** at **5 km per tile**: about 440 × 580 tiles from the Lakes to the Sierra Coast. The convoy moves as one marker along the road network, like a UWNH fleet on the sea.
- **The road network is the sea** (see [02](02-world.md#the-map-as-a-road-network)). Convoys move freely along roads and can't enter the Rough unless every rig in the convoy is off‑road capable. Fog reveals along the roads you drive.
- **One day** is about **25 tiles (125 km) on a clear interstate**. Terrain changes that:

| Terrain | Speed | Fuel | Notes |
|---|---|---|---|
| Interstate | ×1.0 | 1 can/rig/day | 5 lanes. Exposed: you're seen from far away. Breaks every 50–200 km. |
| Highway | ×0.7 | 1 | 3 lanes. Cover from the treeline. |
| Back road | ×0.5 | 1 | 1 lane. Haulers, buses and tankers make a Handling check each day. |
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
  - **a Howl**: a local flare of the old maelstrom on one stretch of road. Radios sing, compasses spin and crew hear voices. You wait it out, push through with a Weird check, or detour. This is UWNH's eerie calm, made psychic. Howls are more frequent near Hum zones, and twice as frequent once the Choir is **Spreading**.

## Supplies and attrition
Four gauges, shown for each rig and for the whole convoy:
- **Water** (casks)
- **Guzzoline** (cans)
- **Chow** (crates)
- **Ammo** (boxes)

Burn rates are in [03](03-core-loops.md#scarcity-budget-tuning-targets-for-the-slice).

**Running out:**
- **Water at 0**: every crew member loses 10% of max HP a day ("*thirst*"), and morale drops 5 a day. From day 3, hands desert.
- **Guzzoline at 0**: the rig stops. You can tow it, abandon it, or send someone walking.
- **Chow at 0**: morale drops 5 a day, and every check is −10. From day 4, hands desert.
- **Ammo at 0**: firearms and rig guns can't fire.

**Road events** are drawn from the threats actually present on that road ([05](05-events.md#how-an-event-is-chosen)). Threat kinds are AW's, used as tags:

| Event | Source threat | Fix or counter |
|---|---|---|
| **Dust storm** | Terrain/Landscape (*Furnace*) | Hunker down (lose a day), or push through with a Cool check (hard) |
| **A Howl** | Affliction (*Condition*) / the Hum | Wait it out, detour, or a Weird check to find the quiet way through |
| **Scavvers in the stores** | Brute (*Hunting pack*) | Traps (an item), or lose chow |
| **Rot** (UWNH's scurvy) | Affliction (*Disease*) | Fresh foods, a Medic, antiseptic |
| **Raiders** | Warlord/Brute | Road war, tribute, or outrun them |
| **Pileup sighted** | Opportunity | Salvage a thousand dead cars: costs time, gives loot, may be a trap |
| **Break ahead** | Terrain (*a wall*) | Detour, clear it, or squeeze a light rig through (Handling check) |
| **Crossing toll** | Warlord/Brute (*Enforcers*) | Pay, face them down (Hard check), run it (road war on a bridge), or find another crossing |
| **First contact** | Opportunity | A hold, camp or traveller that hasn't seen outsiders since the Howling |
| **Straggler camp** | Opportunity | Trade, **dig for water** (Sharp check), or **raid** (Chopper). Camps sit at off‑ramps and rest areas. |
| **A rig breaks down** | Vehicle (*its weakness*) | A Mechanic, Wrenching, or a Savvyhead |

## Vehicles (UWNH's hulls)
Rigs carry UWNH's ship statistics. Their *looks* and *weaknesses* keep AW's Driver lists as flavour, with numeric effects:

| Property | Range | Effect |
|---|---|---|
| **Frame** | bike, compact, large, battle (and a few special frames) | Base stats, crew and cargo |
| **Durability** | 60–600 | The rig's HP in road war. Repaired at garages, or in the field by a Mechanic |
| **Armor** | 0–20 | Subtracted from every hit's damage |
| **Speed** | 1–4 | Overworld speed (× 0.7 + 0.1 × Speed for the slowest rig), and lane and band moves per road‑war turn |
| **Handling** | 0–45 | Subtracted from enemy hit chance. Added to terrain and obstacle checks |
| **Ram** | 0–40 | Ramming damage |
| **Gun mounts** | 0–4 | Rig guns ([13](13-content-tables.md#weapons)). **Each needs 2 crew** to fire, like UWNH's cannons |
| **Crew** min/max | e.g. 1/1 (bike), 2/4 (compact), 4/30 (bus) | UWNH's min/max crew. Below the minimum, half Speed |
| **Cargo** | lots | UWNH's capacity. Supplies share it |
| **Strengths** (choose 1–2) | fast, rugged, aggressive, tight, huge, off‑road, responsive, uncomplaining, capacious, workhorse, easily repaired | +10% to the matching stat (e.g. *capacious*: cargo; *rugged*: Durability) |
| **Looks** (choose 1–2) | sleek, vintage, pristine, powerful, luxe, flashy, muscular, quirky, pretty, handcrafted, spikes & plates, garish | +5% on Hot checks where the rig is seen, and Rep on arrival |
| **Weakness** (choose 1–2) | slow, sloppy, lazy, loud, picky, guzzler, unreliable, rabbity, cramped, bucking, skittish | −10% to a stat, or a matching road event becomes likelier (e.g. *unreliable*: breakdowns) |
| **Hood ornament** | skull, saint, hula girl, steer horns, chrome angel, doll's head… | UWNH's figurehead: a small % bonus ([13](13-content-tables.md#hood-ornaments-uwnhs-figureheads)) |

**Frames at launch** (16, standing in for UWNH's 25 hulls):

| Frame | Durability | Armor | Speed | Handling | Ram | Guns | Crew | Cargo | Notes |
|---|---|---|---|---|---|---|---|---|---|
| Dirt bike | 60 | 0 | 4 | 30 | 0 | 0 | 1/1 | 1 | Off‑road. Scout. Chopper gangs |
| Hog | 90 | 5 | 3 | 15 | 10 | 0 | 1/2 | 2 | Chopper bike |
| Sand buggy | 100 | 0 | 4 | 30 | 10 | 1 | 1/3 | 4 | Off‑road. Fast courier |
| Compact | 120 | 5 | 3 | 30 | 10 | 1 | 2/4 | 8 | Starting Driver option |
| Pickup | 180 | 5 | 2 | 15 | 20 | 1 | 2/6 | 16 | Workhorse |
| Ute with a gun ring | 170 | 5 | 3 | 15 | 20 | 2 | 3/6 | 10 | Battle car |
| Interceptor | 140 | 5 | 4 | 45 | 10 | 1 | 1/2 | 4 | *My other car is a tank* path |
| Bus | 320 | 10 | 1 | 0 | 30 | 2 | 4/30 | 40 | Hardholder caravan, Hocus followers |
| Hauler (semi) | 360 | 10 | 2 | 0 | 30 | 2 | 2/8 | 60 | Trade backbone |
| Tanker | 340 | 10 | 1 | 0 | 30 | 1 | 2/6 | 50 water/fuel only | Grome's leash, if you can get one |
| Half‑track | 300 | 15 | 2 | 15 | 20 | 2 | 3/10 | 20 | Off‑road. The Rough and dunes |
| Battle rig | 440 | 15 | 2 | 0 | 30 | 4 | 6/20 | 30 | Mid‑game flagship |
| Land yacht | 140 | 0 | 3 | 15 | 10 | 1 | 3/12 | 25 | **Sail‑driven: no fuel on dry riverbeds, open interstate and lake ice, but needs wind.** Built at Pesca. UWNH's love letter |
| Ice skiff | 70 | 0 | 4 | 30 | 0 | 0 | 2/4 | 6 | Sail‑driven. Lake ice and riverbeds only. Fastest thing on the winter Lakes |
| Tank (ancient) | 600 | 20 | 1 | 15 | 40 | 3 | 4/6 | 2 | Late game. Gas‑hungry |
| Gondola car | 120 | 5 | — | — | — | 0 | 2/8 | 10 | Up layer only. Rides on cables |

- **Off‑road capability** works like a UWNH ship's draught. Big frames (bus, hauler, tanker, battle rig, tank) are bound to the roads. Bikes, buggies and half‑tracks can take the Rough, and any frame with the *off‑road* strength can too.
- **Convoy**: up to **6 rigs**, each needing a **driver** ([11](11-crew-and-bonds.md#officers-uwnhs-mates)). The *flagship* is your own rig.
- **Garage**: buy, sell or repair rigs. **Refits** (one stat up a step, a new strength, removing a weakness) take workspace time (Savvyhead) or barter (the garage). Each frame has a refit cap.

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
**The In is the maelstrom as a place.** It's a parallel layer over the whole map. You enter it by meditating at a maelstrom site, or anywhere once your Weird is 60 or more.

- **What it looks like.** The overworld as a fever ([14](14-art-audio-ui.md)): oversaturated magenta and gold over black, the roads warped and doubled, and violet veins where the Hum runs. Since the Easing the In is quieter and easier to walk than it has been in a generation, which is why so many people are learning disciplines this year. Holds show up as clusters of lights (people's minds). Threats show up as shapes.
- **Moving through it.** Distance doesn't work normally. Moving between nodes costs **Grit**, not supplies.
- **What you find there:**
  - **Maelstrom sites**, Inindo's mountains: each has a **weird master** who teaches a discipline (see [04](04-characters.md#disciplines-inindos-magic-schools)). Their training is a short In‑dungeon and a test battle.
  - **Echoes**: things that happened at a place. Useful as rumors, and very useful as a hold's secrets.
  - **Glimpses**: a faction's next ambition stage, or where a threat is heading next.
  - **The Choir**: Hum veins lead to Harrowgate. Following them is how you find the Choir's antenna nodes.
- **Risk.** Running out of Grit (you're thrown out, at 0 Grit and half HP), getting **lost** (an In event), and **Hum exposure**.

### Hum exposure
Each character, crew included, has a hidden **Hum exposure from 0 to 100** ([04](04-characters.md#hum-exposure)):
- **Gaining it**: days in Hum zones, In visits near Harrowgate, cantor attacks, and the Choir discipline. Weird reduces every gain.
- **At 50**, the Choir can reach you directly: dreams, whispered commands, crew who repeat your words back to you.
- **At 100**, the "*join them*" ending options open, and crew at 100 may walk to Harrowgate on their own.
- **Lowering it**: the Static discipline, the Savvyhead's jammer, a Hocus's *Divine protection*, and a whole month away from Hum zones (−5).
