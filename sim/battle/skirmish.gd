## Skirmish: Inindo's grid battle (docs/design/09-combat.md, rules/battle.json "skirmish").
## Pure simulation: no Nodes. Both sides are driven by a simple tactical AI, so the same
## code runs auto-resolved battles, the balance bench, and (later) the enemy side of a
## player-controlled battle.
extends RefCounted

const Characters := preload("res://sim/characters.gd")

var data
var rules: Dictionary
var rng: RandomNumberGenerator
var units: Array = []            # every combatant, both sides
var cover: Dictionary = {}       # Vector2i -> true
var size := Vector2i(16, 10)
var round_n := 0
var lines: Array = []            # one line per notable event
var result := {}
var party_fled := false


func setup(sim_data, party: Array, enemies: Array, random: RandomNumberGenerator, cover_tiles: int = 10) -> void:
	data = sim_data
	rules = data.battle["skirmish"]
	rng = random
	size = Vector2i(int(rules["grid"][0]), int(rules["grid"][1]))
	units = party + enemies
	_place(party, true)
	_place(enemies, false)
	var placed := 0
	var tries := 0
	while placed < cover_tiles and tries < 500:
		tries += 1
		var t := Vector2i(rng.randi_range(5, size.x - 6), rng.randi_range(0, size.y - 1))
		if not cover.has(t) and _unit_at(t).is_empty():
			cover[t] = true
			placed += 1


## Lineup: melee in front, ranged at the back, rows spread from the middle.
func _place(side: Array, player_side: bool) -> void:
	var lu: Dictionary = rules["lineup"]
	var rows := [4, 5, 3, 6, 2, 7, 1, 8, 0, 9]
	var used := {}
	for i in side.size():
		var c: Dictionary = side[i]
		var melee: bool = c["weapon"]["range"] == "melee"
		var col: int
		if player_side:
			col = int(lu["front_col"]) if melee else int(lu["back_col"])
		else:
			col = int(lu["enemy_front_col"]) if melee else int(lu["enemy_back_col"])
		for r in rows:
			var p := Vector2i(col, r)
			if not used.has(p):
				c["pos"] = p
				used[p] = true
				break


# ---------------------------------------------------------------- running

## Runs to the end (or max_rounds) with the AI on both sides. Returns the result dictionary.
func run(max_rounds: int = 30) -> Dictionary:
	while round_n < max_rounds and _winner() == "":
		for c in start_round():
			if c["down"] or c["fled"] or _winner() != "":
				continue
			_take_turn(c)
		end_round()
	return finish()


# ---------------------------------------------------------------- stepping (for the playable scene)

## Starts a round: Speed order, re-rolled +-10%. Returns the units in turn order.
func start_round() -> Array:
	round_n += 1
	var order: Array = _alive()
	var sr := float(rules["speed_reroll"])
	var keyed: Array = []
	for c in order:
		keyed.append([c["speed"] * rng.randf_range(1.0 - sr, 1.0 + sr), c])
	keyed.sort_custom(func(a, b): return a[0] > b[0])
	return keyed.map(func(k): return k[1])


func end_round() -> void:
	_check_rout()


func winner() -> String:
	return _winner()


## Start of a unit's turn: statuses, stuns, reloads and Hum-struck lashing out.
## Returns true if the unit may now act (by the AI or the player).
func begin_turn(c: Dictionary) -> bool:
	c["defending"] = false
	c["moved"] = false
	_tick_statuses(c)
	if c["down"]:
		return false
	if c["statuses"].has("stunned") or c["statuses"].has("petrified"):
		lines.append("%s can't act." % c["name"])
		return false
	_tick_buffs(c)
	var foes: Array = _alive("enemy" if c["side"] == "party" else "party")
	var friends: Array = _alive(c["side"])
	if foes.is_empty():
		return false
	if c["statuses"].has("hum_struck") and rng.randf() < 0.5:
		var victims: Array = friends.filter(func(x): return x != c and _dist(x["pos"], c["pos"]) <= 1)
		if not victims.is_empty():
			lines.append("%s is Hum-struck and lashes out." % c["name"])
			_attack(c, victims[0], 1.0)
			return false
	if c["needs_reload"]:
		c["needs_reload"] = false
		_step_toward_cover(c)
		lines.append("%s reloads." % c["name"])
		return false
	return true


