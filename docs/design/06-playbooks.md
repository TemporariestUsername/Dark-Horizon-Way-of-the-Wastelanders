# 06 · Playbooks

Playbooks do two jobs:
1. **Protagonists.** These are UWNH's six captains, each with a different *career*.
2. **NPC archetypes.** These are Inindo's classes: crew, rivals, and the people you recruit.

**Licensing.** Moves, specials, improvement lists and gear come from the licensed AW playbooks as **data imports** (`/data/playbooks/*.json`) and keep AW's wording. This doc covers how each one *plays as a video game*: its signature system, its campaign verbs, its arc and its endings.

## Common to every protagonist
- **Creation**: name, look, stat array, moves, gear and Hx, all following AW, done on an animated playbook sheet.
  - **Hx questions** are asked about the **starting crew and NPCs** (for example, the Driver asks: "*Which one of you once rode with me?*"). The answers set Hx and become **facts** the Director can use.
- **Basic moves** for everyone, plus the playbook's starting picks.
- **Every playbook can do everything**: trade, drive and fight. The playbook makes one career *special* and *cheap*, not the others impossible. This is UWNH's freedom of career.
- **Cameos.** In each campaign, the other five protagonists exist as named NPCs with arcs that run on their own (Wanderer AI plus authored beats). Meeting them crosses the stories over, as UWNH does.

## The six launch playbooks

### 1. The Driver: *the dark horizon*
> "*In Apocalypse World the horizons are dark, and no roads go to them.*"

