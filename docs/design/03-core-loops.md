# 03 · Core Loops and Time

## Time units

| Unit | What happens | Source lineage |
|---|---|---|
| **Hour** (inside holds) | Buildings keep hours. The bar is busiest at night. Some NPCs only show up at certain times. | UWNH town clock |
| **Day** (on the road) | Each rig uses its supplies. The event system draws a road event. HP heals a little; morale drifts. | UWNH days at sea |
| **Month** | Starts with *lifestyle*, wages and gigs posted. Ends with the **world turn** and the Month Report. | Inindo month |
| **Season** (3 months) | Weather regime: spring floods (crossings close, riverbeds run), the Long Heat, storm and twister season, and winter (the Lake ice roads open). The Teeth move camp. | Inindo seasons |
| **The Choir's reach** | How far the Hum has spread: Whispers, Spreading, Marching, Drowning. There's no countdown. See [02](02-world.md#the-choirs-creep-no-clock) | Nobunaga's advance |

A typical campaign runs **60–96 months** (5–8 in‑game years), which is about **40–60 hours** of play. With 130 holds, that's closer to UWNH's length than Inindo's.

## Loop 1: the moment (seconds)
- **On the road:** steer the convoy across the overworld grid. Watch the supply gauges (water, guzzoline, chow, ammo) and the day counter. Choose your line: the interstate (fast and exposed), a highway (slower, with cover), a dry riverbed (fast for light rigs and land yachts), the Rough (off‑road frames only), or the Deep Lines (no fuel, no light, under the rivers). Plan around crossings and breaks the way UWNH captains planned around capes and straits.
- **In a hold:** walk the hold (top‑down, as in UWNH's towns), talk to named NPCs and enter buildings.
- **In a scene:** an NPC, a threat or an opportunity. The player picks a choice; where it's a check, the chance is shown first. The result plays out.

## Loop 2: the run (minutes)
```
 Hold ──► provision ──► the road ──► road event ──► arrive ──► sell/buy ──► invest/gig ──► (next run)
                                                (or first contact,
                                                 charts, a Sight)
  ▲         (water, fuel,     (events: storm,        (or don't:     (surplus/want)   (Lean, Rep,
  │          chow, ammo)       Howl, raiders,         stranded,                      XP, jingle)
  └──────────────────────────  break, toll, camp)    ambushed)  ◄──────────────────────┘
```
**The core tension (from UWNH):** cargo space versus supply space versus crew. A bigger crew wins fights and eats more. More water means less cargo. Going farther means more profit and more risk, and **more of the unknown**: the further you drive, the more of the map is uncharted, and the more first contacts and Sights are waiting.

## Loop 3: the month (tens of minutes)
1. **Month opens**:
   - **Lifestyle and wages**: spend 1–2 barter on yourself (a hardholder's hold provides instead), and pay officers and hands. If you can't, you're **scraping**: Hot −5 and crew morale −5 for the month, and late wages cost loyalty ([11](11-crew-and-bonds.md#wages-and-loyalty)).
   - **Gigs posted**: notice walls and warlord seats offer this month's jobs, as in Inindo, where work is posted at month start.
   - **Rumors refresh** at bars.
   - **Class upkeep**: the Hardholder's Wealth, the Chopper's gang appetite, the Hocus' followers, the Savvyhead's workspace projects.
2. **Play the month**: runs, gigs, battles, scenes. Days pass as you travel.
3. **Month closes**:
   - **Crew check**: morale and loyalty settle (pay, food, victories, wants fed or ignored). Officers below 30 loyalty may leave; hands below 30 morale desert.
   - **The world turn** (see [10](10-warlords-and-politics.md)): every faction, threat and wanderer takes its monthly actions, ambitions advance, the Hum seeps, and Leans settle.
   - **The Month Report**: a one‑screen "*meanwhile…*" written in the News' voice, saying what happened offscreen. This is the payoff of "*think offscreen too*".

## Loop 4: the campaign (hours)
- **Your arc.** Each playbook has a 5‑act personal arc with authored beats. They trigger on a mix of levels, Renown, Rep, Lean and world state, at your own pace. See [06](06-playbooks.md).
- **The world's arc.** Factions chase their ambitions and rise and fall, and holds change hands. This comes out of the simulation and isn't scripted.
- **The Hum's arc.** The Choir creeps outward, slowly, whatever you do. You can push it back, but only by taking Last seriously.
- **Endings** depend on your class, your Lean network, your choices, and the Choir's reach when your arc ends. The campaign has no forced end.

## Scarcity budget (tuning targets for the slice)

| Resource | Burn | Typical stock | Days of range |
|---|---|---|---|
| Water | 1 cask per 4 crew per day | 20 casks on a mid rig | about 10 days with 8 crew |
| Guzzoline | 1 can per rig per day (roads), 2 (the Rough, snow) | 15 cans | about 7–15 days |
| Chow | 1 crate per 6 crew per day | 10 crates | about 7 days with 8 crew |
| Ammo | Used by firearms and rig guns in battle | 6 boxes | about 3–6 fights |

**Rule of thumb:**
- A run within the Closer ring takes 3–6 days.
- A long voyage to the Lakes or the length of the Ten takes 17–20 days. The great voyage to the Sierra Coast takes more than a month. Both need resupply at holds, or stashes laid along the way ([computed travel times](08-travel-and-vehicles.md#the-overworld)).
- Pushing into the Loud needs both, plus nerve.

This deliberately mirrors early UWNH coast‑hugging: early on you stay near holds you know. The Driver's whole game is breaking this rule.

## Fail states (no game overs mid‑run)
- **Stranded.** Out of fuel or water, an event offers a way out at a price: walk, signal, or make a deal with whoever's out there.
- **Broke.** Debt to Rothschild is always available, always with strings.
- **Defeated.** If your whole party falls in battle, you're captured, robbed or left stranded, never killed ([09](09-combat.md)). There's always a way forward.
- **The Choir at Drowning.** The world is at its harshest, but the game goes on. Your arc can still end, darkly ([06](06-playbooks.md#endings-and-the-choirs-reach)).

## Saving (client decision: a conventional save system)
- **Manual saves**: unlimited named slots. You can save anywhere *outside* a battle, an open event card or a dialogue.
- **Autosaves**: a rotating set of 5, taken at month start, on entering a hold, before any battle, and before you cross into the Loud or the In.
- **Quicksave and quickload**: F5 and F9 on Windows, ⌘S and ⌘L on macOS.
- **Saves are full world snapshots**: every hold, threat, ambition, Hum level, wanderer, and the RNG state and log. Loading never re‑rolls a result you've already seen. The RNG restores its seed, so save‑scumming a single check gives the same result. You have to make a different *choice* to get a different outcome.
- **Steam Cloud** sync, with the same save format on Windows and macOS.
- **There's no permadeath mode.** The weight comes from lasting consequences (dead officers, lost rigs, Silenced holds), not from deleting your save.