## The AI's choice for a unit that may act (also the "Auto" button).
func ai_act(c: Dictionary) -> void:
	var foes: Array = _alive("enemy" if c["side"] == "party" else "party")
	var friends: Array = _alive(c["side"])
	if foes.is_empty():
		return
	if _try_support(c, friends):
		return
	if _try_technique(c, foes):
		return
	if c["ammo"] <= 0 and int(c["weapon"]["ammo"]) > 0:
		c["weapon"] = Characters.weapon(data, "fists")   # out of ammo: fight with what's left
	var target := _pick_target(c, foes)
	var rng_tiles := _range_tiles(c)
	if _dist(c["pos"], target["pos"]) > rng_tiles:
		_move_toward(c, target["pos"], rng_tiles)
	if _dist(c["pos"], target["pos"]) <= rng_tiles:
		_attack(c, target, 1.0)
	else:
		c["defending"] = true


## Tiles a unit can reach this turn (breadth-first over free tiles).
func reachable(c: Dictionary) -> Array:
	var steps := int(rules["move_tiles"]) + int(_buff(c, "move"))
	var seen := {c["pos"]: 0}
	var frontier: Array = [c["pos"]]
	while not frontier.is_empty():
		var p: Vector2i = frontier.pop_front()
		if seen[p] >= steps:
			continue
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if _in_bounds(q) and not seen.has(q) and _unit_at(q).is_empty():
				seen[q] = seen[p] + 1
				frontier.append(q)
	seen.erase(c["pos"])
	return seen.keys()


func player_move(c: Dictionary, tile: Vector2i) -> bool:
	if c["moved"] or not reachable(c).has(tile):
		return false
	c["pos"] = tile
	c["moved"] = true
	return true


func range_of(c: Dictionary) -> int:
	if c["ammo"] <= 0 and int(c["weapon"]["ammo"]) > 0:
		c["weapon"] = Characters.weapon(data, "fists")
	return _range_tiles(c)


func targets_for(c: Dictionary) -> Array:
	var r := range_of(c)
	return _alive("enemy" if c["side"] == "party" else "party").filter(func(t): return _dist(c["pos"], t["pos"]) <= r)


func hit_chance(c: Dictionary, t: Dictionary) -> float:
	var shots := 3 if c["weapon"]["tags"].has("autofire") and c["ammo"] >= 3 else 1
	return _hit_chance(c, t, -15.0 if shots == 3 else 0.0)


func player_attack(c: Dictionary, t: Dictionary) -> bool:
	if not targets_for(c).has(t):
		return false
	var hp_before: float = t["hp"]
	_attack(c, t, 1.0)
	lines.append("%s attacks %s: %s." % [c["name"], t["name"], ("%d damage" % roundi(hp_before - t["hp"])) if t["hp"] < hp_before else "miss"])
	return true


func player_defend(c: Dictionary) -> void:
	c["defending"] = true
	lines.append("%s defends." % c["name"])


## Battle actions a unit has right now: class abilities (heal, revive) and discipline techniques.
func skills_for(c: Dictionary) -> Array:
	var out: Array = []
	for ab in c["abilities"]:
		var b: Dictionary = ab["battle"]
		if b.has("action") and b["action"] in ["heal", "revive"] and c["grit"] >= float(b.get("grit", 0)) * c["grit_cost_mult"]:
			out.append({"kind": "ability", "name": ab["name"], "def": ab, "grit": float(b.get("grit", 0))})
	for t in c["techniques"]:
		if c["grit"] >= float(t["grit"]) * c["grit_cost_mult"] and t["target"] != "map":
			out.append({"kind": "technique", "name": t["name"], "def": t, "grit": float(t["grit"])})
	return out


