# 13 · Content Tables (launch seed data)

These are seed values for `/data`. The final tuning comes from the headless sim (see [15](15-roadmap.md)).

## Resources: base values (barter per lot)

| Resource | Category | Base | Notes |
|---|---|---|---|
| Drinking water | Water | 0.6 | Free at Kettle, Reservoir, the Falls and Highwater when their surplus is 3 |
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
| Warlord / Alpha wolf | Dremmer and the Teeth | Rag‑Wastes, pushing east |
| Brute / Hunting pack | Tum Tum's Catchers | The Seventy, down the Fifty‑Five |
| Brute / Cult | The Choir's missionaries | Up, then along the Ten, then everywhere |
| Brute / Family | Mother Krin's Family | Down |
| Brute / Mob | Anchorage's water mob | The Crossing |
| Brute / Enforcers | Grome's Wellguard. Crossing toll‑men. | The Thirty‑Five. Every crossing |
| Brute / Sybarites | The Exchange's clients | The Glass |
| Grotesque / Cannibal | The Rest Area people | Off‑ramps on the Forty |
| Grotesque / Mindfucker | The Choir brainer **Sings‑Back** | Up |
| Grotesque / Disease vector | **Putrid** | The road to Barrow |
| Grotesque / Mutant | Glass‑eyes | The Glass |
| Affliction / Disease | Rot, river‑sick (from drinking the living rivers) | Anywhere with want ≥2 in fresh foods or medicine. River holds |
| Affliction / Delusion | **The Hum** (hold‑level) | Spreads from Up along the Ten |
| Affliction / Custom | Saltlick's debt‑bond. **Isolation**: holds that still bar their gates to all outsiders, a Howling‑era habit | The Crossing. Far holds |
| Affliction / Barrier | Grome's water price. Abondo's trade terms | The Thirty‑Five. The Lakes |
| Landscape / Mirage | The Always City | The Ten, west of Last Stop (Out) |
| Landscape / Maze | Junction's tunnels. The Spaghetti interchange | Down. The Seventy‑Five |
| Landscape / Furnace | The Long Heat on the Thirty‑Five | The Thirty‑Five, the Rag‑Wastes |
| Landscape / Fortress | Sweetwell, Highwater | Seats |
| Landscape / Prison | Pellet's pens | The Seventy |
| Landscape / Breeding pit | Krin's Nest, lowest level | Down |
| Terrain | precipice (a bridge out), wall (a break: overpass down, pileup), overhang (a sagging overpass), exposed place (open interstate), shifting ground (flood‑cut riverbed, lake ice), broken ground (the Rough) | Everywhere |
| Vehicle | *A relentless hauler* (Dremmer's), *a cagey tanker* (Grome's or Abondo's), *a vicious bastard* interceptor (a bounty hunter out of Gallows) | The roads |

## Names
- **Hold bosses** are listed in the [Gazetteer](16-gazetteer.md): one unique name per hold, from the AW name lists plus playbook name lists, and Spanish words in the same spirit for the Bravo and the Sierra Coast.
- **Other named NPCs** in the docs: Shan (Tum Tum's Catchers), Bar (a driver), Sings‑Back (the Choir), Putrid (a disease vector).
- **Rules** (checked by the data validator):
  - No two people share a name.
  - No person shares a name with a hold, except where the hold is named for its boss (Gnarly, Brace Win, Corbett, Partridge, Dog Head).

## NPC wants (the Wanderer AI drives these)
Taken from AW's resource list: meat, water, fuel, security, shelter, leisure, liberty, status, acclaim, loyalty, blood kin, information, drugs, medical supplies, a particular person, revenge, *to see what's out there now*, *to go home* (a hold they left before the Howling), *to hear the Hum*, *to never hear it*.

## Sights (discovery seed list, 20 of about 50)

| Sight | Category | Where |
|---|---|---|
| The thousand‑car pileup | Wreck | The Ten, west of Capitol |
| An airliner on the median | Wreck | The Forty, near Rock |
| The Lighthouse bridge lights | Monument | The Crossing |
| The Arch | Monument | The Seventy |
| The Sphere | Monument | The Seventy‑Five |
| The miniature cathedrals | Monument | The Sixty‑Five (Abbey) |
| The Always City (mirage) | Maelstrom Wonder | Out, west of Last Stop |
| Burning Water | Maelstrom Wonder | The Ten |
| The Falls, still falling | Maelstrom Wonder | The Lakes |
| The edge of the Loud | Maelstrom Wonder | Each Out edge (one Sight per edge) |
| Feral cattle the size of rigs | Beast | The Thirty‑Five |
| River gar as long as a rig | Beast | The Delta |
| Glass‑eyed hounds' den | Beast | The Glass |
| The town under the kudzu | Growth | The Seventy‑Five (Kudzu) |
| Mushroom halls | Growth | Down |
| The Vault's inner door | Ruin | The Sixty‑Five |
| The Fuse rocket garden | Ruin | The Sixty‑Five |
| The stasis bunker | Ruin | Down, beneath Junction |
| The airship *Gondola* | Wreck | Up |
| The Choir's first hollow | Grotesque | Up |

## Maelstrom sites (Inindo's mountains)
See the discipline table in [04](04-moves-engine.md#weird-disciplines-inindos-magic-schools-translated). Each site has a **weird master**, a short In‑dungeon (3–5 rooms), and a **test** (a custom move).

## Lookalike brands (set dressing)
**What they're for.** A brief golden‑age jolt in a ruin that's survived better than most: a sign half‑lit by a hold's generator, a mascot statue, a wrapper in a crate of oddments. They're rare, never a focus, and never a quest hook in their own right.

**Rules:**
1. **Lookalike, not pun.** Each one is a name that **sounds like a real chain that could have existed**: plain, a little bland, the way real brands are. The player should recognise the real brand from its **colours, sign shape, mascot or slogan fragment**, not from wordplay on its name. No winks, no jokes in the name itself. The humour, if any, is in where it turns up.
2. **Never the real thing.** No real name, logo, mascot or exact trade dress. The resemblance is in the palette and the silhouette, never a copy.
3. **Rare.** At most one or two per region on screen at a time, and only in **less‑rusted ruins**: mall interiors, sealed vaults, the Kingdom, the speedway, a bunker.
4. **Background, not foreground.** On signs, in item flavour text and on wrapper oddments. They're never a hold name, a faction or a warlord's symbol.
5. **No mockery of real people**, and no implied endorsement.
6. **Legal review** of the final list before content lock (a production‑risks item).

**Seed list:**

| Lookalike | Reads as (by its look, not its name) | Where it shows up |
|---|---|---|
| **McCready's** | Red and yellow, a doubled‑hump sign, "*billions served*" on a faded board | A sign over a Panhandle off‑ramp. Wrappers as worthless oddments |
| **Buckaroo's** | A giant Texas travel centre with a cartoon beaver mascot and 120 fuel pumps | Gnarly's garage is built in the shell of one. The beaver statue is now a hood ornament |
| **Everyday Mart** | A blue box store with a yellow spark, "*every day*" in the slogan | Haven's mall annex |
| **Siren Coffee** | A green round logo with a two‑tailed figure | A cup worth 1 jingle to collectors at the Exchange |
| **Glazier's** | A doughnut shop with a red "HOT NOW" light | Beale keeps the light running as a joke |
| **Griddle House** | A yellow block‑letter sign, open 24 hours | The "Griddle House index": holds say a road is safe if the Griddle House is still standing |
| **Cascade Cola** | Red, a white ribbon swoosh, a curved bottle | Bottles as oddments. A faded wall mural in Orleans |
| **Conch** | A yellow and red seashell over the pumps | Scavenged pumps at Spindletop |
| **Overland Express** | Purple and orange livery on white haulers | A dead hauler on the Forty. Its cargo is a Sight |
| **Wavelength Electronics** | A red‑lettered strip‑mall electronics store | Savvyhead salvage, at Wisher |

## Hood ornaments (UWNH's figureheads)
Skull (+1 *go aggro* from the rig), Saint (+1 *open your brain* in the rig), Chrome angel (+1 *deal with bad terrain*), Steer horns (+1 massive when ramming), Doll's head (the Director's *announce future badness* comes a day early), Hula girl (+1 Hot at holds), Antenna (hear the Hum: +1 to read a sitch in Hum zones, and +1 Hum exposure a month).

## Rumor samples (bar text bank)
- "*Somebody drove the Forty all the way to Rock and back. Says there's a whole town living in an airplane on the median.*"
- "*Grome turned away a caravan from Barrow. Said they'd brought sickness.*"
- "*Dremmer's camp moves at the turn of the season. They say it's coming east along the Twenty this time.*"
- "*Every radio in Wisher sings at midnight now. Nobody turns them off.*"
- "*There's a road on Gnarly's old atlas that goes past Last Stop. Gnarly won't say where it ends.*"
- "*Tum Tum's coffles go down the Ten to Harrowgate. Full going in. Empty coming out.*"
- "*The ice roads on the Lakes opened early. Abondo's charging double to cross.*"
- "*Fork's bridge is out again. You'll have to go round by the Arch.*"
