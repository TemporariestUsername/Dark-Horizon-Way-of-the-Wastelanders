## A journey: a convoy driving a real route day by day (docs/design/03-core-loops.md loop 2),
## burning supplies, drawing events, fighting the battles they start, and resupplying at the
## holds it passes. The same code drives the text UI (tools/journey.gd), the golden tests and
## the event bench.
extends RefCounted

const Characters := preload("res://sim/characters.gd")
const EventSystem := preload("res://sim/events/event_system.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")
const RoadWar := preload("res://sim/battle/road_war.gd")

const CREW := 10                  # hands plus officers, for supply burn
const CAPACITY := {"water": 20.0, "chow": 12.0, "fuel": 15.0}
const RESUPPLY_BARTER_PER_UNIT := 0.05
const MAX_DAYS_FACTOR := 3.0

var data
var graph
var events                        # EventSystem
var rng: RandomNumberGenerator
var party: Array = []             # battle combatants, HP carried between fights
var convoy: Array = []            # rig specs for road wars
var route: Array = []             # holds along the path, in order
var edges: Array = []
var leg := 0                      # index into edges
var km_in_leg := 0.0
var day := 0.0
var start_month := 3
var supplies := {"water": 20.0, "chow": 12.0, "fuel": 15.0}
var barter := 10.0
var cargo := 1.0                  # share of the starting cargo still aboard
var morale := 70.0
var hum := 0.0
var repairs := 0.0
var xp_road := 0
var renown := {"explorer": 0, "trader": 0, "raider": 0}
var rep := 0
var recruits := 0
var rumors: Array = []
var lines: PackedStringArray = []
var policy: Callable              # (event, choices, chances) -> index; null = the auto policy
var stats := {"events": 0, "road_days": 0, "road_events": 0, "hold_visits": 0, "hold_events": 0, "loot": 0.0, "battles": 0, "battles_won": 0, "defeats": 0, "by_tone": {}, "lethal_unwarned": 0,
	"max_bad_streak": 0, "days_out_of_water": 0, "days_out_of_fuel": 0, "arrived": false}


func setup(sim_data, road_graph, a_world, from: String, to: String, level: int, random: RandomNumberGenerator, month: int = 3) -> void:
	data = sim_data
	graph = road_graph
	rng = random
	start_month = month
	events = EventSystem.new()
	events.setup(data, graph, a_world, rng)
	for cls in ["driver", "angel", "gunlugger"]:
		party.append(Characters.build_class(data, cls, {"road": level, "trade": 1, "fight": level}, "party", rng))
	var band := "early" if level <= int(data.units["party_convoys"]["early"]["max_level"]) else "mid"
	for spec in data.units["party_convoys"][band]["rigs"]:
		var s: Dictionary = spec.duplicate(true)
		s["character"] = party.filter(func(m): return m["class"] == spec["driver"])[0] if party.any(func(m): return m["class"] == spec["driver"]) else Characters.build_class(data, spec["driver"], {"road": level, "trade": 1, "fight": level}, "party", rng)
		convoy.append(s)
	edges = graph.path_edges(from, to)
	route = [from]
	for e in edges:
		route.append(graph.other(e, route[-1]))


var echo := false                 # print lines as they happen (the text UI)


func say(t: String) -> void:
	lines.append(t)
	if echo:
		print(t)


func season() -> String:
	var m := ((start_month - 1 + int(day / 30.0)) % 12) + 1
	for s in data.time["calendar"]["seasons"]:
		if data.time["calendar"]["seasons"][s]["months"].has(float(m)) or data.time["calendar"]["seasons"][s]["months"].has(m):
			return s
	return "spring"


func here() -> String:
	if leg >= edges.size():
		return route[-1]
	var e: Dictionary = edges[leg]
	return route[leg] if km_in_leg < float(e["km"]) / 2.0 else route[leg + 1]


## Travel speed on a leg, from the road graph's travel days (the one source of truth).
func _km_per_day(e: Dictionary) -> float:
	return float(e["km"]) / max(graph.edge_days(e), 0.05)


# ---------------------------------------------------------------- running

