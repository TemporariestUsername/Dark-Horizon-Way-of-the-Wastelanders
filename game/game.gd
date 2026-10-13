## Shared state and look for the playable M2 scenes. Static, so scenes (and the screenshot
## tool) can use it without an autoload.
##
## The look (docs/design/14): a hot world of ochre, rust and bone; the Choir is the only cold,
## violet thing. Pixel fonts drawn at their native sizes (Micro 5 for text, Jersey 10 for
## headings, both SIL OFL, in game/fonts), riveted metal plates for panels and stencil-plate
## buttons from game/art.gd.
extends RefCounted

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const Art := preload("res://game/art.gd")

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
const DIM := Color("a89a84")      # secondary text

## Text styles: the font and the one size it's crisp at.
const BODY := 10
const HEAD := 20
const TITLE := 40
const LINE := 9                   # body line spacing

static var data
static var graph
static var theme: Theme
static var font: FontFile         # Micro 5: body text
static var font_head: FontFile    # Jersey 10: headings and the title

## What the next scene should set up (set by the menu or the journey).
static var next := {}
## A journey in progress (survives the trip into a battle scene and back), and its setup.
static var journey = null
static var journey_info := {}


static func ensure_loaded() -> void:
	if data == null:
		data = SimData.new()
		data.load_all()
		graph = RoadGraph.new()
		graph.build(data)
	if theme == null:
		font = _pixel_font("res://game/fonts/Micro5-Regular.ttf")
		font_head = _pixel_font("res://game/fonts/Jersey10-Regular.ttf")
		theme = _make_theme()


static func _pixel_font(path: String) -> FontFile:
	var f := FontFile.new()
	f.load_dynamic_font(path)
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.generate_mipmaps = false
	return f


static func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font
	t.default_font_size = BODY
	for kind in ["Button", "OptionButton"]:
		t.set_stylebox("normal", kind, Art.plate("button"))
		t.set_stylebox("hover", kind, Art.plate("button_hover"))
		t.set_stylebox("pressed", kind, Art.plate("button_pressed"))
		t.set_stylebox("disabled", kind, Art.plate("button_disabled"))
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_color("font_color", kind, BONE)
		t.set_color("font_hover_color", kind, OIL)
		t.set_color("font_pressed_color", kind, FIRE)
		t.set_color("font_focus_color", kind, BONE)
		t.set_color("font_disabled_color", kind, Color(BONE, 0.35))
		t.set_color("font_outline_color", kind, OIL)
	t.set_color("font_color", "Label", BONE)
	t.set_color("font_shadow_color", "Label", OIL)
	t.set_constant("shadow_offset_x", "Label", 1)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_stylebox("panel", "PopupMenu", Art.plate("panel"))
	t.set_color("font_color", "PopupMenu", BONE)
	t.set_color("font_hover_color", "PopupMenu", OIL)
	var hl := StyleBoxFlat.new()
	hl.bg_color = FIRE
	t.set_stylebox("hover", "PopupMenu", hl)
	t.set_color("default_color", "RichTextLabel", BONE)
	t.set_color("font_shadow_color", "RichTextLabel", OIL)
	t.set_constant("shadow_offset_x", "RichTextLabel", 1)
	t.set_constant("shadow_offset_y", "RichTextLabel", 1)
	t.set_constant("line_separation", "RichTextLabel", -2)
	t.set_font_size("normal_font_size", "RichTextLabel", BODY)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("1f1814")
	track.content_margin_left = 2
	track.content_margin_right = 2
	var grab := StyleBoxFlat.new()
	grab.bg_color = RUST
	var grab_hi := StyleBoxFlat.new()
	grab_hi.bg_color = ORANGE
	t.set_stylebox("scroll", "VScrollBar", track)
	t.set_stylebox("grabber", "VScrollBar", grab)
	t.set_stylebox("grabber_highlight", "VScrollBar", grab_hi)
	t.set_stylebox("grabber_pressed", "VScrollBar", grab_hi)
	return t


# ---------------------------------------------------------------- drawing helpers

## A riveted metal panel (or "card", a lighter plate).
static func panel(ci: CanvasItem, r: Rect2, kind: String = "panel") -> void:
	ci.draw_style_box(Art.plate(kind), r)


