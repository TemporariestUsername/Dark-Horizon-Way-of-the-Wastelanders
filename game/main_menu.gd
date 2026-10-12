## The M2 test menu: pick a skirmish, a road war or a journey and play it.
## (The real title screen, docs/design/14, comes later: New / Continue.)
extends Control

const Game := preload("res://game/game.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

var picks := {}       # "skirmish" / "road_war" / "journey" -> OptionButton
var levels := {}      # same keys -> int
var level_labels := {}
var lists := {}       # same keys -> Array of entries


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	Game.journey = null
	lists["skirmish"] = Game.data.units["encounters"]
	lists["road_war"] = Game.data.units["convoys"]
	lists["journey"] = Game.data.threats["bench_routes"]
	_column("skirmish", "SKIRMISH", 8, "Fight", func(e): return "%s (%s)" % [e["name"], e["rating"]])
	_column("road_war", "ROAD WAR", 164, "Drive", func(e): return "%s (%s)" % [e["name"], e["rating"]])
	_column("journey", "JOURNEY", 320, "Set out", func(e): return "%s to %s" % [_hold(e["from"]), _hold(e["to"])])
	Game.button(self, "Open log folder", Vector2(336, 250), Vector2(96, 14), _open_log_folder)
	Game.button(self, "Quit", Vector2(436, 250), Vector2(38, 14), func(): get_tree().quit())
	if "--smoke-test" in OS.get_cmdline_user_args():
		_smoke_test.call_deferred()


func _open_log_folder() -> void:
	DirAccess.make_dir_recursive_absolute(PlaytestLog.path.get_base_dir())
	OS.shell_open(PlaytestLog.folder())


## For CI: an exported build proves it can load the data and write the log, then quits.
func _smoke_test() -> void:
	var before := PlaytestLog.count()
	PlaytestLog.write("smoke_test", {"holds": Game.data.holds.size(), "encounters": Game.data.units["encounters"].size()})
	var ok: bool = Game.data.holds.size() == 130 and PlaytestLog.count() >= before + 1
	print("smoke test: %s (holds %d, log %s)" % ["ok" if ok else "FAILED", Game.data.holds.size(), PlaytestLog.folder()])
	get_tree().quit(0 if ok else 1)


func _hold(id: String) -> String:
	return Game.data.hold_by_id[id]["name"]


func _column(key: String, head: String, x: float, go: String, label: Callable) -> void:
	var y := 150.0
	var lab := Label.new()
	lab.text = head
	lab.position = Vector2(x, y)
	lab.add_theme_color_override("font_color", Game.FIRE)
	add_child(lab)
	var ob := OptionButton.new()
	ob.position = Vector2(x, y + 14)
	ob.clip_text = true
	ob.add_theme_font_size_override("font_size", 8)
	for e in lists[key]:
		ob.add_item(label.call(e))
	ob.get_popup().add_theme_font_size_override("font_size", 8)
	ob.item_selected.connect(func(i): _set_level(key, _rated_level(key, i)))
	add_child(ob)
	ob.size = Vector2(150, 14)
	picks[key] = ob
	var ll := Label.new()
	ll.position = Vector2(x, y + 33)
	add_child(ll)
	level_labels[key] = ll
	Game.button(self, "-", Vector2(x + 76, y + 34), Vector2(16, 13), func(): _set_level(key, levels[key] - 1))
	Game.button(self, "+", Vector2(x + 94, y + 34), Vector2(16, 13), func(): _set_level(key, levels[key] + 1))
	Game.button(self, go, Vector2(x, y + 52), Vector2(150, 15), func(): _start(key))
	_set_level(key, _rated_level(key, 0))


func _rated_level(key: String, i: int) -> int:
	var e: Dictionary = lists[key][i]
	return int(e["level"]) if key == "journey" else int(e["party_level"])


func _set_level(key: String, lvl: int) -> void:
	levels[key] = clampi(lvl, 1, 20)
	level_labels[key].text = "Party level %d" % levels[key]


func _start(key: String) -> void:
	var e: Dictionary = lists[key][picks[key].selected]
	var lvl: int = levels[key]
	var seed := int(Time.get_unix_time_from_system() * 1000.0) % 1000000007
	match key:
		"skirmish":
			Game.next = {"encounter": e["id"], "level": lvl, "seed": seed}
			get_tree().change_scene_to_file("res://game/skirmish_scene.tscn")
		"road_war":
			Game.next = {"convoy": e["id"], "level": lvl, "seed": seed}
			get_tree().change_scene_to_file("res://game/road_war_scene.tscn")
		"journey":
			Game.next = {"from": e["from"], "to": e["to"], "level": lvl, "month": int(e["month"]), "world_months": int(e.get("world_months", 0)), "seed": seed}
			get_tree().change_scene_to_file("res://game/journey_scene.tscn")


func _draw() -> void:
	# A sunset sky in bands, the interstate running to the horizon, a smoke column, a convoy.
	var bands := [Color("2a1a2e"), Color("5a2a3a"), Color("8e3b1f"), Color("c2582a"), Color("e0621b"), Color("f5a623")]
	for i in bands.size():
		draw_rect(Rect2(0, i * 16, 480, 16), bands[i])
	draw_circle(Vector2(360, 98), 22.0, Color("f7c66b"))
	draw_rect(Rect2(0, 96, 480, 174), Game.OCHRE.darkened(0.35))
	draw_colored_polygon(PackedVector2Array([Vector2(226, 96), Vector2(254, 96), Vector2(420, 270), Vector2(60, 270)]), Game.ASPHALT)
	for i in 6:
		var t := float(i) / 6.0
		var y := 100.0 + t * t * 170.0
		draw_rect(Rect2(239 - t * 2, y, 2 + t * 4, 3 + t * 8), Game.FIRE)
	# The broken overpass, and smoke on the horizon.
	draw_rect(Rect2(40, 80, 120, 6), Game.ASH)
	draw_rect(Rect2(60, 86, 6, 10), Game.ASH)
	draw_rect(Rect2(130, 86, 6, 10), Game.ASH)
	draw_colored_polygon(PackedVector2Array([Vector2(160, 80), Vector2(168, 82), Vector2(162, 86), Vector2(156, 86)]), Game.ASH)
	for i in 8:
		draw_circle(Vector2(420 + sin(i * 1.3) * 6 + i * 3, 92 - i * 9), 4.0 + i * 1.2, Color(Game.OIL, 0.55 - i * 0.05))
	# A convoy, black against the sun, with a dust plume.
	for i in 3:
		var x := 270.0 + i * 22
		draw_rect(Rect2(x, 104, 16, 5), Game.OIL)
		draw_rect(Rect2(x + 9, 101, 6, 3), Game.OIL)
		draw_circle(Vector2(x - 4, 106), 4.0, Color(Game.SAND, 0.5))
	Game.text(self, Vector2(10, 30), "DARK HORIZON", Game.FIRE, 22)
	Game.text(self, Vector2(12, 44), "Way of the Wastelanders", Game.BONE, 10)
	Game.text(self, Vector2(12, 56), "M2 playtest build %s: placeholder art" % PlaytestLog.build_id(), Color(Game.BONE, 0.7), 7)
	Game.panel(self, Rect2(2, 142, 476, 100))
	var n := PlaytestLog.count()
	Game.text(self, Vector2(6, 260), "Playtest log: %d %s. Send us log.jsonl from its folder." % [n, "entry" if n == 1 else "entries"], Game.BONE, 7)
