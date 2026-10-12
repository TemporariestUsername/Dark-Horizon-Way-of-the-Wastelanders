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

## Weapons
Weapons work like Inindo's equipment: an **Attack** value added to the wielder's attack ([04](04-characters.md#derived-stats-inindos-character-sheet)), a **range** (melee, near is 4 tiles, far is 10), and **ammo** per attack. AW's weapon names and tags stay as flavour, and the tags have numeric effects:
- *messy*: a critical also causes bleeding (5 a turn for 3 turns)
- *area*: hits the target and every unit next to it, at half damage
- *autofire*: 3 attacks at −15 accuracy each, 3 ammo
- *armour‑piercing* (AW's *ap*): ignores half the target's Defense or Armor
- *loud*: every enemy within 10 tiles is alerted, and the next road event near a hold is likelier to be trouble
- *reload*: after firing, it needs a turn to reload

| Weapon | Attack | Range | Ammo | Tags |
|---|---|---|---|---|
| Big knife | 12 | melee | — | |
| Machete | 18 | melee | — | messy |
| Crowbar | 14 | melee | — | messy |
| Chain | 10 | melee | — | area |
| Many knives | 12 | near (thrown) | — | never runs out |
| .38 revolver | 16 | near | 1 | reload, loud |
| 9mm | 15 | near | 1 | loud |
| Magnum | 22 | near | 1 | reload, loud |
| Sawed‑off | 24 | near (3 tiles) | 1 | reload, messy |
| Shotgun | 22 | near | 1 | messy |
| SMG | 14 | near | 3 | autofire, loud |
| Assault rifle | 20 | near/far | 1 (3 on autofire) | autofire, loud |
| Hunting rifle | 22 | far | 1 | loud |
| Sniper rifle | 30 | far | 1 | armour‑piercing. Golden‑age |
| Machine gun | 20 | near/far | 3 | area, messy |
| Grenade tube | 30 | near | 1 | area, reload, messy |
| Stun gun | 0 | melee | 1 | stuns for 1 turn, reload |
| Silencer (attachment) | — | — | — | Removes *loud*. Golden‑age |

**Rig guns** (for gun mounts; damage = gun power − target Armor, and each needs 2 crew):

| Rig gun | Power | Range | Ammo | Notes |
|---|---|---|---|---|
| Gun ring | 25 | close/far | 1 | area, loud |
| Rig machine gun | 20 | close/far | 2 | Two attacks a turn |
| Harpoon gun | 15 | close | 1 | Hooked: the target can't change range band next turn |
| Flamethrower | 18 | contact/close | 1 fuel can | Burning: 10 Durability a turn for 3 turns. Burning Water's specialty |
| Rocket rack | 45 | far | 1 (rare) | armour‑piercing. Cerro's foundries and the Down only |

**Natural weapons** (beasts and the Opened): bite 16, gore 18 (*messy*), the Opened's bare hands 16 (*messy*). A cantor's voice does Hum damage instead (see [09](09-combat.md#the-choir-in-battle)).

## Armour
Armour adds to **Defense**, which is subtracted from damage:
- **3–6**: bike leathers, an armoured corset, a riot vest. Anything really.
- **10–15**: serious body armour (riot gear, plate cut from a car).
- **18–25**: golden‑age plate. Rare, and found only in the Down, the Up and stasis vaults.

## Threat roster (examples by kind)

| Kind | Example | Where |
|---|---|---|
| Warlord / Dictator | The six faction hardholders: Clarion, Grome, Abondo, Rothschild, Parcher, Otilia ([17](17-factions.md)) | Their seats |
| Brute / Hunting pack (road gang) | Dremmer's Teeth, the Gar, the Twister Riders, the Whiteout ([18](18-sub-factions.md)) | The Rag‑Wastes, the Delta, the Forty, the Lakes |
| Brute / Hunting pack | Tum Tum's Catchers | The Seventy, down the Fifty‑Five |
| Brute / Cult | The Choir's missionaries. Turned Cross‑folk | Up, then along the Ten, then everywhere |
| Brute / Family (secret society) | Mother Krin's Family, the Odd Lot | Down, and hidden everywhere |
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
See the discipline table in [04](04-characters.md#disciplines-inindos-magic-schools). Each site has a **weird master**, a short In‑dungeon (3–5 rooms), and a **test** (a battle or an ordeal).

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
One per rig. Each gives a small, narrow bonus:

| Ornament | Bonus |
|---|---|
| Skull | +10% on Hard checks to intimidate, from the rig |
| Saint | +10% on Weird checks in the rig (Howls, the Loud) |
| Chrome angel | +10% on Handling checks against terrain and obstacles |
| Steer horns | +20% Ram damage |
| Doll's head | Warnings of trouble (raids, ambushes) come a day early |
| Hula girl | +5% on Hot checks at holds |
| Antenna | Hear the Hum: Hum zones show on the map 2 days ahead, but +2 Hum exposure a month |

## Rumor samples (bar text bank)
- "*Somebody drove the Forty all the way to Rock and back. Says there's a whole town living in an airplane on the median.*"
- "*Grome turned away a caravan from Barrow. Said they'd brought sickness.*"
- "*Dremmer's camp moves at the turn of the season. They say it's coming east along the Twenty this time.*"
- "*Every radio in Wisher sings at midnight now. Nobody turns them off.*"
- "*There's a road on Gnarly's old atlas that goes past Last Stop. Gnarly won't say where it ends.*"
- "*Tum Tum's coffles go down the Ten to Harrowgate. Full going in. Empty coming out.*"
- "*The ice roads on the Lakes opened early. Abondo's charging double to cross.*"
- "*Fork's bridge is out again. You'll have to go round by the Arch.*"
