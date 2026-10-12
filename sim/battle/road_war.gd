## Road war: UWNH's fleet battle on the road (docs/design/09-combat.md, rules/battle.json
## "road_war"). Rigs sit in lanes along the road; their gap to each other sets the range band
## (contact, close, far, gone). Each turn every rig drives, then its manned guns fire; at
## contact a rig can ram or board, and a boarding can turn on a leader duel.
## Positions are along the road relative to where the party's convoy started.
extends RefCounted

const Characters := preload("res://sim/characters.gd")
const GangWar := preload("res://sim/gang_war.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")

const BAND_CONTACT := 1     # gap <= 1: contact
const BAND_CLOSE := 4       # gap <= 4: close
const BAND_FAR := 8         # gap <= 8: far; beyond: gone
const AMMO_SHOTS := 30      # shots a rig carries into a fight
const ROAD_LENGTH := 80     # cells of road the board covers
const OBSTACLE_SHARE := 0.05
const DUEL_EDGE := 1.1          # call a duel when our leader's HP x Attack beats theirs by this much
const FLEE_BELOW := 0.35        # the party AI runs when its strength falls below this share of the enemy's

var data
var rules: Dictionary
var rng: RandomNumberGenerator
var rigs: Array = []
var lanes := 5
var obstacles: Dictionary = {}   # Vector2i(lane, x) -> kind
var round_n := 0
var lines: Array = []
var party_mode := "fight"        # or "flee"
var result := {}


## party_rigs / enemy_rigs: specs as in data/units/units.json (frame, crew, crew_type, guns,
## and for the party, a built `character`; for enemies an optional `leader` unit id).
func setup(sim_data, party_rigs: Array, enemy_rigs: Array, road: String, random: RandomNumberGenerator) -> void:
	data = sim_data
	rules = data.battle["road_war"]
	rng = random
	lanes = int(rules["lanes"][road])
	var i := 0
	for spec in party_rigs:
		rigs.append(_build_rig(spec, "party", i, 0))
		i += 1
	i = 0
	for spec in enemy_rigs:
		rigs.append(_build_rig(spec, "enemy", i, -(BAND_FAR - 1)))
		i += 1
	var kinds := ["dead_car", "dead_car", "pileup", "pillar"]
	for lane in lanes:
		for x in range(-ROAD_LENGTH / 2, ROAD_LENGTH / 2):
			if rng.randf() < OBSTACLE_SHARE and abs(x) > 1:
				obstacles[Vector2i(lane, x)] = kinds[rng.randi_range(0, kinds.size() - 1)]


func _find(list: Array, id: String) -> Dictionary:
	for x in list:
		if x["id"] == id:
			return x
	assert(false, "unknown id " + id)
	return {}


func _build_rig(spec: Dictionary, side: String, idx: int, x: int) -> Dictionary:
	var fr: Dictionary = _find(data.equipment["frames"], spec["frame"])
	var crew_t: Dictionary = _find(data.units["crews"], spec["crew_type"])
	var guns: Array = []
	for gid in spec.get("guns", []):
		guns.append(_find(data.equipment["rig_guns"], gid))
	var ch: Dictionary = spec.get("character", {})
	if ch.is_empty() and spec.has("leader"):
		ch = Characters.build_unit(data, spec["leader"], side, rng, idx)
	var rig := {
		"id": "%s_%s_%d" % [side, spec["frame"], idx], "name": fr["name"], "side": side,
		"durability": float(fr["durability"]), "max_durability": float(fr["durability"]),
		"armor": float(fr["armor"]), "speed": int(fr["speed"]), "handling": float(fr["handling"]),
		"ram": float(fr["ram"]), "mounts": int(fr["gun_mounts"]), "guns": guns.slice(0, int(fr["gun_mounts"])),
		"crew": int(spec["crew"]), "crew_arms": float(crew_t["arms"]), "crew_training": float(crew_t["training"]),
		"crew_tags": crew_t.get("tags", []), "crew_fight": int(crew_t["fight"]), "crew_gunnery": int(crew_t.get("gunnery", 0)),
		"rider_weapon": crew_t.get("rider_weapon", ""),
		"character": ch, "flagship": spec.get("flagship", false) or spec.has("leader"),
		"lane": idx % lanes, "x": x, "status": "active", "ammo": AMMO_SHOTS,
		"evade": false, "hooked": 0, "burning": 0, "gun_hit": 0.0, "driving": 0,
		"charge_armor": 0.0, "charge_ram_pct": 0.0,
	}
	if not ch.is_empty():
		# A named character drives if they can, otherwise mans the guns.
		rig["driving"] = int(ch["skills"].get("driving", 0))
		var cls_abilities: Array = _class_abilities(ch)
		for ab in cls_abilities:
			var r: Dictionary = ab.get("rig", {})
			rig["handling"] += float(r.get("handling", 0))
			rig["gun_hit"] += float(r.get("gun_hit", 0))
			rig["armor"] += float(r.get("armor", 0))
			rig["durability"] += float(r.get("durability", 0))
			rig["max_durability"] += float(r.get("durability", 0))
			rig["charge_armor"] += float(r.get("charge_armor", 0))
			rig["charge_ram_pct"] += float(r.get("charge_ram_pct", 0))
	rig["handling"] += rig["driving"] * 10.0
	return rig