func run() -> Dictionary:
	var expected := 0.0
	for e in edges:
		expected += graph.edge_days(e)
	var limit := expected * MAX_DAYS_FACTOR + 20.0
	say("From %s to %s: %d legs, about %.0f days." % [data.hold_by_id[route[0]]["name"], data.hold_by_id[route[-1]]["name"], edges.size(), expected])
	while leg < edges.size() and day < limit:
		_road_day()
	stats["arrived"] = leg >= edges.size()
	stats["days"] = day
	stats["expected_days"] = expected
	say("%s after %.1f days. Cargo %d%%, barter %.1f, morale %d." % ["Arrived" if stats["arrived"] else "Gave up", day, roundi(cargo * 100), barter, roundi(morale)])
	return stats


func _road_day() -> void:
	var pick := _day_start()
	if not pick.is_empty():
		_play(pick, pending_ctx)
	_day_finish()


## Morning: a new day, supplies burn, and a road event is drawn (or nothing).
func _day_start() -> Dictionary:
	day += 1.0
	stats["road_days"] += 1
	_burn()
	var h := here()
	var hd: Dictionary = data.hold_by_id[h]
	var ctx := {"day": day, "hold": h, "region": hd["region"], "ring": hd["ring"], "season": season(), "kind": "road",
		"crossing": edges[leg]["crossing"] != null if leg < edges.size() else false, "water": supplies["water"], "chow": supplies["chow"]}
	pending_ctx = ctx
	var pick: Dictionary = events.draw(ctx)
	if not pick.is_empty():
		stats["road_events"] += 1
	return pick


## The rest of the day: the drive, and a hold visit if the convoy reaches one.
func _day_finish() -> void:
	stats["max_bad_streak"] = max(stats["max_bad_streak"], events.bad_streak)
	if supplies["fuel"] <= 0.0:
		stats["days_out_of_fuel"] += 1
		_stranded()
		return
	var left := _km_per_day(edges[leg])
	while left > 0.0 and leg < edges.size():
		var e: Dictionary = edges[leg]
		var need: float = float(e["km"]) - km_in_leg
		if left < need:
			km_in_leg += left
			left = 0.0
		else:
			left -= need
			leg += 1
			km_in_leg = 0.0
			_visit(route[leg])
			left = 0.0   # a hold visit ends the day's driving


func _burn() -> void:
	var b: Dictionary = data.time["supply_burn_per_day"]
	var heat: float = float(b["heat_water_multiplier"]) if season() == "summer" else 1.0
	supplies["water"] -= CREW * float(b["water_casks_per_crew"]) * heat
	supplies["chow"] -= CREW * float(b["chow_crates_per_crew"])
	supplies["fuel"] -= convoy.size() * 1.0
	if supplies["water"] < 0.0:
		supplies["water"] = 0.0
		stats["days_out_of_water"] += 1
		morale -= 5.0
		for m in party:
			m["hp"] = max(1.0, m["hp"] - m["max_hp"] * 0.1)
	if supplies["chow"] < 0.0:
		supplies["chow"] = 0.0
		morale -= 5.0
	supplies["fuel"] = max(0.0, supplies["fuel"])
	for m in party:
		m["hp"] = min(m["max_hp"], m["hp"] + float(data.time["health"]["on_road_hp_per_day"]))


## Out of fuel: never a dead end. A trader sells fuel at double price, or someone walks.
func _stranded() -> void:
	if barter >= 2.0:
		barter -= 2.0
		supplies["fuel"] = 6.0
		say("Day %.0f: Out of guzzoline. A trader's rig stops, and sells you six cans at double the price." % day)
	else:
		day += 2.0
		supplies["fuel"] = 4.0
		morale -= 10.0
		say("Day %.0f: Out of guzzoline and barter. Two of the crew walk to the last hold and come back with four cans." % day)


