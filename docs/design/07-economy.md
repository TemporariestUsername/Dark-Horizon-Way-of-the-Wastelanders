# 07 · Economy: Barter, Surplus and Want, Lean

> UWNH's engine (buy low, sell high, invest so ports defect) runs here on Apocalypse World's scarcity economics. Trade isn't arbitrage. It's keeping people alive at a profit, and buying loyalty with it.

## Money
- **Barter** is the unit of account. **1‑barter** is about a month's modest living for one person (AW: a night of high luxury, a few sessions' hire of a bodyguard, a repair of hi‑tech gear…).
- **Jingle** is small change: **10 jingle = 1‑barter**. Coins with holes in them, bullets, bottle caps, ration chits, depending on the hold.
- **Oddments** are portable valuables worth barter (antique coins, a working watch, eyeglasses). They're carried as items and traded at a hold‑specific rate.
- **Hold currency quirks** (AW: "*is there some particular currency your establishment recognizes?*"): Sweetwell takes **water chits**, the Exchange takes **Rothschild notes**, the Teeth take **bullets**, and Highwater takes **lake tokens** stamped from old coins. Converting between them costs 10–30%.

## Resources (trade goods)
These come from AW's resource list, in six categories (each with its own price index, as UWNH has):

| Category | Resources |
|---|---|
| **Water** | drinking water, hot water, brine (low grade) |
| **Chow** | meat, salt, grain, fresh foods, staple foods, preserved foods, "meat (don't ask)" |
| **Fuel and power** | gasoline/guzzoline, crude, batteries, heat |
| **Arms** | weaponry, ammo, armor |
| **Know‑how and goods** | medical supplies, machinery, raw materials, scrap, hi‑tech, books, information, specialized goods |
| **Luxury** | drugs, luxury goods, music and art (the Skinner's beauty), liquor, leisure |
| **People** *(never a player trade good)* | labor, skilled labor. Hired as crew and gang. Tum Tum trades in people. **The player can't buy or sell slaves.** Freeing them is a gig. |

## Price model
Each hold has, per resource:
- **Surplus level** S (0–3): what it makes.
- **Want level** W (0–3): what it lacks. A want above 2 triggers an **Affliction** threat (hunger, disease, thirst, savagery…).
- **Stock**: how many lots are available to buy now. It regenerates from S each week.

```
base(r)        = resource base value in barter per lot          (data table, 13-content-tables)
buy price      = base × (1.0 − 0.15·S + 0.20·W) × cat_index × tribute
sell price     = base × (0.70 − 0.10·S + 0.25·W) × cat_index × tribute × (1 − saturation)
saturation     = 0.04 per lot you've sold here this month (cap 0.6), decays 50% per month
cat_index      = 0.7…1.6 per category, drifts monthly (seasons, raids, threat moves)
tribute        = 1.0 (+0.1 if the hold leans to a warlord who isn't your patron and you lack a mark)
```

**Design targets:**
- A good route (S3 to W3) returns about **2.5×** on cargo before supply costs.
- A typical one returns **1.3–1.8×**.
- Selling 15 or more lots into one hold crushes the margin. That's UWNH's flooding lesson, and it pushes you to *spread out*.
- **Water is never free in Grome's country** (the Thirty‑Five and the Rag‑Wastes). It is free at Kettle's fog nets, Reservoir, the Falls and Highwater when their surplus is 3, as in UWNH's "*Water is free*".
- **Distance is the margin.** Holds near the Crossing have had a year of the Easing to trade with each other, so their prices have mostly evened out. Holds in the Farther ring, and holds you're first to reach, still have **golden‑age‑isolation prices**: their surplus is worth almost nothing locally and a fortune three regions away. That gap is UWNH's spice route, and it closes as traffic grows (the category index drifts toward the regional mean by 10% a month once a road is charted and busy).

## Barter moves in the market
- **Go into a holding's bustling market** (+sharp) to find a *specific* thing that isn't in stock.
  - 10+: you buy it at the listed price.
  - 7–9: the Director picks one: it costs 1‑barter more / it's not openly for sale, but here's a lead / here's who bought it last / something similar, will it do?
  - Miss: the Director makes a move.
- **Make known you want a thing and drop jingle** (+barter spent, max +3). This is a **special order**: the item arrives in N days. 10+ means no strings. 7–9 means close enough. A miss means it comes with strings very much attached (a Director hook).
- **Give 1‑barter with strings attached**: counts as *manipulate* at 10+, with no roll. This is how bribes, gifts and favours are bought.
- **Haggle**: there isn't one. Price negotiation is *seduce or manipulate* with a reason (Rep, a favour owed, a threat): +10% on a 10+, +5% on 7–9.

## Lifestyle and upkeep (the monthly drain)
- **Lifestyle**: at month start, spend **1–2 barter** (AW). Below that you're *scraping*, which gives −1 ongoing to Hot that month and a Director question.
- **Crew cut**: 0.5 barter per crew member per month, or **shares** (a 10% cargo cut). Under‑paying crew pushes Hx down and causes *pack alpha*‑style bids. See [11](11-crew-and-bonds.md).
- **Rig upkeep**: each rig needs a 1‑barter service every 3 months, or it picks up a **weakness**.
- **Holding** (Hardholder): your hold pays your lifestyle while you're there governing it. Wealth and want are rolled at month start.

## Gigs (work)
Work is posted at **month start** (Inindo's rule). It's found on hold **notice walls**, at **warlord seats**, at the **bar** (rumors), and through playbook gig lists from AW ("*Tend to the health of a dozen families*" for an Angel crew member, and so on).

| Gig type | Example | Reward |
|---|---|---|
| Delivery | Carry 10 lots of grain from Corbett to Kettle by month's end | Barter, plus Lean in the destination |
| Procurement | Find antibiotics for Barrow | Barter, plus Rep |
| Escort | Ride with Partridge's caravan through the Rag‑Wastes | Barter and gear |
| Salvage | Bring back the Fuse vault's control board | Barter or the item, plus a Savvyhead project |
| Faction gig | Sabotage Grome's pipe; break Burning Water's embargo; infiltrate Pellet | Large barter, plus the patron's Lean. The target warlord turns against you. |
| Mercy | Free Tum Tum's catch; bring water to a dying straggler camp | Hx and Rep. Little barter. |

## Investment and Lean (UWNH's allegiance, AW's way)
Every hold has a **Lean**: a share of loyalty split across factions that adds up to 100. The shares belong to the **six factions** (the Lighthouse, Sweetwell, Highwater, the Exchange, Burning Water and Cerro; see [17](17-factions.md)), **independent**, and **you** (or your patron, if you've sworn to one). **The Choir holds no Lean**: it Silences holds instead, taking them off this board entirely. **Sub‑factions** ([18](18-sub-factions.md)) hold no Lean either, but the faction they **back** gains Lean drift wherever they have chapters.

```
Lean: { independent: 55, grome: 30, you: 15 }      → the hold "leans" to whoever is ≥ 50
```

**Ways to move Lean.** These are *your* levers. Each AI faction also has its own **influence engine** that works on Lean every month ([17](17-factions.md#the-map-of-power)), and a faction you're sworn to multiplies the matching lever by 1.5 (an Exchange patron's investment, a Keeper patron's charts, and so on).

| Action | Lean change to you | Notes |
|---|---|---|
| **Drop jingle** (invest): put barter into the market, garage, wells or walls | +1 per 2‑barter, falling off above 20 a month | UWNH's "invest in the marketplace or shipyard". It also raises the hold's S in a resource you choose. |
| Relieve a Want ≥2 (sell the wanted resource there) | +1 per 3 lots, or +3 if it ends an Affliction | Trading *is* politics |
| Complete a gig for the hold | +3 to +8 | |
| *Frenzy* or a Hocus sermon (faith) | +2 to +6 per hold, per month | The Hocus's alternative path |
| Defend the hold in gang war | +10 | |
| Raid its caravans or tribute it (Chopper) | −5 to −10 to you; **fear** rises | Fear holds a hold but sours its Lean |
| Warlord conquest (world turn) | The conqueror takes 60, and the rest rescale | See [10](10-warlords-and-politics.md) |

**Thresholds:**
- **≥ 50**: the hold leans to you. You get a discount (tribute 0.9), access to its Seat, its gang **defends** your caravans, and it pays you **a tithe** of 1–3 barter a month.
- **≥ 75**: you can **install** a hardholder, base a caravan there, or (Hardholder) annex it into your holding network.
- **Faction seats** (the Lighthouse, Sweetwell, Highwater, the Exchange, Burning Water, Cerro, and the Choir's Harrowgate and Pellet) **can't be invested in**. That's UWNH's capital rule. They have to be taken.

## Debt (UWNH's bank → AW strings)
- **Rothschild's Exchange** lends up to 20‑barter at **10% a month** (UWNH's rate). Debt is a **threat** with a countdown. Missed payments tick it toward *take away their stuff*: collectors, a seized rig, or a "*favour*" gig.
- **Others lend too, but in strings**: Grome lends water against obedience, Parcher lends fuel against labour, and the Family (a sub‑faction) lends a hand against a stray brought home.

## Information as a commodity (UWNH's cartographers → the News)
- **Charts**: the News, at the Lighthouse, buys newly charted roads (0.5–3 barter per stretch, more for Farther and Notional ones, and a bonus for every break, crossing and toll you mark). **Rothschild pays triple for exclusive charts**, which then aren't sold to anyone else. That shuts other traders (and other playbooks' cameos) out of the route. Hardholders buy charts of the roads *to their* hold.
- **Sights** (discoveries) pay out once to the News, add Rep, and add Lean wherever they're relevant.
- **Rumors**: buy them at bars (1–5 jingle) or sell them. **True rumors** turn into map markers. **False rumors** exist and are planted by threats (a *Mirage* landscape's move: "*entice and betray*").

## Crossing tolls
Whoever holds a crossing over a living river sets its toll: 0–3 jingle a rig, or a share of cargo. Neutral crossings (the Lighthouse) charge nothing by custom. A crossing that leans to you is toll‑free for your caravans, which is a big reason to invest in one. Running a toll is *go aggro* or road war on a bridge.

## Safe passage
A warlord's **mark** (UWNH's Letter of Marque and tax permit rolled together) is a token worn on your rigs:
- No tribute in that warlord's holds.
- Their gangs leave you alone on the road.
- *Activating its downside*: rival warlords treat you as that warlord's creature.
