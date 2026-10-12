## M1 unit tests for res://sim. No add-ons needed:
##   godot --headless --path . --script res://tests/run_tests.gd
## Exits 0 when every test passes, 1 otherwise.
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const World := preload("res://sim/world.gd")
const Lean := preload("res://sim/lean.gd")
const GangWar := preload("res://sim/gang_war.gd")
const Conditions := preload("res://sim/conditions.gd")
const Characters := preload("res://sim/characters.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")
const RoadWar := preload("res://sim/battle/road_war.gd")
const EventSystem := preload("res://sim/events/event_system.gd")
const Journey := preload("res://sim/events/journey.gd")

## Golden journeys: a fixed seed and the auto policy must reproduce these transcripts word for
## word. After an intended change, regenerate with DH_UPDATE_GOLDEN=1 and review the diff.
const GOLDEN := [["lighthouse", "dustwich", 3, 1], ["sweetwell", "last_stop", 4, 2], ["highwater", "motor", 4, 3]]

var data
var graph
var failures := 0
var checks := 0


func _init() -> void:
	data = SimData.new()
	data.load_all()
	graph = RoadGraph.new()
	graph.build(data)
	for t in [
		"test_data_loads", "test_graph", "test_lean", "test_gang_war", "test_conditions",
		"test_characters", "test_determinism", "test_invariants",
		"test_build_class", "test_skirmish", "test_road_war", "test_events", "test_golden_journeys",
	]:
		var before := failures
		call(t)
		print(("PASS  " if failures == before else "FAIL  ") + t)
	print("%d checks, %d failed" % [checks, failures])
	quit(0 if failures == 0 else 1)


