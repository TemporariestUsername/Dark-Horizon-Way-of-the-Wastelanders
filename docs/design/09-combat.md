# 09 · Combat

There are three combat modes, all **turn‑based and formula‑driven**, in the tradition of the source games. The numbers live in [`data/rules/characters.json`](../../data/rules/characters.json) and [`data/rules/war.json`](../../data/rules/war.json). Unit stats for skirmishes and road war arrive with M2.

| Mode | Lineage | Scale | When |
|---|---|---|---|
| **Skirmish** | Inindo's grid battles | You plus up to 3 companions, against enemy groups | Hold fights, salvage dives, ambushes, boarding actions, maelstrom‑site trials |
| **Road war** | UWNH's fleet battles, boarding and duels | Up to 6 rigs a side | Raids, chases, escorts, crossing tolls run by force |
| **Gang war** | Inindo's province wars | Gangs of troops | Sieges, defending a hold, faction conquest |

## Mode 1: Skirmish (Inindo)
**Board.** A grid of about 16 × 10 tiles, with cover (+20 evasion against ranged attacks), high ground (+10 accuracy), hazards (fire, broken floor, Howl‑touched ground) and objectives.

**Lineup** (Inindo's formation screen). Before battle you place your party:
- **Front**: engages first and takes the hits.
- **Back**: ranged attackers and disciplines.
- **Flank**: moves first on turn 1.

**Turn order** is by **Speed**, highest first, re‑rolled ±10% each round. On a turn, a unit can **move** (up to 4 tiles; 2 in rubble, mud or wreckage) and then take one action:

| Action | Rule |
|---|---|
| **Attack** | Hit chance = clamp(70 + Accuracy − Evasion, 5, 95)%. Damage = Attack × (0.9–1.1) − Defense, at least 1. **Critical** (chance = Luck ÷ 4 %): ×1.5 damage. Ranged weapons have a **range** (near is 4 tiles, far is 10) and use **ammo**: a fighter carries enough for 12 attacks, then fights with fists |
| **Discipline** | Spend Grit on a technique ([04](04-characters.md#disciplines-inindos-magic-schools)) |
| **Item** | Use medicine, a stimulant, a grenade, a smoke can… |
| **Defend** | +50% Defense until your next turn. Covers an adjacent ally |
| **Talk** | Hot check against the enemy leader's nerve. Success makes them surrender, flee or parley. It doesn't work on the Opened |
| **Flee** | The party escapes if the average Speed check succeeds: chance = 50 + (party Speed − enemy Speed). Failure loses the turn |

- **Status effects**: bleeding, burning, poisoned, stunned, frightened (−20 accuracy) and **Hum‑struck** (the unit acts randomly for a turn).
- **Rout**: enemies (but never the Opened) break and flee when their leader is down and half their side is down, or when two‑thirds of their side is down. Fled enemies count as beaten.
- **At 0 HP**:
  - An enemy is down.
  - A companion is **gravely wounded**. They need Medicine or an infirmary within 3 days, or they die. They die outright only in story and boss fights.
  - **You** are knocked out. If your whole party is down, you've been **defeated**: captured, robbed or left stranded, as the story dictates. It's never a game over.
- **Injuries**: falling to 0 HP leaves an injury, −10 max HP until it heals in about 14 days, faster at an infirmary.
- **Rewards**: Fight XP (10 per enemy level), loot, barter, Rep and Renown.
- **Encounter ratings.** Every encounter is rated against a party of three at a given level, and the [battle bench](../reports/m2-battle-bench.md) checks the party's win rate: *easy* 95–100%, *fair* 75–92%, *hard* 45–70%, *boss* 30–60% ([`battle.json`](../../data/rules/battle.json)).

## Mode 2: Road war (UWNH's fleet battle)
**Board.** The road itself, as **lanes × range bands**, scrolling past:
- The lanes are 5 on an interstate, 3 on a highway, or 1 on a back road, where only the lead rigs can fight.
- The range bands are contact, close, far and gone.
- A **bridge** is 2–4 lanes with no shoulder, so a rig shoved off it goes into the river.

Obstacles are dead cars, breaks, overpass pillars, the median and pileups. Dust and fog cut ranged accuracy at far range by 15.

**Rigs** carry UWNH's ship statistics ([08](08-travel-and-vehicles.md#vehicles-uwnhs-hulls)):
- **Durability** (the rig's HP)
- **Armor** (damage reduction)
- **Speed** (lane and band moves per turn)
- **Handling** (evasion, and terrain checks)
- **Ram** (mass)
- **Gun mounts**
- **Crew**

**Each turn, each rig** gets a driver action and a gun action:

| Action | Rule |
|---|---|
| **Move** | Change lane or range band, up to Speed. Entering an obstacle takes a Handling check against the obstacle's difficulty; a failure costs Durability |
| **Fire** | Each manned gun mount fires: hit chance = clamp(65 + gunner accuracy + 10 × Gunnery rank − target Handling, 5, 95)%. Damage = gun power − target Armor. It uses ammo. **Each gun needs 2 crew** to fire, as UWNH's cannons needed their crew |
| **Ram** | Same lane, contact range. Damage to the target = Ram × (1 + speed difference) − Armor. The rammer takes half |
| **Board** | Same lane, contact range, and you're not faster than the target. It starts a **boarding fight** (below) |
| **Evade** | +30 Handling until your next turn |

**Boarding** works like UWNH's.
- Boarding strength = crew × (1 + Fight level × 0.05) × (1 + crew arms ÷ 100). Resolve rounds as a small gang war ([war.json](../../data/rules/war.json)) until one crew breaks.
- **Leader duel** (UWNH's duel): either leader can call one. It's a one‑on‑one skirmish on the rig's deck. The winner's crew takes the rig at once.
- **Capture**: a boarded rig whose crew breaks is **taken**, with its cargo, and needs a driver from your crew to bring it home. A rig at 0 Durability is **wrecked**: you can salvage it for parts and part of its cargo.

**Ending a road war:**
- Every enemy rig is taken, wrecked or fled into the "gone" band.
- Or you reach "gone" yourself, which means you've escaped.
- Losing means the raiders take cargo and maybe a rig, and you're left stranded but alive.

## Mode 3: Gang war (Inindo's province war)
This mode is used for **sieges, raids on holds, faction conquest and defending your hold**. The **M1 simulation** uses it for every conquest in the world turn.

Each side brings a **gang** of **troops**, **arms** (0–100) and **training** (0–100). The defender adds its **walls**. Each hold's gang is in [`holds.json`](../../data/world/holds.json).

```
strength = troops × (1 + arms/100) × (1 + training/100) × leader × walls
leader   = absent 0.85 · present 1.0 · the player +2% per Fight level
walls    = defender only: 1.0 / 1.25 / 1.5 for walls 0 / 1 / 2
each round, each side loses  enemy strength × 0.08 × (0.8–1.2)  troops
morale starts at 100 and drops by (losses ÷ troops) × 120; below 30 the side breaks
up to 5 rounds; the attacker must break the defender to take the hold
```

- **Tags** change the numbers:
  - *well‑disciplined*: +20 training, breaks only below 20
  - *savage*: +10 arms, −10 training
  - *mercenary*: deserts when unpaid
  - *siege* and *fire*: bonuses against walls
  - *defend‑only*: never attacks
  - **the Opened**: no morale at all
- **The breach.** Once per gang war, you can drop your party into a **skirmish** at the decisive point: the gate, the pumphouse, the leader's tent. Winning it gives your side +25% strength for the next round.
- **Outcomes** feed the world turn. The winner takes the hold (Lean 60, rules in [`lean.json`](../../data/rules/lean.json)). Losses come off both gangs, and survivors recover 15% a month.
- **Watching or skipping**: wars you're not part of resolve offscreen and appear in the Month Report.

## The Choir in battle
- **The Opened**: they never rout and can't be talked down. They're unarmored, with 60% normal HP, and there are always more of them.
- **Cantors**: they deal **Hum damage** at far range that ignores armor (8 + 30% of the cantor's Weird), and they drain 5 Grit. Any crew member with Hum exposure 50 or more resists each round with a loyalty check against 60, or turns on you for a turn.
- **Static** jams cantors. **Burn** and **Salt** break Opened lines. These are the counters to learn before Harrowgate.

## Prisoners, mercy and consequences
- **What you can do with defeated named NPCs:**
  - **release** them: Rep goes up, and sometimes they owe you
  - **ransom** them for barter
  - **recruit** them, if your Renown is high enough, or they offer: Inindo's "*I surrender!*"
  - **kill** them: fear rises in nearby holds, and their allies come looking
- **Tum Tum's market** appears in the prisoners menu as "*sell*". **Choosing it isn't allowed.** The game shows Tum Tum's offer, and the only options are to refuse it, or to refuse it *with violence*. This is a deliberate design statement.
