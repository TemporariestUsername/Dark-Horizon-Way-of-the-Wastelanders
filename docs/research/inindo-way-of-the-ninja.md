# Teardown: Inindo: Way of the Ninja (Koei, SNES, 1993)

> A research document on the game's mechanical philosophy. No ROM data, dumps or assets are stored in this repo.

## How this was analysed

| Method | What it gave us |
|---|---|
| **ROM header** | Internal title `ININDO`, LoROM (map `0x20`), 1 MB ROM, 8 KB battery SRAM, no copier header. |
| **Static text scan** | All text is **plain ASCII and uncompressed**. Found the class, magic‑school, training‑site, province, officer, monster, item, equipment and AI‑verb tables, plus a leftover **debug menu**. |
| **Record decoding** | Officer records use a 22‑byte stride, holding a name and two 0–100 ratings, about 105 people in all. The exact byte alignment of the two ratings is unconfirmed. |
| **Headless emulation** | Captured the title, name entry, field map, field command menu, the Lineup formation screen, and the Info → Stats sheet. |

Confidence labels: **[ROM]** from the data, **[ROM‑text]** from strings, **[Emu]** seen in emulation, **[Play]** from knowledge of the game.

## 1. The one‑sentence game
You are the last Iga ninja, out for revenge on Oda Nobunaga in 1582 Japan. You train at sacred mountains to learn magic, recruit a party of ronin, monks and ninja, and take jobs from warring daimyo. All the while a living political map redraws itself month by month around you, until you are strong enough to storm Azuchi castle.

## 2. Core loops

| Loop | Length | Beats |
|---|---|---|
| **Moment** | seconds | Walk the overworld. Encounters start turn‑based grid battles. |
| **Month** | minutes | Daimyo post work "at the beginning of the month". You take a mission (infiltrate, sabotage, spy), do it, get paid, and gain standing. Then the warlords take their turn: attacks, alliances, conquests. |
| **Training arc** | hours | Travel to a sacred mountain, clear its dungeon, and learn a magic school from its master. |
| **Campaign** | 20–40 hours | Gather allies, magic and gear while Nobunaga's reach grows, then infiltrate Azuchi. |

### Time model [Emu][ROM‑text]
- Starts on **June 15, 1582**, right after Honnoji. The text has Nobunaga surviving "*badly burned in the attack on Honnoji temple*".
- The date and gold are shown on the field.
- **The month is the strategic heartbeat**:
  - "*If you want work, you must come at the beginning of the month.*"
  - The debug menu has an "*End month*" command.
  - NPCs talk about people who "*haven't been seen for months*".

## 3. Systems inventory

### 3.1 The living map: provinces and daimyo [ROM][ROM‑text]
- **30 provinces**: Mutsu, Dewa, Rikuchu, Rikuzen, Hitachi, Echigo, Kozuke, Sagami, Boso, Kai, Totomi, Mikawa, Etchu, Mino, Echizen, Omi, Ise, Yamashiro, Tanba, Settsu, Kii, Harima, Izumo, Bitchu, Aki, Iyo, Tosa, Bungo, Hizen, Satsuma. Each has a castle town.
- **15 daimyo houses**, including Date, Uesugi, Hojo, Takeda, Tokugawa, Oda, Mori, Chosokabe, Otomo, Shimazu and the Suzuki (Saika). About 90 named generals sit under them. Each person has two 0–100 ratings, probably war skill and politics/intellect.
- **Province strength**: "*Arms: %3d  Training: %3d*".
- **Daimyo personalities** [ROM] are a set of adjective pairs plus a quality rating:
  - Stubborn / Flexible
  - Responsible / Careless
  - Serious / Carefree
  - **Pro‑Nobu / Anti‑Nobu**
  - Warlike / Peaceful
  - Rated Bad / Fair / Good / Great
- **Diplomacy and war** [ROM‑text]:
  - "*Any alliance could shift the balance of power*"
  - "*canceled the attack on %s*"
  - "*The castle was taken over by Lord …*"
  - "*I've heard rumors of large troop movements in the east.*"
- **The design lesson:** the world plays itself. The player is one ninja in a strategy game that runs on its own. The map changing *without you* is what makes your choices feel political.

### 3.2 Autonomous NPC adventurers [ROM]
- One verb table reads **Move · Attack · Flee · Seek work · Work · Train · Wait · Meet**. That's the action set for wandering characters: rival and recruitable ninja live their own monthly lives on the map.
- There are about 50 named wanderers (Shiranui, Mochizuki, Hiryu, Fuma Koji, Hanzo, and others). They are the pool you recruit from.
- Recruiting depends on your experience: "*The more experience you have, the more likely someone will join you*" and "*I'm not strong enough to join you.*"
- Some wanderers are rivals in training, who challenge you: "*I'm in training, and you're just the challenge I need!*" and "*Your strength is truly great. I surrender!*"
- **Keep (big):** NPCs who pursue their own agendas on the same calendar as you. This is AW's "*think offscreen too*".

### 3.3 Classes and party [ROM][Emu]
- **17 classes**: Our Hero, Iga ninja, Koga ninja, Negoro ninja, Fuma ninja, Mendicant, Sohei (warrior monk), Hermit, Sage, Mystic, Magician, Sorcerer, Samurai, Ronin, Swordsman, and others.
- **Lineup**: a small grid that sets each member's position in battle.
- **Stat sheet** [Emu]: Level, Exp Needed, Health, Energy (mana), Attack, Defend, Resist, Power, Speed, Intel, Luck, Gold.
- **Translate:** classes become **playbooks**, and recruits become NPCs from other playbooks. Formation becomes a skirmish deployment.

