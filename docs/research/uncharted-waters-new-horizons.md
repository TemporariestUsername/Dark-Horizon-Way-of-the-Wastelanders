# Teardown: Uncharted Waters: New Horizons (Koei, SNES, 1994)

> Research document. It explains what the game *is* mechanically, so Dark Horizon can take its philosophy without copying its content.
> No ROM data, text dumps or assets from the game are stored in this repo.

## How this was analysed

| Method | What it gave us |
|---|---|
| **ROM header** | Internal title `NEW HORIZONS`, HiROM / FastROM (map byte `0x31`), 2 MB ROM, 32 KB battery SRAM, and a 512‑byte copier header on the supplied dump. |
| **Static text scan** | All game text is **plain ASCII and uncompressed**, so every name table and most dialogue could be found by scanning. |
| **Record decoding** | The ship-type table was decoded (25 records × 25 bytes), as were the port records (22‑byte stride, with map coordinates) and the goods, cannon, crew-role, nation, skill, figurehead and discovery tables. |
| **Headless emulation** | The snes9x libretro core was driven by scripted input. We captured the boot, character select, name entry, intro scenes, the town and the cafe. |

Confidence labels used below:
- **[ROM]**: read directly from ROM data.
- **[ROM‑text]**: inferred from in‑game text strings.
- **[Emu]**: seen while running the game in emulation.
- **[Play]**: from established knowledge of how the game plays. Not verified against code.

## 1. The one‑sentence game
You pick one of six captains, each with a personal story. Then you sail a real‑scale 1500s world, getting rich by buying cheap and selling dear. You invest that money so ports defect to your patron nation, and you discover the unknown. Every voyage is a race between how far you want to go and how much water, food and morale you can carry.

## 2. Core loops

| Loop | Length | Beats |
|---|---|---|
| **Moment** | seconds | Steer the fleet on the world map. Wind and current shape your speed, and the ships' days of supplies tick down. |
| **Voyage** | minutes | Port → provision → sail → event (storm, calm, rats, scurvy, pirates) → arrive, or fail to. |
| **Port visit** | minutes | Market (sell, then buy) → Shipyard → Cafe (rumors, crew) → Lodge (rest/info) → Guild (jobs) → Palace (rank/story) → Bank → Church / Fortune teller. |
| **Career** | hours | Fame ranks unlock story chapters. Your fleet grows from 1 ship to 10. Port allegiance shifts across the map. |

