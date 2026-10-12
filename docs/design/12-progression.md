# 12 · Progression

Progression works the way it did in UWNH and Inindo: **levels, numbers that grow, fame, and better ships and gear**. There are four layers:
1. **The character**: levels on three tracks, attributes, class abilities, skills and disciplines.
2. **The signature asset**: the thing your class owns.
3. **Rigs and gear**: what you drive, wield and wear.
4. **The world**: Renown, Rep, Lean, Standing and the map.

The formulas live in [`data/rules/characters.json`](../../data/rules/characters.json) and are explained in [04](04-characters.md).

## 1. Character
### Levels
- **Three tracks**, Road, Trade and Fight, each run from level **1 to 20** ([04](04-characters.md#levels-three-experience-tracks-uwnh)). XP to the next level is 100 × level^1.5.
- **Each level‑up** gives **4 attribute points**. Where they go is split between the track's weights and your class's **growth** ([06](06-playbooks.md#how-a-class-is-built)). A Driver's Road levels push Cool and Sharp hard; a Chopper's Fight levels push Hard.
- **Attributes cap at 100.** A class's "favoured" attributes grow faster, but every attribute can grow.
- **Every 3 levels** in a track gives a free **skill rank** in one of that track's skills.

### Class abilities
- Each class has **7 abilities**, which keep the names of its AW moves ([06](06-playbooks.md)). Each one unlocks at a set **level in a set track**, and has numeric effects.
- At **level 10** in the class's main track, you can learn **one ability from another class**, taught by an officer of that class with loyalty 60 or more. A second one opens at level 15.

### Skills
- Ranks 1 to 3, from level‑ups or **training at sub‑faction halls** ([04](04-characters.md#skills-uwnhs-skill-set)).
- Training is the main barter sink in the middle game: rank 3 in a skill costs 15 barter and 20 days.

### Disciplines
- Learned at **maelstrom sites** from weird masters ([04](04-characters.md#disciplines-inindos-magic-schools)). Each has three techniques that need Weird 30, 50 and 70.
- You can know any number of disciplines, but Grit is shared, so most characters lean on two.

### The pace
| Campaign month | Typical main‑track level | Typical other tracks | Skills |
|---|---|---|---|
| 1 | 1–3 | 1 | 2 starting skills at rank 1 |
| 12 | 7–9 | 3–5 | 4–5 skills, one at rank 2 |
| 36 | 12–14 | 6–9 | 6–7 skills, two at rank 3 |
| 60–96 | 16–20 | 9–13 | Most skills, three or four at rank 3 |

## 2. The signature asset
Each class's asset upgrades with **barter**, **levels** and **projects** (time in a workspace or a hold):

| Class | Asset | Upgrade path |
|---|---|---|
| Driver | The car, then a convoy | Frame swaps, +Speed/Handling/Armor/Ram, hood ornaments, **2 more cars** (*Collector*), a **battle vehicle** (*My other car is a tank*) |
| Chopper | The gang | Troops (by recruiting and Renown), arms (by buying weaponry), training (by battles and halls), gang tags (*well‑disciplined*, *mobile*, *siege*…), and later a hold of your own |
| Hardholder | The hold | Size, walls (0–2), armory (gang arms), a market, a manufactory (a new surplus good), and the **caravan network** |
| Hocus | Followers | Number of followers, devotion (0–100), and **shrines** in other holds that give Faith Lean |
| Savvyhead | The workspace | Workspace types (garage, lab, infirmary, darkroom, growing space, machinist's floor) and **projects** |
| Quarantine | Stasis | Stasis rooms (medlab, armory, sealed vault…) and **memories** unlocked |

## 3. Rigs and gear
### Rigs (UWNH's ships)
- Rigs are bought at hold garages, **captured** in road wars, or **salvaged** from wrecks and from the Down.
- Each rig has the stats in [08](08-travel-and-vehicles.md#vehicles-uwnhs-hulls): Durability, Armor, Speed, Handling, Ram, gun mounts, crew min/max and cargo.
- **Refits** at garages and Wheelwright halls raise one stat a step, for barter and days. Each frame has a refit cap.
- **Gun mounts** take rig guns ([13](13-content-tables.md#weapons)). Better guns are rarer, not just pricier: the best come from the Down, Cerro's foundries, and Burning Water.

### Personal gear (Inindo's equipment)
- **Weapons** have an Attack value, a range (melee, near or far) and an ammo use ([13](13-content-tables.md#weapons)). Better weapons have higher Attack, and tags such as *armour‑piercing*, *area* and *messy*.
- **Armour** adds to Defense: 1–5 for scavenged gear, up to 15 for serious body armour and 20+ for golden‑age plate.
- **Charms and oddments** add small % bonuses (+5% on Hot checks in the right company, +5 Luck), and they're also trade goods.

## 4. World
- **Renown** (Explorer, Trader, Raider; 0–1,000 each): who you are to the whole map. It gates recruits, faction audiences and some story beats ([04](04-characters.md#renown-and-rep-uwnhs-fame)).
- **Rep** in each hold (−3 to +5): how that hold talks about you. It sets prices (±5% a step), gigs, recruiting and the Seat. It rises with gigs, relieved wants, Sights and defending the hold, and falls with raids, broken deals and *loud* violence.
- **Lean**: territory, held through investment and the factions' engines ([07](07-economy.md#investment-and-lean-uwnhs-allegiance-aws-way)).
- **Standing** with each sub‑faction (−100 to +100): halls, services, recruits and perks ([18](18-sub-factions.md)).
- **Map knowledge**: charts and Sights. A completion journal the News buys from.
- **The Choir's reach**: how far it has spread ([17](17-factions.md#the-choir-the-nobunaga-faction)). Pushing it back is progress the whole map can see.
