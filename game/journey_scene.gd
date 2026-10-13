## The playable journey: drive a route day by day, read event cards, pick choices (their
## check chances shown), and fight or auto-resolve the battles they start. The journey is
## sim/events/journey.gd in interactive mode; it lives in Game.journey while a battle scene is
## open, and the battle scene hands back its result in Game.next.
extends Control

const Game := preload("res://game/game.gd")
const Art := preload("res://game/art.gd")
const Journey := preload("res://sim/events/journey.gd")
const World := preload("res://sim/world.gd")
const PlaytestLog := preload("res://game/playtest_log.gd")

const VIGNETTE := Rect2(0, 0, 480, 62)
const ROUTE := Rect2(2, 64, 476, 34)
const DASH := Rect2(2, 100, 150, 150)
const CARD := Rect2(154, 100, 324, 150)

var j
var state := {}
var title := ""
var journal: RichTextLabel
var choice_btns: Array = []
var slot_choice: Array = [-1, -1, -1, -1]   # choice button slot -> the card's choice index
var btn := {}
var shown_lines := 0
var feel_asked := false
var clock := 0.0
var card: Dictionary:
	get:
		return state if state.get("kind", "") == "card" else {}
var over: bool:
	get:
		return state.get("kind", "") == "end"


func _ready() -> void:
	Game.ensure_loaded()
	theme = Game.theme
	var nx: Dictionary = Game.next
	if Game.journey == null:
		var rng := RandomNumberGenerator.new()
		var seed := int(nx.get("seed", Time.get_ticks_usec()))
		rng.seed = seed
		var world = null
		var month := int(nx.get("month", 3))
		if int(nx.get("world_months", 0)) > 0:
			world = World.new()
			world.setup(Game.data, Game.graph, 1)
			for m in int(nx["world_months"]):
				world.world_turn()
			month = world.calendar_month
		j = Journey.new()
		j.setup(Game.data, Game.graph, world, nx.get("from", "lighthouse"), nx.get("to", "dustwich"), int(nx.get("level", 3)), rng, month)
		j.interactive = true
		Game.journey = j
		Game.journey_info = {"from": j.route[0], "to": j.route[-1], "level": int(nx.get("level", 3)), "seed": seed,
			"month": month, "world_months": int(nx.get("world_months", 0))}
		PlaytestLog.write("journey_start", Game.journey_info)
		state = j.step()
	else:
		j = Game.journey
		if nx.has("battle_result"):
			_log_battle("fought", nx["battle_result"])
			state = j.battle_done(nx["battle_result"])
		else:
			state = j.step()
	Game.next = {}
	title = "%s to %s" % [_hold(j.route[0]), _hold(j.route[-1])]

	journal = RichTextLabel.new()
	journal.position = CARD.position + Vector2(6, 5)
	journal.size = CARD.size - Vector2(12, 10)
	journal.scroll_following = true
	journal.add_theme_font_size_override("normal_font_size", Game.BODY)
	add_child(journal)
	for i in 4:
		var b := Game.button(self, "", Vector2(CARD.position.x + 6, CARD.end.y - 5 - (4 - i) * 16), Vector2(CARD.size.x - 12, 14), func(): _on_choice(slot_choice[i]))
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice_btns.append(b)
	btn["day"] = Game.button(self, "Drive on (one day)", Vector2(154, 253), Vector2(110, 14), _on_drive.bind(false))
	btn["until"] = Game.button(self, "Drive until something happens", Vector2(268, 253), Vector2(150, 14), _on_drive.bind(true))
	btn["menu"] = Game.button(self, "Menu", Vector2(422, 253), Vector2(56, 14), _on_menu)
	btn["fight"] = Game.button(self, "Fight it out", Vector2(CARD.position.x + 6, CARD.end.y - 21), Vector2(152, 14), _on_fight)
	btn["auto"] = Game.button(self, "Auto-resolve", Vector2(CARD.position.x + 166, CARD.end.y - 21), Vector2(152, 14), _on_auto_resolve)
	_show()


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _hold(id: String) -> String:
	return Game.data.hold_by_id[id]["name"]


# ---------------------------------------------------------------- flow

## Drive one day (or until a card, a battle or the end).
func advance(until: bool = false) -> void:
	state = j.step()
	var n := 0
	while until and state["kind"] == "day" and n < 400:
		state = j.step()
		n += 1
	_show()