### Time model [ROM‑text][Play]
- The calendar starts in **1522** (we saw *1522 May 17* at the start of Joao's game). Inside a town a clock runs: 8:00AM → 9:00AM as you walk around, shops keep hours, and inns move you to the next morning.
- At sea, each step costs time. Days drain supplies.
- **Wages are paid monthly**: "our crew was paid %ld gold pieces in wages", "we don't have enough gold to pay our crew's wages".
- Bank loans compound at "**monthly interest rate is 10%**".
- Characters age, which you see in protagonist profiles such as "Age: 18".

## 3. Systems inventory

### 3.1 Protagonists [Play][Emu]
- There are **six** selectable captains, shown on a 3×2 portrait grid. Each one has a nation, a starting ship and a story spine. The game showed: "*Joao Franco, Age 18, son of Portugal's Duke Leon; an adventurer who travels around the world to find the secret of Atlantis.*"
- The six stories share one world. The other five captains show up as NPCs, rivals and allies, and story beats cross over (in the ending text, one character's fame "grew to legendary proportions when he reunited Raul and Joao Franco").
- **Keep:** several protagonists, each a different *career*, all in one shared world.

### 3.2 Attributes and skills [ROM]
- **Attributes** (10 words found together): Cartography, Gunnery, Accounting, Negotiation, Seamanship, Knowledge, Intuition, Courage, Swordsmanship, Charm.
- **Separate experience tracks** for navigation, trade and combat. One string reads "*%d more experience points to advance your combat skill level*".
- **Fame** is its own track, with ranks: "*you need %d more fame points to obtain the next rank*", "*Your fame as an adventurer has gone up*".
- **Keep:** separate experience tracks (**Road, Trade, Fight**) and fame (**Renown**). The 10 attributes become five, carrying Apocalypse World's names (Cool, Hard, Hot, Sharp, Weird) on a 1–100 scale, and the skills become a UWNH‑style skill list ([04](../design/04-characters.md)).

### 3.3 Fleet and ships [ROM]
**25 hull types**, with records of `name[18] id flags minCrew maxCrew(u16) capacity(u16)`:

| Range | Examples (min crew / max crew / capacity) |
|---|---|
| Small | Balsa 5/15/30 · Hansa Cog 5/20/35 · Dhow 5/15/50 · Tallette 10/15/55 |
| Mid | Caravela Latina 10/30/80 · Brigantine 15/45/120 · Pinnace 15/40/95 · Sloop 15/40/195 |
| Large | Nao 30/80/340 · Carrack 30/100/470 · Xebec 30/120/450 · Frigate 65/180/405 · Galleon 70/180/550 |
| Huge or special | Barge 120/270/610 · Full‑rigged Ship 120/300/780 · Venetian Galeass 50/320/580 · Tekkousen 80/360/660 |
| Regional | Junk, Atakabune, Kansen (East Asia) · Light Galley, La Reale (oared Mediterranean) |

More about ships:
- **Flag bits** differ by sail rig (square vs. lateen) and oar propulsion. This suggests they control which wind and propulsion model the ship uses.
- **Ship parts** [ROM]:
  - **Hull material:** Cedar, Beech, Oak, Copper, Iron.
  - **Figureheads:** Sea Horse, Commodore, Unicorn, Lion, Giant Eagle, Hero, Neptune, Dragon, Angel, Goddess. These are flavour that carries a bonus.
  - **Cannon** (8 types): Pedrero, Culverin, Demi‑culverin, Saker, Carronade, Cannon, Demi‑cannon, and others.
- **Fleet**: up to **10 ships**, each needing a captain ("Ship No. 1 … Ship No. 10").
- **Crew roles** [ROM]: Commodore, Captain, First Mate, Bookkeeper, Chief Navigator, Navigator. Mates have **wages you negotiate** ("How much will my new wages be?", "I'm not very happy with such low wages").
- **The design lesson:** crew is a resource with a floor and a ceiling. Below minimum crew the ship can't sail well, and above it you're paying wages for fighting strength. Cargo space competes with supplies.

### 3.4 Supplies and attrition [ROM‑text]
- **Water and food** are loaded per ship, in barrels:
  - "*Water is free. How many barrels should we load?*"
  - "*Food will cost us %ld gold pieces per barrel*"
  - "*We'll starve if we leave with no provisions!*"
- **Voyage events**:
  - **Storm**: "*the sky looks ominous… a storm's headed our way*", then "*somehow we weathered the storm*".
  - **Calm**: "*an eerie calm settling across the waters. Is the wind dying down?*"
  - **Rats**: "*we have rats on board!*", fixed with Rat Poison.
  - **Scurvy**: "*some men are suffering from scurvy*", fixed with Lime Juice.
  - **Storm‑calming oil**: Balm.
- **Landing at villages**: you can land, **search for water**, trade or **plunder** ("*Shall we plunder the village?*", "*The villagers counterattacked!*").
- **The design lesson:** this is the core of UWNH's tension. *Range is a resource.* That carries straight across to AW's scarcity.

### 3.5 Ports, buildings and economy [ROM][ROM‑text]
**About 130 ports**, each with world coordinates and a type byte, grouped into **13 regions**: Iberia, Northern Europe, the Mediterranean, North Africa, the Ottoman Empire, West Africa, Central America, South America, East Africa, Middle East, India, Southeast Asia, Far East.

**Buildings** [ROM]: Marketplace, Cafe, Shipyard, Harbor, Lodge, Palace, Guild, Bank, Item Shop, Church, Fortune Teller.

**Goods**: about **47 trade goods** in categories (Food, Spice, Fabric/Cloth, Gem/Jewelry, Ore, Luxury, Other). Examples:
- Clove, Pepper, Tea, Coffee, Sugar
- Silk, Velvet
- Coral, Pearl, Gold
- Iron ore, Art, Porcelain, Arms, Wood

**Prices:**
- Each port has a **price index for each category**: "*The Price Index of %s Items is %d%%*".
- **Negotiating** at the counter is possible: "*I'll lose my shirt selling at such a low price!*"
- There is a **20% tax** unless you hold a **Tax‑Free Permit** for that nation.
- [Play] Selling a lot of one good pushes its price down, and supply recovers over time.

**Investment and allegiance:**
- "*If you want to ally with a port, invest in the marketplace or shipyard in that port.*"
- "*You can't invest in %s as it's the capital of %s.*"
- [Play] Each port has an **influence share per nation**. Your investment adds to your patron's share and raises the port's economy and industry. When the share crosses a threshold, the port flips.
- **The design lesson:** money turns into territory without a single battle. This is the most important system to carry over.

**Other money sinks:**
- **Bank**: deposits, and loans at 10% a month.
- **Lodge**: port information and rest.
- **Guild**: delivery and procurement jobs ("*needs someone to buy some goods for him*").
- **Item Shop**: weapons, armor, navigation gear (Quadrant, Sextant, Theodolite, Telescope, Pocket Watch), Letters of Marque per nation, and Tax‑Free Permits per nation.

### 3.6 Exploration and discoveries [ROM]
- Discovery categories: Artifact, Monument, Exotic Animal, Plant, Ruins, Monster, Natural Wonder.
- About 45 named discoveries, such as Stonehenge, Rosetta Stone, Victoria Falls, Burning Water, Mohenjo‑Daro, Angkor Wat, Great Wall, Dodo, Passenger Pigeon and Niagara Falls.
- **Treasure maps**: you buy them, they point to a treasure, and you find it by searching at the spot.
- **Cartography**: "*Cartographers are eager to get new information… They may pay for geographical information.*" You also get rumors with coordinates ("*a village around %d%s %d%s*").
- **Keep:** discoveries as named, collectible wonders that are *worth something*, whether money, fame or story.

### 3.7 Combat [ROM‑text][Play]
- **Fleet battle**: turn‑based on a sea grid.
  - Wind direction matters.
  - Actions are cannon fire, ramming and **boarding**.
  - Crew numbers decide boarding.
- **Duel**: "*The enemy's commodore proposed a duel*" and "*Will you challenge the enemy commodore to a duel?*" A one‑on‑one sword fight can decide a whole boarding action.
- You can **flee**: "*Are you sure you want to flee?*", "*We managed to escape!*"
- The spoils are the captured ship, its cargo and fame.
- **Keep:** this becomes road war on the overworld, with UWNH's ship stats on rigs, guns that need crew, boarding resolved by crew strength, a leader duel, and capture ([09](../design/09-combat.md)).

### 3.8 Social [ROM‑text][Play]
- **Cafe**: owner, waitress, rumors and recruiting. Treating the waitress is a small relationship mechanic ("*Are you buying me the cafe's specialty?*"), and the cafe even has regional drinks such as mint tea, oolong and coconut milk.
- **Palace**: rank and titles, royal missions ("*I would like to make a treaty with England. Will you deliver…*"), and **marriage** subplots.
- **Fortune teller**: your fate ("*You have an average fortune… you are the one who carves out your destiny*").

## 4. UI and screen inventory [Emu]
1. Title screen, then New / Continue.
2. 3×2 portrait **character select**.
3. Profile card (portrait, name, age, a two‑line biography, thumbs‑up/down confirm).
4. Parchment‑frame name entry.
5. **Town**: top‑down tiles, with the year and date in the upper right and the clock in the lower right. Building signs are icons (anchor = harbor). NPCs wander.
6. **Building interiors** with a keeper portrait and parchment dialogue boxes.
7. Sea map.
8. Fleet and supply status.
9. Battle grid.
10. Duel.

All the menus are built from portrait plus parchment dialogue plus a thumbs yes/no.

## 5. Pacing observations
- Opening: about 3 minutes of authored scene, then free play in the home port.
- First voyage: the coast is safe. Range limits push you to hug the coast early.
- Mid‑game: open-ocean crossings, with the fleet as a logistics puzzle.
- Late game: allegiance wars and story chapters gated by fame.

## 6. Keep, translate or discard

> **Updated after the client's direction** that the game's mechanics follow UWNH and Inindo, with Apocalypse World supplying the classes, setting and ambiance. The verdicts below reflect that; see [01](../design/01-translation-matrix.md).

| System | Verdict | Dark Horizon form |
|---|---|---|
| 6 protagonists, intertwined stories | **Keep** | 6 launch classes (AW's playbooks) in one shared world |
| Supplies, range, sea events | **Keep (core)** | Water, guzzoline, chow and ammo; dust storms, Howls, rot, scavvers |
| Oceans and land | **Translate** | Interstates are the seas, the Rough is the land, river crossings are the straits |
| Ports with buildings | **Translate** | Holds with a market, bar, garage, infirmary, seat, congregation and brainer's room |
| Goods and regional prices | **Translate** | The Apocalypse World resource list; each hold's surplus and want set the price |
| Investment → allegiance | **Keep (core)** | Dropping jingle and working gigs shift a hold's loyalty between warlords and you |
| 25 hulls, parts, figureheads | **Keep** | Vehicle frames with Durability, Armor, Speed, Handling, Ram, gun mounts, crew and cargo; AW's looks and weaknesses as flavour; hood ornaments |
| Crew min/max, wages, mates | **Keep** | Hands with min/max per rig and morale; officers with wages and loyalty |
| Fleet battle + boarding + duel | **Keep** | Road war, boarding, a leader duel, capture |
| Discoveries and cartography | **Keep** | Golden‑age wonders, sold to the News or traded as rumors |
| 10 attributes, 3 experience tracks, fame | **Keep** | 5 attributes (AW's names), Road/Trade/Fight levels, skills, **Renown**, plus **Rep** in each hold |
| Bank with 10% monthly interest | **Keep** | The Exchange lends at 10% a month; missed payments escalate to seizure |
| Letters of Marque, tax permits | **Translate** | Warlord tokens and safe‑passage marks; raiding without one turns warlords against you |
| Marriage subplot | **Translate** | Affection and a committed partner; intimacy off‑screen, with numeric effects |
| Fortune teller | **Translate** | Discipline map actions (*Read the dust*, *Ask the dead*) and Weird officers |
