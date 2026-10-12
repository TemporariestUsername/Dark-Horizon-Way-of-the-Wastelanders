## The six hardholder factions (docs/design/17-factions.md, rules/factions.json):
## influence engines, monthly actions, ambitions, grip and death.
extends RefCounted

const Lean := preload("res://sim/lean.gd")
const GangWar := preload("res://sim/gang_war.gd")
const Conditions := preload("res://sim/conditions.gd")

const GRIPS := ["weak", "holding", "strong", "iron"]
const WAR_MEMORY_MONTHS := 12     # war(a, b) stays true this long
const BUILD_CHANCE := 0.2         # monthly chance to raise a wall an ambition needs


static func init_faction(w, f: Dictionary) -> Dictionary:
	var rel := {}
	for other in w.data.factions["factions"]:
		var o: String = other["id"]
		if o == f["id"]:
			continue
		var r: Dictionary = w.data.factions["relations"]
		rel[o] = int(r.get(f["id"], {}).get(o, r.get(o, {}).get(f["id"], 0)))
	var st := {
		"id": f["id"], "alive": true, "seat": f["seat"], "grip": f["grip"], "grip_score": 0,
		"temperament": f["temperament"], "relations": rel, "stage": 0, "targets": f["expansion_targets"].duplicate(),
		"study": "", "wars": {}, "routes": [], "aquifer": 0.0, "last_embargo": -99, "last_shutoff": -99,
		"treasury": 0.0, "conquests": 0,
	}
	if f["engine"]["type"] == "freight":
		for chain in f["engine"]["initial_routes"]:
			for id in chain:
				if not st["routes"].has(id):
					st["routes"].append(id)
	if f.has("aquifer"):
		st["aquifer"] = float(f["aquifer"]["start"])
	return st


static func living(w) -> Array:
	return w.F.keys().filter(func(f): return w.F[f]["alive"])


static func rule(w, fid: String) -> Dictionary:
	return w.data.faction_by_id[fid]


static func at_war(w, a: String, x: String) -> bool:
	if not w.F.has(a):
		return false
	var fresh := func(fs: Dictionary, key: String) -> bool:
		return fs["wars"].has(key) and int(fs["wars"][key]) > w.month - WAR_MEMORY_MONTHS
	if fresh.call(w.F[a], x):
		return true
	return w.F.has(x) and fresh.call(w.F[x], a)


## The faction whose fuel a hold runs on: who the nearest live guzzoline source leans to.
static func fuel_source_faction(w, id: String) -> String:
	var key := "fuel|" + id
	if not w.cache.has(key):
		var srcs: Array = []
		if w.H[id]["surplus"].has("guzzoline"):
			srcs.append(id)
		for o in w.graph.nearest(id, 1.0e9):
			if w.H[o]["surplus"].has("guzzoline"):
				srcs.append(o)
		w.cache[key] = srcs
	for src in w.cache[key]:
		if not w.H[src]["silenced"]:
			return w.leans(src)
	return ""


## Crossing holds on the shortest road path between two holds (cached; the graph is fixed).
static func crossings_on_path(w, a: String, b: String) -> Array:
	var key := "xing|%s|%s" % [a, b]
	if not w.cache.has(key):
		var out: Array = []
		for e in w.graph.path_edges(a, b):
			if e["crossing"] != null and not out.has(e["crossing"]):
				out.append(e["crossing"])
		w.cache[key] = out
	return w.cache[key]


# ---------------------------------------------------------------- 1. ambitions

static func advance_ambitions(w) -> void:
	for fid in living(w):
		var fs: Dictionary = w.F[fid]
		var stages: Array = rule(w, fid)["ambition"]["stages"]
		while fs["stage"] < stages.size() and Conditions.evaluate(stages[fs["stage"]]["when"], w):
			w.say("ambition", "%s: %s" % [rule(w, fid)["name"], stages[fs["stage"]]["goal"]])
			fs["stage"] += 1
		var targets: Array = []
		if fs["stage"] < stages.size():
			targets = Conditions.mentioned_holds(stages[fs["stage"]]["when"], w.H)
			_work_toward(w, fid, stages[fs["stage"]]["when"])
		for t in rule(w, fid)["expansion_targets"]:
			if not targets.has(t):
				targets.append(t)
		fs["targets"] = targets.filter(func(t): return not w.H[t]["silenced"] and w.leans(t) != fid)


