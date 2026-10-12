# 13 · Content Tables (launch seed data)

These are seed values for `/data`. The final tuning comes from the headless sim (see [15](15-roadmap.md)).

## Resources: base values (barter per lot)

| Resource | Category | Base | Notes |
|---|---|---|---|
| Drinking water | Water | 0.6 | Free at Kettle and the Pumphouse when their surplus is 3 |
| Hot water | Water | 0.3 | Luxury in the north |
| Meat | Chow | 0.8 | |
| Meat (don't ask) | Chow | 0.4 | Krin's Nest. Rep −1 if you're seen selling it |
| Salt | Chow | 0.3 | Saltlick |
| Grain | Chow | 0.7 | Corbett |
| Fresh foods | Chow | 1.2 | Spoils in 10 days |
| Preserved foods | Chow | 0.9 | |
| Guzzoline | Fuel | 0.5 | Burning Water refines it |
| Crude | Fuel | 0.2 | Must be refined |
| Batteries | Fuel | 1.5 | Golden‑Age salvage |
| Weaponry | Arms | 2.0 | |
| Ammo | Arms | 0.8 | "*Enough bullets*": cheap‑ish |
| Armor | Arms | 2.5 | |
| Medical supplies | Know‑how | 2.5 | Always wanted |
| Machinery | Know‑how | 2.0 | |
| Scrap | Know‑how | 0.3 | |
| Raw materials | Know‑how | 0.5 | |
| Hi‑tech | Know‑how | 4.0 | *valuable* |
| Books | Know‑how | 1.5 | Rothschild collects them |
| Information | Know‑how | varies | Charts, rumors |
| Drugs | Luxury | 1.8 | Rumhouse |
| Luxury goods | Luxury | 3.0 | |
| Liquor | Luxury | 1.0 | |
| Music and art | Luxury | 2.5 | Skinners. Raises a hold's morale (lowers afflictions) |
| Glass and lenses | Luxury | 1.4 | Visage |
| Livestock | Chow | 2.0 | Twice. Occupies crew |

## Weapons (AW tags)

| Weapon | Tags |
|---|---|
| Big knife | 2‑harm hand |
| Machete | 3‑harm hand messy |
| Crowbar | 2‑harm hand messy |
| Chain | 1‑harm hand area |
| Many knives | 2‑harm hand infinite |
| .38 revolver | 2‑harm close reload loud |
| 9mm | 2‑harm close loud |
| Magnum | 3‑harm close reload loud |
| Sawed‑off | 3‑harm close reload messy |
| Shotgun | 3‑harm close messy |
| SMG | 2‑harm close autofire loud |
| Assault rifle | 3‑harm close loud autofire |
| Hunting rifle | 3‑harm far loud |
| Sniper rifle | 4‑harm far hi‑tech |
| Machine gun | 3‑harm close/far area messy |
| Grenade tube | 4‑harm close area reload messy |
| Stun gun | s‑harm hand reload |
| Silencer (attachment) | hi‑tech. Removes *loud* |
| Rig gun ring (vehicle) | 3‑harm close/far area loud. Needs a gunner |
| Harpoon gun (vehicle) | 2‑harm close. Hooked: the target can't *outdistance* |

## Armor
- 1‑armor: bike leathers, an armored corset, a riot vest. Anything really.
- 2‑armor: serious body armor (riot gear, plate made from a car).

## Threat roster (examples by kind)

| Kind | Example | Where |
|---|---|---|
| Warlord / Alpha wolf | Dremmer and the Teeth | W |
| Brute / Hunting pack | Tum Tum's Catchers | N |
| Brute / Cult | The Choir's missionaries | Up, then everywhere |
| Brute / Family | Mother Krin's Family | Down |
| Brute / Mob | Anchorage's water mob | Centre |
| Brute / Enforcers | Grome's Wellguard | S |
| Brute / Sybarites | The Exchange's clients | E |
| Grotesque / Cannibal | The Salt Eaters | Closer ring, wreck fields |
| Grotesque / Mindfucker | The Choir brainer **Sings‑Back** | Up |
| Grotesque / Disease vector | **Putrid** | Barrow road |
| Grotesque / Mutant | Glass‑eyes | E |
| Affliction / Disease | Rot, salt‑lung | anywhere with want ≥2 in fresh foods or medicine |
| Affliction / Delusion | **The Hum** (hold‑level) | Spreads from Up |
| Affliction / Custom | Saltlick's debt‑bond | Centre |
| Affliction / Barrier | Grome's water price | S |
| Landscape / Mirage | The Always City | Out |
| Landscape / Maze | Junction's tunnels | Down |
| Landscape / Furnace | The Long Heat on the Burn‑Flat | S |
| Landscape / Fortress | Sweetwell | S |
| Landscape / Prison | Pellet's pens | N |
| Landscape / Breeding pit | Krin's Nest, lowest level | Down |
| Terrain | precipice (the Drop), shifting ground (dunes), broken ground (the Rag‑Wastes), exposed place (salt flat), overhang (the Skyline), wall (the Sea Wall) | — |
| Vehicle | *A relentless hauler* (Dremmer's), *a cagey tanker* (Grome's), *a vicious bastard* interceptor (bounty hunter) | — |

## Names (AW name lists plus our own, by use)
- **Hold bosses and NPCs**: Tum Tum, Gnarly, Fleece, White, Lala, Bill, Crine, Mercer, Preen, Ik, Shan, Isle, Ula, Joe's Girl, Dremmer, Balls, Amy, Rufe, Jackabacka, Ba, Mice, Dog head, Hugo, Roark, Monk, Pierre, Norvell, H, Omie Wise, Corbett, Jeanette, Rum, Peppering, Brain, Matilda, Rothschild, Partridge, Brace Win, Bar, Krin, Parcher, Millions, Grome, Foster, Mill, Newton, Tao, Missed, III, Princy, Putrid, Last, Clarion, Abondo, Mimi, Fianelly, Li, Harridan, Rice, Do, Winkle.
- **Playbook names**: from each AW playbook's name list (e.g. Driver: Lars, Bullet, Dice… from the playbook data).
- **Rule**: a name in the AW list that we've used as a **hold** (Kettle, Twice, Fuse, Visage, Pellet, Harrow…) isn't also used as a person, except where the hold is named for its boss (Gnarly, Brace Win, Corbett, Partridge, Isle, Dog head). The data validator checks this.

## NPC wants (the Wanderer AI drives these)
Taken from AW's resource list: meat, water, fuel, security, shelter, leisure, liberty, status, acclaim, loyalty, blood kin, information, drugs, medical supplies, a particular person, revenge, *to hear the Hum*, *to never hear it*.

## Sights (discovery seed list, 20 of about 50)

| Sight | Category | Where |
|---|---|---|
| The *Hesper* (an ocean liner, upright) | Wreck | Closer ring, N |
| The Lighthouse lens | Monument | Centre |
| The Sea Wall | Monument | W |
| The Always City (mirage) | Maelstrom Wonder | Out |
| Burning Water | Maelstrom Wonder | S |
| The Drop's downward wind | Maelstrom Wonder | Out |
| Salt crab warren | Beast | Centre |
| The last whale | Beast | N (Fishbone) |
| Stone kelp forest | Growth | Closer ring, S |
| Mushroom halls | Growth | Down |
| The Fuse vault | Ruin | E |
| The drowned cathedral | Ruin | Closer ring, E |
| The stasis bunker | Ruin | Down |
| The airship *Gondola* | Wreck | Up |
| The antenna graves | Ruin | Up |
| The submarine in the dune | Wreck | W |
| The Choir's first hollow | Grotesque | Up |
| Glass‑eyed hounds' den | Beast | E |
| The Pumphouse's great pump | Monument | Down |
| The *where the sea went* view | Maelstrom Wonder | Out (endgame) |

## Maelstrom sites (Inindo's mountains)
See the discipline table in [04](04-moves-engine.md#weird-disciplines-inindos-magic-schools-translated). Each site has a **weird master**, a short In‑dungeon (3–5 rooms), and a **test** (a custom move).

## Hood ornaments (UWNH's figureheads)
Skull (+1 *go aggro* from the rig), Saint (+1 *open your brain* in the rig), Chrome angel (+1 *deal with bad terrain*), Steer horns (+1 massive when ramming), Doll's head (the Director's *announce future badness* comes a day early), Hula girl (+1 Hot at holds), Antenna (hear the Hum: +1 to read a sitch in Hum zones, and +1 Hum exposure a month).

## Rumor samples (bar text bank)
- "*Grome turned away a caravan from Barrow. Said they'd brought sickness.*"
- "*Dremmer's camp moves at the turn of the season. They say it's coming toward the Lighthouse this time.*"
- "*Every radio in Wisher sings at midnight now. Nobody turns them off.*"
- "*There's a road off the edge. Gnarly's seen the map. Gnarly won't sell it.*"
- "*Tum Tum's been sending carts up the lift‑towers. Full going up. Empty coming down.*"