## Unlocked abilities with road-war effects (the built combatant keeps only battle ones).
func _class_abilities(ch: Dictionary) -> Array:
	var out: Array = []
	for cls in data.classes["classes"]:
		if cls["id"] != ch["class"]:
			continue
		for ab in cls["abilities"]:
			var lvl := int(ch["road"]) if ab["track"] == "road" else int(ch["fight"])
			if ab.has("rig") and lvl >= int(ab["level"]):
				out.append(ab)
	return out


# ---------------------------------------------------------------- running

func run(max_rounds: int = 30) -> Dictionary:
	while round_n < max_rounds and _outcome() == "":
		for r in start_round():
			if r["status"] != "active" or _outcome() != "":
				continue
			_turn(r)
		end_round()
	return finish()


# ---------------------------------------------------------------- stepping (for the playable scene)

## Starts a round. Returns the rigs in turn order (fastest and best-handling first).
func start_round() -> Array:
	round_n += 1
	var order: Array = _active()
	order.sort_custom(func(a, b): return a["speed"] * 10 + a["handling"] / 10.0 > b["speed"] * 10 + b["handling"] / 10.0)
	return order


## End of a round: fires burn, hooks slip, evasion ends, and a beaten convoy may break off.
func end_round() -> void:
	for r in _active():
		if r["burning"] > 0:
			r["burning"] -= 1
			_damage(r, 10.0, "fire")
		if r["hooked"] > 0:
			r["hooked"] -= 1
		r["evade"] = false
	_check_rout()


func outcome() -> String:
	return _outcome()


## The AI's turn for a rig (also the "Auto" button for a party rig).
func ai_turn(r: Dictionary) -> void:
	_turn(r)


## Drive: up to Speed cells along the road (dx, + is forward) and one lane change.
func player_drive(r: Dictionary, dx: int, dlane: int) -> void:
	var dx_c: int = clampi(dx, -r["speed"], r["speed"])
	_drive(r, r["x"] + dx_c, clampi(r["lane"] + dlane, 0, lanes - 1))


## Fire every manned gun, at `target` if it's in a gun's bands, else at the best target in range.
func player_fire(r: Dictionary, target: Dictionary = {}) -> void:
	var foes: Array = _active("enemy" if r["side"] == "party" else "party")
	_fire(r, [target] if not target.is_empty() and target["status"] == "active" else foes)
	lines.append("%s fires." % r["name"])


func can_contact(r: Dictionary, t: Dictionary) -> bool:
	return t["status"] == "active" and _gap(r, t) <= BAND_CONTACT and t["lane"] == r["lane"]


func player_ram(r: Dictionary, t: Dictionary) -> bool:
	if not can_contact(r, t):
		return false
	_ram(r, t)
	lines.append("%s rams %s." % [r["name"], t["name"]])
	return true


func player_board(r: Dictionary, t: Dictionary) -> bool:
	if not can_contact(r, t) or r["crew"] < 2:
		return false
	lines.append("%s's crew boards %s." % [r["name"], t["name"]])
	_board(r, t)
	return true


func player_evade(r: Dictionary) -> void:
	r["evade"] = true
	lines.append("%s weaves and evades." % r["name"])


## The whole convoy runs: from now on the party's rigs drive away on their turns.
func player_run() -> void:
	party_mode = "flee"
	lines.append("The convoy runs for it.")


func boarding_odds(r: Dictionary, t: Dictionary) -> float:
	return _boarding_odds(r, t)


func gun_chance(r: Dictionary, t: Dictionary) -> float:
	var f: Dictionary = rules["fire"]
	var handling: float = t["handling"] + (float(rules["evade_handling"]) if t["evade"] else 0.0)
	return clampf(float(f["base"]) + _gun_accuracy(r) - handling, float(f["min"]), float(f["max"]))


