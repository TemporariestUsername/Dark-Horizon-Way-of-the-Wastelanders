# 05 · Events and the Living World

Events work the way UWNH's voyages and ports did: storms, rats, rumors, a stranger at the bar. Encounters work the way Inindo's overworld did. Both are driven by **what's actually out there**: the region, the season, your supplies, and the **threats** on that stretch of road. Apocalypse World supplies the *flavour*: its threat types (warlords, brutes, grotesques, afflictions, landscapes, terrain) tag the events, and its voice writes them. It doesn't supply the rules.

## Kinds of event

| Kind | When | Examples | Source lineage |
|---|---|---|---|
| **Road events** | Each road day | Dust storm, Howl, scavvers in the stores, rot, a break ahead, a pileup sighted, a straggler camp, a crossing toll | UWNH's sea events |
| **Encounters** | On the road, weighted by the danger ring | Raiders, Catchers, a bounty hunter, the Opened, wild beasts | Inindo's overworld encounters |
| **Hold events** | Entering a hold, or at the bar | Rumors, a recruit, a challenge, a theft, a market crash, a request from the boss | UWNH's port and cafe events |
| **Gig events** | Steps in a job | Ambush on the delivery, the target was warned, a double‑cross | Inindo's missions |
| **Story beats** | Triggered by arc conditions | Each class's five‑act arc, faction ambitions, the Choir's reach | Both games' story chapters |
| **World events** | The monthly world turn | A hold changes hands, a warlord dies, an embargo, a Silencing | Inindo's daimyo turn |

## How an event is chosen
On each road day, and on entering a hold, the event system builds a list of eligible events and draws one, possibly "nothing happens". The weight of each event is:

```
weight = base
       × region_and_season_fit     (twisters on the Forty in autumn, ice on the Lakes in winter)
       × danger_ring               (Centre 0.5 · Closer 1.0 · Farther 1.5 · the Loud 3.0)
       × threats_present           (a raider gang within 200 km makes raids likelier)
       × supply_state              (low chow makes rot and desertion likelier)
       × recent_repeat_penalty     (the same event isn't repeated within 10 days)
```

**Threats are data.** Each one is a named gang, beast, cult or affliction with a position on the map, a kind (AW's threat types, used as tags), an aim, and an event list. Threats move during the world turn. That's why encounters cluster where the trouble actually is: the Teeth's raiders turn up on the Thirty‑Five because that's where the Teeth are, not because a dice table said so.

```yaml
id: catchers_fifty_five
name: "Tum Tum's Catchers"
kind: brute/hunting_pack          # AW threat type, used as a tag
aim: take people for the Choir
at: { hold: mudflat, roams_km: 250 }
strength: { troops: 20, arms: 40, training: 35 }
events: [catchers_roadblock, empty_camp, coffle_sighted, catchers_at_the_bar]
```

## Event cards
Every event is a **card**:
- a short scene in the AW voice (second person, profane, apocalyptica)
- 2–4 **choices**

A choice can be safe, or it can be a **check** with its success chance shown ([04](04-characters.md#checks)). Some choices start a battle ([09](09-combat.md)).

> *The radio's been singing for an hour. Not words. Not quite. Fianelly has her hands over her ears and she's still humming along.*
> **[Push through the Howl]** Cool check, fair: 64%. **[Wait it out]** lose a day, crew morale −5. **[Turn back]**

## Anti‑frustration rules
These keep the game hard without being cruel:
1. **A warning before anything lethal.** A raid, a Silencing or a boss always comes after a rumor, a sighting or a Month Report line.
2. **A breather after a bad streak.** After three bad events in a row, the next draw favours an opportunity (a wreck, a recruit, a cache).
3. **Signature assets are safe.** Your class's signature asset can't be permanently lost to a random event. It can only be lost through your own choices in a story beat or a battle you chose.
4. **No empty fail states.** Being stranded, robbed or defeated always comes with a way forward.

## The Wanderer AI (Inindo's autonomous NPCs)
Every named NPC who isn't a hold boss or faction hardholder gets one action per world turn, from Inindo's verb set:

| Verb | Chosen when |
|---|---|
| **Move** | What they want is somewhere else |
| **Attack** | What they want is held by someone weaker |
| **Flee** | Threatened beyond their nerve |
| **Seek work** | Short on barter |
| **Work** | Employed: a gig, a crew, a gang |
| **Train** | Pursuing a discipline or a skill at a hall |
| **Wait** | Content, or stuck |
| **Meet** | Pursuing a friendship or a rivalry, the player included |

Each NPC's **want** comes from [13](13-content-tables.md#npc-wants-the-wanderer-ai-drives-these) and drives where they go and whom they join. That's how a rival turns up at the bar the month after you passed them on the road.

## The Month Report
At the end of each month comes a one‑page broadsheet, "*Meanwhile…*", written in the News' voice:
- Every change in a hold you know about.
- **Rumors** for the ones you don't.
- **Always** where the Choir has spread. Its creep is slow, but it's never hidden.

## In the M2 simulation
The event system runs in [`sim/events/`](../../sim/README.md), over the data in [`data/events/`](../../data/events/threats.json): 12 threats and 43 event cards.
- **The draw.** Each road day draws one road event or encounter, or nothing; each hold passed draws a hold event, or nothing. "Nothing" has a weight of 40 against the events' summed weights. Encounters count four times their listed weight.
- **Warnings** last 45 days. A threat's warning cards (the Teeth's jawbone, an empty camp with chains in the dust, radios singing) must fire before its lethal events can.
- **The breather** follows three bad events in a row. The **repeat penalty** cuts an event's weight to a tenth for 10 days after it fires.
- **A journey** ([`journey.gd`](../../sim/events/journey.gd)) drives a real route day by day: supplies burn, battles start from the cards, the holds it passes resupply it, and running out of fuel is never a dead end. [`tools/journey.gd`](../../tools/journey.gd) plays it as a text UI (`--play`), with an optional designer overlay (`--overlay`).
- **The bench** ([report](../reports/m2-event-bench.md)) drives nine routes 200 times each with a sensible‑player policy. Every route lands at 0.47–0.63 road events a day and 0.7–2.8 battles every 10 days, and no lethal event ever fires unwarned.

## Tuning
- Every draw is **seeded** and **logged**: eligible events, weights, the pick. A designer overlay (off in release) shows why an event fired.
- Fixed seeds plus scripted inputs reproduce the same event sequence exactly, so balance changes can be compared by diffing. Three **golden journeys** in [`tests/golden/`](../../tests/golden/journey_lighthouse_dustwich_s1.txt) are checked word for word by the tests.
