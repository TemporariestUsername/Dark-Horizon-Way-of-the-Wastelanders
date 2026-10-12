## The playable road war (M2 placeholder art). The battle is sim/battle/road_war.gd; this
## scene draws the road around the party's convoy and turns clicks into the sim's actions.
##
## A party rig's turn has two steps: drive (click a teal cell, or Stay), then act (Fire,
## Ram, Board or Evade). Click an enemy rig to target it. Auto plays this rig's whole turn
## with the AI; Run makes the whole convoy run for it.
## Keys: Space stay, F fire, R ram, B board, E evade, A auto.
extends Control

const Game := preload("res://game/game.gd")
const Characters := preload("res://sim/characters.gd")
const RoadWar := preload("res://sim/battle/road_war.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

const CELL := 18
const ROAD_TOP := 22.0
const ROAD_H := 112.0
const AI_DELAY := 0.35
const MAX_ROUNDS := 30
const VIEW_CELLS := 26

var rw
var queue: Array = []
var active: Dictionary = {}
var target: Dictionary = {}
var waiting := false
var stage := "drive"            # drive, act
var hover := Vector2i(-99, -99)  # (lane, x)
var embedded := false
var done := false
var result := {}
var timer := 0.2
var title := ""
var cam_x := 0.0
var btn := {}
var auto_all := false
var log_info := {}              # what this fight is, for the playtest log
var actions := {}               # the player's actions by kind, for the playtest log
var player_turns := 0
var started_ms := 0


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	var nx: Dictionary = Game.next
	if nx.has("sim"):
		rw = nx["sim"]
		embedded = true
		title = nx.get("title", "Road war")
		log_info = nx.get("log", {"source": "journey"})
	else:
		var rng := RandomNumberGenerator.new()
		var seed := int(nx.get("seed", Time.get_ticks_usec()))
		rng.seed = seed
		var cv_id: String = nx.get("convoy", "teeth_outriders")
		var cv: Dictionary = Game.data.units["convoys"].filter(func(c): return c["id"] == cv_id)[0]
		var lvl := int(nx.get("level", cv["party_level"]))
		var pc: Dictionary = Game.data.units["party_convoys"]
		var band := "early" if lvl <= int(pc["early"]["max_level"]) else "mid"
		var party: Array = []
		for spec in pc[band]["rigs"]:
			var s: Dictionary = spec.duplicate(true)
			s["character"] = Characters.build_class(Game.data, spec["driver"], {"road": lvl, "trade": 1, "fight": lvl}, "party", rng)
			party.append(s)
		rw = RoadWar.new()
		rw.setup(Game.data, party, cv["rigs"], cv["road"], rng)
		title = "%s (%s, %s, party level %d)" % [cv["name"], cv["rating"], cv["road"], lvl]
		log_info = {"source": "menu", "convoy": cv_id, "rating": cv["rating"], "level": lvl, "seed": seed}
	started_ms = Time.get_ticks_msec()
	cam_x = _party_center()
	var labels := [["Stay", _on_stay], ["Fire", _on_fire], ["Ram", _on_ram], ["Board", _on_board], ["Evade", _on_evade], ["Auto", _on_auto], ["Run", _on_run]]
	for i in labels.size():
		btn[labels[i][0]] = Game.button(self, labels[i][0], Vector2(4 + i * 68, 253), Vector2(64, 13), labels[i][1])
	btn["continue"] = Game.button(self, "Continue", Vector2(200, 112), Vector2(80, 14), _on_continue)
	btn["continue"].visible = false
	_refresh_buttons()


func _party_center() -> float:
	var xs: Array = rw.rigs.filter(func(r): return r["side"] == "party" and r["status"] == "active").map(func(r): return float(r["x"]))
	if xs.is_empty():
		return cam_x
	var t := 0.0
	for x in xs:
		t += x
	return t / xs.size()


# ---------------------------------------------------------------- the turn loop

func _process(delta: float) -> void:
	var goal: float = float(active["x"]) if waiting else _party_center()
	cam_x = lerpf(cam_x, goal, clampf(delta * 4.0, 0.0, 1.0))
	queue_redraw()
	if done or waiting:
		return
	timer -= delta
	if timer > 0.0:
		return
	step()


## Mirrors RoadWar.run(): once the fight is decided the round's other turns are skipped,
## and the round still ends (so auto play here gives exactly the bench's result).
func step() -> void:
	if queue.is_empty():
		if rw.round_n > 0:
			rw.end_round()
		if rw.outcome() != "" or rw.round_n >= MAX_ROUNDS:
			_finish()
			return
		queue = rw.start_round()
	var r: Dictionary = queue.pop_front()
	if r["status"] != "active" or rw.outcome() != "":
		return
	active = r
	timer = AI_DELAY
	if r["side"] == "party" and not auto_all and rw.party_mode == "fight":
		waiting = true
		player_turns += 1
		stage = "drive"
		if target.is_empty() or target["status"] != "active":
			target = _nearest_enemy(r)
	else:
		rw.ai_turn(r)
	_refresh_buttons()


func _nearest_enemy(r: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	for e in rw.rigs:
		if e["side"] == "enemy" and e["status"] == "active" and (best.is_empty() or abs(e["x"] - r["x"]) < abs(best["x"] - r["x"])):
			best = e
	return best


func _end_turn() -> void:
	waiting = false
	timer = AI_DELAY
	_refresh_buttons()


func _finish() -> void:
	done = true
	waiting = false
	result = rw.finish()
	btn["continue"].visible = true
	if not auto_all:
		var rec := log_info.duplicate()
		rec.merge({"winner": result["winner"], "rounds": result["rounds"], "party_durability_share": snappedf(result["party_durability_share"], 0.01),
			"party_rigs_lost": result["party_rigs_lost"], "enemy_rigs_taken": result["enemy_rigs_taken"], "player_turns": player_turns,
			"actions": actions, "seconds": (Time.get_ticks_msec() - started_ms) / 1000})
		PlaytestLog.write("road_war", rec)
		var about := log_info.duplicate()
		about.merge({"about": "road_war", "winner": result["winner"]})
		PlaytestLog.feel_buttons(self, Vector2(129, 94), about)
	_refresh_buttons()


func _refresh_buttons() -> void:
	var can := waiting and not done
	for k in ["Stay", "Fire", "Ram", "Board", "Evade", "Auto", "Run"]:
		btn[k].disabled = not can
	if not can:
		return
	btn["Stay"].disabled = stage != "drive"
	btn["Auto"].disabled = stage != "drive"
	var has_t = not target.is_empty() and target["status"] == "active"
	btn["Fire"].disabled = rw.manned_guns(active) == 0 and active["rider_weapon"] == ""
	btn["Ram"].disabled = not (has_t and rw.can_contact(active, target))
	btn["Board"].disabled = not (has_t and rw.can_contact(active, target) and active["crew"] >= 2)


# ---------------------------------------------------------------- input

func _lane_h() -> float:
	return minf(24.0, ROAD_H / rw.lanes)


func _road_rect() -> Rect2:
	return Rect2(0, ROAD_TOP + (ROAD_H - _lane_h() * rw.lanes) / 2.0, size.x, _lane_h() * rw.lanes)


## Screen position of the top-left of road cell (lane, x).
func _cell_pos(lane: int, x: float) -> Vector2:
	var rr := _road_rect()
	return Vector2(size.x / 2.0 + (x - cam_x) * CELL - CELL / 2.0, rr.position.y + lane * _lane_h())


func _cell_at(p: Vector2) -> Vector2i:
	var rr := _road_rect()
	if not rr.has_point(p):
		return Vector2i(-99, -99)
	var lane := int((p.y - rr.position.y) / _lane_h())
	var x := roundi((p.x - size.x / 2.0) / CELL + cam_x)
	return Vector2i(lane, x)


## Cells the active rig can drive to: one lane change (costing a point of Speed), then along the road.
func drive_cells() -> Array:
	var out: Array = []
	if not waiting or stage != "drive":
		return out
	var spd: int = 1 if active["hooked"] > 0 else int(active["speed"])
	for dl in [-1, 0, 1]:
		var lane: int = active["lane"] + dl
		if lane < 0 or lane >= rw.lanes:
			continue
		var pts: int = spd - abs(dl)
		for dx in range(-pts, pts + 1):
			out.append(Vector2i(lane, active["x"] + dx))
	return out


func _rig_at(c: Vector2i) -> Dictionary:
	for r in rw.rigs:
		if r["status"] == "active" and r["lane"] == c.x and r["x"] == c.y:
			return r
	return {}


func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion:
		hover = _cell_at(ev.position)
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		click_cell(_cell_at(ev.position))


func click_cell(c: Vector2i) -> void:
	if not waiting:
		return
	var r := _rig_at(c)
	if not r.is_empty() and r["side"] == "enemy":
		target = r
		_refresh_buttons()
		return
	if stage == "drive" and drive_cells().has(c) and r.is_empty():
		rw.player_drive(active, c.y - active["x"], c.x - active["lane"])
		_count("drive")
		stage = "act"
		_refresh_buttons()


func _unhandled_key_input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed) or not waiting:
		return
	match ev.keycode:
		KEY_SPACE: if stage == "drive": _on_stay()
		KEY_F: if not btn["Fire"].disabled: _on_fire()
		KEY_R: if not btn["Ram"].disabled: _on_ram()
		KEY_B: if not btn["Board"].disabled: _on_board()
		KEY_E: _on_evade()
		KEY_A: if stage == "drive": _on_auto()


func _count(k: String) -> void:
	actions[k] = int(actions.get(k, 0)) + 1


func _on_stay() -> void:
	_count("stay")
	stage = "act"
	_refresh_buttons()


func _on_fire() -> void:
	rw.player_fire(active, target)
	_count("fire")
	_end_turn()


func _on_ram() -> void:
	if rw.player_ram(active, target):
		_count("ram")
		_end_turn()


func _on_board() -> void:
	if rw.player_board(active, target):
		_count("board")
		_end_turn()


func _on_evade() -> void:
	rw.player_evade(active)
	_count("evade")
	_end_turn()


func _on_auto() -> void:
	rw.ai_turn(active)
	_count("auto")
	_end_turn()


func _on_run() -> void:
	rw.player_run()
	_count("run")
	rw.ai_turn(active)
	_end_turn()


func _on_continue() -> void:
	if embedded and Game.journey != null:
		Game.next = {"battle_result": result}
		get_tree().change_scene_to_file("res://game/journey_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://game/main_menu.tscn")


# ---------------------------------------------------------------- drawing

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Game.OCHRE.darkened(0.3))
	var rr := _road_rect()
	# Scrub either side of the road, scrolling with the camera.
	for i in 40:
		var sx := fposmod(i * 37.0 - cam_x * CELL, size.x + 40.0) - 20.0
		draw_rect(Rect2(sx, rr.position.y - 8 - (i % 3) * 3, 3, 3), Game.OCHRE.darkened(0.5))
		draw_rect(Rect2(fposmod(sx + 19.0, size.x), rr.end.y + 4 + (i % 4) * 3, 3, 2), Game.OCHRE.darkened(0.5))
	draw_rect(rr, Game.ASPHALT)
	draw_line(rr.position, Vector2(rr.end.x, rr.position.y), Game.BONE, 1.0)
	draw_line(Vector2(0, rr.end.y), rr.end, Game.BONE, 1.0)
	var lo := floori(cam_x) - VIEW_CELLS / 2 - 1
	for lane in range(1, rw.lanes):
		var y := rr.position.y + lane * _lane_h()
		for x in range(lo, lo + VIEW_CELLS + 3):
			if posmod(x, 2) == 0:
				draw_line(Vector2(_cell_pos(0, x).x + 3, y), Vector2(_cell_pos(0, x).x + CELL - 3, y), Color(Game.BONE, 0.5), 1.0)
	# Range bands from the active rig: contact, close, far.
	if waiting:
		var ax: int = active["x"]
		var band_cols := [[RoadWar.BAND_CONTACT, Color(Game.BLOOD, 0.22)], [RoadWar.BAND_CLOSE, Color(Game.ORANGE, 0.12)], [RoadWar.BAND_FAR, Color(Game.FIRE, 0.06)]]
		for bc in band_cols:
			var p0 := _cell_pos(0, ax - bc[0])
			draw_rect(Rect2(p0.x, rr.position.y, (bc[0] * 2 + 1) * CELL, rr.size.y), bc[1])
	for c in drive_cells():
		var p := _cell_pos(c.x, c.y)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(CELL - 2, _lane_h() - 2)), Color(Game.TEAL, 0.35))
	for k in rw.obstacles:
		var p := _cell_pos(k.x, k.y)
		if p.x < -CELL or p.x > size.x:
			continue
		_draw_obstacle(rw.obstacles[k], p)
	for r in rw.rigs:
		if r["status"] == "active":
			_draw_rig(r)
	if hover.x >= 0:
		var p := _cell_pos(hover.x, hover.y)
		draw_rect(Rect2(p, Vector2(CELL, _lane_h())), Game.BONE, false, 1.0)
	_draw_offscreen_markers(rr)
	Game.text(self, Vector2(4, 12), title, Game.FIRE, 9)
	Game.text(self, Vector2(400, 12), "Round %d" % rw.round_n, Game.BONE, 8)
	var lines: Array = rw.lines.slice(max(0, rw.lines.size() - 2))
	for i in lines.size():
		Game.text(self, Vector2(4, 152 + i * 9), lines[i], Game.BONE, 7)
	Game.panel(self, Rect2(2, 166, 236, 84))
	Game.panel(self, Rect2(242, 166, 236, 84))
	if not active.is_empty():
		_draw_info(active, Vector2(6, 177), "Turn" if waiting else "Moving")
		if waiting:
			var hint := "Drive: click a teal cell, or Stay." if stage == "drive" else "Act: Fire, Ram, Board or Evade."
			Game.text(self, Vector2(6, 246), hint, Game.FIRE, 7)
	if not target.is_empty() and target["status"] == "active":
		_draw_info(target, Vector2(246, 177), "Target")
		if waiting:
			var gap: int = abs(target["x"] - active["x"])
			var s := "%s.  Guns hit %d%%" % [RoadWar.band(gap).capitalize(), roundi(rw.gun_chance(active, target))]
			if rw.can_contact(active, target):
				s += "  Board odds %.1f" % rw.boarding_odds(active, target)
			Game.text(self, Vector2(246, 237), s, Game.FIRE, 7)
	if done:
		_draw_result()