func ok(cond: bool, what: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		printerr("  failed: " + what)


func test_data_loads() -> void:
	ok(data.holds.size() == 130, "130 holds")
	ok(data.edges.size() == 423, "423 road edges")
	ok(data.factions["factions"].size() == 6, "6 factions")
	ok(data.subfactions["subfactions"].size() == 16, "16 sub-factions")


func test_graph() -> void:
	ok(graph.dist["lighthouse"].size() == 130, "every hold reachable year-round from the Lighthouse")
	ok(graph.km("lighthouse", "lighthouse") == 0.0, "zero distance to self")
	ok(is_equal_approx(graph.km("lighthouse", "barrow"), graph.km("barrow", "lighthouse")), "distances symmetric")
	var days: float = graph.travel_days("lighthouse", "barrow")
	ok(days > 25.0 and days < 45.0, "the Sierra Coast is about a month from the Crossing (%.1f days)" % days)
	var near: Array = graph.nearest("lighthouse", 400.0)
	var sorted := true
	for i in range(1, near.size()):
		if graph.km("lighthouse", near[i - 1]) > graph.km("lighthouse", near[i]):
			sorted = false
	ok(sorted and not near.has("lighthouse"), "nearest() is sorted and excludes the source")


func test_lean() -> void:
	var l := {"independent": 77.0, "lighthouse": 23.0}
	Lean.add(l, "sweetwell", 30.0)
	ok(is_equal_approx(Lean.total(l), 100.0), "add keeps the total at 100")
	ok(is_equal_approx(Lean.share(l, "independent"), 47.0), "add takes from independent first")
	Lean.add(l, "sweetwell", 60.0)
	ok(is_equal_approx(Lean.total(l), 100.0) and Lean.leans(l) == "sweetwell", "then from the largest share")
	Lean.add(l, "sweetwell", -10.0)
	ok(is_equal_approx(Lean.total(l), 100.0), "negative points go back to independent")
	var c := {"independent": 50.0, "cerro": 30.0, "sweetwell": 20.0}
	Lean.conquer(c, "exchange", 60.0)
	ok(is_equal_approx(c["exchange"], 60.0) and is_equal_approx(Lean.total(c), 100.0), "conquest gives 60 and rescales the rest")
	ok(is_equal_approx(c["cerro"], 12.0), "rest rescaled proportionally")
	ok(Lean.leans({"independent": 45.0, "cerro": 40.0, "exchange": 15.0}) == "", "below 50 everywhere is contested")


func test_gang_war() -> void:
	var rng := RandomNumberGenerator.new()
	var strong := {"troops": 80, "arms": 80, "training": 70, "tags": []}
	var weak := {"troops": 15, "arms": 30, "training": 20, "tags": []}
	var wins := 0
	for i in 100:
		rng.seed = i
		if GangWar.resolve(strong, weak, 0, data.war, rng)["attacker_won"]:
			wins += 1
	ok(wins >= 95, "a much stronger gang wins (%d/100)" % wins)
	wins = 0
	for i in 100:
		rng.seed = i
		if GangWar.resolve(weak, strong, 2, data.war, rng)["attacker_won"]:
			wins += 1
	ok(wins == 0, "a weak gang never takes a walled hold from a strong one")
	rng.seed = 7
	var a: Dictionary = GangWar.resolve(strong, weak, 1, data.war, rng)
	rng.seed = 7
	var b: Dictionary = GangWar.resolve(strong, weak, 1, data.war, rng)
	ok(a == b, "gang war is deterministic for a seed")
	var opened := {"troops": 40, "arms": 30, "training": 20, "tags": ["opened"]}
	var eff := GangWar.effective(opened, data.war)
	ok(eff["no_morale"], "the Opened have no morale")
	ok(GangWar.effective({"troops": 10, "arms": 50, "training": 50, "tags": ["well-disciplined"]}, data.war)["breaks_below"] == 20.0,
		"well-disciplined gangs break only below 20")


func test_conditions() -> void:
	var w := World.new()
	w.setup(data, graph, 1)
	ok(Conditions.evaluate("leans(lighthouse) == lighthouse", w), "leans() of a seat")
	ok(not Conditions.evaluate("aquifer < 50", w), "the aquifer starts at 100")
	ok(Conditions.evaluate("walls(helena) >= 0 and lean(lighthouse, lighthouse) >= 99", w), "and-joined clauses")
	ok(not Conditions.evaluate("cerro_walls(border)", w), "bare boolean clause")
	ok(Conditions.evaluate("teeth_raids_last_6_months == 0", w), "no raids at the start")
	ok(Conditions.evaluate("count(debtors on the Sixty-Five) >= 0", w), "count() with a region")
	ok(Conditions.mentioned_holds("leans(arch) == lighthouse and leans(siege) == lighthouse", w.H) == ["arch", "lighthouse", "siege"],
		"mentioned_holds finds hold ids")
	# Every ambition condition in the data must parse and evaluate.
	for f in data.factions["factions"]:
		for st in f["ambition"]["stages"]:
			Conditions.evaluate(st["when"], w)
	ok(true, "all ambition conditions evaluate")


func test_characters() -> void:
	var r: Dictionary = data.characters
	ok(Characters.check_chance(r, 60, "fair", 1) == 80, "check: 50 + (60 - 40) + 10 = 80")
	ok(Characters.check_chance(r, 10, "brutal") == 5, "check floor is 5")
	ok(Characters.check_chance(r, 100, "easy", 3) == 95, "check cap is 95")
	ok(Characters.xp_to_next(1) == 100 and Characters.xp_to_next(10) == 3162, "XP curve 100 x level^1.5")
	ok(is_equal_approx(Characters.health(50, 0), 70.0), "health 40 + hard x 0.6")
	ok(is_equal_approx(Characters.hum_gain(10, 100), 5.0), "Weird 100 halves Hum gain")


func test_determinism() -> void:
	var a := World.new()
	a.setup(data, graph, 42)
	var b := World.new()
	b.setup(data, graph, 42)
	var c := World.new()
	c.setup(data, graph, 43)
	for m in 24:
		a.world_turn()
		b.world_turn()
		c.world_turn()
	ok(a.fingerprint() == b.fingerprint(), "same seed, same world after 24 months")
	ok(a.events.size() == b.events.size(), "same seed, same Month Reports")
	ok(a.fingerprint() != c.fingerprint(), "different seed, different world")


func test_invariants() -> void:
	var w := World.new()
	w.setup(data, graph, 5)
	var sil := w.silenced_count()
	for m in 36:
		w.world_turn()
		ok(w.silenced_count() >= sil, "with no player, nothing is liberated (month %d)" % w.month)
		sil = w.silenced_count()
	var lean_ok := true
	var stock_ok := true
	var want_ok := true
	var hum_ok := true
	for id in w.H:
		var h: Dictionary = w.H[id]
		if h["lean"] != null and not is_equal_approx(Lean.total(h["lean"]), 100.0):
			lean_ok = false
		for g in h["stock"]:
			if float(h["stock"][g]) < 0.0:
				stock_ok = false
		for g in h["want"]:
			if int(h["want"][g]) < 0 or int(h["want"][g]) > 3:
				want_ok = false
		if h["hum"] < 0.0 or h["hum"] > 100.0 or (h["silenced"] != (h["lean"] == null)):
			hum_ok = false
	ok(lean_ok, "every live hold's Lean sums to 100")
	ok(stock_ok, "no negative stock")
	ok(want_ok, "wants stay within 0-3")
	ok(hum_ok, "Hum within 0-100, and only Silenced holds lose their Lean")
	ok(w.history.size() == 37, "a metric snapshot per month")


func test_build_class() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var d1: Dictionary = Characters.build_class(data, "driver", {"road": 1, "trade": 1, "fight": 1}, "party", rng)
	var total := 0.0
	for a in d1["attributes"]:
		total += float(d1["attributes"][a])
	ok(is_equal_approx(total, 180.0), "a level-1 Driver has 180 attribute points")
	var d5: Dictionary = Characters.build_class(data, "driver", {"road": 5, "trade": 1, "fight": 5}, "party", rng)
	var total5 := 0.0
	for a in d5["attributes"]:
		total5 += float(d5["attributes"][a])
	ok(is_equal_approx(total5, 180.0 + 4 * 8), "8 level-ups add 32 points")
	ok(d5["attributes"]["cool"] > d1["attributes"]["cool"] and d5["max_hp"] > d1["max_hp"], "levels raise Cool and Health")
	ok(d1["abilities"].any(func(ab): return ab["id"] == "eye_on_the_door") == false and d5["abilities"].any(func(ab): return ab["id"] == "eye_on_the_door"),
		"Eye on the door unlocks at Road 5")
	var q: Dictionary = Characters.build_class(data, "quarantine", {"road": 9, "trade": 1, "fight": 9}, "party", rng)
	ok(is_equal_approx(q["attributes"]["weird"], 15.0), "the Quarantine's Weird stays locked")
	var mg: Dictionary = Characters.build_class(data, "gunlugger", {"road": 1, "trade": 1, "fight": 1}, "party", rng)
	ok(mg["ammo"] == 36, "a machine gun carries 12 attacks of ammo at 3 rounds each")
	var op: Dictionary = Characters.build_unit(data, "opened", "enemy", rng)
	ok(op["max_hp"] < Characters.health(op["attributes"]["hard"], op["fight"]), "the Opened have 60% HP")


func _fight(seed_n: int, party_spec: Array, enemy_spec: Dictionary, lvl: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_n
	var party: Array = []
	for c in party_spec:
		party.append(Characters.build_class(data, c, {"road": lvl, "trade": 1, "fight": lvl}, "party", rng))
	var enemies: Array = []
	var n := 0
	for u in enemy_spec:
		for k in int(enemy_spec[u]):
			enemies.append(Characters.build_unit(data, u, "enemy", rng, n))
			n += 1
	var sk := Skirmish.new()
	sk.setup(data, party, enemies, rng)
	return {"result": sk.run(), "sk": sk}


func test_skirmish() -> void:
	var a: Dictionary = _fight(9, ["driver", "angel", "gunlugger"], {"raider": 2, "raider_gunner": 2}, 2)
	var b: Dictionary = _fight(9, ["driver", "angel", "gunlugger"], {"raider": 2, "raider_gunner": 2}, 2)
	ok(a["result"] == b["result"] and a["sk"].lines == b["sk"].lines, "a skirmish replays exactly from its seed")
	var wins := 0
	for i in 50:
		if _fight(100 + i, ["driver", "angel", "gunlugger"], {"scavver": 2}, 5)["result"]["winner"] == "party":
			wins += 1
	ok(wins == 50, "a level-5 party always beats two scavvers")
	var easy: Dictionary = _fight(3, ["driver", "angel", "gunlugger"], {"scavver": 2}, 5)["result"]
	ok(easy["xp"] == 20 and easy["rounds"] >= 1, "XP is 10 per enemy level")
	var losses := 0
	for i in 30:
		if _fight(200 + i, ["driver"], {"shan": 1, "catcher": 3}, 1)["result"]["winner"] == "enemy":
			losses += 1
	ok(losses == 30, "a lone level-1 Driver never beats Shan's catchers")
	var mob: Dictionary = _fight(5, ["driver", "angel", "gunlugger"], {"opened": 8}, 3)
	ok(not mob["sk"].units.any(func(c): return c["tags"].has("opened") and c["fled"]), "the Opened never flee")
	var sk: Skirmish = mob["sk"]
	ok(sk.flee_chance() >= 5.0 and sk.flee_chance() <= 95.0, "flee chance is clamped")
	for c in sk.units:
		if c["hp"] < 0.0 or c["hp"] > c["max_hp"] + 0.001 or c["ammo"] < 0:
			ok(false, "HP and ammo stay in range (%s)" % c["name"])
			return
	ok(true, "HP and ammo stay in range")


func _road_war(seed_n: int, convoy_id: String, lvl: int) -> RoadWar:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_n
	var band := "early" if lvl <= 3 else "mid"
	var party: Array = []
	for spec in data.units["party_convoys"][band]["rigs"]:
		var s: Dictionary = spec.duplicate(true)
		s["character"] = Characters.build_class(data, spec["driver"], {"road": lvl, "trade": 1, "fight": lvl}, "party", rng)
		party.append(s)
	var cv: Dictionary = data.units["convoys"].filter(func(c): return c["id"] == convoy_id)[0]
	var rw := RoadWar.new()
	rw.setup(data, party, cv["rigs"], cv["road"], rng)
	rw.run()
	return rw


func test_road_war() -> void:
	ok(RoadWar.band(0) == "contact" and RoadWar.band(3) == "close" and RoadWar.band(6) == "far" and RoadWar.band(9) == "gone", "range bands")
	var a := _road_war(4, "teeth_raid", 3)
	var b := _road_war(4, "teeth_raid", 3)
	ok(a.result == b.result and a.lines == b.lines, "a road war replays exactly from its seed")
	var wins := 0
	for i in 40:
		if _road_war(300 + i, "teeth_outriders", 6)["result"]["winner"] == "party":
			wins += 1
	ok(wins == 40, "a level-6 convoy always beats the outriders")
	var rw := _road_war(7, "wellguard_tankers", 5)
	var in_range := true
	for r in rw.rigs:
		if r["durability"] < 0.0 or r["durability"] > r["max_durability"] + 0.001 or r["crew"] < 0 or r["ammo"] < 0:
			in_range = false
		if r["lane"] < 0 or r["lane"] >= rw.lanes:
			in_range = false
	ok(in_range, "Durability, crew, ammo and lanes stay in range")
	var pos := {}
	var overlap := false
	for r in rw.rigs:
		if r["status"] == "active":
			var k := Vector2i(r["lane"], r["x"])
			overlap = overlap or pos.has(k)
			pos[k] = true
	ok(not overlap, "no two active rigs share a cell")
	ok(rw.result["winner"] in ["party", "enemy", "escaped", "draw"], "a road war ends with a known outcome")


func _journey(from: String, to: String, lvl: int, seed_n: int, month: int = 3) -> Journey:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_n
	var j := Journey.new()
	j.setup(data, graph, null, from, to, lvl, rng, month)
	j.run()
	return j


func test_events() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var es := EventSystem.new()
	es.setup(data, graph, null, rng)
	var ctx := {"day": 10.0, "hold": "nodders", "region": data.hold_by_id["nodders"]["region"], "ring": "farther", "season": "summer",
		"kind": "road", "crossing": false, "water": 10.0, "chow": 10.0}
	var ids: Array = es.eligible(ctx).map(func(c): return c["event"]["id"])
	ok(not ids.has("teeth_raid") and not ids.has("dremmers_battle_rig"), "lethal Teeth events need a warning first")
	ok(ids.has("teeth_sign") and ids.has("dust_storm"), "near the Teeth in summer: their sign and dust storms can fire")
	es.warn("teeth", 5.0)
	ids = es.eligible(ctx).map(func(c): return c["event"]["id"])
	ok(ids.has("teeth_raid"), "once warned, the Teeth can raid")
	ctx["day"] = 80.0
	ids = es.eligible(ctx).map(func(c): return c["event"]["id"])
	ok(not ids.has("teeth_raid"), "a warning is forgotten after the warning memory")
	es.bad_streak = 3
	var tones: Array = es.eligible(ctx).map(func(c): return c["event"]["tone"])
	ok(not tones.has("bad") and not tones.has("lethal"), "after three bad events in a row, only good or neutral ones")
	es.bad_streak = 0
	var far := ctx.duplicate()
	far["hold"] = "highwater"
	far["region"] = data.hold_by_id["highwater"]["region"]
	ids = es.eligible(far).map(func(c): return c["event"]["id"])
	ok(not ids.has("teeth_sign") and not ids.has("dust_storm"), "no Teeth or Rag-Wastes weather on the Lakes")
	var unwarned := 0
	var streak := 0
	for i in 40:
		var j := _journey("sweetwell", "last_stop", 4, 500 + i, 7)
		unwarned += j.stats["lethal_unwarned"]
		streak = max(streak, j.stats["max_bad_streak"])
	ok(unwarned == 0 and streak <= 3, "40 journeys: no lethal event unwarned, no bad streak over 3")
	var a := _journey("lighthouse", "dustwich", 3, 9)
	var b := _journey("lighthouse", "dustwich", 3, 9)
	ok(a.lines == b.lines and a.stats == b.stats, "a journey replays exactly from its seed")


func test_golden_journeys() -> void:
	var update := OS.get_environment("DH_UPDATE_GOLDEN") == "1"
	for g in GOLDEN:
		var j := _journey(g[0], g[1], g[2], g[3])
		var path := "res://tests/golden/journey_%s_%s_s%d.txt" % [g[0], g[1], g[3]]
		var text := "\n".join(j.lines) + "\n"
		if update or not FileAccess.file_exists(path):
			var f := FileAccess.open(path, FileAccess.WRITE)
			f.store_string(text)
			print("  wrote " + path)
			continue
		var want := FileAccess.get_file_as_string(path)
		ok(want == text, "golden journey %s -> %s (seed %d) matches %s" % [g[0], g[1], g[3], path])
