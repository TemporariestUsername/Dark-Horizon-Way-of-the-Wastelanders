## The Choir: a slow, creeping spread with no clock and no end state
## (docs/design/17-factions.md, rules/choir.json). Ported from tools/sim_choir.py, now
## running against live factions, sub-factions and Lean.
extends RefCounted

const Lean := preload("res://sim/lean.gd")
const GangWar := preload("res://sim/gang_war.gd")

## Share of coffles that reach Harrowgate when nobody hunts them (no player in M1).
const COFFLE_DELIVERY := 0.75
## Before the Choir is Marching, courting Burning Water means Ba's trade: Hum at Pitch.
const COURTSHIP_HUM_AT_PITCH := 6.0


static func init_choir(w) -> void:
	var c: Dictionary = w.data.choir
	w.choir = {"voices": float(c["voices"]["start"]), "coffles": [], "ba_courtships": 0, "bw_sold": false,
		"coffle_months": int(ceil(w.graph.travel_days("pellet", "harrowgate") / 30.0))}
	for id in c["hum"]["start"]:
		w.H[id]["hum"] = float(c["hum"]["start"][id])
	for id in w.H:
		if w.H[id]["silenced"]:
			w.H[id]["hum"] = 100.0


static func _voices_multiplier(w) -> float:
	# "1 + voices/200"
	var expr: String = w.data.choir["hum"]["seep"]["voices_multiplier"]
	return 1.0 + w.choir["voices"] / float(expr.get_slice("/", 1))


static func turn(w) -> void:
	var c: Dictionary = w.data.choir
	var hum_rules: Dictionary = c["hum"]
	var seep: Dictionary = hum_rules["seep"]
	var defs: Dictionary = hum_rules["defences"]
	var stages: Dictionary = hum_rules["stages"]
	var before := {}
	for id in w.H:
		before[id] = w.H[id]["hum"]
	# Seep from Silenced (and, more weakly, Marked) holds along the roads.
	var rng_km := float(seep["seep_range_km"])
	var vm := _voices_multiplier(w)
	var gain := {}
	for src in w.H:
		var hs: float = w.H[src]["hum"]
		var factor := 0.0
		if w.H[src]["silenced"]:
			factor = 1.0
		elif hs >= float(stages["marked"]):
			factor = float(seep["marked_factor"])
		if factor == 0.0:
			continue
		for tgt in w.graph.nearest(src, rng_km):
			if w.H[tgt]["silenced"]:
				continue
			gain[tgt] = gain.get(tgt, 0.0) + float(seep["seep_silenced"]) * factor * (1.0 - w.graph.km(src, tgt) / rng_km) * vm
	for tgt in gain:
		w.H[tgt]["hum"] = min(100.0, w.H[tgt]["hum"] + gain[tgt] * _defence(w, tgt, defs))
	# Turned sub-factions open their holds from inside.
	for s in w.S:
		if not w.S[s]["turned"]:
			continue
		for id in w.H:
			var p: int = w.H[id]["subs"].get(s, {}).get("presence", 0)
			if p > 0 and not w.H[id]["silenced"]:
				w.H[id]["hum"] = min(100.0, w.H[id]["hum"] + float(hum_rules["turned_presence_per_point"]) * p)
				gain[id] = true
	# Ba's trade with Harrowgate.
	var bw: Dictionary = w.data.faction_by_id["burning_water"]["choir_pressure"]
	if w.F["burning_water"]["alive"] and not w.choir["bw_sold"] and w.H.has("pitch") and not w.H["pitch"]["silenced"]:
		w.H["pitch"]["hum"] = min(100.0, w.H["pitch"]["hum"] + float(bw["pitch_hum_bonus_per_month"]))
		gain["pitch"] = true
	# Decay where nothing feeds the Hum.
	for id in w.H:
		var h: Dictionary = w.H[id]
		if not h["silenced"] and not gain.has(id) and h["hum"] > 0.0 and not hum_rules["start"].has(id):
			h["hum"] = max(0.0, h["hum"] - float(hum_rules["decay_per_month_without_source"]))
	# The Choir's own actions, by reach.
	var n_sil: int = w.silenced_count()
	var n_actions := 0
	for t in c["actions"]["per_month_by_reach"]:
		if n_sil >= int(t["from_silenced"]):
			n_actions = int(t["actions"])
	var acts: Dictionary = c["actions"]["list"]
	var names: Array = []
	var weights: Array = []
	for a in acts:
		if float(acts[a]["weight"]) > 0.0:
			names.append(a)
			weights.append(float(acts[a]["weight"]))
	for i in n_actions:
		match names[_weighted(w, weights)]:
			"press": _press(w)
			"run_coffle": _run_coffle(w)
			"cantor": _cantor(w)
			"court_burning_water": _court(w, bw)
	# Coffles arriving at Harrowgate.
	var still: Array = []
	for arrive in w.choir["coffles"]:
		if arrive <= w.month:
			if w.rng.randf() < COFFLE_DELIVERY:
				_add_voices(w, float(c["voices"]["per_coffle_delivered"]))
		else:
			still.append(arrive)
	w.choir["coffles"] = still
	# The Opened march, once the Choir is Marching.
	if n_sil >= int(c["actions"]["march_from_silenced"]) and w.rng.randf() < float(c["actions"]["march_chance_per_month"]):
		_march(w, stages)
	# Stage changes, Silencing, and Marked holds' Lean draining to no one.
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["silenced"]:
			continue
		if h["hum"] >= float(stages["silenced"]):
			silence(w, id)
			continue
		if h["hum"] >= float(stages["marked"]):
			if before[id] < float(stages["marked"]):
				w.say("choir", "The Choir's circle appears on the doors of %s." % id)
			var l = h["lean"]
			var top := Lean.leader(l)
			if top != "" and top != Lean.IND:
				Lean.add(l, top, -3.0)
		elif h["hum"] >= float(stages["touched"]) and before[id] < float(stages["touched"]):
			w.say("choir", "People in %s dream the dream. Some leave for Harrowgate." % id)