func manned_guns(r: Dictionary) -> int:
	return _manned_guns(r)


func finish() -> Dictionary:
	var outcome := _outcome()
	var party: Array = rigs.filter(func(r): return r["side"] == "party")
	var dur := 0.0
	var dmax := 0.0
	for r in party:
		dmax += r["max_durability"]
		dur += max(0.0, r["durability"]) if r["status"] == "active" else 0.0
	result = {
		"winner": outcome if outcome != "" else "draw",
		"rounds": round_n,
		"party_durability_share": dur / max(dmax, 1.0),
		"party_rigs_lost": party.filter(func(r): return r["status"] in ["wrecked", "taken"]).size(),
		"enemy_rigs_taken": rigs.filter(func(r): return r["side"] == "enemy" and r["status"] == "taken").size(),
	}
	return result


func _active(side: String = "") -> Array:
	return rigs.filter(func(r): return r["status"] == "active" and (side == "" or r["side"] == side))


## "party" when every enemy rig is out (wrecked, taken, or fled out of range);
## "escaped" when the party has left them all behind; "enemy" when the party has no rig left.
func _outcome() -> String:
	var p := _active("party")
	var e := _active("enemy")
	if p.is_empty():
		return "enemy"
	if e.is_empty():
		return "party"
	if party_mode == "flee" and e.all(func(er): return p.all(func(pr): return abs(er["x"] - pr["x"]) > BAND_FAR)):
		return "escaped"
	return ""


func _check_rout() -> void:
	var enemies: Array = rigs.filter(func(r): return r["side"] == "enemy")
	var out := enemies.filter(func(r): return r["status"] != "active").size()
	var flag_out := enemies.any(func(r): return r["flagship"] and r["status"] != "active")
	var has_flag := enemies.any(func(r): return r["flagship"])
	if out * 3 >= enemies.size() * 2 or (has_flag and flag_out and out * 2 >= enemies.size()):
		for r in _active("enemy"):
			r["status"] = "gone"
			lines.append("%s breaks off." % r["name"])


static func band(gap: int) -> String:
	if gap <= BAND_CONTACT:
		return "contact"
	if gap <= BAND_CLOSE:
		return "close"
	if gap <= BAND_FAR:
		return "far"
	return "gone"


func _gap(a: Dictionary, b: Dictionary) -> int:
	return abs(int(a["x"]) - int(b["x"]))


# ---------------------------------------------------------------- one rig's turn

func _turn(r: Dictionary) -> void:
	var foes: Array = _active("enemy" if r["side"] == "party" else "party")
	if foes.is_empty():
		return
	var target := _pick_target(r, foes)
	if r["side"] == "party" and party_mode == "fight" and _strength("party") < _strength("enemy") * FLEE_BELOW:
		party_mode = "flee"
		lines.append("The convoy runs for it.")
	if r["side"] == "party" and party_mode == "flee":
		_drive(r, r["x"] + r["speed"], r["lane"])
		_fire(r, foes)
		return
	# Contact: board if it would win, else ram if it hits hard, else keep shooting.
	if _gap(r, target) <= BAND_CONTACT and target["lane"] == r["lane"]:
		if (_boarding_odds(r, target) > 1.2 or _duel_favoured(r, target)) and not _duel_favoured(target, r):
			_board(r, target)
			return
		if r["ram"] >= 20.0 and r["durability"] > r["max_durability"] * 0.4:
			_ram(r, target)
			_fire(r, foes)
			return
	# Enemies close to contact to board or ram; the party holds at close range and shoots.
	var closing: bool = _boarding_odds(r, target) > 1.2 or (_duel_favoured(r, target) and _boarding_odds(r, target) > 0.5)
	if r["side"] == "enemy":
		closing = closing or r["ram"] >= 20.0 or r["crew"] >= 4
	if _duel_favoured(target, r):
		closing = false   # don't come alongside a leader who'd win the duel
	var want_gap := 0 if closing else 2
	var dir := 1 if target["x"] > r["x"] else -1
	var goal_x: int = target["x"] - dir * want_gap
	# A small crew keeps out of reach of the nearest enemy that could board it.
	if not closing:
		var threats: Array = foes.filter(func(f): return _boarding_odds(f, r) > 1.0 and not _duel_favoured(r, f))
		if not threats.is_empty():
			threats.sort_custom(func(a, b): return _gap(r, a) < _gap(r, b))
			var th: Dictionary = threats[0]
			var tdir := 1 if th["x"] > r["x"] else -1
			goal_x = th["x"] - tdir * 3
	if target["hooked"] > 0 and r["side"] == target["side"]:
		goal_x = r["x"]
	_drive(r, goal_x, target["lane"])
	_fire(r, foes)


