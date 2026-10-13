## The playable road war. The battle is sim/battle/road_war.gd; this scene draws the road
## around the party's convoy, animates what happened (driving, gunfire, rams, boarding,
## wrecks) and turns clicks into the sim's actions.
##
## A party rig's turn has two steps: drive (click a teal cell, or Stay), then act (Fire,
## Ram, Board or Evade). Click an enemy rig to target it. Auto plays this rig's whole turn
## with the AI; Run makes the whole convoy run for it.
## Keys: Space stay, F fire, R ram, B board, E evade, A auto.
extends Control

const Game := preload("res://game/game.gd")
const Art := preload("res://game/art.gd")
const Characters := preload("res://sim/characters.gd")
const RoadWar := preload("res://sim/battle/road_war.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

const CELL := 26
const ROAD_TOP := 34.0
const ROAD_H := 110.0
const AI_DELAY := 0.5
const MAX_ROUNDS := 30
const SCROLL := 60.0            # how fast the road rolls by (pixels a second)

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

# Effects.
var vis := {}                   # rig id -> Vector2(x along the road, lane), sliding to the real one
var flash := {}                 # rig id -> seconds left
var shake := {}                 # rig id -> seconds left
var popups: Array = []          # {pos, text, col, t}
var tracers: Array = []         # {a, b, t}
var sparks: Array = []          # {pos, vel, t, col}
var dust: Array = []            # {pos, t, size}
var dur_before := {}
var fx_seen := 0
var clock := 0.0
var dust_timer := 0.0


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED   # the asphalt tiles
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
		title = "%s · %s · party level %d" % [cv["name"], cv["rating"].capitalize(), lvl]
		log_info = {"source": "menu", "convoy": cv_id, "rating": cv["rating"], "level": lvl, "seed": seed}
	started_ms = Time.get_ticks_msec()
	fx_seen = rw.fx.size()
	for r in rw.rigs:
		vis[r["id"]] = Vector2(r["x"], r["lane"])
	cam_x = _party_center()
	var labels := [["Stay", _on_stay], ["Fire", _on_fire], ["Ram", _on_ram], ["Board", _on_board], ["Evade", _on_evade], ["Auto", _on_auto], ["Run", _on_run]]
	for i in labels.size():
		btn[labels[i][0]] = Game.button(self, labels[i][0], Vector2(4 + i * 68, 253), Vector2(64, 14), labels[i][1])
	btn["continue"] = Game.button(self, "Continue", Vector2(200, 122), Vector2(80, 14), _on_continue)
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
	clock += delta
	var goal: float = float(active["x"]) if waiting else _party_center()
	cam_x = lerpf(cam_x, goal, clampf(delta * 3.0, 0.0, 1.0))
	_animate(delta)
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
			_act(func(): rw.end_round())
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
		_act(func(): rw.ai_turn(r))
	_refresh_buttons()


## Runs a sim call and turns what changed into effects. Returns the call's result.
func _act(f: Callable) -> Variant:
	dur_before.clear()
	for r in rw.rigs:
		dur_before[r["id"]] = [r["durability"], r["status"]]
	var res: Variant = f.call()
	_effects()
	return res


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
		PlaytestLog.feel_buttons(self, Vector2(129, 102), about)
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


# ---------------------------------------------------------------- effects

func _rig_by_id(id: String) -> Dictionary:
	for r in rw.rigs:
		if r["id"] == id:
			return r
	return {}


## Where a rig's sprite is centered on screen (from its sliding position).
func _rig_center(r: Dictionary) -> Vector2:
	var v: Vector2 = vis.get(r["id"], Vector2(r["x"], r["lane"]))
	var rr := _road_rect()
	return Vector2(size.x / 2.0 + (v.x - cam_x) * CELL, rr.position.y + (v.y + 0.5) * _lane_h())


func _popup(pos: Vector2, text: String, col: Color) -> void:
	for p in popups:
		if p["t"] < 0.3 and p["pos"].distance_to(pos) < 8.0:
			pos.y -= 8.0
	popups.append({"pos": pos, "text": text, "col": col, "t": 0.0})


func _burst(pos: Vector2, col: Color, n: int, speed: float) -> void:
	for i in n:
		var a := Art.noise(i, sparks.size(), int(clock * 100.0)) * TAU
		sparks.append({"pos": pos, "vel": Vector2(cos(a), sin(a)) * speed * (0.5 + Art.noise(i, 3, sparks.size())), "t": 0.0, "col": col})


func _effects() -> void:
	for r in rw.rigs:
		var before: Array = dur_before.get(r["id"], [r["durability"], r["status"]])
		var d: float = r["durability"] - before[0]
		if d <= -0.5:
			_popup(_rig_center(r) + Vector2(0, -12), str(roundi(-d)), Game.BONE)
			flash[r["id"]] = 0.12
		if r["status"] != before[1]:
			match r["status"]:
				"wrecked":
					_popup(_rig_center(r) + Vector2(0, -20), "WRECKED", Game.ORANGE)
					_burst(_rig_center(r), Game.FIRE, 14, 40.0)
				"taken":
					_popup(_rig_center(r) + Vector2(0, -20), "TAKEN", Game.TEAL.lightened(0.3))
				"gone":
					_popup(_rig_center(r) + Vector2(0, -20), "breaks off", Game.DIM)
	while fx_seen < rw.fx.size():
		var e: Dictionary = rw.fx[fx_seen]
		fx_seen += 1
		var a := _rig_by_id(e["from"])
		var b := _rig_by_id(e["to"])
		if a.is_empty() or b.is_empty():
			continue
		var muzzle := _rig_center(a) + Vector2(6, -7)
		match e["kind"]:
			"shot", "miss":
				var hit_at := _rig_center(b) + (Vector2(0, -2) if e["kind"] == "shot" else Vector2(8, -14))
				tracers.append({"a": muzzle, "b": hit_at, "t": 0.0})
				_burst(muzzle, Game.FIRE, 3, 20.0)
				if e["kind"] == "shot":
					_burst(hit_at, Game.CHROME, 4, 30.0)
				else:
					_popup(_rig_center(b) + Vector2(0, -12), "miss", Game.DIM)
			"ram":
				shake[a["id"]] = 0.25
				shake[b["id"]] = 0.25
				_burst((_rig_center(a) + _rig_center(b)) / 2.0, Game.FIRE, 12, 50.0)
				_popup((_rig_center(a) + _rig_center(b)) / 2.0 + Vector2(0, -16), "RAM", Game.FIRE)
			"board":
				_popup(_rig_center(b) + Vector2(0, -22), "BOARDERS", Game.FIRE)


func _animate(delta: float) -> void:
	for r in rw.rigs:
		var goal := Vector2(r["x"], r["lane"])
		var v: Vector2 = vis.get(r["id"], goal)
		vis[r["id"]] = v.move_toward(goal, delta * max(6.0, v.distance_to(goal) * 4.0))
	for dct in [flash, shake]:
		for k in dct.keys():
			dct[k] -= delta
			if dct[k] <= 0.0:
				dct.erase(k)
	for p in popups:
		p["t"] += delta
	popups = popups.filter(func(p): return p["t"] < 0.9)
	for t in tracers:
		t["t"] += delta
	tracers = tracers.filter(func(t): return t["t"] < 0.1)
	for s in sparks:
		s["t"] += delta
		s["pos"] += s["vel"] * delta
		s["vel"] *= 0.9
	sparks = sparks.filter(func(s): return s["t"] < 0.4)
	# Dust behind every moving rig, and smoke off the burning and the wrecked.
	dust_timer -= delta
	if dust_timer <= 0.0:
		dust_timer = 0.08
		for r in rw.rigs:
			var c := _rig_center(r)
			if r["status"] == "active":
				var w := Art.rig(r["frame"], r["side"], r["crew_type"]).get_width()
				dust.append({"pos": c + Vector2(-w / 2.0, 6), "t": 0.0, "size": 2.0, "col": Game.SAND, "vel": Vector2(-SCROLL * 0.6, -4)})
				if r["burning"] > 0:
					dust.append({"pos": c + Vector2(0, -8), "t": 0.0, "size": 2.0, "col": Game.ASH, "vel": Vector2(-SCROLL * 0.4, -14)})
			elif r["status"] == "wrecked":
				dust.append({"pos": c + Vector2(0, -6), "t": 0.0, "size": 3.0, "col": Game.OIL.lightened(0.15), "vel": Vector2(-SCROLL * 0.2, -16)})
	for d in dust:
		d["t"] += delta
		d["pos"] += d["vel"] * delta
	dust = dust.filter(func(d): return d["t"] < 0.8)


# ---------------------------------------------------------------- input

func _lane_h() -> float:
	return minf(24.0, ROAD_H / rw.lanes)


func _road_rect() -> Rect2:
	var h = _lane_h() * rw.lanes
	return Rect2(0, ROAD_TOP + roundf((ROAD_H - h) / 2.0), size.x, h)


## Screen position of the top-left of road cell (lane, x).
func _cell_pos(lane: int, x: float) -> Vector2:
	var rr := _road_rect()
	return Vector2(roundf(size.x / 2.0 + (x - cam_x) * CELL - CELL / 2.0), rr.position.y + lane * _lane_h())


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
		_act(func(): rw.player_drive(active, c.y - active["x"], c.x - active["lane"]))
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
	_act(func(): rw.player_fire(active, target))
	_count("fire")
	_end_turn()


func _on_ram() -> void:
	if _act(func(): return rw.player_ram(active, target)):
		_count("ram")
		_end_turn()


func _on_board() -> void:
	if _act(func(): return rw.player_board(active, target)):
		_count("board")
		_end_turn()


func _on_evade() -> void:
	rw.player_evade(active)
	_count("evade")
	_end_turn()


func _on_auto() -> void:
	_act(func(): rw.ai_turn(active))
	_count("auto")
	_end_turn()


func _on_run() -> void:
	rw.player_run()
	_count("run")
	_act(func(): rw.ai_turn(active))
	_end_turn()


func _on_continue() -> void:
	if embedded and Game.journey != null:
		Game.next = {"battle_result": result}
		get_tree().change_scene_to_file("res://game/journey_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://game/main_menu.tscn")


# ---------------------------------------------------------------- drawing

func _rig_tex(r: Dictionary) -> Texture2D:
	var tex := Art.rig(r["frame"], r["side"] if r["status"] != "taken" else "party", r["crew_type"])
	var key := "%s|%s|%s" % [r["frame"], r["side"], r["crew_type"]]
	if r["status"] == "wrecked":
		return Art.variant(tex, "dark", key)
	if flash.has(r["id"]):
		return Art.variant(tex, "flash", key)
	return tex


func _draw() -> void:
	var rr := _road_rect()
	# Desert, scrub, and the road rolling by.
	draw_rect(Rect2(Vector2.ZERO, size), Color("8a4a1c"))
	var roll := clock * SCROLL + cam_x * CELL
	for i in 60:
		var sx := fposmod(i * 47.0 - roll * 0.9, size.x + 60.0) - 30.0
		var sy := 24.0 + Art.noise(i, 1, 2) * (rr.position.y - 28.0)
		draw_rect(Rect2(sx, sy, 2 + (i % 3), 2), Color("5a2e14"))
		var sy2 := rr.end.y + 4.0 + Art.noise(i, 2, 2) * 20.0
		draw_rect(Rect2(fposmod(sx + 23.0, size.x + 60.0) - 30.0, sy2, 2 + (i % 2), 2), Color("5a2e14"))
	draw_rect(Rect2(0, rr.position.y - 5, size.x, 5), Color("a8682c"))
	draw_rect(Rect2(0, rr.end.y, size.x, 5), Color("a8682c"))
	var tex := Art.asphalt()
	var off := fposmod(roll, 48.0)
	draw_texture_rect_region(tex, rr, Rect2(off, 0, rr.size.x, rr.size.y))
	draw_rect(Rect2(0, rr.position.y, size.x, 1), Game.BONE)
	draw_rect(Rect2(0, rr.end.y - 1, size.x, 1), Game.BONE)
	for lane in range(1, rw.lanes):
		var y := roundf(rr.position.y + lane * _lane_h())
		var x0 := -fposmod(roll, 26.0)
		while x0 < size.x:
			draw_rect(Rect2(x0, y, 12, 1), Color(Game.BONE, 0.75))
			x0 += 26.0
	# Range bands from the active rig, and where it can drive.
	if waiting:
		var ax: int = active["x"]
		for bc in [[RoadWar.BAND_FAR, Color(Game.FIRE, 0.05), "far"], [RoadWar.BAND_CLOSE, Color(Game.ORANGE, 0.07), "close"], [RoadWar.BAND_CONTACT, Color(Game.BLOOD, 0.18), "contact"]]:
			var p0 := _cell_pos(0, ax - bc[0])
			draw_rect(Rect2(p0.x, rr.position.y, (bc[0] * 2 + 1) * CELL, rr.size.y), bc[1])
			Game.text(self, Vector2(_cell_pos(0, ax + bc[0]).x + 3, rr.position.y - 7), bc[2], Color(Game.BONE, 0.6))
	for c in drive_cells():
		var p := _cell_pos(c.x, c.y)
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(CELL - 2, _lane_h() - 2)), Color(Game.TEAL, 0.3))
		draw_rect(Rect2(p + Vector2(1, 1), Vector2(CELL - 2, _lane_h() - 2)), Color(Game.TEAL, 0.6), false, 1.0)
	# Wrecks in the lanes.
	for k in rw.obstacles:
		var p := _cell_pos(k.x, k.y)
		if p.x < -CELL or p.x > size.x:
			continue
		var ob := Art.obstacle(rw.obstacles[k])
		draw_texture(ob, (p + Vector2(CELL / 2.0 - ob.get_width() / 2.0, _lane_h() - ob.get_height() - 1)).round())
	if hover.x >= 0:
		var hp := _cell_pos(hover.x, hover.y)
		draw_rect(Rect2(hp, Vector2(CELL, _lane_h())), Game.BONE, false, 1.0)
	for d in dust:
		var k: float = d["t"] / 0.8
		draw_rect(Rect2(d["pos"], Vector2.ONE * (d["size"] + k * 3.0)), Color(d["col"], 0.5 * (1.0 - k)))
	# Rigs, top lane first.
	var order: Array = rw.rigs.filter(func(r): return r["status"] in ["active", "wrecked", "taken"])
	order.sort_custom(func(a, b): return vis[a["id"]].y < vis[b["id"]].y)
	for r in order:
		_draw_rig(r)
	for t in tracers:
		draw_line(t["a"], t["b"], Game.FIRE, 1.0)
	for s in sparks:
		draw_rect(Rect2(s["pos"], Vector2(1, 1)), Color(s["col"], 1.0 - s["t"] / 0.4))
	for p in popups:
		var k: float = p["t"] / 0.9
		Game.text_centered(self, p["pos"].x, p["pos"].y - k * 10.0, p["text"], Color(p["col"], 1.0 - max(0.0, k - 0.6) * 2.5))
	_draw_offscreen_markers(rr)
	# Header, log and panels.
	draw_rect(Rect2(0, 0, size.x, 22), Color("2a1f19"))
	Game.text(self, Vector2(4, 17), title, Game.FIRE, "head")
	Game.text(self, Vector2(422, 15), "Round %d" % rw.round_n, Game.BONE)
	draw_rect(Rect2(0, 150, size.x, 120), Color("2a1f19"))
	var lines: Array = rw.lines.slice(max(0, rw.lines.size() - 2))
	for i in lines.size():
		Game.text(self, Vector2(6, 160 + i * Game.LINE), lines[i], Game.BONE if i == lines.size() - 1 else Game.DIM)
	Game.panel(self, Rect2(2, 172, 236, 78))
	Game.panel(self, Rect2(242, 172, 236, 78))
	if not active.is_empty():
		_draw_card(active, Vector2(8, 178), "Your turn" if waiting else "Moving")
		if waiting:
			var hint := "Drive: click a teal cell, or Stay." if stage == "drive" else "Act: Fire, Ram, Board or Evade."
			Game.text(self, Vector2(8, 245), hint, Game.FIRE)
	if not target.is_empty() and target["status"] == "active":
		_draw_card(target, Vector2(248, 178), "Target")
		if waiting:
			var gap: int = abs(target["x"] - active["x"])
			var s := "%s range  ·  guns hit %d%%" % [RoadWar.band(gap).capitalize(), roundi(rw.gun_chance(active, target))]
			if rw.can_contact(active, target):
				s += "  ·  board odds %.1f" % rw.boarding_odds(active, target)
			Game.text(self, Vector2(248, 245), s, Game.FIRE)
	if done:
		_draw_result()


