# Play notes: what the two Koei games feel like in the hands (M3 Phase 0)

The teardowns ([UWNH](uncharted-waters-new-horizons.md), [Inindo](inindo-way-of-the-ninja.md)) list what systems the two games have. These notes record what happened when we played them, with numbers, so the M3 campaign has tuning targets that come from a working game and not from guesses.

**Method.** Both games were driven headless in an emulator with scripted pad input, reading screenshots to navigate menus and diffing work RAM to find values (gold, position) and confirm them against the screen. Nothing from the games is in this repository: no ROMs, save states, screenshots, text or data tables. What follows is our own description and our own measurements. Prices are in each game's currency, and the useful figures are the ratios.

**Coverage, honestly.** UWNH: one port (the Portuguese capital at the start of the first story) played through its bank, market, haggling, market-rate board and harbor. Both games gate their opening behind story scenes, and we stopped before sailing (UWNH) and before the first battle (Inindo) when getting further would have cost more than it told us. Sea-side numbers below come from the ROM tables in the teardown, not from play. Sea battle, duel, Inindo's month and its battles are still unmeasured by play; the teardowns' ROM-text sections remain the source for those.

## UWNH: one port, start of the game

### The opening hour
- **Nothing trades until you have a ship.** The opening is a chain of errands around one town: bank, cafe, the patron's mansion (who hands you a first mate), the shipyard (who hands you a small lateen caravel). Only then do the market's Sell and the harbor's Supply open. Every step teaches one building.
- **The town has a clock.** Each building you enter costs about an hour to an hour and a half of the day. The first day went from 8:30 in the morning to 9:30 at night across eight or nine visits. Time in port isn't free, but it's cheap: the cost of dawdling is days at sea, not hours ashore.
- **Story interrupts errands.** With a ship bought, the harbor still refused to let us sail until a story character elsewhere in town had been visited. That's fine in a story game. For us the lesson is the reverse: the M3 slice should never block the player's next trade on a scripted scene.

### Money and credit
- The bank offers deposit, withdraw, borrow and repay. The first credit line was **1,000 gold at 10% a month**, about 1.3 times the cost of filling the starting ship with a cheap good. Credit is how the first run gets made: the starting purse alone buys about a third of a hold.
- **Our match:** doc 07's loans are 10% a month, which matches. The starting loan in the slice (20 barter against 60 in hand) is smaller than UWNH's; that's deliberate (we want debt to be a choice, not the default), but the first full load should still need *some* credit or a gig.

### The market
- **Ten goods for sale** at the capital, from cheap food (fish 24, olive oil 33, cheese 36) through cloth (56–91) to dye and arms (145). One good is announced as the local specialty. That's a small, readable menu, not the whole catalogue.
- **A tax line.** Without a permit for that nation, every purchase carries 20% on top. Buying a permit is a long-term investment that changes which ports you trade at.
- **Buying doesn't move the price.** Twenty-one lots of cheese bought at 36 left the price at 36. Only *selling* depresses a price (the teardown's play note). So the player's pressure on a market is one-sided: you can strip a port, but you only crash a price where you unload.
- **Capacity is shared with supplies.** The starting ship holds 80. It came with 10 water and 10 food aboard, so cargo had 60, a quarter of the hold already gone to range. The buy screen caps the quantity by both gold and free space.
- **The first mate comments on every price** ("that price is fine" or not) before you commit. It's a tiny touch that makes an officer feel useful and teaches the player what a good price is.
- **Haggling** is a two-step: turn down the asking price, then type your own offer (0 up to the asking price). On fish at 24: an offer of 20 (17% off) was refused with a grumble and the prompt came back; 23 (4% off) was accepted at once. You can try again straight away; there's no penalty for a refused offer at this level. The cut you can get is small, and the play is in the per-lot saving on a big load.
- **The market-rate board** is the real information screen. It gives the port's general price index (100% here), then ten categories each with their own index (spice 99%, food 102%), and for each good in a category both what the port *sells* it for and what it *pays* for it, including goods the port doesn't sell at all. So you learn what *this* port wants, but nothing about other ports except by going there.
- **Buy-back at the producing port is about half.** At the capital, for the goods it sells: cheese sells at 36 and is bought back at 20 (56%), fish 24 → 10 (42%), olive oil 33 → 10 (30%), raisins 43 → 20 (47%), salt 45 → 19 (42%). Mean ≈ **45%**. Goods it doesn't produce fetch much more relative to their cost elsewhere (sugar 45, grain 32, clove 138, cinnamon 118). Buying and selling at the same place loses half your money; the margin is entirely in distance.
- **Investment is closed at capitals.** You can only buy allegiance in ports that aren't a nation's capital. So the capital is the safe, neutral base and the frontier is where money turns into territory.

