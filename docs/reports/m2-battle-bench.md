# M2 battle bench: skirmishes

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

## Notes
- Both sides are played by the same simple tactical AI (sim/battle/skirmish.gd): take the kill, then leaders and cantors; ranged fighters keep their range and prefer cover; healers heal below half HP.
- Fair fights are tough: the party usually wins with 20–40% of its HP left and one or two members down (and recoverable). Hard and boss fights usually cost two or more.
- Long fights: the Catchers' roadblock (17 rounds), Sings-Back (15) and the Wellguard (14) run past the 10-round pacing target; stuns, reloads and heavy armour drag them out.