static func _defence(w, id: String, defs: Dictionary) -> float:
	var mult := 1.0
	var l: String = w.leans(id)
	if w.F.has(l) and w.F[l]["alive"] and w.F[l]["temperament"].has("deaf"):
		mult *= float(defs["deaf_faction_leans"])
	elif l == "choir":
		mult *= float(defs["hum_touched_faction_leans"])
	for s in ["keepers", "watchers"]:
		var p: int = w.H[id]["subs"].get(s, {}).get("presence", 0)
		if p > 0 and not w.S[s]["turned"]:
			mult *= pow(float(defs[s + "_presence_each"]), p)
	return mult


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


static func _press(w) -> void:
	var cands: Array = []
	for id in w.H:
		var hv: float = w.H[id]["hum"]
		if not w.H[id]["silenced"] and hv >= 30.0 and hv < 100.0:
			cands.append(id)
	if not cands.is_empty():
		var t: String = cands[w.rng.randi_range(0, cands.size() - 1)]
		w.H[t]["hum"] = min(100.0, w.H[t]["hum"] + 12.0)


static func _run_coffle(w) -> void:
	var pellet: Dictionary = w.H["pellet"]
	if not pellet["silenced"] and Lean.leader(pellet["lean"]) != "choir":
		return   # Pellet has been taken: the coffles stop
	w.choir["coffles"].append(w.month + w.choir["coffle_months"])


static func _cantor(w) -> void:
	var cands: Array = w.S.keys().filter(func(s): return w.S[s]["hum"] == "touched" and not w.S[s]["turned"])
	if cands.is_empty():
		_press(w)
		return
	var s: String = cands[w.rng.randi_range(0, cands.size() - 1)]
	w.S[s]["turning"] += float(w.data.subfactions["turning"]["cantor_action"])


static func _court(w, bw: Dictionary) -> void:
	if not w.F["burning_water"]["alive"] or w.choir["bw_sold"]:
		_press(w)
		return
	if w.reach_at_least(bw["courtship_needs_reach"]):
		w.choir["ba_courtships"] += 1
		if w.choir["ba_courtships"] >= int(bw["seat_sold_after_courtships"]):
			w.choir["bw_sold"] = true
			w.say("choir", "Ba sells Burning Water to the Choir. Guzzoline prices triple everywhere.")
			silence(w, w.F["burning_water"]["seat"])
	elif w.H.has("pitch") and not w.H["pitch"]["silenced"]:
		w.H["pitch"]["hum"] = min(100.0, w.H["pitch"]["hum"] + COURTSHIP_HUM_AT_PITCH)


static func _march(w, stages: Dictionary) -> void:
	var cands: Array = []
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["silenced"] or h["hum"] < float(stages["marked"]):
			continue
		for n in w.graph.neighbours(id):
			if w.H[n]["silenced"]:
				cands.append(id)
				break
	if cands.is_empty():
		return
	var target: String = cands[w.rng.randi_range(0, cands.size() - 1)]
	var hg: Dictionary = w.H["harrowgate"]["gang"]
	var force := {"troops": float(hg["troops"]) * 0.5, "arms": hg["arms"], "training": hg["training"], "tags": ["opened"]}
	var h: Dictionary = w.H[target]
	var res := GangWar.resolve(force, h["gang"], h["walls"], w.data.war, w.rng)
	h["gang"]["troops"] = res["def_troops"]
	if res["attacker_won"]:
		w.say("choir", "The Opened march on %s, and it falls silent." % target)
		silence(w, target)
	else:
		w.say("choir", "The Opened march on %s, and are thrown back." % target)


static func _add_voices(w, v: float) -> void:
	w.choir["voices"] = min(float(w.data.choir["voices"]["max"]), w.choir["voices"] + v)


## A hold falls to the Choir: off the influence board, its people Opened.
static func silence(w, id: String) -> void:
	var h: Dictionary = w.H[id]
	if h["silenced"]:
		return
	h["silenced"] = true
	h["hum"] = 100.0
	h["lean"] = null
	var troops: float = max(10.0, float(h["gang"]["troops"]))
	h["gang"] = {"troops": troops, "arms": 30, "training": 20, "tags": ["opened"]}
	h["gang_base"] = h["gang"].duplicate(true)
	_add_voices(w, float(w.data.choir["voices"]["per_hold_silenced"]))
	w.say("choir", "%s is Silenced." % id)
