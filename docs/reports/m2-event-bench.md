# M2 event bench

200 journeys per route, the auto policy choosing (a sensible player: best expected value). A road day draws one road event or nothing; each hold passed draws a hold event or nothing.

| Route | Level | Arrived | Days (median, expected) | Road events per road day | Hold events per visit | Battles per 10 days | Battles won | Lethal without warning | Longest bad streak | Days without water | Tone mix (good / neutral / bad / lethal) | |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| The Crossing to the Ten, spring (The Lighthouse → Dustwich) | 3 | 100% | 9.0 (7.0) | 0.46 | 0.27 | 0.97 | 99% | 0 | 3 | 1 | 24 / 16 / 58 / 2% | ✅ |
| A short Delta run (Gnarly → Siege) | 2 | 100% | 4.5 (3.4) | 0.54 | 0.32 | 0.66 | 95% | 0 | 3 | 0 | 22 / 18 / 57 / 2% | ✅ |
| The Rag-Wastes in the Long Heat (Sweetwell → Last Stop) | 4 | 100% | 10.0 (7.1) | 0.64 | 0.33 | 1.99 | 100% | 0 | 3 | 166 | 15 / 27 / 55 / 2% | ✅ |
| The Lakes in winter (Highwater → Motor) | 4 | 100% | 5.5 (3.4) | 0.50 | 0.32 | 1.90 | 100% | 0 | 3 | 0 | 29 / 19 / 52 / 0% | ✅ |
| The long voyage to the Sierra Coast (The Lighthouse → Barrow) | 5 | 100% | 52.2 (31.3) | 0.48 | 0.26 | 1.34 | 76% | 0 | 3 | 1479 | 23 / 20 / 56 / 1% | ✅ |
| The Ten after six years of the Choir (Capitol → Dustwich) | 5 | 100% | 3.0 (0.6) | 0.63 | 0.31 | 2.75 | 99% | 0 | 3 | 0 | 29 / 10 / 61 / 0% | ✅ |
| The Glass (The Exchange → Neon) | 4 | 100% | 10.0 (6.9) | 0.49 | 0.24 | 1.58 | 98% | 0 | 3 | 2 | 25 / 20 / 55 / 0% | ✅ |
| The Forty in twister season (The Lighthouse → Gallows) | 4 | 100% | 7.0 (4.4) | 0.52 | 0.24 | 1.03 | 100% | 0 | 3 | 0 | 29 / 15 / 53 / 2% | ✅ |
| The Whiteout's winter roads (Highwater → Mill Town) | 5 | 100% | 12.0 (7.6) | 0.48 | 0.29 | 1.71 | 100% | 0 | 3 | 0 | 26 / 21 / 53 / 0% | ✅ |

Targets: road events per road day 0.3–0.7, battles per 10 days 0.5–3.0, arrival ≥ 95%, no lethal event without a warning, no more than 3 bad events in a row.

## How often each event fired (all routes)

bandits 1284, scavver_pack 695, break_ahead 665, straggler_camp 593, scavvers_in_stores 590, bar_rumor 570, dust_plume 536, dust_storm 511, lone_traveller 435, pileup 433, rot 431, catchers_coffle 427, howl 400, rest 398, flash_flood 394, bad_water 387, theft 372, abandoned_rig 332, recruit_at_bar 315, opened_on_the_overpass 256, wellguard_patrol 240, gar_ambush 174, fuel_cache 164, teeth_outriders 161, wellguard_tankers 153, crossing_toll 119, empty_camp 105, ice_groans 100, radio_singing 85, catchers_roadblock 72, gar_on_the_river 68, long_heat 59, twister 42, teeth_sign 41, whiteout_raid 40, glass_tracks 38, white_flags 35, glass_eyes 29, teeth_raid 24, cantor 17, dremmers_battle_rig 6, bounty_hunter 6

Never fired on these routes: twister_riders_raid.

## Notes
- **The anti-frustration rules hold**: across every route, no lethal event fired without its threat being warned first, and bad events never ran more than three in a row.
- **Long legs run dry.** The Rag-Wastes in the Long Heat and the voyage to the Sierra Coast leave convoys without water for days: the legs are longer than 20 casks last. A player will need bigger tanks, stashes, or a water hauler. That's "scarcity is the map" working, but the Sierra Coast voyage (about 50 days against 31 expected) may be too punishing.
- **Early roads are dangerous on purpose**: the Catchers work the Crossing and the Delta, so a level-2–3 party meets fights above its level. A sensible player avoids them; the auto policy weighs win chance against losing half the cargo.
- The Twister Riders' raid needs its warning first, and on these routes the dust-plume warning usually points at another gang, so it rarely fires.
