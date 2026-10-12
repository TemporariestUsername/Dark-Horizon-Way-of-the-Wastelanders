## Battle balance bench (M2): fights every encounter in data/units/units.json many times
## against a standard party at the encounter's level, and checks the win rate against
## rules/battle.json encounter_targets.
##
##   godot --headless --path . --script res://tools/battle_bench.gd -- [--fights 500] [--party driver,angel,gunlugger]
##
## Skirmishes use the encounters in data/units/units.json; road wars use its convoys against
## the standard party convoys there. Writes tools/out/battle_report.md; exits 1 if any
## encounter or convoy misses its target.
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const Characters := preload("res://sim/characters.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")
const RoadWar := preload("res://sim/battle/road_war.gd")

var fights := 500
var party_classes: PackedStringArray = ["driver", "angel", "gunlugger"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		match args[i]:
			"--fights": fights = int(args[i + 1])
			"--party": party_classes = args[i + 1].split(",")
	var data := SimData.new()
	data.load_all()
	var targets: Dictionary = data.battle["encounter_targets"]
	var md := PackedStringArray()
	md.append("# M2 battle bench")
	md.append("")
	md.append("## Skirmishes")
	md.append("")
	md.append("%d fights per encounter. Party: %s, all at the encounter's level (Fight and Road levels; Trade 1)." % [fights, ", ".join(party_classes)])
	md.append("")
	md.append("| Encounter | Rating | Party level | Party wins | Target | Rounds (median) | Party HP left (median) | Party members down (mean) | |")
	md.append("|---|---|---|---|---|---|---|---|---|")
	var all_ok := true
	for enc in data.units["encounters"]:
		var lvl := int(enc["party_level"])
		var wins := 0
		var rounds: Array = []
		var hp: Array = []
		var downs := 0.0
		for i in fights:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash("%s|%d" % [enc["id"], i])
			var party: Array = []
			for c in party_classes:
				party.append(Characters.build_class(data, c, {"road": lvl, "trade": 1, "fight": lvl}, "party", rng))
			var enemies: Array = []
			var n := 0
			for uid in enc["units"]:
				for k in int(enc["units"][uid]):
					enemies.append(Characters.build_unit(data, uid, "enemy", rng, n))
					n += 1
			var sk := Skirmish.new()
			sk.setup(data, party, enemies, rng)
			var res := sk.run()
			if res["winner"] == "party":
				wins += 1
			rounds.append(res["rounds"])
			hp.append(res["party_hp_share"])
			downs += res["party_down"]
		var rate := float(wins) / fights
		var t: Array = targets[enc["rating"]]
		var ok: bool = rate >= float(t[0]) and rate <= float(t[1])
		all_ok = all_ok and ok
		md.append("| %s | %s | %d | %d%% | %d–%d%% | %s | %d%% | %.2f | %s |" % [enc["name"], enc["rating"], lvl, roundi(rate * 100),
			roundi(float(t[0]) * 100), roundi(float(t[1]) * 100), _median(rounds), roundi(_median(hp) * 100), downs / fights, "✅" if ok else "❌"])
	all_ok = _road_wars(data, targets, md) and all_ok
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/out"))
	var f := FileAccess.open("res://tools/out/battle_report.md", FileAccess.WRITE)
	f.store_string("\n".join(md) + "\n")
	print("\n".join(md))
	quit(0 if all_ok else 1)


func _road_wars(data, targets: Dictionary, md: PackedStringArray) -> bool:
	var all_ok := true
	md.append("")
	md.append("## Road wars")
	md.append("")
	md.append("%d fights per convoy. The party convoy is the standard one for the convoy's level (data/units/units.json party_convoys); its named characters are at that level." % fights)
	md.append("")
	md.append("| Convoy | Rating | Party level | Party wins | Target | Rounds (median) | Party Durability left (median) | Party rigs lost (mean) | Enemy rigs taken (mean) | |")
	md.append("|---|---|---|---|---|---|---|---|---|---|")
	var pc: Dictionary = data.units["party_convoys"]
	for cv in data.units["convoys"]:
		var lvl := int(cv["party_level"])
		var band := "early" if lvl <= int(pc["early"]["max_level"]) else "mid"
		var wins := 0
		var rounds: Array = []
		var dur: Array = []
		var lost := 0.0
		var taken := 0.0
		for i in fights:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash("road|%s|%d" % [cv["id"], i])
			var party: Array = []
			for spec in pc[band]["rigs"]:
				var s: Dictionary = spec.duplicate(true)
				s["character"] = Characters.build_class(data, spec["driver"], {"road": lvl, "trade": 1, "fight": lvl}, "party", rng)
				party.append(s)
			var rw := RoadWar.new()
			rw.setup(data, party, cv["rigs"], cv["road"], rng)
			var res := rw.run()
			if res["winner"] == "party":
				wins += 1
			rounds.append(res["rounds"])
			dur.append(res["party_durability_share"])
			lost += res["party_rigs_lost"]
			taken += res["enemy_rigs_taken"]
		var rate := float(wins) / fights
		var t: Array = targets[cv["rating"]]
		var ok: bool = rate >= float(t[0]) and rate <= float(t[1])
		all_ok = all_ok and ok
		md.append("| %s | %s | %d | %d%% | %d–%d%% | %s | %d%% | %.2f | %.2f | %s |" % [cv["name"], cv["rating"], lvl, roundi(rate * 100),
			roundi(float(t[0]) * 100), roundi(float(t[1]) * 100), _median(rounds), roundi(_median(dur) * 100), lost / fights, taken / fights, "✅" if ok else "❌"])
	return all_ok


static func _median(a: Array) -> float:
	var b := a.duplicate()
	b.sort()
	if b.is_empty():
		return 0.0
	var n := b.size()
	return float(b[n / 2]) if n % 2 == 1 else (float(b[n / 2 - 1]) + float(b[n / 2])) / 2.0