func _on_drive(until: bool) -> void:
	advance(until)


func _on_choice(i: int) -> void:
	var rec := {"day": int(j.day), "hold": j.here(), "chances": state["chances"], "journey_seed": Game.journey_info.get("seed", 0)}
	state = j.choose(i)
	rec.merge(j.last_choice)
	PlaytestLog.write("card", rec)
	_show()


func _on_fight() -> void:
	Game.next = fight_setup()
	get_tree().change_scene_to_file(Game.next["scene"])


## What the battle scene needs to play the journey's pending battle (and log it).
func fight_setup() -> Dictionary:
	var spec: String = state["spec"]
	var parts := spec.split(":")
	var kind := "skirmish" if parts[0] == "skirmish" else "road_war"
	var list: Array = Game.data.units["encounters"] if kind == "skirmish" else Game.data.units["convoys"]
	var foe: Dictionary = list.filter(func(x): return x["id"] == parts[1])[0]
	return {"sim": state["sim"], "scene": "res://game/%s_scene.tscn" % kind, "title": "%s · %s · day %d" % [foe["name"], foe["rating"].capitalize(), int(j.day)],
		"log": {"source": "journey", "encounter" if kind == "skirmish" else "convoy": parts[1], "rating": foe["rating"],
			"level": Game.journey_info.get("level", 0), "day": int(j.day), "journey_seed": Game.journey_info.get("seed", 0)}}


func _on_auto_resolve() -> void:
	var res: Dictionary = state["sim"].run()
	_log_battle("auto", res)
	state = j.battle_done(res)
	_show()


func _log_battle(mode: String, res: Dictionary) -> void:
	PlaytestLog.write("journey_battle", {"spec": j.pending_battle.get("spec", ""), "mode": mode, "winner": res["winner"],
		"rounds": res["rounds"], "day": int(j.day), "journey_seed": Game.journey_info.get("seed", 0)})


func _log_end(abandoned: bool) -> void:
	if Game.journey_info.get("logged_end", false):
		return
	Game.journey_info["logged_end"] = true
	var st: Dictionary = j.stats
	var rec := {"from": j.route[0], "to": j.route[-1], "level": Game.journey_info.get("level", 0), "journey_seed": Game.journey_info.get("seed", 0),
		"abandoned": abandoned, "arrived": st.get("arrived", false), "days": int(j.day), "expected_days": snappedf(float(st.get("expected_days", 0.0)), 0.1),
		"events": st["events"], "battles": st["battles"], "battles_won": st["battles_won"], "defeats": st["defeats"],
		"cargo": snappedf(j.cargo, 0.01), "barter": snappedf(j.barter, 0.1), "morale": roundi(j.morale)}
	PlaytestLog.write("journey_end", rec)


func _on_menu() -> void:
	if j != null and not over:
		_log_end(true)
	Game.journey = null
	get_tree().change_scene_to_file("res://game/main_menu.tscn")


## Sets which controls show for the current state.
func _show() -> void:
	var kind: String = state.get("kind", "day")
	while shown_lines < j.lines.size():
		var l: String = j.lines[shown_lines]
		shown_lines += 1
		if l.begins_with("Day ") or l.begins_with("From "):
			journal.push_color(Game.FIRE)
			journal.add_text(l)
			journal.pop()
		else:
			journal.add_text(l)
		journal.newline()
	journal.visible = kind == "day" or kind == "end"
	if kind == "end" and not Game.journey_info.get("logged_end", false):
		_log_end(false)
		journal.size.y = CARD.size.y - 56
		journal.scroll_to_line.call_deferred(max(0, journal.get_line_count() - 1))
		var about := {"about": "journey", "from": j.route[0], "to": j.route[-1], "level": Game.journey_info.get("level", 0),
			"journey_seed": Game.journey_info.get("seed", 0), "arrived": state["arrived"]}
		PlaytestLog.feel_buttons(self, Vector2(CARD.position.x + 8, CARD.end.y - 32), about)
		feel_asked = true
	for b in choice_btns:
		b.visible = false
	btn["fight"].visible = kind == "battle"
	btn["auto"].visible = kind == "battle"
	btn["day"].disabled = kind != "day"
	btn["until"].disabled = kind != "day"
	if kind == "card":
		var e: Dictionary = state["event"]
		var n: int = e["choices"].size()
		for i in n:
			var c: Dictionary = e["choices"][i]
			var b: Button = choice_btns[4 - n + i]
			slot_choice[4 - n + i] = i
			b.visible = true
			b.text = "%d) %s" % [i + 1, c["label"]]
			if c.has("check"):
				b.text += "   [%s, %s: %d%%]" % [c["check"]["attr"].capitalize(), c["check"]["difficulty"], state["chances"][i]]
	queue_redraw()