## Some ambition clauses are things a faction builds rather than takes: walls(h) >= n.
## Each month there's a chance it raises a wall there, if the hold isn't a rival's.
static func _work_toward(w, fid: String, expr: String) -> void:
	for clause in expr.split(" and "):
		var c: String = clause.strip_edges()
		if not c.begins_with("walls(") or Conditions.evaluate(c, w):
			continue
		var id: String = c.get_slice("(", 1).get_slice(")", 0)
		var l: String = w.leans(id)
		if w.H[id]["silenced"] or (l != "" and l != Lean.IND and l != fid):
			continue
		if w.rng.randf() < BUILD_CHANCE:
			w.H[id]["walls"] = mini(2, w.H[id]["walls"] + 1)
			w.say("faction", "%s builds at %s." % [rule(w, fid)["name"], id])


## A stage that needs `war(self, X)` once its other clauses hold forces an attack on X.
static func forced_war_target(w, fid: String) -> String:
	var fs: Dictionary = w.F[fid]
	var stages: Array = rule(w, fid)["ambition"]["stages"]
	if fs["stage"] >= stages.size():
		return ""
	var target := ""
	var others_hold := true
	for clause in stages[fs["stage"]]["when"].split(" and "):
		var c: String = clause.strip_edges()
		if c.begins_with("war(" + fid + ","):
			target = c.trim_prefix("war(" + fid + ",").trim_suffix(")").strip_edges()
		elif not Conditions.evaluate(c, w):
			others_hold = false
	if target == "" or not others_hold:
		return ""
	if w.H.has(target):
		return target if not w.H[target]["silenced"] else ""
	# A faction target: its nearest leaning hold.
	var best := ""
	var best_km := INF
	for id in w.holds_leaning_to(target):
		var km: float = w.graph.km(fs["seat"], id)
		if km < best_km:
			best = id
			best_km = km
	return best


# ---------------------------------------------------------------- 2. influence engines

static func run_engines(w) -> void:
	for fid in living(w):
		var eng: Dictionary = rule(w, fid)["engine"]
		match eng["type"]:
			"passage": _passage(w, fid, eng)
			"thirst": _thirst(w, fid, eng)
			"freight": _freight(w, fid, eng)
			"debt": _debt(w, fid, eng)
			"fuel": _fuel(w, fid, eng)
			"walls": _walls(w, fid, eng)


static func _passage(w, fid: String, eng: Dictionary) -> void:
	var seat: String = w.F[fid]["seat"]
	var mine: Array = []
	for id in w.H:
		if w.H[id]["crossing"] and w.leans(id) == fid:
			mine.append(id)
	if mine.is_empty():
		return
	var pts: float = min(float(eng["max_points"]), float(eng["base_points"]) + float(eng["per_extra_crossing"]) * (mine.size() - 1))
	for id in w.graph.nearest(seat, float(eng["radius_km"])):
		if w.H[id]["silenced"]:
			continue
		for x in crossings_on_path(w, id, seat):
			if mine.has(x):
				w.drift(id, fid, pts)
				break


