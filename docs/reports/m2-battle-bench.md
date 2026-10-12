# M2 battle bench

## Skirmishes

500 fights per encounter. Party: driver, angel, gunlugger, all at the encounter's level (Fight and Road levels; Trade 1).

| Encounter | Rating | Party level | Party wins | Target | Rounds (median) | Party HP left (median) | Party members down (mean) | |
|---|---|---|---|---|---|---|---|---|
| Scavvers in the stores | easy | 1 | 100% | 95–100% | 6.0 | 88% | 0.02 | ✅ |
| Toll men at the crossing | easy | 2 | 100% | 95–100% | 8.0 | 85% | 0.07 | ✅ |
| A Teeth raiding pack | fair | 2 | 77% | 75–92% | 9.0 | 20% | 1.78 | ✅ |
| Glass-eyes in the dunes | fair | 3 | 82% | 75–92% | 10.0 | 39% | 1.46 | ✅ |
| The Opened on the overpass | fair | 3 | 79% | 75–92% | 10.0 | 28% | 1.70 | ✅ |
| A Teeth war band | hard | 3 | 55% | 45–70% | 10.0 | 6% | 2.26 | ✅ |
| A Wellguard patrol | hard | 4 | 63% | 45–70% | 14.0 | 11% | 2.17 | ✅ |
| Tum Tum's Catchers' roadblock | boss | 5 | 50% | 30–60% | 17.0 | 0% | 2.40 | ✅ |
| A cantor and its Opened | hard | 5 | 61% | 45–70% | 13.0 | 14% | 1.94 | ✅ |
| A bounty hunter out of Gallows | hard | 5 | 59% | 45–70% | 9.0 | 7% | 2.34 | ✅ |
| Sings-Back at the dishes | boss | 9 | 56% | 30–60% | 15.0 | 4% | 2.39 | ✅ |

## Road wars

500 fights per convoy. The party convoy is the standard one for the convoy's level (data/units/units.json party_convoys); its named characters are at that level.

| Convoy | Rating | Party level | Party wins | Target | Rounds (median) | Party Durability left (median) | Party rigs lost (mean) | Enemy rigs taken (mean) | |
|---|---|---|---|---|---|---|---|---|---|
| Teeth outriders | easy | 2 | 100% | 95–100% | 4.0 | 98% | 0.00 | 0.99 | ✅ |
| Toll men give chase | easy | 2 | 98% | 95–100% | 7.0 | 93% | 0.00 | 0.00 | ✅ |
| A Teeth raid | fair | 3 | 83% | 75–92% | 8.0 | 54% | 0.49 | 0.15 | ✅ |
| Catchers guarding a coffle | hard | 5 | 49% | 45–70% | 17.5 | 35% | 1.28 | 0.05 | ✅ |
| A Wellguard tanker escort | hard | 5 | 70% | 45–70% | 13.0 | 62% | 1.07 | 0.00 | ✅ |
| Dremmer's war rig | boss | 6 | 59% | 30–60% | 6.0 | 65% | 1.35 | 0.64 | ✅ |

## Notes
- Both sides are played by the same simple tactical AI (sim/battle/). In skirmishes: take the kill, then leaders and cantors; ranged fighters keep their range and prefer cover; healers heal below half HP. In road wars: the party holds at close range and shoots; crews board when they outmatch the defenders or their leader would win the duel; small crews keep away from boarders; the party runs when outgunned three to one.
- **Fair skirmishes are tough**: the party usually wins with 20–40% of its HP left and one or two members down (recoverable). Hard and boss fights usually cost two or more.
- **Long skirmishes**: the Catchers' roadblock (17 rounds), Sings-Back (15) and the Wellguard (14) run past the 10-round pacing target; stuns, reloads and heavy armour drag them out.
- **Leader duels decide road wars** when one leader clearly outclasses the other, as in UWNH. Hard convoys therefore carry level-matched captains.
- **Edge cases to watch**: the Wellguard escort (70%), Dremmer's war rig (59%) and the Catchers' coffle (49%) sit near the edges of their windows.