func _unhandled_key_input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed):
		return
	var kind: String = state.get("kind", "")
	if kind == "day" and ev.keycode == KEY_SPACE:
		advance(false)
	elif kind == "day" and ev.keycode == KEY_ENTER:
		advance(true)
	elif kind == "card" and ev.keycode >= KEY_1 and ev.keycode <= KEY_4:
		var i: int = ev.keycode - KEY_1
		if i < state["event"]["choices"].size():
			_on_choice(i)


# ---------------------------------------------------------------- drawing

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("2a1f19"))
	_draw_vignette()
	_draw_route()
	_draw_dash()
	Game.panel(self, CARD, "card")
	var kind: String = state.get("kind", "day")
	var x := CARD.position.x + 8
	if kind == "card":
		var e: Dictionary = state["event"]
		var tone: String = e["tone"]
		var col: Color = {"good": Game.TEAL.lightened(0.2), "neutral": Game.BONE, "bad": Game.ORANGE, "lethal": Game.BLOOD.lightened(0.3)}.get(tone, Game.BONE)
		Game.text(self, Vector2(x, CARD.position.y + 13), "Day %d  ·  near %s" % [int(j.day), _hold(j.here())], col)
		var tag: String = tone.to_upper()
		Game.text(self, Vector2(CARD.end.x - 8 - Game.text_width(tag), CARD.position.y + 13), tag, col)
		draw_rect(Rect2(x, CARD.position.y + 16, CARD.size.x - 16, 1), Color(col, 0.6))
		var lines := Game.wrap(e["text"], CARD.size.x - 18)
		var n: int = e["choices"].size()
		var max_lines := int((CARD.size.y - 26 - n * 16) / Game.LINE)
		for i in min(lines.size(), max_lines):
			Game.text(self, Vector2(x, CARD.position.y + 27 + i * Game.LINE), lines[i])
	elif kind == "battle":
		var parts: PackedStringArray = String(state["spec"]).split(":")
		var skirmish := parts[0] == "skirmish"
		var foe: Dictionary = (Game.data.units["encounters"] if skirmish else Game.data.units["convoys"]).filter(func(f): return f["id"] == parts[1])[0]
		Game.text(self, Vector2(x, CARD.position.y + 13), "TROUBLE ON THE ROAD", Game.BLOOD.lightened(0.3))
		draw_rect(Rect2(x, CARD.position.y + 16, CARD.size.x - 16, 1), Color(Game.BLOOD, 0.6))
		Game.text(self, Vector2(x, CARD.position.y + 36), foe["name"], Game.FIRE, "head")
		Game.text(self, Vector2(x, CARD.position.y + 47), "%s  ·  %s" % ["A skirmish" if skirmish else "A road war on the " + String(foe["road"]), String(foe["rating"]).capitalize()], Game.DIM)
		# Who you're up against.
		var lineup: Array = []
		if skirmish:
			for uid in foe["units"]:
				for k in int(foe["units"][uid]):
					lineup.append(Art.variant(Art.unit(uid), "flip", uid))
		else:
			for r in foe["rigs"]:
				lineup.append(Art.rig(r["frame"], "enemy", r["crew_type"]))
		var lx := x
		var base := CARD.position.y + 86
		draw_rect(Rect2(CARD.position.x + 4, base - 1, CARD.size.x - 8, 3), Color("8a4a1c"))
		for t in lineup:
			if lx + t.get_width() > CARD.end.x - 8:
				break
			draw_texture(t, Vector2(lx, base - t.get_height() + 1))
			lx += t.get_width() + 3
		Game.text(self, Vector2(x, CARD.position.y + 104), "Fight it yourself, or let the crew handle it." if skirmish else "Take the wheel, or let the drivers handle it.", Game.BONE)
	elif kind == "end":
		var arrived: bool = state["arrived"]
		Game.text(self, Vector2(x, CARD.end.y - 6), ("Arrived at %s." % _hold(j.route[-1])) if arrived else "You turn back.", Game.FIRE)
		if feel_asked:
			Game.text(self, Vector2(x, CARD.end.y - 36), "How did the trip feel? (for the playtest log)", Game.DIM)


