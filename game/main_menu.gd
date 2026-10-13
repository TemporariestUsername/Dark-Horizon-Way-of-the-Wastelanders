## The M2 test menu: pick a skirmish, a road war or a journey and play it.
## (The real title screen, docs/design/14, comes later: New / Continue.)
extends Control

const Game := preload("res://game/game.gd")
const Art := preload("res://game/art.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

const COLUMNS := [
	["skirmish", "Skirmish", "Fight", 6.0],
	["road_war", "Road war", "Drive", 164.0],
	["journey", "Journey", "Set out", 322.0],
]
const PLATE_Y := 140.0
const PLATE_W := 152.0
const PLATE_H := 102.0

var picks := {}       # "skirmish" / "road_war" / "journey" -> OptionButton
var levels := {}      # same keys -> int
var lists := {}       # same keys -> Array of entries
var clock := 0.0
var log_count := 0


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	Game.journey = null
	lists["skirmish"] = Game.data.units["encounters"]
	lists["road_war"] = Game.data.units["convoys"]
	lists["journey"] = Game.data.threats["bench_routes"]
	var labels := {
		"skirmish": func(e): return "%s (%s)" % [e["name"], e["rating"]],
		"road_war": func(e): return "%s (%s)" % [e["name"], e["rating"]],
		"journey": func(e): return "%s to %s" % [_hold(e["from"]), _hold(e["to"])],
	}
	for col in COLUMNS:
		_column(col[0], col[3], col[2], labels[col[0]])
	Game.button(self, "Open log folder", Vector2(330, 251), Vector2(100, 14), _open_log_folder)
	Game.button(self, "Quit", Vector2(434, 251), Vector2(42, 14), func(): get_tree().quit())
	log_count = PlaytestLog.count()
	if "--smoke-test" in OS.get_cmdline_user_args():
		_smoke_test.call_deferred()


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _open_log_folder() -> void:
	DirAccess.make_dir_recursive_absolute(PlaytestLog.path.get_base_dir())
	OS.shell_open(PlaytestLog.folder())


## For CI: an exported build proves it can load the data and fonts and write the log, then quits.
func _smoke_test() -> void:
	var before := PlaytestLog.count()
	PlaytestLog.write("smoke_test", {"holds": Game.data.holds.size(), "encounters": Game.data.units["encounters"].size()})
	var fonts_ok: bool = Game.font.get_string_size("Dark Horizon", HORIZONTAL_ALIGNMENT_LEFT, -1, Game.BODY).x > 0 \
		and Game.font.get_font_name() != "" and Game.font_head.get_font_name() != ""
	var ok: bool = Game.data.holds.size() == 130 and PlaytestLog.count() >= before + 1 and fonts_ok
	print("smoke test: %s (holds %d, fonts %s / %s, log %s)" % ["ok" if ok else "FAILED", Game.data.holds.size(),
		Game.font.get_font_name(), Game.font_head.get_font_name(), PlaytestLog.folder()])
	get_tree().quit(0 if ok else 1)


func _hold(id: String) -> String:
	return Game.data.hold_by_id[id]["name"]


func _column(key: String, x: float, go: String, label: Callable) -> void:
	var ob := OptionButton.new()
	ob.position = Vector2(x + 6, PLATE_Y + 28)
	ob.clip_text = true
	ob.add_theme_font_size_override("font_size", Game.BODY)
	for e in lists[key]:
		ob.add_item(label.call(e))
	ob.get_popup().add_theme_font_size_override("font_size", Game.BODY)
	ob.item_selected.connect(func(i): _set_level(key, _rated_level(key, i)))
	add_child(ob)
	ob.size = Vector2(PLATE_W - 12, 15)
	picks[key] = ob
	Game.button(self, "-", Vector2(x + PLATE_W - 46, PLATE_Y + 48), Vector2(18, 14), func(): _set_level(key, levels[key] - 1))
	Game.button(self, "+", Vector2(x + PLATE_W - 24, PLATE_Y + 48), Vector2(18, 14), func(): _set_level(key, levels[key] + 1))
	Game.button(self, go, Vector2(x + 6, PLATE_Y + 74), Vector2(PLATE_W - 12, 18), func(): _start(key))
	_set_level(key, _rated_level(key, 0))


func _rated_level(key: String, i: int) -> int:
	var e: Dictionary = lists[key][i]
	return int(e["level"]) if key == "journey" else int(e["party_level"])


func _set_level(key: String, lvl: int) -> void:
	levels[key] = clampi(lvl, 1, 20)


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
	draw_texture(Art.backdrop(), Vector2.ZERO)
	# A convoy crossing the horizon in front of the sun, black against it, dust behind.
	var x := fposmod(clock * 14.0 + 300.0, 620.0) - 120.0
	for f in ["half_track", "pickup", "hog"]:
		var tex := Art.variant(Art.rig(f, "party", "hands"), "silhouette", "%s|party|hands" % f)
		var bounce := 1.0 if sin(clock * 12.0 + x) > 0.7 else 0.0
		draw_texture(tex, Vector2(roundf(x), 129 - tex.get_height() - bounce))
		for k in 3:
			var a := fposmod(clock * 1.5 + k * 0.33, 1.0)
			draw_rect(Rect2(roundf(x) - 4 - a * 20.0, 125 - a * 5.0, 2 + a * 3.0, 2 + a * 2.0), Color("c2582a", 0.6 * (1.0 - a)))
		x -= tex.get_width() + 10
	# The title, stencil-heavy: a dark outline, a rust shadow, then the fill.
	var tp := Vector2(12, 40)
	for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1)]:
		draw_string(Game.font_head, tp + d * 2, "DARK HORIZON", HORIZONTAL_ALIGNMENT_LEFT, -1, Game.TITLE, Game.OIL)
	draw_string(Game.font_head, tp + Vector2(2, 2), "DARK HORIZON", HORIZONTAL_ALIGNMENT_LEFT, -1, Game.TITLE, Game.RUST)
	draw_string(Game.font_head, tp, "DARK HORIZON", HORIZONTAL_ALIGNMENT_LEFT, -1, Game.TITLE, Game.FIRE)
	Game.text(self, Vector2(14, 62), "WAY OF THE WASTELANDERS", Game.BONE, "head")
	Game.text(self, Vector2(14, 74), "M2 playtest build %s  ·  placeholder art" % PlaytestLog.build_id(), Color(Game.BONE, 0.75))
	# The three plates.
	var art := {
		"skirmish": Art.unit("raider"),
		"road_war": Art.rig("hog", "enemy", "teeth"),
		"journey": Art.gate(false),
	}
	for col in COLUMNS:
		var key: String = col[0]
		var r := Rect2(col[3], PLATE_Y, PLATE_W, PLATE_H)
		Game.panel(self, r)
		Game.text(self, r.position + Vector2(7, 21), String(col[1]).to_upper(), Game.FIRE, "head")
		var t: Texture2D = art[key]
		if key == "skirmish":
			t = Art.variant(t, "flip", "raider")
		draw_texture(t, Vector2(r.end.x - t.get_width() - 7, r.position.y + 24 - t.get_height()))
		Game.text(self, r.position + Vector2(7, 58), "Party level", Game.BONE)
		Game.text(self, r.position + Vector2(62, 58), str(levels[key]), Game.FIRE)
	draw_rect(Rect2(0, 247, 480, 23), Color(Game.OIL, 0.75))
	Game.text(self, Vector2(8, 261), "Playtest log: %d %s. Send us log.jsonl from its folder." % [log_count, "entry" if log_count == 1 else "entries"], Game.BONE)
