# 15 · Roadmap, Vertical Slice and Open Questions

## Milestones

| # | Milestone | Proves | Contents |
|---|---|---|---|
| **M0** | **Design bible** (this round) | Direction | These docs, the RE teardowns, the platform pick |
| **M1** | **Sim spike** (headless, Godot 4) | The economy and politics work *without* graphics | Moves engine, dice service, 10 holds' economy, Lean, 3 warlords, the world turn, a 36‑month sim runner, a balance report |
| **M2** | **Paper Director** | AW's MC as an AI is fun and fair | The Director decision procedure, threat data, event cards in a text UI, golden tests |
| **M3** | **Vertical slice** | The full loop, at quality, for about 2 hours | Defined below |
| **M4** | **Alpha** | The whole Basin and all six playbooks | All regions, holds, warlords, the Hum arc, Up, Down and In |
| **M5** | **Beta / content lock** | Endings, balance, polish | All endings, the Month Report text bank, localization pass |
| **M6** | **Launch** (PC/Steam/Steam Deck) | — | — |
| post | **v1.1–1.2** | Roster | Angel, Battlebabe, Gunlugger, then Brainer, Maestro D', Skinner as protagonists. Console ports. |

## The vertical slice (M3)
- **Playbook**: the **Driver** only. It touches the most systems (travel, trade, road war, discovery).
- **Region**: the Centre plus the North‑West wedge: the Lighthouse, Anchorage, Saltlick, Gnarly, Dog Head, Kettle, Dustwich, Pellet, Rumhouse and the Teeth (**10 holds**).
- **Warlords**: Dremmer and Tum Tum, plus Last as an offscreen World Clock running at 3× speed so the slice reaches 6:00.
- **Systems in**:
  - Overworld with supplies, fog, weather and the Calm
  - Hold walking, the market, the bar, the garage and the notice wall
  - Basic moves through dialogue stances
  - **Road war** (full)
  - **Skirmish** (basic: 6 battle moves)
  - Lean and investment
  - The world turn and the Month Report
  - Crew of up to 4 (Navigator, Angel, Gunner, Mechanic)
  - 6 Sights
  - 1 maelstrom site with 1 discipline (Static)
- **Systems out**: gang war, the Up and Down layers, the In beyond one site, the other 5 playbooks, endings.
- **The slice is a success when** playtesters can tell, unprompted:
  1. what a 7–9 means
  2. why they ran out of water
  3. that a hold changed hands *without them*
  4. who Last is, or what they think Last is

## Production risks

| Risk | Mitigation |
|---|---|
| **The Director feels random** | Golden tests, the designer overlay, *announce before you hit* (fan rules), and threats visible in the journal |
| **The economy breaks** (runaway money, dead markets) | Saturation, monthly lifestyle drain, the headless sim with 200‑seed balance reports in CI |
| **Text volume** (AW's voice is the game) | A text‑bank pipeline with tags (region, threat, move, result). A writers' style guide built from the AW playbook voice |
| **Licensing scope** | The client holds an AW license. **Confirm it covers video‑game adaptation, all 16 playbooks, the art style ("in the style of"), and commercial distribution.** Keep AW text in `/data` so it's easy to audit |
| **Mature content and ratings** | The content policy in [00](00-vision.md#tone-and-content-policy), content toggles, and an early ESRB/PEGI/IARC questionnaire |
| **Source‑game IP** | We take *philosophy*, not content. No Koei names, maps, text, art or music. The RE notes stay internal, and ROMs are never committed |

## Open questions for the client
1. **License scope**: video game rights; which AW editions and supplements; whether the *Faceless*, *Waterbearer*, *Child‑thing* and *News* playbooks are included.
2. **Co‑op**: AW is a group game. Should a 2–4 player co‑op mode (shared convoy, shared Hx between PCs) be a post‑launch goal or a launch feature? It changes the netcode budget a lot.
3. **Ironman default**: should death be permanent by default, with save‑scumming as an option, or the other way round?
4. **Map scale**: 30 holds at launch (recommended), or UWNH‑scale (about 100) for a longer tail?
5. **Platform order**: PC first (recommended), or a simultaneous Switch target? That affects the UI density budget.