| | |
|---|---|
| **Career** | Explorer and courier (UWNH's adventurer path) |
| **Signature system** | **The car**: frame, strengths, looks, weakness, battle options (AW Driver), plus a hood ornament. The Driver's rig gets +1 range tier and earns **Sights** (discoveries) at double value. |
| **Moves (data)** | Combat driver, Eye on the door, Weather eye, Reputation, Daredevil, Collector, My other car is a tank |
| **Campaign verbs** | **Chart** (fog of war reveals at double radius, and charts sell to the News) · **Stash** (leave supply caches) · **Run** (courier gigs with deadlines) · **Find the Out** |
| **Starting point** | Gnarly's garage (Closer ring, N) |
| **Arc** | I. *Gnarly's debt*: run three deliveries. II. *A map that isn't*: a rumor of a road off the salt. III. *The Drop's edge*: first reach the Out. IV. *Who else is looking*: Rothschild wants the route. V. *Where the sea went*. |
| **Endings** | **Over the edge**: cross the Drop and leave the Basin; your crew decides whether to follow. **The road home**: chart the Basin, and the holds live by your maps. **The courier of the Hum**: if the World Clock is past 10:00 and your Weird is +2, drive the Choir's message to every hold. |
| **Cameo in other runs** | A named Driver who sells maps at the Lighthouse and goes missing in month 20 or so |

### 2. The Chopper: *every road belongs to my pack*
| | |
|---|---|
| **Career** | Raider and warlord‑in‑waiting (UWNH's pirate path) |
| **Signature system** | **The gang**: about 15 violent bastards (2‑harm gang small savage 1‑armor). Strengths and weaknesses come from AW options (well‑armed, nomadic, in debt, filthy and unwell…). The gang eats: it needs chow and **action** each month or it starts *pack alpha* bids. |
| **Moves (data)** | Pack alpha, Fucking thieves (plus a bike and a gang) |
| **Campaign verbs** | **Raid** caravans and straggler camps (road war, then take cargo) · **Tribute** (shake down holds; their Lean drops, your fear rises) · **Grow** (recruit from defeated gangs) · **Challenge** (single combat for another gang's leadership) |
| **Starting point** | Dog Head fence market (Closer ring, W) |
| **Arc** | I. *The pack is hungry*. II. *Dremmer notices*: tribute or war. III. *A bid for alpha*: someone in your own gang. IV. *The Teeth*: take Dremmer's seat or bow. V. *Choppers don't hum*: the Choir offers your gang purpose. |
| **Endings** | **King of the road**: replace Dremmer as Alpha wolf. **The pack scatters**: you lose the gang and ride alone. **Fucking thieves**: steal the antenna core from Harrowgate, which resets the World Clock by 2 segments. |
| **Cameo** | A chopper whose gang raids your caravans, and who might be recruited |

### 3. The Hardholder: *my hold feeds half the Basin*
| | |
|---|---|
| **Career** | Merchant prince and governor (UWNH's trader path, with a home) |
| **Signature system** | **The holding**. You choose a starting hold (Partridge, Anchorage or Saltlick) and configure it with AW's holding options (size, surplus, want, armory, walls, gang…). **Wealth**: at the start of each month, roll+hard for surplus or want. **You are the only protagonist with a fixed home.** You govern from the Seat and send **caravans** (convoys led by NPC captains) along trade routes, as UWNH's fleet captains do. |
| **Moves (data)** | Leadership, Wealth |
| **Campaign verbs** | **Govern** (settle disputes in the hold, set the tithe) · **Dispatch** (send caravans on standing routes) · **Invest** (buy influence in other holds; you're the best at moving Lean) · **Defend** (gang war at your walls) |
| **The tension** | You can ride with a caravan yourself, but **while you're gone your hold rolls Wealth at −1**, and threats get bold. This is AW's "*serious and immobile home base*" as a mechanic. |
| **Arc** | I. *Want*: the hold is hungry. II. *Routes*: the first standing caravan. III. *Grome's price*: the water leash. IV. *Allegiance*: five holds lean your way, and the warlords notice. V. *Refuge*: the Hum's refugees arrive at your gates. |
| **Endings** | **Hardholder of the Basin**: 10 or more holds leaning to you, a new power. **Walls**: your hold survives 12:00 sealed and deaf. **Gave it away**: hand the hold to its people (a quiet ending, with epilogue text from them). |
| **Cameo** | Partridge's hardholder, who offers you caravan contracts |

### 4. The Hocus: *they follow me because I hear what it says*
| | |
|---|---|
| **Career** | Prophet and cult leader (a new career, and the mirror image of Last) |
| **Signature system** | **Followers**: a cult, family or students (AW's Hocus options). **Fortunes**: a monthly roll for surplus or want from your followers. Followers give you access to **insight** and **augury**. **Faith** is a form of Lean: holds can lean to *you* through faith rather than investment. |
| **Moves (data)** | Fortunes, Charismatic, Frenzy, Fucking wacknut, Seeing souls, Divine protection, Characterize them |
| **Campaign verbs** | **Preach** (*Frenzy* on a hold's mob) · **Augur** (map actions; see [04](04-moves-engine.md#insight-and-augury)) · **Convert** (rival cults, and Hum‑touched holds) · **Counter‑broadcast** (later, against Last) |
| **Starting point** | Barrow, the mourners' hold (Farther ring, S) |
| **Arc** | I. *The dead are loud lately*. II. *Followers want*. III. *A rival voice*: Last's missionaries reach Barrow. IV. *Speak to the Choir*. V. *Which of you is right?* |
| **Endings** | **Two prophets**: defeat Last's theology in a final *Frenzy* at Harrowgate. **Become the Choir**: take Last's place. **Silence**: lead your followers to *contain* the maelstrom fragment, which has a cost. |
| **Note on *Frenzy*** | The "*orgy of uninhibited emotion*" option plays as a crowd frenzy of lamenting, fighting, sharing and celebrating. Anything sexual stays off‑screen, per the [content policy](00-vision.md#tone-and-content-policy). |
| **Cameo** | A hocus at Barrow who might become your ally against the Hum, or your rival |

### 5. The Savvyhead: *things break*
| | |
|---|---|
| **Career** | Salvager and engineer (UWNH's exploration and shipbuilding, rolled together) |
| **Signature system** | **The workspace**: a garage, lab or infirmary, as in AW, with AW's project rule ("*it's going to take hours/days/weeks; first you'll need… it'll require…*"). **Things speak**: examine salvage to learn its history. Golden‑Age tech recovered from the **Down** and **Up** feeds **projects**: better rigs, water condensers, a **Static jammer** against the Hum. |
| **Moves (data)** | Things speak (special), Bonefeel, Oftener right, Reality's fraying edge, Spooky intense, Deep insights |
| **Campaign verbs** | **Salvage** (Down and Up dungeon crawls: Inindo's mountain dungeons) · **Build** (projects that take real calendar time) · **Fix** (other people's stuff, for Rep and barter) · **Augur** through the workspace |
| **Starting point** | Dustwich container stacks (Farther ring, N) |
| **Arc** | I. *Things break*: Dustwich's pump. II. *The vault at Fuse*. III. *Wisher's mast*: what the antennas are for. IV. *Build the jammer*. V. *The Gondola*: get above the Choir. |
| **Endings** | **Static**: the jammer silences the Hum across the Basin for good (World Clock to 0:00, but the maelstrom is cut off for everyone, hocuses included). **Sweet water**: fix the Pumphouse, which ends Grome's leash. **Keep it running**: you become Harrowgate's mechanic. |
| **Cameo** | Newton of Fuse, a rival digger who has the part you need |

### 6. The Quarantine: *I was there before*
| | |
|---|---|
| **Career** | Soldier out of time. **The main‑quest spine**, like Inindo's hero |
| **Signature system** | **Stasis**: your stasis facility is a hidden workspace (AW's Quarantine stasis options, e.g. *medlab*). **A sane modern sensibility**: you get unique dialogue reading the Golden Age's remains, and you can **operate** Golden‑Age machinery without a Savvyhead. **Weird is locked at the start** (AW's "Weird—"). It opens through play. |
| **Moves (data)** | Leave no one behind, Eager to know, Inspiring, Release, Medlab (stasis options) |
| **Campaign verbs** | **Remember** (fragments of the before, triggered at Golden‑Age sites) · **Advise** (*Eager to know* makes NPCs a quest compass) · **Lead** (crew rolling +Hx to help you mark experience, so crew grow faster under you) |
| **Starting point** | Waking in a sealed stasis bunker in the Deep Lines, beneath Junction |
| **Arc** | I. *Out of the box*: Junction, then the Lighthouse. II. *What year is it*: the world as it is now. III. *Another empty pod*: someone woke before you. IV. *Last's name*: you knew them, before. V. *Harrowgate*: the reckoning. |
| **Endings** | **Shut it down**: you end the broadcast; Last dies or goes back into stasis (player's choice). **Join them**: Last was right, and you open your brain. **Back in the box**: you seal yourself and the Choir's core in stasis together. |
| **Cameo** | A strange soldier asking strange questions around Junction |

## Endings and the World Clock

| World Clock at the end | Effect on endings |
|---|---|
| Below 6:00 (won early) | Full versions of the ending, with an epilogue for every hold you touched |
| 6:00 to 11:00 | The ending is coloured by the Hum: some holds are lost, and crew may be *listening* |
| 12:00 | **Everybody hears it.** Each playbook has a 12:00 ending in which its arc is resolved *inside* the Hum. These are bittersweet, not game‑overs. |

## The rest of the roster (crew archetypes and unlockable protagonists)

| Playbook | As crew (recruitable) | Unlock as protagonist |
|---|---|---|
| **Angel** | A medic: stabilizes harm, gives the convoy an infirmary. Signature: the angel kit and stock. | v1.1 |
| **Battlebabe** | A duelist for single combat. *Dangerous & sexy* in hold scenes. | v1.1 |
| **Brainer** | Reads minds for *read a person* help, gives brain‑based interrogation, Weird support. **Non‑sexual** outcomes only for transfixion moves. | v1.2 |
| **Gunlugger** | Battle muscle. *NOT TO BE FUCKED WITH* (counts as a small gang). | v1.1 |
| **Maestro D'** | Runs an establishment: a bar where you recruit and hear rumors. *Everybody eats, even that guy* works as an information network. | v1.2 |
| **Skinner** | Social leverage. Hot moves, beauty as a luxury good, hold morale. | v1.2 |
| **Faceless** | A rare recruit. Gigantic violence, mask lore, tragedy. | Post‑launch |
| **Waterbearer** | *The Source*: whoever has them can break Grome's leash. A story NPC in launch. | Post‑launch |
| **News** | Buys your maps and truth. Writes the **Month Report**. A story NPC in launch. | Post‑launch |
| **Child‑thing** | "*We are coming.*" A late‑game horror thread tied to the Hum. | Post‑launch, as a secret |
