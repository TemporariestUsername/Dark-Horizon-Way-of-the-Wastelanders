## Shared state and look for the playable M2 scenes. Static, so scenes (and the screenshot
## tool) can use it without an autoload.
##
## Placeholder art: everything is drawn in code from the palette below (docs/design/14:
## a hot world of ochre, rust and bone; the Choir is the only cold, violet thing).
extends RefCounted

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")

const SAND := Color("d9a35b")
const OCHRE := Color("c27c2c")
const RUST := Color("8e3b1f")
const ORANGE := Color("e0621b")
const BONE := Color("efe3c8")
const OIL := Color("1b1714")
const ASH := Color("3a302a")
const ASPHALT := Color("2b2622")
const STEEL := Color("2e5e63")
const TEAL := Color("6fa3a0")
const FIRE := Color("f5a623")
const BLOOD := Color("9e1b1b")
const CHROME := Color("b8c0c2")
const CHOIR_WHITE := Color("f4f1ea")
const VIOLET := Color("8a5cf6")
const NIGHT := Color("142226")

static var data
static var graph
static var theme: Theme
static var font: Font

## What the next scene should set up (set by the menu or the journey).
static var next := {}
## A journey in progress (survives the trip into a battle scene and back).
static var journey = null


static func ensure_loaded() -> void:
	if data == null:
		data = SimData.new()
		data.load_all()
		graph = RoadGraph.new()
		graph.build(data)
	if theme == null:
		theme = _make_theme()


static func _box(bg: Color, border: Color, w: int = 1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(w)
	sb.set_content_margin_all(1)
	sb.content_margin_left = 3
	sb.content_margin_right = 3
	return sb


static func _make_theme() -> Theme:
	var t := Theme.new()
	font = ThemeDB.fallback_font
	t.default_font = font
	t.default_font_size = 8
	t.set_stylebox("normal", "Button", _box(RUST, OIL))
	t.set_stylebox("hover", "Button", _box(ORANGE, BONE))
	t.set_stylebox("pressed", "Button", _box(FIRE, OIL))
	t.set_stylebox("disabled", "Button", _box(ASH, OIL))
	t.set_stylebox("focus", "Button", _box(Color(0, 0, 0, 0), FIRE))
	t.set_color("font_color", "Button", BONE)
	t.set_color("font_hover_color", "Button", OIL)
	t.set_color("font_pressed_color", "Button", OIL)
	t.set_color("font_disabled_color", "Button", Color(BONE, 0.4))
	t.set_color("font_color", "Label", BONE)
	t.set_stylebox("normal", "OptionButton", _box(ASH, RUST))
	t.set_stylebox("hover", "OptionButton", _box(RUST, BONE))
	t.set_stylebox("panel", "PopupMenu", _box(OIL, RUST))
	t.set_stylebox("panel", "PanelContainer", _box(Color(OIL, 0.92), RUST))
	return t


## A stencil-style panel: oil fill, rust frame, rivets in the corners.
static func panel(ci: CanvasItem, r: Rect2, fill: Color = Color(OIL, 0.92)) -> void:
	ci.draw_rect(r, fill)
	ci.draw_rect(r, RUST, false, 1.0)
	for p in [r.position + Vector2(2, 2), Vector2(r.end.x - 3, r.position.y + 2), Vector2(r.position.x + 2, r.end.y - 3), r.end - Vector2(3, 3)]:
		ci.draw_rect(Rect2(p, Vector2(1, 1)), CHROME)


static func text(ci: CanvasItem, pos: Vector2, s: String, col: Color = BONE, size: int = 8) -> void:
	ci.draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


## A fuel-gauge style bar with E and F marks (docs/design/14: supply gauges are fuel gauges).
static func gauge(ci: CanvasItem, pos: Vector2, w: float, frac: float, label: String, col: Color = FIRE) -> void:
	text(ci, pos + Vector2(0, 7), label, BONE, 7)
	var r := Rect2(pos + Vector2(0, 9), Vector2(w, 5))
	ci.draw_rect(r, ASH)
	ci.draw_rect(Rect2(r.position, Vector2(w * clampf(frac, 0.0, 1.0), 5)), col if frac > 0.2 else BLOOD)
	ci.draw_rect(r, OIL, false, 1.0)
	text(ci, pos + Vector2(0, 21), "E", Color(BONE, 0.6), 6)
	text(ci, pos + Vector2(w - 4, 21), "F", Color(BONE, 0.6), 6)


static func bar(ci: CanvasItem, r: Rect2, frac: float, col: Color) -> void:
	ci.draw_rect(r, OIL)
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(frac, 0.0, 1.0), r.size.y)), col)


## Builds a small button, wired to a callback.
static func button(parent: Node, label: String, pos: Vector2, size: Vector2, cb: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.position = pos
	b.add_theme_font_size_override("font_size", 8)
	b.pressed.connect(cb)
	parent.add_child(b)
	b.size = size   # after joining the tree, so the size is checked against the themed minimum
	return b
