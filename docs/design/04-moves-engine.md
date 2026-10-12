# 04 · The Moves Engine

The moves engine is the game's resolution system. It's Apocalypse World's rules running in a video game: when the fiction triggers a move, you roll 2d6 and read the result in bands.

## Stats
- **Cool**: acting under pressure, driving, waiting out a crisis.
- **Hard**: violence, intimidation, holding your ground.
- **Hot**: charm, manipulation, beauty, presence.
- **Sharp**: reading people and situations, smarts, the market.
- **Weird**: the maelstrom, augury, strangeness, the In.

Stats range from −3 to +3, with playbooks capping their improvements at +2 or +3. You choose a starting array from your playbook's sets.

## The roll
```
2d6 + stat (+ forward/ongoing/hold/help/gear)
  10+   strong hit   — you do it, often with choices
  7–9   weak hit     — you do it, but: a worse outcome, a hard bargain, or an ugly choice
  6–    miss         — the Director makes a move (as hard as it likes)
  12+   advanced     — only after the "advance a basic move" improvement
```

**Presentation.**
- The roll is always shown: two dice tumble on the playbook sheet, the stat slides in, and the total lands on a **band strip** (miss | 7–9 | 10+).
- **Highlighted stats** glow. A roll with a highlighted stat marks **experience**, shown as a pip filling.
- **There are no hidden modifiers.** Every +1 is named in the roll ticker: "*+1 forward: read a sitch*", "*+1: help (Fianelly, Hx+2)*".
- **Choose‑lists** come up as cards. The player picks, and on 7–9 the Director picks the cost where the move says so.

**Modifiers:**
- **forward**: applies to the next relevant roll.
- **ongoing**: applies while a condition lasts.
- **hold**: tokens spent later, shown as chits on the sheet.
- **help/interfere**: an ally (or rival) rolls +Hx. On 10+ they add +2 (or −2 to interfere). On 7–9 they add +1 (or −1) and expose themselves to the cost.

## How fiction triggers moves in a video game
In AW, *to do it, you do it*. In the game, the context gives you **stances** and **verbs**. The engine knows which move a verb triggers, and the UI names the move.

| Basic move | Trigger in game | Interface |
|---|---|---|
| **Do something under fire** | Any **contextual action** taken while a threat is active: hot‑wiring a rig as raiders close in, crossing a collapsing gantry, holding a door, staying silent during a search | The action prompt shows a ⚠ "*under fire*" tag, and pressing it rolls +cool. On 7–9 the Director offers *a worse outcome, a hard bargain or an ugly choice* as a card. |
| **Go aggro** | Dialogue stance **[Threaten]**, or pointing a weapon in the field | You choose the *demand* and the *threat*. On a hit, the target chooses from AW's lists: force your hand and suck it up / cave; on 7–9 also get out of your way, barricade, give you something they think you want, or back off calmly. |
| **Sucker someone** | Attacking an unaware or helpless target | No roll. Harm as established. If they could fight back, it becomes *go aggro*. |
| **Do battle** | Entering a skirmish, road war or gang war | Switches to the battle moves. See [09](09-combat.md). |
| **Seduce or manipulate** | Dialogue stance **[Persuade]** (includes *bluff*, *fast‑talk* and *lie*). You must choose **a reason** from what you know, have or can offer. | NPC on 10+: they go along unless something betrays the reason. On 7–9: they need **an assurance, corroboration or evidence** first, which turns into a quest step. |
| **Help or interfere** | When a crew member or rival is in a scene, a prompt appears | Rolled +Hx. Interfering with a rival's move is how you sabotage NPC plans. |
| **Read a sitch** | **[Read]** when arriving at a charged scene, at the start of a battle, or entering a hold during trouble | Ask questions from AW's list on a card ("*Where's my best escape route?*", "*Which enemy is most vulnerable to me?*", "*What's my enemy's true position?*"…). Acting on an answer gives **+1 forward**, shown as a bright tag on the matching action. |
| **Read a person** | **[Read]** in a charged conversation | Hold 3 on 10+ or 1 on 7–9. Spend it during the conversation: "*Are they telling the truth?*", "*What do they intend to do?*", "*How could I get them to ___?*" The answer opens new dialogue options. |
| **Open your brain** | **[Listen]** anywhere (a maelstrom site gives a bonus), or at a fork where the fiction is murky | On a hit, the Director tells you something new about the situation: a revealed secret, a hidden threat on the map, or a glimpse of a countdown. Opening your brain is also how you **enter the In**. |
| **Session end** | Month close | See [03](03-core-loops.md). |

**On misses.** Every basic move's miss reads "*be prepared for the worst*", which hands the turn to [the Director](05-director.md).

## Peripheral moves

