## Sub-factions (docs/design/18-sub-factions.md, rules/subfactions.json): backing drift,
## one verb a month, and the Choir's Turning of the Hum-touched.
extends RefCounted

const Lean := preload("res://sim/lean.gd")

const RAID_RANGE_KM := 400.0


static func init_sub(w, s: Dictionary) -> Dictionary:
	var backs: String = s["backs"] if s["backs"] != null else ""
	var hum: String = s["hum"]
	return {"id": s["id"], "type": s["type"], "home": s["home"], "backs": backs,
		"bidder": backs == "highest_bidder", "hum": "touched" if hum == "touched" else hum,
		"turning": 0.0, "turned": false, "switches": 0, "raids": s.get("raids", [])}


static func chapters(w, sid: String) -> Array:
	var out: Array = []
	for id in w.H:
		if int(w.H[id]["subs"].get(sid, {}).get("presence", 0)) > 0:
			out.append(id)
	return out


static func _backed(w, sid: String) -> String:
	var s: Dictionary = w.S[sid]
	if s["turned"]:
		return ""
	if s["bidder"]:
		# The Odd Lot backs whoever is biggest this month.
		var best := ""
		var best_n := 0
		for f in w.F:
			if w.F[f]["alive"]:
				var n: int = w.holds_leaning_to(f).size()
				if n > best_n:
					best = f
					best_n = n
		return best
	var b: String = s["backs"]
	return b if w.F.has(b) and w.F[b]["alive"] else ""


## Presence x 2 Lean a month to the backed faction, in every chapter hold.
static func backing_drift(w) -> void:
	var per := float(w.data.subfactions["backing"]["drift_points_per_presence"])
	for sid in w.S:
		var f := _backed(w, sid)
		if f == "":
			continue
		for id in chapters(w, sid):
			if not w.H[id]["silenced"]:
				w.drift(id, f, per * int(w.H[id]["subs"][sid]["presence"]))


static func act(w) -> void:
	var verbs: Dictionary = w.data.subfactions["verbs"]
	for sid in w.S:
		var s: Dictionary = w.S[sid]
		if s["turned"]:
			_preach(w, sid)   # turned chapters spread for the Choir
			continue
		var wts: Dictionary = verbs[s["type"]]
		var names: Array = []
		var weights: Array = []
		for v in wts:
			if float(wts[v]) > 0.0:
				names.append(v)
				weights.append(float(wts[v]))
		match names[_weighted(w, weights)]:
			"raid": _raid(w, sid)
			"grow": _grow(w, sid, false)
			"preach": _preach(w, sid)
			"work": _work(w, sid)
			"hide": _grow(w, sid, true)
			"back": _back(w, sid)
	_turning(w)


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


static func _raid(w, sid: String) -> void:
	var s: Dictionary = w.S[sid]
	var bases: Array = chapters(w, sid)
	var cands: Array = []
	var preferred: Array = []
	for b in bases:
		for id in w.graph.nearest(b, RAID_RANGE_KM):
			var l: String = w.leans(id)
			if w.H[id]["silenced"] or l == "" or l == Lean.IND or l == _backed(w, sid) or cands.has(id):
				continue
			cands.append(id)
			if s["raids"].has("burning_water_crude") and l == "burning_water":
				preferred.append(id)
	if cands.is_empty():
		return
	var pool: Array = preferred if not preferred.is_empty() and w.rng.randf() < 0.6 else cands
	var t: String = pool[w.rng.randi_range(0, pool.size() - 1)]
	var victim: String = w.leans(t)
	w.drift(t, victim, -3.0)
	var backer := _backed(w, sid)
	if backer != "":
		w.drift(t, backer, 1.0)
	for g in w.H[t]["stock"]:
		w.H[t]["stock"][g] = float(w.H[t]["stock"][g]) * 0.7
	if victim == "burning_water" and sid == "teeth":
		w.teeth_raids.append(w.month)
	if victim == "highwater" and w.F["highwater"]["routes"].has(t):
		var pen := float(w.data.faction_by_id["highwater"]["engine"]["raid_penalty_along_route"])
		for r in w.F["highwater"]["routes"]:
			if not w.H[r]["silenced"]:
				w.drift(r, "highwater", -pen)
	w.say("raid", "%s raid %s." % [w.data.sub_by_id[sid]["name"], t])


static func _grow(w, sid: String, hidden: bool) -> void:
	var cands: Array = []
	for b in chapters(w, sid):
		for n in w.graph.neighbours(b):
			if not w.H[n]["silenced"] and not w.H[n]["subs"].has(sid) and not cands.has(n):
				cands.append(n)
	if cands.is_empty():
		return
	var t: String = cands[w.rng.randi_range(0, cands.size() - 1)]
	w.H[t]["subs"][sid] = {"presence": int(w.data.subfactions["presence"]["new_chapter"]), "hidden": hidden}


static func _preach(w, sid: String) -> void:
	var ch: Array = chapters(w, sid).filter(func(id): return not w.H[id]["silenced"])
	if ch.is_empty():
		return
	var t: String = ch[w.rng.randi_range(0, ch.size() - 1)]
	var p: Dictionary = w.H[t]["subs"][sid]
	p["presence"] = min(int(w.data.subfactions["presence"]["max"]), int(p["presence"]) + 1)
	if w.S[sid]["hum"] == "touched":
		w.H[t]["hum"] = min(100.0, w.H[t]["hum"] + 1.0)


static func _work(w, sid: String) -> void:
	var ch: Array = chapters(w, sid).filter(func(id): return not w.H[id]["silenced"])
	if ch.is_empty():
		return
	var t: String = ch[w.rng.randi_range(0, ch.size() - 1)]
	for g in w.H[t]["surplus"]:
		w.H[t]["stock"][g] = float(w.H[t]["stock"].get(g, 0.0)) + 2.0


## Switch backing toward the faction its chapters live among, if that isn't the current one.
static func _back(w, sid: String) -> void:
	var s: Dictionary = w.S[sid]
	if s["bidder"]:
		return
	var totals := {}
	for id in chapters(w, sid):
		var l = w.H[id]["lean"]
		if l == null:
			continue
		for f in l:
			if w.F.has(f) and w.F[f]["alive"]:
				totals[f] = totals.get(f, 0.0) + float(l[f]) * int(w.H[id]["subs"][sid]["presence"])
	var best := ""
	var best_v := 0.0
	for f in totals:
		if totals[f] > best_v:
			best = f
			best_v = totals[f]
	var cur: String = s["backs"]
	if best == "" or best == cur:
		return
	if cur != "" and totals.get(cur, 0.0) >= best_v * 0.8:
		return
	if w.rng.randf() < float(w.data.subfactions["backing"]["ai_switch_chance_when_want_fed_elsewhere"]):
		s["backs"] = best
		s["switches"] += 1
		w.say("backing", "%s now back %s." % [w.data.sub_by_id[sid]["name"], w.data.faction_by_id[best]["name"]])


static func _turning(w) -> void:
	var t: Dictionary = w.data.subfactions["turning"]
	for sid in t["per_month"]:
		var s: Dictionary = w.S[sid]
		var rule: Dictionary = t["per_month"][sid]
		if s["turned"]:
			continue
		if w.reach_at_least(rule["from_reach"]):
			s["turning"] += float(rule["rate"])
	for sid in w.S:
		var s: Dictionary = w.S[sid]
		if not s["turned"] and s["turning"] >= float(t["turned_at"]):
			s["turned"] = true
			s["hum"] = "turned"
			s["backs"] = ""
			w.say("choir", "%s are turned. Their chapters open their holds to the Choir." % w.data.sub_by_id[sid]["name"])