## The convoy on the road: sky, mesas, the road rolling by, dust.
func _draw_vignette() -> void:
	var r := VIGNETTE
	var sky := [Color("3a1c34"), Color("6a2436"), Color("a8382a"), Color("e0621b"), Color("f5a623")]
	var horizon := 38.0
	for y in int(horizon):
		var t := float(y) / horizon * (sky.size() - 1)
		var i := mini(int(t), sky.size() - 2)
		var c1: Color = sky[i]
		var c2: Color = sky[i + 1]
		var f := t - i
		# Two-tone dither bands, drawn as rows of alternating runs.
		draw_rect(Rect2(0, y, r.size.x, 1), c1 if f < 0.5 else c2)
		if f > 0.25 and f < 0.75:
			var step := 2 if f > 0.4 and f < 0.6 else 4
			for x in range(posmod(y, 2), int(r.size.x), step):
				draw_rect(Rect2(x, y, 1, 1), c2 if f < 0.5 else c1)
	# Mesas drifting by.
	var drift := clock * 4.0
	for m in 6:
		var mx := fposmod(m * 97.0 - drift, r.size.x + 120.0) - 60.0
		var w := 40.0 + Art.noise(m, 1, 9) * 50.0
		var h := 4.0 + Art.noise(m, 2, 9) * 8.0
		draw_colored_polygon(PackedVector2Array([Vector2(mx, horizon), Vector2(mx + 6, horizon - h), Vector2(mx + w - 6, horizon - h), Vector2(mx + w, horizon)]), Color("4a2230"))
	draw_rect(Rect2(0, horizon, r.size.x, r.end.y - horizon), Color("8a4a1c"))
	for i in 40:
		var sx := fposmod(i * 37.0 - clock * 30.0, r.size.x + 20.0) - 10.0
		draw_rect(Rect2(sx, horizon + 2 + Art.noise(i, 4, 1) * 6.0, 2, 1), Color("5a2e14"))
	var road_y := 50.0
	draw_rect(Rect2(0, road_y, r.size.x, 10), Game.ASPHALT)
	draw_rect(Rect2(0, road_y, r.size.x, 1), Color("a8682c"))
	var dx := -fposmod(clock * 70.0, 24.0)
	while dx < r.size.x:
		draw_rect(Rect2(dx, road_y + 5, 10, 1), Game.FIRE)
		dx += 24.0
	# The convoy, lead rig in front.
	var cx := 300.0
	for i in j.convoy.size():
		var spec: Dictionary = j.convoy[i]
		var tex := Art.rig(spec["frame"], "party", "hands")
		var bounce := 1.0 if sin(clock * 13.0 + i * 2.1) > 0.6 else 0.0
		var pos := Vector2(roundf(cx - tex.get_width()), roundf(road_y + 8 - tex.get_height() - bounce))
		for k in 3:
			var a := fposmod(clock * 2.0 + k * 0.33, 1.0)
			draw_rect(Rect2(pos.x - 4 - a * 26.0, road_y + 4 - a * 4.0, 2 + a * 3.0, 2 + a * 2.0), Color(Game.SAND, 0.45 * (1.0 - a)))
		draw_texture(tex, pos)
		cx -= tex.get_width() + 14
	Game.text(self, Vector2(6, 17), title, Game.BONE, "head")
	var day := "Day %d  ·  %s" % [int(j.day), j.season().capitalize()]
	Game.text(self, Vector2(r.end.x - 6 - Game.text_width(day), 12), day, Game.BONE)