### Ships and supplies (ROM tables, not play)
- Hulls run from tiny (crew 5–15, hold 30) through the starting caravel (crew 10–30, hold 80) and brigantine (15–45, 120) to big carracks and galleons (30–100, 470; 70–180, 550). Each has a minimum crew to sail and a maximum it can carry.
- Water is free to load, food costs per barrel, and both share the hold with cargo. The supply/cargo split is the core trade-off: every barrel of water is a lot of goods you didn't carry, and every lot of goods is a day of range you gave up.

## Inindo: the first minutes
- The game opens on **June 15** of its start year, with 50 gold, the ninja at level 1 with **25 health and 10 energy**, in their home village.
- The field menu is Search, Lineup, Items, Info, Magic and Spy. The field shows only the date and gold; the bottom bar shows level, name, health and energy.
- The opening is a short scripted chase through a small walled village: villagers urge you to the elder while the warlord's thugs close the exits. We didn't find the trigger to leave in the time we gave it. The point stands: Inindo's opening has no tutorial screens; the world's talk tells you what's happening.
- **Still to play:** the first battle (turn order, energy cost of spells against the 10-point pool), a daimyo's job board and a month end. Until then the teardown's ROM-text notes are the reference.

## What this changes in our numbers

| Measured in UWNH | Our current value | M3 target |
|---|---|---|
| Buy-back at the producing port ≈ 45% of the sale price (30–56%) | `sell_k0 0.7, sell_ks −0.1`: about 70–75% at a surplus hold | Sell-back at a hold's own surplus goods **40–60%** of its buy price. Starting point for the campaign bench: `sell_k0 0.6, sell_ks −0.12` (S=1: 56%, S=2: 51%, S=3: 44%). Same-hold round trips must always lose |
| Haggle: 4% accepted, 17% refused, retries free | Cap 12% (17% with Trading) | Keep the cap. Make the first refusal free and the second a walkout, so it's a quick gamble, not a menu grind |
| 20% tax without a permit | 10% tribute without the hold's mark | Keep 10%; the mark is our permit |
| Credit line ≈ 1.3 full starting loads, 10% a month | Loans at 10% a month, max 20 barter | Keep the rate. The cap should cover about one full load of the starting convoy's cheapest good |
| Buying never moves a price; selling does | Saturation on sales only (4% a lot, cap 60%, halves monthly) | Keep. No buy-side saturation; stock limits do that job |
| A quarter of the starting hold is supplies | Supplies and cargo don't share space yet | Supplies take cargo space. The starting convoy should carry 20–30% supplies for its first leg |
| Ten goods on the board, one specialty | All 29 goods priced everywhere | Each hold lists only the goods it has stock of (plus a "pays for" column on the rate board for everything), with one marked specialty |
| First mate rates each price | Nothing | An officer (or the Driver with no officer) rates a price against the price memory: "best you've seen", "fair", "you paid less at the Pyramid" |
| Investment closed at capitals | Lean investment anywhere | A faction's seat (its capital) can't be bought; ordinary holds and outposts can |
| Time ashore costs about an hour per building | No time in holds | Keep holds free of time in M3; the day cost is at sea (on the road). Revisit if players linger without cost |