func _visit(h: String) -> void:
	var hd: Dictionary = data.hold_by_id[h]
	if events.world != null and events.world.H[h]["silenced"] or events.world == null and hd["silenced"]:
		say("Day %.0f: %s is Silenced. Nobody comes to the gate. You drive on." % [day, hd["name"]])
		return
	var cost := 0.0
	for k in CAPACITY:
		var need: float = CAPACITY[k] - supplies[k]
		var buy: float = min(need, barter / RESUPPLY_BARTER_PER_UNIT) if need > 0.0 else 0.0
		supplies[k] += buy
		barter -= buy * RESUPPLY_BARTER_PER_UNIT
		cost += buy * RESUPPLY_BARTER_PER_UNIT
	if repairs > 0.0 and barter > 0.0:
		var fix: float = min(repairs, barter)
		barter -= fix
		repairs -= fix
	for m in party:
		m["down"] = false
		m["hp"] = min(m["max_hp"], max(m["hp"], 1.0) + float(data.time["health"]["rest_in_hold_hp_per_day"]))
	say("Day %.0f: %s. You resupply for %.1f barter." % [day, hd["name"], cost])
	stats["hold_visits"] += 1
	var ctx := {"day": day, "hold": h, "region": hd["region"], "ring": hd["ring"], "season": season(), "kind": "hold",
		"water": supplies["water"], "chow": supplies["chow"]}
	var pick: Dictionary = events.draw(ctx)
	if not pick.is_empty():
		stats["hold_events"] += 1
		if interactive:
			_open_card(pick, ctx)
		else:
			_play(pick, ctx)


# ---------------------------------------------------------------- playing an event card

func _play(pick: Dictionary, ctx: Dictionary) -> void:
	var chances := _present(pick, ctx)
	var e: Dictionary = pick["event"]
	var idx: int = policy.call(e, e["choices"], chances) if policy.is_valid() else auto_choice(e, chances)
	_choose(pick, idx)


## Shows a card (the transcript lines and stats). Returns each choice's chance (-1 if safe).
func _present(pick: Dictionary, ctx: Dictionary) -> Array:
	var e: Dictionary = pick["event"]
	stats["events"] += 1
	stats["by_tone"][e["tone"]] = int(stats["by_tone"].get(e["tone"], 0)) + 1
	if e["tone"] == "lethal" and not events.is_warned(pick["threat"], day):
		stats["lethal_unwarned"] += 1
	var chances: Array = []
	for c in e["choices"]:
		chances.append(events.chance(c, party) if c.has("check") else -1)
	say("")
	say("Day %.0f, near %s (%s, %s)" % [day, data.hold_by_id[ctx["hold"]]["name"], ctx["region"], ctx["season"]])
	say(e["text"])
	for i in e["choices"].size():
		var c: Dictionary = e["choices"][i]
		var tag := ""
		if c.has("check"):
			tag = "  [%s check, %s: %d%%]" % [c["check"]["attr"].capitalize(), c["check"]["difficulty"], chances[i]]
		say("  %d) %s%s" % [i + 1, c["label"], tag])
	return chances


func _choose(pick: Dictionary, idx: int) -> void:
	var e: Dictionary = pick["event"]
	var choice: Dictionary = e["choices"][idx]
	var res = events.resolve(choice, party)
	last_choice = {"event": e["id"], "tone": e["tone"], "picked": idx, "check": res["check"],
		"chance": res.get("chance", -1), "success": res.get("success", true)}
	var outcome := ""
	if res["check"]:
		outcome = " (%d%%: %s)" % [res["chance"], "success" if res["success"] else "failure"]
	say("> %s%s" % [choice["label"], outcome])
	_apply(res["effects"], pick)


