# 04 · Characters, Levels and Checks

> **The split.** Apocalypse World gives Dark Horizon its **classes** (the playbooks), its **setting** and its **ambiance**. The **mechanics** come from Uncharted Waters: New Horizons and Inindo: numeric attributes, levels on separate experience tracks, hit points, skills learned and trained, fame, and formulas the player can read. Numbers live in [`data/rules/characters.json`](../../data/rules/characters.json).

## Attributes
There are five attributes, each from **1 to 100**. They keep Apocalypse World's names, which are part of the setting's voice, but they work like UWNH's attributes and Inindo's stats.

| Attribute | Governs |
|---|---|
| **Cool** | Nerve, driving, initiative, ranged accuracy |
| **Hard** | Melee, intimidation, carrying, Health |
| **Hot** | Charm, negotiation, recruiting, prices |
| **Sharp** | Navigation, trade, spotting, evasion |
| **Weird** | Disciplines, the In, resisting the Hum, Grit |

Each **class** ([06](06-playbooks.md)) sets starting values (a total of about 180) and **growth**: how its level‑ups split across the five.

## Derived stats (Inindo's character sheet)

| Stat | Formula | Notes |
|---|---|---|
| **Health** (HP) | 40 + Hard × 0.6 + Fight level × 6 | At 0 you're down (see [09](09-combat.md)) |
| **Grit** | 10 + Weird × 0.4 + Road level + Fight level | Spent on disciplines and some class abilities. Refills with rest |
| **Attack** | weapon + Hard × 0.3 (melee) or Cool × 0.3 (ranged) + Fight level | |
| **Accuracy** | Hard × 0.5 (melee) or Cool × 0.5 (ranged) + skill rank × 10 + Fight level | Against the target's Evasion |
| **Defense** | armour + Cool × 0.2 + Fight level | Subtracted from damage |
| **Speed** | 20 + Cool × 0.4 + Sharp × 0.2 − encumbrance | Turn order in battle |
| **Luck** | class luck + 1–20 | Critical hits, loot, the odd miracle |

## Levels: three experience tracks (UWNH)
UWNH kept separate levels for sailing, trade and combat. Dark Horizon does the same, with three tracks running from **level 1 to 20**:

| Track | Earned by | Raises |
|---|---|---|
| **Road** | Kilometres on uncharted road, first contacts (+60), Sights (+120), new crossings | Cool, Sharp, Weird. Driving, Navigation, Wrenching, Scouting, Lore |
| **Trade** | Profit (1 XP per barter), investment, gigs delivered | Hot, Sharp. Trading, Medicine |
| **Fight** | Enemies defeated (10 per enemy level), rigs disabled, gang wars, duels | Hard, Cool, Weird. Gunnery, Brawling |

- **XP to the next level** is 100 × level^1.5. So level 2 needs 100, level 10 needs about 3,160, and level 19 about 8,280.
- **Each level‑up** gives 4 attribute points, split by the track's weights and the class's growth.
- **Every 3 levels** in a track gives a new **skill rank** in that track.
- **Class abilities** unlock at set levels in set tracks ([06](06-playbooks.md)).