### Harm and healing
- **Suffering harm**: when a PC suffers harm, roll + harm suffered (after armor). This roll is *bad* when high.
  - On 10+, the Director chooses one: *out of action*, *worse than it seemed (+1 harm)*, or *2 from the 7–9 list*.
  - On 7–9 it chooses one: lose your footing, lose your grip on what you're holding, lose track of someone, or miss noticing something important.
  - On a miss, it may still pick a 7–9 result in exchange for −1 harm.
- **Inflicting or healing harm on another PC** (or on crew; the game treats key crew as PC‑like for Hx): +1 Hx for each segment, and resetting at +4 marks experience. *When you hurt someone, they see you more clearly. When you heal someone, you see them more clearly.*

### Barter moves (see [07](07-economy.md))
- **Give 1‑barter with strings attached**: counts as *manipulate* with a 10+, no roll.
- **Go into a holding's bustling market** for a specific thing: roll +sharp.
- **Make known that you want a thing and drop jingle to speed it on its way**: roll + barter spent (max +3).

### Insight and augury
These require hocus followers, a Savvyhead workspace, or a **maelstrom site**.
- **Insight**: ask your followers what your best course is. Pursuing it gives +1, and failing at it still marks experience.
- **Augury**: roll +weird and choose an effect:
  - reach through the maelstrom to someone or something connected to it
  - isolate and protect a person or thing from it
  - isolate and contain a fragment of it
  - insert information into it
  - open a window into it

  On 10+ choose 2 qualities (persists, deep, broad, stable), or 1 on a 7–9.

  In the game, augury is a *map action*:
  - **reach** = locate a named NPC or threat anywhere
  - **protect** = shield a hold from the Hum for a season
  - **contain** = seal a maelstrom bleed
  - **insert** = plant a rumor that spreads by itself
  - **window** = scout a region of the In

## Weird disciplines (Inindo's magic schools, translated)
At **maelstrom sites** (see [08](08-travel-and-vehicles.md#the-in)), a weird master can teach a **discipline**: a set of 3 moves learned in order, each costing **strain** to use. Strain is a 3‑box track, separate from harm. A full strain track gives **Ψ‑harm** (1 harm, AP, plus a Director move).

| Discipline | Site (In) | Tier 1 / 2 / 3 | Source school |
|---|---|---|---|
| **Static** | The Dishes (Up: Harrowgate) | jam a radio / blind a brainer / silence the Hum locally | Ninjutsu |
| **Burn** | Burning Water (the Ten) | heat‑shimmer / make it catch / the fire remembers | Fire |
| **Wind** | Last Stop, at the edge of the Loud (Rag‑Wastes) | read the dust / turn a storm / walk on wind | Sky |
| **Salt** | Saltlick's salt barns (the Crossing) | preserve / still the ground / turn to salt | Earth |
| **Mirror** | Mirror Town (the Glass) | see behind / double / step through a reflection | Mysticism |
| **Mend** | Barrow's ossuary (Sierra Coast) | close a wound (heal 1) / call back the dying / borrow a life | Cures |
| **Iron** | The Teeth's pit (Rag‑Wastes) | steady hands / no pain / become a weapon | Bukyo (martial) |
| **Lure** | Rumhouse cellar (the Ten) | catch an eye / be wanted / make them follow | Magic |
| **Rot** | Krin's Nest (Down) | spoil food / sicken / the Family's touch | Sorcery |
| **Echo** | Wisher's mast (Up), and Tajin (Sierra Coast) | hear the dead / ask the dead / speak as the dead | Visions |
| **Choir** | Harrowgate (Up, late) | hum / open them / join the Choir (dangerous) | Evil |
| **Hex** | the Pumphouse (Down) | mark / jinx (−1 ongoing) / undo | Curses |

Each discipline's moves are written as AW moves with a trigger, a roll (+weird unless stated) and a choose‑list.

## Hx
- Hx normally sits from **−2 to +3**, on your sheet, for each named character you're bonded to: your **crew** and **key NPCs** (the game is single‑player).
- **What Hx does:** it's your *help/interfere* bonus, and it's how well you know them. At Hx+2 or more you see an NPC's *want* on their card. At Hx+3 you see their *secret*.
- **Hx changes through:**
  - playbook Hx questions at character creation (asked about the starting crew and NPCs)
  - harm and healing
  - session end
  - sex moves (off‑screen)
  - specific playbook moves
- **Reset** (as in AW's session end): reaching **+4** resets to **+1** and marks experience. Dropping to **−3** through session end resets to **0** and also marks experience.

## Highlights and experience
- **Two stats are highlighted** each month. One is chosen by the crew member with the highest Hx with you, and the other by the **Director**, which picks the stat that would make the coming month most interesting given its active threats.
- Rolling a highlighted stat marks 1 experience. **5 experience gives an improvement.** See [12](12-progression.md).
- **A playbook move can't be learned by grinding.** It comes only through improvements. That's deliberate: AW characters change because of what happens, not because of repetition.
