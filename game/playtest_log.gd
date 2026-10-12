## The playtest log: one JSON object per line, appended to user://playtest/log.jsonl, so testers
## can send it back and tools/playtest_report.py can set what players did against the benches.
##
## Where it lives (application/config/custom_user_dir_name is "Dark Horizon"):
##   Windows  %APPDATA%\Dark Horizon\playtest\log.jsonl
##   macOS    ~/Library/Application Support/Dark Horizon/playtest/log.jsonl
##   Linux    ~/.local/share/Dark Horizon/playtest/log.jsonl
##
## Every line has: t (unix seconds), session, build, kind. Kinds: session, skirmish, road_war,
## feel (a tester's "too easy / about right / too hard"), journey_start, card, journey_battle,
## journey_end. Nothing personal is recorded: no names, paths or hardware IDs.
extends RefCounted

const Game := preload("res://game/game.gd")

const DEFAULT_PATH := "user://playtest/log.jsonl"

static var path := DEFAULT_PATH    # tests point this elsewhere
static var session := ""


static func build_id() -> String:
	if FileAccess.file_exists("res://build.txt"):
		var f := FileAccess.open("res://build.txt", FileAccess.READ)
		return f.get_as_text().strip_edges()
	return "dev"


static func folder() -> String:
	return ProjectSettings.globalize_path(path.get_base_dir())


## Appends one record. Never throws: a log that can't be written must not stop the game.
static func write(kind: String, fields: Dictionary = {}) -> void:
	if session == "":
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		session = "%08x" % rng.randi()
		_append(_record("session", {"os": OS.get_name(), "godot": Engine.get_version_info()["string"], "locale": OS.get_locale_language()}))
	_append(_record(kind, fields))


static func _record(kind: String, fields: Dictionary) -> Dictionary:
	var r := {"t": int(Time.get_unix_time_from_system()), "session": session, "build": build_id(), "kind": kind}
	r.merge(fields)
	return r


static func _append(r: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
	if f == null:
		push_warning("playtest log: cannot write " + path)
		return
	f.seek_end()
	f.store_line(JSON.stringify(r))


static func count() -> int:
	if not FileAccess.file_exists(path):
		return 0
	return FileAccess.get_file_as_string(path).count("\n")


## "Too easy / About right / Too hard" under a result. One click logs it and locks the row.
static func feel_buttons(parent: Control, pos: Vector2, about: Dictionary) -> Array:
	var btns: Array = []
	var verdicts := [["too_easy", "Too easy"], ["about_right", "About right"], ["too_hard", "Too hard"]]
	for i in verdicts.size():
		var v: Array = verdicts[i]
		var b := Game.button(parent, v[1], pos + Vector2(i * 74, 0), Vector2(70, 14), func(): pass)
		btns.append(b)
	for i in btns.size():
		var verdict: String = verdicts[i][0]
		btns[i].pressed.connect(func():
			var rec := about.duplicate()
			rec["verdict"] = verdict
			write("feel", rec)
			for b in btns:
				b.disabled = true
			btns[i].text = "Noted"
		)
	return btns
