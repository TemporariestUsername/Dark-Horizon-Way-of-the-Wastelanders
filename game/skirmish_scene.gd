## The playable skirmish. The battle itself is sim/battle/skirmish.gd: this scene draws it,
## animates what happened (moves, shots, hits, misses, the fallen) and turns clicks into the
## sim's player actions. Enemy turns are played by the same AI the balance bench uses.
##
## Controls: click a highlighted tile to move (once a turn), click an enemy in range to attack.
## Buttons: Defend, Skill, Auto (let the AI play this unit), End turn, Flee (the chance shown).
## Keys: D defend, S skill, A auto, Space end turn, F flee.
extends Control

const Game := preload("res://game/game.gd")
const Art := preload("res://game/art.gd")
const Characters := preload("res://sim/characters.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

const TILE := 20
const ORIGIN := Vector2(4, 26)
const PANEL := Rect2(328, 24, 150, 204)
const AI_DELAY := 0.45
const MOVE_TIME := 0.18
const MAX_ROUNDS := 30

var sk
var queue: Array = []
var active: Dictionary = {}
var waiting := false
var hover := Vector2i(-1, -1)
var target_skill: Dictionary = {}
var embedded := false
var done := false
var result := {}
var timer := 0.2
var title := ""
var btn := {}
var skill_menu: PopupMenu
var skill_list: Array = []
var auto_all := false           # the screenshot tool and tests can let the AI play everything
var log_info := {}              # what this fight is, for the playtest log
var actions := {}               # the player's actions by kind, for the playtest log
var player_turns := 0
var started_ms := 0

# Effects: where each unit is drawn (sliding toward its tile), flashes, lunges, popups, tracers.
var vis := {}                   # unit id -> Vector2 (pixel position of its tile's top-left)
var flash := {}                 # unit id -> seconds left
var lunge := {}                 # unit id -> [direction, seconds left]
var popups: Array = []          # {pos, text, col, t}
var tracers: Array = []         # {a, b, col, t, kind}
var puffs: Array = []           # {pos, t}
var hp_before := {}
var fx_seen := 0
var clock := 0.0


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	var nx: Dictionary = Game.next
	if nx.has("sim"):
		sk = nx["sim"]
		embedded = true
		title = nx.get("title", "Skirmish")
		log_info = nx.get("log", {"source": "journey"})
	else:
		var rng := RandomNumberGenerator.new()
		var seed := int(nx.get("seed", Time.get_ticks_usec()))
		rng.seed = seed
		var enc_id: String = nx.get("encounter", "raider_pack")
		var enc: Dictionary = Game.data.units["encounters"].filter(func(e): return e["id"] == enc_id)[0]
		var lvl := int(nx.get("level", enc["party_level"]))
		var party: Array = []
		for cl in nx.get("party", ["driver", "angel", "gunlugger"]):
			party.append(Characters.build_class(Game.data, cl, {"road": lvl, "trade": 1, "fight": lvl}, "party", rng))
		var enemies: Array = []
		var n := 0
		for uid in enc["units"]:
			for k in int(enc["units"][uid]):
				enemies.append(Characters.build_unit(Game.data, uid, "enemy", rng, n))
				n += 1
		sk = Skirmish.new()
		sk.setup(Game.data, party, enemies, rng)
		title = "%s · %s · party level %d" % [enc["name"], enc["rating"].capitalize(), lvl]
		log_info = {"source": "menu", "encounter": enc_id, "rating": enc["rating"], "level": lvl, "seed": seed}
	started_ms = Time.get_ticks_msec()
	fx_seen = sk.fx.size()
	for c in sk.units:
		vis[c["id"]] = _tile_px(c["pos"])
	var x := PANEL.position.x + 5
	var y := PANEL.end.y - 50
	btn["defend"] = Game.button(self, "Defend", Vector2(x, y), Vector2(68, 14), _on_defend)
	btn["skill"] = Game.button(self, "Skill", Vector2(x + 72, y), Vector2(68, 14), _on_skill)
	btn["auto"] = Game.button(self, "Auto", Vector2(x, y + 16), Vector2(68, 14), _on_auto)
	btn["end"] = Game.button(self, "End turn", Vector2(x + 72, y + 16), Vector2(68, 14), _on_end_turn)
	btn["flee"] = Game.button(self, "Flee", Vector2(x, y + 32), Vector2(140, 14), _on_flee)
	btn["continue"] = Game.button(self, "Continue", Vector2(200, 174), Vector2(80, 14), _on_continue)
	btn["continue"].visible = false
	skill_menu = PopupMenu.new()
	skill_menu.id_pressed.connect(_on_skill_chosen)
	add_child(skill_menu)
	_refresh_buttons()


# ---------------------------------------------------------------- the turn loop

func _process(delta: float) -> void:
	clock += delta
	_animate(delta)
	queue_redraw()
	if done or waiting:
		return
	timer -= delta
	if timer > 0.0:
		return
	step()


## Advances to the next unit's turn. Enemy (and auto) turns play out; a party unit waits for input.
## Mirrors Skirmish.run(): once the fight is decided the round's other turns are skipped,
## and the round still ends (so auto play here gives exactly the bench's result).
func step() -> void:
	if sk.party_fled:
		_finish()
		return
	if queue.is_empty():
		if sk.round_n > 0:
			_act(func(): sk.end_round())
		if sk.winner() != "" or sk.round_n >= MAX_ROUNDS:
			_finish()
			return
		queue = sk.start_round()
	var c: Dictionary = queue.pop_front()
	if c["down"] or c["fled"] or sk.winner() != "":
		return
	active = c
	timer = AI_DELAY
	var can_act: bool = _act(func(): return sk.begin_turn(c))
	if not can_act:
		return
	if c["side"] == "party" and not auto_all:
		waiting = true
		player_turns += 1
		target_skill = {}
	else:
		_act(func(): sk.ai_act(c))
	_refresh_buttons()


## Runs a sim call and turns what changed into effects. Returns the call's result.
func _act(f: Callable) -> Variant:
	hp_before.clear()
	for c in sk.units:
		hp_before[c["id"]] = [c["hp"], c["down"]]
	var r: Variant = f.call()
	_effects()
	return r


func _end_turn() -> void:
	waiting = false
	target_skill = {}
	timer = AI_DELAY
	_refresh_buttons()


func _finish() -> void:
	done = true
	waiting = false
	result = sk.finish()
	btn["continue"].visible = true
	if not auto_all:
		var rec := log_info.duplicate()
		rec.merge({"winner": result["winner"], "rounds": result["rounds"], "party_hp_share": snappedf(result["party_hp_share"], 0.01),
			"party_down": result["party_down"], "xp": result["xp"], "player_turns": player_turns, "actions": actions,
			"seconds": (Time.get_ticks_msec() - started_ms) / 1000})
		PlaytestLog.write("skirmish", rec)
		var about := log_info.duplicate()
		about.merge({"about": "skirmish", "winner": result["winner"]})
		PlaytestLog.feel_buttons(self, Vector2(129, 154), about)
	_refresh_buttons()


func _refresh_buttons() -> void:
	var can := waiting and not done
	for k in ["defend", "skill", "auto", "end", "flee"]:
		btn[k].disabled = not can
	if can:
		btn["skill"].disabled = sk.skills_for(active).is_empty()
		btn["flee"].text = "Flee (%d%%)" % roundi(sk.flee_chance())


# ---------------------------------------------------------------- effects

func _tile_px(t: Vector2i) -> Vector2:
	return ORIGIN + Vector2(t) * TILE


func _unit_by_id(id: String) -> Dictionary:
	for c in sk.units:
		if c["id"] == id:
			return c
	return {}


func _center(c: Dictionary) -> Vector2:
	return vis.get(c["id"], _tile_px(c["pos"])) + Vector2(TILE / 2.0, TILE / 2.0 - 4)


## A floating number or word. Ones landing on the same spot stack upward instead of overprinting.
func _popup(pos: Vector2, text: String, col: Color) -> void:
	for p in popups:
		if p["t"] < 0.3 and p["pos"].distance_to(pos) < 6.0:
			pos.y -= 8.0
	popups.append({"pos": pos, "text": text, "col": col, "t": 0.0})


## Damage numbers and flashes from HP changes; tracers, misses and Hum from the sim's fx list.
func _effects() -> void:
	for c in sk.units:
		var before: Array = hp_before.get(c["id"], [c["hp"], c["down"]])
		var d: float = c["hp"] - before[0]
		if d <= -0.5:
			_popup(_center(c) + Vector2(0, -10), str(roundi(-d)), Game.BONE)
			flash[c["id"]] = 0.15
		elif d >= 0.5:
			_popup(_center(c) + Vector2(0, -10), "+%d" % roundi(d), Game.TEAL.lightened(0.3))
		if c["down"] and not before[1]:
			puffs.append({"pos": _center(c) + Vector2(0, 6), "t": 0.0})
	while fx_seen < sk.fx.size():
		var e: Dictionary = sk.fx[fx_seen]
		fx_seen += 1
		var a := _unit_by_id(e["from"])
		var b := _unit_by_id(e["to"])
		if a.is_empty() or b.is_empty():
			continue
		var ranged: bool = a["weapon"]["range"] != "melee"
		match e["kind"]:
			"hit", "miss", "stun":
				if ranged:
					tracers.append({"a": _center(a) + Vector2(4 if a["side"] == "party" else -4, 0), "b": _center(b) + (Vector2.ZERO if e["kind"] != "miss" else Vector2(6, -6)), "col": Game.FIRE, "t": 0.0, "kind": "shot"})
				else:
					lunge[a["id"]] = [(_center(b) - _center(a)).normalized(), 0.16]
				if e["kind"] == "miss":
					_popup(_center(b) + Vector2(0, -12), "miss", Game.DIM)
				elif e["kind"] == "stun":
					_popup(_center(b) + Vector2(0, -12), "stunned", Game.FIRE)
			"hum":
				tracers.append({"a": _center(a), "b": _center(b), "col": Game.VIOLET, "t": 0.0, "kind": "hum"})


func _animate(delta: float) -> void:
	for c in sk.units:
		var goal := _tile_px(c["pos"])
		var v: Vector2 = vis.get(c["id"], goal)
		vis[c["id"]] = v.move_toward(goal, TILE / MOVE_TIME * delta * max(1.0, v.distance_to(goal) / TILE))
	for k in flash.keys():
		flash[k] -= delta
		if flash[k] <= 0.0:
			flash.erase(k)
	for k in lunge.keys():
		lunge[k][1] -= delta
		if lunge[k][1] <= 0.0:
			lunge.erase(k)
	for p in popups:
		p["t"] += delta
	popups = popups.filter(func(p): return p["t"] < 0.9)
	for t in tracers:
		t["t"] += delta
	tracers = tracers.filter(func(t): return t["t"] < (0.14 if t["kind"] == "shot" else 0.4))
	for p in puffs:
		p["t"] += delta
	puffs = puffs.filter(func(p): return p["t"] < 0.6)


# ---------------------------------------------------------------- input

func _tile_at(p: Vector2) -> Vector2i:
	var q := (p - ORIGIN) / TILE
	return Vector2i(floori(q.x), floori(q.y))


func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion:
		hover = _tile_at(ev.position)
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		click_tile(_tile_at(ev.position))


func _unhandled_key_input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed) or not waiting:
		return
	match ev.keycode:
		KEY_D: _on_defend()
		KEY_S: _on_skill()
		KEY_A: _on_auto()
		KEY_SPACE: _on_end_turn()
		KEY_F: _on_flee()


