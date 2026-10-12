# 18 · Sub‑factions

**Factions** ([17](17-factions.md)) are hardholder powers that own the map. **Sub‑factions** are the people who move *across* it: cults, road gangs, guilds and secret societies. They don't own holds and never hold Lean. Instead they have **chapters** in holds, **Standing** with you, and the power to **back** a faction, which can tip a hold's loyalty without a single barter changing hands.

Where a faction is a country, a sub‑faction is a church, a gang, a union or a conspiracy that lives inside several countries at once. They're where most of the game's **gigs, recruits and services** come from, and where the Choir does its quietest damage.

## How sub‑factions work

### Standing (you and them)
Standing runs from **−100 to +100**, per sub‑faction, like UWNH's guild and port standing ([`subfactions.json`](../../data/rules/subfactions.json)).

| Standing | What it means |
|---|---|
| **+75** | **Sworn friend.** You can use their **perk**. They'll **back** the faction you ask them to, if you give them a reason. |
| **+50** | **Trusted.** Their recruits, services and training hall are open to you. |
| **+25** | **Known.** Their gigs and chapter houses are open to you. You can train skills at their hall ([04](04-characters.md#skills-uwnhs-skill-set)). |
| **0** | **Strangers.** They trade with you at a 10% mark‑up. |
| **−1 to −49** | **Unwelcome.** Their chapters close to you. |
| **−50 or below** | **Hostile.** They become a **threat** on the map (see below), and every chapter acts against you. |

- **Raised by**: their gigs (+10), defending a chapter (+15), feeding their want (+5), and bringing them a recruit or a secret (+10).
- **Lowered by**: attacking members (−20), working against their want (−10), and siding with their enemies (−15).

Your class sets some starting Standings: the Chopper starts at +25 with the Teeth, the Hocus at +50 with the Mourners, the Quarantine at +25 with the Waking.

### Chapters and Presence
- A sub‑faction has a **home** and **chapters** in specific holds. Each chapter gives **Presence 1–3** in that hold.
- **Presence isn't Lean.** It doesn't decide who the hold belongs to. What it does:
  - **Services and gigs** are available at that hold.
  - Their **rumors** show up in that hold's bar.
  - **Hidden Presence**: secret societies' chapters don't appear on the map until revealed by a Sharp check (Scouting helps), the Mirror discipline's *See behind*, a spy gig, a Brainer officer, or the News.

### Backing (how sub‑factions move Lean)
- Each sub‑faction backs **at most one faction** at a time, or none.
- **In every hold where it has Presence, a backing sub‑faction adds Presence × 0.5 to its faction's Lean drift each month.** It's slow, steady weight: five Keeper chapters backing the Lighthouse hold its bridges' towns for it year after year. Five Teeth chapters backing nobody is a lot of unused weight.
- **Switching backing**:
  - In the world turn, sub‑factions shift toward whoever feeds their **want**.
  - The player can shift a sub‑faction's backing with Standing +75 and a Hot check against its leader, with bonuses for giving it a reason it actually cares about.
- **This is the political lever money can't buy.** You can't invest your way into the Teeth's loyalty. You have to ride with them.

### Sub‑factions in the world turn
After faction actions, each sub‑faction takes **one verb**, driven by its want:

| Verb | Who uses it | Effect |
|---|---|---|
| **Grow** | anyone | Opens a chapter in a neighbouring hold (Presence 1) |
| **Work** | guilds | Posts gigs, and moves goods along their routes |
| **Raid** | road gangs | Hits a convoy or hold. That hold's Lean drifts away from its current faction |
| **Preach** | cults | Raises Presence. In Hum‑touched cults, raises that hold's Hum level |
| **Hide** | secret societies | Moves hidden Presence, and plants a cousin or contact |
| **Strike** | the Tankermen | Stops water and fuel along one route (a League‑breaking lever) |
| **Back** | anyone | Switches the faction it backs |

### Sub‑factions as threats
At Standing −50 or worse, or whenever its want collides with your plans, a sub‑faction becomes a **threat** on the map ([05](05-events.md#how-an-event-is-chosen)), tagged with a matching AW kind:
- road gangs are Brutes/*Hunting pack*
- cults are Brutes/*Cult*
- guilds on strike are Brutes/*Mob*
- secret societies are Brutes/*Family*, or a Grotesque if they've been turned

### Turned by the Choir
**Hum‑touched** sub‑factions (the Family and the Cross‑folk at the start, and any sub‑faction whose leader reaches Hum exposure 50) carry hidden **Turning progress** from 0 to 100. It rises each month (the Family by 1.5 from the start, the Cross‑folk by 2 once the Choir is **Spreading**), and by 10 each time a cantor works on them.
- At 100, the sub‑faction **is turned**. Its chapters become Choir instruments: every point of Presence adds 1 Hum a month to that hold, on top of any seep and past every defence, so **a hold with a turned chapter can be Silenced from inside, with no march at all.**
- **Preventing it**: each Hum‑touched sub‑faction has an arc. Each arc beat takes 20 off its Turning; persuading its leader (a Hot check) or exposing the Choir's agent inside it takes 40. Its Turning progress is visible in your journal once you reach Standing +25.
- This is the main reason to care about cults and secret societies you'd otherwise ignore.

---

## Roster

### Cults

#### The Keepers
> *"Keep the light on."*

**Leader**: Kindle, an old woman who has never left the Memphis bridge and knows every crossing by its sound.
**Home**: the Lighthouse.
**Chapters**: Helena, Fork, Spillway, Siege, Derby, Span, Shoals, the Arch. These are the lamps at river crossings.

When the Howling started, someone on the Memphis bridge refused to let the lights go out. Through twenty‑five years of nobody travelling, the Keepers kept lamps lit on bridges and towers so that *if* anyone ever came, they'd find their way. They're the reason the Lighthouse exists, and they're not Clarion's people. They'd close the bridge rather than see it tolled.
- **Want**: every crossing lit and free.
- **Backs**: the Lighthouse.
- **Hum stance**: **Deaf.** The first to be afraid of the Choir.
- **Offers**:
  - **Gigs**: exploration and lamp‑lighting at uncharted crossings.
  - **Recruits**: Angel, Hocus.
  - **Services**: lodging, and charts of the river.
- **Perk (Standing +75), *Light the way***: when you rest at a lit Keeper crossing, every road within a day's drive is revealed, and your next day's travel from there is 10% faster.
- **If hostile**: they close a bridge to you. At a crossing, that's devastating.

#### The Watchers of Tajin
> *"La calma es un regalo. Don't waste it."* (The calm is a gift.)

**Leader**: Quiet.
**Home**: Tajin.
**Chapters**: Southmost, the Fort, the Green, Barrow.

The Watchers have kept vigil on the pyramids of El Tajín since before the Easing. They believe the dead quieted the maelstrom as a gift to the living, and that it has to be *guarded*. Southern voice ([guide](02-world.md#voice-the-bravo-and-the-sierra-coast)).
- **Want**: the Easing kept, and the Loud watched.
- **Backs**: none. They lean friendly toward Cerro.
- **Hum stance**: **Deaf**, and fiercely anti‑Choir.
- **Offers**:
  - **Divining**: a Watcher reads the dust or the dead for you (a discipline map action, for barter).
  - **The Echo discipline** (secondary site).
  - **Recruits**: Brainer, Hocus.
- **Perk (Standing +75), *Watch the edge***: at Southmost, once a month, look into the Loud: reveal one Notional place on the map without spending Grit or gaining Hum exposure.

#### The Cross‑folk
**Leader**: Orchid.
**Home**: Cross (Effingham, on the Seventy).
**Chapters**: Boon, Campus, Granary, the Arch.

They gather under the giant cross where two interstates meet and listen to the wind, which they say carries the dead. They're gentle, hospitable and very easy to frighten. Their crossing at the Arch is where the Hum jumps north once the Choir is **Marching**.
- **Want**: to hear their dead.
- **Backs**: none.
- **Hum stance**: **Hum‑touched.** The Choir's softest target on the Seventy. Their Turning starts once the Choir is **Spreading**.
- **Offers**:
  - **Listening**: they tell you what the wind says about a hold (a rumor that's always true).
  - **Recruits**: Hocus.
  - Lodging on the Seventy.
- **Perk (Standing +75), *Ask the dead***: once a month, at any Cross‑folk chapter, learn one hold's secret (as the Echo discipline's *Ask the dead*) for no Grit.

#### The Mourners
**Leader**: Matilda.
**Home**: Barrow.
**Chapters**: the Fort, Tux, Tajin.

They bury the dead properly in a world that mostly doesn't. If you play the Hocus, these are your followers.
- **Want**: the dead buried right, and the Opened given back.
- **Backs**: none.
- **Hum stance**: Deaf.
- **Offers**:
  - **Recruits**: Angel, Hocus.
  - **The Mend discipline**.
- **Perk (Standing +75), *Wake for the dead***: after a battle, crew deaths cost no grief modifier, and the Mourners' Standing rises by 5.

### Road gangs

#### The Teeth
> *"Pay, or we eat."*

**Leader**: Dremmer, the Alpha wolf.
**Home**: the Teeth (a mobile camp in the Permian).
**Chapters**: Twice, Drift, Brand, the Stack, Gullet, Rumhouse.

The biggest raider pack on the map, a moving city of bikes and war rigs that has followed Dremmer since the Howling emptied the open roads and so made them *his*. They're not a power that wants to *govern*: they want the road, tribute and a fight.
- **Lieutenants**: Rufe (Rumhouse), Crine (Drift), Ik (Gullet).
- **Want**: tribute, and the open road.
- **Backs**: none. Sweetwell's Chel pays them to stay off the springs, and they **raid Burning Water's crude convoys** from Nodders and Derricks.
- **Hum stance**: Deaf.
- **Offers**:
  - **Gigs**: raids.
  - **Recruits**: Chopper, Gunlugger.
  - **The tooth mark**: raiders leave you alone in the west.
- **Perk (Standing +75), *Ride with the Teeth***: once a month, call a Teeth raid pack (troops 20, arms 50, training 20, *savage*, *mobile*) to ride with you for one road war or gang war.
- **If hostile**: a *Hunting pack* on every western road.
- **Chopper note**: replacing Dremmer as Alpha wolf is the Chopper's arc.

#### The Gar
**Leader**: Bon.
**Home**: Barge Town.
**Chapters**: Crawdad, Bluff, Helena, Kettle.

Delta mud‑runners in airboats and swamp buggies. They know every ford and backwater on the lower Mississippi. They raid barges and crossings, and **Clarion pays them** to stay off her stretch of the river.
- **Want**: the river.
- **Backs**: none, but whoever pays more.
- **Hum stance**: Deaf.
- **Offers**:
  - **Unofficial crossings** of the Mississippi at fords, for a price.
  - **Recruits**: Driver, Battlebabe.
- **Perk (Standing +75), *Gar crossing***: once a month, cross the Mississippi anywhere in the Delta at night, with no crossing needed.
- **If hostile**: they ambush you at fords and crossings.

#### The Twister Riders
**Leader**: Gale.
**Home**: Stockade.
**Chapters**: Rock, Gallows, Hub.

Storm chasers on the plains of the Forty. They follow twisters for what they tear open, and they read the sky better than anyone alive.
- **Want**: salvage and speed.
- **Backs**: none.
- **Hum stance**: Deaf.
- **Offers**:
  - **Weather reading** (twisters announced a day early).
  - **Recruits**: Driver.
- **Perk (Standing +75), *Ride the storm***: in twister season, use a twister as cover: +30% to escape any road war, and raiders can't find you for a day.

#### The Whiteout
**Leader**: Icicle.
**Home**: Mill Town (in winter).
**Chapters**: the Loop, Brewhouse, Burnriver.

Winter raiders on the Lakes' ice roads, Highwater's oldest enemy. In summer they're steelworkers. In winter they're ghosts on the ice.
- **Want**: Highwater's freight.
- **Backs**: none. They're natural allies of anyone fighting Highwater.
- **Hum stance**: Deaf.
- **Offers**:
  - **Ice raids**.
  - **Recruits**: Chopper.
- **Perk (Standing +75), *Whiteout***: in winter, your convoy can vanish on the ice: escape from any road war on lake ice always succeeds.

### Guilds

#### The Wheelwrights
**Leader**: Lars.
**Home**: Motor.
**Chapters**: Gnarly, the Track, Sinkhole, Rails, Spaghetti.

The mechanics' guild. If it has wheels, a Wheelwright can keep it rolling, for a price and a part.
- **Want**: parts, and golden‑age frames.
- **Backs**: none.
- **Hum stance**: Deaf.
- **Offers**:
  - **Repairs** and **frame upgrades**.
  - **Rig sales**.
  - **Recruits**: Savvyhead, Driver.
- **Perk (Standing +75), *Guild garage***: at any Wheelwright chapter, remove a rig's weakness in a day instead of a month, and refits cost 25% less.

#### The Tankermen
**Leader**: Partridge.
**Home**: Partridge.
**Chapters**: Burning Water, Sweetwell, Highwater, Falcon, Tampico, the Lighthouse.

The haulers who move water and fuel between factions that hate each other. Every faction needs them, so no faction owns them. **They can strike.**
- **Want**: fair rates, and safe roads.
- **Backs**: none, on principle.
- **Hum stance**: Deaf.
- **Offers**:
  - **Tanker contracts**.
  - **Recruits**: Driver.
- **Perk (Standing +75), *Union card***: no faction's embargo applies to your tankers, and Tankermen drivers work for half wages.
- **If hostile, or striking**: water and fuel stop moving on a route. Strikes are a **League‑breaking lever**, and a League‑saving one.

#### The Players
**Leader**: Lala.
**Home**: Beale.
**Chapters**: Crossroads, Strings, Orleans, Shoals, Pier Saint, Circus.

Musicians, performers and skinners working the old music road from Orleans up through Crossroads and Memphis to Nashville. They carry songs, and songs carry news.
- **Want**: audiences, and safe roads between gigs.
- **Backs**: none.
- **Hum stance**: Deaf, and they hate the Choir's singing.
- **Offers**:
  - **Rumors**.
  - **Morale** (a hold with a Players chapter has −1 to affliction severity).
  - **Recruits**: Skinner, Maestro D'.
- **Perk (Standing +75), *Play the room***: +10% on Hot checks in any hold with a Players chapter.

#### The Diggers
**Leader**: Newton.
**Home**: Fuse.
**Chapters**: the Vault, Hangar, Dustwich.

The salvage guild: vault crackers, ruin divers, rocket‑garden strippers. They work under contract to the Exchange, and they resent it.
- **Want**: dig rights, and the Vault's door.
- **Backs**: the Exchange, reluctantly.
- **Hum stance**: Deaf.
- **Offers**:
  - **Golden‑age tech**.
  - **Project parts** (Savvyhead).
  - **Recruits**: Savvyhead.
- **Perk (Standing +75), *Dig rights***: salvage a Ruin Sight a second time.

#### The News
**Leader**: Omie Wise.
**Home**: the Lighthouse (the desk).
**Chapters**: Orleans, Highwater, the Exchange.

They buy charts and sell truth. They print the **Month Report**. Every faction wants them on its side, and every faction is a little afraid of them.
- **Want**: the truth, first.
- **Backs**: none, ever.
- **Hum stance**: Deaf.
- **Offers**:
  - **Buys charts and Sights**.
  - **Sells rumors**.
  - **Recruits**: Quarantine‑types and other outsiders.
- **Perk (Standing +75), *Print it***: once a season, publish a truth you can prove (a faction's secret, or a sub‑faction's hidden Presence). That truth becomes common knowledge map‑wide, and the exposed party loses 10 Lean in its holds, or 1 Presence.

### Secret societies

#### The Family
> *"There's always room at the table."*

**Leader**: Mother Krin, the Hive queen. Warm, terrifying, hungry.
**Home**: Krin's Nest.
**Chapters (hidden)**: Junction, the Reserve, the Pumphouse, Mammoth, Anchorage, Barge Town, the Loop.

Under the salt domes and pipeline tunnels, Mother Krin took in everyone the Howling broke. The Family is enormous, mostly unseen, and everywhere: cousins at every table, kin‑words for strangers, a door that opens from the inside.
- **Want**: strays, and meat.
- **Backs**: none in the open. **Hostile to Burning Water**, which covets the Reserve they live beside.
- **Hum stance**: **Hum‑touched.** Mother Krin hears something in the dark. Their Turning runs from the start, and if they're turned, **every hidden chapter becomes a door for the Choir.**
- **Offers**:
  - **The tunnel key** (travel in the Down, under the rivers).
  - **Spy gigs**.
  - **Recruits**: any.
- **Perk (Standing +75), *Cousin***: reveal every hidden Presence in a hold, or plant your own (Presence 1, hidden).

#### The Waking
**Leader**: H.
**Meets at**: Junction.
**Chapters (hidden)**: Hangar, Dome, Fuse.

A society of people who have found *other* stasis bunkers, empty ones. They know Last came out of one. Some want to warn the world. Some want to wake whoever else is still asleep.
- **Want**: every stasis facility found.
- **Backs**: none.
- **Hum stance**: Deaf, but split. A faction inside the Waking wants to wake "*more like Last*".
- **Offers**:
  - **Stasis lore** (Quarantine arc beats).
  - **Bunker locations**.
- **Perk (Standing +75), *Wake the sleeper***: open a sealed stasis pod. What comes out is a story beat: a recruit, a memory, or something worse.

#### The Odd Lot
**Leader**: Dog head.
**Home**: Dog Head.
**Chapters (hidden)**: Rumhouse, Casino, Mobile, Haven, Gemela.

Fences and smugglers. They'll move anything past any toll or embargo. Anything except people: the Odd Lot drew that line when Tum Tum's coffles started using their roads.
- **Want**: margin.
- **Backs**: whoever pays.
- **Hum stance**: Deaf.
- **Offers**:
  - **Contraband** trade.
  - **Smuggling** past embargoes and tolls.
  - **Recruits**: Driver, Skinner.
- **Perk (Standing +75), *Off the books***: once a month, make one trade that saturation, embargo and tribute don't touch.

### Not a sub‑faction: the Catchers
**Tum Tum's Catchers** are the Choir's arm ([17](17-factions.md#the-choir-the-nobunaga-faction)). They don't have Standing, chapters or a perk, and you can't join them.

---

## Chapters
The single source for sub‑faction Presence at the start (★ is the home; *(h)* is hidden):

| Sub‑faction | Type | Home | Chapters | Backs at start | Hum |
|---|---|---|---|---|---|
| The Keepers | Cult | ★ the Lighthouse | Helena, Fork, Spillway, Siege, Derby, Span, Shoals, the Arch | The Lighthouse | Deaf |
| The Watchers | Cult | ★ Tajin | Southmost, the Fort, the Green, Barrow | — | Deaf |
| The Cross‑folk | Cult | ★ Cross | Boon, Campus, Granary, the Arch | — | **Touched** |
| The Mourners | Cult | ★ Barrow | the Fort, Tux, Tajin | — | Deaf |
| The Teeth | Road gang | ★ the Teeth | Twice, Drift, Brand, the Stack, Gullet, Rumhouse | — | Deaf |
| The Gar | Road gang | ★ Barge Town | Crawdad, Bluff, Helena, Kettle | — | Deaf |
| The Twister Riders | Road gang | ★ Stockade | Rock, Gallows, Hub | — | Deaf |
| The Whiteout | Road gang | ★ Mill Town | the Loop, Brewhouse, Burnriver | — | Deaf |
| The Wheelwrights | Guild | ★ Motor | Gnarly, the Track, Sinkhole, Rails, Spaghetti | — | Deaf |
| The Tankermen | Guild | ★ Partridge | Burning Water, Sweetwell, Highwater, Falcon, Tampico, the Lighthouse | — | Deaf |
| The Players | Guild | ★ Beale | Crossroads, Strings, Orleans, Shoals, Pier Saint, Circus | — | Deaf |
| The Diggers | Guild | ★ Fuse | the Vault, Hangar, Dustwich | The Exchange | Deaf |
| The News | Guild | ★ the Lighthouse | Orleans, Highwater, the Exchange | — | Deaf |
| The Family | Secret society | ★ Krin's Nest | *(h)* Junction, the Reserve, the Pumphouse, Mammoth, Anchorage, Barge Town, the Loop | — | **Touched** |
| The Waking | Secret society | ★ Junction *(h)* | *(h)* Hangar, Dome, Fuse | — | Deaf (split) |
| The Odd Lot | Secret society | ★ Dog Head | *(h)* Rumhouse, Casino, Mobile, Haven, Gemela | — | Deaf |
