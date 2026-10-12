## The playable journey (M2 placeholder art): drive a route day by day, read event cards,
## pick choices (their check chances shown), and fight or auto-resolve the battles they start.
## The journey is sim/events/journey.gd in interactive mode; it lives in Game.journey while a
## battle scene is open, and the battle scene hands back its result in Game.next.
extends Control

const Game := preload("res://game/game.gd")
const Journey := preload("res://sim/events/journey.gd")
const World := preload("res://sim/world.gd")

const CARD := Rect2(156, 60, 322, 172)
const DASH := Rect2(2, 60, 150, 190)

var j
var state := {}
var title := ""
var journal: RichTextLabel
var card_text: Label
var choice_btns: Array = []
var slot_choice: Array = [-1, -1, -1, -1]   # choice button slot -> the card's choice index
var btn := {}
var shown_lines := 0
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
		rng.seed = int(nx.get("seed", Time.get_ticks_usec()))
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
		state = j.step()
	else:
		j = Game.journey
		state = j.battle_done(nx["battle_result"]) if nx.has("battle_result") else j.step()
	Game.next = {}
	title = "%s to %s" % [_hold(j.route[0]), _hold(j.route[-1])]

	journal = RichTextLabel.new()
	journal.position = CARD.position + Vector2(4, 4)
	journal.size = CARD.size - Vector2(8, 8)
	journal.scroll_following = true
	journal.add_theme_font_size_override("normal_font_size", 7)
	journal.add_theme_color_override("default_color", Game.BONE)
	add_child(journal)
	card_text = Label.new()
	card_text.position = CARD.position + Vector2(6, 16)
	card_text.size = Vector2(CARD.size.x - 12, 90)
	card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_text.add_theme_font_size_override("font_size", 8)
	add_child(card_text)
	for i in 4:
		var b := Game.button(self, "", Vector2(CARD.position.x + 4, CARD.end.y - 4 - (4 - i) * 16), Vector2(CARD.size.x - 8, 14), func(): _on_choice(slot_choice[i]))
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice_btns.append(b)
	btn["day"] = Game.button(self, "Drive on (one day)", Vector2(156, 236), Vector2(80, 14), _on_drive.bind(false))
	btn["until"] = Game.button(self, "Drive until something happens", Vector2(240, 236), Vector2(178, 14), _on_drive.bind(true))
	btn["menu"] = Game.button(self, "Menu", Vector2(422, 236), Vector2(56, 14), _on_menu)
	btn["fight"] = Game.button(self, "Fight it out", Vector2(CARD.position.x + 4, CARD.end.y - 36), Vector2(150, 14), _on_fight)
	btn["auto"] = Game.button(self, "Auto-resolve", Vector2(CARD.position.x + 164, CARD.end.y - 36), Vector2(150, 14), _on_auto_resolve)
	_show()


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
	state = j.choose(i)
	_show()


func _on_fight() -> void:
	var spec: String = state["spec"]
	var parts := spec.split(":")
	var kind := "skirmish" if parts[0] == "skirmish" else "road_war"
	var list: Array = Game.data.units["encounters"] if kind == "skirmish" else Game.data.units["convoys"]
	var foe: Dictionary = list.filter(func(x): return x["id"] == parts[1])[0]
	Game.next = {"sim": state["sim"], "title": "%s (%s), day %d" % [foe["name"], foe["rating"], int(j.day)]}
	get_tree().change_scene_to_file("res://game/%s_scene.tscn" % kind)


func _on_auto_resolve() -> void:
	state = j.battle_done(state["sim"].run())
	_show()


func _on_menu() -> void:
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
	card_text.visible = kind == "card" or kind == "battle"
	for b in choice_btns:
		b.visible = false
	btn["fight"].visible = kind == "battle"
	btn["auto"].visible = kind == "battle"
	btn["day"].disabled = kind != "day"
	btn["until"].disabled = kind != "day"
	if kind == "card":
		var e: Dictionary = state["event"]
		card_text.text = e["text"]
		var n: int = e["choices"].size()
		for i in n:
			var c: Dictionary = e["choices"][i]
			var b: Button = choice_btns[4 - n + i]
			slot_choice[4 - n + i] = i
			b.visible = true
			b.text = "%d) %s" % [i + 1, c["label"]]
			if c.has("check"):
				b.text += "   [%s, %s: %d%%]" % [c["check"]["attr"].capitalize(), c["check"]["difficulty"], state["chances"][i]]
	elif kind == "battle":
		var parts: PackedStringArray = String(state["spec"]).split(":")
		var skirmish := parts[0] == "skirmish"
		var foe: Dictionary = (Game.data.units["encounters"] if skirmish else Game.data.units["convoys"]).filter(func(x): return x["id"] == parts[1])[0]
		card_text.text = "%s: %s (%s).\n\n%s" % ["Skirmish" if skirmish else "Road war", foe["name"], foe["rating"],
			"Fight it out on the grid, or let the crew handle it (auto-resolve)." if skirmish else "Take the wheel, or let the drivers handle it (auto-resolve)."]
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
	draw_rect(Rect2(Vector2.ZERO, size), Game.OCHRE.darkened(0.45))
	Game.text(self, Vector2(4, 12), title, Game.FIRE, 9)
	Game.text(self, Vector2(330, 12), "Day %d, %s" % [int(j.day), j.season()], Game.BONE, 8)
	_draw_route(Rect2(4, 18, 472, 38))
	_draw_dash()
	Game.panel(self, CARD)
	var kind: String = state.get("kind", "day")
	if kind == "card":
		var e: Dictionary = state["event"]
		var tone: String = e["tone"]
		var col: Color = {"good": Game.TEAL, "neutral": Game.BONE, "bad": Game.ORANGE, "lethal": Game.BLOOD}.get(tone, Game.BONE)
		Game.text(self, CARD.position + Vector2(6, 11), "Day %d, near %s" % [int(j.day), _hold(j.here())], col, 8)
		draw_rect(Rect2(CARD.position + Vector2(4, 13), Vector2(CARD.size.x - 8, 1)), col)
	elif kind == "battle":
		Game.text(self, CARD.position + Vector2(6, 11), "TROUBLE ON THE ROAD", Game.BLOOD, 8)
	elif kind == "end":
		var arrived: bool = state["arrived"]
		Game.text(self, Vector2(CARD.position.x + 6, CARD.end.y - 8), ("Arrived at %s." % _hold(j.route[-1])) if arrived else "You turn back.", Game.FIRE, 8)