func _apply(fx: Dictionary, pick: Dictionary) -> void:
	var summary: PackedStringArray = []
	for k in ["water", "chow", "fuel"]:
		if fx.has(k):
			supplies[k] = clampf(supplies[k] + float(fx[k]), 0.0, CAPACITY[k])
			summary.append("%s %s" % [k, _num(float(fx[k]), true)])
	if fx.has("days"):
		day += float(fx["days"])
		if float(fx["days"]) > 0.0:
			summary.append("%s day(s)" % _num(float(fx["days"])))
	if fx.has("morale"):
		morale = clampf(morale + float(fx["morale"]), 0.0, 100.0)
		summary.append("morale %+d" % int(fx["morale"]))
	if fx.has("hp"):
		for m in party:
			m["hp"] = clampf(m["hp"] + float(fx["hp"]), 1.0, m["max_hp"])
		summary.append("HP %+d each" % int(fx["hp"]))
	if fx.has("cargo"):
		cargo = max(0.0, cargo * (1.0 + float(fx["cargo"])))
		summary.append("cargo %+d%%" % roundi(float(fx["cargo"]) * 100))
	if fx.has("barter"):
		barter = max(0.0, barter + float(fx["barter"]))
		summary.append("barter %s" % _num(float(fx["barter"]), true))
	if fx.has("repairs"):
		repairs += float(fx["repairs"])
		summary.append("repairs %s barter" % _num(float(fx["repairs"])))
	if fx.has("hum"):
		hum += Characters.hum_gain(float(fx["hum"]), float(party[0]["attributes"]["weird"]))
		summary.append("Hum exposure +%d" % int(fx["hum"]))
	if fx.has("xp_road"):
		xp_road += int(fx["xp_road"])
	for k in ["renown_raider", "renown_explorer", "renown_trader"]:
		if fx.has(k):
			renown[k.trim_prefix("renown_")] += int(fx[k])
	if fx.has("rep_nearby"):
		rep += int(fx["rep_nearby"])
	if fx.has("recruit"):
		recruits += int(fx["recruit"])
		summary.append("a recruit")
	if fx.has("warn"):
		var t: String = fx["warn"]
		if t == "nearest_threat" or t == "nearest_road_gang":
			t = events.nearest_threat(here(), season(), "brute/hunting_pack" if t == "nearest_road_gang" else "")
			if t == "" and pick["threat"] != "":
				t = pick["threat"]
		events.warn(t, day)
		if t != "":
			summary.append("warned: %s" % events.threats[t]["name"])
	if fx.has("rumor"):
		var r: String = fx["rumor"]
		if r == "nearest_threat":
			var t = events.nearest_threat(here(), season())
			r = "Word is %s are out there, %s." % [events.threats[t]["name"], "near " + data.hold_by_id[events.threats[t]["at"]]["name"]] if t != "" else "Nothing you didn't know."
		rumors.append(r)
		summary.append("rumor: \"%s\"" % r)
	if not summary.is_empty():
		say("  " + ", ".join(summary))
	if fx.has("battle"):
		if interactive:
			pending_battle = {"spec": fx["battle"], "on_win": fx.get("on_win", {}), "pick": pick}
			return
		var won := _battle(fx["battle"])
		if won and fx.has("on_win"):
			_apply(fx["on_win"], pick)


static func _num(x: float, signed: bool = false) -> String:
	var t := str(int(x)) if is_equal_approx(x, roundf(x)) else "%.1f" % x
	return ("+" + t) if signed and x > 0.0 else t


## Fights a battle from the data, automatically. Returns true if the party won.
func _battle(spec: String) -> bool:
	var sim = battle_setup(spec)
	return battle_outcome(spec, sim, sim.run())


## Builds the battle a card started (a Skirmish or a RoadWar, ready to run or to play).
func battle_setup(spec: String):
	stats["battles"] += 1
	var parts: PackedStringArray = spec.split(":")
	if parts[0] == "skirmish":
		var enc: Dictionary = data.units["encounters"].filter(func(x): return x["id"] == parts[1])[0]
		var enemies: Array = []
		var n := 0
		for uid in enc["units"]:
			for k in int(enc["units"][uid]):
				enemies.append(Characters.build_unit(data, uid, "enemy", rng, n))
				n += 1
		for m in party:
			m["down"] = false
			m["fled"] = false
			m["statuses"] = {}
			m["buffs"] = []
		var sk := Skirmish.new()
		sk.setup(data, party, enemies, rng)
		return sk
	var cv: Dictionary = data.units["convoys"].filter(func(x): return x["id"] == parts[1])[0]
	var rw := RoadWar.new()
	rw.setup(data, convoy, cv["rigs"], cv["road"], rng)
	return rw