static func _thirst(w, fid: String, eng: Dictionary) -> void:
	var fs: Dictionary = w.F[fid]
	var aq: Dictionary = rule(w, fid)["aquifer"]
	var summer: bool = w.season() == "summer"
	fs["aquifer"] = max(0.0, fs["aquifer"] - float(aq["loss_per_year"]) / 12.0 - (float(aq["long_heat_extra_loss"]) / 3.0 if summer else 0.0))
	if fs["aquifer"] <= 0.0 and not fs.get("springs_failed", false):
		fs["springs_failed"] = true
		if w.H[fs["seat"]]["surplus"].has("water"):
			w.H[fs["seat"]]["surplus"]["water"] = 1
		w.say("faction", "Sweetwell's springs fail. Grome goes to war for water.")
	var pts := float(eng["points"]) * (float(eng["long_heat_multiplier"]) if summer else 1.0)
	var in_range: Array = w.graph.nearest(fs["seat"], float(eng["tanker_range_km"]))
	for id in in_range:
		if not w.H[id]["silenced"] and int(w.H[id]["want"].get("water", 0)) >= int(eng["min_want"]):
			w.drift(id, fid, pts)
	if w.month - fs["last_shutoff"] >= int(eng["shutoff"]["cooldown_months"]):
		for id in in_range:
			var l: String = w.leans(id)
			if w.H[id]["silenced"] or l == fid or l == "" or not w.H[id]["want"].has("water"):
				continue
			if l != Lean.IND and fs["relations"].get(l, 0) >= 1:
				continue
			w.H[id]["want"]["water"] = min(3, int(w.H[id]["want"]["water"]) + int(eng["shutoff"]["adds_water_want"]))
			w.H[id]["shutoff_until"] = w.month + 1
			fs["last_shutoff"] = w.month
			w.say("faction", "Grome shuts off the water to %s." % id)
			break


static func _freight(w, fid: String, eng: Dictionary) -> void:
	var fs: Dictionary = w.F[fid]
	var pts := float(eng["points"]) * (float(eng["winter_multiplier"]) if w.season() == "winter" else 1.0)
	for id in fs["routes"]:
		if not w.H[id]["silenced"]:
			w.drift(id, fid, pts)
	if w.rng.randf() < float(eng["extend_chance"]):
		var best := ""
		var best_score := INF
		for r in fs["routes"]:
			for id in w.graph.nearest(r, float(eng["extend_km"])):
				if fs["routes"].has(id) or w.H[id]["silenced"]:
					continue
				var l: String = w.leans(id)
				if l != "" and l != Lean.IND and l != fid and fs["relations"].get(l, 0) <= -2:
					continue
				var score: float = w.graph.km(r, id) - (1000.0 if fs["targets"].has(id) else 0.0)
				if score < best_score:
					best = id
					best_score = score
		if best != "":
			fs["routes"].append(best)
			w.say("faction", "Highwater's freight now runs to %s." % best)


static func _debt(w, fid: String, eng: Dictionary) -> void:
	var fs: Dictionary = w.F[fid]
	# Debtors slide toward the Exchange until they repay.
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["debt"] <= 0.0 or h["silenced"]:
			continue
		w.drift(id, fid, float(eng["slide_points"]))
		if w.rng.randf() < float(eng["repay_chance_per_month"]):
			h["debt"] = 0.0
	# New loans: up to two holds in want.
	var lent := 0
	for id in w.graph.nearest(fs["seat"], 1.0e9):
		if lent >= 2:
			break
		var h: Dictionary = w.H[id]
		if h["silenced"] or h["debt"] > 0.0 or w.leans(id) == fid:
			continue
		var wanting := false
		for g in h["want"]:
			if int(h["want"][g]) >= int(eng["lend_to_want_at_least"]):
				wanting = true
		if wanting and w.rng.randf() < 0.5:
			h["debt"] = w.rng.randf_range(float(eng["loan_barter"][0]), float(eng["loan_barter"][1]))
			lent += 1
	# Investment, like the player's: 1 point per 2 barter, in up to three holds.
	var budget := float(eng["invest_budget_barter_per_month"])
	var per_point := float(w.data.lean["player_levers"]["invest_barter_per_point"])
	var picks: Array = fs["targets"].slice(0, 3)
	for id in w.graph.nearest(fs["seat"], 1.0e9):
		if picks.size() >= 3:
			break
		if not picks.has(id) and not w.H[id]["silenced"] and w.leans(id) != fid and not _is_live_seat(w, id):
			picks.append(id)
	for id in picks:
		if not _is_live_seat(w, id):
			w.drift(id, fid, budget / per_point / picks.size())


