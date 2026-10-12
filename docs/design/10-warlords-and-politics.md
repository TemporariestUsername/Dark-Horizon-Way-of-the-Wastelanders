# 10 · Warlords, Politics and the World Turn

> Inindo's lesson: *the map changes without you.* UWNH's lesson: *you can change the map without firing a shot.* Both are true here.
>
> This doc covers the **machinery**: warlord AI, the world turn and conquest. **Who the factions are** is in [17 · Factions](17-factions.md). **Sub‑factions** (cults, road gangs, guilds, secret societies) are in [18](18-sub-factions.md).

## The political units
- **Holds** carry **Lean** (see [07](07-economy.md#investment-and-lean-uwnhs-allegiance-aws-way)), **Walls** (0–2), a **Gang** (troops, arms 0–100, training 0–100, tags; see [09](09-combat.md#mode-3-gang-war-inindos-province-war)), a **Boss**, and **Afflictions**.
- **Factions** are each led by a **warlord** who owns a **seat** (which can't be invested in) and commands the holds that lean to the faction. Each has:
  - **Kind and drive**: AW's warlord types, used as AI weighting tags and as the writers' brief.
  - **Temperament**: Inindo's personality pairs, adapted.
  - **Grip**: Weak / Holding / Strong / Iron (Inindo's Bad / Fair / Good / Great). It sets how many actions they get each turn and how hard their holds are to flip.
  - **Lieutenants**: named NPCs with **Brawn** and **Cunning** ratings (0–100), like Inindo's officer ratings. They lead gangs and run conquered holds.
  - An **ambition**: four ordered goals the AI works toward, each with a concrete condition ([17](17-factions.md)). They appear in your journal as rumored plans, never as a clock.
  - **Open questions**: what the story wants to find out about them.
  - An **influence engine**: the faction's own way of gaining Lean each month (light, money, freight, thirst, fear, kin). See [17](17-factions.md#the-map-of-power).

## Temperament (Inindo's traits translated)

| Pair | Effect on AI weighting |
|---|---|
| **Stubborn / Flexible** | Stubborn warlords won't negotiate after a loss. Flexible ones make deals and flip alliances. |
| **Steady / Reckless** | Steady ones attack only with a size advantage. Reckless ones attack whenever their drive says so. |
| **Grim / Wild** | Grim ones prefer *a show of discipline*. Wild ones prefer *a show of force* and burst violence. |
| **Hum‑touched / Deaf** | Inindo's Pro‑Nobu/Anti‑Nobu. Hum‑touched warlords trade with and ally to Last, and their holds drift toward the Hum. Deaf ones fight the Choir. |
| **Warlike / Peaceful** | Warlike ones use their monthly actions on conquest. Peaceful ones use them on economy and tribute. |

## The world turn (end of each month)
It resolves in this order, with every step logged for the Month Report:

1. **Ambitions advance**: each faction checks the condition of its next ambition stage. A met stage fires: a Month Report line, new targets, and sometimes a war. Threats move ([05](05-events.md#how-an-event-is-chosen)).
2. **Influence engines run**: each faction applies its engine (passage, thirst, freight and winter, debt, fuel, walls). Then **sub‑faction backing** adds Presence × 0.5 to the backed faction's drift in every hold where the sub‑faction has a chapter.
3. **Warlord actions**: each faction's warlord gets 1–3 actions, depending on grip, chosen by weighted AI from this list, weighted by drive, temperament and ambition ([`factions.json`](../../data/rules/factions.json)):

| Action | Rule |
|---|---|
| **Claim territory** | Attack a hold. Resolved as a gang war, offscreen unless the player is there or connected. |
| **Make a show of force** | Fear rises in nearby holds, and their Lean drifts toward this warlord. |
| **Offer to negotiate** | An alliance or truce with another warlord, or an offer *to the player* (a gig or a mark). |
| **Buy out someone's allies** | Lean shifts by barter. The warlord invests, just as you do. |
| **Seize someone for leverage** | Kidnap a boss or a crew member. Becomes a rescue gig. |
| **Make a careful study** | Targets the weakest hold or **you**. Next month's attack gets +20% strength. |
| **Demand tribute** | Leaning holds pay. A want rises if they can't. |

4. **Hold economy**: stock regenerates from surplus. Wants above 2 create or worsen **afflictions**. Category price indexes drift.
5. **Lean settles**: holds below 50 for everyone become **contested**. Warlords whose holds are contested lose grip. **Home rule** moves 1.5 points a month from each hold's largest faction share back to independent (seats excepted), so influence has to be kept up.
6. **Sub‑factions act**: each takes one verb (Grow, Work, Raid, Preach, Hide, Strike, Back), and Turning progress rises for Hum‑touched sub‑factions ([18](18-sub-factions.md#subfactions-in-the-world-turn)).
7. **Wanderer AI**: every named wandering NPC takes one verb (*Move, Attack, Flee, Seek work, Work, Train, Wait, Meet*).
8. **The Choir's turn**: Hum seeps from Silenced holds; the Choir takes its actions (1, or 2 from **Spreading**: coffles, cantors, turning; marches from **Marching**); voices and reach update; League tension moves (see [02](02-world.md#the-choirs-creep-no-clock) and [17](17-factions.md#the-choir-the-nobunaga-faction)).
9. **The Month Report**: "*Meanwhile…*", in the News' voice, listing every change in a hold you know about. Fog‑hidden events show up as rumors.

**Balance targets:**
- Over 48 simulated months without the player, **4 to 6 of the six factions** should still be alive.
- At least **25 of the 130 holds should change Lean**, but no faction should take more than 30% of the holds.
- At least **4 sub‑factions should switch backing** at least once, so the second layer visibly moves.
- **Without the player, the Choir keeps creeping**: by month 60 it should have Silenced 11–16 holds, turned the Family and the Cross‑folk, and bought or broken Burning Water. It never stops on its own. The player is what pushes it back.
- At least **half the independents should still be independent**, so there's always territory left to win.
- The Choir should reach **Marching** (15 Silenced) **between months 60 and 84**, and no sooner than month 48 ([`choir.json`](../../data/rules/choir.json) balance targets).

The [headless sim runner](../research/platform-recommendation.md#recommended-architecture) checks all of this over 200 seeds.

## The player in politics
- **Patronage**: swear to a warlord, and get their **mark** and gigs. Their enemies become your enemies. You can break the oath; Stubborn warlords remember.
- **Independence**: build your own Lean network. Once **3 or more holds lean to you**, you count as a **warlord** in the AI. Warlords target you with *make a careful study* and offer you negotiations.
- **Gigs** are posted at seats at month start (Inindo): *infiltrate, sabotage, spy, deliver, kill, broker*. The rewards are barter plus the patron's Lean, and the target's hostility.
- **Assassination and decapitation**: killing a warlord **doesn't end their faction**. The strongest lieutenant takes over. Grip drops to Weak and temperament is rerolled. Their open questions are answered.

## Warlord sheets (launch)

### Clarion, hardholder of the Lighthouse (the Crossing)
- **Drive**: Dictator (to control), bent to *to keep everyone crossing*.
- **Temperament**: Flexible, Steady, Grim, Deaf, Peaceful.
- **Grip**: Holding.
- **Gang**: the Bridge Wardens: troops 18, arms 60, training 80, *well‑disciplined*, *defend‑only*.
- **Lieutenants**: Inch (Fork; Brawn 35 / Cunning 70), White (Weigh Station; 30 / 62, wants tolls), Line (Helena; 40 / 55).
- **Backed by**: the Keepers ([18](18-sub-factions.md#the-keepers)). Pays the Gar to stay off the river.
- **Open questions and ambition**: see [17](17-factions.md#the-lighthouse).

### Parcher, hardholder of Burning Water (the Ten)
- **Drive**: Dictator (to control), the fuel.
- **Temperament**: Stubborn, Steady, Grim, **contested Hum** (Ba's Choir trade inside), Peaceful.
- **Grip**: Strong in fuel, Weak in people.
- **Gang**: the Flare crews: troops 23, arms 80, training 60, *fire*.
- **Lieutenants**: Ba (Pitch; Brawn 45 / Cunning 74, trading with Harrowgate), Key (Spindletop; 60 / 50), Wei (Derricks; 55 / 40).
- **Raided by**: the Teeth, on the crude roads from Nodders and Derricks.
- **Open questions and ambition**: see [17](17-factions.md#burning-water).

### Tum Tum, Slaver of Pellet: the Choir's flesh trade (the Seventy)
- **Drive**: to own and sell people.
- **Temperament**: Flexible, Steady, Grim, Hum‑touched, Peaceful (it sells to everyone).
- **Grip**: Holding.
- **Reach**: slave coffles move down the Fifty‑Five from Kansas City to the Delta's farms and to Capitol on the Ten.
- **Open questions**: *Will Saltlick's debtors be sold? Who is Tum Tum selling to in Harrowgate?*
- **Part of the Choir.** The Choir buys bodies, and the coffles go down the Ten to Harrowgate. Tum Tum is the Choir's ordinary face: his holds play the Lean game like anyone else's, and he trades and negotiates (never in people with the player). He's where the Choir is most *beatable*. See [17](17-factions.md#what-makes-it-beatable).

### Rothschild, Collector of the Exchange (the Glass)
- **Drive**: to own.
- **Temperament**: Flexible, Steady, Grim, Deaf, Peaceful.
- **Grip**: Strong (in money).
- The only lender on the map. Collects Golden‑Age relics and **buys exclusive charts**: Rothschild wants to own the *roads*, not just the holds.
- **Open questions**: *What's in the Vault? Will Rothschild own the charts to the Lakes?*

### Grome, Dictator of Sweetwell (the Thirty‑Five)
- **Drive**: to control.
- **Temperament**: Stubborn, Steady, Grim, Deaf, Warlike.
- **Grip**: Iron.
- Sits on the aquifer springs and sets the water price across the southwest.
- **Open questions**: *Will the Pumphouse run again? Will Grome's tankers reach the Sierra Coast before Barrow dies of thirst? Will Grome and Abondo go to war over water?*

### Abondo, Dictator of Highwater (the Lakes)
- **Drive**: to control.
- **Temperament**: Flexible, Steady, Grim, Deaf, Peaceful.
- **Grip**: Strong.
- **Gang**: the Lakemen: troops 86, arms 70, training 80, *well‑disciplined*. They winter on the ice roads.
- **Lieutenants**: Venus (Brawn 40 / Cunning 81), Shade (55 / 60), Frost (70 / 35).
- Controls the north's fresh water and the winter ice roads. Abondo trades rather than conquers, but the *terms* are the leash.
- **Open questions**: *Will Abondo's tankers come down the Seventy? Will the Lakes close their roads to the south when the Hum comes north?*
- **Ambition**: *The tankers south*. Caravans push down the Seventy each spring, to Motor, the Loop, then the Arch. The last stage is Highwater and Sweetwell at war over the water trade.

### Otilia, hardholder of Cerro (the Bravo)
- **Drive**: Dictator (to control), through walls.
- **Temperament**: Stubborn, Steady, Grim, Deaf, Warlike (slowly).
- **Grip**: Iron.
- **Gang**: the Foundry: troops 45, arms 85, training 60, *siege*. Steel‑plated war rigs (Armor 15).
- **Lieutenants**: Abe (Desierto; Brawn 50 / Cunning 66, wants roads, not walls), Lupe (Gemela; 62 / 58), Rosa (Soto; 55 / 45).
- **Open questions and ambition**: see [17](17-factions.md#cerro).

### Last, Prophet of Harrowgate: the Choir (Up)
- **Drive**: to denounce and overthrow.
- **Temperament**: Stubborn, Steady, Grim, *the Hum itself*.
- **Grip**: doesn't apply. The Choir's actions scale with its reach: 1 a month, 2 from **Spreading**, and marches from **Marching**.
- **Doesn't play Lean.** It **Silences** holds: through Hum seep and cantors, and, once it's **Marching**, by sending the Opened. Full rules are in [17](17-factions.md#how-the-choir-breaks-the-rules).
- **Open questions**: *Is Last right? Who was Last, before? What happens if the Choir lets go?*
