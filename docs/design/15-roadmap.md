# 15 · Roadmap, Vertical Slice and Open Questions

## Milestones

| # | Milestone | Proves | Contents |
|---|---|---|---|
| **M0** | **Design bible** ✅ | Direction | These docs, the RE teardowns, the platform pick |
| **M0.5** | **M1 data prerequisites** ✅ | The rules are concrete enough to simulate | The road network (Natural Earth), economic profiles for all 130 holds, the rules as numbers, time pacing, a validator. See [19](19-numbers-and-data.md) |
| **M1** | **Sim spike** (headless, Godot 4) ✅ | The economy and politics work *without* graphics, at full scale. Every balance target passes ([report](../reports/m1-balance-report.md), [findings](19-numbers-and-data.md#what-m1-found)) | The character and check formulas, a seeded RNG service, the road graph, all 130 holds' economy, Lean, the 6 factions' ambitions and engines, gang war, the Choir's spread, the world turn, a 48‑month sim runner, a balance report |
| **M2** | **Battle and event prototype** (in progress: class, unit and equipment data ✅, skirmish ✅, road war ✅ ([bench](../reports/m2-battle-bench.md)); events next) | The fights and the events are fun and fair | Skirmish and road war with placeholder art, unit and class data, threats as data, event cards in a text UI, golden tests |
| **M3** | **Vertical slice** | The full loop, at quality, for about 2 hours | Defined below |
| **M4** | **Alpha** | The whole map (130 holds) and all six playbooks | All regions, holds, factions, the Choir's creep, Up, Down and In |
| **M5** | **Beta / content lock** | Endings, balance, polish | All endings, the Month Report text bank, localization pass |
| **M6** | **Launch**: Windows and macOS (Steam; GOG and itch.io optional) | — | — |
| post | **v1.1–1.2** | Roster | Angel, Battlebabe, Gunlugger, then Brainer, Maestro D', Skinner as protagonists |

## The vertical slice (M3)
- **Class**: the **Driver** only. It touches the most systems (travel, trade, road war, discovery).
- **Region**: the Crossing, the Delta and the east end of the Ten, so the slice has a living river (the Mississippi), four crossings, interstate, highway, back roads and a dry riverbed (**14 holds**):
  - the Crossing: the Lighthouse, Anchorage, Saltlick, Gnarly, Pyramid, Beale
  - the Delta: Siege, Brace Win, Barge Town, Mudflat, Reservoir
  - the Ten: Capitol, Orleans, Dustwich
- **Fog**: everything outside the Crossing starts uncharted, so every Delta and Ten hold is a **first contact**.
- **Factions**: **the Lighthouse** (Clarion, the player's likely first patron) and **the Choir**, whose Catchers come down the Fifty‑Five through Tum Tum's Mudflat and Capitol. One Delta hold is **Silenced** during the slice, so playtesters see the difference between losing a hold to Lean and losing it to the Choir. Brace Win is an independent minor warlord holding the dam.
- **Sub‑factions**: **the Keepers** (who back the Lighthouse), **the Gar** (Delta river raiders whom Clarion pays off), and **the Players** (Beale, Crossroads, Orleans). That's enough to show Standing, chapters and a sub‑faction switching its backing. The Choir's seep runs at 3× speed in the slice, so playtesters watch a hold go from Touched to Marked to Silenced.
- **Systems in**:
  - Overworld road network with supplies, fog, charts, breaks, crossings, weather and Howls
  - First contact scenes
  - Hold walking, the market, the bar, the garage and the notice wall
  - Checks with shown chances, in dialogue and events
  - **Road war** (full)
  - **Skirmish** (basic: the 6 core actions)
  - Lean and investment
  - The world turn and the Month Report
  - Hands and morale, and up to 4 officers (Navigator, Medic, Gunner, Mechanic) with wages and loyalty
  - Road, Trade and Fight levels, and the Driver's first four abilities
  - 6 Sights
  - 1 maelstrom site with 1 discipline (Salt, at Saltlick)
  - The save system (manual, auto, quick)
- **Systems out**: gang war, the Up and Down layers, the In beyond one site, the other 5 classes, endings.
- **The slice is a success when** playtesters can tell, unprompted:
  1. why a check had the chance it did
  2. why they ran out of water
  3. which roads they've charted and where the river can be crossed
  4. why the Choir is scarier than any other faction
  5. that a hold changed hands *without them*
  6. who Last is, or what they think Last is

## Production risks

| Risk | Mitigation |
|---|---|
| **Events feel random** | Threats as data on the map, golden tests, the designer overlay, the [anti‑frustration rules](05-events.md#antifrustration-rules), and threats visible in the journal |
| **The Choir feels like background, not a threat** | It's always on the Month Report, its spread is visible on the map as colour drains away, Marked holds get a month's warning, and the sim targets in [`choir.json`](../../data/rules/choir.json) keep it creeping but never stalled |
| **The economy breaks** (runaway money, dead markets) | Saturation, monthly lifestyle drain, the headless sim with 200‑seed balance reports in CI |
| **Text volume** (AW's voice is the game) | A text‑bank pipeline with tags (region, threat, event, outcome). A writers' style guide built from the AW playbook voice, including the [southern voice guide](02-world.md#voice-the-bravo-and-the-sierra-coast). A Spanish‑fluent writer or sensitivity reader for the southern text bank |
| **Licensing scope** | **Confirmed by the client.** The license covers this video game. AW text is still kept in `/data` so it's easy to audit |
| **Mature content and ratings** | The content policy in [00](00-vision.md#tone-and-content-policy), content toggles, and an early ESRB/PEGI/IARC questionnaire |
| **Real‑world geography and lookalike brands** | Real geography and real interstate numbers are used (client decision). Holds use survivor names, and real place names appear through the Quarantine. Lookalike brands are rare set dressing under strict rules ([13](13-content-tables.md#lookalike-brands-set-dressing)): never real names, logos or trade dress. **Legal review of the lookalike list before content lock.** |
| **Map scale** (130 holds) | The headless sim tests all 130 from M1. Hold tiers (outposts are cheap) keep content cost down. Regions are authored in priority order: the slice region first, the Loud edges last |
| **macOS distribution without an Apple Developer account** | Builds are **ad‑hoc signed** (required on Apple Silicon) and **not notarized**. Steam installs run normally. Direct‑download testers allow the app once (*Privacy & Security → Open Anyway*). Universal (Apple Silicon + Intel) builds; test on a low‑end MacBook Air. See the [platform recommendation](../research/platform-recommendation.md#macos-without-an-apple-developer-account) |
| **Mad Max as visual inspiration** | Inspired by, never copied: no replicas of the films' vehicles, masks, costumes or rituals, and no quotes. An art‑review check on every vehicle and costume ([14](14-art-audio-ui.md#ip-guardrail)) |
| **Source‑game IP** | We take *philosophy*, not content. No Koei names, maps, text, art or music. The RE notes stay internal, and ROMs are never committed |

## Client decisions (resolved)

| # | Question | Decision | Where it's reflected |
|---|---|---|---|
| 1 | AW license covers a video game | **Yes** | Risks table |
| 2 | Co‑op | **No. Single‑player only** | [00](00-vision.md#non-goals) |
| 3 | Permadeath or saves | **A conventional save system** | [03](03-core-loops.md#saving-client-decision-a-conventional-save-system) |
| 4 | Map scale | **About 130 holds** across a smaller area: a portion of the former US, Canada and Mexico | [02](02-world.md), [16](16-gazetteer.md) |
| 5 | Platforms | **Windows and macOS only** | [Platform recommendation](../research/platform-recommendation.md) |
| 6 | Travel model | **Interstates are the seas**, dry riverbeds are extra roads, living rivers are barriers, and **the Easing** makes exploration the heart of the game | [02](02-world.md#the-map-as-a-road-network), [08](08-travel-and-vehicles.md) |
| 7 | The drained Gulf | **Dropped.** The Gulf stays as water at the map's edge | [02](02-world.md) |
| 8 | Spanish | **Spanish‑inflected dialogue** along the Bravo and the Sierra Coast, without drifting from apocalyptica. UI and ability names stay in English | [02](02-world.md#voice-the-bravo-and-the-sierra-coast) |
| 9 | Real geography and brands | **Real interstate numbers and real geography.** Brands are rare set dressing in less‑rusted ruins, as **lookalikes**: plausible chain names recognisable by look, not puns (*McCready's*, *Buckaroo's*) | [02](02-world.md#naming-rules), [13](13-content-tables.md#lookalike-brands-set-dressing) |
| 10 | Apple Developer account | **None.** macOS builds are ad‑hoc signed and not notarized; Steam is the main Mac channel | [Platform recommendation](../research/platform-recommendation.md#macos-without-an-apple-developer-account), risks table |
| 11 | Visual inspiration | **Closer to Mad Max** than to AW's black‑and‑white art: **full‑colour pixel art** | [14](14-art-audio-ui.md) |
| 12 | The clock | **Dropped.** The Choir is a slow, creeping spread with **no forced end**; its reach colours the endings | [02](02-world.md#the-choirs-creep-no-clock), [17](17-factions.md#the-choir-the-nobunaga-faction), [06](06-playbooks.md#endings-and-the-choirs-reach) |
| 13 | Whose mechanics | **UWNH's and Inindo's.** AW supplies the classes, setting and ambiance | [01](01-translation-matrix.md), [04](04-characters.md), [09](09-combat.md), [11](11-crew-and-bonds.md) |

## Open questions for the client
None outstanding. The M1 sim raised design questions for the M2 pass ([findings](19-numbers-and-data.md#what-m1-found)): Burning Water falls early, the factions barely grow on their own, and some ambitions stall.
