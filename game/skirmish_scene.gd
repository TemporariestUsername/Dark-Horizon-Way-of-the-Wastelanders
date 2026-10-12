## The playable skirmish (M2 placeholder art). The battle itself is sim/battle/skirmish.gd:
## this scene only draws it and turns clicks into the sim's player actions. Enemy turns are
## played by the same AI the balance bench uses.
##
## Controls: click a highlighted tile to move (once a turn), click an enemy in range to attack.
## Buttons: Defend, Skill, Auto (let the AI play this unit), End turn, Flee (the chance shown).
## Keys: D defend, S skill, A auto, Space end turn, F flee.
extends Control

const Game := preload("res://game/game.gd")
const Characters := preload("res://sim/characters.gd")
const Skirmish := preload("res://sim/battle/skirmish.gd")

const TILE := 21
const ORIGIN := Vector2(4, 22)
const PANEL := Rect2(344, 22, 132, 210)
const AI_DELAY := 0.3
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


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	var nx: Dictionary = Game.next
	if nx.has("sim"):
		sk = nx["sim"]
		embedded = true
		title = nx.get("title", "Skirmish")
	else:
		var rng := RandomNumberGenerator.new()
		rng.seed = int(nx.get("seed", Time.get_ticks_usec()))
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
		title = "%s (%s, party level %d)" % [enc["name"], enc["rating"], lvl]
	var x := PANEL.position.x + 4
	var y := 168.0
	btn["defend"] = Game.button(self, "Defend", Vector2(x, y), Vector2(61, 13), _on_defend)
	btn["skill"] = Game.button(self, "Skill", Vector2(x + 63, y), Vector2(61, 13), _on_skill)
	btn["auto"] = Game.button(self, "Auto", Vector2(x, y + 16), Vector2(61, 13), _on_auto)
	btn["end"] = Game.button(self, "End turn", Vector2(x + 63, y + 16), Vector2(61, 13), _end_turn)
	btn["flee"] = Game.button(self, "Flee", Vector2(x, y + 32), Vector2(124, 13), _on_flee)
	btn["continue"] = Game.button(self, "Continue", Vector2(200, 166), Vector2(80, 14), _on_continue)
	btn["continue"].visible = false
	skill_menu = PopupMenu.new()
	skill_menu.id_pressed.connect(_on_skill_chosen)
	add_child(skill_menu)
	_refresh_buttons()


# ---------------------------------------------------------------- the turn loop

func _process(delta: float) -> void:
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
			sk.end_round()
		if sk.winner() != "" or sk.round_n >= MAX_ROUNDS:
			_finish()
			return
		queue = sk.start_round()
	var c: Dictionary = queue.pop_front()
	if c["down"] or c["fled"] or sk.winner() != "":
		return
	active = c
	timer = AI_DELAY
	if not sk.begin_turn(c):
		queue_redraw()
		return
	if c["side"] == "party" and not auto_all:
		waiting = true
		target_skill = {}
	else:
		sk.ai_act(c)
	_refresh_buttons()
	queue_redraw()


func _end_turn() -> void:
	waiting = false
	target_skill = {}
	timer = AI_DELAY
	_refresh_buttons()
	queue_redraw()


func _finish() -> void:
	done = true
	waiting = false
	result = sk.finish()
	btn["continue"].visible = true
	_refresh_buttons()
	queue_redraw()


func _refresh_buttons() -> void:
	var can := waiting and not done
	for k in ["defend", "skill", "auto", "end", "flee"]:
		btn[k].disabled = not can
	if can:
		btn["skill"].disabled = sk.skills_for(active).is_empty()
		btn["flee"].text = "Flee (%d%%)" % roundi(sk.flee_chance())


# ---------------------------------------------------------------- input

func _tile_at(p: Vector2) -> Vector2i:
	var q := (p - ORIGIN) / TILE
	return Vector2i(floori(q.x), floori(q.y))


func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion:
		hover = _tile_at(ev.position)
		queue_redraw()
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		click_tile(_tile_at(ev.position))