static func _fuel(w, fid: String, eng: Dictionary) -> void:
	var fs: Dictionary = w.F[fid]
	var in_range: Array = w.graph.nearest(fs["seat"], float(eng["range_km"]))
	for id in in_range:
		var want := int(w.H[id]["want"].get("guzzoline", 0))
		if w.H[id]["silenced"] or want <= 0 or fuel_source_faction(w, id) != fid:
			continue
		w.drift(id, fid, float(eng["points_want2plus"]) if want >= 2 else float(eng["points_want1"]))
	var emb: Dictionary = eng["embargo"]
	if w.month - fs["last_embargo"] >= int(emb["cooldown_months"]):
		for id in in_range:
			var l: String = w.leans(id)
			if w.H[id]["silenced"] or l == fid or not w.H[id]["want"].has("guzzoline"):
				continue
			if l != "" and l != Lean.IND and fs["relations"].get(l, 0) >= 1:
				continue
			w.H[id]["embargo_until"] = w.month + 1
			w.H[id]["want"]["guzzoline"] = min(3, int(w.H[id]["want"]["guzzoline"]) + int(emb["adds_fuel_want"]))
			fs["last_embargo"] = w.month
			var submits: bool = w.rng.randf() < float(emb["submit_chance"])
			w.drift(id, fid, float(emb["submit_points"]) if submits else float(emb["turn_points"]))
			w.say("faction", "Burning Water embargoes %s; it %s." % [id, "submits" if submits else "turns away"])
			break


static func _walls(w, fid: String, eng: Dictionary) -> void:
	var fs: Dictionary = w.F[fid]
	var done := 0
	var cands: Array = fs["targets"].duplicate()
	for id in w.graph.nearest(fs["seat"], float(eng["fortify_range_km"])):
		if not cands.has(id):
			cands.append(id)
	for id in cands:
		if done >= int(eng["fortify_per_month"]):
			break
		var h: Dictionary = w.H[id]
		if h["silenced"] or h["walls"] >= int(eng["walls_max"]) or w.graph.km(fs["seat"], id) > float(eng["fortify_range_km"]):
			continue
		var l: String = w.leans(id)
		if l != "" and l != Lean.IND and l != fid:
			continue   # a protection contract needs a hold that isn't someone else's
		h["walls"] += 1
		if not h["cerro_walled"]:
			h["cerro_walled"] = true
			w.say("faction", "Cerro's walls go up at %s." % id)
		done += 1
	for id in w.H:
		if w.H[id]["cerro_walled"] and not w.H[id]["silenced"]:
			w.drift(id, fid, float(eng["points_per_walled_hold"]))
	for e in w.data.edges:
		if e["kind"] == "riverbed" and e["roads"].has("Rio Grande bed"):
			for id in [e["a"], e["b"]]:
				if not w.H[id]["silenced"]:
					w.drift(id, fid, float(eng["riverbed_toll_points"]))


static func _is_live_seat(w, id: String) -> bool:
	for f in w.F:
		if w.F[f]["alive"] and w.F[f]["seat"] == id:
			return true
	return id == "harrowgate" or id == "pellet"


# ---------------------------------------------------------------- 3. actions

static func take_actions(w) -> void:
	var acts: Dictionary = w.data.factions["actions"]
	var tw: Dictionary = w.data.factions["temperament_weights"]
	for fid in living(w):
		var fs: Dictionary = w.F[fid]
		var forced := forced_war_target(w, fid)
		if forced != "":
			_claim(w, fid, forced)
		var n := int(w.data.factions["grip_actions_per_month"][fs["grip"]])
		for i in n:
			if not fs["alive"]:
				break
			var names: Array = []
			var weights: Array = []
			for a in acts:
				var wt := float(acts[a]["weight"])
				for t in fs["temperament"]:
					wt *= float(tw.get(t, {}).get(a, 1.0))
				if a == "claim_territory":
					if not _can_attack(w, fid) or w.month - int(fs.get("last_claim", -99)) < int(acts[a].get("cooldown_months", 0)):
						wt = 0.0
					if fs.get("springs_failed", false):
						wt *= 2.0
				names.append(a)
				weights.append(wt)
			var pick: String = names[_weighted(w, weights)]
			match pick:
				"claim_territory": _claim(w, fid, "")
				"show_of_force": _show_of_force(w, fid)
				"show_of_discipline": _show_of_discipline(w, fid)
				"offer_to_negotiate": _negotiate(w, fid)
				"buy_out_allies": _buy_out(w, fid)
				"seize_leverage": _seize(w, fid)
				"careful_study": _study(w, fid)
				"demand_tribute": _tribute(w, fid)


