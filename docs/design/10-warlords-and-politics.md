# 10 · Warlords, Politics and the World Turn

> Inindo's lesson: *the map changes without you.* UWNH's lesson: *you can change the map without firing a shot.* Both are true here.

## The political units
- **Holds** carry **Lean** (see [07](07-economy.md#investment-and-lean-uwnhs-allegiance-aws-way)), **Walls** (armor 0–2), a **Gang** (size, harm, armor, tags), a **Boss**, and **Afflictions**.
- **Warlords** own **seats** (which can't be invested in) and command the holds that lean to them. Each has:
  - **Kind and impulse** (AW warlord types).
  - **Temperament**: Inindo's personality pairs, adapted.
  - **Grip**: Weak / Holding / Strong / Iron (Inindo's Bad / Fair / Good / Great). It sets how many actions they get each turn and how hard their holds are to flip.
  - **Lieutenants**: named NPCs with **Brawn** and **Cunning** ratings (0–100), like Inindo's officer ratings. They lead gangs and run conquered holds.
  - **Stakes questions** and a **countdown**, as AW threats.

## Temperament (Inindo's traits translated)

| Pair | Effect on AI weighting |
|---|---|
| **Stubborn / Flexible** | Stubborn warlords won't negotiate after a loss. Flexible ones make deals and flip alliances. |
| **Steady / Reckless** | Steady ones attack only with a size advantage. Reckless ones attack whenever their impulse says so. |
| **Grim / Wild** | Grim ones prefer *a show of discipline*. Wild ones prefer *a show of force* and burst violence. |
| **Hum‑touched / Deaf** | Inindo's Pro‑Nobu/Anti‑Nobu. Hum‑touched warlords trade with and ally to Last, and their holds drift toward the Hum. Deaf ones fight the Choir. |
| **Warlike / Peaceful** | Warlike ones use their monthly actions on conquest. Peaceful ones use them on economy and tribute. |

## The world turn (end of each month)
It resolves in this order, with every step logged for the Month Report:

1. **Countdowns tick**: every threat whose conditions are met advances one segment and *fires* its line.
2. **Warlord actions**: each warlord gets 1–3 actions, depending on grip, chosen by weighted AI over its impulse's threat moves:

| Action | Rule |
|---|---|
| **Claim territory** | Attack a hold. Resolved as a gang war, offscreen unless the player is there or connected. |
| **Make a show of force** | Fear rises in nearby holds, and their Lean drifts toward this warlord. |
| **Offer to negotiate** | An alliance or truce with another warlord, or an offer *to the player* (a gig or a mark). |
| **Buy out someone's allies** | Lean shifts by barter. The warlord invests, just as you do. |
| **Seize someone for leverage** | Kidnap a boss or a crew member. Becomes a rescue gig. |
| **Make a careful study** | Targets the weakest hold or **you**. Next month's attack gets +1. |
| **Demand tribute** | Leaning holds pay. A want rises if they can't. |

3. **Hold economy**: stock regenerates from surplus. Wants above 2 create or worsen **afflictions**. Category price indexes drift.
4. **Lean settles**: holds below 50 for everyone become **contested**. Warlords whose holds are contested lose grip.
5. **Wanderer AI**: every named wandering NPC takes one verb (*Move, Attack, Flee, Seek work, Work, Train, Wait, Meet*).
6. **Last's turn**: Prophet threat moves, plus the World Clock check (see [02](02-world.md#last-and-the-hum-the-campaign-antagonist)).
7. **The Month Report**: "*Meanwhile…*", in the News' voice, listing every change in a hold you know about. Fog‑hidden events show up as rumors.

**Balance targets:**
- Over 36 simulated months without the player, the Basin should keep **3 to 5 warlords alive**.
- At least **8 holds should change Lean**, but no warlord should take more than 40% of the holds.
- The World Clock should reach **9:00 between months 28 and 40**.

The [headless sim runner](../research/platform-recommendation.md#recommended-architecture) checks all of this over 200 seeds.

## The player in politics
- **Patronage**: swear to a warlord, and get their **mark** and gigs. Their enemies become your enemies. You can break the oath; Stubborn warlords remember.
- **Independence**: build your own Lean network. Once **3 or more holds lean to you**, you count as a **warlord** in the AI. Warlords target you with *make a careful study* and offer you negotiations.
- **Gigs** are posted at seats at month start (Inindo): *infiltrate, sabotage, spy, deliver, kill, broker*. The rewards are barter plus the patron's Lean, and the target's hostility.
- **Assassination and decapitation**: killing a warlord **doesn't end their faction**. The strongest lieutenant takes over. Grip drops to Weak and temperament is rerolled. Their *stakes questions* are answered.

## Warlord sheets (launch)

### Dremmer, Alpha wolf of the Teeth (W)
- **Impulse**: to hunt and dominate.
- **Temperament**: Stubborn, Reckless, Wild, Deaf, Warlike.
- **Grip**: Strong.
- **Gang**: the Teeth, large, 3‑harm, 1‑armor, savage, mobile.
- **Lieutenants**: Rufe (Brawn 72 / Cunning 40), Crine (65 / 55), Ik (58 / 30).
- **Stakes**: *Will Dremmer take the Lighthouse? Who will Dremmer bow to, if anyone?*
- **Countdown**: the Teeth move closer to the Shallows each season. **12:00** means the Lighthouse falls.

### Tum Tum, Slaver of Pellet (N)
- **Impulse**: to own and sell people.
- **Temperament**: Flexible, Steady, Grim, Hum‑touched, Peaceful (it sells to everyone).
- **Grip**: Holding.
- **Stakes**: *Will Saltlick's debtors be sold? Who is Tum Tum selling to in Harrowgate?*
- The Choir buys bodies. That's the thread connecting Tum Tum to Last.

### Rothschild, Collector of the Exchange (E)
- **Impulse**: to own.
- **Temperament**: Flexible, Steady, Grim, Deaf, Peaceful.
- **Grip**: Strong (in money).
- The Basin's lender. Collects Golden‑Age relics.
- **Stakes**: *What's in the Fuse vault? Will Rothschild own the Driver's route?*

### Grome, Dictator of Sweetwell (S)
- **Impulse**: to control.
- **Temperament**: Stubborn, Steady, Grim, Deaf, Warlike.
- **Grip**: Iron.
- Sets the water price across the Burn‑Flat.
- **Stakes**: *Will the Pumphouse run again? Will Grome let Barrow die of thirst?*

### Mother Krin, Hive queen of the Deep Lines (Down)
- **Impulse**: to consume and swarm.
- **Temperament**: Flexible, Reckless, Wild, Hum‑touched, Warlike.
- **Grip**: Holding.
- The Family grows by *taking people in*.
- **Stakes**: *Will Junction be swallowed? What does Krin hear in the dark?*

### Last, Prophet of Harrowgate (Up)
- **Impulse**: to denounce and overthrow.
- **Temperament**: Stubborn, Steady, Grim, *the Hum itself*.
- **Grip**: Iron, inside the Hum.
- Doesn't conquer by gang war until 9:00. Before that, conquers by **Lean drift** in Hum‑touched holds.
- **Stakes**: *Is Last right? Who was Last, before? Will the Choir sing at 12:00?*