## A click on the grid: attack (or use the chosen skill on) an enemy in range, or move.
func click_tile(t: Vector2i) -> void:
	if not waiting:
		return
	var u := _unit_at(t)
	if not u.is_empty() and u["side"] == "enemy":
		if not target_skill.is_empty():
			if _act(func(): return sk.player_skill(active, target_skill, u)):
				_count("skill")
				_end_turn()
			return
		if _act(func(): return sk.player_attack(active, u)):
			_count("attack")
			_end_turn()
		return
	if u.is_empty() and sk.player_move(active, t):
		_count("move")


func _unit_at(t: Vector2i) -> Dictionary:
	for c in sk.units:
		if not c["down"] and not c["fled"] and c["pos"] == t:
			return c
	return {}


func _count(k: String) -> void:
	actions[k] = int(actions.get(k, 0)) + 1


func _on_end_turn() -> void:
	_count("pass")
	_end_turn()


func _on_defend() -> void:
	sk.player_defend(active)
	_count("defend")
	_end_turn()


func _on_auto() -> void:
	_act(func(): sk.ai_act(active))
	_count("auto")
	_end_turn()


func _on_flee() -> void:
	_count("flee" if sk.player_flee() else "flee_failed")
	_end_turn()


func _on_skill() -> void:
	skill_list = sk.skills_for(active)
	skill_menu.clear()
	for i in skill_list.size():
		skill_menu.add_item("%s (Grit %d)" % [skill_list[i]["name"], int(skill_list[i]["grit"])], i)
	skill_menu.position = Vector2i(get_global_transform_with_canvas() * Vector2(PANEL.position.x, 110))
	skill_menu.popup()


