## Event bench (M2): many journeys on each bench route (data/events/threats.json), checked
## against the pacing targets and the anti-frustration rules.
##
##   godot --headless --path . --script res://tools/event_bench.gd -- [--journeys 100]
##
## Writes tools/out/event_report.md; exits 1 if a route misses a target.
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const World := preload("res://sim/world.gd")
const Journey := preload("res://sim/events/journey.gd")

var journeys := 100


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--journeys":
			journeys = int(args[i + 1])
	var data := SimData.new()
	data.load_all()
	var graph := RoadGraph.new()
	graph.build(data)
	var tg: Dictionary = data.threats["targets"]
	var md := PackedStringArray()
	md.append("# M2 event bench")
	md.append("")
	md.append("%d journeys per route, the auto policy choosing (a sensible player: best expected value). A road day draws one road event or nothing; each hold passed draws a hold event or nothing." % journeys)
	md.append("")
	md.append("| Route | Level | Arrived | Days (median, expected) | Road events per road day | Hold events per visit | Battles per 10 days | Battles won | Lethal without warning | Longest bad streak | Days without water | Tone mix (good / neutral / bad / lethal) | |")
	md.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
	var all_ok := true
	var event_counts := {}
	for rt in data.threats["bench_routes"]:
		var world = null
		var month := int(rt["month"])
		if rt.has("world_months"):
			world = World.new()
			world.setup(data, graph, 1)
			for m in int(rt["world_months"]):
				world.world_turn()
			month = world.calendar_month
		var arrived := 0
		var days: Array = []
		var ev := 0
		var road_days := 0.0
		var rdays := 0
		var revents := 0
		var visits := 0
		var hevents := 0
		var battles := 0
		var won := 0
		var unwarned := 0
		var streak := 0
		var thirsty := 0
		var tones := {"good": 0, "neutral": 0, "bad": 0, "lethal": 0}
		var expected := 0.0
		for i in journeys:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash("%s|%s|%d" % [rt["from"], rt["to"], i])
			var j := Journey.new()
			j.setup(data, graph, world, rt["from"], rt["to"], int(rt["level"]), rng, month)
			var st := j.run()
			expected = st["expected_days"]
			if st["arrived"]:
				arrived += 1
			days.append(st["days"])
			ev += st["events"]
			road_days += st["days"]
			rdays += st["road_days"]
			revents += st["road_events"]
			visits += st["hold_visits"]
			hevents += st["hold_events"]
			battles += st["battles"]
			won += st["battles_won"]
			unwarned += st["lethal_unwarned"]
			streak = max(streak, st["max_bad_streak"])
			thirsty += st["days_out_of_water"]
			for t in st["by_tone"]:
				tones[t] += st["by_tone"][t]
			for d in j.events.decisions:
				if d["pick"] != "nothing":
					event_counts[d["pick"]] = event_counts.get(d["pick"], 0) + 1
		var epd = float(revents) / max(rdays, 1)
		var bp10 = battles / max(road_days, 1.0) * 10.0
		var arr := float(arrived) / journeys
		var ok: bool = arr >= float(tg["arrival_min"]) and epd >= float(tg["events_per_road_day"][0]) and epd <= float(tg["events_per_road_day"][1]) \
			and bp10 >= float(tg["battles_per_10_days"][0]) and bp10 <= float(tg["battles_per_10_days"][1]) \
			and unwarned <= int(tg["lethal_unwarned"]) and streak <= int(tg["max_bad_streak"])
		all_ok = all_ok and ok
		var tot: float = max(1, tones["good"] + tones["neutral"] + tones["bad"] + tones["lethal"])
		md.append("| %s (%s) | %d | %d%% | %.1f (%.1f) | %.2f | %.2f | %.2f | %d%% | %d | %d | %d | %d / %d / %d / %d%% | %s |" % [
			rt["note"], "%s → %s" % [data.hold_by_id[rt["from"]]["name"], data.hold_by_id[rt["to"]]["name"]], rt["level"],
			roundi(arr * 100), _median(days), expected, epd, float(hevents) / max(visits, 1), bp10, roundi(100.0 * won / max(battles, 1)), unwarned, streak, thirsty,
			roundi(tones["good"] / tot * 100), roundi(tones["neutral"] / tot * 100), roundi(tones["bad"] / tot * 100), roundi(tones["lethal"] / tot * 100),
			"✅" if ok else "❌"])
	md.append("")
	md.append("Targets: road events per road day %s–%s, battles per 10 days %s–%s, arrival ≥ %d%%, no lethal event without a warning, no more than %d bad events in a row." % [
		tg["events_per_road_day"][0], tg["events_per_road_day"][1], tg["battles_per_10_days"][0], tg["battles_per_10_days"][1], roundi(float(tg["arrival_min"]) * 100), tg["max_bad_streak"]])
	md.append("")
	md.append("## How often each event fired (all routes)")
	md.append("")
	var keys := event_counts.keys()
	keys.sort_custom(func(a, b): return event_counts[a] > event_counts[b])
	md.append(", ".join(keys.map(func(k): return "%s %d" % [k, event_counts[k]])))
	var never: Array = data.events["events"].map(func(e): return e["id"]).filter(func(id): return not event_counts.has(id))
	md.append("")
	md.append("Never fired on these routes: " + (", ".join(never) if not never.is_empty() else "none") + ".")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/out"))
	var f := FileAccess.open("res://tools/out/event_report.md", FileAccess.WRITE)
	f.store_string("\n".join(md) + "\n")
	print("\n".join(md))
	quit(0 if all_ok else 1)


static func _median(a: Array) -> float:
	var b := a.duplicate()
	b.sort()
	if b.is_empty():
		return 0.0
	var n := b.size()
	return float(b[n / 2]) if n % 2 == 1 else (float(b[n / 2 - 1]) + float(b[n / 2])) / 2.0