func _unhandled_key_input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed) or not waiting:
		return
	match ev.keycode:
		KEY_D: _on_defend()
		KEY_S: _on_skill()
		KEY_A: _on_auto()
		KEY_SPACE: _end_turn()
		KEY_F: _on_flee()


## A click on the grid: attack (or use the chosen skill on) an enemy in range, or move.
func click_tile(t: Vector2i) -> void:
	if not waiting:
		return
	var u := _unit_at(t)
	if not u.is_empty() and u["side"] == "enemy":
		if not target_skill.is_empty():
			if sk.player_skill(active, target_skill, u):
				_end_turn()
			return
		if sk.player_attack(active, u):
			_end_turn()
		return
	if u.is_empty() and sk.player_move(active, t):
		queue_redraw()


func _unit_at(t: Vector2i) -> Dictionary:
	for c in sk.units:
		if not c["down"] and not c["fled"] and c["pos"] == t:
			return c
	return {}


func _on_defend() -> void:
	sk.player_defend(active)
	_end_turn()


func _on_auto() -> void:
	sk.ai_act(active)
	_end_turn()


func _on_flee() -> void:
	sk.player_flee()
	_end_turn()


func _on_skill() -> void:
	skill_list = sk.skills_for(active)
	skill_menu.clear()
	for i in skill_list.size():
		skill_menu.add_item("%s (Grit %d)" % [skill_list[i]["name"], int(skill_list[i]["grit"])], i)
	skill_menu.position = Vector2i(get_global_transform_with_canvas() * Vector2(PANEL.position.x, 120))
	skill_menu.popup()


func _on_skill_chosen(i: int) -> void:
	var s: Dictionary = skill_list[i]
	var t: String = s["def"].get("target", "")
	if s["kind"] == "technique" and t in ["enemy", "enemy_area"]:
		target_skill = s   # the next enemy click uses it
		queue_redraw()
		return
	if sk.player_skill(active, s):
		_end_turn()


func _on_continue() -> void:
	if embedded and Game.journey != null:
		Game.next = {"battle_result": result}
		get_tree().change_scene_to_file("res://game/journey_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://game/main_menu.tscn")


# ---------------------------------------------------------------- drawing

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Game.SAND.darkened(0.55))
	Game.text(self, Vector2(4, 12), title, Game.FIRE, 9)
	Game.text(self, Vector2(300, 12), "Round %d" % sk.round_n, Game.BONE, 8)
	var reach: Array = sk.reachable(active) if waiting and not active.get("moved", false) else []
	var in_range: Array = sk.targets_for(active) if waiting else []
	for x in sk.size.x:
		for y in sk.size.y:
			var t := Vector2i(x, y)
			var r := Rect2(ORIGIN + Vector2(x, y) * TILE, Vector2(TILE, TILE))
			draw_rect(r, Game.SAND if (x + y) % 2 == 0 else Game.SAND.darkened(0.07))
			if sk.cover.has(t):
				draw_rect(r.grow(-3), Game.ASH)
				draw_rect(r.grow(-3), Game.OIL, false, 1.0)
				draw_line(r.position + Vector2(3, 3), r.end - Vector2(3, 3), Game.OIL)
			if reach.has(t):
				draw_rect(r.grow(-1), Color(Game.TEAL, 0.45))
			if t == hover:
				draw_rect(r, Game.BONE, false, 1.0)
	for c in sk.units:
		if c["fled"]:
			continue
		_draw_unit(c, in_range.has(c))
	Game.panel(self, PANEL)
	_draw_info(active, Vector2(PANEL.position.x + 4, PANEL.position.y + 12), "Turn")
	var h := _unit_at(hover)
	if not h.is_empty() and h != active:
		_draw_info(h, Vector2(PANEL.position.x + 4, PANEL.position.y + 84), "Target" if h["side"] == "enemy" else "Ally")
	if not target_skill.is_empty():
		Game.text(self, Vector2(PANEL.position.x + 4, 160), "Pick a target: " + target_skill["name"], Game.FIRE, 7)
	var lines: Array = sk.lines.slice(max(0, sk.lines.size() - 3))
	for i in lines.size():
		Game.text(self, Vector2(4, 244 + i * 9), lines[i], Game.BONE, 7)
	if done:
		_draw_result()


