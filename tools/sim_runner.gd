## M1 headless simulation runner: runs the world turn for many seeds and reports against
## the balance targets in rules/factions.json and rules/choir.json.
##
##   godot --headless --path . --script res://tools/sim_runner.gd -- [--months 120] [--seeds 200] [--first-seed 1]
##
## Writes tools/out/report.md and tools/out/report.json, and prints the report.
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const World := preload("res://sim/world.gd")
const Lean := preload("res://sim/lean.gd")

var months := 120
var seeds := 200
var first_seed := 1
var faction_month := 48


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		match args[i]:
			"--months": months = int(args[i + 1])
			"--seeds": seeds = int(args[i + 1])
			"--first-seed": first_seed = int(args[i + 1])
	var t0 := Time.get_ticks_msec()
	var data := SimData.new()
	data.load_all()
	var graph := RoadGraph.new()
	graph.build(data)
	var runs: Array = []
	var sample_events: Array = []
	for s in range(first_seed, first_seed + seeds):
		var w := World.new()
		w.setup(data, graph, s)
		var snap48 := {}
		for m in months:
			w.world_turn()
			if w.month == faction_month:
				snap48 = _faction_snapshot(w)
		if snap48.is_empty():
			snap48 = _faction_snapshot(w)
		runs.append({"seed": s, "history": w.history, "factions": snap48, "final": _faction_snapshot(w)})
		if s == first_seed:
			sample_events = w.events.filter(func(e): return e["m"] <= 24)
	var secs := (Time.get_ticks_msec() - t0) / 1000.0
	var report := _report(data, runs, sample_events, secs)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/out"))
	var f := FileAccess.open("res://tools/out/report.md", FileAccess.WRITE)
	f.store_string(report["md"])
	f = FileAccess.open("res://tools/out/report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report["json"], " "))
	print(report["md"])
	quit(0 if report["json"]["all_pass"] else 1)


func _faction_snapshot(w) -> Dictionary:
	var leaning := {}
	for f in w.F:
		leaning[f] = w.holds_leaning_to(f).size()
	leaning["choir_lean"] = w.holds_leaning_to("choir").size()
	var ind0 := 0
	var ind_now := 0
	for id in w.H:
		if w.initial_leans[id] == Lean.IND:
			ind0 += 1
			if not w.H[id]["silenced"] and w.leans(id) == Lean.IND:
				ind_now += 1
	var changed := 0
	for id in w.first_change:
		if w.first_change[id] <= w.month:
			changed += 1
	var switched := 0
	for sid in w.S:
		if w.S[sid]["switches"] > 0:
			switched += 1
	var stages := {}
	var conquests := {}
	for f in w.F:
		stages[f] = w.F[f]["stage"]
		conquests[f] = w.F[f]["conquests"]
	return {
		"month": w.month,
		"alive": w.F.keys().filter(func(f): return w.F[f]["alive"]),
		"leaning": leaning,
		"changed": changed,
		"ind_share": float(ind_now) / max(ind0, 1),
		"switched": switched,
		"stages": stages,
		"conquests": conquests,
		"silenced": w.silenced_count(),
	}


static func _median(a: Array) -> float:
	if a.is_empty():
		return 0.0
	var b := a.duplicate()
	b.sort()
	var n := b.size()
	return float(b[n / 2]) if n % 2 == 1 else (float(b[n / 2 - 1]) + float(b[n / 2])) / 2.0


static func _pct(n: int, d: int) -> String:
	return "%d%%" % roundi(100.0 * n / max(d, 1))


func _report(data, runs: Array, sample_events: Array, secs: float) -> Dictionary:
	var n := runs.size()
	var bt: Dictionary = data.factions["balance_targets"]
	var cbt: Dictionary = data.choir["balance_targets"]
	var rows: Array = []

	var add_row := func(name: String, target: String, values: Array, ok_fn: Callable, required: bool = true) -> void:
		var passes: int = values.filter(ok_fn).size()
		var med: float = _median(values)
		var ok: bool = float(passes) / max(n, 1) >= 0.5
		rows.append({"target": name, "goal": target, "median": med, "min": values.min(), "max": values.max(),
			"pass_rate": float(passes) / max(n, 1), "ok": ok, "required": required})

	var fm := faction_month
	add_row.call("Factions alive at month %d" % fm, "%d–%d of 6" % [bt["factions_alive"][0], bt["factions_alive"][1]],
		runs.map(func(r): return r["factions"]["alive"].size()),
		func(v): return v >= bt["factions_alive"][0] and v <= bt["factions_alive"][1])
	add_row.call("Holds that changed Lean by month %d" % fm, "≥ %d" % bt["holds_changing_lean_min"],
		runs.map(func(r): return r["factions"]["changed"]), func(v): return v >= bt["holds_changing_lean_min"])
	add_row.call("Largest faction's share of holds, month %d" % fm, "≤ %d%%" % roundi(bt["max_faction_share"] * 100),
		runs.map(func(r):
			var mx := 0
			for f in r["factions"]["leaning"]:
				if f != "choir_lean":
					mx = max(mx, r["factions"]["leaning"][f])
			return float(mx) / 130.0),
		func(v): return v <= bt["max_faction_share"])
	add_row.call("Independents still independent, month %d" % fm, "≥ %d%%" % roundi(bt["independents_still_independent_min_share"] * 100),
		runs.map(func(r): return r["factions"]["ind_share"]), func(v): return v >= bt["independents_still_independent_min_share"])
	add_row.call("Sub-factions that switched backing by month %d" % fm, "≥ %d" % bt["subfactions_switching_backing_min"],
		runs.map(func(r): return r["factions"]["switched"]), func(v): return v >= bt["subfactions_switching_backing_min"])

	var wp: Dictionary = cbt["without_player"]
	var sil_at := func(r, m): return r["history"][min(m, r["history"].size() - 1)]["silenced"]
	if months >= 36:
		add_row.call("Silenced holds at month 36", "≤ %d" % wp["month_36_silenced_max"],
			runs.map(func(r): return sil_at.call(r, 36)), func(v): return v <= wp["month_36_silenced_max"])
	if months >= 60:
		add_row.call("Silenced holds at month 60", "%d–%d" % [wp["month_60_silenced_range"][0], wp["month_60_silenced_range"][1]],
			runs.map(func(r): return sil_at.call(r, 60)),
			func(v): return v >= wp["month_60_silenced_range"][0] and v <= wp["month_60_silenced_range"][1])
		add_row.call("Hum-touched sub-factions turned by month 60", "Family and Cross-folk (2)",
			runs.map(func(r): return r["history"][60]["turned"].filter(func(s): return cbt["turned_without_player_by_month_60"].has(s)).size()),
			func(v): return v >= cbt["turned_without_player_by_month_60"].size())
	if months >= 120:
		add_row.call("Silenced holds at month 120", "%d–%d" % [wp["month_120_silenced_range"][0], wp["month_120_silenced_range"][1]],
			runs.map(func(r): return sil_at.call(r, 120)),
			func(v): return v >= wp["month_120_silenced_range"][0] and v <= wp["month_120_silenced_range"][1])

	# (Lambdas capture locals by value, so the verdict is read back from the rows.)
	var all_pass := rows.all(func(r): return r["ok"] or not r["required"])
	var md := PackedStringArray()
	md.append("# M1 balance report")
	md.append("")
	md.append("%d seeds (%d–%d) × %d months, no player. Faction targets are read at month %d. Ran in %.1f s with Godot %s." % [
		n, first_seed, first_seed + n - 1, months, fm, secs, Engine.get_version_info()["string"]])
	md.append("")
	md.append("A target **passes** when at least half the seeds meet it.")
	md.append("")
	md.append("| Target | Goal | Median | Range | Seeds meeting it | |")
	md.append("|---|---|---|---|---|---|")
	for r in rows:
		md.append("| %s | %s | %s | %s–%s | %s | %s |" % [r["target"], r["goal"], _fmt(r["median"]), _fmt(r["min"]), _fmt(r["max"]),
			"%d%%" % roundi(r["pass_rate"] * 100), "✅" if r["ok"] else "❌"])

	md.append("")
	md.append("## The Choir's creep (median Silenced holds)")
	md.append("")
	var cols: Array = [12, 24, 36, 48, 60, 72, 96, 120].filter(func(m): return m <= months)
	md.append("| Month | " + " | ".join(cols.map(func(m): return str(m))) + " |")
	md.append("|---|" + "---|".repeat(cols.size()))
	md.append("| Silenced | " + " | ".join(cols.map(func(m): return _fmt(_median(runs.map(func(r): return r["history"][m]["silenced"]))))) + " |")
	md.append("| Voices | " + " | ".join(cols.map(func(m): return _fmt(_median(runs.map(func(r): return r["history"][m]["voices"]))))) + " |")
	md.append("| Most common reach | " + " | ".join(cols.map(func(m): return _mode(runs.map(func(r): return r["history"][m]["reach"])))) + " |")

	md.append("")
	md.append("## Factions at month %d (median across seeds; the last two columns cover the whole run)" % fm)
	md.append("")
	md.append("| Faction | Holds leaning at start | Holds leaning | Alive in | Conquests | Ambition stage reached | Falls by month %d in | Median month it falls |" % months)
	md.append("|---|---|---|---|---|---|---|---|")
	for f in data.factions["factions"]:
		var fid: String = f["id"]
		md.append("| %s | %s | %s | %s | %s | %s of 4 | %s | %s |" % [f["name"],
			_fmt(_median(runs.map(func(r): return r["history"][0]["leaning"].get(fid, 0)))),
			_fmt(_median(runs.map(func(r): return r["factions"]["leaning"][fid]))),
			_pct(runs.filter(func(r): return r["factions"]["alive"].has(fid)).size(), n),
			_fmt(_median(runs.map(func(r): return r["factions"]["conquests"][fid]))),
			_fmt(_median(runs.map(func(r): return r["factions"]["stages"][fid]))),
			_pct(runs.filter(func(r): return _fall_month(r, fid) > 0).size(), n),
			_fmt(_median(runs.map(func(r): return _fall_month(r, fid)).filter(func(m): return m > 0))) if runs.any(func(r): return _fall_month(r, fid) > 0) else "—"])
	md.append("| Independent | %s | %s | | | | | |" % [
		_fmt(_median(runs.map(func(r): return r["history"][0]["leaning"].get("independent", 0)))),
		_fmt(_median(runs.map(func(r): return r["factions"]["leaning"].get("independent", 0) if r["factions"]["leaning"].has("independent") else r["history"][min(fm, r["history"].size() - 1)]["leaning"].get("independent", 0))))])

	md.append("")
	md.append("## Economy (median across seeds)")
	md.append("")
	var ecols: Array = [0, 12, 24, 48].filter(func(m): return m <= months)
	md.append("| Month | " + " | ".join(ecols.map(func(m): return str(m))) + " |")
	md.append("|---|" + "---|".repeat(ecols.size()))
	for key in [["afflicted", "Holds with a want above its starting level"], ["mean_want", "Mean want level"],
			["price_water", "Water, mean buy price"], ["price_guzzoline", "Guzzoline, mean buy price"],
			["price_medicine", "Medicine, mean buy price"], ["contested", "Contested holds"]]:
		md.append("| %s | " % key[1] + " | ".join(ecols.map(func(m): return _fmt(_median(runs.map(func(r): return r["history"][m][key[0]]))))) + " |")

	md.append("")
	md.append("## Month Report sample (seed %d, first two years)" % first_seed)
	md.append("")
	var shown := 0
	for e in sample_events:
		if e["kind"] in ["affliction"]:
			continue
		md.append("- Month %d: %s" % [e["m"], e["text"]])
		shown += 1
		if shown >= 40:
			md.append("- …")
			break

	return {"md": "\n".join(md) + "\n", "json": {"seeds": n, "months": months, "rows": rows, "all_pass": all_pass}}


## The first month a faction is no longer alive, or 0 if it survives the run.
static func _fall_month(r: Dictionary, fid: String) -> int:
	for h in r["history"]:
		if not h["alive"].has(fid):
			return h["month"]
	return 0


static func _fmt(v: Variant) -> String:
	var f := float(v)
	if is_equal_approx(f, roundf(f)):
		return str(int(roundf(f)))
	return "%.2f" % f


static func _mode(a: Array) -> String:
	var c := {}
	for x in a:
		c[x] = c.get(x, 0) + 1
	var best := ""
	var bn := -1
	for k in c:
		if c[k] > bn:
			best = k
			bn = c[k]
	return best