## Use a skill. Heals and revives pick the neediest ally; attacks need a target in reach.
func player_skill(c: Dictionary, skill: Dictionary, target: Dictionary = {}) -> bool:
	var friends: Array = _alive(c["side"])
	if skill["kind"] == "ability" or skill["def"]["target"] in ["ally", "downed_ally"]:
		return _try_support(c, friends)
	var foes: Array = _alive("enemy" if c["side"] == "party" else "party")
	if target.is_empty():
		target = _pick_target(c, foes)
	var t: Dictionary = skill["def"]
	if t["target"] != "self" and _dist(c["pos"], target["pos"]) > 6:
		return false
	c["grit"] -= float(t["grit"]) * c["grit_cost_mult"]
	if t.has("buff"):
		(c if t["target"] == "self" else target)["buffs"].append(t["buff"].duplicate())
	var victims: Array = [target] if t["target"] != "self" else []
	if t["target"] == "enemy_area":
		victims = foes.filter(func(f): return _dist(f["pos"], target["pos"]) <= 1)
	for v in victims:
		if t.has("damage"):
			_hurt(v, float(t["damage"]), t["name"])
		if t.has("hum_damage"):
			_hurt(v, float(t["hum_damage"]), t["name"])
		if t.has("status") and not v["down"]:
			v["statuses"][t["status"]["id"]] = int(t["status"]["turns"])
	lines.append("%s uses %s." % [c["name"], t["name"]])
	return true


## The party tries to flee: one roll for everyone. Success ends the battle.
func player_flee() -> bool:
	var ok := rng.randf() * 100.0 < flee_chance()
	if ok:
		for c in _alive("party"):
			c["fled"] = true
		party_fled = true
		lines.append("The party gets away.")
	else:
		lines.append("The party tries to run, and can't.")
	return ok


func finish() -> Dictionary:
	var w := "fled" if party_fled else _winner()
	var party: Array = units.filter(func(c): return c["side"] == "party")
	var hp_max := 0.0
	var hp_now := 0.0
	for c in party:
		hp_max += c["max_hp"]
		hp_now += max(c["hp"], 0.0)
	var xp := 0
	for c in units:
		if c["side"] == "enemy" and (c["down"] or c["fled"]):
			xp += int(rules["xp"]["fight_per_enemy_level"]) * int(c["fight"])
	result = {
		"winner": w if w != "" else "draw",
		"rounds": round_n,
		"party_hp_share": hp_now / max(hp_max, 1.0),
		"party_down": party.filter(func(c): return c["down"]).size(),
		"xp": xp if w == "party" else 0,
	}
	return result


func _alive(side: String = "") -> Array:
	return units.filter(func(c): return not c["down"] and not c["fled"] and (side == "" or c["side"] == side))


func _winner() -> String:
	if _alive("enemy").is_empty():
		return "party"
	if _alive("party").is_empty():
		return "enemy"
	return ""


func _check_rout() -> void:
	var rr: Dictionary = rules["rout"]
	var enemies: Array = units.filter(func(c): return c["side"] == "enemy")
	var standing: Array = _alive("enemy")
	if standing.is_empty():
		return
	var down_share := 1.0 - float(standing.size()) / enemies.size()
	var leader_down := enemies.any(func(c): return c["tags"].has("leader") and c["down"])
	var has_leader := enemies.any(func(c): return c["tags"].has("leader"))
	if down_share >= float(rr["share"]) or (has_leader and leader_down and down_share >= float(rr["leader_down_and_share"])):
		for c in standing:
			if not c["tags"].any(func(t): return rr["immune_tags"].has(t)):
				c["fled"] = true
				lines.append("%s flees." % c["name"])


# ---------------------------------------------------------------- a turn

func _take_turn(c: Dictionary) -> void:
	if begin_turn(c):
		ai_act(c)


func _tick_statuses(c: Dictionary) -> void:
	var st: Dictionary = c["statuses"]
	for id in st.keys():
		var def: Dictionary = rules["statuses"].get(id, {})
		if def.has("damage"):
			_hurt(c, float(def["damage"]), id)
		st[id] -= 1
		if st[id] <= 0:
			st.erase(id)


func _tick_buffs(c: Dictionary) -> void:
	var keep: Array = []
	for b in c["buffs"]:
		b["turns"] -= 1
		if b["turns"] > 0:
			keep.append(b)
	c["buffs"] = keep


