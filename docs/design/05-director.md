# 05 · The Director (the MC as AI)

The Director is the game's game master. It runs on Apocalypse World's MC rules, made into data and a decision procedure. There are **no random encounter tables**. Everything that happens to you is a threat acting on its impulse, or the Director making a move it has a reason for.

## Agenda (the Director's objective function)
1. **Make Apocalypse World seem real.** Be consistent: threats have locations, needs and memories.
2. **Make the player characters' lives not boring.** Pressure, stakes and change.
3. **Play to find out what happens.** No pre‑decided outcomes. Countdowns and stakes questions settle themselves through play.

## Principles (as rules in code)

| AW principle | Implementation |
|---|---|
| Barf forth apocalyptica | Every scene gets at least one sensory "flavour" line from the region's text bank (smell, sound, light, salt). |
| Address the characters, not the players | All Director text is diegetic and in second person. No UI ever says "MC move". |
| Make your move, but misdirect / never speak its name | Moves come out as *events*. "*Separate them*" shows up as "*the gantry gives way between you and Fianelly*". |
| Look through crosshairs | Every named NPC can be killed. The Director keeps an **expendable** flag and is willing to use it. |
| Name everyone, make everyone human | Every NPC the player interacts with gets a name, a look and a **want** from [13](13-content-tables.md). |
| Ask provocative questions and build on the answers | Playbook creation questions and Hx questions are saved as **facts** the Director can use later ("*Which one of you put a hand in when it mattered?*" makes that NPC an ally hook). |
| Respond with fuckery and intermittent rewards | Reward schedule: a jackpot about 1 in 6 times after soft moves, so the player never fully settles. |
| Be a fan of the players' characters | **Fan rules**: never kill without a warning move first. Never take away the playbook's signature item for good without a way back. Always offer an opportunity after a hard streak. |
| Think offscreen too | The world turn, the Wanderer AI, and the Month Report. |
| Sometimes disclaim decision‑making | Countdowns, stakes questions, **rolling for NPCs** (v‑harm, harm), and **handing choices to the player**. |

## The Director's moves
**Soft moves** are announced, give warning, and can be interrupted. **Hard moves** take effect immediately.