func _draw_obstacle(kind: String, p: Vector2) -> void:
	var h := _lane_h()
	match kind:
		"pillar":
			draw_rect(Rect2(p + Vector2(5, 2), Vector2(8, h - 4)), Game.ASH.lightened(0.2))
		"pileup":
			draw_rect(Rect2(p + Vector2(1, 3), Vector2(CELL - 2, h - 6)), Game.RUST.darkened(0.4))
			draw_rect(Rect2(p + Vector2(4, 1), Vector2(9, 5)), Game.ASH)
		_:
			draw_rect(Rect2(p + Vector2(2, h / 2 - 3), Vector2(CELL - 4, 7)), Game.RUST.darkened(0.2))
			draw_rect(Rect2(p + Vector2(5, h / 2 - 5), Vector2(7, 3)), Game.ASH)


func _draw_rig(r: Dictionary) -> void:
	var p := _cell_pos(r["lane"], r["x"])
	if p.x < -CELL or p.x > size.x:
		return
	var h := _lane_h()
	var body := Rect2(p + Vector2(1, h / 2 - 4), Vector2(CELL - 2, 8))
	var col: Color = Game.STEEL if r["side"] == "party" else Game.RUST
	var trim: Color = Game.TEAL if r["side"] == "party" else Game.BLOOD
	if r == active:
		draw_rect(body.grow(2), Game.FIRE)
	if r == target:
		draw_rect(body.grow(2), Game.BONE, false, 1.0)
	# Dust plume behind (everyone drives forward, to the right), the body, a cab, wheels, gun mounts.
	draw_circle(body.get_center() + Vector2(-11, 2), 3.0, Color(Game.SAND, 0.35))
	draw_rect(body, col)
	draw_rect(body, trim, false, 1.0)
	draw_rect(Rect2(body.end.x - 6, body.position.y - 3, 5, 3), col.darkened(0.3))
	draw_rect(Rect2(body.position.x + 2, body.end.y - 1, 3, 2), Game.OIL)
	draw_rect(Rect2(body.end.x - 5, body.end.y - 1, 3, 2), Game.OIL)
	for g in r["guns"].size():
		draw_rect(Rect2(body.position.x + 5 + g * 4, body.position.y - 2, 2, 2), Game.CHROME)
	if r["flagship"]:
		draw_rect(Rect2(body.get_center().x - 1, body.position.y - 6, 1, 4), Game.BONE)
		draw_rect(Rect2(body.get_center().x, body.position.y - 6, 3, 2), Game.FIRE)
	if r["burning"] > 0:
		draw_circle(body.get_center() + Vector2(0, -5), 2.5, Game.ORANGE)
		draw_circle(body.get_center() + Vector2(0, -6), 1.3, Game.FIRE)
	if r["hooked"] > 0:
		draw_line(body.position, body.position + Vector2(-6, -3), Game.CHROME, 1.0)
	if r["evade"]:
		draw_line(body.position + Vector2(-3, 1), body.position + Vector2(-3, 7), Game.TEAL, 1.0)
	Game.bar(self, Rect2(p + Vector2(1, h / 2 - 8 - 3), Vector2(CELL - 2, 2)), r["durability"] / r["max_durability"], Game.FIRE if r["side"] == "party" else Game.BLOOD)
	if waiting and r["side"] == "enemy":
		var gap: int = abs(r["x"] - active["x"])
		if gap <= RoadWar.BAND_FAR:
			Game.text(self, p + Vector2(0, h / 2 + 11), "%d%%" % roundi(rw.gun_chance(active, r)), Game.FIRE, 6)


