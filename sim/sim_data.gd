## Loads the game data (res://data) once. Read-only: a World copies what it mutates.
extends RefCounted

var holds: Array = []          # holds.json "holds", in file order
var hold_by_id: Dictionary = {}
var edges: Array = []          # roads.json "edges"
var resources: Dictionary = {} # id -> resource record
var economy: Dictionary = {}
var lean: Dictionary = {}
var time: Dictionary = {}
var factions: Dictionary = {}  # factions.json (whole file)
var faction_by_id: Dictionary = {}
var choir: Dictionary = {}
var subfactions: Dictionary = {}
var sub_by_id: Dictionary = {}
var war: Dictionary = {}
var characters: Dictionary = {}


static func read_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	assert(f != null, "cannot open " + path)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	assert(parsed != null, "bad JSON in " + path)
	return parsed


func load_all(root: String = "res://data") -> void:
	holds = read_json(root + "/world/holds.json")["holds"]
	for h in holds:
		hold_by_id[h["id"]] = h
	edges = read_json(root + "/world/roads.json")["edges"]
	for r in read_json(root + "/rules/resources.json")["resources"]:
		resources[r["id"]] = r
	economy = read_json(root + "/rules/economy.json")
	lean = read_json(root + "/rules/lean.json")
	time = read_json(root + "/rules/time.json")
	factions = read_json(root + "/rules/factions.json")
	for f in factions["factions"]:
		faction_by_id[f["id"]] = f
	choir = read_json(root + "/rules/choir.json")
	subfactions = read_json(root + "/rules/subfactions.json")
	for s in subfactions["subfactions"]:
		sub_by_id[s["id"]] = s
	war = read_json(root + "/rules/war.json")
	characters = read_json(root + "/rules/characters.json")


## Region names use non-breaking hyphens ("Sixty‑Five"); compare on a plain form.
static func norm(s: String) -> String:
	return s.replace("‑", "-").to_lower()