| AW MC move | Game expression (examples) | Soft or hard |
|---|---|---|
| Separate them | A crew member gets cut off, a rig is forced off course, the convoy is split by a storm | Either |
| Capture someone | Crew are taken (Tum Tum's raiders), the PC is held at a seat | Hard |
| Put someone in a spot | A crew member is cornered, a hold's want spikes, a gun is pointed at you | Soft |
| Trade harm for harm | The battle exchange | Hard |
| Announce off‑screen badness | "*Smoke on the horizon toward Twice*". This puts a threat on the map. | Soft |
| Announce future badness | "*The fog nets at Kettle are failing; three weeks, maybe*". This starts a countdown. | Soft |
| Inflict harm (as established) | Ambush, terrain, Ψ‑harm | Hard |
| Take away their stuff | Cargo stolen, a weapon lost, a vehicle stolen, a stash looted | Hard |
| Make them buy | A price spike, a bribe demanded, a toll | Soft |
| Activate their stuff's downside | A loud weapon draws attention, a valuable item draws thieves, Golden‑Age tech bites | Either |
| Tell them the possible consequences and ask | A confirmation card: "*If you go through the Deep Lines without light…*" | Soft |
| Offer an opportunity, with or without a cost | A wreck sighted, a recruit offers to join, a gig with strings attached | Soft |
| Turn their move back on them | A *read a person* miss means *they* read *you*. A *go aggro* miss means they call your bluff | Hard |
| Make a threat move | Picks a move from a present threat's list (below) | Either |

After every move, the game returns control with an explicit prompt: **"What do you do?"** It's the literal last line of every Director event card.

## When the Director moves
1. **The player misses**: a hard move, as hard as it likes, within the fan rules.
2. **Golden opportunity**: the player does something that sets up a move (ignoring an announced threat, idling in danger, leaving a valuable unguarded). A soft move, or hard if it was already warned.
3. **The player looks to the Director**: idle time on the road (a day ticks), waiting in a hold, or a scene stalling. A soft move.
4. **The world turn**: threat moves offscreen, which later show up as on‑screen consequences.

## Decision procedure (per trigger)
```
candidates = []
for threat in threats_near(player, ring_radius by trigger):      # map rings and octants
    for move in threat.kind.threat_moves:
        score = impulse_fit(threat, move)                          # does it serve the impulse?
              + fiction_fit(move, scene_tags)                       # possible here and now?
              + stakes_pressure(threat.countdown, threat.stakes)    # urgency
              + variety_bonus(not used recently)
              + fan_adjust(player_state)                            # see fan rules
        candidates.append((score, threat, move))
candidates += general_mc_moves(scene_tags)                          # separate them, offer an opportunity…
choose by weighted random from the top 3 (seeded, logged)
hardness = HARD if trigger in {miss, unheeded warning} else SOFT
render(move, threat, scene) → event card → "What do you do?"
```

**Fan rules (`fan_adjust`):**
- If the PC is at 9:00 or worse, harm‑inflicting moves need a soft warning first.
- After 3 hard moves in a row, boost *offer an opportunity*.
- Never pick *take away their stuff* on a playbook's signature (rig, gang, hold, followers, workspace) unless the threat's countdown has reached 9:00 or worse.
- If the last 10 rolls were all hits, boost harder moves. The Director is a fan, not a pushover.

## Threats (data model)
Each threat follows AW's threat sheet:
```yaml
id: tum_tum_raiders
name: "Tum Tum's Catchers"
kind: brute/hunting_pack           # AW: Hunting pack (to victimize anyone vulnerable)
impulse: victimize anyone vulnerable
map: { ring: closer, octant: N }  # position on the threat map; moves each world turn
cast: [ "Shan (boss, Hard+2)", "Bar (driver)", "about 12 catchers (2-harm gang small 1-armor)" ]
stakes:
  - "Will Tum Tum take Saltlick's debtors?"
  - "Will the Lighthouse stay neutral?"
countdown:                          # each tick fires its line; 12:00 = resolved
  "3:00": "Catchers seen on the Fifty‑Five, coming down from the Seventy."
  "6:00": "A straggler camp at an off‑ramp vanishes. Tracks lead north."
  "9:00": "Catchers raid Saltlick's outworks."
  "10:00": "Ula sells debtors to Tum Tum to keep the peace."
  "11:00": "Catchers take the Saltlick barns."
  "12:00": "Saltlick becomes a slave pen. Lean: Tum Tum."
connected: [ tum_tum, saltlick_debt ]
custom_moves: []
```

**Threat kinds and impulses** (all from AW):
- **Warlords**: Slaver, Hive queen, Prophet, Dictator, Collector, Alpha wolf.
- **Grotesques**: Cannibal, Mutant, Pain addict, Disease vector, Mindfucker, Perversion of birth.
- **Brutes**: Hunting pack, Sybarites, Enforcers, Cult, Mob, Family.
- **Afflictions**: Disease, Condition, Custom, Delusion, Sacrifice, Barrier.
- **Landscapes**: Prison, Breeding pit, Furnace, Mirage, Maze, Fortress.
- **Terrain**: precipice, wall, overhang, exposed place, shifting ground, broken ground.
- **Vehicles**: relentless, cagey, wild, ferocious, vicious, bold.

Each kind carries **its AW threat‑move list** as data. Examples:
- **Warlords**: push the battle moves, outflank someone, attack suddenly or cautiously, seize leverage, make a show of force or discipline, offer to negotiate, claim territory, buy out someone's allies, study someone and strike where they're weak.
- **Afflictions**: someone neglects duties, flies into a rage, takes self‑destructive action, approaches seeking help or comfort, withdraws, proclaims the affliction just punishment or a blessing, refuses to adapt, brings loved ones along.

### Essential threats (auto‑created, as in AW's first session)
- **Where you are** becomes a *Landscape*.
- **Your gang** (Chopper, Hardholder) becomes *Brutes* (its own internal pressure).
- **Your other important NPCs** become *Brutes*, plus a *Grotesque* and/or a *wannabe warlord*.
- **Your vehicles** become *Vehicles*, with personalities ("*a cagey bastard*").
- **Local populations** each get an *Affliction*.

## The threat map (UI)
- In the **Journal**, the Director's view is shown to the player *as rumor*: the eight octants and four rings, centred on **you**.
- Known threats appear as stencil icons with an arrow showing their direction of motion. Unknown ones appear as "?" smudges that *announce off‑screen badness* left behind.
- Countdowns appear as pie clocks next to known threats.

## The Wanderer AI (Inindo's autonomous NPCs)
Every named NPC who isn't a hold boss or warlord gets one action per world turn, from Inindo's verb set:

| Verb | Chosen when |
|---|---|
| **Move** | Their want is somewhere else |
| **Attack** | Their want is held by someone weaker |
| **Flee** | Threatened beyond their nerve |
| **Seek work** | Short on barter |
| **Work** | Employed: a gig, a crew, a gang |
| **Train** | Pursuing a discipline at a maelstrom site |
| **Wait** | Content, or stuck |
| **Meet** | Pursuing Hx with someone, the PC included |

Each NPC's **want** is one AW resource or relationship from [13](13-content-tables.md). This drives where they go and whom they join. That's how rivals turn up at the bar *the month after* you saw them on the road.

## Debugging and tuning
- The Director logs every decision (inputs, top‑3 candidates, choice, seed). A designer overlay (off in release) shows "*Director: Announce future badness ← Kettle fog nets (Affliction: Condition)*".
- **Golden tests**: fixed seeds plus scripted player inputs must produce the same event sequence, so balance changes can be compared by diffing.
