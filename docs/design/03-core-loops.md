# 03 · Core Loops and Time

## Time units

| Unit | What happens | Source lineage |
|---|---|---|
| **Hour** (inside holds) | Buildings keep hours. The bar is busiest at night. Some NPCs only show up at certain times. | UWNH town clock |
| **Day** (on the road) | Each rig uses its supplies. The Director checks for road events. Harm heals or worsens. | UWNH days at sea |
| **Month** = **one AW session** | Starts with *lifestyle* and gigs posted. Ends with *session end* (Hx) and the **world turn**. | AW session + Inindo month |
| **Season** (3 months) | Weather regime: Dust season, Fog season, the Long Heat, the Still. The Teeth move camp. | Inindo seasons |
| **World Clock** | The campaign countdown to 12:00. See [02](02-world.md#last-and-the-hum-the-campaign-antagonist) | Nobunaga's advance |

A typical campaign runs **48–72 months** (4–6 in‑game years), which is about **30–45 hours** of play. That sits between Inindo's length and UWNH's.

## Loop 1: the moment (seconds)
- **On the road:** steer the convoy across the overworld grid. Watch the supply gauges (water, guzzoline, chow, ammo) and the day counter. Choose your line: salt (fast), dunes (slow, hides you), broken ground (risky), or the Deep Lines (no fuel, no light).
- **In a hold:** walk the hold (top‑down, as in UWNH's towns), talk to named NPCs and enter buildings.
- **In a scene:** an NPC, a threat or an opportunity. The player chooses a stance, which triggers a move. The dice show. The result plays out.

## Loop 2: the run (minutes)
```
 Hold ──► provision ──► the road ──► road event ──► arrive ──► sell/buy ──► invest/gig ──► (next run)
  ▲         (water, fuel,     (Director: storm,      (or don't:     (surplus/want)   (Lean, Rep,
  │          chow, ammo)       Calm, raiders,         stranded,                        Hx, jingle)
  └──────────────────────────  wreck, straggler)     ambushed)  ◄──────────────────────┘
```
**The core tension (from UWNH):** cargo space versus supply space versus crew. A bigger crew wins fights and eats more. More water means less cargo. Going farther means more profit and more risk.

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
- **The Basin's arc.** Warlords rise and fall, and holds change hands. This comes out of the simulation and isn't scripted.
- **The Hum's arc.** The World Clock. The player can push it back, but only by taking Last's stakes seriously.
- **Endings** depend on your playbook, your Lean network, the World Clock and your *answers to the stakes questions*.

## Scarcity budget (tuning targets for the slice)

| Resource | Burn | Typical stock | Days of range |
|---|---|---|---|
| Water | 1 cask per 4 crew per day | 20 casks on a mid rig | about 10 days with 8 crew |
| Guzzoline | 1 can per rig per day (salt), 2 (dunes or broken ground) | 15 cans | about 7–15 days |
| Chow | 1 crate per 6 crew per day | 10 crates | about 7 days with 8 crew |
| Ammo | Used per battle move with a *loud* or *reload* weapon | 6 boxes | about 3–6 fights |

**Rule of thumb:** a profitable crossing from the Centre to the Farther ring takes 5–8 days. You can only go out into the Notional ring with stashes laid along the way or by buying from straggler camps. This deliberately mirrors early UWNH coast‑hugging. The Driver's whole game is breaking this rule.

## Fail states (no game overs mid‑run)
- **Stranded.** Out of fuel or water, the Director offers a hard bargain: walk, signal, or make a deal with whoever's out there.
- **Broke.** Debt to Rothschild is always available, always with strings.
- **Untenable life.** Choose to come back with −1hard, come back with +1weird, change playbook (your crew remembers you), or **die**. Death can end the campaign (ironman), or you can **continue as a crew member** (from AW's "*create a second character*"), whose Hx with the dead person becomes their motivation.
- **12:00.** The campaign ends. It is an ending, not a game over.