func _draw_rig(r: Dictionary) -> void:
	var c := _rig_center(r)
	if c.x < -60 or c.x > size.x + 60:
		return
	var tex := _rig_tex(r)
	var bounce := 0.0
	if r["status"] == "active":
		bounce = 1.0 if sin(clock * 14.0 + r["id"].length() * 1.7) > 0.6 else 0.0
	var jolt := Vector2.ZERO
	if shake.has(r["id"]):
		jolt = Vector2(roundf(sin(clock * 90.0) * 2.0), 0)
	var bottom := c.y + _lane_h() / 2.0 - 2.0
	var pos := Vector2(roundf(c.x - tex.get_width() / 2.0), roundf(bottom - tex.get_height() - bounce)) + jolt
	draw_rect(Rect2(pos.x + 2, bottom - 1, tex.get_width() - 4, 2), Color(Game.OIL, 0.4))
	if r == active and not done:
		draw_rect(Rect2(pos.x - 1, bottom, tex.get_width() + 2, 1), Game.FIRE)
		var tip := Vector2(c.x, pos.y - 3 + roundf(sin(clock * 6.0)))
		draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-3, -3), tip + Vector2(3, -3)]), Game.FIRE)
	if r == target and r["status"] == "active":
		var tr := Rect2(pos - Vector2(2, 2), tex.get_size() + Vector2(4, 4))
		for corner in [tr.position, Vector2(tr.end.x - 3, tr.position.y), Vector2(tr.position.x, tr.end.y - 3), tr.end - Vector2(3, 3)]:
			draw_rect(Rect2(corner, Vector2(3, 3)), Game.BLOOD.lightened(0.3), false, 1.0)
	draw_texture(tex, pos)
	if r["status"] == "wrecked":
		var f := pos + Vector2(tex.get_width() / 2.0, 2)
		draw_rect(Rect2(f + Vector2(-2, -2 - roundf(sin(clock * 20.0))), Vector2(4, 3)), Game.ORANGE)
		draw_rect(Rect2(f + Vector2(-1, -3), Vector2(2, 2)), Game.FIRE)
		return
	if r["status"] == "taken":
		draw_rect(Rect2(pos + Vector2(tex.get_width() - 6, -6), Vector2(1, 6)), Game.BONE)
		draw_rect(Rect2(pos + Vector2(tex.get_width() - 5, -6), Vector2(4, 2)), Game.TEAL)
		return
	if r["burning"] > 0:
		var f := pos + Vector2(tex.get_width() / 2.0, 1)
		draw_rect(Rect2(f + Vector2(-2, -2 - roundf(sin(clock * 24.0))), Vector2(4, 3)), Game.ORANGE)
		draw_rect(Rect2(f + Vector2(-1, -3), Vector2(2, 2)), Game.FIRE)
	if r["evade"]:
		draw_rect(Rect2(pos + Vector2(-4, 4), Vector2(2, 1)), Game.TEAL)
		draw_rect(Rect2(pos + Vector2(-6, 7), Vector2(3, 1)), Game.TEAL)
	Game.bar(self, Rect2(c.x - 9, pos.y - 4, 18, 1), r["durability"] / r["max_durability"], Game.TEAL.lightened(0.2) if r["side"] == "party" else Game.BLOOD.lightened(0.2))
	if waiting and r["side"] == "enemy" and abs(r["x"] - active["x"]) <= RoadWar.BAND_FAR:
		var label := "%d%%" % roundi(rw.gun_chance(active, r))
		var lx := pos.x + tex.get_width() + 3
		draw_rect(Rect2(lx - 1, c.y - 5, Game.text_width(label) + 3, 8), Color(Game.OIL, 0.8))
		Game.text(self, Vector2(lx, c.y + 1), label, Game.FIRE)


