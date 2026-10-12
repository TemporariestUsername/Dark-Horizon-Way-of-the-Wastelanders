# 03 · Core Loops and Time

## Time units

| Unit | What happens | Source lineage |
|---|---|---|
| **Hour** (inside holds) | Buildings keep hours. The bar is busiest at night. Some NPCs only show up at certain times. | UWNH town clock |
| **Day** (on the road) | Each rig uses its supplies. The Director checks for road events. Harm heals or worsens. | UWNH days at sea |
| **Month** = **one AW session** | Starts with *lifestyle* and gigs posted. Ends with *session end* (Hx) and the **world turn**. | AW session + Inindo month |
| **Season** (3 months) | Weather regime: spring floods (crossings close, riverbeds run), the Long Heat, storm and twister season, and winter (the Lake ice roads open). The Teeth move camp. | Inindo seasons |
| **World Clock** | The campaign countdown to 12:00. See [02](02-world.md#last-and-the-hum-the-campaign-antagonist) | Nobunaga's advance |

A typical campaign runs **60–96 months** (5–8 in‑game years), which is about **40–60 hours** of play. With 130 holds, that's closer to UWNH's length than Inindo's.

## Loop 1: the moment (seconds)
- **On the road:** steer the convoy across the overworld grid. Watch the supply gauges (water, guzzoline, chow, ammo) and the day counter. Choose your line: the interstate (fast and exposed), a highway (slower, with cover), a dry riverbed (fast for light rigs and land yachts), the Rough (off‑road frames only), or the Deep Lines (no fuel, no light, under the rivers). Plan around crossings and breaks the way UWNH captains planned around capes and straits.
- **In a hold:** walk the hold (top‑down, as in UWNH's towns), talk to named NPCs and enter buildings.
- **In a scene:** an NPC, a threat or an opportunity. The player chooses a stance, which triggers a move. The dice show. The result plays out.

## Loop 2: the run (minutes)
```
 Hold ──► provision ──► the road ──► road event ──► arrive ──► sell/buy ──► invest/gig ──► (next run)
                                                (or first contact,
                                                 charts, a Sight)
  ▲         (water, fuel,     (Director: storm,      (or don't:     (surplus/want)   (Lean, Rep,
  │          chow, ammo)       Howl, raiders,         stranded,                        Hx, jingle)
  └──────────────────────────  break, toll, camp)    ambushed)  ◄──────────────────────┘
```
**The core tension (from UWNH):** cargo space versus supply space versus crew. A bigger crew wins fights and eats more. More water means less cargo. Going farther means more profit and more risk, and **more of the unknown**: the further you drive, the more of the map is uncharted, and the more first contacts and Sights are waiting.

## Loop 3: the month, as an AW session (tens of minutes)
1. **Month opens** (the "start of session" beat):
   - **Lifestyle**: spend 1–2 barter (playbook‑specific; a hardholder's holding provides instead). If you can't or won't, the Director asks you a hard question and a consequence lands ("*your crew's grumbling*", "*you're sleeping in the rig*").
   - **Gigs posted**: notice walls and warlord seats offer this month's jobs, as in Inindo, where work is posted at month start.
   - **Rumors refresh** at bars.
   - **Playbook upkeep**: the Hardholder's surplus and want, the Chopper's gang appetite, the Hocus' followers, the Savvyhead's workspace projects.
2. **Play the month**: runs, gigs, battles, scenes. Days pass as you travel.
3. **Month closes** (the "session end" beat):
   - **Session end move**: choose a character who knows you better than they did, and they get +1 Hx with you. If several do, pick one. If no one does, pick someone who knows you *less* well than they thought: −1 Hx. Resetting Hx (at +4 back to +1, at −3 back to 0) gives experience. (In the UI, the game shows you who you spent the month with.)
   - **Harm ticks**: harm below 6:00 heals by one segment. Harm at 9:00 or worse that isn't stabilized gets worse.
   - **The world turn** (see [10](10-warlords-and-politics.md)): every warlord, threat and wanderer takes its monthly actions, countdowns tick, and Leans settle.
   - **The Month Report**: a one‑screen "*meanwhile…*" written in the News' voice, saying what happened offscreen. This is the payoff of "*think offscreen too*".

## Loop 4: the campaign (hours)
- **Your arc.** Each playbook has a 5‑act personal arc with authored beats. They trigger on a mix of Rep, Lean, world state and the World Clock. See [06](06-playbooks.md).
- **The world's arc.** Warlords rise and fall, and holds change hands. This comes out of the simulation and isn't scripted.
- **The Hum's arc.** The World Clock. The player can push it back, but only by taking Last's stakes seriously.
- **Endings** depend on your playbook, your Lean network, the World Clock and your *answers to the stakes questions*.

## Scarcity budget (tuning targets for the slice)

| Resource | Burn | Typical stock | Days of range |
|---|---|---|---|
| Water | 1 cask per 4 crew per day | 20 casks on a mid rig | about 10 days with 8 crew |
| Guzzoline | 1 can per rig per day (roads), 2 (the Rough, snow) | 15 cans | about 7–15 days |
| Chow | 1 crate per 6 crew per day | 10 crates | about 7 days with 8 crew |
| Ammo | Used per battle move with a *loud* or *reload* weapon | 6 boxes | about 3–6 fights |

**Rule of thumb:**
- A run within the Closer ring takes 3–6 days.
- A long voyage to the Lakes, the length of the Ten, or the Sierra Coast takes 12–18 days and needs resupply at holds, or stashes laid along the way.
- Pushing into the Loud needs both, plus nerve.

This deliberately mirrors early UWNH coast‑hugging: early on you stay near holds you know. The Driver's whole game is breaking this rule.

## Fail states (no game overs mid‑run)
- **Stranded.** Out of fuel or water, the Director offers a hard bargain: walk, signal, or make a deal with whoever's out there.
- **Broke.** Debt to Rothschild is always available, always with strings.
- **Untenable life.** Choose to come back with −1hard, come back with +1weird, change playbook (your crew remembers you), or **die**. If you choose death, you can **load a save**, or **continue as a crew member** (from AW's "*create a second character*"), whose Hx with the dead person becomes their motivation.
- **12:00.** The campaign ends. It is an ending, not a game over.

## Saving (client decision: a conventional save system)
- **Manual saves**: unlimited named slots. You can save anywhere *outside* a battle, an open Director event card or a dialogue.
- **Autosaves**: a rotating set of 5, taken at month start, on entering a hold, before any battle, and before you cross into the Loud or the In.
- **Quicksave and quickload**: F5 and F9 on Windows, ⌘S and ⌘L on macOS.
- **Saves are full world snapshots**: every hold, threat, countdown, wanderer, the Director's RNG state and log. Loading never re‑rolls a result you've already seen. The dice service restores its seed, so save‑scumming a single roll gives the same result. You have to make a different *choice* to get a different outcome.
- **Steam Cloud** sync, with the same save format on Windows and macOS.
- **There's no permadeath mode.** AW's weight comes from the Director's fan rules and the cost of untenable harm, not from deleting your save.