## Rough fighting strength of a side: Durability x (1 + manned guns), summed.
func _strength(side: String) -> float:
	var t := 0.0
	for r in _active(side):
		t += r["durability"] * (1.0 + _manned_guns(r))
	return t


func _pick_target(r: Dictionary, foes: Array) -> Dictionary:
	var best: Dictionary = foes[0]
	var best_s := -INF
	for f in foes:
		var s = -float(_gap(r, f)) * 3.0 - f["durability"] / max(f["max_durability"], 1.0) * 20.0
		if f["flagship"]:
			s += 10.0
		if s > best_s:
			best = f
			best_s = s
	return best


## Move toward (goal_x, lane): one lane change costs one point of Speed. Hooked rigs can't pull away.
func _drive(r: Dictionary, goal_x: int, lane: int) -> void:
	var pts: int = r["speed"]
	if r["hooked"] > 0:
		pts = 1
	if lane != r["lane"] and pts > 0:
		var nl: int = r["lane"] + (1 if lane > r["lane"] else -1)
		if _free(nl, r["x"], r):
			r["lane"] = nl
			pts -= 1
	while pts > 0 and r["x"] != goal_x:
		var nx: int = r["x"] + (1 if goal_x > r["x"] else -1)
		if not _free(r["lane"], nx, r):
			# Blocked: sidestep into a neighbouring lane that's clear ahead, if there is one.
			var moved := false
			for dl in [1, -1]:
				var l2: int = r["lane"] + dl
				if pts >= 2 and _free(l2, r["x"], r) and _free(l2, nx, r):
					r["lane"] = l2
					pts -= 1
					moved = true
					break
			if not moved:
				break
			continue
		r["x"] = nx
		pts -= 1
		var ob: String = obstacles.get(Vector2i(r["lane"], nx), "")
		if ob != "":
			var diff := float(data.characters["checks"]["difficulty"][rules["obstacle_check_difficulty"][ob]])
			var chance := clampf(50.0 + r["handling"] - diff, 5.0, 95.0)
			if rng.randf() * 100.0 >= chance:
				_damage(r, 15.0, ob)


func _free(lane: int, x: int, me: Dictionary) -> bool:
	if lane < 0 or lane >= lanes:
		return false
	for o in rigs:
		if o != me and o["status"] == "active" and o["lane"] == lane and o["x"] == x:
			return false
	return true


func _gun_accuracy(r: Dictionary) -> float:
	var acc = float(r["crew_fight"]) + r["crew_gunnery"] * 10.0
	var ch: Dictionary = r["character"]
	if not ch.is_empty() and r["driving"] == 0:
		acc = max(acc, float(ch["attributes"]["cool"]) * 0.5 + int(ch["skills"].get("gunnery", 0)) * 10.0 + ch["fight"])
	return acc + r["gun_hit"]


## Each gun needs 2 crew; on a small rig the driver works a gun too.
func _manned_guns(r: Dictionary) -> int:
	return min(r["guns"].size(), max(0, r["crew"] / 2))


func _fire(r: Dictionary, foes: Array) -> void:
	var f: Dictionary = rules["fire"]
	var shooters: Array = r["guns"].slice(0, _manned_guns(r))
	if shooters.is_empty() and r["rider_weapon"] != "":
		var w: Dictionary = Characters.weapon(data, r["rider_weapon"])
		shooters = [{"power": float(w["attack"]) * 0.5, "bands": ["contact", "close"], "ammo": 1, "tags": [], "attacks": max(1, r["crew"] - 1)}]
	for g in shooters:
		var targets: Array = foes.filter(func(t): return t["status"] == "active" and g["bands"].has(band(_gap(r, t))))
		if targets.is_empty():
			continue
		var t := _pick_target(r, targets)
		for k in int(g.get("attacks", 1)):
			if r["ammo"] < int(g["ammo"]) or t["status"] != "active":
				break
			r["ammo"] -= int(g["ammo"])
			var handling: float = t["handling"] + (float(rules["evade_handling"]) if t["evade"] else 0.0)
			var chance := clampf(float(f["base"]) + _gun_accuracy(r) - handling, float(f["min"]), float(f["max"]))
			if rng.randf() * 100.0 >= chance:
				continue
			var armor: float = t["armor"] * (0.5 if g["tags"].has("armour_piercing") else 1.0)
			_damage(t, max(1.0, float(g["power"]) - armor), g.get("name", "riders"))
			if g["tags"].has("burning"):
				t["burning"] = 3
			if g["tags"].has("hook"):
				t["hooked"] = 1