## Arrows at the screen edge for rigs out of view.
func _draw_offscreen_markers(rr: Rect2) -> void:
	for r in rw.rigs:
		if r["status"] != "active":
			continue
		var c := _rig_center(r)
		var col: Color = Game.TEAL if r["side"] == "party" else Game.BLOOD.lightened(0.2)
		if c.x < -20:
			draw_colored_polygon(PackedVector2Array([Vector2(2, c.y), Vector2(8, c.y - 4), Vector2(8, c.y + 4)]), col)
		elif c.x > size.x + 20:
			draw_colored_polygon(PackedVector2Array([Vector2(size.x - 2, c.y), Vector2(size.x - 8, c.y - 4), Vector2(size.x - 8, c.y + 4)]), col)


## A rig's card: its sprite, name and driver, Durability, and its numbers.
func _draw_card(r: Dictionary, pos: Vector2, label: String) -> void:
	var tex := Art.rig(r["frame"], r["side"], r["crew_type"])
	Game.text(self, pos + Vector2(0, 5), label.to_upper(), Game.DIM)
	var who: String = r["character"]["name"] if not r["character"].is_empty() else ""
	Game.text(self, pos + Vector2(0, 15), r["name"] + ((" · " + who) if who != "" else ""), Game.FIRE if r["side"] == "party" else Game.BLOOD.lightened(0.35))
	draw_texture(tex, pos + Vector2(224 - tex.get_width() - 6, 2))
	Game.bar(self, Rect2(pos + Vector2(0, 20), Vector2(120, 3)), max(0.0, r["durability"]) / r["max_durability"], Game.TEAL.lightened(0.2) if r["side"] == "party" else Game.BLOOD.lightened(0.2))
	Game.text(self, pos + Vector2(124, 25), "%d/%d" % [roundi(max(0.0, r["durability"])), roundi(r["max_durability"])])
	Game.text(self, pos + Vector2(0, 35), "Armor %d   Speed %d   Handling %d   Ram %d" % [roundi(r["armor"]), r["speed"], roundi(r["handling"]), roundi(r["ram"])], Game.BONE)
	var guns: Array = r["guns"].map(func(g): return g["name"])
	Game.text(self, pos + Vector2(0, 44), "Crew %d   Guns %d/%d manned   Ammo %d" % [r["crew"], rw.manned_guns(r), guns.size(), r["ammo"]], Game.DIM)
	var st: PackedStringArray = []
	if r["burning"] > 0:
		st.append("burning")
	if r["hooked"] > 0:
		st.append("hooked")
	if r["evade"]:
		st.append("evading")
	if not st.is_empty():
		Game.text(self, pos + Vector2(0, 53), ", ".join(st).capitalize(), Game.ORANGE)
	elif not guns.is_empty():
		Game.text(self, pos + Vector2(0, 53), ", ".join(guns), Game.DIM)


func _draw_result() -> void:
	var r := Rect2(120, 34, 240, 108)
	draw_rect(Rect2(Vector2.ZERO, size), Color(Game.OIL, 0.45))
	Game.panel(self, r)
	var w: String = result["winner"]
	var head: String = {"party": "VICTORY", "enemy": "DEFEAT", "escaped": "GOT AWAY"}.get(w, "BROKE OFF")
	Game.text_centered(self, r.get_center().x, r.position.y + 30, head, Game.FIRE if w == "party" else Game.BLOOD.lightened(0.3), "title")
	Game.text_centered(self, r.get_center().x, r.position.y + 46, "%d rounds  ·  convoy Durability left %d%%" % [result["rounds"], roundi(result["party_durability_share"] * 100)], Game.BONE)
	Game.text_centered(self, r.get_center().x, r.position.y + 55, "Rigs lost %d  ·  enemy rigs taken %d" % [result["party_rigs_lost"], result["enemy_rigs_taken"]], Game.BONE)
	if not auto_all:
		Game.text_centered(self, r.get_center().x, r.position.y + 64, "How did that fight feel?", Game.DIM)