func _on_skill_chosen(i: int) -> void:
	var s: Dictionary = skill_list[i]
	var t: String = s["def"].get("target", "")
	if s["kind"] == "technique" and t in ["enemy", "enemy_area"]:
		target_skill = s   # the next enemy click uses it
		return
	if _act(func(): return sk.player_skill(active, s)):
		_count("skill")
		_end_turn()


func _on_continue() -> void:
	if embedded and Game.journey != null:
		Game.next = {"battle_result": result}
		get_tree().change_scene_to_file("res://game/journey_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://game/main_menu.tscn")


# ---------------------------------------------------------------- drawing

func _sprite(c: Dictionary) -> Texture2D:
	var key: String = c["class"]
	var tex: Texture2D = Art.unit(key)
	var kind := ""
	if c["down"]:
		kind = "down"
	elif flash.has(c["id"]):
		kind = "flash"
	elif c["side"] == "enemy":
		kind = "flip"
	return Art.variant(tex, kind, key) if kind != "" else tex


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("2a1f19"))
	# Title bar and the turn order.
	Game.text(self, Vector2(4, 17), title, Game.FIRE, "head")
	_draw_turn_strip()
	# The ground.
	var reach: Array = sk.reachable(active) if waiting and not active.get("moved", false) else []
	var in_range: Array = sk.targets_for(active) if waiting else []
	draw_rect(Rect2(ORIGIN - Vector2(1, 1), Vector2(sk.size) * TILE + Vector2(2, 2)), Game.OIL)
	for x in sk.size.x:
		for y in sk.size.y:
			var t := Vector2i(x, y)
			var p := _tile_px(t)
			draw_texture(Art.ground(int(Art.noise(x, y, 9) * 7.0)), p)
			draw_rect(Rect2(p, Vector2(TILE, 1)), Color(Game.OIL, 0.12))
			draw_rect(Rect2(p, Vector2(1, TILE)), Color(Game.OIL, 0.12))
			if reach.has(t):
				draw_rect(Rect2(p + Vector2(1, 1), Vector2(TILE - 1, TILE - 1)), Color(Game.TEAL, 0.35))
				draw_rect(Rect2(p + Vector2(1, 1), Vector2(TILE - 1, TILE - 1)), Color(Game.TEAL, 0.7), false, 1.0)
	for x in sk.size.x:
		for y in sk.size.y:
			if sk.cover.has(Vector2i(x, y)):
				draw_texture(Art.cover(int(Art.noise(x, y, 4) * 4.0)), _tile_px(Vector2i(x, y)) + Vector2(0, 2))
	if hover.x >= 0 and hover.y >= 0 and hover.x < sk.size.x and hover.y < sk.size.y:
		draw_rect(Rect2(_tile_px(hover), Vector2(TILE, TILE)), Color(Game.BONE, 0.8), false, 1.0)
	# Units, back to front.
	var order: Array = sk.units.filter(func(c): return not c["fled"])
	order.sort_custom(func(a, b): return vis[a["id"]].y < vis[b["id"]].y if vis[a["id"]].y != vis[b["id"]].y else (a["down"] and not b["down"]))
	for c in order:
		_draw_unit(c, in_range.has(c))
	for p in puffs:
		var k: float = p["t"] / 0.6
		for i in 5:
			var a := i * TAU / 5.0
			draw_rect(Rect2(p["pos"] + Vector2(cos(a), sin(a) * 0.5) * (3.0 + k * 9.0), Vector2(2, 2)), Color(Game.SAND.lightened(0.2), 1.0 - k))
	for t in tracers:
		if t["kind"] == "shot":
			draw_line(t["a"], t["b"], t["col"], 1.0)
			draw_rect(Rect2(t["b"] - Vector2(1, 1), Vector2(3, 3)), Game.BONE)
		else:
			var k: float = t["t"] / 0.4
			draw_arc(t["a"].lerp(t["b"], k), 3.0 + k * 4.0, 0, TAU, 12, Color(Game.VIOLET, 1.0 - k), 1.0)
	for p in popups:
		var k: float = p["t"] / 0.9
		var s: String = p["text"]
		Game.text_centered(self, p["pos"].x, p["pos"].y - k * 10.0, s, Color(p["col"], 1.0 - max(0.0, k - 0.6) * 2.5))
	# The side panel.
	Game.panel(self, PANEL)
	if not active.is_empty():
		_draw_card(active, Vector2(PANEL.position.x + 6, PANEL.position.y + 6), "Their turn" if not waiting else "Your turn")
	var h := _unit_at(hover)
	if not h.is_empty() and h != active:
		_draw_card(h, Vector2(PANEL.position.x + 6, PANEL.position.y + 78), "Target" if h["side"] == "enemy" else "Ally")
	if not target_skill.is_empty():
		Game.text(self, Vector2(PANEL.position.x + 6, PANEL.end.y - 56), "Pick a target: " + target_skill["name"], Game.FIRE)
	# The log.
	var lines: Array = sk.lines.slice(max(0, sk.lines.size() - 4))
	for i in lines.size():
		Game.text(self, Vector2(6, 239 + i * Game.LINE), lines[i], Game.BONE if i == lines.size() - 1 else Game.DIM)
	if done:
		_draw_result()