## Applies a finished battle's result to the journey. Returns true if the party won.
func battle_outcome(spec: String, sim, res: Dictionary) -> bool:
	var parts: PackedStringArray = spec.split(":")
	var won: bool = res["winner"] == "party"
	if parts[0] == "skirmish":
		var enc: Dictionary = data.units["encounters"].filter(func(x): return x["id"] == parts[1])[0]
		for m in party:
			m["hp"] = max(m["hp"], 1.0)   # the downed are stabilised after the fight
			m["fled"] = false
		say("  Skirmish: %s. %s in %d rounds." % [enc["name"], "Won" if won else ("Got away" if res["winner"] == "fled" else "Lost"), res["rounds"]])
		if res["winner"] == "fled":
			return false
	else:
		var cv: Dictionary = data.units["convoys"].filter(func(x): return x["id"] == parts[1])[0]
		repairs += (1.0 - res["party_durability_share"]) * 6.0
		if res["winner"] == "escaped":
			say("  Road war: %s. You get away." % cv["name"])
			return false
		say("  Road war: %s. %s in %d rounds." % [cv["name"], "Won" if won else "Lost", res["rounds"]])
	if won:
		stats["battles_won"] += 1
		morale = min(100.0, morale + 10.0)
		var loot := _loot(spec)
		barter += loot
		stats["loot"] += loot
		say("  Loot: %s barter." % _num(loot))
	else:
		stats["defeats"] += 1
		cargo *= 0.5
		barter = max(0.0, barter - 2.0)
		for k in supplies:
			supplies[k] *= 0.5
		morale = max(0.0, morale - 15.0)
		say("  Beaten. They take half the cargo and half the stores, and leave you on the road.")
	return won


# ---------------------------------------------------------------- playing it (the journey scene)

var interactive := false
var last_choice: Dictionary = {}  # the last card choice and its check, for the playtest log
var phase := "start"              # start, morning, drive, end
var pending_ctx: Dictionary = {}
var pending_card: Dictionary = {} # {pick, ctx, chances}
var pending_battle: Dictionary = {}  # {spec, on_win, pick}
var limit_days := 0.0


func _open_card(pick: Dictionary, ctx: Dictionary) -> void:
	pending_card = {"pick": pick, "ctx": ctx, "chances": _present(pick, ctx)}


## Advances until the player is needed. Returns one of:
##   {kind: "card", event, chances}     choose with choose(i)
##   {kind: "battle", spec, sim}        play sim, then battle_done(sim.finish())
##   {kind: "day"}                      a day passed; call step() again
##   {kind: "end", arrived}
func step() -> Dictionary:
	if not pending_battle.is_empty():
		return {"kind": "battle", "spec": pending_battle["spec"], "sim": pending_battle.get("sim")}
	if not pending_card.is_empty():
		return {"kind": "card", "event": pending_card["pick"]["event"], "chances": pending_card["chances"]}
	if phase == "start":
		var expected := 0.0
		for e in edges:
			expected += graph.edge_days(e)
		stats["expected_days"] = expected
		limit_days = expected * MAX_DAYS_FACTOR + 20.0
		say("From %s to %s: %d legs, about %.0f days." % [data.hold_by_id[route[0]]["name"], data.hold_by_id[route[-1]]["name"], edges.size(), expected])
		phase = "morning"
	if phase == "end" or leg >= edges.size() or day >= limit_days:
		if phase != "end":
			phase = "end"
			stats["arrived"] = leg >= edges.size()
			stats["days"] = day
			say("%s after %.1f days. Cargo %d%%, barter %.1f, morale %d." % ["Arrived" if stats["arrived"] else "Gave up", day, roundi(cargo * 100), barter, roundi(morale)])
		return {"kind": "end", "arrived": stats["arrived"]}
	if phase == "morning":
		var pick := _day_start()
		phase = "drive"
		if not pick.is_empty():
			_open_card(pick, pending_ctx)
			return step()
	if phase == "drive":
		_day_finish()
		phase = "morning"
		if not pending_card.is_empty():
			return step()
	return {"kind": "day"}


## The player picks a choice on the open card.
func choose(idx: int) -> Dictionary:
	var pick: Dictionary = pending_card["pick"]
	pending_card = {}
	_choose(pick, idx)
	if not pending_battle.is_empty():
		pending_battle["sim"] = battle_setup(pending_battle["spec"])
	return step()