### 3.4 Magic: schools and sacred mountains [ROM]
- **12 schools**: Ninjutsu, Fire, Sky, Earth, Mysticism, Cures, Bukyo, Magic, Sorcery, Visions, Evil, Curses.
- **Spells** (about 40, in tiers): Flame → Torch → Blaze → Burn; Wind → Storm → Dragon; Geyser, Quake; Heal tiers; Guard, Speed, Sleep, Vanish, Wings, Gust, Awaken, Revive, Shield, Dizzy, Drain, Unfog, Ghost, Fright, Weaken, Jinx…
- **Training sites**: Iga, Fuji, Tsukuba, Haguro (Dewa), Osore, Oshima, Ontake, Ochi, Ken, Aso, Hiei, plus Tengu, Sado, a Swordsmith, Kusanagi and others.
  - "*Mt. Tsukuba training ground is south of here. There you will learn to heal wounds.*"
  - "*Can you endure rigorous training? I hope you're not a quitter.*"
- **The design lesson:** power is *geographic*. You learn what you can do by *going somewhere* strange and getting through it.
- **Translate:** sacred mountains become **places where the psychic maelstrom runs thin**. Masters become brainers, hocuses and other weird hermits. Spells become Weird moves and augury.

### 3.5 Missions [ROM‑text]
- Mission types: "*Infiltrate the castle*", "*Sabotage the castle*", spying (the **Spy** field command), and "*I want you to sabotage…*".
- On failure: "*Darn! Failed mission.*" On success: "*received a reward.*"
- Doing missions changes how a daimyo regards you and makes their side stronger.
- **Translate:** these become warlord **gigs**: sabotage, infiltrate, spy, deliver, assassinate.

### 3.6 Field commands [Emu]
Search · Lineup · Items · Info (Stats / Items / Magic / Skills) · Magic · **Spy**.

### 3.7 Combat [ROM][Play]
- Turn‑based battle on a grid, with movement, melee, ranged and magic, ordered by speed.
- **Monsters** (about 120) range from bandits, robbers and Oda's thugs, through yokai and beasts (Ironpede, Hydra, Thorn Gator, Kubi Warrior, Ninja Dog, Fire Hound), up to bosses (Mori Ranmaru, and Oda Nobunaga in several forms).
- **Equipment slots**: weapon, helmet, body, ranged/thrown (Shuriken, Shaken, bows, Pistol, Musket, Arquebus), and talisman (Amulet, Talisman, Scarab, Idol).
- **Monster abilities** [ROM]: Flame blow, Cold breath, Flash, Flute, Poison, Sleep, Drain, Mind Control, Reinforce, Renew, Cure, Flight, Lightning.

### 3.8 The antagonist clock [ROM‑text][Play]
- Nobunaga is out of reach at first ("*For the protection of Nobunaga, ordinary citizens are forbidden to approach Azuchi castle*").
- His army moves across the map. "*They say a number of strange men have assembled at Azuchi castle.*"
- The world feels *unsafe* because he keeps advancing, not because there are lots of encounters.

## 4. UI and screen inventory [Emu]
- **Title**: a white‑on‑black brush logo with a blood‑red banner. That's very close to Apocalypse World's two‑tone‑and‑red look.
- **Name entry**: a black window with a cyan frame.
- **Field**: a top‑down overworld. A date and gold box sits top‑right. A status bar along the bottom shows level, name, health (with an icon) and energy.
- **Command window**: a vertical list on the left.
- **Lineup grid** and the **Stats sheet**.

## 5. Pacing observations
- The opening is minimal: a few text cards, then you're dropped into a field with "*There's nothing special*". The world speaks through rumors.
- Early game is a training pilgrimage (Haguro, then Tsukuba, then Fuji). Mid game is mercenary politics. Late game is the infiltration of Azuchi.
- The tension comes from *time spent*: every month you train is a month the warlords move.

## 6. Keep, translate or discard

| System | Verdict | Dark Horizon form |
|---|---|---|
| Monthly strategic turn | **Keep (core)** | The month as an AW "session". The **world turn**: warlords and threats act, and countdowns tick |
| Daimyo personalities | **Keep** | Warlord temperament pairs, including **Hum‑touched / Deaf** (for or against Last) |
| Provinces changing hands | **Keep** | Holds change allegiance through conquest *or* investment (from UWNH) |
| Autonomous wandering NPCs | **Keep (big)** | Named NPCs with wants who live on the calendar: the "*think offscreen too*" principle as a system |
| Recruiting gated by experience | **Translate** | Recruiting gated by **Hx and reputation**, not level |
| 17 classes | **Translate** | Playbooks as protagonists and as crew archetypes |
| Magic schools at mountains | **Translate** | Maelstrom sites in the **In** octant, with weird masters, Weird moves, augury and Ψ‑harm |
| Missions from daimyo | **Keep** | Warlord gigs |
| Grid tactical battles | **Translate** | Skirmishes resolved through **battle moves**, not hit‑point trades |
| Levels and HP | **Discard** | Harm clocks, highlights, improvements |
| Random monster encounters | **Discard** | No random encounters. The Director makes threat moves |
| A villain who stays far away | **Keep** | **Last** at Harrowgate: present in rumors and countdowns, reachable only late |
