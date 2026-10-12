# 15 · Roadmap, Vertical Slice and Open Questions

## Milestones

| # | Milestone | Proves | Contents |
|---|---|---|---|
| **M0** | **Design bible** (this round) | Direction | These docs, the RE teardowns, the platform pick |
| **M1** | **Sim spike** (headless, Godot 4) | The economy and politics work *without* graphics, at full scale | Moves engine, dice service, the road graph, all 130 holds' economy, Lean, 7 warlords, the world turn, a 48‑month sim runner, a balance report |
| **M2** | **Paper Director** | AW's MC as an AI is fun and fair | The Director decision procedure, threat data, event cards in a text UI, golden tests |
| **M3** | **Vertical slice** | The full loop, at quality, for about 2 hours | Defined below |
| **M4** | **Alpha** | The whole map (130 holds) and all six playbooks | All regions, holds, warlords, the Hum arc, Up, Down and In |
| **M5** | **Beta / content lock** | Endings, balance, polish | All endings, the Month Report text bank, localization pass |
| **M6** | **Launch**: Windows and macOS (Steam; GOG and itch.io optional) | — | — |
| post | **v1.1–1.2** | Roster | Angel, Battlebabe, Gunlugger, then Brainer, Maestro D', Skinner as protagonists |

## The vertical slice (M3)
- **Playbook**: the **Driver** only. It touches the most systems (travel, trade, road war, discovery).
- **Region**: the Crossing, the Delta and the east end of the Ten, so the slice has a living river (the Mississippi), four crossings, interstate, highway, back roads and a dry riverbed (**14 holds**):
  - the Crossing: the Lighthouse, Anchorage, Saltlick, Gnarly, Pyramid, Beale
  - the Delta: Siege, Brace Win, Barge Town, Mudflat, Reservoir
  - the Ten: Capitol, Orleans, Dustwich
- **Fog**: everything outside the Crossing starts uncharted, so every Delta and Ten hold is a **first contact**.
- **Warlords**: Tum Tum (whose Catchers come down the Fifty‑Five, with Mudflat and Capitol leaning his way), and Brace Win as a minor warlord holding the dam. Last runs offscreen as a World Clock at 3× speed, so the slice reaches 6:00.
- **Systems in**:
  - Overworld road network with supplies, fog, charts, breaks, crossings, weather and Howls
  - First contact scenes
  - Hold walking, the market, the bar, the garage and the notice wall
  - Basic moves through dialogue stances
  - **Road war** (full)
  - **Skirmish** (basic: 6 battle moves)
  - Lean and investment
  - The world turn and the Month Report
  - Crew of up to 4 (Navigator, Angel, Gunner, Mechanic)
  - 6 Sights
  - 1 maelstrom site with 1 discipline (Salt, at Saltlick)
  - The save system (manual, auto, quick)
- **Systems out**: gang war, the Up and Down layers, the In beyond one site, the other 5 playbooks, endings.
- **The slice is a success when** playtesters can tell, unprompted:
  1. what a 7–9 means
  2. why they ran out of water
  3. which roads they've charted and where the river can be crossed
  4. that a hold changed hands *without them*
  5. who Last is, or what they think Last is

## Production risks

| Risk | Mitigation |
|---|---|
| **The Director feels random** | Golden tests, the designer overlay, *announce before you hit* (fan rules), and threats visible in the journal |
| **The economy breaks** (runaway money, dead markets) | Saturation, monthly lifestyle drain, the headless sim with 200‑seed balance reports in CI |
| **Text volume** (AW's voice is the game) | A text‑bank pipeline with tags (region, threat, move, result). A writers' style guide built from the AW playbook voice, including the [southern voice guide](02-world.md#voice-the-bravo-and-the-sierra-coast). A Spanish‑fluent writer or sensitivity reader for the southern text bank |
| **Licensing scope** | **Confirmed by the client.** The license covers this video game. AW text is still kept in `/data` so it's easy to audit |
| **Mature content and ratings** | The content policy in [00](00-vision.md#tone-and-content-policy), content toggles, and an early ESRB/PEGI/IARC questionnaire |
| **Real‑world geography and lookalike brands** | Real geography and real interstate numbers are used (client decision). Holds use survivor names, and real place names appear through the Quarantine. Lookalike brands are rare set dressing under strict rules ([13](13-content-tables.md#lookalike-brands-set-dressing)): never real names, logos or trade dress. **Legal review of the lookalike list before content lock.** |
| **Map scale** (130 holds) | The headless sim tests all 130 from M1. Hold tiers (outposts are cheap) keep content cost down. Regions are authored in priority order: the slice region first, the Loud edges last |
| **macOS distribution** | Apple Developer ID signing and notarization in CI from M1. Universal (Apple Silicon + Intel) builds. Test on a low‑end MacBook Air |
| **Source‑game IP** | We take *philosophy*, not content. No Koei names, maps, text, art or music. The RE notes stay internal, and ROMs are never committed |

## Client decisions (resolved)

| # | Question | Decision | Where it's reflected |
|---|---|---|---|
| 1 | AW license covers a video game | **Yes** | Risks table |
| 2 | Co‑op | **No. Single‑player only** | [00](00-vision.md#non-goals), [04](04-moves-engine.md#hx) |
| 3 | Permadeath or saves | **A conventional save system** | [03](03-core-loops.md#saving-client-decision-a-conventional-save-system) |
| 4 | Map scale | **About 130 holds** across a smaller area: a portion of the former US, Canada and Mexico | [02](02-world.md), [16](16-gazetteer.md) |
| 5 | Platforms | **Windows and macOS only** | [Platform recommendation](../research/platform-recommendation.md) |
| 6 | Travel model | **Interstates are the seas**, dry riverbeds are extra roads, living rivers are barriers, and **the Easing** makes exploration the heart of the game | [02](02-world.md#the-map-as-a-road-network), [08](08-travel-and-vehicles.md) |
| 7 | The drained Gulf | **Dropped.** The Gulf stays as water at the map's edge | [02](02-world.md) |
| 8 | Spanish | **Spanish‑inflected dialogue** along the Bravo and the Sierra Coast, without drifting from apocalyptica. UI and moves stay in English | [02](02-world.md#voice-the-bravo-and-the-sierra-coast) |
| 9 | Real geography and brands | **Real interstate numbers and real geography.** Brands are rare set dressing in less‑rusted ruins, as **lookalikes**: plausible chain names recognisable by look, not puns (*McCready's*, *Buckaroo's*) | [02](02-world.md#naming-rules), [13](13-content-tables.md#lookalike-brands-set-dressing) |

## Open questions for the client
None outstanding. New questions will come out of the M1 sim spike (economy balance at 130 holds) and the M2 Director prototype.
