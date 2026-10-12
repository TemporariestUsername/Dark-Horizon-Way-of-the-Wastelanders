## The hold economy (docs/design/07-economy.md, rules/economy.json): stock, NPC trade,
## wants rising and easing, afflictions, and the category price index.
##
## M1 has no player, so goods move by abstract NPC trade: each wanting hold draws on the
## nearest holds with stock, within a trade range, nearest first. Embargoes and water
## shut-offs block the matching goods.
##
## The map is scarce by design (medicine, fuel and water can't meet demand), so a hold's
## starting wants are its normal state. Each hold remembers how well each want was supplied
## in its first month; a want rises when supply falls below half of that for
## want_growth_months_unmet months (a disruption: a supplier Silenced, an embargo, a raid),
## and eases back toward its starting level once supply recovers.
extends RefCounted

const Lean := preload("res://sim/lean.gd")

const TRADE_RANGE_KM := 700.0      # about a week's drive: the reach of ordinary NPC traders
const SHIP_SHARE := 0.5            # a supplier ships at most half its stock a month
const DEMAND_SHARE := 0.25         # monthly lots wanted = want x want_relief_lots[tier] x this


static func run_month(w) -> void:
	_regen(w)
	_trade(w)
	if w.month == 1:
		for id in w.live_holds():
			w.H[id]["baseline"] = w.H[id]["supplied"].duplicate()
	_wants(w)
	_drift_index(w)


static func _regen(w) -> void:
	var st: Dictionary = w.data.economy["stock"]
	for id in w.live_holds():
		var h: Dictionary = w.H[id]
		var per_week := float(st["weekly_regen_per_surplus_level"][h["tier"]])
		for g in h["surplus"]:
			var lvl := float(h["surplus"][g])
			var cap := per_week * lvl * float(st["cap_multiplier_weeks"])
			h["stock"][g] = min(cap, float(h["stock"].get(g, 0.0)) + per_week * lvl * 4.0)


static func demand(w, id: String, good: String) -> float:
	var h: Dictionary = w.H[id]
	return float(h["want"][good]) * float(w.data.economy["stock"]["want_relief_lots_per_level"][h["tier"]]) * DEMAND_SHARE


static func _blocked(w, src: String, dst: String, good: String) -> bool:
	var d: Dictionary = w.H[dst]
	if good == "guzzoline" and d["embargo_until"] >= w.month and w.leans(src) == "burning_water":
		return true
	if good == "water" and d["shutoff_until"] >= w.month and w.leans(src) == "sweetwell":
		return true
	return false


static func _trade(w) -> void:
	var shipped := {}
	var order: Array = w.live_holds()
	_shuffle(w, order)
	for id in order:
		var h: Dictionary = w.H[id]
		h["supplied"] = {}
		for g in h["want"]:
			var need := demand(w, id, g)
			if need <= 0.0:
				h["supplied"][g] = 1.0
				continue
			var got := 0.0
			for src in w.graph.nearest(id, TRADE_RANGE_KM):
				if got >= need:
					break
				var sh: Dictionary = w.H[src]
				if sh["silenced"] or float(sh["stock"].get(g, 0.0)) <= 0.0 or _blocked(w, src, id, g):
					continue
				var key: String = src + "|" + g
				var room: float = float(sh["stock"][g]) * SHIP_SHARE - float(shipped.get(key, 0.0))
				if room <= 0.0:
					continue
				var take: float = min(room, need - got)
				shipped[key] = float(shipped.get(key, 0.0)) + take
				got += take
			h["supplied"][g] = got / need
	for key in shipped:
		var parts: PackedStringArray = key.split("|")
		var sh: Dictionary = w.H[parts[0]]
		sh["stock"][parts[1]] = max(0.0, float(sh["stock"][parts[1]]) - float(shipped[key]))


static func _wants(w) -> void:
	var st: Dictionary = w.data.economy["stock"]
	var grow_after := int(st["want_growth_months_unmet"])
	for id in w.live_holds():
		var h: Dictionary = w.H[id]
		for g in h["want"]:
			var s: float = h["supplied"].get(g, 0.0)
			var s0: float = h["baseline"].get(g, 0.0)
			if s < s0 * 0.5:
				h["unmet"][g] = int(h["unmet"].get(g, 0)) + 1
				h["met"][g] = 0
			elif s >= s0 * 0.999:
				h["met"][g] = int(h["met"].get(g, 0)) + 1
				h["unmet"][g] = 0
			if int(h["unmet"].get(g, 0)) >= grow_after and int(h["want"][g]) < 3:
				h["want"][g] = int(h["want"][g]) + 1
				h["unmet"][g] = 0
				if int(h["want"][g]) >= int(st["affliction_at_want"]):
					w.say("affliction", "%s is short of %s" % [id, g])
			elif int(h["met"].get(g, 0)) >= grow_after and int(h["want"][g]) > int(h["base_want"].get(g, 0)):
				h["want"][g] = int(h["want"][g]) - 1
				h["met"][g] = 0


static func _drift_index(w) -> void:
	var ci: Dictionary = w.data.economy["category_index"]
	var lo := float(ci["min"])
	var hi := float(ci["max"])
	var sd := float(ci["monthly_drift_sd"])
	for id in w.live_holds():
		var cat: Dictionary = w.H[id]["cat_index"]
		for c in cat:
			var v: float = cat[c]
			v += (1.0 - v) * 0.1 + w.rng.randfn(0.0, sd)
			cat[c] = clampf(v, lo, hi)


## Buy price at a hold (docs/design/07-economy.md), before tribute, haggling and saturation.
static func buy_price(w, id: String, good: String) -> float:
	var p: Dictionary = w.data.economy["price"]
	var h: Dictionary = w.H[id]
	var r: Dictionary = w.data.resources[good]
	var s := float(h["surplus"].get(good, 0))
	var wl := float(h["want"].get(good, 0))
	var idx: float = h["cat_index"][r["category"]]
	var shift: Dictionary = w.data.economy["category_index"]["season_shift"].get(w.season(), {})
	idx *= 1.0 + float(shift.get(r["category"], 0.0))
	if r["category"] == "fuel" and w.choir.get("bw_sold", false):
		idx *= float(w.data.faction_by_id["burning_water"]["choir_pressure"]["if_falls"]["guzzoline_cat_index_multiplier"])
	if good == "guzzoline" and h["embargo_until"] >= w.month:
		idx *= 2.0
	return float(r["base"]) * (float(p["buy_k0"]) + float(p["buy_ks"]) * s + float(p["buy_kw"]) * wl) * idx


static func mean_price(w, good: String) -> float:
	var t := 0.0
	var n := 0
	for id in w.live_holds():
		t += buy_price(w, id, good)
		n += 1
	return t / max(n, 1)


static func _shuffle(w, a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j = w.rng.randi_range(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t