static func _weighted(w, weights: Array) -> int:
	var total := 0.0
	for x in weights:
		total += x
	var r: float = w.rng.randf() * total
	for i in weights.size():
		r -= weights[i]
		if r <= 0.0:
			return i
	return weights.size() - 1


static func _claim_range(w) -> float:
	return float(w.data.factions["actions"]["claim_territory"]["range_km"])


static func _sent_share(w) -> float:
	return float(w.data.factions["actions"]["claim_territory"]["sent_share"])


static func _study_bonus(w) -> float:
	return float(w.data.factions["actions"]["careful_study"]["strength_bonus"])


static func _can_attack(w, fid: String) -> bool:
	var g: Dictionary = w.H[w.F[fid]["seat"]]["gang"]
	return not g.get("tags", []).has("defend-only") and float(g["troops"]) * _sent_share(w) >= 8.0


static func _lieutenant_bonus(w, fid: String) -> float:
	var best := 0.0
	for lt in rule(w, fid)["lieutenants"]:
		best = max(best, float(lt["brawn"]))
	return best / 10.0 * float(w.data.war["leader"]["lieutenant_per_10_brawn"])


static func _attack_force(w, fid: String) -> Dictionary:
	var g: Dictionary = w.H[w.F[fid]["seat"]]["gang"]
	return {"troops": float(g["troops"]) * _sent_share(w), "arms": g["arms"], "training": g["training"], "tags": g.get("tags", [])}


static func _defense_strength(w, id: String) -> float:
	var h: Dictionary = w.H[id]
	var eff := GangWar.effective(h["gang"], w.data.war)
	return GangWar.strength(float(h["gang"]["troops"]), eff, 1.0, float(w.data.war["walls_defender_multiplier"][clampi(h["walls"], 0, 2)]))


static func _claim_candidates(w, fid: String) -> Array:
	var fs: Dictionary = w.F[fid]
	var mine: Array = w.holds_leaning_to(fid)
	var out: Array = []
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["silenced"] or w.leans(id) == fid or _is_live_seat(w, id) or h.get("garrison_until", -1) >= w.month:
			continue
		var l: String = w.leans(id)
		if l != "" and l != Lean.IND and fs["relations"].get(l, 0) >= 1:
			continue
		var reachable: bool = w.graph.km(fs["seat"], id) <= _claim_range(w)
		if not reachable:
			for n in w.graph.neighbours(id):
				if mine.has(n):
					reachable = true
					break
		if reachable:
			out.append(id)
	return out


