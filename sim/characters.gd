## Character formulas (docs/design/04-characters.md, rules/characters.json) and the builder
## that turns a class at given levels, or an enemy unit, into a battle-ready combatant.
extends RefCounted

const ATTRS := ["cool", "hard", "hot", "sharp", "weird"]


## Success chance (%) of a check: clamp(base + (attribute - difficulty) + rank*10 + mods, min, max).
static func check_chance(rules: Dictionary, attribute: float, difficulty: String, skill_rank: int = 0, mods: float = 0.0) -> int:
	var c: Dictionary = rules["checks"]
	var d := float(c["difficulty"][difficulty])
	var v := float(c["base"]) + (attribute - d) + skill_rank * 10.0 + mods
	return int(clampf(v, float(c["min"]), float(c["max"])))


## XP needed to go from `level` to the next: round(100 * level^1.5).
static func xp_to_next(level: int) -> int:
	return roundi(100.0 * pow(level, 1.5))


static func health(hard: float, fight_level: int) -> float:
	return 40.0 + hard * 0.6 + fight_level * 6.0


static func grit(weird: float, road_level: int, fight_level: int) -> float:
	return 10.0 + weird * 0.4 + road_level + fight_level


## Hum exposure gained, reduced by Weird: gain * (1 - weird/200).
static func hum_gain(gain: float, weird: float) -> float:
	return gain * (1.0 - weird / 200.0)


## Attributes after level-ups: each level gained in a track gives 4 points, split half by the
## track's weights and half by the class's growth. Capped at 100. Locked attributes don't grow.
static func grown_attributes(data, cls: Dictionary, levels: Dictionary) -> Dictionary:
	var lv: Dictionary = data.characters["levels"]
	var per := float(lv["attribute_points_per_level"])
	var out: Dictionary = cls["attributes"].duplicate()
	var locked: Array = ["weird"] if cls.has("weird_locked_until") else []
	for track in lv["tracks"]:
		var gained := int(levels.get(track, 1)) - 1
		if gained <= 0:
			continue
		var tw: Dictionary = lv["track_attribute_weights"][track]
		for a in ATTRS:
			if locked.has(a):
				continue
			var share := 0.5 * float(tw.get(a, 0.0)) + 0.5 * float(cls["growth"].get(a, 0.0))
			out[a] = min(100.0, float(out[a]) + per * gained * share)
	return out


static func _find(list: Array, id: String) -> Dictionary:
	for x in list:
		if x["id"] == id:
			return x
	assert(false, "unknown id: " + id)
	return {}


static func weapon(data, id: String) -> Dictionary:
	return _find(data.equipment["weapons"], id)


static func armour(data, id: String) -> Dictionary:
	return _find(data.equipment["armour"], id)


## A protagonist or companion of class `class_id` at the given track levels.
static func build_class(data, class_id: String, levels: Dictionary, side: String, rng: RandomNumberGenerator, name: String = "") -> Dictionary:
	var cls: Dictionary = _find(data.classes["classes"], class_id)
	var abilities: Array = []
	for ab in cls["abilities"]:
		if int(levels.get(ab["track"], 1)) >= int(ab["level"]):
			abilities.append(ab)
	var c := _combatant(data, {
		"id": class_id, "name": name if name != "" else cls["name"], "side": side, "class": class_id,
		"attributes": grown_attributes(data, cls, levels), "skills": cls["skills"].duplicate(),
		"weapon": cls["weapon"], "armour": cls["armour"], "luck": cls["luck"],
		"fight": int(levels.get("fight", 1)), "road": int(levels.get("road", 1)),
		"tags": ["protagonist"] if cls["protagonist"] else ["companion"],
		"abilities": abilities, "disciplines": cls.get("disciplines", []),
	}, rng)
	return c


## An enemy from data/units/units.json.
static func build_unit(data, unit_id: String, side: String, rng: RandomNumberGenerator, n: int = 0) -> Dictionary:
	var u: Dictionary = _find(data.units["units"], unit_id)
	return _combatant(data, {
		"id": "%s_%d" % [unit_id, n], "name": u["name"], "side": side, "class": unit_id,
		"attributes": u["attributes"].duplicate(), "skills": u["skills"].duplicate(),
		"weapon": u["weapon"], "armour": u["armour"], "luck": u["luck"],
		"fight": int(u["level"]), "road": int(u["level"]), "tags": u["tags"].duplicate(),
		"abilities": [], "disciplines": u.get("disciplines", []),
	}, rng)