func _unit_colors(c: Dictionary) -> Array:
	if c["side"] == "party":
		return [Game.STEEL, Game.TEAL]
	if c["tags"].has("cantor"):
		return [Game.VIOLET, Game.CHOIR_WHITE]
	if c["tags"].has("opened"):
		return [Game.CHOIR_WHITE, Game.VIOLET]
	if c["tags"].has("beast"):
		return [Game.OCHRE.darkened(0.3), Game.OIL]
	return [Game.RUST, Game.BLOOD]


func _draw_unit(c: Dictionary, targetable: bool) -> void:
	var center: Vector2 = ORIGIN + Vector2(c["pos"]) * TILE + Vector2(TILE, TILE) / 2.0
	var cols := _unit_colors(c)
	if c["down"]:
		draw_line(center - Vector2(5, 5), center + Vector2(5, 5), Game.OIL, 2.0)
		draw_line(center + Vector2(-5, 5), center + Vector2(5, -5), Game.OIL, 2.0)
		return
	if c == active:
		draw_circle(center, 10.0, Game.FIRE)
	if c["tags"].has("leader") or c["tags"].has("boss"):
		draw_arc(center, 9.0, 0, TAU, 16, Game.FIRE, 1.0)
	draw_circle(center, 7.5, cols[0])
	draw_arc(center, 7.5, 0, TAU, 16, cols[1], 1.0)
	var letter: String = String(c["name"]).trim_prefix("The ").substr(0, 1)
	Game.text(self, center + Vector2(-3, 3), letter, Game.BONE if cols[0] != Game.CHOIR_WHITE else Game.OIL, 8)
	Game.bar(self, Rect2(center + Vector2(-8, -12), Vector2(16, 2)), c["hp"] / c["max_hp"], Game.FIRE if c["side"] == "party" else Game.BLOOD)
	if c["defending"]:
		draw_rect(Rect2(center + Vector2(6, 2), Vector2(3, 4)), Game.CHROME)
	if targetable and waiting:
		Game.text(self, center + Vector2(-7, 14), "%d%%" % roundi(sk.hit_chance(active, c)), Game.FIRE, 7)


func _draw_info(c: Dictionary, pos: Vector2, label: String) -> void:
	if c.is_empty():
		return
	Game.text(self, pos, "%s: %s" % [label, c["name"]], Game.FIRE, 7)
	Game.text(self, pos + Vector2(0, 10), "HP %d/%d  Grit %d" % [roundi(c["hp"]), roundi(c["max_hp"]), roundi(c["grit"])], Game.BONE, 7)
	var ammo := ("  ammo %d" % c["ammo"]) if int(c["weapon"]["ammo"]) > 0 else ""
	Game.text(self, pos + Vector2(0, 19), "%s (%s)%s" % [c["weapon"]["name"], c["weapon"]["range"], ammo], Game.BONE, 7)
	Game.text(self, pos + Vector2(0, 28), "Atk %d  Def %d  Spd %d" % [roundi(Characters.attack_value(c)), roundi(c["defense"]), roundi(c["speed"])], Game.BONE, 7)
	var st: Array = c["statuses"].keys()
	if not st.is_empty():
		Game.text(self, pos + Vector2(0, 37), ", ".join(st), Game.ORANGE, 7)


func _draw_result() -> void:
	var r := Rect2(120, 90, 240, 100)
	Game.panel(self, r)
	var w: String = result["winner"]
	var head: String = {"party": "VICTORY", "enemy": "DEFEAT", "fled": "GOT AWAY"}.get(w, "STALEMATE")
	Game.text(self, r.position + Vector2(80, 22), head, Game.FIRE if w == "party" else Game.BLOOD, 14)
	Game.text(self, r.position + Vector2(12, 42), "%d rounds. Party HP left: %d%%. Fight XP: %d." % [result["rounds"], roundi(result["party_hp_share"] * 100), result["xp"]], Game.BONE, 7)
