# 11 · Crew and Bonds

> UWNH gave you **hands** to fill a ship and **mates** with wages and loyalty. Inindo gave you **companions** recruited at inns who fought beside you. Dark Horizon uses both. Apocalypse World gives the people their *voice*: every named NPC has a name, a look and a want.

## Three layers of people

| Layer | What it is | Lineage | Numbers |
|---|---|---|---|
| **Hands** | A headcount that crews your rigs and makes up your gang | UWNH's sailors | Count, **morale** 0–100 |
| **Officers** | Named NPCs in a role on the convoy | UWNH's mates | Level, class, **wages**, **loyalty** 0–100 |
| **Party** | Up to 3 officers who fight beside you in skirmishes | Inindo's companions | Full character sheets ([04](04-characters.md)) |

You can have up to **8 officers**. Any 3 of them can be in the party, and a party member can hold an officer role at the same time.

## Hands
- **Each rig has a minimum and maximum crew** ([08](08-travel-and-vehicles.md#vehicles-uwnhs-hulls)). Below the minimum, the rig moves at half Speed and its guns can't all be manned. Each gun mount needs 2 hands to fire.
- **Hire hands** at hold bars: 1 barter buys about 5, and supply depends on the hold's size and your Rep there. Hands also come from rescued coffles, defeated gangs and straggler camps.
- **Upkeep**: hands eat and drink ([`time.json`](../../data/rules/time.json) supply burn), and draw pay of 0.5 barter a month for every 10, or a **shares** deal: 10% of cargo profit, split ([`economy.json`](../../data/rules/economy.json)).
- **Hands are your gang.** In a gang war, your troops are your hands. Their **arms** come from the weaponry in your cargo, and their **training** rises with battles won and time at a sub‑faction hall.
- Hands have no names until something happens to them. When one dies saving the convoy, or deserts with the water, the game gives them a name and a line in the Month Report.

### Crew morale
Morale is a single number from **0 to 100** for all your hands, as in UWNH.

| Raises morale | Lowers morale |
|---|---|
| Pay on time (+2 a month) and bonuses (+5 per barter shared) | Hunger or thirst (−5 a day out of chow or water) |
| A rest in a hold (+3 a day, up to 70) | Late pay (−10 a month) |
| Victories (+10), big sales (+5) | Losses in battle (−1 per hand lost) |
| A First Mate with high loyalty (+10% to every gain) | Howls, dust storms and Hum zones (−5 a day) |
| A hold that celebrates you (Rep +4 or more: +5) | Long stretches with no hold (−1 a day after 20 days) |

- **Below 30**: hands **desert** in every hold you enter (5% of them each time).
- **Below 15**: a **mutiny** event. You pay them off, face down the ringleader (a Hard check or a duel), or lose a rig and its cargo to them.
- Morale also acts as the gang's starting morale in a gang war ([`war.json`](../../data/rules/war.json)).

## Officers (UWNH's mates)
Officers are named NPCs with their own class ([06](06-playbooks.md#the-rest-of-the-roster-crew-archetypes-and-unlockable-protagonists)), attributes, levels and skills. Each one in a **role** adds their numbers to the convoy:

| Role | Effect | Uses the officer's |
|---|---|---|
| **First Mate** | Leads a second convoy when you split off. Adds 10% to every morale gain. Leads boarding if you don't | Hard, Fight level |
| **Navigator** | −1% travel time per Road level (max −15%). +1 fog‑reveal radius at Navigation rank 2 | Sharp, Navigation |
| **Quartermaster** | −1% supply burn per Trade level (max −15%). Adds Trading rank to haggling | Sharp, Trading |
| **Mechanic** | Field repair: Durability per day = 5 + Wrenching rank × 5. −10% breakdowns per rank | Wrenching |
| **Medic** | Party heals +3 HP a day per Medicine rank. Stabilises the gravely wounded | Medicine |
| **Gunner** | Each rig's gun accuracy uses the Gunner's Gunnery rank, if it's higher than yours | Cool, Gunnery |
| **Weird** | Warns of Hum zones a day ahead. Party Hum exposure gain −20%. Can use disciplines on the map | Weird, Lore |

Each **convoy rig** also needs a **driver**: any officer, or a hand (a hand drives at Driving rank 0).

### Wages and loyalty
- **Wages** are agreed when an officer joins: a monthly sum in barter, about 0.5 + 0.1 × the officer's highest level. You can haggle them down with a Hot check, but a low wage costs starting loyalty.
- **Loyalty** runs from **0 to 100** for each officer, as in UWNH:

| Raises loyalty | Lowers loyalty |
|---|---|
| Wages paid on time (+2 a month), a raise (+10) | Late wages (−5 a month) |
| Feeding their **want** (+5 to +15) | Ignoring their want for 3 months (−10) |
| Victories they fought in (+3), healing them (+5) | Being left gravely wounded (−15) |
| Gifts (+1 per barter's worth, up to +10 a month) | Acts they hate: their sub‑faction's enemies, Tum Tum's market, cruelty (−5 to −20) |
| Promotion to a better role (+5) | Being passed over for a role they wanted (−5) |

- **Wants.** Every officer has a want ([13](13-content-tables.md#npc-wants-the-wanderer-ai-drives-these)). Feed it and loyalty rises. Ignore it and they **ask**, then **demand**, then act on their own.
- **Below 30**: they may **leave** at the next hold, taking their wages owed in cargo.
- **Below 10**: they may **betray** you: sell your charts, open a gate to raiders, or make a bid to take your crew, which you answer with a Hard check, a duel or a payout. This is UWNH's mutiny, carried by one person.
- **At 80 or more**: they'll follow you anywhere. They fight harder (+5 Attack), never desert, and can be asked for a personal favour once a year.

## The party (Inindo's companions)
- Up to **3 companions** fight beside you in skirmishes ([09](09-combat.md#mode-1-skirmish-inindo)) and take part in story beats.
- Companions earn **Fight XP** in battle and **Road XP** while travelling, at 80% of your rate. They level up on their own class's growth ([12](12-progression.md)).
- You choose their gear and their Lineup position. You don't choose their disciplines: they learn what their class and their teacher allow.
- A companion at 0 HP is **gravely wounded**. They need a Medic, Medicine or an infirmary within 3 days, or they die. In ordinary fights, a party member can't die outright.

## Recruiting
- **Where**:
  - hold **bars** (UWNH's cafe, Inindo's inn)
  - straggler camps
  - defeated rivals ("*I surrender!*")
  - rescued prisoners and coffles
  - maelstrom sites (a weird master's students)
  - **sub‑faction halls**: at Standing +50, each sub‑faction offers recruits of particular classes. The Teeth have Choppers and Gunluggers, the Keepers have Angels and Hocuses, the Wheelwrights have Savvyheads ([18](18-sub-factions.md)). A sub‑faction recruit carries that sub‑faction's Standing with them, which works both ways.
- **The gate** is Inindo's ("*the more experience you have, the more likely someone will join you*") plus UWNH's fame:
  - **Your Renown** must meet the recruit's bar. Better officers want a more famous captain: a level‑10 Gunlugger won't ride for a nobody.
  - **Your Rep** in that hold sets the price, and whether they'll talk at all.
  - **Recruit chance** = clamp(30 + (your total Renown ÷ 20) − recruit level × 3 + Rep × 5 + Hot ÷ 5, 5, 95)%, shown before you ask.
  - Feeding their want there and then (a cause, a debt paid, a promise) adds to the chance. A promise becomes a small gig.
- **A first question.** On joining, each recruit asks *you* one question in their class's voice ("*Which one of you do I figure is doomed to self‑destruction?*" as the Angel asks). Your answer is remembered, sets their starting loyalty (±10), and comes back in their story beats.

## Rivals
- **Training rivals** (Inindo): wanderers on their own Train or Seek work goals ([05](05-events.md#the-wanderer-ai-inindos-autonomous-npcs)) who challenge you to a **duel** at maelstrom sites and bars. Win, and they surrender, then join, owe you, or leave with respect (+Renown). Lose, and they take something.
- **Mirror protagonists**: the other five launch classes, as named NPCs (see [06](06-playbooks.md#common-to-every-protagonist)).

## Bonds and intimacy (off‑screen)
UWNH let a captain court and marry in port. Dark Horizon keeps that idea, and keeps it adult and off‑screen.
- **Affection** is a second number, **0 to 100**, kept for officers and a few named hold NPCs. It rises with time together, gifts that match their tastes, story choices, and their want fed.
- **[Stay the night]** can appear in private scenes once affection reaches 50 and their mood and the story allow. NPCs can also *offer*.
- **Presentation**: a **cut to black**, then a short line of morning‑after prose in the class's voice. Nothing explicit, ever. With the **Intimacy** setting off, even that line is skipped. The numbers still apply.
- **Effects**: loyalty +10, and a small class flavour bonus for the next month. For example:
  - Chopper: the partner's loyalty can't fall below 50 for a month.
  - Hocus: you each get +10% on checks that help the other, even at a distance.
  - Quarantine: you learn one secret they're keeping.
  - Driver: a Cool check decides whether it's "*no big deal*". If it isn't, affection +10.
  - Hardholder: your next gift to them costs nothing.
- **A committed partner** (UWNH's marriage): at affection 90, a story beat lets you make it formal. A partner gives you a home hold where you're always welcome (Rep floor +2), and a role in your class's ending. They also become your heaviest loss if they die.
- **Hard rules**:
  - Adults only.
  - Never as a result of brainer control, threats, captivity or debt.
  - An NPC who is captive, or in Tum Tum's market, can never be an intimacy option.
  - The Hocus's *Frenzy* and the Brainer's transfixion abilities are **non‑sexual** in this game.
- **Consequences**: jealousy among officers (loyalty −5 to −15 for a rival with high affection), story hooks (someone wants them back), and real loss if they die.

## Crew death and memory
- Named officers who die are remembered: their **grave** is placed on the map, and the convoy carries a **grief** modifier for a month (morale −10, and Hot −5 for you; or Hard +5 if your class takes it that way).
- Visiting a grave restores 5 morale and lets you leave something there.
- **You can't die in an ordinary battle.** Defeat means captured, robbed or stranded ([09](09-combat.md)). Your character can die only in an ending you choose.