## Text with a one-pixel shadow. style: "body" (Micro 5), "head" or "title" (Jersey 10).
## pos is the baseline's left end.
static func text(ci: CanvasItem, pos: Vector2, s: String, col: Color = BONE, style: String = "body", width: float = -1.0) -> void:
	var f: Font = font if style == "body" else font_head
	var size: int = BODY if style == "body" else (HEAD if style == "head" else TITLE)
	pos = pos.round()
	ci.draw_string(f, pos + Vector2(1, 1), s, HORIZONTAL_ALIGNMENT_LEFT, width, size, Color(OIL, 0.85))
	ci.draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_LEFT, width, size, col)


static func text_width(s: String, style: String = "body") -> float:
	var f: Font = font if style == "body" else font_head
	var size: int = BODY if style == "body" else (HEAD if style == "head" else TITLE)
	return f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


static func text_centered(ci: CanvasItem, center_x: float, y: float, s: String, col: Color = BONE, style: String = "body") -> void:
	text(ci, Vector2(roundf(center_x - text_width(s, style) / 2.0), y), s, col, style)


## Wraps text into lines that fit a width (body font).
static func wrap(s: String, width: float) -> PackedStringArray:
	var out: PackedStringArray = []
	for para in s.split("\n"):
		var line := ""
		for word in para.split(" ", false):
			var trial := word if line == "" else line + " " + word
			if text_width(trial) > width and line != "":
				out.append(line)
				line = word
			else:
				line = trial
		out.append(line)
	return out


## A pixel bar with a dark frame and a lighter top row.
static func bar(ci: CanvasItem, r: Rect2, frac: float, col: Color) -> void:
	r = Rect2(r.position.round(), r.size.round())
	ci.draw_rect(r.grow(1), OIL)
	ci.draw_rect(r, ASH.darkened(0.3))
	var w := roundf(r.size.x * clampf(frac, 0.0, 1.0))
	if w > 0.0:
		ci.draw_rect(Rect2(r.position, Vector2(w, r.size.y)), col)
		ci.draw_rect(Rect2(r.position, Vector2(w, 1)), col.lightened(0.3))


## A dial gauge with E and F marks and a needle (doc 14: supply gauges are fuel gauges).
## center is the dial's pivot; it reads left (E) to right (F).
static func dial(ci: CanvasItem, center: Vector2, radius: float, frac: float, label: String, col: Color = FIRE, redline := 0.2) -> void:
	center = center.round()
	for ring in [[radius + 2, OIL], [radius + 1, ASH], [radius, Color("231d19")]]:
		var pts := PackedVector2Array()
		for i in 17:
			var a0 := PI + PI * i / 16.0
			pts.append(center + Vector2(cos(a0), sin(a0)) * float(ring[0]))
		pts.append(center + Vector2(ring[0], 2))
		pts.append(center + Vector2(-ring[0], 2))
		ci.draw_colored_polygon(pts, ring[1])
	for i in 9:
		var a := PI + PI * i / 8.0
		var d := Vector2(cos(a), sin(a))
		var tick_col := BLOOD if float(i) / 8.0 < redline else BONE.darkened(0.3)
		ci.draw_line(center + d * (radius - 2), center + d * radius, tick_col, 1.0)
	var f := clampf(frac, 0.0, 1.0)
	var a := PI + PI * f
	var needle_col := col if f >= redline else BLOOD.lightened(0.2)
	ci.draw_line(center, center + Vector2(cos(a), sin(a)) * (radius - 1), needle_col, 1.0)
	ci.draw_rect(Rect2(center - Vector2(1, 1), Vector2(2, 2)), CHROME)
	text(ci, center + Vector2(-radius, 7), "E", BLOOD.lightened(0.2))
	text(ci, center + Vector2(radius - 3, 7), "F", DIM)
	text_centered(ci, center.x, center.y - radius - 3, label, BONE)


## Builds a small button, wired to a callback.
static func button(parent: Node, label: String, pos: Vector2, size: Vector2, cb: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.position = pos
	b.add_theme_font_size_override("font_size", BODY)
	b.pressed.connect(cb)
	parent.add_child(b)
	b.size = size   # after joining the tree, so the size is checked against the themed minimum
	return b