## Skills (UWNH's skill set)
Skills have ranks 1 to 3. You learn them at level‑ups, or **train them at sub‑faction halls** for barter and time (Inindo's training), once you have Standing +25 there ([18](18-sub-factions.md)).

| Skill | Effect per rank | Trained at |
|---|---|---|
| Driving | +10 handling in road war, −5% fuel | Wheelwrights, Twister Riders |
| Navigation | +1 fog‑reveal radius, −5% travel time | Keepers, the Gar |
| Wrenching | +20% field repair, −10% breakdown chance | Wheelwrights, Diggers |
| Trading | +3% sell price, +5% haggle cap | Tankermen, the Odd Lot |
| Gunnery | +10 accuracy with rig guns and firearms | The Teeth, the Whiteout |
| Brawling | +10 melee accuracy | The Teeth, the Pyramid's pit |
| Medicine | +3 HP a day healed for the party; can stabilise the gravely wounded | The Mourners, the Keepers |
| Scouting | +15% chance to spot an ambush or event a day early | Twister Riders, the Waking |
| Lore | +20% chart value; reads golden‑age tech; +10% discipline power in the In | The News, the Diggers, the Waking |

Training costs 3 barter and 5 days for rank 1, 8 barter and 10 days for rank 2, and 15 barter and 20 days for rank 3.

## Renown and Rep (UWNH's fame)
- **Renown** comes in three kinds, each from 0 to 1,000, with a title every 200:
  - **Explorer**: Sights, first contacts, charts sold.
  - **Trader**: profit, investment, gigs.
  - **Raider**: convoys taken, tribute, battles.

  Renown unlocks story beats, better recruits, and audiences with faction hardholders, as UWNH's fame gated royal audiences.
- **Rep** is how each hold sees you, from −3 to +5. It shifts prices (±5% per step), opens gigs and the Seat, and gates recruiting.

## Checks
Everything outside battle that can fail is a **check**:
- haggling
- talking a gate guard down
- a risky crossing in a flood
- spotting an ambush
- reading a golden‑age machine

The formula is:

```
chance = clamp( 50 + (attribute − difficulty) + skill rank × 10 + modifiers , 5%, 95% )
difficulty: easy 20 · fair 40 · hard 60 · brutal 80
```

- **The chance is shown before you commit**, as UWNH shows its negotiation odds and Inindo shows hit chance. The roll itself is hidden.
- **Modifiers** come from class abilities, gear, Rep, officers' skills, hood ornaments, weather and the Hum.
- **Failure has a cost, never a dead end.** It might cost a worse price, a day lost, an injury, a hostile hold, or an event ([05](05-events.md)).

## Disciplines (Inindo's magic schools)
At **maelstrom sites** ([08](08-travel-and-vehicles.md#the-in)), a weird master teaches a **discipline**:
- Each has three techniques, learned in order, which need Weird 30, 50 and 70.
- Using a technique costs **Grit**.
- Training takes days at the site, plus a test battle or ordeal in the In, like Inindo's mountain training.
- Since the Easing the In is quieter than it's been in a generation, which is why so many people are learning this year.

| Discipline | Site | Techniques (Grit) | Inindo school |
|---|---|---|---|
| **Static** | The Dishes (Up: Harrowgate) | Jam (6): stops enemy radios and cantors for 2 turns · Blind (12): a brainer loses its turn · Silence (25): no Hum gain in this hold for a month | Ninjutsu |
| **Burn** | Burning Water (the Ten) | Shimmer (5): +20 evasion · Catch (10): 15 fire damage, area · The fire remembers (22): 30 fire damage, burns for 3 turns | Fire |
| **Wind** | Last Stop (Rag‑Wastes) | Read the dust (4): forecast weather for 3 days · Turn a storm (15): end a dust storm or Howl here · Walk on wind (25): the party moves double for a battle | Sky |
| **Salt** | Saltlick (the Crossing) | Preserve (4): food doesn't spoil for a month · Still the ground (12): enemies lose a move · Turn to salt (28): petrify one enemy | Earth |
| **Mirror** | Mirror Town (the Glass) | See behind (5): reveal hidden Presence and ambushes · Double (14): a decoy draws attacks · Step through (24): teleport within a battle | Mysticism |
| **Mend** | Barrow (Sierra Coast) | Close a wound (6): heal 20 HP · Call back (18): revive a downed ally at 25% HP · Borrow a life (30): full heal, costs max HP until rested | Cures |
| **Iron** | The Teeth's pit (Rag‑Wastes) | Steady (5): +15 accuracy · No pain (12): ignore injuries for a battle · Become a weapon (22): +20 attack for 3 turns | Bukyo |
| **Lure** | Rumhouse (the Ten) | Catch an eye (4): +15% on a Hot check · Be wanted (12): an enemy won't attack you · Make them follow (25): turn one enemy for 3 turns | Magic |
| **Rot** | Krin's Nest (Down) | Spoil (5): ruin enemy supplies · Sicken (12): poison, 5 a turn · The Family's touch (24): drain 20 HP to yourself | Sorcery |
| **Echo** | Wisher (Up), Tajin (Sierra Coast) | Hear the dead (5): a rumor about this place · Ask the dead (14): reveal a hold's secret · Speak as the dead (26): +30% on a check against the living | Visions |
| **Choir** | Harrowgate (late; dangerous) | Hum (8) · Open them (20) · Join the Choir (40). Each use gives **+10 Hum exposure** | Evil |
| **Hex** | The Pumphouse (Down) | Mark (5): +15 accuracy against a target · Jinx (14): target −20 accuracy for 3 turns · Undo (26): cancel an enemy discipline | Curses |

Outside battle, some techniques are **map actions** that replace AW's augury:
- **Silence** shields a hold from the Hum.
- **See behind** reveals hidden Presence.
- **Ask the dead** uncovers a hold's secret.
- **Read the dust** forecasts the weather.

## Hum exposure
Hum exposure is a hidden **0–100** value for each character, crew included ([`choir.json`](../../data/rules/choir.json)).
- **Gaining it**: time in Hum zones, cantor attacks, In visits near Harrowgate, and the Choir discipline. Weird reduces every gain: gain × (1 − Weird/200).
- **At 50**, the Choir can reach you directly with dreams, voices and crew who repeat its words.
- **At 100**, the "*join them*" ending opens. Crew members at 100 may walk to Harrowgate on their own.
- **Lowering it**: Static, the Savvyhead's jammer, and a whole month spent away from Hum zones (−5).
