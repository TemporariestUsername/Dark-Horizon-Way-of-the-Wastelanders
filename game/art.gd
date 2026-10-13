## Placeholder pixel art, generated in code from the doc 14 palette: people, beasts and rigs
## (side view), ground tiles, cover, road wrecks, icons, UI plates and the menu backdrop.
##
## Everything is built once, cached, and drawn at 1x on the 480x270 canvas. Sprites face right;
## the scenes flip enemies. A one-pixel dark outline is added around every sprite, which is
## what makes them read as solid shapes at this size (doc 14: "silhouette first").
##
## This is stand-in art, made to be readable and consistent until an artist replaces it.
## Rules from doc 14 hold here too: a hot world, and violet only for the Choir.
extends RefCounted

const OIL := Color("1b1714")
const ASH := Color("3a302a")
const ASPHALT := Color("2b2622")
const SAND := Color("d9a35b")
const OCHRE := Color("c27c2c")
const RUST := Color("8e3b1f")
const ORANGE := Color("e0621b")
const FIRE := Color("f5a623")
const BONE := Color("efe3c8")
const BLOOD := Color("9e1b1b")
const CHROME := Color("b8c0c2")
const STEEL := Color("2e5e63")
const TEAL := Color("6fa3a0")
const VIOLET := Color("8a5cf6")
const CHOIR_WHITE := Color("f4f1ea")
const NIGHT := Color("142226")
const CONCRETE := Color("8a8278")
const LEATHER := Color("5a3a22")
const WELL_BLUE := Color("2f6a9a")
const CLEAR_BLUE := Color("7fc4ea")

static var _cache := {}


# ---------------------------------------------------------------- a tiny pixel canvas

