## Gang war: Inindo's province war (rules/war.json, docs/design/09-combat.md).
## A gang is {troops, arms, training, tags}. Resolution mutates neither input; it returns
## the survivors and who won.
extends RefCounted


static func effective(gang: Dictionary, rules: Dictionary) -> Dictionary:
	var arms := float(gang["arms"])
	var training := float(gang["training"])
	var breaks_below := float(rules["morale"]["breaks_below"])
	var no_morale := false
	var vs_walls := 1.0
	var attacks := true
	for t in gang.get("tags", []):
		var tag: Dictionary = rules["tags"].get(t, {})
		arms += float(tag.get("arms", 0))
		training += float(tag.get("training", 0))
		if tag.has("breaks_below"):
			breaks_below = float(tag["breaks_below"])
		if tag.get("no_morale", false):
			no_morale = true
		vs_walls = max(vs_walls, float(tag.get("vs_walls", 1.0)))
		if tag.get("attacks", true) == false:
			attacks = false
	return {"arms": clampf(arms, 0, 100), "training": clampf(training, 0, 100),
		"breaks_below": breaks_below, "no_morale": no_morale, "vs_walls": vs_walls, "attacks": attacks}


static func strength(troops: float, eff: Dictionary, leader: float, walls_mult: float) -> float:
	return troops * (1.0 + eff["arms"] / 100.0) * (1.0 + eff["training"] / 100.0) * leader * walls_mult


## att/def: gangs. walls: the defender's walls (0-2). Leaders are multipliers (1.0 = present).
## Returns {attacker_won, att_troops, def_troops, rounds, log}.
static func resolve(att: Dictionary, def: Dictionary, walls: int, rules: Dictionary, rng: RandomNumberGenerator,
		att_leader: float = 1.0, def_leader: float = 1.0) -> Dictionary:
	var ea := effective(att, rules)
	var ed := effective(def, rules)
	var wm: float = rules["walls_defender_multiplier"][clampi(walls, 0, 2)]
	var att_wall_bonus: float = ea["vs_walls"] if walls > 0 else 1.0
	var at := float(att["troops"])
	var dt := float(def["troops"])
	var am := float(rules["morale"]["start"])
	var dm := float(rules["morale"]["start"])
	var rounds := int(rules["rounds_max"])
	var r := 0
	var att_broke := false
	var def_broke := false
	while r < rounds:
		r += 1
		var sa := strength(at, ea, att_leader, att_wall_bonus)
		var sd := strength(dt, ed, def_leader, wm)
		var loss_d: float = min(dt, sa * 0.08 * rng.randf_range(0.8, 1.2))
		var loss_a: float = min(at, sd * 0.08 * rng.randf_range(0.8, 1.2))
		if dt > 0.0 and not ed["no_morale"]:
			dm -= loss_d / dt * 120.0
		if at > 0.0 and not ea["no_morale"]:
			am -= loss_a / at * 120.0
		dt -= loss_d
		at -= loss_a
		def_broke = dt <= 0.5 or (not ed["no_morale"] and dm < ed["breaks_below"])
		att_broke = at <= 0.5 or (not ea["no_morale"] and am < ea["breaks_below"])
		if def_broke or att_broke:
			break
	# The attacker must break the defender (and not break first in the same round) to take the hold.
	var won := def_broke and not (att_broke and at <= dt)
	return {"attacker_won": won, "att_troops": max(at, 0.0), "def_troops": max(dt, 0.0), "rounds": r}
