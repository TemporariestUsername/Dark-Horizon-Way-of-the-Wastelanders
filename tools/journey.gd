## Text UI for the event system (M2): drive a real route day by day and play the event cards.
##
##   godot --headless --path . --script res://tools/journey.gd -- --from lighthouse --to dustwich [--level 3]
##         [--seed 1] [--start-month 3] [--world-months 0] [--play]
##
## Without --play a sensible-player policy chooses. --world-months runs the world that many
## months first (so the Choir has spread and the factions have moved). --overlay prints the
## designer overlay: every draw's eligible events and weights.
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const World := preload("res://sim/world.gd")
const Journey := preload("res://sim/events/journey.gd")


func _init() -> void:
	var from := "lighthouse"
	var to := "dustwich"
	var level := 3
	var seed_n := 1
	var month := 3
	var world_months := 0
	var play := false
	var overlay := false
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		match args[i]:
			"--from": from = args[i + 1]
			"--to": to = args[i + 1]
			"--level": level = int(args[i + 1])
			"--seed": seed_n = int(args[i + 1])
			"--start-month": month = int(args[i + 1])
			"--world-months": world_months = int(args[i + 1])
			"--play": play = true
			"--overlay": overlay = true
	var data := SimData.new()
	data.load_all()
	var graph := RoadGraph.new()
	graph.build(data)
	var world = null
	if world_months > 0:
		world = World.new()
		world.setup(data, graph, seed_n)
		for m in world_months:
			world.world_turn()
		month = world.calendar_month
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_n
	var j := Journey.new()
	j.setup(data, graph, world, from, to, level, rng, month)
	j.echo = true
	if play:
		j.policy = func(e, choices, chances):
			while true:
				printraw("Choose 1-%d: " % choices.size())
				var line := OS.read_string_from_stdin(1024).strip_edges()
				if line.is_valid_int() and int(line) >= 1 and int(line) <= choices.size():
					return int(line) - 1
			return 0
	var stats := j.run()
	print("")
	print(JSON.stringify(stats))
	if overlay:
		for d in j.events.decisions:
			print("day %.0f at %s: %s <- %s" % [d["day"], d["hold"], d["pick"], d["eligible"]])
	quit()
