## The event system (docs/design/05-events.md): picks road, encounter and hold events by
## weight, from the threats actually present, and resolves the player's choice.
##
##   weight = base x region and season fit x danger ring (bad, lethal) x threat present
##            x supplies x repeat penalty
##
## Anti-frustration rules enforced here: a lethal event needs its threat warned within
## warning_memory_days; after bad_streak_breather bad events in a row only good or neutral
## events can fire; every event offers at least one choice without a check (the validator
## checks that).
extends RefCounted

const Characters := preload("res://sim/characters.gd")
const SimData := preload("res://sim/sim_data.gd")

var data
var graph
var world          # optional World: Hum levels and Lean (null = the map as it starts)
var rng: RandomNumberGenerator
var cfg: Dictionary
var threats: Dictionary = {}
var warned: Dictionary = {}       # threat id -> day warned
var last_fired: Dictionary = {}   # event id -> day
var bad_streak := 0
var decisions: Array = []         # the designer overlay's log: eligible events, weights, pick


func setup(sim_data, road_graph, a_world, random: RandomNumberGenerator) -> void:
	data = sim_data
	graph = road_graph
	world = a_world
	rng = random
	cfg = data.threats
	for t in cfg["threats"]:
		threats[t["id"]] = t


func hum_at(id: String) -> float:
	if world != null:
		return world.H[id]["hum"]
	return float(data.choir["hum"]["start"].get(id, 100.0 if data.hold_by_id[id]["silenced"] else 0.0))


## Highest Hum within 300 km of a hold.
func hum_near(id: String) -> float:
	var best := hum_at(id)
	for o in graph.nearest(id, 300.0):
		best = max(best, hum_at(o))
	return best


## Distance to a threat (km), or INF if it isn't present here and now.
func threat_distance(t: Dictionary, hold: String, season: String) -> float:
	if t.has("seasons") and not t["seasons"].has(season):
		return INF
	if t.get("anywhere", false):
		return 0.0
	if t.has("hum_zone"):
		return 0.0 if hum_near(hold) >= float(t["hum_zone"]) else INF
	var km: float = graph.km(t["at"], hold)
	return km if km <= float(t["roams_km"]) else INF


func _present(kind: String, hold: String, season: String) -> Array:
	var out: Array = []
	for id in threats:
		var t: Dictionary = threats[id]
		if t["kind"] == kind and threat_distance(t, hold, season) < INF:
			out.append(id)
	return out


func nearest_threat(hold: String, season: String, kind: String = "") -> String:
	var best := ""
	var best_d := INF
	for id in threats:
		var t: Dictionary = threats[id]
		if kind != "" and t["kind"] != kind:
			continue
		if not t.has("at"):
			continue   # everywhere, or wherever the Hum is: not a place to point at
		var d := threat_distance(t, hold, season)
		if d < best_d:
			best = id
			best_d = d
	return best


func is_warned(threat_id: String, day: float) -> bool:
	return warned.has(threat_id) and day - float(warned[threat_id]) <= float(cfg["warning_memory_days"])