## Arrows at the screen edge for rigs out of view.
func _draw_offscreen_markers(rr: Rect2) -> void:
	for r in rw.rigs:
		if r["status"] != "active":
			continue
		var p := _cell_pos(r["lane"], r["x"])
		var y := p.y + _lane_h() / 2.0
		var col: Color = Game.TEAL if r["side"] == "party" else Game.BLOOD
		if p.x < -CELL:
			draw_colored_polygon(PackedVector2Array([Vector2(2, y), Vector2(8, y - 4), Vector2(8, y + 4)]), col)
		elif p.x > size.x:
			draw_colored_polygon(PackedVector2Array([Vector2(size.x - 2, y), Vector2(size.x - 8, y - 4), Vector2(size.x - 8, y + 4)]), col)


func _draw_info(r: Dictionary, pos: Vector2, label: String) -> void:
	var who: String = r["character"]["name"] if not r["character"].is_empty() else ""
	Game.text(self, pos, "%s: %s%s" % [label, r["name"], (" (%s)" % who) if who != "" else ""], Game.FIRE, 7)
	Game.text(self, pos + Vector2(0, 10), "Durability %d/%d  Armor %d" % [roundi(max(0.0, r["durability"])), roundi(r["max_durability"]), roundi(r["armor"])], Game.BONE, 7)
	Game.text(self, pos + Vector2(0, 19), "Speed %d  Handling %d  Ram %d" % [r["speed"], roundi(r["handling"]), roundi(r["ram"])], Game.BONE, 7)
	var guns: Array = r["guns"].map(func(g): return g["name"])
	Game.text(self, pos + Vector2(0, 28), "Crew %d  Guns %d/%d manned  Ammo %d" % [r["crew"], rw.manned_guns(r), guns.size(), r["ammo"]], Game.BONE, 7)
	if not guns.is_empty():
		Game.text(self, pos + Vector2(0, 37), ", ".join(guns), Color(Game.BONE, 0.75), 7)
	var st: PackedStringArray = []
	if r["burning"] > 0:
		st.append("burning")
	if r["hooked"] > 0:
		st.append("hooked")
	if r["evade"]:
		st.append("evading")
	if not st.is_empty():
		Game.text(self, pos + Vector2(0, 46), ", ".join(st), Game.ORANGE, 7)


func _draw_result() -> void:
	var r := Rect2(120, 30, 240, 102)
	Game.panel(self, r)
	var w: String = result["winner"]
	var head: String = {"party": "VICTORY", "enemy": "DEFEAT", "escaped": "GOT AWAY"}.get(w, "BROKE OFF")
	Game.text(self, r.position + Vector2(80, 20), head, Game.FIRE if w == "party" else Game.BLOOD, 14)
	Game.text(self, r.position + Vector2(12, 34), "%d rounds. Convoy Durability left: %d%%." % [result["rounds"], roundi(result["party_durability_share"] * 100)], Game.BONE, 7)
	Game.text(self, r.position + Vector2(12, 44), "Rigs lost: %d. Enemy rigs taken: %d." % [result["party_rigs_lost"], result["enemy_rigs_taken"]], Game.BONE, 7)
	if not auto_all:
		Game.text(self, r.position + Vector2(12, 60), "How did that fight feel? (for the playtest log)", Color(Game.BONE, 0.75), 7)