func _damage(r: Dictionary, amount: float, source: String) -> void:
	if r["status"] != "active":
		return
	r["durability"] -= amount
	if r["durability"] <= 0.0:
		r["durability"] = 0.0
		r["status"] = "wrecked"
		lines.append("%s (%s) is wrecked by %s." % [r["name"], r["side"], source])


## Ram: Ram x (1 + speed difference / 4) - Armor; the rammer takes half (rules/battle.json).
func _ram(r: Dictionary, t: Dictionary) -> void:
	var diff: float = max(0, r["speed"] - t["speed"])
	var power: float = r["ram"] * (1.0 + diff / 4.0) * (1.0 + r["charge_ram_pct"] / 100.0)
	_damage(t, max(1.0, power - t["armor"]), r["name"] + "'s ram")
	_damage(r, max(0.0, power * float(rules["ram"]["self_damage_share"]) - r["armor"] - r["charge_armor"]), "ramming")


func _gang(r: Dictionary, troops: float) -> Dictionary:
	return {"troops": troops, "arms": r["crew_arms"], "training": r["crew_training"], "tags": r["crew_tags"]}


## Boarding strength = crew x (1 + Fight level x 0.05) x (1 + arms/100).
func _board_strength(r: Dictionary, troops: float) -> float:
	return troops * (1.0 + r["crew_fight"] * 0.05) * (1.0 + r["crew_arms"] / 100.0) * (1.0 + r["crew_training"] / 100.0)


func _boarding_odds(r: Dictionary, t: Dictionary) -> float:
	var lw := 1.0 + (int(t["character"]["fight"]) * 0.02 if not t["character"].is_empty() else 0.0)
	return _board_strength(r, r["crew"] - 1) / max(_board_strength(t, t["crew"]) * lw, 0.1)


## A leader duel (UWNH's duel) is on when both rigs carry a leader and ours looks the stronger.
func _duel_favoured(r: Dictionary, t: Dictionary) -> bool:
	var a_ch: Dictionary = r["character"]
	var d_ch: Dictionary = t["character"]
	return not a_ch.is_empty() and not d_ch.is_empty() and _power(a_ch) > _power(d_ch) * DUEL_EDGE


func _board(r: Dictionary, t: Dictionary) -> void:
	var boarders := float(r["crew"] - 1)
	var a_ch: Dictionary = r["character"]
	var d_ch: Dictionary = t["character"]
	# Either leader can call the duel: whoever looks the stronger does.
	if _duel_favoured(r, t) or _duel_favoured(t, r):
		var duel := Skirmish.new()
		var a := a_ch.duplicate(true)
		var d := d_ch.duplicate(true)
		a["side"] = "party"
		d["side"] = "enemy"
		duel.setup(data, [a], [d], rng, 2)
		var res := duel.run(20)
		var a_won: bool = res["winner"] == "party"
		lines.append("Leader duel on %s: %s wins." % [t["name"], a_ch["name"] if a_won else d_ch["name"]])
		if a_won:
			_take(r, t)
		else:
			r["crew"] = max(1, r["crew"] - int(boarders / 2))
		return
	# A leader aboard fights alongside the crew (war.json leader modifiers).
	var lw: Dictionary = data.war["leader"]
	var att_lead: float = 1.0 + (int(a_ch["fight"]) * float(lw["player_per_fight_level"]) if not a_ch.is_empty() else 0.0)
	var def_lead: float = 1.0 + (int(d_ch["fight"]) * float(lw["player_per_fight_level"]) if not d_ch.is_empty() else 0.0)
	var res := GangWar.resolve(_gang(r, boarders), _gang(t, float(t["crew"])), 0, data.war, rng, att_lead, def_lead)
	if res["attacker_won"]:
		r["crew"] = 1 + int(round(res["att_troops"]))
		_take(r, t)
	else:
		r["crew"] = 1 + int(round(res["att_troops"]))
		t["crew"] = int(round(res["def_troops"]))
		lines.append("Boarders thrown off %s." % t["name"])
		if t["crew"] <= 0:
			t["status"] = "wrecked"


func _take(r: Dictionary, t: Dictionary) -> void:
	t["status"] = "taken"
	lines.append("%s (%s) is taken by boarders." % [t["name"], t["side"]])


static func _power(ch: Dictionary) -> float:
	return ch["max_hp"] * Characters.attack_value(ch)
