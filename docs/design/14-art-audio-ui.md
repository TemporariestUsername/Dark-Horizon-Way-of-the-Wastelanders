# 14 · Art, Audio and UI

## Visual identity: "chrome, dust and fire"
The look is **full‑colour pixel art inspired by the Mad Max films**: sun‑blasted desert roads, kitbashed war machines, war paint, smoke and fire. It is *inspired by*, never copied (see [the IP guardrail](#ip-guardrail)). Apocalypse World still supplies the *people and the voice*. The art carries the heat.

**Rules:**
1. **A hot world, one cold enemy.** The world is drawn in heat: ochre, burnt orange, rust and bone by day, steel‑teal and sodium‑orange at night. **The Choir is the only cold thing on the map**: bleached white, a **violet** Hum glow, and static. The player learns to read cold and violet as danger. No faction, sub‑faction or hold uses violet.
2. **A restricted master palette** of about **48 colours**, built as ramps: rust, ochre, sand, bone, chrome, oil‑black, sky‑teal, fire, blood, and the Choir's white‑violet. Every region draws from it with its own emphasis (below).
3. **Silhouette first.** Rigs, people and threats have to read as solid shapes at 1× scale. Rigs are **kitbashed**: welded plates, spikes, skulls, roll cages, mismatched wheels, exhaust stacks. People wear scavenged armour, goggles, war paint and banners.
4. **Movement and particles carry the energy.** Dust plumes behind every convoy, heat shimmer on the asphalt, exhaust flame, sparks off scraping metal, smoke columns from burning wrecks you can see from far away on the map.
5. **The In is a fever.** The In layer pushes the palette to oversaturated magenta, gold and black, with the road warped and doubled.
6. **Scale.** Native 480×270 pixel art with 16×16 tiles. Portraits are 64×80, painted in the same palette with hard light from one side.

### Regional palettes
Each region shifts the master palette, so the player knows where they are at a glance:

| Region | Palette | Light |
|---|---|---|
| Rag‑Wastes, the Forty, the Ten (west) | Dust orange, rust, bleached sand | Hard midday glare; red dust storms |
| The Delta, the Crossing | Fog green, mud brown, oily black water | Low, wet, hazy |
| The Lakes, Seventy‑Five | Cold steel blue, frost white, wet asphalt | Grey and flat; ice glints |
| The Glass | White‑hot sand, glass glare, black shadow | Overexposed; the brightest region in the game |
| Sierra Coast | Jungle green, terracotta, sea teal | Humid, dappled |
| The Seventy, the Sixty‑Five | Wheat gold, sky blue, red barns rusted brown | Long golden evenings |
| Bravo, Thirty‑Five | Ochre, cement grey, mesquite green | Dry and dusty |
| The Down | Sodium orange lamps, tunnel black | Pools of light |
| The Up | Thin‑air blue, snow, cable‑car steel | Cold and clear |
| Harrowgate and Hum zones | Everything drains toward **bleached white**, with **violet** glow at the edges | Still, silent, wrong |

As a hold's **Hum level** rises, its tiles lose saturation step by step. A Marked hold looks washed out. A Silenced hold is white and violet.

## IP guardrail
"Closer to Mad Max" means its **energy and palette**, not its designs:
- **No replicas** of the films' vehicles (no recognisable copies of the hero cars or the battle rig), masks, characters, costumes, gangs or rituals.
- **No quotes, catchphrases or near‑quotes** from the films, and no names lifted from them: the heaviest frame is a *battle rig*.
- Every vehicle, faction look and costume is designed from **Dark Horizon's own setting**: its factions, regions and sub‑factions. The [faction table](#faction-marks) is the source.
- Art reviews include a "could this be mistaken for a film still?" check. If yes, it's redrawn.

## Key screens

| Screen | Lineage | Contents |
|---|---|---|
| **Title** | Inindo, UWNH | *DARK HORIZON* in welded steel letters over a convoy on an empty interstate at sunset, dust behind it, a broken overpass and a smoke column on the horizon. "New / Continue". |
| **Class select** | UWNH's 3×2 portrait grid | Six portrait cards, each with its signature asset behind it. Hover shows the playbook blurb and its italic "*Warning:*" line. |
| **Character creation** | Inindo | Portrait and look choices, attributes with the class's starting values and growth bars, the adjustment points, the starting officers' questions. |
| **The overworld** | UWNH sea map | The road network as the sea: interstates as wide, sun‑bleached asphalt bands; highways narrower; the Rough as dark scrub and rock; living rivers as hard blue barriers with crossings marked; breaks as collapsed sections. Holds as painted gate icons. Fog that burns off along the roads you drive. Old road‑sign shields with the interstate numbers. A date box (top right, Inindo). Supply gauges (bottom). **Threat overlay** toggle (danger rings, threat markers, the Choir's Hum levels). |
| **Hold (walkable)** | UWNH town | Top‑down hold with painted signs on scrap, NPCs, and a day/night cycle. |
| **Market** | UWNH market | A table of goods with Surplus/Want pips and buy/sell prices. Saturation is shown as a draining gauge. |
| **Dialogue** | UWNH/Inindo portrait boxes | Portrait plus a stencilled scrap‑metal box. Choices show their **success chance** where there's a check. |
| **Event card** | UWNH events | A painted vignette, prose in the AW voice, and 2–4 choices with their chances ([05](05-events.md#event-cards)). |
| **Skirmish** | Inindo battle | Grid, unit sprites, HP and Grit bars over each unit, an action menu, the turn‑order strip. |
| **Road war** | UWNH fleet battle | Lanes (5, 3 or 1 by road class), range bands, scrolling asphalt with lane paint and dead cars, rigs as side‑view sprites with Durability bars, gun crews visible on the mounts. |
| **Gang war** | Inindo province war | A siege view with gang blocks, walls, and morale bars. |
| **Character sheet** | Inindo | Attributes, derived stats, the three track levels and XP bars, skills, abilities, disciplines, Renown, gear. |
| **Crew** | UWNH mates | Officer cards: portrait, role, level, wages, a loyalty gauge, and their want. Crew morale gauge for the hands. |
| **Journal** | UWNH, Inindo | Known threats on the map, faction ambitions as plans, rumors, arc goals. |
| **First contact** | UWNH port discovery | The arrival at an uncharted hold: the gate, the watchers, and the hold's name painted onto your map. |
| **Month Report** | "Meanwhile…" | A one‑page broadsheet in the News' voice. The Choir's reach is printed in the masthead. |

**Placeholder screens (M2).** The skirmish, road war and journey (route strip, dial gauges, event cards) are playable with placeholder pixel art generated in code from this palette, pixel fonts at their native sizes, riveted plates and stencil buttons: see [`game/`](../../game/README.md) and the [screenshots](../screenshots/). They test layout, readability and feel, not the final look: an artist replaces them.

## UI: the dashboard
- **Diegetic**. The UI is built from the convoy's own parts: a **dashboard** with needle gauges, scrap‑metal panels with **stencilled** labels, rivets, rust and chipped paint.
- **Supply gauges are fuel gauges**: water, chow and guzzoline each get a needle and an "E" mark. Crew morale is a tachometer that redlines below 30.
- **Menus** are stencilled metal plates. The active choice is lit like a dash warning lamp.
- **Numbers are always readable.** Chances, prices, HP and loyalty are printed plainly, in the tradition of UWNH and Inindo. Style never hides a number.

## Signage and ruins
- **Most signage is gone.** It's rust, bare poles and sun‑bleached blanks. Interstate shields and mile markers survive best, because they're metal and they matter; they're drawn crisp because people still use them.
- **Lookalike brands** appear rarely, in less‑rusted ruins only, as faded or half‑lit signs. They should be recognisable from silhouette and palette alone: the art carries the reference, not the name. Rules and seed list: [13](13-content-tables.md#lookalike-brands-set-dressing).

## Faction marks
Each faction has a **sigil and colours**, painted on its holds' gates, its rigs and its gangs' gear. On the map, a hold's Lean is drawn as a bar split by those colours.

| Faction | Sigil | Colours | Look |
|---|---|---|---|
| The Lighthouse | A lamp with three rays | Lamp yellow on white | White armbands, lamps on everything, long tables |
| Sweetwell | A drop inside a ring | Clear blue on chrome | Sealed helmets, numbered chits, polished tanker convoys |
| Highwater | Three wave lines | Navy and frost white | Wool, frost, matching coats, ice skiffs |
| The Exchange | A coin with a hole punched through | Gold on green | White suits going green, gold teeth, ledgers |
| Burning Water | A flare stack | Fire orange on soot black | Soot, welding masks, scorched tankers, the flare on the horizon |
| Cerro | A mountain saddle over a bar of steel | Rust red and cement grey | Rebar crowns, slag walls, plated battle rigs |
| **The Choir** | **A circle** | **Bleached white and violet** | Unpainted, sun‑bleached rigs. The Opened standing still on overpasses, all facing Harrowgate. The only cold colours on the map |

**Sub‑faction marks** ([18](18-sub-factions.md)) are smaller, scrawled and personal. They're never painted on gates, only tagged, worn or hidden:
- the Keepers' lantern hung at a crossing
- the Teeth's jaw scratched into a road sign
- the Wheelwrights' cog stamped on a repaired part
- the Tankermen's union patch
- the Players' chalked note on a wall
- the Family's open hand, drawn only where kin will see it
- the Odd Lot's knot of wire on a fence post

Spotting a hidden sub‑faction mark takes a Sharp check (Scouting helps).

## Iconography
- **Gauges** for everything that runs down: supplies, morale, Durability, loyalty.
- **Hum level**: a violet ring around a hold icon, filling as the Hum rises. Touched, Marked and Silenced each have a distinct icon, so it's readable without colour.
- **Lean**: a bar split by faction colours, with the sigils on it.
- **Chances**: a percentage on every choice that has a check.

## Typography
- **Display**: a heavy, distressed stencil sans, as if sprayed through a cut‑metal template (licensed or commissioned).
- **Body**: a clean, readable sans for numbers and menus; a condensed serif for event prose and the Month Report.

## Audio
- **Palette**: **engine roar** (each frame has its own voice), **war drums** (oil drums, pipes, chains), **distorted guitar** riffs for battle, wind and sand for the road.
- **Battle music** builds with the fight: drums for a skirmish, drums and guitar for a road war, everything for a gang war.
- **The Hum** is the Choir's sound: a low choral tone that is **cold and clean** against the world's noise. It's absent where the Choir hasn't reached, faint in Touched holds, under everything in Marked ones, and alone in Silenced ones, where the engines and drums drop out. As the Choir's reach grows, the Hum creeps into more of the map's music.
- **Diegetic radio**: rigs have radios. Tuning in finds the News, Rumhouse music, and later the Choir.
- **Silence** is a tool. A Howl brings back the old roar for a few seconds, then cuts to nothing but wind and radio hiss.

## Accessibility
- Every chance and modifier is shown and named.
- Hum levels, Lean and danger are readable without colour (icons and patterns, not only violet).
- Colour‑blind presets that keep the Choir distinct.
- A reduce‑flashes option for fire, explosions and the In.
- Text speed and an instant‑text option. Large‑text mode.
- The Intimacy content toggle (see [00](00-vision.md#tone-and-content-policy)). Gore‑level toggle.
- **Mouse and keyboard first** (Windows and macOS), with remappable keys. Gamepad supported through Godot's focus system. Full trackpad support on Macs.
- Scalable UI for laptop screens down to 1280×800, including Retina scaling.