static func _claim(w, fid: String, forced: String) -> void:
	var fs: Dictionary = w.F[fid]
	if not _can_attack(w, fid):
		return
	var force := _attack_force(w, fid)
	var eff := GangWar.effective(force, w.data.war)
	var att_s := GangWar.strength(force["troops"], eff, 1.0, 1.0)
	var steady: bool = fs["temperament"].has("steady")
	var edge := 1.2 if steady else 0.8
	var target := forced
	if target == "":
		var cands := _claim_candidates(w, fid)
		var best_s := INF
		for t in fs["targets"]:
			if cands.has(t) and att_s * (1.0 + _study_bonus(w) if fs["study"] == t else 1.0) > _defense_strength(w, t) * edge:
				target = t
				break
		if target == "":
			for id in cands:
				var ds := _defense_strength(w, id)
				if att_s > ds * edge and ds < best_s:
					best_s = ds
					target = id
	if target == "":
		_show_of_discipline(w, fid)
		return
	fs["last_claim"] = w.month
	var h: Dictionary = w.H[target]
	var defender: String = w.leans(target)
	var att_leader := 1.0 + _lieutenant_bonus(w, fid) + (_study_bonus(w) if fs["study"] == target else 0.0)
	var res := GangWar.resolve(force, h["gang"], h["walls"], w.data.war, w.rng, att_leader, 1.0)
	var seat_gang: Dictionary = w.H[fs["seat"]]["gang"]
	seat_gang["troops"] = float(seat_gang["troops"]) - force["troops"] + res["att_troops"] * (0.5 if res["attacker_won"] else 1.0)
	h["gang"]["troops"] = res["def_troops"] + (res["att_troops"] * 0.5 if res["attacker_won"] else 0.0)
	fs["wars"][target] = w.month
	if defender != "" and defender != Lean.IND:
		fs["wars"][defender] = w.month
		if w.F.has(defender):
			fs["relations"][defender] = max(-2, fs["relations"].get(defender, 0) - 1)
			w.F[defender]["relations"][fid] = max(-2, w.F[defender]["relations"].get(fid, 0) - 1)
	fs["study"] = ""
	if res["attacker_won"]:
		Lean.conquer(h["lean"], fid, float(w.data.lean["conquest"]["conqueror_share"]))
		h["garrison_until"] = w.month + int(w.data.lean["conquest"]["garrison_months"])
		fs["conquests"] += 1
		w.say("war", "%s takes %s by force." % [rule(w, fid)["name"], target])
	else:
		w.say("war", "%s's attack on %s fails." % [rule(w, fid)["name"], target])


static func _show_of_force(w, fid: String) -> void:
	var a: Dictionary = w.data.factions["actions"]["show_of_force"]
	var n := 0
	for id in w.graph.nearest(w.F[fid]["seat"], float(a["range_km"])):
		if n >= int(a["holds"]):
			break
		if w.H[id]["silenced"] or w.leans(id) == fid:
			continue
		w.drift(id, fid, float(a["points"]))
		w.H[id]["fear"] += 1
		n += 1


static func _show_of_discipline(w, fid: String) -> void:
	w.F[fid]["grip_score"] += 1
	for id in w.H:
		var l = w.H[id]["lean"]
		if l != null and Lean.leader(l) == fid and Lean.share(l, fid) < 50.0:
			w.drift(id, fid, float(w.data.factions["actions"]["show_of_discipline"]["regain_points"]))


static func _negotiate(w, fid: String) -> void:
	var fs: Dictionary = w.F[fid]
	var pick := ""
	var lowest := 99
	for o in fs["relations"]:
		if w.F[o]["alive"] and fs["relations"][o] < 1 and fs["relations"][o] >= -1 and fs["relations"][o] < lowest:
			pick = o
			lowest = fs["relations"][o]
	if pick != "" and w.rng.randf() < 0.5:
		fs["relations"][pick] += 1
		w.F[pick]["relations"][fid] = fs["relations"][pick]


static func _buy_out(w, fid: String) -> void:
	var fs: Dictionary = w.F[fid]
	var budget := float(w.data.factions["actions"]["buy_out_allies"]["budget_barter"])
	var pts := budget / float(w.data.lean["player_levers"]["invest_barter_per_point"])
	var cands: Array = fs["targets"].duplicate()
	cands.append_array(w.graph.nearest(fs["seat"], _claim_range(w)))
	for id in cands:
		var l: String = w.leans(id)
		if w.H[id]["silenced"] or l == fid or _is_live_seat(w, id):
			continue
		if l != "" and l != Lean.IND and fs["relations"].get(l, 0) >= 1:
			continue
		w.drift(id, fid, pts)
		return


static func _seize(w, fid: String) -> void:
	for id in w.graph.nearest(w.F[fid]["seat"], _claim_range(w)):
		var l: String = w.leans(id)
		if l != "" and l != Lean.IND and l != fid and w.F[fid]["relations"].get(l, 0) <= -1:
			w.drift(id, l, -2.0)
			w.say("faction", "%s seizes someone from %s for leverage." % [rule(w, fid)["name"], id])
			return


