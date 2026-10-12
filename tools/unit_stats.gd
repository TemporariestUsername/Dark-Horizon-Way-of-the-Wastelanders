## Debug helper: prints the derived battle stats of the standard party at levels 1, 3 and 5
## and of every enemy unit.   godot --headless --path . --script res://tools/unit_stats.gd
extends SceneTree
const SimData := preload("res://sim/sim_data.gd")
const C := preload("res://sim/characters.gd")
func _init() -> void:
	var data := SimData.new(); data.load_all()
	var rng := RandomNumberGenerator.new(); rng.seed = 1
	var rows: Array = []
	for lvl in [1, 3, 5]:
		for cl in ["driver", "angel", "gunlugger"]:
			rows.append(C.build_class(data, cl, {"road": lvl, "trade": 1, "fight": lvl}, "party", rng, "%s L%d" % [cl, lvl]))
	for u in data.units["units"]:
		rows.append(C.build_unit(data, u["id"], "enemy", rng))
	for c in rows:
		print("%-28s hp %5.1f atk %5.1f acc %5.1f def %5.1f spd %5.1f eva %5.1f %s ammo%d" % [c["name"], c["max_hp"], C.attack_value(c), C.accuracy_value(c), c["defense"], c["speed"], c["speed"]*0.5, c["weapon"]["id"], c["ammo"]])
	quit()