func _draw_turn_strip() -> void:
	var upcoming: Array = []
	if not active.is_empty() and not done:
		upcoming.append(active)
	for c in queue:
		if not c["down"] and not c["fled"]:
			upcoming.append(c)
	var x = 476.0 - min(upcoming.size(), 9) * 11
	Game.text(self, Vector2(x - 26, 15), "Next", Game.DIM)
	for i in min(upcoming.size(), 9):
		var c: Dictionary = upcoming[i]
		var r := Rect2(x + i * 11, 5, 10, 10)
		draw_rect(r, Game.OIL)
		draw_rect(r.grow(-1), Game.STEEL if c["side"] == "party" else Game.RUST.darkened(0.2))
		var tex := Art.unit(c["class"])
		draw_texture_rect_region(tex, Rect2(r.position + Vector2(1, 1), Vector2(8, 8)), Rect2(6, 1, 8, 8))
		if i == 0:
			draw_rect(r.grow(1), Game.FIRE, false, 1.0)


func _draw_unit(c: Dictionary, targetable: bool) -> void:
	var p: Vector2 = vis[c["id"]]
	if lunge.has(c["id"]):
		p += lunge[c["id"]][0] * 4.0 * sin(lunge[c["id"]][1] / 0.16 * PI)
	var tex := _sprite(c)
	var base := p + Vector2(TILE / 2.0, TILE - 2)
	if c["down"]:
		draw_texture(tex, (base - Vector2(tex.get_width() / 2.0, tex.get_height())).round())
		return
	# Shadow, the active marker, the sprite.
	draw_rect(Rect2(base + Vector2(-6, -1), Vector2(12, 2)), Color(Game.OIL, 0.45))
	if c == active and not done:
		var bob := roundf(sin(clock * 6.0))
		var tip := base + Vector2(0, -tex.get_height() - 4 + bob)
		draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-3, -3), tip + Vector2(3, -3)]), Game.FIRE)
		draw_rect(Rect2(base + Vector2(-7, -1), Vector2(14, 2)), Color(Game.FIRE, 0.5))
	draw_texture(tex, (base - Vector2(tex.get_width() / 2.0, tex.get_height())).round())
	if c["tags"].has("leader") or c["tags"].has("boss"):
		var top := base + Vector2(4, -tex.get_height())
		draw_rect(Rect2(top, Vector2(1, 5)), Game.BONE)
		draw_rect(Rect2(top + Vector2(1, 0), Vector2(3, 2)), Game.FIRE if c["side"] == "party" else Game.BLOOD)
	# HP over the head, statuses beside it.
	var bar_pos := base + Vector2(-7, -tex.get_height() - 3)
	Game.bar(self, Rect2(bar_pos, Vector2(14, 1)), c["hp"] / c["max_hp"], Game.TEAL.lightened(0.2) if c["side"] == "party" else Game.BLOOD.lightened(0.2))
	var sx := 16.0
	for s in c["statuses"].keys():
		var col: Color = {"stunned": Game.FIRE, "bleeding": Game.BLOOD, "hum_struck": Game.VIOLET, "petrified": Game.CHROME}.get(s, Game.BONE)
		draw_rect(Rect2(bar_pos + Vector2(sx, -1), Vector2(2, 2)), col)
		sx += 3
	if c["defending"]:
		draw_rect(Rect2(base + Vector2(6, -9), Vector2(3, 4)), Game.CHROME)
		draw_rect(Rect2(base + Vector2(6, -9), Vector2(3, 1)), Game.BONE)
	if targetable and waiting:
		var t := _tile_px(c["pos"])
		draw_rect(Rect2(t, Vector2(TILE, TILE)), Game.BLOOD.lightened(0.3), false, 1.0)
		var label := "%d%%" % roundi(sk.hit_chance(active, c))
		draw_rect(Rect2(t + Vector2(TILE / 2.0 - Game.text_width(label) / 2.0 - 2, TILE - 1), Vector2(Game.text_width(label) + 4, 8)), Color(Game.OIL, 0.8))
		Game.text_centered(self, t.x + TILE / 2.0, t.y + TILE + 5, label, Game.FIRE)