static func _combatant(data, b: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var a: Dictionary = b["attributes"]
	var f: int = b["fight"]
	var r: int = b["road"]
	var wpn: Dictionary = weapon(data, b["weapon"])
	var arm: Dictionary = armour(data, b["armour"])
	var mods := {}
	for ab in b["abilities"]:
		for k in ab.get("mods", {}):
			mods[k] = float(mods.get(k, 0.0)) + float(ab["mods"][k])
	var tags: Array = b["tags"]
	var opened: bool = tags.has("opened")
	var max_hp := health(float(a["hard"]), f) + float(mods.get("health", 0.0))
	if opened:
		max_hp *= float(data.battle["the_choir"]["opened"]["hp_mult"])
	var spd := 20.0 + float(a["cool"]) * 0.4 + float(a["sharp"]) * 0.2 - float(arm.get("encumbrance", 0)) + float(mods.get("speed", 0.0))
	var techniques: Array = []
	for did in b["disciplines"]:
		for t in _find(data.disciplines["disciplines"], did)["techniques"]:
			if float(a["weird"]) >= float(t["needs_weird"]) and t["target"] != "map":
				techniques.append(t)
	var battle_abilities: Array = []
	for ab in b["abilities"]:
		if ab.has("battle"):
			battle_abilities.append(ab)
	return {
		"id": b["id"], "name": b["name"], "side": b["side"], "class": b["class"], "tags": tags,
		"attributes": a, "skills": b["skills"], "fight": f, "road": r,
		"weapon": wpn, "armour": arm,
		"ammo": int(data.battle["skirmish"]["ammo_attacks"]) * int(wpn["ammo"]),   # enough for N attacks
		"max_hp": max_hp, "hp": max_hp,
		"max_grit": grit(float(a["weird"]), r, f), "grit": grit(float(a["weird"]), r, f),
		"speed": spd,
		"defense": float(arm["defense"]) + float(a["cool"]) * 0.2 + f + float(mods.get("defense", 0.0)),
		"defense_vs_hum": float(mods.get("defense_vs_hum", 0.0)),
		"luck": float(b["luck"]) + rng.randi_range(1, 20),
		"crit_mult": float(mods.get("crit_mult", 1.0)),
		"grit_cost_mult": 1.0 + float(mods.get("grit_cost_pct", 0.0)) / 100.0,
		"acc_melee_mod": float(mods.get("accuracy_melee", 0.0)),
		"acc_ranged_mod": float(mods.get("accuracy_ranged", 0.0)),
		"abilities": battle_abilities, "techniques": techniques,
		"hum_exposure": 0.0, "loyalty": 70.0,
		"statuses": {}, "buffs": [], "down": false, "fled": false, "pos": Vector2i.ZERO,
		"defending": false, "needs_reload": false, "used_once": {},
	}


## Attack value of a combatant's current weapon (docs/design/04-characters.md derived stats).
static func attack_value(c: Dictionary) -> float:
	var w: Dictionary = c["weapon"]
	var a: Dictionary = c["attributes"]
	var base = float(w["attack"]) + c["fight"]
	if w["range"] == "melee":
		return base + float(a["hard"]) * 0.3
	return base + float(a["cool"]) * 0.3


static func accuracy_value(c: Dictionary) -> float:
	var w: Dictionary = c["weapon"]
	var a: Dictionary = c["attributes"]
	if w["tags"].has("hum"):
		return float(a["weird"]) * 0.5 + c["fight"]
	if w["range"] == "melee":
		return float(a["hard"]) * 0.5 + int(c["skills"].get("brawling", 0)) * 10 + c["fight"] + c["acc_melee_mod"]
	return float(a["cool"]) * 0.5 + int(c["skills"].get("gunnery", 0)) * 10 + c["fight"] + c["acc_ranged_mod"]