## The battle scene reports back with the sim's finish() result.
func battle_done(res: Dictionary) -> Dictionary:
	var pb := pending_battle
	pending_battle = {}
	var won := battle_outcome(pb["spec"], pb["sim"], res)
	if won and not pb["on_win"].is_empty():
		_apply(pb["on_win"], pb["pick"])
	return step()


# ---------------------------------------------------------------- the auto policy

const BATTLE_COST := {"easy": 1.0, "fair": 4.0, "hard": 10.0, "boss": 18.0}
const LOOT_PER_ENEMY := 0.5       # barter per enemy fighter beaten in a skirmish
const LOOT_PER_RIG := 1.5         # barter per enemy rig in a road war


## Salvage and loot from a won battle (weapons, ammo, parts, whatever they were carrying).
func _loot(spec: String) -> float:
	var parts: PackedStringArray = spec.split(":")
	if parts[0] == "skirmish":
		var enc: Dictionary = data.units["encounters"].filter(func(x): return x["id"] == parts[1])[0]
		var n := 0
		for u in enc["units"]:
			n += int(enc["units"][u])
		return n * LOOT_PER_ENEMY
	var cv: Dictionary = data.units["convoys"].filter(func(x): return x["id"] == parts[1])[0]
	return cv["rigs"].size() * LOOT_PER_RIG


func _value(fx: Dictionary) -> float:
	var v := 0.0
	v -= 2.0 * float(fx.get("days", 0.0))
	for k in ["water", "chow"]:
		v += 0.6 * float(fx.get(k, 0.0))
	v += 0.8 * float(fx.get("fuel", 0.0))
	v += 0.25 * float(fx.get("morale", 0.0))
	v += 0.3 * float(fx.get("hp", 0.0))
	v += 30.0 * float(fx.get("cargo", 0.0))
	v += 2.5 * float(fx.get("barter", 0.0))
	v -= 2.5 * float(fx.get("repairs", 0.0))
	v -= 0.3 * float(fx.get("hum", 0.0))
	v += 0.05 * float(fx.get("xp_road", 0.0)) + (0.5 if fx.has("rumor") else 0.0) + (1.0 if fx.has("warn") else 0.0)
	v += 0.05 * (float(fx.get("renown_raider", 0)) + float(fx.get("renown_explorer", 0)))
	if fx.has("battle"):
		var parts: PackedStringArray = String(fx["battle"]).split(":")
		var list: Array = data.units["encounters"] if parts[0] == "skirmish" else data.units["convoys"]
		var foe: Dictionary = list.filter(func(x): return x["id"] == parts[1])[0]
		var p := win_estimate(foe)
		var win_v := 2.5 * _loot(fx["battle"]) + (_value(fx["on_win"]) if fx.has("on_win") else 0.0)
		var lose_v := -30.0 * 0.5 * cargo - 2.5 * 2.0 - 0.25 * 15.0   # half the cargo and stores, barter, morale
		v += p * win_v + (1.0 - p) * lose_v - BATTLE_COST[foe["rating"]]
	return v


## Rough win chance a player would guess from a fight's rating and how far it's above their level
## (the rating windows in rules/battle.json, centred; -15% per level of gap).
func win_estimate(foe: Dictionary) -> float:
	var t: Array = data.battle["encounter_targets"][foe["rating"]]
	var p := (float(t[0]) + float(t[1])) / 2.0
	var gap := int(foe["party_level"]) - int(party[0]["fight"])
	return clampf(p - 0.15 * gap, 0.05, 0.99)


## A sensible player: the choice with the best expected value.
func auto_choice(e: Dictionary, chances: Array) -> int:
	var best := 0
	var best_v := -INF
	for i in e["choices"].size():
		var c: Dictionary = e["choices"][i]
		var v: float
		if c.has("check"):
			var p: float = chances[i] / 100.0
			v = p * _value(c["success"]) + (1.0 - p) * _value(c["failure"])
		else:
			v = _value(c.get("effects", {}))
		if v > best_v:
			best = i
			best_v = v
	return best
