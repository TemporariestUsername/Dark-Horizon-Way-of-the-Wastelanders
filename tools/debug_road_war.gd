## Debug helper: one road war against a convoy, round by round, with the standard mid-game
## party convoy at level 5.
##   godot --headless --path . --script res://tools/debug_road_war.gd -- wellguard_tankers
extends SceneTree
const SimData := preload("res://sim/sim_data.gd")
const C := preload("res://sim/characters.gd")
const RW := preload("res://sim/battle/road_war.gd")
func _init() -> void:
	var data := SimData.new(); data.load_all()
	var rng := RandomNumberGenerator.new(); rng.seed = 5
	var cv: Dictionary = data.units["convoys"].filter(func(c): return c["id"] == OS.get_cmdline_user_args()[0])[0]
	var party: Array = []
	for spec in data.units["party_convoys"]["mid"]["rigs"]:
		var s: Dictionary = spec.duplicate(true)
		s["character"] = C.build_class(data, spec["driver"], {"road": 5, "trade": 1, "fight": 5}, "party", rng)
		party.append(s)
	var rw := RW.new()
	rw.setup(data, party, cv["rigs"], cv["road"], rng)
	for r in rw.rigs:
		print("%s %s dur %d arm %d spd %d hdl %d crew %d guns %d manned %d acc %.0f x %d lane %d" % [r["side"], r["name"], r["durability"], r["armor"], r["speed"], r["handling"], r["crew"], r["guns"].size(), rw._manned_guns(r), rw._gun_accuracy(r), r["x"], r["lane"]])
	while rw.round_n < 30 and rw._outcome() == "":
		var before := rw.lines.size()
		rw.round_n += 1
		for r in rw._active():
			if r["status"] == "active" and rw._outcome() == "":
				rw._turn(r)
		var st := []
		for r in rw.rigs:
			st.append("%s:%s x%d l%d d%d c%d" % [r["side"][0], r["name"].substr(0, 8), r["x"], r["lane"], r["durability"], r["crew"]])
		print("R%d %s" % [rw.round_n, " | ".join(st)])
		for l in rw.lines.slice(before):
			print("   ", l)
	quit()
