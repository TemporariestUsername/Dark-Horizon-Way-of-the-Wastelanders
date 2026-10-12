## One simulated world: the mutable state for a single seed, built from SimData.
## The world turn (docs/design/10-warlords-and-politics.md) runs in world_turn().
## All randomness goes through `rng`, so a seed always replays the same history.
extends RefCounted

const Lean := preload("res://sim/lean.gd")
const Conditions := preload("res://sim/conditions.gd")
const Economy := preload("res://sim/economy.gd")
const Factions := preload("res://sim/factions.gd")
const Choir := preload("res://sim/choir.gd")
const Subfactions := preload("res://sim/subfactions.gd")

var data
var graph
var rng := RandomNumberGenerator.new()
var seed_value: int = 0

var month: int = 0              # world turns completed
var calendar_month: int = 3     # 1-12; the game starts on the first day of spring
var H: Dictionary = {}          # hold id -> hold state (see _init_hold)
var F: Dictionary = {}          # faction id -> faction state
var S: Dictionary = {}          # sub-faction id -> sub-faction state
var choir: Dictionary = {}      # the Choir's own state
var teeth_raids: Array = []     # months in which the Teeth hit Burning Water
var moved_this_month: Dictionary = {}  # hold id -> Lean points moved by drift this month
var events: Array = []          # {m, kind, text}: the Month Report lines
var history: Array = []         # per-month metric snapshots
var initial_leans: Dictionary = {}
var first_change: Dictionary = {}  # hold id -> month it first leaned somewhere new (or was Silenced)
var cache: Dictionary = {}      # static lookups computed on first use (paths, fuel sources)


func setup(sim_data, road_graph, seed_in: int) -> void:
	data = sim_data
	graph = road_graph
	seed_value = seed_in
	rng.seed = seed_in
	calendar_month = int(data.time["calendar"]["start"]["month"])
	for h in data.holds:
		H[h["id"]] = _init_hold(h)
	for f in data.factions["factions"]:
		F[f["id"]] = Factions.init_faction(self, f)
	for s in data.subfactions["subfactions"]:
		S[s["id"]] = Subfactions.init_sub(self, s)
	Choir.init_choir(self)
	for id in H:
		initial_leans[id] = leans(id)
	record_metrics()


func _init_hold(h: Dictionary) -> Dictionary:
	var econ: Dictionary = h["economy"]
	var subs := {}
	for sid in h["subfactions"]:
		subs[sid] = {"presence": int(h["subfactions"][sid]["presence"]), "hidden": bool(h["subfactions"][sid]["hidden"])}
	var cat := {}
	for c in data.resources.values().map(func(r): return r["category"]):
		cat[c] = 1.0
	return {
		"id": h["id"], "tier": h["tier"], "region": h["region"], "layer": h["layer"],
		"lean": h["lean"].duplicate() if h["lean"] != null else null,
		"silenced": bool(h["silenced"]),
		"hum": 0.0,
		"walls": int(h["walls"]),
		"gang": h["gang"].duplicate(true),
		"gang_base": h["gang"].duplicate(true),
		"surplus": econ["surplus"].duplicate(),
		"want": econ["want"].duplicate(),
		"base_want": econ["want"].duplicate(),
		"stock": econ["stock"].duplicate(),
		"met": {}, "unmet": {}, "supplied": {}, "baseline": {},
		"cat_index": cat,
		"fear": 0,
		"debt": 0.0,
		"cerro_walled": false,
		"embargo_until": -1, "shutoff_until": -1,
		"subs": subs,
		"crossing": h["crossing"] != null and h["crossing"].size() > 0,
	}


# ---------------------------------------------------------------- calendar

func season() -> String:
	var seasons: Dictionary = data.time["calendar"]["seasons"]
	for s in seasons:
		if seasons[s]["months"].has(float(calendar_month)) or seasons[s]["months"].has(calendar_month):
			return s
	return "spring"


# ---------------------------------------------------------------- Lean helpers

func leans(id: String) -> String:
	return Lean.leans(H[id]["lean"], float(data.lean["thresholds"]["leans"]))


func live_holds() -> Array:
	var out: Array = []
	for id in H:
		if not H[id]["silenced"]:
			out.append(id)
	return out


## Drift Lean toward a faction, respecting the per-hold monthly cap (rules/lean.json drift).
func drift(id: String, faction: String, pts: float) -> float:
	var h: Dictionary = H[id]
	if h["silenced"] or h["lean"] == null or pts == 0.0 or is_live_seat(id):
		return 0.0   # a living faction's seat can only be taken or Silenced, never drifted
	var cap := float(data.lean["drift"]["max_points_per_hold_per_month"])
	var used: float = moved_this_month.get(id, 0.0)
	var room: float = max(cap - used, 0.0)
	var p: float = clampf(pts, -room, room)
	var moved := Lean.add(h["lean"], faction, p)
	moved_this_month[id] = used + abs(moved)
	return moved


func is_live_seat(id: String) -> bool:
	for f in F:
		if F[f]["alive"] and F[f]["seat"] == id:
			return true
	return false


func holds_leaning_to(faction: String) -> Array:
	var out: Array = []
	for id in H:
		if not H[id]["silenced"] and leans(id) == faction:
			out.append(id)
	return out


func silenced_count() -> int:
	var n := 0
	for id in H:
		if H[id]["silenced"]:
			n += 1
	return n