## The route as a strip: holds as gates, spaced by km, with the convoy on it.
func _draw_route(r: Rect2) -> void:
	var cum: Array = [0.0]
	for e in j.edges:
		cum.append(cum[-1] + float(e["km"]))
	var total: float = max(cum[-1], 1.0)
	var y := r.position.y + 18
	var x0 := r.position.x + 8
	var w := r.size.x - 16
	draw_line(Vector2(x0, y), Vector2(x0 + w, y), Game.ASPHALT, 4.0)
	for i in j.route.size():
		var x: float = x0 + cum[i] / total * w
		var id: String = j.route[i]
		var hum: float = j.events.hum_at(id)
		var col: Color = Game.BONE if i > j.leg else Game.SAND
		if hum >= 30.0:
			draw_arc(Vector2(x, y), 6.0, 0, TAU * clampf(hum / 100.0, 0.0, 1.0), 16, Game.VIOLET, 1.5)
		draw_rect(Rect2(x - 3, y - 4, 6, 7), Game.RUST if hum < 100.0 else Game.CHOIR_WHITE)
		draw_rect(Rect2(x - 3, y - 4, 6, 7), col, false, 1.0)
		var name := _hold(id)
		if j.route.size() > 8 and i != 0 and i != j.route.size() - 1:
			name = name.substr(0, 10)
		var tw := Game.font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x
		var tx := clampf(x - tw / 2.0, r.position.x, r.end.x - tw)
		Game.text(self, Vector2(tx, y - 8 if i % 2 == 0 else y + 14), name, col, 6)
	var pos: float = cum[min(j.leg, j.edges.size())] + (j.km_in_leg if j.leg < j.edges.size() else 0.0)
	var cx: float = x0 + pos / total * w
	draw_rect(Rect2(cx - 5, y - 3, 10, 5), Game.STEEL)
	draw_rect(Rect2(cx - 5, y - 3, 10, 5), Game.TEAL, false, 1.0)
	draw_circle(Vector2(cx - 8, y), 2.5, Color(Game.SAND, 0.6))


func _draw_dash() -> void:
	Game.panel(self, DASH)
	var p := DASH.position + Vector2(6, 2)
	for k in ["water", "chow", "fuel"]:
		var frac: float = j.supplies[k] / Journey.CAPACITY[k]
		Game.gauge(self, p, 64, frac, "%s %.1f" % [{"water": "Water", "chow": "Chow", "fuel": "Guzzoline"}[k], j.supplies[k]])
		p.y += 24
	# Morale as a tachometer bar that redlines below 30.
	Game.text(self, Vector2(DASH.position.x + 80, DASH.position.y + 9), "Morale %d" % roundi(j.morale), Game.BONE, 7)
	Game.bar(self, Rect2(DASH.position.x + 80, DASH.position.y + 11, 64, 5), j.morale / 100.0, Game.FIRE if j.morale >= 30.0 else Game.BLOOD)
	draw_rect(Rect2(DASH.position.x + 80 + 64 * 0.3, DASH.position.y + 10, 1, 7), Game.BLOOD)
	var stats := [
		"Barter %.1f" % j.barter,
		"Cargo %d%%" % roundi(j.cargo * 100),
		"Repairs owed %.1f" % j.repairs,
		"Hum exposure %d" % roundi(j.hum),
		"Battles %d won of %d" % [j.stats["battles_won"], j.stats["battles"]],
	]
	for i in stats.size():
		Game.text(self, Vector2(DASH.position.x + 80, DASH.position.y + 28 + i * 10), stats[i], Game.BONE, 7)
	var py := DASH.position.y + 84
	Game.text(self, Vector2(DASH.position.x + 6, py), "PARTY", Game.FIRE, 7)
	for m in j.party:
		py += 12
		Game.text(self, Vector2(DASH.position.x + 6, py), m["name"], Game.BONE, 7)
		Game.text(self, Vector2(DASH.position.x + 104, py), "%d/%d" % [roundi(m["hp"]), roundi(m["max_hp"])], Game.BONE, 7)
		Game.bar(self, Rect2(DASH.position.x + 6, py + 2, 138, 2), m["hp"] / m["max_hp"], Game.FIRE)
	if not j.rumors.is_empty():
		py += 14
		Game.text(self, Vector2(DASH.position.x + 6, py), "RUMORS %d" % j.rumors.size(), Game.FIRE, 7)
	var conv := "Convoy: " + ", ".join(j.convoy.map(func(s): return String(s["frame"]).capitalize()))
	Game.text(self, Vector2(DASH.position.x + 6, DASH.end.y - 6), conv, Color(Game.BONE, 0.75), 6)