func _buff(c: Dictionary, stat: String) -> float:
	var t := 0.0
	for b in c["buffs"]:
		t += float(b.get(stat, 0.0))
	return t


func _range_tiles(c: Dictionary) -> int:
	var r: String = c["weapon"]["range"]
	var tiles := int(rules["ranges"][r])
	if c["weapon"].has("max_tiles"):
		tiles = min(tiles, int(c["weapon"]["max_tiles"]))
	return tiles


static func _dist(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func _unit_at(p: Vector2i) -> Dictionary:
	for c in units:
		if not c["down"] and not c["fled"] and c["pos"] == p:
			return c
	return {}


func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y


## Greedy steps toward a point until within `stop_at` tiles of it; ranged units prefer cover.
func _move_toward(c: Dictionary, goal: Vector2i, stop_at: int) -> void:
	var steps := int(rules["move_tiles"]) + int(_buff(c, "move"))
	if c["statuses"].has("rescue_move"):
		steps += 2
	for i in max(steps, 0):
		if _dist(c["pos"], goal) <= stop_at:
			break
		var best: Vector2i = c["pos"]
		var best_d := _dist(c["pos"], goal)
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var p: Vector2i = c["pos"] + d
			if not _in_bounds(p) or not _unit_at(p).is_empty():
				continue
			var nd := _dist(p, goal)
			if nd < best_d or (nd == best_d and cover.has(p) and not cover.has(best)):
				best = p
				best_d = nd
		if best == c["pos"]:
			break
		c["pos"] = best


func _step_toward_cover(c: Dictionary) -> void:
	if cover.has(c["pos"]):
		return
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var p: Vector2i = c["pos"] + d
		if cover.has(p) and _in_bounds(p) and _unit_at(p).is_empty():
			c["pos"] = p
			return


## Prefer a target we can kill, then leaders and cantors, then the nearest.
func _pick_target(c: Dictionary, foes: Array) -> Dictionary:
	var best: Dictionary = foes[0]
	var best_score := -INF
	var atk := Characters.attack_value(c)
	for f in foes:
		var score := -float(_dist(c["pos"], f["pos"])) * 2.0
		if f["hp"] <= atk - f["defense"]:
			score += 40.0
		if f["tags"].has("cantor") or f["tags"].has("leader"):
			score += 15.0
		score -= f["hp"] / max(f["max_hp"], 1.0) * 10.0
		if score > best_score:
			best = f
			best_score = score
	return best


# ---------------------------------------------------------------- attacks

func _hit_chance(c: Dictionary, t: Dictionary, acc_mod: float) -> float:
	var h: Dictionary = rules["hit"]
	var evasion = t["speed"] * 0.5 + _buff(t, "evasion")
	var ranged: bool = c["weapon"]["range"] != "melee"
	if ranged and cover.has(t["pos"]):
		evasion += float(rules["cover_evasion_vs_ranged"])
	var acc := Characters.accuracy_value(c) + _buff(c, "accuracy") + acc_mod
	if c["statuses"].has("frightened"):
		acc += float(rules["statuses"]["frightened"]["accuracy"])
	if c["statuses"].has("jinxed"):
		acc -= 20.0
	if t["statuses"].has("marked"):
		acc += 15.0
	return clampf(float(h["base"]) + acc - evasion, float(h["min"]), float(h["max"]))


func _defense_of(t: Dictionary, armour_piercing: bool) -> float:
	if _buff(t, "defense_zero") > 0.0:
		return 0.0   # just used Release
	var d: float = t["defense"]
	var dd: Dictionary = rules["defend"]
	if t["defending"]:
		d *= float(dd["defense_mult"])
	elif units.any(func(x): return x != t and x["side"] == t["side"] and x["defending"] and not x["down"] and _dist(x["pos"], t["pos"]) <= 1):
		d *= float(dd["adjacent_ally_defense_mult"])
	return d * 0.5 if armour_piercing else d


## One weapon attack (or a volley for autofire). dmg_mult supports abilities like Release.
func _attack(c: Dictionary, t: Dictionary, dmg_mult: float) -> void:
	var w: Dictionary = c["weapon"]
	var tags: Array = w["tags"]
	var shots := 3 if tags.has("autofire") and c["ammo"] >= 3 else 1
	var acc_mod := -15.0 if shots == 3 else 0.0
	var release := _try_release(c)
	if release > 1.0:
		dmg_mult *= release
	for s in shots:
		if t["down"]:
			break
		if int(w["ammo"]) > 0:
			c["ammo"] -= 1
		if rng.randf() * 100.0 >= _hit_chance(c, t, acc_mod):
			continue
		if tags.has("hum"):
			_hum_hit(c, t)
			continue
		if tags.has("stun"):
			t["statuses"]["stunned"] = 1
			continue
		var crit = rng.randf() * 100.0 < c["luck"] / 4.0 * c["crit_mult"]
		var var_r: Array = rules["damage"]["variance"]
		var raw := (Characters.attack_value(c) + _buff(c, "attack")) * rng.randf_range(float(var_r[0]), float(var_r[1])) * dmg_mult
		var dmg: float = max(float(rules["damage"]["min"]), raw - _defense_of(t, tags.has("armour_piercing")))
		if crit:
			dmg *= float(rules["crit"]["multiplier"])
			if tags.has("messy"):
				t["statuses"]["bleeding"] = int(rules["statuses"]["bleeding"]["turns"])
		_hurt(t, dmg, c["name"])
		if tags.has("area"):
			for o in _alive(t["side"]):
				if o != t and _dist(o["pos"], t["pos"]) <= 1:
					_hurt(o, dmg * 0.5, c["name"])
	if tags.has("reload"):
		c["needs_reload"] = true
	if release > 1.0:
		c["buffs"].append({"defense_zero": 1, "turns": 1})


## The cantor's voice: Hum damage that ignores armour, drains Grit, and can turn the exposed.
func _hum_hit(c: Dictionary, t: Dictionary) -> void:
	var ch: Dictionary = data.battle["the_choir"]["cantor"]
	var dmg: float = max(1.0, float(ch["hum_damage_base"]) + float(c["attributes"]["weird"]) * float(ch["hum_damage_per_weird"]) - t["defense_vs_hum"])
	_hurt(t, dmg, c["name"])
	t["grit"] = max(0.0, t["grit"] - float(ch["grit_drain"]))
	var tc: Dictionary = ch["turn_check"]
	if t["hum_exposure"] >= float(tc["needs_hum_exposure"]) and rng.randf() * 100.0 >= t["loyalty"] - float(tc["loyalty_vs"]) + 50.0:
		t["statuses"]["hum_struck"] = int(rules["statuses"]["hum_struck"]["turns"])


func _hurt(t: Dictionary, dmg: float, source: String) -> void:
	if t["down"]:
		return
	t["hp"] -= dmg
	if t["hp"] <= 0.0:
		t["hp"] = 0.0
		t["down"] = true
		lines.append("%s is down (%s)." % [t["name"], source])


## Quarantine's Release: once per battle, double damage.
func _try_release(c: Dictionary) -> float:
	for ab in c["abilities"]:
		var b: Dictionary = ab["battle"]
		if b.get("action", "") == "release" and not c["used_once"].has("release"):
			c["used_once"]["release"] = true
			return float(b["damage_mult"])
	return 1.0


# ---------------------------------------------------------------- support and disciplines

## Heal or revive an ally with a class ability or a Mend technique.
func _try_support(c: Dictionary, friends: Array) -> bool:
	var downed: Array = units.filter(func(x): return x["side"] == c["side"] and x["down"] and not x["tags"].has("opened"))
	var hurt: Array = friends.filter(func(x): return x["hp"] < x["max_hp"] * 0.5)
	hurt.sort_custom(func(a, b): return a["hp"] / a["max_hp"] < b["hp"] / b["max_hp"])
	for ab in c["abilities"]:
		var b: Dictionary = ab["battle"]
		var cost = float(b.get("grit", 0)) * c["grit_cost_mult"]
		if c["grit"] < cost:
			continue
		if b.get("action", "") == "revive" and not downed.is_empty():
			var d: Dictionary = downed[0]
			if _reach(c, d["pos"], int(b["range"])):
				c["grit"] -= cost
				d["down"] = false
				d["hp"] = d["max_hp"] * float(b["hp_pct"]) / 100.0
				lines.append("%s brings %s back." % [c["name"], d["name"]])
				return true
		if b.get("action", "") == "heal" and not hurt.is_empty():
			var h: Dictionary = hurt[0]
			if _reach(c, h["pos"], int(b["range"])):
				c["grit"] -= cost
				var amount := 15.0 + int(c["skills"].get("medicine", 0)) * 5.0
				h["hp"] = min(h["max_hp"], h["hp"] + amount)
				return true
	for t in c["techniques"]:
		var cost = float(t["grit"]) * c["grit_cost_mult"]
		if c["grit"] < cost:
			continue
		if t["target"] == "downed_ally" and not downed.is_empty() and _reach(c, downed[0]["pos"], 4):
			c["grit"] -= cost
			downed[0]["down"] = false
			downed[0]["hp"] = downed[0]["max_hp"] * float(t["revive_pct"]) / 100.0
			return true
		if t["target"] == "ally" and t.has("heal") and not hurt.is_empty() and _reach(c, hurt[0]["pos"], 4):
			c["grit"] -= cost
			hurt[0]["hp"] = min(hurt[0]["max_hp"], hurt[0]["hp"] + float(t["heal"]))
			return true
	return false


## Move within `tiles` of a point if possible; true if then in reach.
func _reach(c: Dictionary, p: Vector2i, tiles: int) -> bool:
	if _dist(c["pos"], p) > tiles:
		_move_toward(c, p, tiles)
	return _dist(c["pos"], p) <= tiles


## Offensive or self-buff techniques: the strongest affordable one, about half the time.
func _try_technique(c: Dictionary, foes: Array) -> bool:
	if c["techniques"].is_empty() or rng.randf() < 0.5:
		return false
	var best: Dictionary = {}
	for t in c["techniques"]:
		if c["grit"] < float(t["grit"]) * c["grit_cost_mult"]:
			continue
		if t["target"] in ["enemy", "enemy_area", "self"] and (best.is_empty() or float(t["grit"]) > float(best["grit"])):
			best = t
	if best.is_empty():
		return false
	var target := _pick_target(c, foes)
	if best["target"] != "self" and _dist(c["pos"], target["pos"]) > 6:
		return false
	if best.get("only_tags", []).size() > 0 and not best["only_tags"].any(func(x): return target["tags"].has(x)):
		return false
	if best.get("immune_tags", []).any(func(x): return target["tags"].has(x)):
		return false
	c["grit"] -= float(best["grit"]) * c["grit_cost_mult"]
	if best.has("buff"):
		var b: Dictionary = best["buff"].duplicate()
		(c if best["target"] == "self" else target)["buffs"].append(b)
	var victims: Array = [target]
	if best["target"] == "enemy_area":
		victims = foes.filter(func(f): return _dist(f["pos"], target["pos"]) <= 1)
	for v in victims:
		if best.has("damage"):
			_hurt(v, float(best["damage"]), best["name"])
		if best.has("hum_damage"):
			_hurt(v, float(best["hum_damage"]), best["name"])
		if best.has("status") and not v["down"]:
			v["statuses"][best["status"]["id"]] = int(best["status"]["turns"])
		if best.get("drain", false):
			c["hp"] = min(c["max_hp"], c["hp"] + float(best.get("damage", 0)))
	if best.has("hum_exposure"):
		c["hum_exposure"] += float(best["hum_exposure"])
	return true


## Attempt to flee (the party): 50 + (party mean Speed - enemy mean Speed).
func flee_chance() -> float:
	var ps := _alive("party").map(func(c): return c["speed"])
	var es := _alive("enemy").map(func(c): return c["speed"])
	var mp := 0.0
	for s in ps:
		mp += s
	var me := 0.0
	for s in es:
		me += s
	mp /= max(ps.size(), 1)
	me /= max(es.size(), 1)
	return clampf(float(rules["flee"]["base"]) + mp - me, 5.0, 95.0)