func reach_tier() -> String:
	var n := silenced_count()
	var tier := "whispers"
	for t in data.choir["reach_tiers"]:
		if n >= int(t["from_silenced"]):
			tier = t["id"]
	return tier


func reach_at_least(tier: String) -> bool:
	var order := []
	for t in data.choir["reach_tiers"]:
		order.append(t["id"])
	return order.find(reach_tier()) >= order.find(tier)


func say(kind: String, text: String) -> void:
	events.append({"m": month, "kind": kind, "text": text})


# ---------------------------------------------------------------- ambition queries

## Functions available to ambition conditions (sim/conditions.gd).
func query(fname: String, args: Array) -> Variant:
	match fname:
		"walls":
			return H[args[0]]["walls"]
		"lean":
			return Lean.share(H[args[0]]["lean"], args[1])
		"leans":
			var l := leans(args[0])
			return l if l != "" else "none"
		"aquifer":
			return F["sweetwell"]["aquifer"]
		"war":
			return Factions.at_war(self, args[0], args[1])
		"route":
			return F[args[0]]["routes"].has(args[1])
		"cerro_walls":
			return H[args[0]]["cerro_walled"]
		"teeth_raids_last_6_months":
			return teeth_raids.filter(func(m): return m > month - 6).size()
		"count":
			return _count(args[0])
		"share":
			return _share(args[0])
	assert(false, "unknown condition function: " + fname)
	return null


func _count(what: String) -> int:
	if what.begins_with("debtors on the "):
		var region = data.norm("the " + what.trim_prefix("debtors on the "))
		var n := 0
		for id in H:
			if H[id]["debt"] > 0.0 and data.norm(H[id]["region"]) == region:
				n += 1
		return n
	if what == "holds on Burning Water fuel":
		var n := 0
		for id in live_holds():
			if Factions.fuel_source_faction(self, id) == "burning_water":
				n += 1
		return n
	assert(false, "unknown count(): " + what)
	return 0


func _share(what: String) -> float:
	if what == "independent debtors":
		var ind := holds_leaning_to(Lean.IND)
		if ind.is_empty():
			return 0.0
		return float(ind.filter(func(id): return H[id]["debt"] > 0.0).size()) / float(ind.size())
	assert(false, "unknown share(): " + what)
	return 0.0


# ---------------------------------------------------------------- the world turn

func world_turn() -> void:
	month += 1
	moved_this_month.clear()
	Factions.advance_ambitions(self)       # 1. ambitions
	Factions.run_engines(self)             # 2. influence engines
	Subfactions.backing_drift(self)        #    + sub-faction backing
	Factions.take_actions(self)            # 3. faction actions
	Economy.run_month(self)                # 4. hold economy
	Factions.settle(self)                  # 5. Lean settles, grip, deaths
	Factions.home_rule(self)
	Factions.recover_gangs(self)
	Subfactions.act(self)                  # 6. sub-faction verbs, Turning
	# 7. Wanderer AI: needs the named-NPC roster (M2). Not simulated in M1.
	Choir.turn(self)                       # 8. the Choir
	Factions.settle(self)                  #    (a Silenced seat kills a faction this month)
	record_metrics()                       # 9. the Month Report's numbers
	calendar_month = calendar_month % 12 + 1


func record_metrics() -> void:
	var leaning := {}
	var contested := 0
	var afflicted := 0
	var want_sum := 0.0
	var want_n := 0
	for id in H:
		var h: Dictionary = H[id]
		if h["silenced"]:
			continue
		var l := leans(id)
		if l == "":
			contested += 1
		else:
			leaning[l] = leaning.get(l, 0) + 1
			if month > 0 and l != initial_leans[id] and not first_change.has(id):
				first_change[id] = month
		var hit := false
		for g in h["want"]:
			want_sum += float(h["want"][g])
			want_n += 1
			if int(h["want"][g]) > int(h["base_want"].get(g, 0)):
				hit = true
		if hit:
			afflicted += 1
	for id in H:
		if H[id]["silenced"] and month > 0 and initial_leans[id] != "" and not first_change.has(id):
			first_change[id] = month
	var alive := []
	for f in F:
		if F[f]["alive"]:
			alive.append(f)
	history.append({
		"month": month,
		"silenced": silenced_count(),
		"reach": reach_tier(),
		"voices": choir["voices"],
		"leaning": leaning,
		"contested": contested,
		"alive": alive,
		"afflicted": afflicted,
		"mean_want": want_sum / max(want_n, 1),
		"price_water": Economy.mean_price(self, "water"),
		"price_guzzoline": Economy.mean_price(self, "guzzoline"),
		"price_medicine": Economy.mean_price(self, "medicine"),
		"turning": {"family": S["family"]["turning"], "cross_folk": S["cross_folk"]["turning"]},
		"turned": S.keys().filter(func(s): return S[s]["turned"]),
	})


## A compact fingerprint of the state, for determinism tests.
func fingerprint() -> String:
	var parts: PackedStringArray = []
	for id in H:
		var h: Dictionary = H[id]
		parts.append("%s:%s:%.3f:%d:%.2f" % [id, leans(id), h["hum"], h["walls"], h["gang"]["troops"]])
	parts.append("v%.3f" % choir["voices"])
	return ",".join(parts).md5_text()
