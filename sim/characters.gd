## Character formulas (docs/design/04-characters.md, rules/characters.json).
## M1 uses only the check and XP maths; the full sheet arrives with M2's battles.
extends RefCounted


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