## ctx: {day, hold, region, ring, season, kind ("road" or "hold"), crossing, water, chow}
func eligible(ctx: Dictionary) -> Array:
	var out: Array = []
	var kinds: Array = ["road", "encounter"] if ctx["kind"] == "road" else ["hold"]
	var region := SimData.norm(ctx["region"])
	for e in data.events["events"]:
		if not kinds.has(e["kind"]):
			continue
		if e.has("regions_only") and not e["regions_only"].has(region):
			continue
		if e.has("seasons_only") and not e["seasons_only"].has(ctx["season"]):
			continue
		var needs: Dictionary = e.get("needs", {})
		if needs.get("crossing", false) and not ctx.get("crossing", false):
			continue
		if float(ctx.get("chow", 99)) < float(needs.get("chow_min", 0)) or float(ctx.get("water", 99)) < float(needs.get("water_min", 0)):
			continue
		var tone: String = e["tone"]
		if bad_streak >= int(cfg["bad_streak_breather"]) and (tone == "bad" or tone == "lethal"):
			continue
		var threat := ""
		if e.has("threat"):
			if threat_distance(threats[e["threat"]], ctx["hold"], ctx["season"]) == INF:
				continue
			threat = e["threat"]
		elif e.has("threat_kind"):
			var present := _present(e["threat_kind"], ctx["hold"], ctx["season"])
			if present.is_empty():
				continue
			threat = present[0]
		if e.has("near_home_km") and threat != "" and threats[threat].has("at"):
			if graph.km(threats[threat]["at"], ctx["hold"]) > float(e["near_home_km"]):
				continue
		if e.get("needs_warning", false) and not is_warned(threat, ctx["day"]):
			continue
		var w := float(e["weight"])
		if e["kind"] == "encounter":
			w *= float(cfg.get("encounter_weight", 1.0))
		w *= float(e.get("regions", {}).get(region, 1.0))
		w *= float(e.get("seasons", {}).get(ctx["season"], 1.0))
		if tone == "bad" or tone == "lethal":
			w *= float(cfg["danger_ring"].get(ctx["ring"], 1.0))
		if threat != "":
			w *= 1.5
		if e.get("warning", false) and threat != "" and is_warned(threat, ctx["day"]):
			w *= 0.2   # already warned: the warning is old news
		if e.has("hum_weight") and hum_near(ctx["hold"]) >= 30.0:
			w *= float(e["hum_weight"])
		if last_fired.has(e["id"]) and ctx["day"] - float(last_fired[e["id"]]) < float(cfg["repeat_penalty_days"]):
			w *= float(cfg["repeat_penalty"])
		if w > 0.0:
			out.append({"event": e, "weight": w, "threat": threat})
	return out


## Draws one event (or nothing) for this day or hold visit. Returns {} for "nothing happens".
func draw(ctx: Dictionary) -> Dictionary:
	var cands := eligible(ctx)
	var quiet := float(cfg["quiet_weight"]) if ctx["kind"] == "road" else float(cfg["quiet_weight"]) * 0.5
	var total := quiet
	for c in cands:
		total += c["weight"]
	var r := rng.randf() * total
	var pick: Dictionary = {}
	if r >= quiet:
		r -= quiet
		for c in cands:
			r -= c["weight"]
			if r <= 0.0:
				pick = c
				break
	decisions.append({"day": ctx["day"], "hold": ctx["hold"], "eligible": cands.map(func(c): return [c["event"]["id"], snappedf(c["weight"], 0.01)]),
		"pick": pick["event"]["id"] if not pick.is_empty() else "nothing"})
	if pick.is_empty():
		return {}
	var e: Dictionary = pick["event"]
	last_fired[e["id"]] = ctx["day"]
	if e["tone"] == "bad" or e["tone"] == "lethal":
		bad_streak += 1
	else:
		bad_streak = 0
	return pick


## Success chance of a choice's check for this party: the best member's attribute and skill.
func chance(choice: Dictionary, party: Array) -> int:
	var c: Dictionary = choice["check"]
	var best := 0
	for m in party:
		if m["down"]:
			continue
		var rank := int(m["skills"].get(c.get("skill", ""), 0))
		best = max(best, Characters.check_chance(data.characters, float(m["attributes"][c["attr"]]), c["difficulty"], rank))
	return best


## The effects of a choice (rolling its check if it has one). Returns {effects, check, chance, success}.
func resolve(choice: Dictionary, party: Array) -> Dictionary:
	if not choice.has("check"):
		return {"effects": choice.get("effects", {}), "check": false}
	var p := chance(choice, party)
	var ok := rng.randf() * 100.0 < p
	return {"effects": choice["success"] if ok else choice["failure"], "check": true, "chance": p, "success": ok}


func warn(threat_id: String, day: float) -> void:
	if threat_id != "":
		warned[threat_id] = day