## A unit's card: portrait, name, HP and Grit bars, weapon, stats, statuses.
func _draw_card(c: Dictionary, pos: Vector2, label: String) -> void:
	Game.text(self, pos + Vector2(0, 6), label.to_upper(), Game.DIM)
	var frame := Rect2(pos + Vector2(0, 10), Vector2(22, 26))
	Game.panel(self, frame, "card")
	var tex := Art.unit(c["class"])
	if c["side"] == "enemy":
		tex = Art.variant(tex, "flip", c["class"])
	draw_texture(tex, frame.position + Vector2(2, 2))
	var tx := pos.x + 26
	Game.text(self, Vector2(tx, pos.y + 18), c["name"], Game.FIRE if c["side"] == "party" else Game.BLOOD.lightened(0.35), "body", 112)
	draw_texture(Art.icon("hp"), Vector2(tx, pos.y + 22))
	Game.bar(self, Rect2(tx + 9, pos.y + 24, 60, 3), c["hp"] / c["max_hp"], Game.BLOOD.lightened(0.2))
	Game.text(self, Vector2(tx + 73, pos.y + 29), "%d/%d" % [roundi(c["hp"]), roundi(c["max_hp"])])
	draw_texture(Art.icon("grit"), Vector2(tx, pos.y + 31))
	Game.bar(self, Rect2(tx + 9, pos.y + 33, 60, 3), c["grit"] / max(c["max_grit"], 1.0), Game.FIRE)
	Game.text(self, Vector2(tx + 73, pos.y + 38), "%d" % roundi(c["grit"]))
	var ammo := ("  ·  ammo %d" % c["ammo"]) if int(c["weapon"]["ammo"]) > 0 else ""
	Game.text(self, pos + Vector2(0, 48), "%s, %s%s" % [c["weapon"]["name"], c["weapon"]["range"], ammo], Game.BONE)
	Game.text(self, pos + Vector2(0, 57), "Attack %d   Defense %d   Speed %d" % [roundi(Characters.attack_value(c)), roundi(c["defense"]), roundi(c["speed"])], Game.DIM)
	var st: Array = c["statuses"].keys().map(func(s): return String(s).replace("_", " "))
	if not st.is_empty():
		Game.text(self, pos + Vector2(0, 66), ", ".join(st).capitalize(), Game.ORANGE)


func _draw_result() -> void:
	var r := Rect2(120, 76, 240, 118)
	draw_rect(Rect2(Vector2.ZERO, size), Color(Game.OIL, 0.45))
	Game.panel(self, r)
	var w: String = result["winner"]
	var head: String = {"party": "VICTORY", "enemy": "DEFEAT", "fled": "GOT AWAY"}.get(w, "STALEMATE")
	Game.text_centered(self, r.get_center().x, r.position.y + 30, head, Game.FIRE if w == "party" else Game.BLOOD.lightened(0.3), "title")
	Game.text_centered(self, r.get_center().x, r.position.y + 50, "%d rounds  ·  party HP left %d%%  ·  Fight XP %d" % [result["rounds"], roundi(result["party_hp_share"] * 100), result["xp"]], Game.BONE)
	if not auto_all:
		Game.text_centered(self, r.get_center().x, r.position.y + 72, "How did that fight feel?", Game.DIM)
