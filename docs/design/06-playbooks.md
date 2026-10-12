# 06 · Playbooks as Classes

Apocalypse World's playbooks are Dark Horizon's **classes**. They do two jobs:
1. **Protagonists.** These are UWNH's six captains, each with a different *career*.
2. **NPC classes.** These are Inindo's classes: officers, rivals, and the people you recruit.

**What comes from AW, and what doesn't.** Each class keeps its playbook's name, voice, look lists, signature asset and **move names**, which become **class abilities**. The *rules* are UWNH's and Inindo's: attributes from 1 to 100, levels on three tracks, abilities with numeric effects ([04](04-characters.md)). Class data lives in `/data/classes/*.json` (arriving with M2).

## How a class is built
Every class defines:
- **Starting attributes**, totalling about **180** across Cool, Hard, Hot, Sharp and Weird.
- **Growth**: the share of each level‑up's 4 points that goes to each attribute (Inindo's class growth). The track you levelled in also pulls points toward its attributes ([04](04-characters.md#levels-three-experience-tracks-uwnh)).
- **A main track**: Road, Trade or Fight. It's the track where the class's abilities mostly unlock.
- **Starting skills** at rank 1, and **class Luck**.
- **Seven abilities**, each unlocking at a set level in a set track. They use the AW move names, with numeric effects.
- **A signature asset**: the thing only this class owns ([12](12-progression.md#2-the-signature-asset)).
- **A start**, an **arc** of five acts, and **endings**.

## Common to every protagonist
- **Creation**: name and look (from the playbook's lists), then a small **attribute adjustment** (move up to 15 points between attributes), a starting weapon, and the class's asset.
- **Starting questions.** Your starting officers each ask one question about the others (for example, the Driver's: "*Which one of you once rode with me?*"). The answers set their starting loyalty and come back in story beats.
- **Every class can do everything**: trade, drive and fight. The class makes one career *special* and *cheap*, not the others impossible. This is UWNH's freedom of career.
- **Factions.** Each class has a natural patron and a natural enemy among the [factions](17-factions.md#playbook-affinities-defaults-never-locks). These are defaults, never locks: any class can swear to any faction, or to none.
- **Cameos.** In each campaign, the other five protagonists exist as named NPCs with arcs that run on their own (Wanderer AI plus authored beats). Meeting them crosses the stories over, as UWNH does.
- **No deadline.** Arcs run at your pace. The Choir's spread doesn't end the game. It decides how dark your ending is ([below](#endings-and-the-choirs-reach)).

## The six launch classes

### 1. The Driver: *the dark horizon*
> "*In Apocalypse World the horizons are dark, and no roads go to them.*"

| | |
|---|---|
| **Career** | Explorer and courier (UWNH's adventurer path) |
| **Attributes** | Cool 50 · Hard 25 · Hot 30 · Sharp 45 · Weird 30 |
| **Growth** | Cool 35% · Sharp 30% · Weird 15% · Hot 10% · Hard 10% |
| **Main track · skills · Luck** | Road · Driving 1, Navigation 1 · 12 |
| **Signature asset** | **The car**: a frame with its looks, a weakness and a **hood ornament**, and +1 range tier for supplies. **Sights** and **first contacts** give the Driver double XP and Renown. The Driver is the class built for the Easing: the first person in a generation to drive these roads for a living. |
| **Campaign verbs** | **Chart** (fog reveals at double radius, and charts sell to the News) · **Stash** (leave supply caches) · **Run** (courier gigs with deadlines) · **Find the Out** |
| **Start** | Gnarly's garage, a truck stop on the Fifty‑Five (the Crossing) |
| **Arc** | I. *Gnarly's debt*: run three deliveries down roads nobody's driven since the Howling. II. *A map that isn't*: a golden‑age atlas with a road marked in red ink that isn't on any other map. III. *Last Stop*: first reach the edge of the Loud. IV. *Who else is looking*: Rothschild wants your charts, exclusively. V. *How far the Quiet goes*: drive into the Loud. |
| **Endings** | **Into the Loud**: drive an interstate off the edge of the map and find what's past it; your crew decides whether to follow. **The road home**: chart every road in the Quiet, and the holds live by your maps. **The courier of the Hum**: if the Choir is **Marching** or worse and your Hum exposure is 50 or more, drive its message to every hold. |
| **Cameo in other runs** | A named Driver who sells charts at the Lighthouse and goes missing near Last Stop in month 20 or so |

| Ability | Unlocks | Effect |
|---|---|---|
| **Combat driver** | Road 1 | Your rig gets +10 Handling, and its guns +15 hit chance, while you drive it |
| **Weather eye** | Road 3 | Forecast weather 2 days ahead. Fog and snow slow you 50% less |
| **Eye on the door** | Road 5 | Fleeing any battle gets +30%. Once per battle, if your Speed is at least the enemy's, it simply works |
| **Daredevil** | Fight 6 | When you drive straight into contact range, +3 Armor and +25% Ram damage that turn |
| **Reputation** | Road 8 | Explorer Renown gains +25%. Recruit chance +10 in holds that know your name |
| **Collector** | Trade 8 | Own up to 2 more personal cars, each with its own hood ornament (bonuses stack across the convoy) |
| **My other car is a tank** | Road 14 | A battle vehicle: 2 extra gun mounts, Armor +3, Durability +40 |

### 2. The Chopper: *every road belongs to my pack*

| | |
|---|---|
| **Career** | Raider and warlord‑in‑waiting (UWNH's pirate path) |
| **Attributes** | Cool 40 · Hard 50 · Hot 25 · Sharp 30 · Weird 35 |
| **Growth** | Hard 35% · Cool 25% · Weird 15% · Sharp 15% · Hot 10% |
| **Main track · skills · Luck** | Fight · Brawling 1, Driving 1 · 10 |
| **Signature asset** | **The gang**: about 15 riders on bikes (troops 15, arms 50, training 30, tag *savage*). The gang eats: it needs chow, pay and **action** every month, or its morale falls and someone makes a bid to lead it ([11](11-crew-and-bonds.md#wages-and-loyalty)). |
| **Campaign verbs** | **Raid** caravans and straggler camps (road war, then take cargo) · **Tribute** (shake down holds; their Lean drops and your Raider Renown rises) · **Grow** (recruit from defeated gangs) · **Challenge** (a duel for another gang's leadership) |
| **Start** | Dog Head fence market on the Houston ship channel (the Ten), in Dremmer's shadow |
| **Arc** | I. *The pack is hungry*. II. *Dremmer notices*: tribute or war. III. *A bid for alpha*: someone in your own gang. IV. *The Teeth*: take Dremmer's camp, or bow. V. *Choppers don't hum*: the Choir offers your gang purpose. |
| **Endings** | **King of the road**: replace Dremmer as Alpha wolf. **The pack scatters**: you lose the gang and ride alone. **Fucking thieves**: steal the dish core from Harrowgate; every hold within 600 km of it loses 40 Hum, and the Choir's voices are halved. |
| **Cameo** | A chopper whose gang raids your caravans, and who might be recruited |

| Ability | Unlocks | Effect |
|---|---|---|
| **Pack alpha** | Fight 1 | Your gang gets +15 training. Bids for its leadership are answered with a Hard check at +20 |
| **Fucking thieves** | Trade 1 | Once per hold visit, "find" a wanted item in the gang's stash: chance 40 + Sharp ÷ 2 |
| **Nomadic** | Road 4 | The gang needs 25% less chow and water, and moves off‑road at full speed |
| **Well‑armed** | Fight 5 | Gang arms +20. Bought weaponry counts double for arms |
| **Self‑sufficient** | Trade 7 | Raids also yield chow and fuel. Pay can be skipped for one month a year without loss |
| **Well‑disciplined** | Fight 10 | Gang gains the *well‑disciplined* tag (+20 training, breaks only below 20 morale) |
| **A holding of your own** | Fight 15 | Take a hold by gang war and make it your seat, with its own Wealth |

### 3. The Hardholder: *my caravans feed half the Quiet*

| | |
|---|---|
| **Career** | Merchant prince and governor (UWNH's trader path, with a home) |
| **Attributes** | Cool 30 · Hard 40 · Hot 45 · Sharp 45 · Weird 20 |
| **Growth** | Hot 30% · Sharp 30% · Hard 20% · Cool 15% · Weird 5% |
| **Main track · skills · Luck** | Trade · Trading 1, Gunnery 1 · 8 |
| **Signature asset** | **The hold**. You choose a starting hold (Partridge, Anchorage or Saltlick) and set it up from AW's holding options (size, surplus, want, armory, walls, gang). **You're the only protagonist with a fixed home.** You govern from the Seat and send **caravans** (convoys led by NPC captains) along trade routes, as UWNH's fleet captains do. |
| **Campaign verbs** | **Govern** (settle disputes in the hold, set the tithe) · **Dispatch** (send caravans on standing routes) · **Invest** (buy influence in other holds; you're the best at moving Lean) · **Defend** (gang war at your walls) |
| **The tension** | You can ride with a caravan yourself, but **while you're gone, Wealth yields 30% less** and threats get bold. This is AW's "*serious and immobile home base*", as a number. |
| **Arc** | I. *Want*: the hold is hungry. II. *Routes*: the first standing caravan. III. *Grome's price*: the water leash. IV. *Allegiance*: five holds lean your way, and the factions notice. V. *Refuge*: the Hum's refugees arrive at your gates. |
| **Endings** | **Hardholder of the Quiet**: 10 or more holds leaning to you, a new power. **Walls**: your hold stands, sealed and deaf, even if the Choir is **Drowning**. **Gave it away**: hand the hold to its people (a quiet ending, with epilogue text from them). |
| **Cameo** | Partridge's hardholder, who offers you caravan contracts |

| Ability | Unlocks | Effect |
|---|---|---|
| **Wealth** | Trade 1 | Each month the hold yields 2 + hold size + Trade level ÷ 4 barter, if its wants are met. An unmet want costs the yield instead |
| **Leadership** | Fight 1 | Leading your gang, your leader modifier is 1.15 (not 1.0), and it breaks only below 20 morale |
| **Caravans** | Trade 3 | Send 1 standing caravan, +1 for every 4 Trade levels |
| **Investment** | Trade 5 | Your investment moves Lean 25% further |
| **Armory** | Fight 6 | Your hold's gang arms +20 |
| **Walls** | Trade 10 | Your hold's walls +1 (to a maximum of 2) |
| **Hardholder of the Quiet** | Trade 15 | Audience with any faction hardholder whatever your Renown. Holds leaning to you send tribute |

### 4. The Hocus: *they follow me because I hear what it says*

| | |
|---|---|
| **Career** | Prophet and cult leader (a new career, and the mirror image of Last) |
| **Attributes** | Cool 25 · Hard 25 · Hot 45 · Sharp 30 · Weird 55 |
| **Growth** | Weird 35% · Hot 30% · Sharp 15% · Cool 10% · Hard 10% |
| **Main track · skills · Luck** | Road · Lore 1, Medicine 1 · 14 |
| **Signature asset** | **Followers**: a cult, family or students, with a number and a **devotion** (0–100). **Faith** is a form of Lean: holds can lean to *you* through faith rather than investment. |
| **Campaign verbs** | **Preach** (*Frenzy* on a hold's crowd) · **Divine** (discipline map actions; see [04](04-characters.md#disciplines-inindos-magic-schools)) · **Convert** (rival cults, and Hum‑touched holds) · **Counter‑broadcast** (later, against Last) |
| **Start** | Barrow, the mourners' hold (Sierra Coast). Far from everything, a long voyage to anywhere |
| **Arc** | I. *The dead are loud lately*. II. *Followers want*. III. *A rival voice*: Last's missionaries reach Barrow. IV. *Speak to the Choir*. V. *Which of you is right?* |
| **Endings** | **Two prophets**: defeat Last's theology in a final *Frenzy* at Harrowgate. **Become the Choir**: take Last's place. **Silence**: lead your followers to *contain* the maelstrom fragment, which has a cost. |
| **Note on *Frenzy*** | AW's "*orgy of uninhibited emotion*" plays as a crowd frenzy of lamenting, fighting, sharing and celebrating. Anything sexual stays off‑screen, per the [content policy](00-vision.md#tone-and-content-policy). |
| **Cameo** | A hocus at Barrow who might become your ally against the Hum, or your rival |

| Ability | Unlocks | Effect |
|---|---|---|
| **Fortunes** | Trade 1 | Each month, followers yield 1 + followers ÷ 10 barter if devotion is 50 or more; below 30 they want something instead |
| **Seeing souls** | Road 3 | See an NPC's want and loyalty on sight. +15% on Hot checks against people you've seen |
| **Charismatic** | Trade 3 | Recruit chance +15. Faith Lean +25% |
| **Frenzy** | Fight 4 | (Grit 15) A crowd or a gang acts as you say for a battle or a scene: +30 morale to your side, or −30 to theirs |
| **Fucking wacknut** | Road 6 | +10 Weird while in the In, and Hum exposure gains −30% |
| **Divine protection** | Fight 8 | +5 Defense, and +10 against Hum damage |
| **Speak to the Choir** | Road 15 | Talk to cantors and the Opened in battle; a success makes them stand still for 2 turns |

### 5. The Savvyhead: *things break*

| | |
|---|---|
| **Career** | Salvager and engineer (UWNH's exploration and shipbuilding, rolled together) |
| **Attributes** | Cool 30 · Hard 25 · Hot 30 · Sharp 50 · Weird 45 |
| **Growth** | Sharp 35% · Weird 25% · Cool 15% · Hot 15% · Hard 10% |
| **Main track · skills · Luck** | Road · Wrenching 1, Lore 1 · 10 |
| **Signature asset** | **The workspace**: a garage, lab or infirmary, as in AW. **Projects** take calendar time, parts and sometimes a site: better rigs, water condensers, a **Static jammer** against the Hum. Golden‑age tech recovered from the **Down** and **Up** feeds them. |
| **Campaign verbs** | **Salvage** (Down and Up dungeon crawls: Inindo's mountain dungeons) · **Build** (projects that take real calendar time) · **Fix** (other people's stuff, for Rep and barter) · **Read** machines and sites |
| **Start** | Dustwich container stacks at the old port of Orleans (the Ten) |
| **Arc** | I. *Things break*: Dustwich's pump. II. *The rocket garden at Fuse*, up the Sixty‑Five. III. *Wisher's mast*: what the antennas are for. IV. *Build the jammer*. V. *The Gondola*: get above the Choir. |
| **Endings** | **Static**: the jammer stops the Choir spreading for good, and Silenced holds slowly come back. Whether the Quiet holds without it is answered in the epilogue, by what you learned in the In. The maelstrom is cut off for everyone, hocuses included. **Sweet water**: fix the Pumphouse and open the old water mains under the Ten, which breaks Grome's leash. **Keep it running**: you become Harrowgate's mechanic. |
| **Cameo** | Newton of Fuse, a rival digger who has the part you need |

| Ability | Unlocks | Effect |
|---|---|---|
| **Things speak** | Road 1 | Examining salvage tells you its history. Salvage and charts are worth +20% |
| **Spooky intense** | Fight 3 | Talk in battle gets +20. Enemies with low morale may flee from you |
| **Oftener right** | Trade 3 | When an officer makes a check on your advice, +10 |
| **Bonefeel** | Road 4 | Scouting +15%. You're never surprised by an ambush: your party always acts first |
| **Reality's fraying edge** | Fight 5 | +5 Defense, and +5 more against Hum damage |
| **Deep insights** | Road 8 | Projects take 25% less time. Disciplines cost 20% less Grit |
| **The jammer** | Road 14 | Begin the Static jammer project (needs parts from the Up and the Down) |

### 6. The Quarantine: *I was there before*

| | |
|---|---|
| **Career** | Soldier out of time. **The main‑quest spine**, like Inindo's hero |
| **Attributes** | Cool 40 · Hard 45 · Hot 35 · Sharp 45 · Weird 15 (locked) |
| **Growth** | Hard 30% · Sharp 25% · Cool 25% · Hot 20% · Weird 0% until it opens, then 20% (taken evenly from the others) |
| **Main track · skills · Luck** | Fight · Gunnery 1, Medicine 1 · 10 |
| **Signature asset** | **Stasis**: a hidden facility (AW's Quarantine stasis options, such as the *medlab*). **A sane modern sensibility**: you see **golden‑age names under the new ones** on the map, read old road atlases perfectly (breaks surprise you half as often), and can **operate** golden‑age machinery without a Savvyhead. **Weird is locked at the start** (AW's "Weird—"). It opens in Act III. |
| **Campaign verbs** | **Remember** (fragments of the before, triggered at golden‑age sites) · **Advise** (*Eager to know* makes NPCs a quest compass) · **Lead** (officers grow faster under you) |
| **Start** | Waking in a sealed stasis bunker in the Deep Lines, beneath Junction, a year into the Easing (nobody would have found you during the Howling) |
| **Arc** | I. *Out of the box*: Junction, then the Lighthouse. II. *What year is it*: the world as it is now, and the old names under the new ones. III. *Another empty pod*: someone woke before you. IV. *Last's name*: you knew them, before. V. *Harrowgate*: the reckoning. |
| **Endings** | **Shut it down**: you end the broadcast; Last dies or goes back into stasis (your choice). **Join them**: Last was right, and you open your brain. **Back in the box**: you seal yourself and the Choir's core in stasis together. |
| **Cameo** | A strange soldier asking strange questions around Junction |

| Ability | Unlocks | Effect |
|---|---|---|
| **Leave no one behind** | Fight 1 | Moving to a downed ally gives +2 move that turn and stabilises them |
| **Eager to know** | Road 1 | Ask an NPC for advice. Following it gives +20 on the check; ignoring it and failing gives double XP |
| **Inspiring** | Fight 4 | Allies adjacent to you get +10 accuracy. Officers earn +20% XP |
| **Medlab** | Trade 5 | Resting at the stasis facility heals the party fully in 3 days; the gravely wounded always live |
| **Release** | Fight 8 | Once per battle, an all‑out attack at double damage, after which your Defense is 0 until your next turn |
| **Combat veteran** | Fight 12 | +10 accuracy with firearms and +2 Speed |
| **Stasis armory** | Trade 12 | A golden‑age rifle and armour (Attack 30, Defense 18) from the vault |

## Endings and the Choir's reach
No class ending is gated by a deadline. When you trigger an ending, the **Choir's reach at that moment** ([17](17-factions.md#the-choir-the-nobunaga-faction)) decides its colour:

| Reach at the end | Effect on endings |
|---|---|
| **Whispers** or **Spreading** (0–14 Silenced) | Full versions of the ending, with an epilogue for every hold you touched |
| **Marching** (15–29) | Bittersweet: the ending is coloured by the Hum. Some holds are lost, and some crew are *listening* |
| **Drowning** (30+) | **Everybody hears it.** Each class has a dark ending in which its arc is resolved *inside* the Hum. They're bleak, not game‑overs. |

## The rest of the roster (crew archetypes and unlockable protagonists)
These are recruitable as **officers and companions**, each with its own attributes, growth and abilities.

| Class | As an officer or companion | Unlock as protagonist |
|---|---|---|
| **Angel** | A medic: Medicine 2 at the start, and an infirmary on the road. Signature: the angel kit and its stock. | v1.1 |
| **Battlebabe** | A duellist, best in leader duels. *Dangerous & sexy*: +15% on Hot checks in hold scenes. | v1.1 |
| **Brainer** | Reads people (sees wants and secrets), helps with interrogation, and supports disciplines. Transfixion abilities are **non‑sexual**. | v1.2 |
| **Gunlugger** | Battle muscle. *NOT TO BE FUCKED WITH*: counts as 10 troops in a gang war. | v1.1 |
| **Maestro D'** | Runs an establishment: a bar where you recruit and hear rumors. *Everybody eats, even that guy* works as an information network. | v1.2 |
| **Skinner** | Social leverage: Hot abilities, beauty as a luxury good, hold morale. | v1.2 |
| **Faceless** | A rare recruit. Gigantic violence, mask lore, tragedy. | Post‑launch |
| **Waterbearer** | *The Source*: whoever has them can break Grome's leash. A story NPC at launch. | Post‑launch |
| **News** | Buys your maps and your truth. Writes the **Month Report**. A story NPC at launch. | Post‑launch |
| **Child‑thing** | "*We are coming.*" A late‑game horror thread tied to the Hum. | Post‑launch, as a secret |