class Canvas:
	var img: Image
	var ox := 1     # drawing offset: one pixel of margin for the outline
	var oy := 1

	func _init(w: int, h: int) -> void:
		img = Image.create(w + 2, h + 2, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))

	func px(x: int, y: int, c: Color) -> void:
		var X := x + ox
		var Y := y + oy
		if X >= 0 and Y >= 0 and X < img.get_width() and Y < img.get_height():
			img.set_pixel(X, Y, c)

	func rect(x: int, y: int, w: int, h: int, c: Color) -> void:
		for i in w:
			for j in h:
				px(x + i, y + j, c)

	func hline(x0: int, x1: int, y: int, c: Color) -> void:
		for x in range(min(x0, x1), max(x0, x1) + 1):
			px(x, y, c)

	func vline(x: int, y0: int, y1: int, c: Color) -> void:
		for y in range(min(y0, y1), max(y0, y1) + 1):
			px(x, y, c)

	func line(x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
		var n: int = max(abs(x1 - x0), abs(y1 - y0))
		for i in n + 1:
			var t = float(i) / max(n, 1)
			px(roundi(lerpf(x0, x1, t)), roundi(lerpf(y0, y1, t)), c)

	func disc(cx: int, cy: int, r: float, c: Color) -> void:
		for x in range(cx - ceili(r), cx + ceili(r) + 1):
			for y in range(cy - ceili(r), cy + ceili(r) + 1):
				if Vector2(x - cx, y - cy).length() <= r + 0.25:
					px(x, y, c)

	func ellipse(cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
		for x in range(floori(cx - rx), ceili(cx + rx) + 1):
			for y in range(floori(cy - ry), ceili(cy + ry) + 1):
				var dx := (x - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.05:
					px(x, y, c)

	## Darkens some opaque pixels in a pseudo-random but fixed pattern (rust, grime).
	func grime(x0: int, y0: int, w: int, h: int, amount: float, seed: int, darken := 0.25) -> void:
		for x in range(x0, x0 + w):
			for y in range(y0, y0 + h):
				var X := x + ox
				var Y := y + oy
				if X < 0 or Y < 0 or X >= img.get_width() or Y >= img.get_height():
					continue
				var c := img.get_pixel(X, Y)
				if c.a > 0.0 and Canvas.hash01(x, y, seed) < amount:
					img.set_pixel(X, Y, c.darkened(darken))

	## A one-pixel outline around everything opaque.
	func outline(c: Color = OIL) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var src := img.duplicate()
		for x in w:
			for y in h:
				if src.get_pixel(x, y).a > 0.0:
					continue
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var q: Vector2i = Vector2i(x, y) + d
					if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and src.get_pixel(q.x, q.y).a > 0.5:
						img.set_pixel(x, y, c)
						break

	func texture() -> ImageTexture:
		return ImageTexture.create_from_image(img)

	static func hash01(x: int, y: int, seed: int) -> float:
		var h := (x * 374761393 + y * 668265263 + seed * 2147483647) & 0x7fffffff
		h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
		return float(h % 10007) / 10007.0


## Fixed pseudo-random noise in 0..1 for a pixel.
static func noise(x: int, y: int, seed: int = 0) -> float:
	return Canvas.hash01(x, y, seed)


static func _cached(key: String, make: Callable) -> Texture2D:
	if not _cache.has(key):
		_cache[key] = make.call()
	return _cache[key]


## A texture's variants: "flip" (mirrored), "flash" (white), "down" (lying), "dark", "silhouette".
static func variant(tex: Texture2D, kind: String, key: String) -> Texture2D:
	return _cached(key + "|" + kind, func():
		var img: Image = tex.get_image().duplicate()
		match kind:
			"flip":
				img.flip_x()
			"flash":
				for x in img.get_width():
					for y in img.get_height():
						if img.get_pixel(x, y).a > 0.0:
							img.set_pixel(x, y, Color(1, 1, 1, 1))
			"down":
				img.rotate_90(CLOCKWISE)
				for x in img.get_width():
					for y in img.get_height():
						var c := img.get_pixel(x, y)
						if c.a > 0.0:
							img.set_pixel(x, y, c.darkened(0.35))
			"silhouette":
				for x in img.get_width():
					for y in img.get_height():
						if img.get_pixel(x, y).a > 0.0:
							img.set_pixel(x, y, Color("1e1218"))
			"dark":
				for x in img.get_width():
					for y in img.get_height():
						var c := img.get_pixel(x, y)
						if c.a > 0.0:
							img.set_pixel(x, y, c.darkened(0.55))
		return ImageTexture.create_from_image(img))


# ---------------------------------------------------------------- people

## How each person looks: colors, head gear, body, weapon, extras.
const PEOPLE := {
	# The party (a teal armband marks the player's side).
	"driver": {"skin": "c08a5e", "hair": "3a2418", "cloth": "6b4226", "pants": "3a302a", "accent": "e0621b", "head": "goggles", "body": "coat", "weapon": "pistol", "extras": ["scarf", "band"]},
	"angel": {"skin": "e0b48a", "hair": "8a5a2a", "cloth": "c9c1a8", "pants": "4a4a3a", "accent": "6fa3a0", "head": "bandana", "body": "normal", "weapon": "pistol", "extras": ["satchel", "band"]},
	"gunlugger": {"skin": "8d5a3b", "hair": "1b1714", "cloth": "4f5a3a", "pants": "3a3a2a", "accent": "b8c0c2", "head": "helmet", "body": "big", "weapon": "heavy", "extras": ["plates", "band"]},
	"battlebabe": {"skin": "c08a5e", "hair": "9e1b1b", "cloth": "2b2622", "pants": "2b2622", "accent": "b8c0c2", "head": "bare", "body": "coat", "weapon": "machete", "extras": ["band"]},
	"chopper": {"skin": "c08a5e", "hair": "1b1714", "cloth": "3a2418", "pants": "2b2622", "accent": "e0621b", "head": "goggles", "body": "normal", "weapon": "crowbar", "extras": ["pad", "band"]},
	"hardholder": {"skin": "8d5a3b", "hair": "3a302a", "cloth": "6b5a3a", "pants": "3a302a", "accent": "f5a623", "head": "hat", "body": "big", "weapon": "shotgun", "extras": ["cape", "band"]},
	"hocus": {"skin": "e0b48a", "hair": "efe3c8", "cloth": "5a4a3a", "pants": "3a302a", "accent": "f5a623", "head": "hood", "body": "robe", "weapon": "none", "extras": ["band"]},
	"savvyhead": {"skin": "c08a5e", "hair": "3a2418", "cloth": "8a6a3a", "pants": "3a302a", "accent": "b8c0c2", "head": "goggles", "body": "normal", "weapon": "crowbar", "extras": ["satchel", "band"]},
	"quarantine": {"skin": "e0b48a", "hair": "3a2418", "cloth": "4a5a6a", "pants": "2b2622", "accent": "b8c0c2", "head": "bare", "body": "normal", "weapon": "rifle", "extras": ["band"]},
	"brainer": {"skin": "e0b48a", "hair": "1b1714", "cloth": "3a3a4a", "pants": "2b2622", "accent": "b8c0c2", "head": "bare", "body": "coat", "weapon": "none", "extras": ["band"]},
	# The Teeth: rust leather, red crests, war paint.
	"raider": {"skin": "c08a5e", "hair": "9e1b1b", "cloth": "5a2e1f", "pants": "2b2622", "accent": "9e1b1b", "head": "mohawk", "body": "normal", "weapon": "machete", "extras": ["pad", "paint"]},
	"raider_gunner": {"skin": "8d5a3b", "hair": "9e1b1b", "cloth": "5a2e1f", "pants": "2b2622", "accent": "9e1b1b", "head": "goggles", "body": "normal", "weapon": "pistol", "extras": ["pad", "paint"]},
	"raider_boss": {"skin": "c08a5e", "hair": "9e1b1b", "cloth": "3a1a12", "pants": "2b2622", "accent": "9e1b1b", "head": "skull", "body": "big", "weapon": "shotgun", "extras": ["pad", "cape"]},
	"dremmer": {"skin": "8d5a3b", "hair": "9e1b1b", "cloth": "3a1a12", "pants": "1b1714", "accent": "9e1b1b", "head": "skullhawk", "body": "big", "weapon": "machete", "extras": ["pad", "plates", "cape"]},
	# Toll men: ochre dusters and hats.
	"toll_man": {"skin": "c08a5e", "hair": "3a2418", "cloth": "8a6a3a", "pants": "3a302a", "accent": "efe3c8", "head": "hat", "body": "coat", "weapon": "crowbar", "extras": []},
	# Sweetwell's Wellguard: clear blue on chrome, sealed helmets.
	"wellguard": {"skin": "c08a5e", "hair": "1b1714", "cloth": "2f6a9a", "pants": "2b3a4a", "accent": "b8c0c2", "head": "sealed", "body": "normal", "weapon": "shotgun", "extras": ["plates"]},
	"wellguard_captain": {"skin": "c08a5e", "hair": "1b1714", "cloth": "2f6a9a", "pants": "2b3a4a", "accent": "b8c0c2", "head": "sealed", "body": "big", "weapon": "shotgun", "extras": ["plates", "cape"]},
	# Tum Tum's Catchers: bleached cloth, the Choir's violet sash.
	"catcher": {"skin": "c08a5e", "hair": "3a302a", "cloth": "d9d2c3", "pants": "8a8278", "accent": "8a5cf6", "head": "hood", "body": "normal", "weapon": "crowbar", "extras": ["sash"]},
	"catcher_netter": {"skin": "8d5a3b", "hair": "3a302a", "cloth": "d9d2c3", "pants": "8a8278", "accent": "8a5cf6", "head": "hood", "body": "normal", "weapon": "stun", "extras": ["sash", "net"]},
	"catcher_captain": {"skin": "c08a5e", "hair": "3a302a", "cloth": "efe3c8", "pants": "8a8278", "accent": "8a5cf6", "head": "hat", "body": "big", "weapon": "pistol", "extras": ["sash", "cape"]},
	"shan": {"skin": "8d5a3b", "hair": "1b1714", "cloth": "f4f1ea", "pants": "8a8278", "accent": "8a5cf6", "head": "hat", "body": "coat", "weapon": "pistol", "extras": ["sash", "cape"]},
	# The Choir: bleached white and violet. The Opened stand slack and empty.
	"opened": {"skin": "e8e4dc", "hair": "e8e4dc", "cloth": "f4f1ea", "pants": "c9c4ba", "accent": "8a5cf6", "head": "opened", "body": "normal", "weapon": "slack", "extras": []},
	"cantor": {"skin": "e8e4dc", "hair": "e8e4dc", "cloth": "4b2f7a", "pants": "4b2f7a", "accent": "f4f1ea", "head": "hood", "body": "robe", "weapon": "voice", "extras": []},
	"sings_back": {"skin": "e8e4dc", "hair": "e8e4dc", "cloth": "f4f1ea", "pants": "f4f1ea", "accent": "8a5cf6", "head": "hood", "body": "robe", "weapon": "voice", "extras": ["sash"]},
	"bounty_hunter": {"skin": "c08a5e", "hair": "3a2418", "cloth": "2e2a26", "pants": "1b1714", "accent": "b8c0c2", "head": "hat", "body": "coat", "weapon": "sniper", "extras": ["scarf"]},
}

const BEASTS := {
	"scavver": {"kind": "dog", "coat": "8a5a2a", "belly": "c08a5e", "eye": "1b1714"},
	"glass_eye": {"kind": "dog", "coat": "8a8278", "belly": "b8b0a4", "eye": "7fe6e0"},
	"feral_bull": {"kind": "bull", "coat": "5a3a22", "belly": "8a5a3a", "eye": "1b1714"},
}


## A person or beast for a skirmish unit, facing right.
static func unit(id: String) -> Texture2D:
	if BEASTS.has(id):
		return _cached("beast|" + id, func(): return _beast(BEASTS[id]))
	var spec: Dictionary = PEOPLE.get(id, PEOPLE["raider"])
	return _cached("person|" + id, func(): return _person(spec))


static func _person(s: Dictionary) -> Texture2D:
	var c := Canvas.new(16, 20)
	var skin := Color(s["skin"])
	var hair := Color(s["hair"])
	var cloth := Color(s["cloth"])
	var pants := Color(s["pants"])
	var accent := Color(s["accent"])
	var shade := cloth.darkened(0.3)
	var boots := Color("2b2622")
	var body: String = s["body"]
	var big := body == "big"
	var extras: Array = s["extras"]
	var x0 := 4 if big else 5      # torso left
	var x1 := 11 if big else 10    # torso right
	# Cape (behind everything).
	if extras.has("cape"):
		c.rect(x0 - 2, 7, 2, 10, accent.darkened(0.45) if accent != Color("b8c0c2") else Color("3a302a"))
		c.px(x0 - 3, 15, accent.darkened(0.45))
	# Legs and boots.
	if body != "robe":
		c.rect(x0 + 1, 13, 2, 5, pants.darkened(0.2))
		c.rect(x0 + 3 + (1 if big else 0), 13, 2, 5, pants)
		c.rect(x0 + 1, 18, 2, 2, boots)
		c.rect(x0 + 3 + (1 if big else 0), 18, 3, 2, boots)
	# Back arm.
	var back_arm := cloth.darkened(0.4)
	if s["weapon"] == "slack":
		c.vline(x0 - 1, 8, 14, back_arm)
		c.px(x0 - 1, 15, skin.darkened(0.2))
	else:
		c.vline(x0 - 1, 8, 11, back_arm)
		c.px(x0 - 1, 12, skin.darkened(0.2))
	# Torso.
	match body:
		"robe":
			for y in range(7, 20):
				var spread := (y - 7) / 4
				c.hline(x0 - spread, x1 + spread, y, cloth)
				c.px(x1 + spread, y, shade)
			c.hline(x0 - 3, x1 + 3, 19, cloth.darkened(0.2))
			c.vline((x0 + x1) / 2 + 1, 12, 19, accent)
		"coat":
			c.rect(x0, 7, x1 - x0 + 1, 9, cloth)
			c.vline(x1, 7, 15, shade)
			c.vline(x0 + 3, 12, 15, shade)
			c.hline(x0, x1, 11, cloth.darkened(0.15))
		_:
			c.rect(x0, 7, x1 - x0 + 1, 6, cloth)
			c.vline(x1, 7, 12, shade)
			c.hline(x0, x1, 12, Color("3a2418"))
			c.px(x0 + 3, 12, Color("b8c0c2"))
	if extras.has("plates"):
		c.hline(x0, x1, 8, Color("8a8278"))
		c.hline(x0, x1, 10, Color("8a8278"))
		c.px(x0 + 1, 8, CHROME)
		c.px(x1 - 1, 10, CHROME)
	if extras.has("sash"):
		c.line(x0, 7, x1, 12, accent)
	if extras.has("satchel"):
		c.line(x0 + 1, 7, x1 - 1, 11, Color("3a2418"))
		c.rect(x1 - 1, 11, 3, 3, Color("6b4226"))
		c.px(x1, 12, accent)
	if extras.has("band"):
		c.rect(x0 - 1, 9, 1, 2, TEAL)   # the party's armband
	if extras.has("pad"):
		c.rect(x0 - 2, 6, 4, 2, Color("8a8278"))
		c.px(x0 - 2, 5, CHROME)
		c.px(x0, 5, CHROME)
	if extras.has("scarf"):
		c.hline(x0 + 1, x1, 7, accent)
		c.px(x0 - 1, 8, accent)
	if extras.has("net"):
		for i in 4:
			for j in 4:
				if (i + j) % 2 == 0:
					c.px(x0 - 4 + i, 11 + j, Color("d9d2c3"))
	# Head.
	var hx := 6
	c.rect(hx, 2, 5, 5, skin)
	c.vline(hx + 4, 3, 6, skin.darkened(0.15))
	c.px(hx + 3, 4, OIL)                      # the eye (facing right)
	c.rect(hx, 2, 5, 1, hair)
	c.vline(hx, 2, 4, hair)
	c.rect(hx + 1, 7, 3, 1, skin.darkened(0.25))   # neck
	if extras.has("paint"):
		c.hline(hx + 1, hx + 4, 4, accent)
		c.px(hx + 3, 4, OIL)
	match s["head"]:
		"mohawk":
			c.rect(hx, 2, 5, 1, skin.darkened(0.1))
			for i in 4:
				c.px(hx + i, 1 - (i % 2), hair)
				c.px(hx + i, 1, hair)
		"skullhawk":
			_skull_face(c, hx)
			for i in 4:
				c.px(hx + i, 1 - (i % 2), hair)
				c.px(hx + i, 1, hair)
		"skull":
			_skull_face(c, hx)
		"helmet":
			c.rect(hx - 1, 1, 7, 3, Color("6a6a5a"))
			c.hline(hx - 1, hx + 5, 3, Color("4a4a3a"))
			c.px(hx + 1, 1, CHROME)
		"sealed":
			c.rect(hx - 1, 1, 7, 6, CHROME)
			c.rect(hx + 2, 3, 4, 2, CLEAR_BLUE)
			c.px(hx + 4, 3, Color.WHITE)
			c.hline(hx - 1, hx + 5, 6, Color("8a8278"))
		"hood":
			c.rect(hx - 1, 1, 6, 7, cloth)
			c.rect(hx + 2, 3, 3, 4, skin.darkened(0.5))
			c.px(hx + 3, 4, VIOLET if s["cloth"] in ["4b2f7a", "f4f1ea"] else FIRE.darkened(0.2))
			c.vline(hx - 1, 2, 7, cloth.darkened(0.25))
		"hat":
			c.hline(hx - 2, hx + 6, 2, Color("3a2418"))
			c.rect(hx, 0, 5, 2, Color("4a3020"))
			c.hline(hx, hx + 4, 1, accent if accent != Color("b8c0c2") else Color("6b4226"))
		"goggles":
			c.hline(hx, hx + 4, 3, Color("3a2418"))
			c.rect(hx + 3, 3, 2, 2, TEAL)
			c.px(hx + 4, 3, Color.WHITE)
		"bandana":
			c.rect(hx, 1, 5, 2, accent)
			c.px(hx - 1, 2, accent)
			c.px(hx - 2, 3, accent)
		"opened":
			c.rect(hx, 2, 5, 1, skin)
			c.px(hx + 3, 4, VIOLET)
			c.px(hx + 2, 4, VIOLET.darkened(0.3))
	# Front arm and weapon (the hand at about (x1 + 2, 10)).
	var hand := Vector2i(x1 + 2, 10)
	match s["weapon"]:
		"slack":
			c.vline(x1, 8, 13, cloth.darkened(0.15))
			c.px(x1, 14, skin)
		"voice":
			c.line(x1 - 1, 9, x1 + 1, 6, cloth.darkened(0.15))
			c.px(x1 + 2, 5, skin)
			c.px(x1 + 3, 4, VIOLET)
			c.px(x1 + 3, 6, Color(VIOLET, 0.7))
			c.px(x1 + 4, 5, Color(VIOLET, 0.5))
		"none":
			c.hline(x1 - 1, x1 + 1, 9, cloth.darkened(0.15))
			c.px(x1 + 2, 9, skin)
		_:
			c.line(x1 - 1, 8, x1 + 1, 10, cloth.darkened(0.15))
			c.px(hand.x, hand.y, skin)
			_weapon(c, s["weapon"], hand)
	return _finish(c)


static func _skull_face(c: Canvas, hx: int) -> void:
	c.rect(hx + 1, 2, 4, 5, BONE)
	c.px(hx + 2, 3, OIL)
	c.px(hx + 4, 3, OIL)
	c.hline(hx + 1, hx + 4, 6, Color("8a8278"))
	c.px(hx + 2, 6, BONE)
	c.px(hx + 4, 6, BONE)


static func _weapon(c: Canvas, w: String, h: Vector2i) -> void:
	var metal := Color("8a8278")
	var dark := Color("3a302a")
	var wood := Color("6b4226")
	match w:
		"pistol":
			c.hline(h.x, h.x + 3, h.y - 1, metal)
			c.px(h.x, h.y, dark)
		"stun":
			c.hline(h.x, h.x + 2, h.y - 1, dark)
			c.px(h.x + 3, h.y - 1, VIOLET)
		"shotgun", "rifle":
			c.hline(h.x - 3, h.x + 4, h.y - 1, metal)
			c.hline(h.x - 3, h.x - 1, h.y, wood)
			if w == "shotgun":
				c.hline(h.x, h.x + 3, h.y - 2, dark)
		"sniper":
			c.hline(h.x - 3, h.x + 5, h.y - 1, metal)
			c.hline(h.x - 3, h.x - 1, h.y, wood)
			c.hline(h.x, h.x + 2, h.y - 2, dark)
		"heavy":
			c.rect(h.x - 3, h.y - 2, 5, 3, dark)
			c.hline(h.x + 2, h.x + 5, h.y - 1, metal)
			c.px(h.x - 1, h.y - 2, CHROME)
			c.vline(h.x - 2, h.y + 1, h.y + 3, FIRE.darkened(0.3))
		"machete":
			c.line(h.x + 1, h.y - 1, h.x + 4, h.y - 5, CHROME)
			c.line(h.x + 2, h.y - 1, h.x + 4, h.y - 4, metal)
			c.px(h.x, h.y, dark)
		"crowbar":
			c.line(h.x, h.y + 1, h.x + 3, h.y - 5, Color("4a4a4a"))
			c.px(h.x + 4, h.y - 5, Color("4a4a4a"))


static func _beast(s: Dictionary) -> Texture2D:
	var coat := Color(s["coat"])
	var belly := Color(s["belly"])
	var eye := Color(s["eye"])
	if s["kind"] == "bull":
		var c := Canvas.new(24, 17)
		c.ellipse(10, 8, 8, 5, coat)
		c.ellipse(8, 5, 5, 3, coat.lightened(0.08))     # the hump
		c.hline(4, 16, 12, belly)
		for lx in [4, 7, 13, 16]:
			c.rect(lx, 12, 2, 4, coat.darkened(0.25))
			c.px(lx, 16, OIL)
			c.px(lx + 1, 16, OIL)
		c.rect(17, 5, 5, 6, coat)
		c.rect(21, 8, 2, 3, belly.darkened(0.2))
		c.px(20, 7, eye)
		c.line(18, 4, 21, 1, BONE)
		c.line(19, 4, 22, 2, BONE)
		c.line(0, 6, 2, 8, coat.darkened(0.3))
		c.grime(0, 0, 24, 17, 0.12, 7, 0.15)
		return _finish(c)
	var d := Canvas.new(20, 14)
	d.ellipse(9, 7, 6, 3, coat)
	d.hline(5, 13, 9, belly)
	for lx in [4, 6, 12, 14]:
		d.vline(lx, 9, 12, coat.darkened(0.25))
	d.rect(14, 3, 4, 4, coat)
	d.hline(17, 19, 6, coat.darkened(0.15))
	d.px(19, 5, OIL)
	d.px(15, 2, coat.darkened(0.3))
	d.px(16, 1, coat.darkened(0.3))
	d.px(16, 4, eye)
	if eye == Color("7fe6e0"):
		d.px(17, 4, eye)
		d.px(16, 3, Color.WHITE)
	d.line(0, 3, 3, 6, coat.darkened(0.2))
	d.grime(0, 0, 20, 14, 0.15, 3, 0.15)
	return _finish(d)


static func _finish(c: Canvas) -> Texture2D:
	c.outline()
	return c.texture()


# ---------------------------------------------------------------- rigs (side view, driving right)

## Body and trim colors by side and crew.
static func rig_colors(side: String, crew: String) -> Array:
	if side == "party":
		return [STEEL, TEAL]
	match crew:
		"teeth":
			return [RUST, BLOOD]
		"catchers":
			return [Color("cfc6b4"), VIOLET]
		"wellguard":
			return [WELL_BLUE, CHROME]
		"tollmen":
			return [OCHRE.darkened(0.15), BONE]
	return [RUST, ORANGE]


static func rig(frame: String, side: String, crew: String = "") -> Texture2D:
	return _cached("rig|%s|%s|%s" % [frame, side, crew], func(): return _rig(frame, side, crew))


static func _wheel(c: Canvas, x: int, y: int, r: int) -> void:
	c.disc(x, y, r, OIL)
	c.disc(x, y, max(1, r - 1), ASH)
	c.px(x, y, CHROME)


static func _window(c: Canvas, x: int, y: int, w: int, h: int) -> void:
	c.rect(x, y, w, h, NIGHT)
	c.px(x + w - 1, y, TEAL)
	if w > 2:
		c.px(x + w - 2, y, Color(TEAL, 0.6))


static func _rider(c: Canvas, x: int, y: int, cloth: Color, lean := true) -> void:
	c.rect(x, y, 3, 4, cloth)
	c.rect(x + (1 if lean else 0), y - 3, 3, 3, Color("c08a5e"))
	c.hline(x + (1 if lean else 0), x + (3 if lean else 2), y - 3, Color("3a2418"))
	c.px(x + (3 if lean else 2), y - 2, TEAL)


static func _gun(c: Canvas, x: int, y: int) -> void:
	c.rect(x, y, 3, 2, ASH)
	c.hline(x + 3, x + 5, y, CHROME)


static func _spikes(c: Canvas, x: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1, 2):
		c.px(x, y, CHROME)
		c.px(x + 1, y, CHROME.darkened(0.3))


static func _rig(frame: String, side: String, crew: String) -> Texture2D:
	var cols := rig_colors(side, crew)
	var body: Color = cols[0]
	var trim: Color = cols[1]
	var dark := body.darkened(0.35)
	var spiky := crew == "teeth"
	var rider_cloth: Color = Color("5a2e1f") if spiky else (Color("6b4226") if side == "party" else body.darkened(0.2))
	var c: Canvas
	match frame:
		"dirt_bike", "hog":
			var big := frame == "hog"
			c = Canvas.new(24 if big else 20, 15)
			var r := 3 if big else 2
			_wheel(c, 4, 11, r)
			_wheel(c, 19 if big else 15, 11, r)
			c.line(5, 9, 17 if big else 13, 8, ASH)
			c.rect(7, 7, 9 if big else 6, 3, body)
			c.hline(7, 15 if big else 12, 7, trim)
			c.rect(9, 9, 4, 2, ASH)
			c.line(17 if big else 13, 8, 19 if big else 15, 4, CHROME)
			if big:
				c.hline(2, 7, 10, CHROME.darkened(0.3))
			_rider(c, 10, 6, rider_cloth)
			if spiky:
				c.px(21, 7, CHROME)
				c.px(22, 8, CHROME)
		"sand_buggy":
			c = Canvas.new(28, 15)
			_wheel(c, 6, 11, 3)
			_wheel(c, 22, 11, 3)
			c.rect(3, 8, 23, 3, body)
			c.hline(3, 25, 8, trim)
			c.line(8, 8, 11, 2, ASH)
			c.line(11, 2, 19, 2, ASH)
			c.line(19, 2, 22, 8, ASH)
			c.vline(15, 2, 8, ASH)
			_rider(c, 12, 7, rider_cloth, false)
			_gun(c, 4, 6)
		"compact", "interceptor", "land_yacht":
			var low := frame == "interceptor"
			c = Canvas.new(30, 15 if frame != "land_yacht" else 24)
			var top := 9 if frame == "land_yacht" else 0
			c.rect(1, top + 6, 28, 5 if not low else 4, body)
			c.hline(1, 28, top + 6, body.lightened(0.15))
			c.hline(1, 28, top + 9, trim)
			c.rect(9 if not low else 11, top + 2 + (1 if low else 0), 11 if not low else 8, 4 if not low else 3, body)
			_window(c, 11 if not low else 12, top + 3 + (1 if low else 0), 7 if not low else 6, 2)
			_wheel(c, 7, top + 11, 3)
			_wheel(c, 22, top + 11, 3 if not low else 3)
			if low:
				c.rect(22, top + 4, 4, 2, CHROME)
				c.px(25, top + 3, CHROME)
				c.hline(0, 3, top + 9, CHROME.darkened(0.2))
			if frame == "land_yacht":
				c.vline(14, 0, top + 2, Color("6b4226"))
				for y in range(1, top + 1):
					c.hline(15, 15 + (y * 9) / max(top, 1), y, BONE.darkened(0.1))
		"pickup", "ute":
			c = Canvas.new(32, 16)
			c.rect(1, 7, 17, 5, body)
			c.hline(1, 17, 7, body.lightened(0.15))
			c.rect(17, 3, 9, 9, body)
			c.rect(25, 7, 6, 5, body)
			_window(c, 19, 4, 6, 3)
			c.hline(1, 30, 10, trim)
			_wheel(c, 7, 12, 3)
			_wheel(c, 25, 12, 3)
			if frame == "ute":
				c.disc(9, 5, 2, ASH)
				_gun(c, 8, 3)
				_gun(c, 2, 4)
			else:
				_gun(c, 8, 4)
			c.px(4, 5, Color("c08a5e"))
			c.px(12, 5, Color("c08a5e"))
		"bus":
			c = Canvas.new(40, 17)
			c.rect(1, 2, 38, 11, body)
			c.hline(1, 38, 2, body.lightened(0.15))
			for wx in range(4, 34, 6):
				_window(c, wx, 4, 4, 3)
			_window(c, 34, 4, 4, 4)
			c.hline(1, 38, 9, trim)
			_wheel(c, 8, 13, 3)
			_wheel(c, 31, 13, 3)
			_gun(c, 8, 0)
			_gun(c, 24, 0)
		"hauler", "tanker", "battle_rig":
			var w := 46 if frame == "battle_rig" else 44
			c = Canvas.new(w, 19 if frame == "battle_rig" else 17)
			var cab_x := w - 11
			if frame == "tanker":
				c.ellipse(16, 8, 15, 5, CHROME.darkened(0.25) if side != "party" else body)
				c.hline(2, 30, 4, CHROME)
				for bx in [8, 16, 24]:
					c.vline(bx, 4, 12, dark)
				c.rect(1, 12, 32, 2, ASH)
			else:
				c.rect(1, 2, cab_x - 2, 11, body if frame == "hauler" else dark)
				c.hline(1, cab_x - 2, 2, body.lightened(0.15))
				c.hline(1, cab_x - 2, 9, trim)
				if frame == "battle_rig":
					for px_ in range(3, cab_x - 2, 4):
						c.px(px_, 5, CHROME)
						c.px(px_, 11, CHROME)
					_gun(c, 5, 0)
					_gun(c, 15, 0)
					_gun(c, 25, 0)
				else:
					_gun(c, 10, 0)
			c.rect(cab_x, 3, 9, 10, body)
			c.rect(cab_x + 8, 7, 2, 6, body)
			_window(c, cab_x + 3, 4, 5, 3)
			c.vline(cab_x + 1, 0, 4, CHROME)
			c.px(cab_x + 1, 0, ASH)
			c.hline(cab_x, cab_x + 9, 10, trim)
			for wx in [6, 13, cab_x - 4, cab_x + 6]:
				_wheel(c, wx, 14 if frame != "battle_rig" else 15, 3)
			if frame == "battle_rig":
				c.rect(cab_x + 9, 5, 2, 9, Color("8a8278"))
				_spikes(c, cab_x + 11, 5, 13)
				c.grime(0, 0, w, 19, 0.18, 11)
		"half_track", "tank":
			c = Canvas.new(38 if frame == "tank" else 36, 17)
			c.rect(2, 11, 24, 5, OIL)
			for tx in range(3, 26, 3):
				c.px(tx, 12, ASH)
				c.px(tx, 15, ASH)
			if frame == "tank":
				c.rect(2, 6, 30, 5, body)
				c.rect(10, 2, 12, 4, body.lightened(0.1))
				c.hline(22, 36, 3, ASH)
				c.rect(26, 11, 8, 5, OIL)
			else:
				c.rect(1, 5, 32, 6, body)
				c.hline(1, 32, 5, body.lightened(0.15))
				c.rect(23, 1, 9, 5, body)
				_window(c, 25, 2, 6, 2)
				c.hline(1, 32, 8, trim)
				_wheel(c, 30, 13, 3)
				_gun(c, 6, 3)
				_gun(c, 14, 3)
		"ice_skiff":
			c = Canvas.new(28, 18)
			c.rect(2, 12, 24, 3, body)
			c.hline(1, 26, 15, CHROME)
			c.vline(12, 1, 11, Color("6b4226"))
			for y in range(2, 11):
				c.hline(13, 13 + y, y, BONE.darkened(0.1))
			_rider(c, 18, 11, rider_cloth)
		_:
			c = Canvas.new(20, 18)
			c.rect(2, 4, 16, 11, body)
			_window(c, 4, 6, 12, 4)
			c.vline(10, 0, 4, ASH)
	if spiky and frame in ["pickup", "ute", "sand_buggy", "compact", "interceptor", "hauler", "bus"]:
		var W := c.img.get_width() - 2
		_spikes(c, W - 1, 6, 12)
	c.grime(0, 0, c.img.get_width(), c.img.get_height(), 0.1, frame.length() * 13, 0.2)
	return _finish(c)


# ---------------------------------------------------------------- ground, cover, road

## A desert ground tile (size x size) for a skirmish grid square.
static func ground(variant_n: int, size: int = 20) -> Texture2D:
	return _cached("ground|%d|%d" % [variant_n, size], func():
		var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
		for x in size:
			for y in size:
				var n := noise(x, y, variant_n * 31 + 5)
				var col := SAND
				if n < 0.18:
					col = SAND.darkened(0.08)
				elif n < 0.22:
					col = OCHRE.darkened(0.05)
				elif n > 0.97:
					col = SAND.lightened(0.18)
				img.set_pixel(x, y, col)
		# A pebble or two and the odd crack.
		var px_ := int(noise(1, 1, variant_n) * (size - 3))
		var py_ := int(noise(2, 2, variant_n) * (size - 3))
		img.set_pixel(px_, py_, OCHRE.darkened(0.3))
		img.set_pixel(px_ + 1, py_, OCHRE.darkened(0.15))
		if variant_n % 3 == 0:
			var cx := int(noise(3, 3, variant_n) * (size - 8)) + 2
			var cy := int(noise(4, 4, variant_n) * (size - 4)) + 2
			for i in 6:
				img.set_pixel(cx + i, cy + (i / 2) % 2, SAND.darkened(0.22))
		return ImageTexture.create_from_image(img))


## Cover on a skirmish square: drums, a barrier, a wreck or scrap.
static func cover(kind: int) -> Texture2D:
	return _cached("cover|%d" % kind, func():
		var c := Canvas.new(18, 16)
		match kind % 4:
			0:   # two oil drums
				for dx in [1, 9]:
					c.rect(dx, 3, 7, 12, RUST)
					c.vline(dx + 6, 3, 14, RUST.darkened(0.3))
					c.hline(dx, dx + 6, 6, ORANGE.darkened(0.2))
					c.hline(dx, dx + 6, 11, ORANGE.darkened(0.2))
					c.hline(dx, dx + 6, 3, RUST.lightened(0.15))
				c.grime(0, 0, 18, 16, 0.25, 2)
			1:   # a concrete barrier
				c.rect(1, 6, 16, 9, CONCRETE)
				c.rect(3, 3, 12, 3, CONCRETE)
				c.hline(1, 16, 14, CONCRETE.darkened(0.3))
				c.hline(3, 14, 3, CONCRETE.lightened(0.15))
				for sx in range(2, 16, 4):
					c.px(sx, 9, FIRE.darkened(0.2))
					c.px(sx + 1, 9, FIRE.darkened(0.2))
				c.grime(0, 0, 18, 16, 0.2, 9)
			2:   # a car door and wheel, rusted out
				c.rect(2, 4, 12, 9, RUST.darkened(0.15))
				c.rect(4, 5, 7, 4, NIGHT)
				c.px(9, 5, TEAL.darkened(0.3))
				c.disc(14, 12, 3, OIL)
				c.disc(14, 12, 2, ASH)
				c.grime(0, 0, 18, 16, 0.35, 4, 0.3)
			3:   # scrap: sheet metal and pipe
				c.line(1, 14, 8, 4, ASH)
				c.line(2, 14, 9, 4, ASH)
				c.rect(6, 8, 10, 6, Color("6a6458"))
				c.line(3, 6, 16, 10, CHROME.darkened(0.25))
				c.px(12, 9, CHROME)
				c.grime(0, 0, 18, 16, 0.3, 6)
		c.outline()
		return c.texture())


## A tileable patch of asphalt for the road war.
static func asphalt() -> Texture2D:
	return _cached("asphalt", func():
		var s := 48
		var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
		for x in s:
			for y in s:
				var n := noise(x, y, 17)
				var col := ASPHALT
				if n < 0.12:
					col = ASPHALT.darkened(0.25)
				elif n > 0.9:
					col = ASPHALT.lightened(0.12)
				img.set_pixel(x, y, col)
		for i in 9:   # a crack
			img.set_pixel(10 + i, 20 + int(sin(i) * 1.5), ASPHALT.darkened(0.45))
		for x in range(30, 37):   # an oil stain
			for y in range(36, 40):
				if noise(x, y, 3) < 0.7:
					img.set_pixel(x, y, OIL)
		return ImageTexture.create_from_image(img))


## A dead car, a pileup or an overpass pillar in a road lane.
static func obstacle(kind: String) -> Texture2D:
	return _cached("obstacle|" + kind, func():
		var c: Canvas
		match kind:
			"pillar":
				c = Canvas.new(10, 20)
				c.rect(1, 2, 8, 18, CONCRETE)
				c.vline(8, 2, 19, CONCRETE.darkened(0.3))
				c.hline(0, 9, 2, CONCRETE.lightened(0.1))
				c.px(2, 0, ASH)
				c.px(2, 1, ASH)
				c.px(6, 0, ASH)
				c.px(6, 1, ASH)
				c.grime(0, 0, 10, 20, 0.2, 21)
			"pileup":
				c = Canvas.new(24, 15)
				c.rect(1, 9, 22, 5, RUST.darkened(0.2))
				c.rect(6, 6, 9, 3, RUST.darkened(0.2))
				c.rect(4, 3, 14, 5, Color("6b4a3a"))
				c.rect(7, 1, 6, 2, Color("6b4a3a"))
				c.rect(8, 4, 4, 2, NIGHT)
				c.grime(0, 0, 24, 15, 0.35, 5, 0.3)
			_:
				c = Canvas.new(22, 11)
				c.rect(1, 5, 20, 5, RUST.darkened(0.1))
				c.rect(6, 2, 9, 3, RUST.darkened(0.1))
				c.rect(7, 3, 6, 2, NIGHT)
				c.px(4, 10, OIL)
				c.px(17, 10, OIL)
				c.grime(0, 0, 22, 11, 0.35, 8, 0.3)
		c.outline()
		return c.texture())


## A hold's gate for the route strip: two posts and a lintel.
static func gate(silenced: bool) -> Texture2D:
	return _cached("gate|%s" % silenced, func():
		var c := Canvas.new(9, 9)
		var col := CHOIR_WHITE if silenced else RUST
		c.rect(0, 2, 2, 7, col)
		c.rect(7, 2, 2, 7, col)
		c.rect(0, 1, 9, 2, col.darkened(0.2))
		c.rect(2, 4, 5, 5, NIGHT if not silenced else VIOLET.darkened(0.3))
		c.px(4, 0, FIRE if not silenced else VIOLET)
		c.outline()
		return c.texture())


# ---------------------------------------------------------------- icons (7x7)

const ICONS := {
	"water": ["...b...", "..bbb..", ".bbbbb.", "bbbbbbb", "bbwbbbb", ".bbbbb.", "..bbb.."],
	"chow": [".ooooo.", "o.....o", "ccccccc", "cwccccc", "ccccccc", "ccccccc", ".ccccc."],
	"fuel": [".rrr...", "rrrrrr.", "rwrrrrr", "rr.r.rr", "rrr.rrr", "rr.r.rr", "rrrrrrr"],
	"barter": ["..mmm..", ".mmmmm.", "mmm.mmm", "mm...mm", "mmm.mmm", ".mmmmm.", "..mmm.."],
	"cargo": ["ooooooo", "o.o.o.o", "ooooooo", "o.o.o.o", "ooooooo", "o.o.o.o", "ooooooo"],
	"morale": ["..fff..", ".fffff.", "ff.f.ff", "fffffff", "f.fff.f", ".f...f.", "..fff.."],
	"hum": ["..vvv..", ".v...v.", "v..v..v", "v.vvv.v", "v..v..v", ".v...v.", "..vvv.."],
	"repairs": ["mm.....", "m.m....", ".mmm...", "..mmm..", "...mmm.", "....mmm", ".....mm"],
	"hp": [".bb.bb.", "bbbbbbb", "bwbbbbb", "bbbbbbb", ".bbbbb.", "..bbb..", "...b..."],
	"grit": ["...ff..", "..ff...", ".ffff..", "..ffff.", "...ff..", "..ff...", ".f....."],
	"battle": ["m.....m", ".m...m.", "..m.m..", "...m...", "..m.m..", ".o...o.", "o.....o"],
	"day": ["..f.f..", "...f...", "f.fff.f", ".fffff.", "f.fff.f", "...f...", "..f.f.."],
}
const ICON_COLORS := {"b": Color("7fc4ea"), "w": Color.WHITE, "o": Color("6b4226"), "c": Color("8a8278"), "r": Color("9e1b1b"),
	"m": Color("b8c0c2"), "f": Color("f5a623"), "v": Color("8a5cf6")}


static func icon(name: String) -> Texture2D:
	return _cached("icon|" + name, func():
		var rows: Array = ICONS.get(name, ICONS["cargo"])
		var img := Image.create(7, 7, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		for y in 7:
			for x in 7:
				var ch: String = rows[y][x]
				if ch != ".":
					var col: Color = ICON_COLORS[ch]
					if name == "hp" and ch == "b":
						col = BLOOD.lightened(0.15)
					img.set_pixel(x, y, col)
		return ImageTexture.create_from_image(img))


# ---------------------------------------------------------------- UI plates

## A riveted metal plate (9-slice).
static func plate(kind: String) -> StyleBoxTexture:
	var key := "plate|" + kind
	if _cache.has(key):
		return _cache[key]
	var fill := Color("231d19")
	var light := Color("4a3f36")
	var dark := OIL
	var rivets := true
	match kind:
		"button":
			fill = RUST
			light = Color("b8582c")
			dark = Color("5a2412")
			rivets = false
		"button_hover":
			fill = ORANGE
			light = FIRE
			dark = RUST
			rivets = false
		"button_pressed":
			fill = Color("6a2a14")
			light = Color("4a1c0c")
			dark = Color("b8582c")
			rivets = false
		"button_disabled":
			fill = Color("2e2622")
			light = Color("3a302a")
			dark = OIL
			rivets = false
		"card":
			fill = Color("2a221d")
			light = Color("5a4a3a")
	var s := 12
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	for x in s:
		for y in s:
			var col := fill
			if x == 0 or y == 0 or x == s - 1 or y == s - 1:
				col = OIL
			elif x == 1 or y == 1:
				col = light
			elif x == s - 2 or y == s - 2:
				col = dark
			elif noise(x, y, kind.length()) < 0.08:
				col = fill.darkened(0.12)
			img.set_pixel(x, y, col)
	if rivets:
		for p in [Vector2i(3, 3), Vector2i(s - 4, 3), Vector2i(3, s - 4), Vector2i(s - 4, s - 4)]:
			img.set_pixel(p.x, p.y, CHROME)
			img.set_pixel(p.x + 1, p.y + 1, OIL)
	var sb := StyleBoxTexture.new()
	sb.texture = ImageTexture.create_from_image(img)
	sb.texture_margin_left = 5
	sb.texture_margin_right = 5
	sb.texture_margin_top = 5
	sb.texture_margin_bottom = 5
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 1
	sb.content_margin_bottom = 2
	_cache[key] = sb
	return sb


# ---------------------------------------------------------------- the menu backdrop

const BAYER := [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


## Dithered blend between two colors (t 0..1) for a pixel.
static func dither(a: Color, b: Color, t: float, x: int, y: int) -> Color:
	return b if t * 16.0 > float(BAYER[y % 4][x % 4]) + 0.5 else a


## Sunset over the desert: a dithered sky, mesas, the sun, a broken overpass, smoke on the
## horizon, and an empty interstate running to it.
static func backdrop() -> Texture2D:
	return _cached("backdrop", func():
		var W := 480
		var H := 270
		var horizon := 128
		var up := horizon - 150   # everything below was laid out for a horizon at 150
		var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
		var sky := [Color("1e1428"), Color("3a1c34"), Color("6a2436"), Color("a8382a"), Color("e0621b"), Color("f5a623"), Color("f7c66b")]
		for y in horizon:
			var t := float(y) / horizon * (sky.size() - 1)
			var i := mini(int(t), sky.size() - 2)
			for x in W:
				img.set_pixel(x, y, dither(sky[i], sky[i + 1], t - i, x, y))
		# The sun, cut by bands of haze.
		var sun := Vector2(360, 128 + up)
		for x in range(int(sun.x) - 30, int(sun.x) + 31):
			for y in range(int(sun.y) - 30, horizon):
				var d := Vector2(x, y).distance_to(sun)
				if d <= 28.0 and not (y > sun.y and (y - int(sun.y)) % 5 == 0):
					img.set_pixel(x, y, dither(Color("f7c66b"), Color("fff0b0"), clampf(1.0 - d / 28.0, 0.0, 1.0), x, y))
		# Mesas on the horizon.
		var mesa := Color("4a2230")
		for x in W:
			var h := 0
			for m in [[20, 110, 14], [140, 200, 8], [250, 300, 18], [400, 470, 11]]:
				if x >= m[0] and x <= m[1]:
					var edge: int = min(x - m[0], m[1] - x)
					h = max(h, min(m[2], edge))
			for y in range(horizon - h, horizon):
				img.set_pixel(x, y, mesa)
		# Desert floor.
		for y in range(horizon, H):
			var t := float(y - horizon) / (H - horizon)
			for x in W:
				var col := dither(Color("8a4a1c"), Color("5a2e14"), t, x, y)
				if noise(x, y, 77) < 0.02:
					col = Color("a8682c")
				img.set_pixel(x, y, col)
		# The interstate, in perspective, with its centre line.
		var vp := Vector2(240, horizon)
		for y in range(horizon, H):
			var t := float(y - horizon) / (H - horizon)
			var half := 4.0 + t * 170.0
			for x in range(int(vp.x - half), int(vp.x + half) + 1):
				if x >= 0 and x < W:
					var col := Color("2b2622") if noise(x, y, 5) > 0.08 else Color("3a302a")
					img.set_pixel(x, y, col)
			if int(pow(t, 0.5) * 40.0) % 3 == 0:
				var dw := maxi(1, int(t * 6.0))
				for x in range(int(vp.x) - dw / 2, int(vp.x) + dw / 2 + 1):
					img.set_pixel(x, y, FIRE)
		# A broken overpass on the left.
		var deck := Color("2a1a22")
		for x in range(30, 170):
			for y in range(108 + up, 116 + up):
				if x < 160 or y < 112 + up - (x - 160):
					img.set_pixel(x, y, deck)
		for px_ in [55, 120]:
			for x in range(px_, px_ + 7):
				for y in range(116 + up, horizon):
					img.set_pixel(x, y, deck)
		for i in 6:
			img.set_pixel(163 + i, 107 + up - (i % 3), deck)
		# A smoke column far off on the right.
		for i in 14:
			var cx := 432 + int(sin(i * 0.9) * 4.0) + i
			var cy := horizon - 4 - i * 7
			var r := 3.0 + i * 0.7
			for x in range(cx - int(r), cx + int(r) + 1):
				for y in range(cy - int(r), cy + int(r) + 1):
					var dd := Vector2(x, y).distance_to(Vector2(cx, cy))
					if dd <= r and x >= 0 and x < W and y >= 0:
						var density := (1.0 - dd / r) * 1.6 - i * 0.05
						if dither(Color(0, 0, 0, 0), Color(1, 1, 1, 1), clampf(density, 0.0, 1.0), x, y).a > 0.5:
							img.set_pixel(x, y, Color("2a1e1e") if density > 0.6 else Color("3a2a2a"))
		return ImageTexture.create_from_image(img))