## The route as a strip: holds as gates, spaced by km, with the convoy on it.
func _draw_route() -> void:
	var r := ROUTE
	Game.panel(self, r)
	var cum: Array = [0.0]
	for e in j.edges:
		cum.append(cum[-1] + float(e["km"]))
	var total: float = max(cum[-1], 1.0)
	var y := r.position.y + 17
	var x0 := r.position.x + 14
	var w := r.size.x - 28
	draw_rect(Rect2(x0, y - 1, w, 3), Game.ASPHALT)
	var pos: float = cum[min(j.leg, j.edges.size())] + (j.km_in_leg if j.leg < j.edges.size() else 0.0)
	var cx: float = x0 + pos / total * w
	draw_rect(Rect2(x0, y - 1, cx - x0, 3), Color("a8682c"))
	for i in j.route.size():
		var x: float = roundf(x0 + cum[i] / total * w)
		var id: String = j.route[i]
		var hum: float = j.events.hum_at(id)
		if hum >= 30.0:
			draw_arc(Vector2(x, y), 7.0, -PI / 2.0, -PI / 2.0 + TAU * clampf(hum / 100.0, 0.0, 1.0), 16, Game.VIOLET, 1.0)
		draw_texture(Art.gate(hum >= 100.0), Vector2(x - 5, y - 6))
		var name := _hold(id)
		var col: Color = Game.BONE if i > j.leg else Game.DIM
		var tw := Game.text_width(name)
		var tx := clampf(x - tw / 2.0, r.position.x + 4, r.end.x - 4 - tw)
		Game.text(self, Vector2(tx, y - 8 if i % 2 == 0 else y + 13), name, col)
	draw_rect(Rect2(roundf(cx) - 2, y - 3, 5, 5), Game.TEAL)
	draw_rect(Rect2(roundf(cx) - 2, y - 3, 5, 5), Game.OIL, false, 1.0)


func _draw_dash() -> void:
	Game.panel(self, DASH)
	var x0 := DASH.position.x
	var y0 := DASH.position.y
	var dials := [["water", "Water"], ["chow", "Chow"], ["fuel", "Fuel"]]
	for i in dials.size():
		var k: String = dials[i][0]
		var c := Vector2(x0 + 26 + i * 49, y0 + 28)
		Game.dial(self, c, 13, j.supplies[k] / Journey.CAPACITY[k], dials[i][1])
		Game.text_centered(self, c.x, c.y + 15, "%.1f" % j.supplies[k], Game.BONE)
	# Morale: a tachometer bar that redlines below 30.
	var my := y0 + 52
	draw_texture(Art.icon("morale"), Vector2(x0 + 6, my))
	Game.text(self, Vector2(x0 + 16, my + 7), "Morale", Game.BONE)
	Game.bar(self, Rect2(x0 + 48, my + 2, 70, 3), j.morale / 100.0, Game.FIRE if j.morale >= 30.0 else Game.BLOOD.lightened(0.2))
	draw_rect(Rect2(x0 + 48 + 21, my + 1, 1, 5), Game.BLOOD)
	Game.text(self, Vector2(x0 + 122, my + 7), "%d" % roundi(j.morale))
	var stats := [["barter", "Barter", "%.1f" % j.barter], ["cargo", "Cargo", "%d%%" % roundi(j.cargo * 100)],
		["repairs", "Repairs owed", "%.1f" % j.repairs], ["hum", "Hum", "%d" % roundi(j.hum)]]
	for i in stats.size():
		var sx := x0 + 6 + (i % 2) * 72
		var sy := my + 12 + (i / 2) * 10
		draw_texture(Art.icon(stats[i][0]), Vector2(sx, sy))
		Game.text(self, Vector2(sx + 10, sy + 7), "%s %s" % [stats[i][1], stats[i][2]], Game.BONE if stats[i][0] != "hum" or j.hum < 1.0 else Game.VIOLET.lightened(0.3))
	var py := my + 36
	for m in j.party:
		var r := Rect2(x0 + 6, py, 10, 10)
		draw_rect(r, Game.OIL)
		draw_rect(r.grow(-1), Game.STEEL)
		draw_texture_rect_region(Art.unit(m["class"]), Rect2(r.position + Vector2(1, 1), Vector2(8, 8)), Rect2(6, 1, 8, 8))
		Game.text(self, Vector2(x0 + 20, py + 7), m["name"], Game.BONE)
		Game.bar(self, Rect2(x0 + 76, py + 3, 40, 3), m["hp"] / m["max_hp"], Game.BLOOD.lightened(0.2))
		Game.text(self, Vector2(x0 + 120, py + 7), "%d" % roundi(m["hp"]), Game.DIM)
		py += 12
	var won := "Battles %d won of %d" % [j.stats["battles_won"], j.stats["battles"]]
	if not j.rumors.is_empty():
		won += "  ·  rumors %d" % j.rumors.size()
	Game.text(self, Vector2(x0 + 6, DASH.end.y - 6), won, Game.DIM)