static func _study(w, fid: String) -> void:
	var cands := _claim_candidates(w, fid)
	var fs: Dictionary = w.F[fid]
	for t in fs["targets"]:
		if cands.has(t):
			fs["study"] = t
			return
	if not cands.is_empty():
		fs["study"] = cands[w.rng.randi_range(0, cands.size() - 1)]


static func _tribute(w, fid: String) -> void:
	var tithe: Dictionary = w.data.lean["tithe_barter_per_month"]
	for id in w.holds_leaning_to(fid):
		var h: Dictionary = w.H[id]
		var worst := ""
		var worst_s := 1.0
		for g in h["supplied"]:
			if h["supplied"][g] < worst_s:
				worst = g
				worst_s = h["supplied"][g]
		if worst == "" or worst_s >= float(h["baseline"].get(worst, 0.0)) * 0.5:
			w.F[fid]["treasury"] += float(tithe[h["tier"]]) * 2.0
		elif worst != "":
			h["want"][worst] = min(3, int(h["want"][worst]) + 1)


# ---------------------------------------------------------------- 5. settle

static func settle(w) -> void:
	for fid in living(w):
		var fs: Dictionary = w.F[fid]
		var contested := 0
		for id in w.H:
			var l = w.H[id]["lean"]
			if l != null and Lean.leader(l) == fid and Lean.share(l, fid) < 50.0:
				contested += 1
		if contested > 2:
			fs["grip_score"] -= 1
		var gi := GRIPS.find(fs["grip"])
		if fs["grip_score"] <= -3:
			fs["grip"] = GRIPS[max(0, gi - 1)]
			fs["grip_score"] = 0
		elif fs["grip_score"] >= 3:
			fs["grip"] = GRIPS[min(GRIPS.size() - 1, gi + 1)]
			fs["grip_score"] = 0
		# Seat lost: move to the strongest hold still leaning here, or die.
		var seat: String = fs["seat"]
		if w.H[seat]["silenced"] or w.leans(seat) != fid:
			var best := ""
			var best_t := -1.0
			for id in w.holds_leaning_to(fid):
				if float(w.H[id]["gang"]["troops"]) > best_t:
					best = id
					best_t = float(w.H[id]["gang"]["troops"])
			if best == "":
				_kill(w, fid, "silenced" if w.H[seat]["silenced"] else "taken")
			else:
				fs["seat"] = best
				w.say("faction", "%s loses %s and rules from %s." % [rule(w, fid)["name"], seat, best])


## Home rule: influence fades unless it's kept up (rules/lean.json drift.home_rule_per_month).
static func home_rule(w) -> void:
	var pull := float(w.data.lean["drift"].get("home_rule_per_month", 0.0))
	if pull <= 0.0:
		return
	for id in w.H:
		var l = w.H[id]["lean"]
		if l == null or _is_live_seat(w, id):
			continue
		var top := ""
		var top_v := 0.0
		for k in l:
			if k != Lean.IND and float(l[k]) > top_v:
				top = k
				top_v = float(l[k])
		if top != "":
			Lean.add(l, top, -min(pull, top_v))


## Gangs recover toward their base strength (once a month).
static func recover_gangs(w) -> void:
	var rec := float(w.data.war["outcome"]["survivor_recovery_per_month"])
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["silenced"]:
			continue
		var base := float(h["gang_base"]["troops"])
		var t := float(h["gang"]["troops"])
		if t < base:
			h["gang"]["troops"] = t + (base - t) * rec


static func _kill(w, fid: String, how: String) -> void:
	var fs: Dictionary = w.F[fid]
	fs["alive"] = false
	for id in w.H:
		if w.H[id]["lean"] != null:
			Lean.dissolve(w.H[id]["lean"], fid)
	for s in w.S:
		if w.S[s]["backs"] == fid:
			w.S[s]["backs"] = ""
	w.say("death", "%s is finished: its seat was %s." % [rule(w, fid)["name"], how])
